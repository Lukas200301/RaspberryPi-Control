package main

import (
	"bufio"
	"bytes"
	"context"
	"io"
	"os"
	"os/exec"
	"regexp"
	"strconv"
	"strings"
	"time"

	pb "pi_agent/proto"
)

// A leading timestamp as written by PM2 (--time, --log-date-format) and
// most loggers: 2026-10-13T18:19:31: msg, 2026-10-13 18:19 +02:00: msg
var pm2LogTimePattern = regexp.MustCompile(
	`^(\d{4}-\d{2}-\d{2})[T ](\d{2}:\d{2}(?::\d{2}(?:\.\d{1,9})?)?)\s?(Z|[+-]\d{2}:?\d{2})?:?\s`)

type pm2LogSource struct {
	app    string
	pmID   int32
	stream string
}

type pm2LogEntry struct {
	src       pm2LogSource
	text      string
	message   string
	timestamp int64 // unix ms, 0 = unknown
	fromLog   bool
	sortKey   int64
}

func (e pm2LogEntry) toProto(history bool) *pb.Pm2LogLine {
	return &pb.Pm2LogLine{
		AppName:          e.src.app,
		PmId:             e.src.pmID,
		Stream:           e.src.stream,
		Text:             e.text,
		Message:          e.message,
		Timestamp:        e.timestamp,
		TimestampFromLog: e.fromLog,
		History:          history,
		ReceivedAt:       time.Now().UnixMilli(),
	}
}

// newPm2LogEntry uses the timestamp of the line, or fallback (unix ms) when
// the line has none
func newPm2LogEntry(src pm2LogSource, text string, fallback int64) pm2LogEntry {
	text = strings.TrimSuffix(stripANSI(text), "\r")
	e := pm2LogEntry{src: src, text: text, message: text, timestamp: fallback}
	if ts, rest, ok := parseLogTimestamp(text); ok {
		e.timestamp, e.message, e.fromLog = ts, rest, true
	}
	e.sortKey = e.timestamp
	return e
}

// parseLogTimestamp returns the unix ms of a leading timestamp and the rest
// of the line. Timestamps without a zone are in the local time of the Pi.
func parseLogTimestamp(line string) (int64, string, bool) {
	m := pm2LogTimePattern.FindStringSubmatch(line)
	if m == nil {
		return 0, line, false
	}

	clock := m[2]
	if len(clock) == 5 {
		clock += ":00"
	}
	value := m[1] + "T" + clock
	const layout = "2006-01-02T15:04:05.999999999"

	var t time.Time
	var err error
	if zone := m[3]; zone != "" {
		if zone != "Z" && !strings.Contains(zone, ":") {
			zone = zone[:3] + ":" + zone[3:]
		}
		t, err = time.Parse(layout+"Z07:00", value+zone)
	} else {
		t, err = time.ParseInLocation(layout, value, time.Local)
	}
	if err != nil {
		return 0, line, false
	}
	return t.UnixMilli(), line[len(m[0]):], true
}

// readPm2LogHistory returns the last n lines of a log file and the offset
// right after them, where following has to continue. timed reports whether
// the lines carry timestamps, so files can be merged chronologically.
func readPm2LogHistory(path string, n int, src pm2LogSource) (entries []pm2LogEntry, offset int64, timed bool) {
	f, err := os.Open(path)
	if err != nil {
		return nil, 0, true
	}
	defer f.Close()

	info, err := f.Stat()
	if err != nil {
		return nil, 0, true
	}

	lines, offset := lastLines(f, info.Size(), n)

	var firstTs, lastTs int64
	for _, line := range lines {
		e := newPm2LogEntry(src, line, 0)
		if e.fromLog {
			lastTs = e.timestamp
			if firstTs == 0 {
				firstTs = e.timestamp
			}
		} else {
			// Continuation lines (stack traces...) sort with the line before
			e.sortKey = lastTs
		}
		entries = append(entries, e)
	}
	for i := range entries {
		if entries[i].sortKey == 0 {
			entries[i].sortKey = firstTs
		}
	}

	return entries, offset, firstTs > 0 || len(entries) == 0
}

// lastLines reads the last n complete lines before size. The returned
// offset is the end of the last complete line: a line that is still being
// written is left to the follower.
func lastLines(f *os.File, size int64, n int) ([]string, int64) {
	const chunkSize = 64 * 1024
	const maxBytes = 16 << 20

	var buf []byte
	pos := size
	newlines := 0
	for pos > 0 && newlines <= n && len(buf) < maxBytes {
		read := int64(chunkSize)
		if pos < read {
			read = pos
		}
		pos -= read
		chunk := make([]byte, read)
		if _, err := f.ReadAt(chunk, pos); err != nil && err != io.EOF {
			break
		}
		newlines += bytes.Count(chunk, []byte{'\n'})
		buf = append(chunk, buf...)
	}

	last := bytes.LastIndexByte(buf, '\n')
	if last < 0 {
		return nil, pos
	}
	offset := pos + int64(last) + 1

	lines := strings.Split(string(buf[:last]), "\n")
	if pos > 0 {
		// Reading started in the middle of a line
		lines = lines[1:]
	}
	if len(lines) > n {
		lines = lines[len(lines)-n:]
	}
	return lines, offset
}

// followPm2LogFile streams lines appended to path after offset until ctx is
// done. tail -F keeps following across truncation (pm2 flush) and rotation.
func followPm2LogFile(ctx context.Context, path string, offset int64, src pm2LogSource, events chan<- pm2LogEntry) {
	cmd := exec.CommandContext(ctx, "tail", "-c", "+"+strconv.FormatInt(offset+1, 10), "-F", path)
	stdout, err := cmd.StdoutPipe()
	if err != nil {
		return
	}
	if err := cmd.Start(); err != nil {
		return
	}
	defer cmd.Wait()

	scanner := bufio.NewScanner(stdout)
	scanner.Buffer(make([]byte, 64*1024), 1024*1024)
	for scanner.Scan() {
		e := newPm2LogEntry(src, scanner.Text(), time.Now().UnixMilli())
		select {
		case events <- e:
		case <-ctx.Done():
			return
		}
	}
}

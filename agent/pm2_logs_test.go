package main

import (
	"os"
	"path/filepath"
	"strings"
	"testing"
	"time"
)

func TestParseLogTimestamp(t *testing.T) {
	local := func(s string) int64 {
		tm, err := time.ParseInLocation("2006-01-02T15:04:05", s, time.Local)
		if err != nil {
			t.Fatal(err)
		}
		return tm.UnixMilli()
	}

	cases := []struct {
		line    string
		ts      int64
		message string
		ok      bool
	}{
		{"2026-10-13T18:19:31: tick 1", local("2026-10-13T18:19:31"), "tick 1", true},
		{"2026-09-28T15:29:24: PM2 log: App [x:0] online", local("2026-09-28T15:29:24"), "PM2 log: App [x:0] online", true},
		{"2026-10-13 18:19 +02:00: hello", time.Date(2026, 10, 13, 16, 19, 0, 0, time.UTC).UnixMilli(), "hello", true},
		{"2026-10-13 18:19:31.250Z: utc", time.Date(2026, 10, 13, 18, 19, 31, 250e6, time.UTC).UnixMilli(), "utc", true},
		{"2026-10-13 18:19:31 +0100 msg", time.Date(2026, 10, 13, 17, 19, 31, 0, time.UTC).UnixMilli(), "msg", true},
		{"tick 1 without time", 0, "tick 1 without time", false},
		{"    at Object.<anonymous> (/app/x.js:1:1)", 0, "    at Object.<anonymous> (/app/x.js:1:1)", false},
	}
	for _, c := range cases {
		ts, message, ok := parseLogTimestamp(c.line)
		if ok != c.ok || ts != c.ts || message != c.message {
			t.Errorf("%q: got (%d, %q, %v), want (%d, %q, %v)", c.line, ts, message, ok, c.ts, c.message, c.ok)
		}
	}
}

func writeTemp(t *testing.T, content string) string {
	path := filepath.Join(t.TempDir(), "app-out.log")
	if err := os.WriteFile(path, []byte(content), 0644); err != nil {
		t.Fatal(err)
	}
	return path
}

func TestLastLines(t *testing.T) {
	cases := []struct {
		name    string
		content string
		n       int
		lines   []string
		offset  int64
	}{
		{"complete lines", "a\nb\nc\n", 2, []string{"b", "c"}, 6},
		{"all lines", "a\nb\n", 10, []string{"a", "b"}, 4},
		{"partial last line is left for the follower", "a\nb\nhalf", 5, []string{"a", "b"}, 4},
		{"empty file", "", 5, nil, 0},
		{"only a partial line", "half", 5, nil, 0},
		{"blank lines are kept", "a\n\nb\n", 5, []string{"a", "", "b"}, 5},
	}
	for _, c := range cases {
		f, err := os.Open(writeTemp(t, c.content))
		if err != nil {
			t.Fatal(err)
		}
		lines, offset := lastLines(f, int64(len(c.content)), c.n)
		f.Close()
		if strings.Join(lines, "|") != strings.Join(c.lines, "|") || offset != c.offset {
			t.Errorf("%s: got (%q, %d), want (%q, %d)", c.name, lines, offset, c.lines, c.offset)
		}
	}
}

func TestLastLinesAcrossChunks(t *testing.T) {
	var b strings.Builder
	for i := 0; i < 20000; i++ {
		b.WriteString(strings.Repeat("x", 30))
		b.WriteString("\n")
	}
	b.WriteString("last\n")
	content := b.String()

	f, err := os.Open(writeTemp(t, content))
	if err != nil {
		t.Fatal(err)
	}
	defer f.Close()

	lines, offset := lastLines(f, int64(len(content)), 3000)
	if len(lines) != 3000 || lines[len(lines)-1] != "last" || lines[0] != strings.Repeat("x", 30) {
		t.Fatalf("got %d lines, first %q, last %q", len(lines), lines[0], lines[len(lines)-1])
	}
	if offset != int64(len(content)) {
		t.Fatalf("offset %d, want %d", offset, len(content))
	}
}

func TestReadPm2LogHistoryInheritsTimestamps(t *testing.T) {
	path := writeTemp(t, "Error: boom\n2026-10-13T18:00:00: first\n    at stack\n2026-10-13T18:00:05: second\n")
	entries, _, timed := readPm2LogHistory(path, 10, pm2LogSource{"app", 0, "err"})
	if !timed || len(entries) != 4 {
		t.Fatalf("timed=%v entries=%d", timed, len(entries))
	}
	first, second := entries[1].timestamp, entries[3].timestamp
	if entries[0].sortKey != first || entries[2].sortKey != first || entries[3].sortKey != second {
		t.Errorf("sort keys %d %d %d %d", entries[0].sortKey, entries[1].sortKey, entries[2].sortKey, entries[3].sortKey)
	}
	if entries[2].timestamp != 0 || entries[2].fromLog {
		t.Errorf("continuation line must not get a displayed timestamp")
	}
}

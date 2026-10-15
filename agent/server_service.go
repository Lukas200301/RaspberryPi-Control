package main

import (
	"bufio"
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"os/exec"
	"strconv"
	"strings"
	"time"

	pb "pi_agent/proto"
)

// ListServices returns all systemd services
func (s *systemMonitorServer) ListServices(ctx context.Context, req *pb.Empty) (*pb.ServiceList, error) {
	cmd := exec.Command("systemctl", "list-units", "--type=service", "--all", "--no-pager", "--no-legend")
	output, err := cmd.Output()
	if err != nil {
		return nil, err
	}

	var services []*pb.ServiceInfo
	scanner := bufio.NewScanner(bytes.NewReader(output))
	for scanner.Scan() {
		line := scanner.Text()
		fields := strings.Fields(line)
		if len(fields) < 4 {
			continue
		}

		name := strings.TrimSuffix(fields[0], ".service")
		status := fields[2]
		subState := fields[3]

		// Get description
		description := ""
		if len(fields) > 4 {
			description = strings.Join(fields[4:], " ")
		}

		// Check if enabled
		enabled := false
		enabledCmd := exec.Command("systemctl", "is-enabled", fields[0])
		if out, err := enabledCmd.Output(); err == nil {
			enabled = strings.TrimSpace(string(out)) == "enabled"
		}

		services = append(services, &pb.ServiceInfo{
			Name:        name,
			Status:      status,
			Description: description,
			Enabled:     enabled,
			SubState:    subState,
		})
	}

	return &pb.ServiceList{Services: services}, nil
}

// ManageService controls systemd services
func (s *systemMonitorServer) ManageService(ctx context.Context, req *pb.ServiceCommand) (*pb.ActionStatus, error) {
	if !validUnitName(req.ServiceName) {
		return &pb.ActionStatus{Success: false, Message: "Invalid service name", ErrorCode: 1}, nil
	}
	var action string
	switch req.Action {
	case pb.ServiceAction_START:
		action = "start"
	case pb.ServiceAction_STOP:
		action = "stop"
	case pb.ServiceAction_RESTART:
		action = "restart"
	case pb.ServiceAction_ENABLE:
		action = "enable"
	case pb.ServiceAction_DISABLE:
		action = "disable"
	case pb.ServiceAction_RELOAD:
		action = "reload"
	default:
		return &pb.ActionStatus{
			Success:   false,
			Message:   "Unknown action",
			ErrorCode: 1,
		}, nil
	}

	cmd := exec.Command("systemctl", action, req.ServiceName)
	output, err := cmd.CombinedOutput()
	if err != nil {
		return &pb.ActionStatus{
			Success:   false,
			Message:   fmt.Sprintf("Failed to %s service %s: %v\n%s", action, req.ServiceName, err, string(output)),
			ErrorCode: 2,
		}, nil
	}

	return &pb.ActionStatus{
		Success: true,
		Message: fmt.Sprintf("Successfully %sed service %s", action, req.ServiceName),
	}, nil
}

// StreamLogs streams the systemd journal: the last TailLines entries, then new ones
func (s *systemMonitorServer) StreamLogs(req *pb.LogFilter, stream pb.SystemMonitor_StreamLogsServer) error {
	args := []string{"-f", "--no-pager", "-o", "json", "-n", strconv.Itoa(int(req.TailLines))}
	if req.Service != "" {
		if !validUnitName(req.Service) {
			return fmt.Errorf("invalid service name")
		}
		args = append(args, "-u", req.Service)
	}
	if len(req.Levels) > 0 {
		// journalctl takes one priority (and everything more severe)
		level := strings.ToLower(req.Levels[0])
		if level == "error" {
			level = "err"
		}
		valid := false
		for _, p := range journalPriorities {
			valid = valid || p == level
		}
		if !valid {
			return fmt.Errorf("invalid log level %q", req.Levels[0])
		}
		args = append(args, "-p", level)
	}

	// Stops journalctl as soon as the client goes away
	cmd := exec.CommandContext(stream.Context(), "journalctl", args...)
	stdout, err := cmd.StdoutPipe()
	if err != nil {
		return err
	}
	if err := cmd.Start(); err != nil {
		return err
	}
	defer func() { _ = cmd.Wait() }()

	scanner := bufio.NewScanner(stdout)
	scanner.Buffer(make([]byte, 64*1024), 4*1024*1024)
	for scanner.Scan() {
		entry := parseJournalLine(scanner.Bytes(), req.Service)
		if entry == nil {
			continue
		}
		if err := stream.Send(entry); err != nil {
			return err
		}
	}
	if stream.Context().Err() != nil {
		return nil
	}
	return scanner.Err()
}

var journalPriorities = []string{"emerg", "alert", "crit", "err", "warning", "notice", "info", "debug"}

// parseJournalLine turns one `journalctl -o json` line into a LogEntry
func parseJournalLine(line []byte, service string) *pb.LogEntry {
	var raw map[string]json.RawMessage
	if err := json.Unmarshal(line, &raw); err != nil {
		// Not JSON (old journalctl?): pass the text through
		text := strings.TrimSpace(string(line))
		if text == "" {
			return nil
		}
		return &pb.LogEntry{Timestamp: time.Now().Unix(), Level: "info", Service: service, Message: text}
	}
	str := func(key string) string {
		v, ok := raw[key]
		if !ok {
			return ""
		}
		var s string
		if json.Unmarshal(v, &s) == nil {
			return s
		}
		// Binary fields come as byte arrays
		var b []byte
		if json.Unmarshal(v, &b) == nil {
			return string(b)
		}
		return ""
	}

	entry := &pb.LogEntry{Level: "info", Message: strings.TrimRight(str("MESSAGE"), "\n")}
	if us, err := strconv.ParseInt(str("__REALTIME_TIMESTAMP"), 10, 64); err == nil {
		entry.Timestamp = us / 1_000_000
	} else {
		entry.Timestamp = time.Now().Unix()
	}
	if p, err := strconv.Atoi(str("PRIORITY")); err == nil && p >= 0 && p < len(journalPriorities) {
		entry.Level = journalPriorities[p]
	}
	entry.Service = str("SYSLOG_IDENTIFIER")
	if entry.Service == "" {
		entry.Service = strings.TrimSuffix(str("_SYSTEMD_UNIT"), ".service")
	}
	if pid := str("_PID"); pid != "" && entry.Service != "" {
		entry.Service += "[" + pid + "]"
	}
	return entry
}

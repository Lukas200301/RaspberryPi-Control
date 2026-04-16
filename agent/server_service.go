package main

import (
	"bufio"
	"bytes"
	"context"
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

// StreamLogs streams system logs in real-time
func (s *systemMonitorServer) StreamLogs(req *pb.LogFilter, stream pb.SystemMonitor_StreamLogsServer) error {
	args := []string{"-f", "--no-pager"}

	// Add tail lines if specified
	if req.TailLines > 0 {
		args = append(args, "-n", strconv.Itoa(int(req.TailLines)))
	}

	// Add service filter if specified
	if req.Service != "" {
		args = append(args, "-u", req.Service)
	}

	// Add level filters if specified
	if len(req.Levels) > 0 {
		for _, level := range req.Levels {
			args = append(args, "-p", level)
		}
	}

	cmd := exec.Command("journalctl", args...)
	stdout, err := cmd.StdoutPipe()
	if err != nil {
		return err
	}

	if err := cmd.Start(); err != nil {
		return err
	}

	defer cmd.Process.Kill()

	scanner := bufio.NewScanner(stdout)
	for scanner.Scan() {
		line := scanner.Text()

		// Parse journalctl output (simplified)
		entry := &pb.LogEntry{
			Timestamp: time.Now().Unix(),
			Level:     "info",
			Service:   req.Service,
			Message:   line,
		}

		if err := stream.Send(entry); err != nil {
			return err
		}

		// Check if client disconnected
		select {
		case <-stream.Context().Done():
			return nil
		default:
		}
	}

	return scanner.Err()
}

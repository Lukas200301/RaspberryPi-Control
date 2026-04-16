package main

import (
	"context"
	"fmt"

	"github.com/shirou/gopsutil/v3/process"

	pb "pi_agent/proto"
)

// ListProcesses returns all running processes
func (s *systemMonitorServer) ListProcesses(ctx context.Context, req *pb.Empty) (*pb.ProcessList, error) {
	procs, err := process.Processes()
	if err != nil {
		return nil, err
	}

	var result []*pb.ProcessInfo
	for _, p := range procs {
		name, _ := p.Name()
		cpuPercent, _ := p.CPUPercent()
		memPercent, _ := p.MemoryPercent()
		memInfo, _ := p.MemoryInfo()
		status, _ := p.Status()
		username, _ := p.Username()
		cmdline, _ := p.Cmdline()

		var memBytes uint64
		if memInfo != nil {
			memBytes = memInfo.RSS
		}

		// Convert status array to single string
		statusStr := ""
		if len(status) > 0 {
			statusStr = status[0]
		}

		ppid, _ := p.Ppid()

		result = append(result, &pb.ProcessInfo{
			Pid:           int32(p.Pid),
			Name:          name,
			CpuPercent:    cpuPercent,
			MemoryPercent: float64(memPercent),
			MemoryBytes:   memBytes,
			Status:        statusStr,
			Username:      username,
			Cmdline:       cmdline,
			Ppid:          ppid,
		})
	}

	return &pb.ProcessList{Processes: result}, nil
}

// KillProcess terminates a process by PID
func (s *systemMonitorServer) KillProcess(ctx context.Context, req *pb.ProcessId) (*pb.ActionStatus, error) {
	p, err := process.NewProcess(req.Pid)
	if err != nil {
		return &pb.ActionStatus{
			Success:   false,
			Message:   fmt.Sprintf("Process not found: %v", err),
			ErrorCode: 1,
		}, nil
	}

	name, _ := p.Name()
	if err := p.Kill(); err != nil {
		return &pb.ActionStatus{
			Success:   false,
			Message:   fmt.Sprintf("Failed to kill process %s (PID %d): %v", name, req.Pid, err),
			ErrorCode: 2,
		}, nil
	}

	return &pb.ActionStatus{
		Success: true,
		Message: fmt.Sprintf("Successfully killed process %s (PID %d)", name, req.Pid),
	}, nil
}

// PauseProcess sends SIGSTOP to a process
func (s *systemMonitorServer) PauseProcess(ctx context.Context, req *pb.ProcessId) (*pb.ActionStatus, error) {
	p, err := process.NewProcess(req.Pid)
	if err != nil {
		return &pb.ActionStatus{
			Success:   false,
			Message:   fmt.Sprintf("Process not found: %v", err),
			ErrorCode: 1,
		}, nil
	}

	name, _ := p.Name()
	if err := p.Suspend(); err != nil {
		return &pb.ActionStatus{
			Success:   false,
			Message:   fmt.Sprintf("Failed to pause process %s (PID %d): %v", name, req.Pid, err),
			ErrorCode: 2,
		}, nil
	}

	return &pb.ActionStatus{
		Success: true,
		Message: fmt.Sprintf("Successfully paused process %s (PID %d)", name, req.Pid),
	}, nil
}

// ResumeProcess sends SIGCONT to a process
func (s *systemMonitorServer) ResumeProcess(ctx context.Context, req *pb.ProcessId) (*pb.ActionStatus, error) {
	p, err := process.NewProcess(req.Pid)
	if err != nil {
		return &pb.ActionStatus{
			Success:   false,
			Message:   fmt.Sprintf("Process not found: %v", err),
			ErrorCode: 1,
		}, nil
	}

	name, _ := p.Name()
	if err := p.Resume(); err != nil {
		return &pb.ActionStatus{
			Success:   false,
			Message:   fmt.Sprintf("Failed to resume process %s (PID %d): %v", name, req.Pid, err),
			ErrorCode: 2,
		}, nil
	}

	return &pb.ActionStatus{
		Success: true,
		Message: fmt.Sprintf("Successfully resumed process %s (PID %d)", name, req.Pid),
	}, nil
}

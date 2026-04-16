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

		result = append(result, &pb.ProcessInfo{
			Pid:           int32(p.Pid),
			Name:          name,
			CpuPercent:    cpuPercent,
			MemoryPercent: float64(memPercent),
			MemoryBytes:   memBytes,
			Status:        statusStr,
			Username:      username,
			Cmdline:       cmdline,
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

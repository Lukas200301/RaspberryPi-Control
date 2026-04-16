package main

import (
	"context"
	"os"
	"time"

	"github.com/shirou/gopsutil/v3/disk"
	"github.com/shirou/gopsutil/v3/process"

	pb "pi_agent/proto"
)

type systemMonitorServer struct {
	pb.UnimplementedSystemMonitorServer
	processCache     map[int32]*process.Process
	processCacheTime time.Time
	topProcesses     []*pb.ProcessInfo
	topProcessesTime time.Time
	prevDiskIO       map[string]disk.IOCountersStat
	prevDiskIOTime   time.Time
}

// GetVersion returns the agent version and privilege status
func (s *systemMonitorServer) GetVersion(ctx context.Context, req *pb.Empty) (*pb.VersionInfo, error) {
	// Check if running as root
	isRoot := os.Geteuid() == 0

	return &pb.VersionInfo{
		Version: Version,
		IsRoot:  isRoot,
	}, nil
}

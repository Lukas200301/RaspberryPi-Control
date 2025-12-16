package main

import (
	"bufio"
	"bytes"
	"context"
	"fmt"
	"log"
	"os/exec"
	"strconv"
	"strings"
	"time"

	"github.com/shirou/gopsutil/v3/cpu"
	"github.com/shirou/gopsutil/v3/disk"
	"github.com/shirou/gopsutil/v3/host"
	"github.com/shirou/gopsutil/v3/load"
	"github.com/shirou/gopsutil/v3/mem"
	"github.com/shirou/gopsutil/v3/net"
	"github.com/shirou/gopsutil/v3/process"

	pb "pi_agent/proto"
)

type systemMonitorServer struct {
	pb.UnimplementedSystemMonitorServer
	processCache       map[int32]*process.Process
	processCacheTime   time.Time
	topProcesses       []*pb.ProcessInfo
	topProcessesTime   time.Time
}

// StreamStats sends real-time system statistics every 1000ms
func (s *systemMonitorServer) StreamStats(req *pb.Empty, stream pb.SystemMonitor_StreamStatsServer) error {
	ticker := time.NewTicker(1000 * time.Millisecond)
	defer ticker.Stop()

	var prevNet netStats
	firstRun := true

	for {
		select {
		case <-stream.Context().Done():
			return nil
		case <-ticker.C:
			stats, err := collectStats()
			if err != nil {
				log.Printf("Error collecting stats: %v", err)
				continue
			}

			// Calculate network speed (bytes per second)
			if !firstRun {
				// Store the raw counters before calculating the rate
				currentSent := stats.NetBytesSent
				currentRecv := stats.NetBytesRecv

				// Calculate rate (already per second since interval is 1s)
				stats.NetBytesSent = currentSent - prevNet.sent
				stats.NetBytesRecv = currentRecv - prevNet.recv

				// Prevent negative values from counter resets
				if stats.NetBytesSent > 1e12 { // Unreasonably large, likely overflow
					stats.NetBytesSent = 0
				}
				if stats.NetBytesRecv > 1e12 {
					stats.NetBytesRecv = 0
				}

				// Update previous counters with raw values
				prevNet = netStats{sent: currentSent, recv: currentRecv}
			} else {
				firstRun = false
				prevNet = netStats{sent: stats.NetBytesSent, recv: stats.NetBytesRecv}
				stats.NetBytesSent = 0
				stats.NetBytesRecv = 0
			}

			// Update top processes every 2 seconds
			now := time.Now()
			if now.Sub(s.topProcessesTime) > 2*time.Second || s.topProcesses == nil {
				topProcs, err := s.getTopProcessesOptimized(5)
				if err == nil {
					s.topProcesses = topProcs
					s.topProcessesTime = now
				}
			}
			stats.TopProcesses = s.topProcesses

			if err := stream.Send(stats); err != nil {
				return err
			}
		}
	}
}

type netStats struct {
	sent uint64
	recv uint64
}

// collectStats gathers all system statistics
func collectStats() (*pb.LiveStats, error) {
	stats := &pb.LiveStats{
		Timestamp: time.Now().Unix(),
	}

	// CPU usage (use 100ms interval for more accurate reading)
	cpuPercents, err := cpu.Percent(100*time.Millisecond, true)
	if err == nil {
		stats.CpuPerCore = cpuPercents
		if len(cpuPercents) > 0 {
			var total float64
			for _, p := range cpuPercents {
				total += p
			}
			stats.CpuUsage = total / float64(len(cpuPercents))
		}
	}

	// Memory
	vmem, err := mem.VirtualMemory()
	if err == nil {
		stats.RamUsed = vmem.Used
		stats.RamTotal = vmem.Total
		stats.RamFree = vmem.Free
		stats.RamCached = vmem.Cached
	}

	// Swap
	swap, err := mem.SwapMemory()
	if err == nil {
		stats.SwapUsed = swap.Used
		stats.SwapTotal = swap.Total
	}

	// Temperature (Raspberry Pi specific)
	temp := getCPUTemperature()
	stats.CpuTemp = temp
	stats.GpuTemp = getGPUTemperature()

	// Uptime
	uptime, err := host.Uptime()
	if err == nil {
		stats.Uptime = uptime
	}

	// Load average
	loadAvg, err := load.Avg()
	if err == nil {
		stats.Load_1Min = loadAvg.Load1
		stats.Load_5Min = loadAvg.Load5
		stats.Load_15Min = loadAvg.Load15
	}

	// Network
	netIO, err := net.IOCounters(false)
	if err == nil && len(netIO) > 0 {
		stats.NetBytesSent = netIO[0].BytesSent
		stats.NetBytesRecv = netIO[0].BytesRecv
	}

	// Top processes - only update every 2 seconds to reduce CPU load
	// This is called from StreamStats which runs every 1s, so we alternate
	return stats, nil
}

// Helper to collect top processes efficiently
func (s *systemMonitorServer) getTopProcessesOptimized(n int) ([]*pb.ProcessInfo, error) {
	// Refresh process cache every 2 seconds
	now := time.Now()
	if now.Sub(s.processCacheTime) > 2*time.Second || s.processCache == nil {
		s.processCache = make(map[int32]*process.Process)
		procs, err := process.Processes()
		if err != nil {
			return nil, err
		}
		for _, p := range procs {
			s.processCache[p.Pid] = p
		}
		s.processCacheTime = now
	}

	type procWithCPU struct {
		proc *process.Process
		cpu  float64
	}

	var procsWithCPU []procWithCPU

	// Sample more processes to get a better view of system activity
	// We'll check up to 300 processes to catch most active ones
	count := 0
	maxSample := 300

	for _, p := range s.processCache {
		if count >= maxSample {
			break
		}

		// Use non-blocking CPU percent call
		cpuPercent, err := p.CPUPercent()
		if err != nil {
			continue
		}

		// Include all processes, even with 0% CPU to avoid flickering
		// We'll sort them later and only show top N
		procsWithCPU = append(procsWithCPU, procWithCPU{proc: p, cpu: cpuPercent})
		count++
	}

	// Simple selection sort for top N
	for i := 0; i < len(procsWithCPU) && i < n; i++ {
		maxIdx := i
		for j := i + 1; j < len(procsWithCPU); j++ {
			if procsWithCPU[j].cpu > procsWithCPU[maxIdx].cpu {
				maxIdx = j
			}
		}
		if maxIdx != i {
			procsWithCPU[i], procsWithCPU[maxIdx] = procsWithCPU[maxIdx], procsWithCPU[i]
		}
	}

	// Convert to protobuf
	var result []*pb.ProcessInfo
	for i := 0; i < len(procsWithCPU) && i < n; i++ {
		p := procsWithCPU[i].proc
		name, _ := p.Name()
		memPercent, _ := p.MemoryPercent()
		memInfo, _ := p.MemoryInfo()
		status, _ := p.Status()
		username, _ := p.Username()
		cmdline, _ := p.Cmdline()

		var memBytes uint64
		if memInfo != nil {
			memBytes = memInfo.RSS
		}

		statusStr := ""
		if len(status) > 0 {
			statusStr = status[0]
		}

		result = append(result, &pb.ProcessInfo{
			Pid:           int32(p.Pid),
			Name:          name,
			CpuPercent:    procsWithCPU[i].cpu,
			MemoryPercent: float64(memPercent),
			MemoryBytes:   memBytes,
			Status:        statusStr,
			Username:      username,
			Cmdline:       cmdline,
		})
	}

	return result, nil
}

// getCPUTemperature reads CPU temperature from Raspberry Pi thermal zone
func getCPUTemperature() float64 {
	// Try reading from thermal zone (common on Raspberry Pi)
	data, err := exec.Command("cat", "/sys/class/thermal/thermal_zone0/temp").Output()
	if err == nil {
		temp := strings.TrimSpace(string(data))
		if val, err := strconv.ParseFloat(temp, 64); err == nil {
			return val / 1000.0 // Convert millidegrees to degrees
		}
	}

	// Fallback: try vcgencmd (Raspberry Pi specific)
	data, err = exec.Command("vcgencmd", "measure_temp").Output()
	if err == nil {
		// Output format: temp=42.8'C
		temp := strings.TrimSpace(string(data))
		temp = strings.TrimPrefix(temp, "temp=")
		temp = strings.TrimSuffix(temp, "'C")
		if val, err := strconv.ParseFloat(temp, 64); err == nil {
			return val
		}
	}

	return 0.0
}

// getGPUTemperature reads GPU temperature (Raspberry Pi specific)
func getGPUTemperature() float64 {
	data, err := exec.Command("vcgencmd", "measure_temp").Output()
	if err == nil {
		temp := strings.TrimSpace(string(data))
		temp = strings.TrimPrefix(temp, "temp=")
		temp = strings.TrimSuffix(temp, "'C")
		if val, err := strconv.ParseFloat(temp, 64); err == nil {
			return val
		}
	}
	return 0.0
}


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

// GetDiskInfo returns disk usage information
func (s *systemMonitorServer) GetDiskInfo(ctx context.Context, req *pb.Empty) (*pb.DiskInfo, error) {
	partitions, err := disk.Partitions(false)
	if err != nil {
		return nil, err
	}

	var diskPartitions []*pb.DiskPartition
	for _, partition := range partitions {
		usage, err := disk.Usage(partition.Mountpoint)
		if err != nil {
			continue
		}

		diskPartitions = append(diskPartitions, &pb.DiskPartition{
			Device:       partition.Device,
			MountPoint:   partition.Mountpoint,
			Filesystem:   partition.Fstype,
			TotalBytes:   usage.Total,
			UsedBytes:    usage.Used,
			FreeBytes:    usage.Free,
			UsagePercent: usage.UsedPercent,
		})
	}

	return &pb.DiskInfo{Partitions: diskPartitions}, nil
}

// GetNetworkInfo returns network interface information
func (s *systemMonitorServer) GetNetworkInfo(ctx context.Context, req *pb.Empty) (*pb.NetworkInfo, error) {
	interfaces, err := net.Interfaces()
	if err != nil {
		return nil, err
	}

	var networkInterfaces []*pb.NetworkInterface
	for _, iface := range interfaces {
		// Get addresses for this interface (Addrs is already a slice in gopsutil)
		var addresses []string
		for _, addr := range iface.Addrs {
			addresses = append(addresses, addr.Addr)
		}

		// Get interface stats
		ioStats, err := net.IOCounters(true)
		var bytesSent, bytesRecv, packetsSent, packetsRecv uint64
		if err == nil {
			for _, stat := range ioStats {
				if stat.Name == iface.Name {
					bytesSent = stat.BytesSent
					bytesRecv = stat.BytesRecv
					packetsSent = stat.PacketsSent
					packetsRecv = stat.PacketsRecv
					break
				}
			}
		}

		networkInterfaces = append(networkInterfaces, &pb.NetworkInterface{
			Name:        iface.Name,
			Addresses:   addresses,
			MacAddress:  iface.HardwareAddr, // In gopsutil, this is already a string
			IsUp:        iface.Flags != nil && len(iface.Flags) > 0 && iface.Flags[0] == "up",
			BytesSent:   bytesSent,
			BytesRecv:   bytesRecv,
			PacketsSent: packetsSent,
			PacketsRecv: packetsRecv,
		})
	}

	return &pb.NetworkInfo{Interfaces: networkInterfaces}, nil
}

func (s *systemMonitorServer) GetNetworkConnections(ctx context.Context, req *pb.Empty) (*pb.NetworkConnectionList, error) {
	// Get all TCP and UDP connections
	conns, err := net.Connections("all")
	if err != nil {
		return nil, err
	}

	var networkConnections []*pb.NetworkConnection
	for _, conn := range conns {
		// Get process name if PID is available
		processName := ""
		if conn.Pid != 0 {
			proc, err := process.NewProcess(conn.Pid)
			if err == nil {
				name, err := proc.Name()
				if err == nil {
					processName = name
				}
			}
		}

		// Convert connection type to string
		protocol := ""
		switch conn.Type {
		case 1:
			protocol = "TCP"
		case 2:
			protocol = "UDP"
		case 3:
			protocol = "TCP6"
		case 4:
			protocol = "UDP6"
		default:
			protocol = fmt.Sprintf("UNKNOWN(%d)", conn.Type)
		}

		// Format addresses
		localAddr := conn.Laddr.IP
		remoteAddr := conn.Raddr.IP

		networkConnections = append(networkConnections, &pb.NetworkConnection{
			Protocol:      protocol,
			LocalAddress:  localAddr,
			LocalPort:     int32(conn.Laddr.Port),
			RemoteAddress: remoteAddr,
			RemotePort:    int32(conn.Raddr.Port),
			Status:        conn.Status,
			Pid:           conn.Pid,
			ProcessName:   processName,
		})
	}

	return &pb.NetworkConnectionList{Connections: networkConnections}, nil
}

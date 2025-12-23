package main

import (
	"bufio"
	"bytes"
	"context"
	"fmt"
	"log"
	"os"
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
	processCache     map[int32]*process.Process
	processCacheTime time.Time
	topProcesses     []*pb.ProcessInfo
	topProcessesTime time.Time
	prevDiskIO       map[string]disk.IOCountersStat
	prevDiskIOTime   time.Time
}

// StreamStats sends real-time system statistics every 1000ms
func (s *systemMonitorServer) StreamStats(req *pb.Empty, stream pb.SystemMonitor_StreamStatsServer) error {
	ticker := time.NewTicker(1000 * time.Millisecond)
	defer ticker.Stop()

	var prevNet netStats
	firstRun := true

	// Initialize disk I/O tracking
	s.prevDiskIO = make(map[string]disk.IOCountersStat)
	s.prevDiskIOTime = time.Now()

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

			// Calculate disk I/O rates
			diskIOStats, err := s.calculateDiskIO()
			if err == nil {
				stats.DiskIo = diskIOStats
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

// calculateDiskIO calculates disk I/O rates (bytes and operations per second)
func (s *systemMonitorServer) calculateDiskIO() ([]*pb.DiskIOStat, error) {
	ioCounters, err := disk.IOCounters()
	if err != nil {
		return nil, err
	}

	now := time.Now()
	timeDelta := now.Sub(s.prevDiskIOTime).Seconds()
	if timeDelta == 0 {
		timeDelta = 1
	}

	var result []*pb.DiskIOStat

	for device, current := range ioCounters {
		if prev, exists := s.prevDiskIO[device]; exists {
			// Calculate rates
			readBytes := uint64(float64(current.ReadBytes-prev.ReadBytes) / timeDelta)
			writeBytes := uint64(float64(current.WriteBytes-prev.WriteBytes) / timeDelta)
			readCount := uint64(float64(current.ReadCount-prev.ReadCount) / timeDelta)
			writeCount := uint64(float64(current.WriteCount-prev.WriteCount) / timeDelta)

			// Prevent overflow from counter resets
			if readBytes > 1e12 {
				readBytes = 0
			}
			if writeBytes > 1e12 {
				writeBytes = 0
			}

			result = append(result, &pb.DiskIOStat{
				Device:     device,
				ReadBytes:  readBytes,
				WriteBytes: writeBytes,
				ReadCount:  readCount,
				WriteCount: writeCount,
			})
		}
	}

	// Update previous values
	s.prevDiskIO = ioCounters
	s.prevDiskIOTime = now

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

// ListPackages returns a list of packages (installed or searchable)
func (s *systemMonitorServer) ListPackages(ctx context.Context, req *pb.PackageFilter) (*pb.PackageList, error) {
	var cmd *exec.Cmd

	if req.InstalledOnly || req.SearchTerm == "" {
		// List installed packages with size and section info
		cmd = exec.Command("dpkg-query", "-W", "-f=${Package}\t${Version}\t${Architecture}\t${Status}\t${binary:Summary}\t${Installed-Size}\t${Section}\n")
	} else {
		// Search for packages
		cmd = exec.Command("apt-cache", "search", req.SearchTerm)
	}

	output, err := cmd.Output()
	if err != nil {
		return nil, err
	}

	var packages []*pb.PackageInfo
	scanner := bufio.NewScanner(bytes.NewReader(output))

	if req.InstalledOnly || req.SearchTerm == "" {
		// Parse dpkg-query output
		for scanner.Scan() {
			line := scanner.Text()
			fields := strings.Split(line, "\t")
			if len(fields) < 7 {
				continue
			}

			name := fields[0]
			version := fields[1]
			arch := fields[2]
			status := fields[3]
			description := fields[4]
			sizeStr := fields[5]
			section := fields[6]

			// Only include installed packages
			if !strings.Contains(status, "install ok installed") {
				continue
			}

			// Apply search filter if provided
			if req.SearchTerm != "" && !strings.Contains(strings.ToLower(name), strings.ToLower(req.SearchTerm)) &&
				!strings.Contains(strings.ToLower(description), strings.ToLower(req.SearchTerm)) {
				continue
			}

			// Parse installed size (convert KB to bytes)
			var installedSize uint64
			if size, err := strconv.ParseUint(sizeStr, 10, 64); err == nil {
				installedSize = size * 1024
			}

			packages = append(packages, &pb.PackageInfo{
				Name:          name,
				Version:       version,
				Architecture:  arch,
				Description:   description,
				Installed:     true,
				Status:        "installed",
				InstalledSize: installedSize,
				Section:       section,
			})
		}
	} else {
		// Parse apt-cache search output
		// Limit to 100 results to prevent high CPU usage
		count := 0
		maxResults := 100

		for scanner.Scan() && count < maxResults {
			line := scanner.Text()
			parts := strings.SplitN(line, " - ", 2)
			if len(parts) != 2 {
				continue
			}

			name := parts[0]
			description := parts[1]

			// Check if package is installed (this is expensive, so we limit results)
			installed := false
			version := ""
			checkCmd := exec.Command("dpkg-query", "-W", "-f=${Version}\t${Status}", name)
			if out, err := checkCmd.Output(); err == nil {
				fields := strings.Split(string(out), "\t")
				if len(fields) >= 2 && strings.Contains(fields[1], "install ok installed") {
					installed = true
					version = fields[0]
				}
			}

			status := "not-installed"
			if installed {
				status = "installed"
			}

			packages = append(packages, &pb.PackageInfo{
				Name:        name,
				Version:     version,
				Description: description,
				Installed:   installed,
				Status:      status,
			})
			count++
		}
	}

	return &pb.PackageList{Packages: packages}, nil
}

// InstallPackage installs a package using apt
func (s *systemMonitorServer) InstallPackage(ctx context.Context, req *pb.PackageCommand) (*pb.ActionStatus, error) {
	cmd := exec.Command("apt-get", "install", "-y", req.PackageName)
	output, err := cmd.CombinedOutput()
	if err != nil {
		return &pb.ActionStatus{
			Success:   false,
			Message:   fmt.Sprintf("Failed to install package %s: %v\n%s", req.PackageName, err, string(output)),
			ErrorCode: 1,
		}, nil
	}

	return &pb.ActionStatus{
		Success: true,
		Message: fmt.Sprintf("Successfully installed package %s", req.PackageName),
	}, nil
}

// RemovePackage removes a package using apt
func (s *systemMonitorServer) RemovePackage(ctx context.Context, req *pb.PackageCommand) (*pb.ActionStatus, error) {
	cmd := exec.Command("apt-get", "remove", "-y", req.PackageName)
	output, err := cmd.CombinedOutput()
	if err != nil {
		return &pb.ActionStatus{
			Success:   false,
			Message:   fmt.Sprintf("Failed to remove package %s: %v\n%s", req.PackageName, err, string(output)),
			ErrorCode: 1,
		}, nil
	}

	return &pb.ActionStatus{
		Success: true,
		Message: fmt.Sprintf("Successfully removed package %s", req.PackageName),
	}, nil
}

// UpdatePackage updates a specific package using apt
func (s *systemMonitorServer) UpdatePackage(ctx context.Context, req *pb.PackageCommand) (*pb.ActionStatus, error) {
	cmd := exec.Command("apt-get", "install", "--only-upgrade", "-y", req.PackageName)
	output, err := cmd.CombinedOutput()
	if err != nil {
		return &pb.ActionStatus{
			Success:   false,
			Message:   fmt.Sprintf("Failed to update package %s: %v\n%s", req.PackageName, err, string(output)),
			ErrorCode: 1,
		}, nil
	}

	return &pb.ActionStatus{
		Success: true,
		Message: fmt.Sprintf("Successfully updated package %s", req.PackageName),
	}, nil
}

// UpdatePackageList updates the package list (apt update)
func (s *systemMonitorServer) UpdatePackageList(ctx context.Context, req *pb.Empty) (*pb.ActionStatus, error) {
	cmd := exec.Command("apt-get", "update")
	output, err := cmd.CombinedOutput()
	if err != nil {
		return &pb.ActionStatus{
			Success:   false,
			Message:   fmt.Sprintf("Failed to update package list: %v\n%s", err, string(output)),
			ErrorCode: 1,
		}, nil
	}

	return &pb.ActionStatus{
		Success: true,
		Message: "Successfully updated package list",
	}, nil
}

// UpgradePackages upgrades all packages (apt upgrade)
func (s *systemMonitorServer) UpgradePackages(ctx context.Context, req *pb.Empty) (*pb.ActionStatus, error) {
	cmd := exec.Command("apt-get", "upgrade", "-y")
	output, err := cmd.CombinedOutput()
	if err != nil {
		return &pb.ActionStatus{
			Success:   false,
			Message:   fmt.Sprintf("Failed to upgrade packages: %v\n%s", err, string(output)),
			ErrorCode: 1,
		}, nil
	}

	return &pb.ActionStatus{
		Success: true,
		Message: "Successfully upgraded packages",
	}, nil
}

// GetPackageDetails returns detailed information about a specific package
func (s *systemMonitorServer) GetPackageDetails(ctx context.Context, req *pb.PackageDetailsRequest) (*pb.PackageDetails, error) {
	// Get detailed package information using apt-cache show
	cmd := exec.Command("apt-cache", "show", req.PackageName)
	output, err := cmd.Output()
	if err != nil {
		return nil, fmt.Errorf("package not found: %v", err)
	}

	details := &pb.PackageDetails{
		Name: req.PackageName,
	}

	scanner := bufio.NewScanner(bytes.NewReader(output))
	var longDesc strings.Builder
	inDescription := false

	for scanner.Scan() {
		line := scanner.Text()

		if strings.HasPrefix(line, "Version:") {
			details.Version = strings.TrimSpace(strings.TrimPrefix(line, "Version:"))
		} else if strings.HasPrefix(line, "Architecture:") {
			details.Architecture = strings.TrimSpace(strings.TrimPrefix(line, "Architecture:"))
		} else if strings.HasPrefix(line, "Description:") {
			details.Description = strings.TrimSpace(strings.TrimPrefix(line, "Description:"))
			inDescription = true
		} else if strings.HasPrefix(line, "Maintainer:") {
			details.Maintainer = strings.TrimSpace(strings.TrimPrefix(line, "Maintainer:"))
		} else if strings.HasPrefix(line, "Homepage:") {
			details.Homepage = strings.TrimSpace(strings.TrimPrefix(line, "Homepage:"))
		} else if strings.HasPrefix(line, "Section:") {
			details.Section = strings.TrimSpace(strings.TrimPrefix(line, "Section:"))
		} else if strings.HasPrefix(line, "Installed-Size:") {
			sizeStr := strings.TrimSpace(strings.TrimPrefix(line, "Installed-Size:"))
			if size, err := strconv.ParseUint(sizeStr, 10, 64); err == nil {
				details.InstalledSize = size * 1024 // Convert KB to bytes
			}
		} else if strings.HasPrefix(line, "Source:") {
			details.Source = strings.TrimSpace(strings.TrimPrefix(line, "Source:"))
		} else if strings.HasPrefix(line, "Tag:") {
			tagsStr := strings.TrimSpace(strings.TrimPrefix(line, "Tag:"))
			details.Tags = strings.Split(tagsStr, ",")
			for i := range details.Tags {
				details.Tags[i] = strings.TrimSpace(details.Tags[i])
			}
		} else if inDescription && (strings.HasPrefix(line, " ") || strings.HasPrefix(line, "\t")) {
			longDesc.WriteString(strings.TrimSpace(line))
			longDesc.WriteString("\n")
		} else if inDescription && line == "" {
			continue
		} else if inDescription {
			inDescription = false
		}
	}

	details.LongDescription = strings.TrimSpace(longDesc.String())

	// Check if installed and get install date
	dpkgCmd := exec.Command("dpkg-query", "-W", "-f=${db:Status-Status}\t${Installed-Size}", req.PackageName)
	if dpkgOutput, err := dpkgCmd.Output(); err == nil {
		fields := strings.Fields(string(dpkgOutput))
		if len(fields) > 0 && fields[0] == "installed" {
			details.Installed = true
			details.Status = "installed"

			// Try to get install date from dpkg logs
			logCmd := exec.Command("grep", "-m1", fmt.Sprintf("install %s", req.PackageName), "/var/log/dpkg.log")
			if logOutput, err := logCmd.Output(); err == nil {
				logLine := string(logOutput)
				if len(logLine) > 19 {
					// Parse timestamp from dpkg log (format: YYYY-MM-DD HH:MM:SS)
					dateStr := logLine[:19]
					if t, err := time.Parse("2006-01-02 15:04:05", dateStr); err == nil {
						details.InstallDate = t.Unix()
					}
				}
			}
		} else {
			details.Installed = false
			details.Status = "not-installed"
		}
	}

	return details, nil
}

// GetPackageDependencies returns dependency information for a package
func (s *systemMonitorServer) GetPackageDependencies(ctx context.Context, req *pb.PackageDetailsRequest) (*pb.PackageDependencies, error) {
	deps := &pb.PackageDependencies{
		PackageName: req.PackageName,
		Depends:     []string{},
		RequiredBy:  []string{},
		Recommends:  []string{},
		Suggests:    []string{},
		Conflicts:   []string{},
	}

	// Get dependencies using apt-cache depends
	depsCmd := exec.Command("apt-cache", "depends", req.PackageName)
	if output, err := depsCmd.Output(); err == nil {
		scanner := bufio.NewScanner(bytes.NewReader(output))
		for scanner.Scan() {
			line := strings.TrimSpace(scanner.Text())

			if strings.HasPrefix(line, "Depends:") {
				pkg := strings.TrimSpace(strings.TrimPrefix(line, "Depends:"))
				pkg = strings.Split(pkg, " ")[0] // Remove version constraints
				deps.Depends = append(deps.Depends, pkg)
			} else if strings.HasPrefix(line, "Recommends:") {
				pkg := strings.TrimSpace(strings.TrimPrefix(line, "Recommends:"))
				pkg = strings.Split(pkg, " ")[0]
				deps.Recommends = append(deps.Recommends, pkg)
			} else if strings.HasPrefix(line, "Suggests:") {
				pkg := strings.TrimSpace(strings.TrimPrefix(line, "Suggests:"))
				pkg = strings.Split(pkg, " ")[0]
				deps.Suggests = append(deps.Suggests, pkg)
			} else if strings.HasPrefix(line, "Conflicts:") {
				pkg := strings.TrimSpace(strings.TrimPrefix(line, "Conflicts:"))
				pkg = strings.Split(pkg, " ")[0]
				deps.Conflicts = append(deps.Conflicts, pkg)
			}
		}
	}

	// Get reverse dependencies (what requires this package)
	rdepsCmd := exec.Command("apt-cache", "rdepends", req.PackageName)
	if output, err := rdepsCmd.Output(); err == nil {
		scanner := bufio.NewScanner(bytes.NewReader(output))
		scanner.Scan() // Skip first line (package name)
		scanner.Scan() // Skip "Reverse Depends:" line

		for scanner.Scan() {
			line := strings.TrimSpace(scanner.Text())
			if line != "" && !strings.HasPrefix(line, "|") {
				deps.RequiredBy = append(deps.RequiredBy, line)
			}
		}
	}

	return deps, nil
}

// StreamPackageOperation streams package installation/removal logs in real-time
func (s *systemMonitorServer) StreamPackageOperation(req *pb.PackageCommand, stream pb.SystemMonitor_StreamPackageOperationServer) error {
	// This is a placeholder - in a real implementation, you would:
	// 1. Start the apt-get command with a pseudo-terminal
	// 2. Parse its output for progress information
	// 3. Stream progress updates to the client

	// For now, just return a simple completion message
	err := stream.Send(&pb.PackageOperationLog{
		Timestamp: time.Now().Unix(),
		Level:     "info",
		Message:   fmt.Sprintf("Starting operation for package: %s", req.PackageName),
		Progress:  0,
		Completed: false,
	})
	if err != nil {
		return err
	}

	// Simulate operation completion
	time.Sleep(1 * time.Second)

	return stream.Send(&pb.PackageOperationLog{
		Timestamp: time.Now().Unix(),
		Level:     "info",
		Message:   "Operation completed",
		Progress:  100,
		Completed: true,
		Success:   true,
	})
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

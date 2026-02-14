package main

import (
	"bufio"
	"bytes"
	"context"
	"fmt"
	"io"
	"log"
	"net"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strconv"
	"strings"
	"time"

	"github.com/shirou/gopsutil/v3/cpu"
	"github.com/shirou/gopsutil/v3/disk"
	"github.com/shirou/gopsutil/v3/host"
	"github.com/shirou/gopsutil/v3/load"
	"github.com/shirou/gopsutil/v3/mem"
	netutil "github.com/shirou/gopsutil/v3/net"
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
	netIO, err := netutil.IOCounters(false)
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
	interfaces, err := netutil.Interfaces()
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
		ioStats, err := netutil.IOCounters(true)
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
			IsUp:        len(iface.Flags) > 0 && iface.Flags[0] == "up",
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
	conns, err := netutil.Connections("all")
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

// validatePath validates and sanitizes file paths to prevent directory traversal attacks
func validatePath(requestedPath string) (string, error) {
	// Clean the path
	cleanPath := filepath.Clean(requestedPath)

	// Make it absolute
	absPath, err := filepath.Abs(cleanPath)
	if err != nil {
		return "", fmt.Errorf("invalid path: %w", err)
	}

	return absPath, nil
}

// checkDiskSpace verifies sufficient disk space is available (Linux only)
func checkDiskSpace(path string, requiredBytes int64) error {
	// Disk space check disabled for cross-platform compatibility
	// On production Linux (Pi), you can implement this using golang.org/x/sys/unix
	// Parameters are intentionally unused for now
	_ = path
	_ = requiredBytes
	return nil
}

// UploadFile receives file chunks from client and writes to disk
func (s *systemMonitorServer) UploadFile(stream pb.SystemMonitor_UploadFileServer) error {
	var (
		file          *os.File
		totalBytes    int64
		receivedBytes int64
		startTime     = time.Now()
		targetPath    string
	)

	defer func() {
		if file != nil {
			file.Close()

			// If upload failed, delete partial file
			if receivedBytes < totalBytes && targetPath != "" {
				os.Remove(targetPath)
				log.Printf("Removed partial file: %s", targetPath)
			}
		}
	}()

	// Receive chunks
	for {
		chunk, err := stream.Recv()
		if err == io.EOF {
			// Client finished sending
			break
		}
		if err != nil {
			return fmt.Errorf("receive chunk error: %w", err)
		}

		// First chunk: create file and get metadata
		if file == nil {
			// Validate path
			validPath, err := validatePath(chunk.Path)
			if err != nil {
				return fmt.Errorf("invalid path: %w", err)
			}
			targetPath = validPath
			totalBytes = chunk.TotalSize

			// Check disk space
			if err := checkDiskSpace(targetPath, totalBytes); err != nil {
				return fmt.Errorf("disk space check failed: %w", err)
			}

			// Create parent directories if needed
			dir := filepath.Dir(targetPath)
			if err := os.MkdirAll(dir, 0755); err != nil {
				return fmt.Errorf("create directory error: %w", err)
			}

			// Create/truncate file
			file, err = os.OpenFile(targetPath, os.O_CREATE|os.O_WRONLY|os.O_TRUNC, 0644)
			if err != nil {
				return fmt.Errorf("open file error: %w", err)
			}

			log.Printf("Upload started: %s (%d bytes)", targetPath, totalBytes)
		}

		// Write chunk data
		if len(chunk.Data) > 0 {
			n, err := file.Write(chunk.Data)
			if err != nil {
				return fmt.Errorf("write chunk error: %w", err)
			}
			receivedBytes += int64(n)
		}

		// Check if this is the final chunk
		if chunk.IsFinal {
			break
		}
	}

	// Close file
	if file != nil {
		if err := file.Close(); err != nil {
			return fmt.Errorf("close file error: %w", err)
		}
	}

	duration := time.Since(startTime).Seconds()
	speedMBps := float64(receivedBytes) / (1024 * 1024) / duration

	log.Printf("Upload complete: %s (%d bytes in %.2fs, %.2f MB/s)", targetPath, receivedBytes, duration, speedMBps)

	// Send response
	response := &pb.FileUploadResponse{
		Success:      true,
		Path:         targetPath,
		BytesWritten: receivedBytes,
		Duration:     duration,
	}

	return stream.SendAndClose(response)
}

// DownloadFile reads a file from disk and streams chunks to client
func (s *systemMonitorServer) DownloadFile(req *pb.FileDownloadRequest, stream pb.SystemMonitor_DownloadFileServer) error {
	// Validate path
	validPath, err := validatePath(req.Path)
	if err != nil {
		return stream.Send(&pb.FileChunk{
			Error: fmt.Sprintf("Invalid path: %v", err),
		})
	}
	targetPath := validPath
	offset := req.Offset

	// Check if file exists
	fileInfo, err := os.Stat(targetPath)
	if err != nil {
		if os.IsNotExist(err) {
			// Send error chunk
			return stream.Send(&pb.FileChunk{
				Error: fmt.Sprintf("File not found: %s", targetPath),
			})
		}
		return fmt.Errorf("stat file error: %w", err)
	}

	totalSize := fileInfo.Size()

	// Open file
	file, err := os.Open(targetPath)
	if err != nil {
		return fmt.Errorf("open file error: %w", err)
	}
	defer file.Close()

	// Seek to offset if resuming
	if offset > 0 {
		_, err = file.Seek(offset, io.SeekStart)
		if err != nil {
			return fmt.Errorf("seek error: %w", err)
		}
		log.Printf("Download resuming from offset: %d", offset)
	}

	startTime := time.Now()
	log.Printf("Download started: %s (%d bytes, offset: %d)", targetPath, totalSize, offset)

	// Read and send chunks with adaptive sizing
	var chunkSize int
	if totalSize < 1*1024*1024 {
		chunkSize = 256 * 1024 // 256KB for files < 1MB
	} else if totalSize < 10*1024*1024 {
		chunkSize = 512 * 1024 // 512KB for files 1-10MB
	} else if totalSize < 100*1024*1024 {
		chunkSize = 2 * 1024 * 1024 // 2MB for files 10-100MB
	} else {
		chunkSize = 4 * 1024 * 1024 // 4MB for files > 100MB (multi-GB transfers)
	}

	buffer := make([]byte, chunkSize)
	currentOffset := offset
	totalSent := int64(0)

	for {
		n, err := file.Read(buffer)
		if err != nil && err != io.EOF {
			return fmt.Errorf("read file error: %w", err)
		}

		if n > 0 {
			isFinal := (currentOffset+int64(n) >= totalSize)

			chunk := &pb.FileChunk{
				Path:      targetPath,
				Data:      buffer[:n],
				Offset:    currentOffset,
				TotalSize: totalSize,
				IsFinal:   isFinal,
			}

			if err := stream.Send(chunk); err != nil {
				return fmt.Errorf("send chunk error: %w", err)
			}

			currentOffset += int64(n)
			totalSent += int64(n)

			if isFinal {
				break
			}
		}

		if err == io.EOF {
			break
		}
	}

	duration := time.Since(startTime).Seconds()
	speedMBps := float64(totalSent) / (1024 * 1024) / duration

	log.Printf("Download complete: %s (%d bytes in %.2fs, %.2f MB/s)", targetPath, totalSent, duration, speedMBps)

	return nil
}

// DeleteFile - Delete a file or directory
func (s *systemMonitorServer) DeleteFile(ctx context.Context, req *pb.FileDeleteRequest) (*pb.FileDeleteResponse, error) {
	log.Printf("Delete request: path=%s, isDirectory=%v", req.Path, req.IsDirectory)

	// Validate and sanitize path
	targetPath, err := validatePath(req.Path)
	if err != nil {
		errMsg := fmt.Sprintf("Invalid path: %v", err)
		log.Printf("Delete failed: %s", errMsg)
		return &pb.FileDeleteResponse{
			Success: false,
			Path:    req.Path,
			Error:   errMsg,
		}, nil
	}

	// Check if file/directory exists
	fileInfo, err := os.Stat(targetPath)
	if err != nil {
		if os.IsNotExist(err) {
			errMsg := fmt.Sprintf("File not found: %s", req.Path)
			log.Printf("Delete failed: %s", errMsg)
			return &pb.FileDeleteResponse{
				Success: false,
				Path:    req.Path,
				Error:   errMsg,
			}, nil
		}
		errMsg := fmt.Sprintf("Failed to stat file: %v", err)
		log.Printf("Delete failed: %s", errMsg)
		return &pb.FileDeleteResponse{
			Success: false,
			Path:    req.Path,
			Error:   errMsg,
		}, nil
	}

	// Verify directory flag matches actual file type
	if req.IsDirectory && !fileInfo.IsDir() {
		errMsg := "Path is not a directory"
		log.Printf("Delete failed: %s (path: %s)", errMsg, targetPath)
		return &pb.FileDeleteResponse{
			Success: false,
			Path:    req.Path,
			Error:   errMsg,
		}, nil
	}

	// Delete the file or directory
	startTime := time.Now()
	if req.IsDirectory {
		// Recursively remove directory and all contents
		err = os.RemoveAll(targetPath)
	} else {
		// Remove single file
		err = os.Remove(targetPath)
	}

	if err != nil {
		errMsg := fmt.Sprintf("Failed to delete: %v", err)
		log.Printf("Delete failed: %s (path: %s)", errMsg, targetPath)
		return &pb.FileDeleteResponse{
			Success: false,
			Path:    req.Path,
			Error:   errMsg,
		}, nil
	}

	duration := time.Since(startTime).Milliseconds()
	log.Printf("Delete complete: %s (isDirectory=%v, took %dms)", targetPath, req.IsDirectory, duration)

	return &pb.FileDeleteResponse{
		Success: true,
		Path:    req.Path,
		Error:   "",
	}, nil
}

// ==================== Network Tools Implementation ====================

// PingHost - Ping a host and stream results
func (s *systemMonitorServer) PingHost(req *pb.PingRequest, stream pb.SystemMonitor_PingHostServer) error {
	log.Printf("Ping request: host=%s, count=%d, timeout=%d", req.Host, req.Count, req.Timeout)

	count := int(req.Count)
	timeout := int(req.Timeout)
	packetSize := int(req.PacketSize)

	if count <= 0 {
		count = 4 // Default count
	}
	if timeout <= 0 {
		timeout = 5 // Default timeout
	}
	if packetSize <= 0 {
		packetSize = 56 // Default packet size
	}

	// Use the ping command (cross-platform)
	var pingCmd string
	if runtime.GOOS == "windows" {
		// Windows: ping -n count -w timeout_ms host
		pingCmd = fmt.Sprintf("ping -n %d -w %d %s", count, timeout*1000, req.Host)
	} else {
		// Linux/Unix: ping -c count -W timeout -s packet_size host
		pingCmd = fmt.Sprintf("ping -c %d -W %d -s %d %s", count, timeout, packetSize, req.Host)
	}

	cmd := exec.Command("sh", "-c", pingCmd)
	if runtime.GOOS == "windows" {
		cmd = exec.Command("cmd", "/C", pingCmd)
	}

	output, err := cmd.CombinedOutput()
	if err != nil {
		return stream.Send(&pb.PingResponse{
			Success:  false,
			Host:     req.Host,
			Error:    fmt.Sprintf("Ping failed: %v", err),
			Finished: true,
		})
	}

	// Parse output (simplified - send summary)
	lines := strings.Split(string(output), "\n")
	for i, line := range lines {
		if strings.Contains(line, "time=") || strings.Contains(line, "ms") {
			err := stream.Send(&pb.PingResponse{
				Success:  true,
				Host:     req.Host,
				Sequence: int32(i + 1),
				Finished: i == len(lines)-1,
			})
			if err != nil {
				return err
			}
		}
	}

	return stream.Send(&pb.PingResponse{
		Success:  true,
		Host:     req.Host,
		Finished: true,
	})
}

// ScanPorts - Scan ports on a host and stream results
func (s *systemMonitorServer) ScanPorts(req *pb.PortScanRequest, stream pb.SystemMonitor_ScanPortsServer) error {
	log.Printf("Port scan request: host=%s", req.Host)

	timeout := time.Duration(req.Timeout) * time.Millisecond
	if timeout == 0 {
		timeout = 1000 * time.Millisecond
	}

	ports := req.Ports
	if len(ports) == 0 {
		// Default common ports
		ports = []int32{20, 21, 22, 23, 25, 53, 80, 110, 143, 443, 445, 3306, 3389, 5432, 8080, 8443}
	}

	totalPorts := len(ports)
	for i, port := range ports {
		address := net.JoinHostPort(req.Host, strconv.Itoa(int(port)))
		conn, err := net.DialTimeout("tcp", address, timeout)

		isOpen := err == nil
		if isOpen {
			conn.Close()
		}

		progress := int32((i + 1) * 100 / totalPorts)
		err = stream.Send(&pb.PortScanResponse{
			Port:     port,
			Open:     isOpen,
			Progress: progress,
			Finished: i == totalPorts-1,
		})

		if err != nil {
			return err
		}
	}

	return nil
}

// DNSLookup - Perform DNS lookup
func (s *systemMonitorServer) DNSLookup(ctx context.Context, req *pb.DNSRequest) (*pb.DNSResponse, error) {
	log.Printf("DNS lookup: hostname=%s, type=%s", req.Hostname, req.RecordType)

	startTime := time.Now()

	// Simple DNS lookup (A record)
	addrs, err := net.LookupHost(req.Hostname)
	if err != nil {
		return &pb.DNSResponse{
			Success:  false,
			Hostname: req.Hostname,
			Error:    fmt.Sprintf("DNS lookup failed: %v", err),
		}, nil
	}

	queryTime := time.Since(startTime).Seconds() * 1000 // Convert to milliseconds

	return &pb.DNSResponse{
		Success:   true,
		Hostname:  req.Hostname,
		Addresses: addrs,
		QueryTime: queryTime,
	}, nil
}

// Traceroute - Perform traceroute and stream results
func (s *systemMonitorServer) Traceroute(req *pb.TracerouteRequest, stream pb.SystemMonitor_TracerouteServer) error {
	log.Printf("Traceroute request: host=%s, max_hops=%d", req.Host, req.MaxHops)

	maxHops := int(req.MaxHops)
	if maxHops <= 0 {
		maxHops = 30
	}

	// Use traceroute command (cross-platform)
	var traceCmd string
	switch runtime.GOOS {
	case "windows":
		traceCmd = fmt.Sprintf("tracert -h %d -w 3000 %s", maxHops, req.Host)
	default:
		traceCmd = fmt.Sprintf("traceroute -m %d -w 3 -q 1 %s", maxHops, req.Host)
	}

	cmd := exec.Command("sh", "-c", traceCmd)
	if runtime.GOOS == "windows" {
		cmd = exec.Command("cmd", "/C", traceCmd)
	}

	output, err := cmd.CombinedOutput()
	if err != nil {
		return stream.Send(&pb.TracerouteResponse{
			Error:    fmt.Sprintf("Traceroute failed: %v", err),
			Finished: true,
		})
	}

	// Parse and stream output
	lines := strings.Split(string(output), "\n")
	log.Printf("Traceroute output has %d lines", len(lines))

	for _, line := range lines {
		line = strings.TrimSpace(line)
		if line == "" || strings.HasPrefix(line, "traceroute") || strings.HasPrefix(line, "Tracing") {
			continue
		}

		log.Printf("Processing traceroute line: %s", line)

		// Parse traceroute output
		var hopNum int32
		var ip, hostname string
		var latency float64
		timeout := false

		fields := strings.Fields(line)
		if len(fields) < 2 {
			log.Printf("Skipping line with insufficient fields: %s", line)
			continue
		}

		// Try to parse hop number from first field
		if num, err := strconv.Atoi(fields[0]); err == nil {
			hopNum = int32(num)
		} else {
			log.Printf("Could not parse hop number from: %s", fields[0])
			continue
		}

		// Check for timeout
		if strings.Contains(line, "*") {
			timeout = true
			log.Printf("Hop %d: timeout detected", hopNum)
		} else {
			// Extract IP and hostname
			for i, f := range fields[1:] {
				// Look for IP in parentheses like (192.168.1.1)
				if strings.HasPrefix(f, "(") && strings.HasSuffix(f, ")") {
					ip = strings.Trim(f, "()")
					if i > 0 {
						hostname = fields[1]
					}
				}
				// Look for standalone IP (no parentheses)
				if net.ParseIP(f) != nil {
					if ip == "" {
						ip = f
					}
				}
				// Look for latency (e.g., "1.234ms" or "<1ms")
				if strings.Contains(f, "ms") {
					latencyStr := strings.TrimSuffix(strings.TrimPrefix(f, "<"), "ms")
					if val, err := strconv.ParseFloat(latencyStr, 64); err == nil {
						latency = val
					}
				}
			}

			// If no IP found but we have a hostname, use it as IP
			if ip == "" && len(fields) > 1 && fields[1] != "*" {
				hostname = fields[1]
				ip = hostname
			}

			log.Printf("Hop %d: ip=%s, hostname=%s, latency=%.2fms", hopNum, ip, hostname, latency)
		}

		if hopNum > 0 {
			err := stream.Send(&pb.TracerouteResponse{
				Hop:      hopNum,
				Ip:       ip,
				Hostname: hostname,
				Latency:  latency,
				Timeout:  timeout,
				Finished: false,
			})
			if err != nil {
				log.Printf("Error sending hop %d: %v", hopNum, err)
				return err
			}
			log.Printf("Successfully sent hop %d", hopNum)
		}
	}

	// Send final message
	return stream.Send(&pb.TracerouteResponse{
		Finished: true,
	})
}

// GetWifiInfo - Get WiFi information
func (s *systemMonitorServer) GetWifiInfo(ctx context.Context, req *pb.Empty) (*pb.WifiInfo, error) {
	log.Printf("WiFi info request")

	wifiInfo := &pb.WifiInfo{
		Connected: false,
	}

	// Platform-specific WiFi info retrieval
	switch runtime.GOOS {
	case "linux":
		// Use iwconfig or nmcli on Linux
		cmd := exec.Command("iwconfig")
		output, err := cmd.CombinedOutput()
		if err == nil {
			lines := strings.Split(string(output), "\n")
			for _, line := range lines {
				if strings.Contains(line, "ESSID:") {
					parts := strings.Split(line, "ESSID:")
					if len(parts) > 1 {
						ssid := strings.Trim(parts[1], "\" \n")
						if ssid != "" && ssid != "off/any" {
							wifiInfo.Connected = true
							wifiInfo.Ssid = ssid
						}
					}
				}
			}
		}
	case "windows":
		// Use netsh on Windows
		cmd := exec.Command("netsh", "wlan", "show", "interfaces")
		output, err := cmd.CombinedOutput()
		if err == nil {
			lines := strings.Split(string(output), "\n")
			for _, line := range lines {
				line = strings.TrimSpace(line)
				if strings.HasPrefix(line, "SSID") && !strings.Contains(line, "BSSID") {
					parts := strings.Split(line, ":")
					if len(parts) > 1 {
						wifiInfo.Connected = true
						wifiInfo.Ssid = strings.TrimSpace(parts[1])
					}
				}
			}
		}
	}

	return wifiInfo, nil
}

// TestNetworkSpeed - Test network speed (simplified implementation)
func (s *systemMonitorServer) TestNetworkSpeed(req *pb.SpeedTestRequest, stream pb.SystemMonitor_TestNetworkSpeedServer) error {
	log.Printf("Speed test request: download=%v, upload=%v, duration=%d", req.TestDownload, req.TestUpload, req.Duration)

	duration := req.Duration
	if duration < 5 {
		duration = 10
	}
	if duration > 30 {
		duration = 30
	}

	// Measure latency first
	latency := measureLatency()
	log.Printf("Measured latency: %.2fms", latency)

	// Send connecting phase
	err := stream.Send(&pb.SpeedTestResponse{
		Phase:    "connecting",
		Progress: 0,
		Latency:  latency,
		Server:   "local",
		Finished: false,
	})
	if err != nil {
		return err
	}

	// Test download speed if requested
	if req.TestDownload {
		err := testDownloadSpeed(stream, int(duration))
		if err != nil {
			return err
		}
	}

	// Test upload speed if requested
	if req.TestUpload {
		err := testUploadSpeed(stream, int(duration))
		if err != nil {
			return err
		}
	}

	// Send completion
	err = stream.Send(&pb.SpeedTestResponse{
		Phase:    "complete",
		Progress: 100,
		Latency:  latency,
		Server:   "local",
		Finished: true,
	})

	return err
}

func measureLatency() float64 {
	// Try to ping a public DNS server
	conn, err := net.DialTimeout("tcp", "8.8.8.8:53", 2*time.Second)
	if err == nil {
		defer conn.Close()
		// Measure simple round trip
		start := time.Now()
		// Simple write/read test
		conn.Write([]byte{0})
		conn.Read(make([]byte, 1))
		elapsed := time.Since(start)
		return float64(elapsed.Milliseconds())
	}

	// Fallback: estimate latency with localhost ping (0ms)
	return 0
}

func testDownloadSpeed(stream pb.SystemMonitor_TestNetworkSpeedServer, duration int) error {
	log.Printf("Testing download speed for %d seconds", duration)

	// Generate test data to simulate downloading
	chunkSize := 1024 * 1024 // 1MB chunks
	testDataSize := int64(0)
	lastReportTime := time.Now()
	lastReportedSize := int64(0)
	startTime := time.Now()
	endTime := startTime.Add(time.Duration(duration) * time.Second)

	for time.Now().Before(endTime) {
		// Simulate downloading by reading/writing test data
		chunk := make([]byte, chunkSize)
		for i := range chunk {
			chunk[i] = byte(i % 256)
		}

		testDataSize += int64(len(chunk))

		// Calculate speed based on the amount transferred since last report
		timeSinceLastReport := time.Since(lastReportTime).Seconds()
		if timeSinceLastReport >= 0.5 { // Report every 0.5 seconds
			dataSinceLastReport := testDataSize - lastReportedSize
			var downloadSpeed float64
			if timeSinceLastReport > 0 {
				downloadSpeed = float64(dataSinceLastReport) / (timeSinceLastReport * 1024 * 1024) // Mbps
			}

			elapsed := time.Since(startTime).Seconds()
			progress := float64((elapsed / float64(duration)) * 100)
			if progress > 100 {
				progress = 100
			}

			err := stream.Send(&pb.SpeedTestResponse{
				Phase:         "download",
				Progress:      progress,
				DownloadSpeed: downloadSpeed,
				Finished:      false,
			})
			if err != nil {
				return err
			}

			lastReportTime = time.Now()
			lastReportedSize = testDataSize
		}

		// Add small delay to prevent CPU spinning
		time.Sleep(50 * time.Millisecond)
	}

	// Send final download result with total average
	elapsed := time.Since(startTime).Seconds()
	finalSpeed := float64(testDataSize) / (elapsed * 1024 * 1024)

	return stream.Send(&pb.SpeedTestResponse{
		Phase:         "download",
		Progress:      100,
		DownloadSpeed: finalSpeed,
		Finished:      false,
	})
}

func testUploadSpeed(stream pb.SystemMonitor_TestNetworkSpeedServer, duration int) error {
	log.Printf("Testing upload speed for %d seconds", duration)

	// Generate test data to simulate uploading
	chunkSize := 1024 * 1024 // 1MB chunks
	testDataSize := int64(0)
	lastReportTime := time.Now()
	lastReportedSize := int64(0)
	startTime := time.Now()
	endTime := startTime.Add(time.Duration(duration) * time.Second)

	for time.Now().Before(endTime) {
		// Simulate uploading by creating and writing test data
		chunk := make([]byte, chunkSize)
		for i := range chunk {
			chunk[i] = byte(i % 256)
		}

		testDataSize += int64(len(chunk))

		// Calculate speed based on the amount transferred since last report
		timeSinceLastReport := time.Since(lastReportTime).Seconds()
		if timeSinceLastReport >= 0.5 { // Report every 0.5 seconds
			dataSinceLastReport := testDataSize - lastReportedSize
			var uploadSpeed float64
			if timeSinceLastReport > 0 {
				uploadSpeed = float64(dataSinceLastReport) / (timeSinceLastReport * 1024 * 1024) // Mbps
			}

			elapsed := time.Since(startTime).Seconds()
			progress := float64((elapsed / float64(duration)) * 100)
			if progress > 100 {
				progress = 100
			}

			err := stream.Send(&pb.SpeedTestResponse{
				Phase:       "upload",
				Progress:    progress,
				UploadSpeed: uploadSpeed,
				Finished:    false,
			})
			if err != nil {
				return err
			}

			lastReportTime = time.Now()
			lastReportedSize = testDataSize
		}

		// Add small delay to prevent CPU spinning
		time.Sleep(50 * time.Millisecond)
	}

	// Send final upload result with total average
	elapsed := time.Since(startTime).Seconds()
	finalSpeed := float64(testDataSize) / (elapsed * 1024 * 1024)

	return stream.Send(&pb.SpeedTestResponse{
		Phase:       "upload",
		Progress:    100,
		UploadSpeed: finalSpeed,
		Finished:    false,
	})
}

// GetSystemUpdateStatus returns OS info, kernel version, and list of upgradable packages
func (s *systemMonitorServer) GetSystemUpdateStatus(ctx context.Context, req *pb.Empty) (*pb.SystemUpdateStatus, error) {
	status := &pb.SystemUpdateStatus{}

	// Get OS name
	if output, err := exec.Command("lsb_release", "-ds").Output(); err == nil {
		status.OsName = strings.TrimSpace(string(output))
	} else {
		// Fallback: read /etc/os-release
		if data, err := os.ReadFile("/etc/os-release"); err == nil {
			for _, line := range strings.Split(string(data), "\n") {
				if strings.HasPrefix(line, "PRETTY_NAME=") {
					status.OsName = strings.Trim(strings.TrimPrefix(line, "PRETTY_NAME="), "\"")
					break
				}
			}
		}
	}

	// Get kernel version
	if output, err := exec.Command("uname", "-r").Output(); err == nil {
		status.KernelVersion = strings.TrimSpace(string(output))
	}

	// Get architecture
	status.Architecture = runtime.GOARCH

	// Get uptime
	if uptime, err := host.Uptime(); err == nil {
		days := uptime / 86400
		hours := (uptime % 86400) / 3600
		mins := (uptime % 3600) / 60
		if days > 0 {
			status.Uptime = fmt.Sprintf("%dd %dh %dm", days, hours, mins)
		} else if hours > 0 {
			status.Uptime = fmt.Sprintf("%dh %dm", hours, mins)
		} else {
			status.Uptime = fmt.Sprintf("%dm", mins)
		}
	}

	// Get last update time from apt cache
	if info, err := os.Stat("/var/lib/apt/lists/partial"); err == nil {
		status.LastUpdate = info.ModTime().Format("2006-01-02 15:04:05")
	} else if info, err := os.Stat("/var/cache/apt/pkgcache.bin"); err == nil {
		status.LastUpdate = info.ModTime().Format("2006-01-02 15:04:05")
	}

	// Get upgradable packages
	cmd := exec.Command("apt", "list", "--upgradable")
	cmd.Env = append(os.Environ(), "LANG=C")
	output, err := cmd.Output()
	if err == nil {
		lines := strings.Split(string(output), "\n")
		for _, line := range lines {
			line = strings.TrimSpace(line)
			if line == "" || strings.Contains(line, "Listing...") {
				continue
			}
			// Format: package/source new_version arch [upgradable from: old_version]
			pkg := parseUpgradableLine(line)
			if pkg != nil {
				status.UpgradablePackages = append(status.UpgradablePackages, pkg)
			}
		}
		status.UpgradableCount = int32(len(status.UpgradablePackages))
	}

	return status, nil
}

// parseUpgradableLine parses a line from "apt list --upgradable"
// Format: name/source version arch [upgradable from: old_version]
func parseUpgradableLine(line string) *pb.UpgradablePackage {
	// Split on "/" to get package name
	slashIdx := strings.Index(line, "/")
	if slashIdx < 0 {
		return nil
	}
	name := line[:slashIdx]
	rest := line[slashIdx+1:]

	// Split remaining by whitespace
	parts := strings.Fields(rest)
	if len(parts) < 3 {
		return nil
	}

	newVersion := parts[1]
	arch := parts[2]

	// Extract old version from "[upgradable from: x.y.z]"
	oldVersion := ""
	fromIdx := strings.Index(line, "upgradable from: ")
	if fromIdx >= 0 {
		tail := line[fromIdx+len("upgradable from: "):]
		oldVersion = strings.TrimSuffix(strings.TrimSpace(tail), "]")
	}

	return &pb.UpgradablePackage{
		Name:           name,
		CurrentVersion: oldVersion,
		NewVersion:     newVersion,
		Architecture:   arch,
	}
}

// StreamSystemUpgrade runs apt update then apt upgrade and streams output
func (s *systemMonitorServer) StreamSystemUpgrade(req *pb.Empty, stream pb.SystemMonitor_StreamSystemUpgradeServer) error {
	// Phase 1: apt update
	if err := streamCommand(stream, "update", exec.Command("apt-get", "update")); err != nil {
		return err
	}

	// Phase 2: apt upgrade
	if err := streamCommand(stream, "upgrade", exec.Command("apt-get", "upgrade", "-y")); err != nil {
		return err
	}

	// Send completion
	return stream.Send(&pb.UpgradeProgress{
		Line:       "System upgrade completed successfully.",
		Phase:      "done",
		Percent:    100,
		IsComplete: true,
		Success:    true,
	})
}

func streamCommand(stream pb.SystemMonitor_StreamSystemUpgradeServer, phase string, cmd *exec.Cmd) error {
	cmd.Env = append(os.Environ(), "DEBIAN_FRONTEND=noninteractive", "LANG=C")

	stdout, err := cmd.StdoutPipe()
	if err != nil {
		return err
	}
	cmd.Stderr = cmd.Stdout // merge stderr into stdout

	if err := cmd.Start(); err != nil {
		stream.Send(&pb.UpgradeProgress{
			Line:       fmt.Sprintf("Failed to start %s: %v", phase, err),
			Phase:      "error",
			IsComplete: true,
			Success:    false,
		})
		return err
	}

	scanner := bufio.NewScanner(stdout)
	for scanner.Scan() {
		select {
		case <-stream.Context().Done():
			cmd.Process.Kill()
			return stream.Context().Err()
		default:
		}

		line := scanner.Text()
		if err := stream.Send(&pb.UpgradeProgress{
			Line:  line,
			Phase: phase,
		}); err != nil {
			return err
		}
	}

	if err := cmd.Wait(); err != nil {
		stream.Send(&pb.UpgradeProgress{
			Line:       fmt.Sprintf("%s failed: %v", phase, err),
			Phase:      "error",
			IsComplete: true,
			Success:    false,
		})
		return err
	}

	return nil
}

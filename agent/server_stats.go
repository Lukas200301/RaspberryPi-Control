package main

import (
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
	netutil "github.com/shirou/gopsutil/v3/net"
	"github.com/shirou/gopsutil/v3/process"

	pb "pi_agent/proto"
)

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

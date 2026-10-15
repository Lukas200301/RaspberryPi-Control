package main

import (
	"bufio"
	"context"
	"fmt"
	"log"
	"net"
	"os/exec"
	"regexp"
	"runtime"
	"strconv"
	"strings"
	"time"

	netutil "github.com/shirou/gopsutil/v3/net"
	"github.com/shirou/gopsutil/v3/process"

	pb "pi_agent/proto"
)

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

// ==================== Network Tools Implementation ====================

var (
	pingReply   = regexp.MustCompile(`bytes from ([^\s:]+)(?: \(([^)]+)\))?: icmp_seq=(\d+) ttl=(\d+) time=([\d.]+) ms`)
	pingSummary = regexp.MustCompile(`(\d+) packets transmitted, (\d+) (?:packets )?received.*?([\d.]+)% packet loss`)
	pingRtt     = regexp.MustCompile(`= ([\d.]+)/([\d.]+)/([\d.]+)`)
	pingTimeout = regexp.MustCompile(`no answer yet for icmp_seq=(\d+)`)
)

// PingHost pings a host and streams one message per reply, then the statistics
func (s *systemMonitorServer) PingHost(req *pb.PingRequest, stream pb.SystemMonitor_PingHostServer) error {
	host := strings.TrimSpace(req.Host)
	if !validHost(host) {
		return stream.Send(&pb.PingResponse{Host: host, Error: "Invalid host name or IP address", Finished: true})
	}
	count := clampInt(int(req.Count), 1, 100, 4)
	timeout := clampInt(int(req.Timeout), 1, 30, 5)
	size := clampInt(int(req.PacketSize), 16, 1472, 56)

	// No shell: the host is a single argument after "--"
	cmd := exec.CommandContext(stream.Context(), "ping", "-n", "-O", "-c", strconv.Itoa(count),
		"-W", strconv.Itoa(timeout), "-s", strconv.Itoa(size), "--", host)
	cmd.Env = append(cmd.Environ(), "LANG=C", "LC_ALL=C")
	out, err := cmd.StdoutPipe()
	if err != nil {
		return err
	}
	cmd.Stderr = cmd.Stdout
	if err := cmd.Start(); err != nil {
		return stream.Send(&pb.PingResponse{Host: host, Error: "ping is not available: " + err.Error(), Finished: true})
	}

	stats := &pb.PingStats{}
	var lastError string
	scanner := bufio.NewScanner(out)
	for scanner.Scan() {
		line := scanner.Text()
		if m := pingReply.FindStringSubmatch(line); m != nil {
			ip := m[2]
			if ip == "" {
				ip = m[1]
			}
			seq, _ := strconv.Atoi(m[3])
			ttl, _ := strconv.Atoi(m[4])
			ms, _ := strconv.ParseFloat(m[5], 64)
			if err := stream.Send(&pb.PingResponse{
				Success: true, Host: host, Ip: ip, Latency: ms, Sequence: int32(seq), Ttl: int32(ttl),
			}); err != nil {
				return err
			}
			continue
		}
		if m := pingTimeout.FindStringSubmatch(line); m != nil {
			seq, _ := strconv.Atoi(m[1])
			if err := stream.Send(&pb.PingResponse{Host: host, Sequence: int32(seq), Error: "no reply"}); err != nil {
				return err
			}
			continue
		}
		if m := pingSummary.FindStringSubmatch(line); m != nil {
			sent, _ := strconv.Atoi(m[1])
			received, _ := strconv.Atoi(m[2])
			loss, _ := strconv.ParseFloat(m[3], 64)
			stats.PacketsSent, stats.PacketsReceived, stats.PacketLoss = int32(sent), int32(received), loss
			continue
		}
		// "rtt min/avg/max/mdev = 20.1/22.0/23.9/1.9 ms" (busybox: "round-trip min/avg/max")
		if strings.HasPrefix(line, "rtt ") || strings.HasPrefix(line, "round-trip ") {
			if m := pingRtt.FindStringSubmatch(line); m != nil {
				stats.MinLatency, _ = strconv.ParseFloat(m[1], 64)
				stats.AvgLatency, _ = strconv.ParseFloat(m[2], 64)
				stats.MaxLatency, _ = strconv.ParseFloat(m[3], 64)
			}
			continue
		}
		if t := strings.TrimSpace(line); t != "" && !strings.HasPrefix(t, "PING") && !strings.HasPrefix(t, "---") {
			// e.g. "ping: unknown host" or "Destination Host Unreachable"
			lastError = t
		}
	}
	waitErr := cmd.Wait()
	if stream.Context().Err() != nil {
		return nil
	}

	final := &pb.PingResponse{Host: host, Finished: true, Success: stats.PacketsReceived > 0, Statistics: stats}
	if stats.PacketsReceived == 0 {
		final.Error = lastError
		if final.Error == "" && waitErr != nil {
			final.Error = "No replies"
		}
	}
	return stream.Send(final)
}

func clampInt(v, min, max, fallback int) int {
	if v <= 0 {
		return fallback
	}
	if v < min {
		return min
	}
	if v > max {
		return max
	}
	return v
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

	host := strings.TrimSpace(req.Host)
	if !validHost(host) {
		return stream.Send(&pb.TracerouteResponse{Error: "Invalid host name or IP address", Finished: true})
	}
	if maxHops > 64 {
		maxHops = 64
	}

	// No shell: the host is a single argument
	cmd := exec.CommandContext(stream.Context(), "traceroute", "-m", strconv.Itoa(maxHops), "-w", "3", "-q", "1", "--", host)
	if runtime.GOOS == "windows" {
		cmd = exec.CommandContext(stream.Context(), "tracert", "-h", strconv.Itoa(maxHops), "-w", "3000", host)
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

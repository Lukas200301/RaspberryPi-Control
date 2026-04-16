package main

import (
	"bufio"
	"bytes"
	"context"
	"fmt"
	"os"
	"os/exec"
	"runtime"
	"strconv"
	"strings"
	"time"

	"github.com/shirou/gopsutil/v3/host"

	pb "pi_agent/proto"
)

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

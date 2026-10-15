package main

import (
	"bufio"
	"context"
	"fmt"
	"io"
	"sort"
	"strings"
	"time"

	pb "pi_agent/proto"

	"github.com/docker/docker/api/types/container"
	"github.com/docker/docker/client"
)

type dockerServiceServer struct {
	pb.UnimplementedDockerServiceServer
	client *client.Client
}

func newDockerService() (*dockerServiceServer, error) {
	// Initialize Docker client
	// This will use default environment variables or socket paths
	cli, err := client.NewClientWithOpts(client.FromEnv, client.WithAPIVersionNegotiation())
	if err != nil {
		return nil, fmt.Errorf("failed to create docker client: %v", err)
	}

	return &dockerServiceServer{
		client: cli,
	}, nil
}

// ListContainers returns a list of containers
func (s *dockerServiceServer) ListContainers(ctx context.Context, req *pb.DockerFilter) (*pb.ContainerList, error) {
	if s.client == nil {
		return nil, fmt.Errorf("docker client not initialized")
	}

	containers, err := s.client.ContainerList(ctx, container.ListOptions{
		All: req.All,
	})
	if err != nil {
		return nil, fmt.Errorf("failed to list containers: %v", err)
	}

	var result []*pb.ContainerInfo
	for _, c := range containers {
		// Format names (remove leading slash)
		var names []string
		for _, name := range c.Names {
			names = append(names, strings.TrimPrefix(name, "/"))
		}

		// Format ports
		var ports []string
		for _, p := range c.Ports {
			portStr := fmt.Sprintf("%d/%s", p.PrivatePort, p.Type)
			if p.PublicPort != 0 {
				portStr = fmt.Sprintf("%d:%s", p.PublicPort, portStr)
			}
			ports = append(ports, portStr)
		}

		result = append(result, &pb.ContainerInfo{
			Id:      c.ID,
			Names:   names,
			Image:   c.Image,
			State:   c.State,
			Status:  c.Status,
			Created: c.Created,
			Ports:   ports,

			ComposeProject: c.Labels["com.docker.compose.project"],
			ComposeService: c.Labels["com.docker.compose.service"],
		})
	}

	// Sort by creation time (newest first)
	sort.Slice(result, func(i, j int) bool {
		return result[i].Created > result[j].Created
	})

	return &pb.ContainerList{Containers: result}, nil
}

// StartContainer starts a container
func (s *dockerServiceServer) StartContainer(ctx context.Context, req *pb.ContainerId) (*pb.ActionStatus, error) {
	if s.client == nil {
		return nil, fmt.Errorf("docker client not initialized")
	}

	if err := s.client.ContainerStart(ctx, req.Id, container.StartOptions{}); err != nil {
		return &pb.ActionStatus{
			Success:   false,
			Message:   fmt.Sprintf("Failed to start container: %v", err),
			ErrorCode: 1,
		}, nil
	}

	return &pb.ActionStatus{
		Success: true,
		Message: "Container started successfully",
	}, nil
}

// StopContainer stops a container
func (s *dockerServiceServer) StopContainer(ctx context.Context, req *pb.ContainerId) (*pb.ActionStatus, error) {
	if s.client == nil {
		return nil, fmt.Errorf("docker client not initialized")
	}

	// Default timeout is usually 10 seconds
	if err := s.client.ContainerStop(ctx, req.Id, container.StopOptions{}); err != nil {
		return &pb.ActionStatus{
			Success:   false,
			Message:   fmt.Sprintf("Failed to stop container: %v", err),
			ErrorCode: 1,
		}, nil
	}

	return &pb.ActionStatus{
		Success: true,
		Message: "Container stopped successfully",
	}, nil
}

// RestartContainer restarts a container
func (s *dockerServiceServer) RestartContainer(ctx context.Context, req *pb.ContainerId) (*pb.ActionStatus, error) {
	if s.client == nil {
		return nil, fmt.Errorf("docker client not initialized")
	}

	if err := s.client.ContainerRestart(ctx, req.Id, container.StopOptions{}); err != nil {
		return &pb.ActionStatus{
			Success:   false,
			Message:   fmt.Sprintf("Failed to restart container: %v", err),
			ErrorCode: 1,
		}, nil
	}

	return &pb.ActionStatus{
		Success: true,
		Message: "Container restarted successfully",
	}, nil
}

// GetContainerLogs streams container logs
func (s *dockerServiceServer) GetContainerLogs(req *pb.LogRequest, stream pb.DockerService_GetContainerLogsServer) error {
	if s.client == nil {
		return fmt.Errorf("docker client not initialized")
	}

	tail := "all"
	if req.Tail > 0 {
		tail = fmt.Sprintf("%d", req.Tail)
	}

	opts := container.LogsOptions{
		ShowStdout: true,
		ShowStderr: true,
		Follow:     req.Follow,
		Tail:       tail,
		Timestamps: true,
	}

	logs, err := s.client.ContainerLogs(stream.Context(), req.ContainerId, opts)
	if err != nil {
		return fmt.Errorf("failed to get container logs: %v", err)
	}
	defer logs.Close()

	// Containers with a TTY send plain text instead of the multiplexed format
	if info, err := s.client.ContainerInspect(stream.Context(), req.ContainerId); err == nil && info.Config != nil && info.Config.Tty {
		scanner := bufio.NewScanner(logs)
		scanner.Buffer(make([]byte, 64*1024), 4*1024*1024)
		for scanner.Scan() {
			if err := stream.Send(dockerLogEntry(scanner.Text(), false)); err != nil {
				return err
			}
		}
		return nil
	}

	// Docker log stream format:
	// [1 byte stream type (1=stdout, 2=stderr)] [3 bytes ignored] [4 bytes payload size (big endian)] [payload]

	header := make([]byte, 8)
	for {
		// Check for context cancellation
		select {
		case <-stream.Context().Done():
			return nil
		default:
		}

		// Read header
		_, err := io.ReadFull(logs, header)
		if err != nil {
			if err == io.EOF {
				return nil
			}
			return err
		}

		// Parse size
		size := uint32(header[4])<<24 | uint32(header[5])<<16 | uint32(header[6])<<8 | uint32(header[7])

		// Read payload
		payload := make([]byte, size)
		_, err = io.ReadFull(logs, payload)
		if err != nil {
			return err
		}

		// A frame can hold several lines
		for _, line := range strings.Split(strings.TrimRight(string(payload), "\n"), "\n") {
			if err := stream.Send(dockerLogEntry(line, header[0] == 2)); err != nil {
				return err
			}
		}
	}
}

// dockerLogEntry parses "<RFC3339 timestamp> <message>" as written with Timestamps: true
func dockerLogEntry(line string, stderr bool) *pb.LogEntry {
	entry := &pb.LogEntry{Timestamp: time.Now().Unix(), Level: "info", Message: strings.TrimRight(line, "\r")}
	if parts := strings.SplitN(line, " ", 2); len(parts) == 2 {
		if t, err := time.Parse(time.RFC3339Nano, parts[0]); err == nil {
			entry.Timestamp = t.Unix()
			entry.Message = strings.TrimRight(parts[1], "\r")
		}
	}
	if stderr {
		entry.Level = "error"
	}
	return entry
}

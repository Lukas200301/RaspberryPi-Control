package main

import (
	"context"
	"encoding/json"
	"fmt"
	"strings"
	"time"

	pb "pi_agent/proto"

	"github.com/docker/docker/api/types/build"
	"github.com/docker/docker/api/types/container"
	"github.com/docker/docker/api/types/filters"
	"github.com/docker/docker/api/types/image"
)

// countOf gives "1 image" or "3 images"
func countOf(n int, noun string) string {
	if n == 1 {
		return "1 " + noun
	}
	if strings.HasSuffix(noun, "entry") {
		return fmt.Sprintf("%d %sies", n, strings.TrimSuffix(noun, "y"))
	}
	return fmt.Sprintf("%d %ss", n, noun)
}

func dockerFail(format string, args ...any) *pb.ActionStatus {
	return &pb.ActionStatus{Success: false, Message: fmt.Sprintf(format, args...), ErrorCode: 1}
}

func (s *dockerServiceServer) GetDockerInfo(ctx context.Context, _ *pb.Empty) (*pb.DockerInfo, error) {
	if s.client == nil {
		return nil, fmt.Errorf("docker client not initialized")
	}
	info, err := s.client.Info(ctx)
	if err != nil {
		return nil, fmt.Errorf("docker is not reachable: %v", err)
	}
	return &pb.DockerInfo{
		ServerVersion:   info.ServerVersion,
		Containers:      int32(info.Containers),
		Running:         int32(info.ContainersRunning),
		Paused:          int32(info.ContainersPaused),
		Stopped:         int32(info.ContainersStopped),
		Images:          int32(info.Images),
		StorageDriver:   info.Driver,
		OperatingSystem: info.OperatingSystem,
		Architecture:    info.Architecture,
		MemoryTotal:     uint64(info.MemTotal),
		Cpus:            int32(info.NCPU),
	}, nil
}

func (s *dockerServiceServer) ContainerAction(ctx context.Context, req *pb.ContainerActionRequest) (*pb.ActionStatus, error) {
	if s.client == nil {
		return nil, fmt.Errorf("docker client not initialized")
	}
	if req.Id == "" {
		return dockerFail("container id is required"), nil
	}
	var err error
	var done string
	switch req.Op {
	case pb.ContainerOp_CONTAINER_PAUSE:
		err, done = s.client.ContainerPause(ctx, req.Id), "paused"
	case pb.ContainerOp_CONTAINER_UNPAUSE:
		err, done = s.client.ContainerUnpause(ctx, req.Id), "resumed"
	case pb.ContainerOp_CONTAINER_KILL:
		err, done = s.client.ContainerKill(ctx, req.Id, "SIGKILL"), "killed"
	case pb.ContainerOp_CONTAINER_REMOVE:
		err = s.client.ContainerRemove(ctx, req.Id, container.RemoveOptions{Force: req.Force, RemoveVolumes: req.RemoveVolumes})
		done = "removed"
	default:
		return dockerFail("unknown container operation"), nil
	}
	if err != nil {
		return dockerFail("%v", err), nil
	}
	return &pb.ActionStatus{Success: true, Message: "Container " + done}, nil
}

func dockerTime(v string) int64 {
	t, err := time.Parse(time.RFC3339Nano, v)
	if err != nil || t.Year() < 2000 {
		return 0
	}
	return t.Unix()
}

func (s *dockerServiceServer) InspectContainer(ctx context.Context, req *pb.ContainerId) (*pb.ContainerDetails, error) {
	if s.client == nil {
		return nil, fmt.Errorf("docker client not initialized")
	}
	c, err := s.client.ContainerInspect(ctx, req.Id)
	if err != nil {
		return nil, fmt.Errorf("inspect failed: %v", err)
	}
	d := &pb.ContainerDetails{
		Info: &pb.ContainerInfo{
			Id:      c.ID,
			Names:   []string{strings.TrimPrefix(c.Name, "/")},
			Created: dockerTime(c.Created),
		},
		RestartCount: int32(c.RestartCount),
	}
	if c.Config != nil {
		d.Info.Image = c.Config.Image
		d.Command = strings.TrimSpace(strings.Join(append(append([]string{}, c.Config.Entrypoint...), c.Config.Cmd...), " "))
		d.Env = c.Config.Env
		d.Hostname = c.Config.Hostname
		d.Tty = c.Config.Tty
		d.Info.ComposeProject = c.Config.Labels["com.docker.compose.project"]
		d.Info.ComposeService = c.Config.Labels["com.docker.compose.service"]
	}
	if c.State != nil {
		d.Info.State = c.State.Status
		d.ExitCode = int32(c.State.ExitCode)
		d.StartedAt = dockerTime(c.State.StartedAt)
		d.FinishedAt = dockerTime(c.State.FinishedAt)
		if c.State.Health != nil {
			d.Health = string(c.State.Health.Status)
		}
	}
	if c.HostConfig != nil {
		d.RestartPolicy = string(c.HostConfig.RestartPolicy.Name)
		for port, bindings := range c.HostConfig.PortBindings {
			for _, b := range bindings {
				d.Info.Ports = append(d.Info.Ports, fmt.Sprintf("%s:%s", b.HostPort, port))
			}
		}
	}
	if c.NetworkSettings != nil {
		for name, n := range c.NetworkSettings.Networks {
			d.Networks = append(d.Networks, name)
			if n != nil && n.IPAddress != "" {
				d.IpAddresses = append(d.IpAddresses, n.IPAddress)
			}
		}
	}
	for _, m := range c.Mounts {
		d.Mounts = append(d.Mounts, &pb.ContainerMount{
			Type:        string(m.Type),
			Source:      m.Source,
			Destination: m.Destination,
			ReadWrite:   m.RW,
			Name:        m.Name,
		})
	}
	return d, nil
}

// containerStatsFrom computes usage like `docker stats` does
func containerStatsFrom(st *container.StatsResponse) *pb.ContainerStats {
	out := &pb.ContainerStats{Pids: st.PidsStats.Current}
	cpuDelta := float64(st.CPUStats.CPUUsage.TotalUsage) - float64(st.PreCPUStats.CPUUsage.TotalUsage)
	sysDelta := float64(st.CPUStats.SystemUsage) - float64(st.PreCPUStats.SystemUsage)
	cpus := float64(st.CPUStats.OnlineCPUs)
	if cpus == 0 {
		cpus = float64(len(st.CPUStats.CPUUsage.PercpuUsage))
	}
	if cpuDelta > 0 && sysDelta > 0 && cpus > 0 {
		out.CpuPercent = cpuDelta / sysDelta * cpus * 100
	}
	// Page cache is not really used memory (cgroup v2: inactive_file, v1: total_inactive_file)
	usage := st.MemoryStats.Usage
	if cache, ok := st.MemoryStats.Stats["inactive_file"]; ok && cache < usage {
		usage -= cache
	} else if cache, ok := st.MemoryStats.Stats["total_inactive_file"]; ok && cache < usage {
		usage -= cache
	}
	out.MemoryUsage = usage
	out.MemoryLimit = st.MemoryStats.Limit
	for _, n := range st.Networks {
		out.NetRx += n.RxBytes
		out.NetTx += n.TxBytes
	}
	for _, e := range st.BlkioStats.IoServiceBytesRecursive {
		switch strings.ToLower(e.Op) {
		case "read":
			out.BlockRead += e.Value
		case "write":
			out.BlockWrite += e.Value
		}
	}
	return out
}

func (s *dockerServiceServer) GetContainerStats(ctx context.Context, req *pb.ContainerId) (*pb.ContainerStats, error) {
	if s.client == nil {
		return nil, fmt.Errorf("docker client not initialized")
	}
	// Not one-shot: Docker samples twice so the CPU share can be computed
	resp, err := s.client.ContainerStats(ctx, req.Id, false)
	if err != nil {
		return nil, fmt.Errorf("stats failed: %v", err)
	}
	defer resp.Body.Close()
	var st container.StatsResponse
	if err := json.NewDecoder(resp.Body).Decode(&st); err != nil {
		return nil, fmt.Errorf("stats unreadable: %v", err)
	}
	return containerStatsFrom(&st), nil
}

func (s *dockerServiceServer) ListImages(ctx context.Context, _ *pb.Empty) (*pb.ImageList, error) {
	if s.client == nil {
		return nil, fmt.Errorf("docker client not initialized")
	}
	images, err := s.client.ImageList(ctx, image.ListOptions{})
	if err != nil {
		return nil, fmt.Errorf("failed to list images: %v", err)
	}
	// Count users ourselves; the API only does it on request and not everywhere
	used := map[string]int32{}
	if containers, err := s.client.ContainerList(ctx, container.ListOptions{All: true}); err == nil {
		for _, c := range containers {
			used[c.ImageID]++
		}
	}
	out := &pb.ImageList{}
	for _, img := range images {
		tags := []string{}
		for _, t := range img.RepoTags {
			if t != "<none>:<none>" {
				tags = append(tags, t)
			}
		}
		out.Images = append(out.Images, &pb.DockerImage{
			Id:         img.ID,
			Tags:       tags,
			Size:       img.Size,
			Created:    img.Created,
			Containers: used[img.ID],
		})
	}
	return out, nil
}

func (s *dockerServiceServer) RemoveImage(ctx context.Context, req *pb.ImageRemoveRequest) (*pb.ActionStatus, error) {
	if s.client == nil {
		return nil, fmt.Errorf("docker client not initialized")
	}
	if req.Id == "" {
		return dockerFail("image id is required"), nil
	}
	deleted, err := s.client.ImageRemove(ctx, req.Id, image.RemoveOptions{Force: req.Force, PruneChildren: true})
	if err != nil {
		return dockerFail("%v", err), nil
	}
	return &pb.ActionStatus{Success: true, Message: fmt.Sprintf("Removed (%d layers or tags)", len(deleted))}, nil
}

func (s *dockerServiceServer) Prune(ctx context.Context, req *pb.PruneRequest) (*pb.PruneResult, error) {
	if s.client == nil {
		return nil, fmt.Errorf("docker client not initialized")
	}
	fail := func(err error) (*pb.PruneResult, error) {
		return &pb.PruneResult{Success: false, Message: err.Error()}, nil
	}
	switch req.Target {
	case pb.PruneTarget_PRUNE_CONTAINERS:
		r, err := s.client.ContainersPrune(ctx, filters.NewArgs())
		if err != nil {
			return fail(err)
		}
		return &pb.PruneResult{Success: true, Deleted: int32(len(r.ContainersDeleted)), SpaceReclaimed: r.SpaceReclaimed,
			Message: "Removed " + countOf(len(r.ContainersDeleted), "stopped container")}, nil
	case pb.PruneTarget_PRUNE_IMAGES, pb.PruneTarget_PRUNE_ALL_IMAGES:
		f := filters.NewArgs()
		if req.Target == pb.PruneTarget_PRUNE_ALL_IMAGES {
			f.Add("dangling", "false")
		}
		r, err := s.client.ImagesPrune(ctx, f)
		if err != nil {
			return fail(err)
		}
		return &pb.PruneResult{Success: true, Deleted: int32(len(r.ImagesDeleted)), SpaceReclaimed: r.SpaceReclaimed,
			Message: "Removed " + countOf(len(r.ImagesDeleted), "image")}, nil
	case pb.PruneTarget_PRUNE_VOLUMES:
		// Like `docker volume prune`: anonymous volumes no container uses
		r, err := s.client.VolumesPrune(ctx, filters.NewArgs())
		if err != nil {
			return fail(err)
		}
		return &pb.PruneResult{Success: true, Deleted: int32(len(r.VolumesDeleted)), SpaceReclaimed: r.SpaceReclaimed,
			Message: "Removed " + countOf(len(r.VolumesDeleted), "volume")}, nil
	case pb.PruneTarget_PRUNE_NETWORKS:
		r, err := s.client.NetworksPrune(ctx, filters.NewArgs())
		if err != nil {
			return fail(err)
		}
		return &pb.PruneResult{Success: true, Deleted: int32(len(r.NetworksDeleted)),
			Message: "Removed " + countOf(len(r.NetworksDeleted), "network")}, nil
	case pb.PruneTarget_PRUNE_BUILD_CACHE:
		r, err := s.client.BuildCachePrune(ctx, build.CachePruneOptions{})
		if err != nil {
			return fail(err)
		}
		return &pb.PruneResult{Success: true, Deleted: int32(len(r.CachesDeleted)), SpaceReclaimed: r.SpaceReclaimed,
			Message: "Removed " + countOf(len(r.CachesDeleted), "build cache entry")}, nil
	}
	return fail(fmt.Errorf("unknown prune target"))
}

package main

import (
	"testing"

	"github.com/docker/docker/api/types/container"
)

func TestContainerStatsFrom(t *testing.T) {
	var st container.StatsResponse
	st.CPUStats.CPUUsage.TotalUsage = 3_000_000
	st.PreCPUStats.CPUUsage.TotalUsage = 1_000_000
	st.CPUStats.SystemUsage = 20_000_000
	st.PreCPUStats.SystemUsage = 10_000_000
	st.CPUStats.OnlineCPUs = 4
	st.MemoryStats.Usage = 300
	st.MemoryStats.Limit = 1000
	st.MemoryStats.Stats = map[string]uint64{"inactive_file": 100}
	st.Networks = map[string]container.NetworkStats{"eth0": {RxBytes: 10, TxBytes: 20}, "eth1": {RxBytes: 1, TxBytes: 2}}
	st.BlkioStats.IoServiceBytesRecursive = []container.BlkioStatEntry{{Op: "Read", Value: 5}, {Op: "write", Value: 7}}
	st.PidsStats.Current = 9

	s := containerStatsFrom(&st)
	// 2M of 10M system time on 4 CPUs = 80 %
	if s.CpuPercent < 79.9 || s.CpuPercent > 80.1 {
		t.Errorf("cpu = %v", s.CpuPercent)
	}
	if s.MemoryUsage != 200 || s.MemoryLimit != 1000 {
		t.Errorf("memory = %d / %d", s.MemoryUsage, s.MemoryLimit)
	}
	if s.NetRx != 11 || s.NetTx != 22 || s.BlockRead != 5 || s.BlockWrite != 7 || s.Pids != 9 {
		t.Errorf("got %+v", s)
	}

	// A first sample without a previous one has no CPU share
	if s := containerStatsFrom(&container.StatsResponse{}); s.CpuPercent != 0 {
		t.Errorf("cpu without delta = %v", s.CpuPercent)
	}
}

func TestDockerLogEntry(t *testing.T) {
	e := dockerLogEntry("2026-10-14T18:00:00.123456789Z listening on :80\r", true)
	if e.Timestamp != 1792000800 || e.Message != "listening on :80" || e.Level != "error" {
		t.Errorf("got %+v", e)
	}
	e = dockerLogEntry("no timestamp here", false)
	if e.Message != "no timestamp here" || e.Level != "info" {
		t.Errorf("got %+v", e)
	}
}

//go:build !windows

package main

import (
	"os/exec"
	"syscall"
)

// runAsUser makes cmd run with the uid, gid and supplementary groups of the
// PM2 user. Only takes effect when the agent runs as root.
func runAsUser(cmd *exec.Cmd, uid, gid uint32, groups []uint32) {
	cmd.SysProcAttr = &syscall.SysProcAttr{
		Credential: &syscall.Credential{Uid: uid, Gid: gid, Groups: groups},
	}
}

// processAlive reports whether a process with the given pid exists.
func processAlive(pid int) bool {
	if pid <= 0 {
		return false
	}
	err := syscall.Kill(pid, 0)
	return err == nil || err == syscall.EPERM
}

//go:build windows

package main

import "os/exec"

// The agent only runs on the Pi; these stubs keep it compiling on Windows.

func runAsUser(cmd *exec.Cmd, uid, gid uint32, groups []uint32) {}

func processAlive(pid int) bool { return false }

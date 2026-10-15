package main

import (
	"bufio"
	"bytes"
	"context"
	"fmt"
	"net"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"sort"
	"strconv"
	"strings"
	"time"

	pb "pi_agent/proto"
)

type systemAdminServer struct {
	pb.UnimplementedSystemAdminServer
}

var (
	adminUserPattern  = regexp.MustCompile(`^[a-z_][a-z0-9_-]{0,31}$`)
	adminPortPattern  = regexp.MustCompile(`^\d{1,5}(:\d{1,5})?$`)
	adminIfacePattern = regexp.MustCompile(`^[a-zA-Z0-9._-]{1,15}$`)
	adminAppPattern   = regexp.MustCompile(`^[A-Za-z0-9 ._+-]{1,64}$`)
)

// adminRun runs a command as root and returns its combined output
func adminRun(ctx context.Context, timeout time.Duration, stdin string, name string, args ...string) *pb.CommandOutput {
	ctx, cancel := context.WithTimeout(ctx, timeout)
	defer cancel()

	cmd := exec.CommandContext(ctx, name, args...)
	cmd.Env = append(os.Environ(), "DEBIAN_FRONTEND=noninteractive", "LC_ALL=C")
	if stdin != "" {
		cmd.Stdin = strings.NewReader(stdin)
	}
	output, code, err := runCombined(cmd)
	result := &pb.CommandOutput{
		Command:  pm2CommandLine(name, args),
		Output:   strings.TrimSpace(output),
		ExitCode: int32(code),
		Success:  err == nil && code == 0,
	}
	if err != nil {
		result.Output = strings.TrimSpace(result.Output + "\n" + err.Error())
	}
	if ctx.Err() == context.DeadlineExceeded {
		result.Success = false
		result.Output = strings.TrimSpace(result.Output + "\nTimed out")
	}
	return result
}

func adminFail(format string, a ...interface{}) *pb.CommandOutput {
	return &pb.CommandOutput{Success: false, Output: fmt.Sprintf(format, a...), ExitCode: 1}
}

func adminOutput(ctx context.Context, name string, args ...string) string {
	ctx, cancel := context.WithTimeout(ctx, 10*time.Second)
	defer cancel()
	out, _ := exec.CommandContext(ctx, name, args...).Output()
	return strings.TrimSpace(string(out))
}

func adminAgentUser() string {
	if u, err := resolvePm2User(); err == nil {
		return u.Username
	}
	return "root"
}

func adminCheckUser(name string) error {
	if !adminUserPattern.MatchString(name) {
		return fmt.Errorf("invalid user name %q", name)
	}
	return nil
}

// ==================== Cron ====================

func (s *systemAdminServer) GetCrontab(ctx context.Context, req *pb.CrontabRequest) (*pb.Crontab, error) {
	user := req.User
	if user == "" {
		user = adminAgentUser()
	}
	if err := adminCheckUser(user); err != nil {
		return nil, err
	}

	result := &pb.Crontab{User: user}

	cctx, cancel := context.WithTimeout(ctx, 10*time.Second)
	defer cancel()
	out, err := exec.CommandContext(cctx, "crontab", "-l", "-u", user).CombinedOutput()
	if err == nil {
		result.Exists = true
		result.Content = string(out)
	}

	for _, dir := range []string{"/var/spool/cron/crontabs", "/var/spool/cron"} {
		entries, err := os.ReadDir(dir)
		if err != nil {
			continue
		}
		for _, e := range entries {
			if !e.IsDir() && adminUserPattern.MatchString(e.Name()) {
				result.UsersWithCrontab = append(result.UsersWithCrontab, e.Name())
			}
		}
		break
	}

	files := []string{"/etc/crontab"}
	if extra, err := filepath.Glob("/etc/cron.d/*"); err == nil {
		files = append(files, extra...)
	}
	for _, path := range files {
		info, err := os.Stat(path)
		if err != nil || info.IsDir() || info.Size() > 256*1024 {
			continue
		}
		if data, err := os.ReadFile(path); err == nil {
			result.SystemFiles = append(result.SystemFiles, &pb.CronFile{Path: path, Content: string(data)})
		}
	}

	return result, nil
}

func (s *systemAdminServer) SetCrontab(ctx context.Context, req *pb.Crontab) (*pb.CommandOutput, error) {
	if err := adminCheckUser(req.User); err != nil {
		return adminFail("%v", err), nil
	}
	content := req.Content
	if strings.TrimSpace(content) == "" {
		return adminRun(ctx, 10*time.Second, "", "crontab", "-r", "-u", req.User), nil
	}
	if !strings.HasSuffix(content, "\n") {
		content += "\n"
	}
	// crontab validates the syntax and rejects invalid files
	return adminRun(ctx, 10*time.Second, content, "crontab", "-u", req.User, "-"), nil
}

func (s *systemAdminServer) RunAsUser(ctx context.Context, req *pb.RunAsUserRequest) (*pb.CommandOutput, error) {
	if err := adminCheckUser(req.User); err != nil {
		return adminFail("%v", err), nil
	}
	if strings.TrimSpace(req.Command) == "" {
		return adminFail("command is required"), nil
	}
	timeout := time.Duration(req.TimeoutSeconds) * time.Second
	if timeout <= 0 || timeout > 10*time.Minute {
		timeout = time.Minute
	}
	result := adminRun(ctx, timeout, "", "runuser", "-l", req.User, "-c", req.Command)
	if len(result.Output) > 64*1024 {
		result.Output = result.Output[len(result.Output)-64*1024:]
	}
	return result, nil
}

// ==================== Firewall ====================

var ufwNumberedRule = regexp.MustCompile(`^\[\s*(\d+)\]\s+(.+?)\s{2,}((?:ALLOW|DENY|REJECT|LIMIT)(?:\s+(?:IN|OUT|FWD))?)\s{2,}(.+?)\s*$`)

func (s *systemAdminServer) GetFirewall(ctx context.Context, req *pb.Empty) (*pb.FirewallStatus, error) {
	result := &pb.FirewallStatus{SshPort: 22}

	// Prefer the port sshd actually listens on; the config can differ (sshd -p)
	if ports := sshListenPorts(adminOutput(ctx, "ss", "-Htlnp")); len(ports) > 0 {
		result.SshPort = ports[0]
	} else if port := adminOutput(ctx, "sh", "-c", "sshd -T 2>/dev/null | awk '/^port /{print $2; exit}'"); port != "" {
		if p, err := strconv.Atoi(port); err == nil {
			result.SshPort = int32(p)
		}
	}

	if _, err := exec.LookPath("ufw"); err != nil {
		return result, nil
	}
	result.Installed = true

	verbose := adminOutput(ctx, "ufw", "status", "verbose")
	result.Raw = verbose
	for _, line := range strings.Split(verbose, "\n") {
		switch {
		case strings.HasPrefix(line, "Status:"):
			result.Active = strings.Contains(line, "active") && !strings.Contains(line, "inactive")
		case strings.HasPrefix(line, "Logging:"):
			result.Logging = strings.TrimSpace(strings.TrimPrefix(line, "Logging:"))
		case strings.HasPrefix(line, "Default:"):
			for _, part := range strings.Split(strings.TrimPrefix(line, "Default:"), ",") {
				part = strings.TrimSpace(part)
				fields := strings.Fields(part)
				if len(fields) < 2 {
					continue
				}
				switch strings.Trim(fields[1], "()") {
				case "incoming":
					result.DefaultIncoming = fields[0]
				case "outgoing":
					result.DefaultOutgoing = fields[0]
				case "routed":
					result.DefaultRouted = fields[0]
				}
			}
		}
	}

	numbered := adminOutput(ctx, "ufw", "status", "numbered")
	for _, line := range strings.Split(numbered, "\n") {
		m := ufwNumberedRule.FindStringSubmatch(strings.TrimRight(line, " "))
		if m == nil {
			continue
		}
		n, _ := strconv.Atoi(m[1])
		from, comment := m[4], ""
		if i := strings.Index(from, "#"); i >= 0 {
			comment = strings.TrimSpace(from[i+1:])
			from = strings.TrimSpace(from[:i])
		}
		result.Rules = append(result.Rules, &pb.FirewallRule{
			Number:  int32(n),
			To:      strings.TrimSpace(m[2]),
			Action:  m[3],
			From:    from,
			V6:      strings.Contains(m[2], "(v6)") || strings.Contains(from, "(v6)"),
			Comment: comment,
		})
	}

	// An inactive firewall lists no rules in `ufw status`; show the rules it will apply
	if !result.Active {
		result.Rules = append(result.Rules, ufwAddedRules(adminOutput(ctx, "ufw", "show", "added"))...)
	}

	for _, line := range strings.Split(adminOutput(ctx, "ufw", "app", "list"), "\n") {
		line = strings.TrimSpace(line)
		if line != "" && !strings.HasSuffix(line, ":") {
			result.AppProfiles = append(result.AppProfiles, line)
		}
	}
	return result, nil
}

// sshListenPorts returns the TCP ports sshd listens on, from `ss -Htlnp`
func sshListenPorts(output string) []int32 {
	var ports []int32
	seen := map[int32]bool{}
	for _, line := range strings.Split(output, "\n") {
		if !strings.Contains(line, `"sshd`) {
			continue
		}
		fields := strings.Fields(line)
		if len(fields) < 4 {
			continue
		}
		local := fields[3]
		i := strings.LastIndex(local, ":")
		if i < 0 {
			continue
		}
		p, err := strconv.Atoi(local[i+1:])
		if err != nil || seen[int32(p)] {
			continue
		}
		seen[int32(p)] = true
		ports = append(ports, int32(p))
	}
	return ports
}

// firewallAllowsPort reports whether a rule lets TCP traffic to port in from anywhere
func firewallAllowsPort(rules []*pb.FirewallRule, port int32) bool {
	p := strconv.Itoa(int(port))
	for _, r := range rules {
		if !strings.HasPrefix(r.Action, "ALLOW") && !strings.HasPrefix(r.Action, "LIMIT") {
			continue
		}
		if strings.HasSuffix(r.Action, "OUT") || !strings.HasPrefix(r.From, "Anywhere") {
			continue
		}
		to := strings.Fields(r.To)
		if len(to) == 0 {
			continue
		}
		if to[0] == p || to[0] == p+"/tcp" || (port == 22 && to[0] == "OpenSSH") {
			return true
		}
	}
	return false
}

var ufwComment = regexp.MustCompile(`\s+comment\s+'([^']*)'\s*$`)

// ufwAddedRules parses `ufw show added` lines such as "ufw allow 443/tcp comment 'HTTPS'"
func ufwAddedRules(output string) []*pb.FirewallRule {
	var rules []*pb.FirewallRule
	for _, line := range strings.Split(output, "\n") {
		line = strings.TrimSpace(line)
		if !strings.HasPrefix(line, "ufw ") {
			continue
		}
		spec := strings.TrimPrefix(line, "ufw ")
		body, comment := spec, ""
		if m := ufwComment.FindStringSubmatchIndex(spec); m != nil {
			comment = spec[m[2]:m[3]]
			body = spec[:m[0]]
		}
		fields := strings.Fields(body)
		if len(fields) < 2 {
			continue
		}
		action := strings.ToUpper(fields[0])
		rest := fields[1:]
		if rest[0] == "in" || rest[0] == "out" {
			action += " " + strings.ToUpper(rest[0])
			rest = rest[1:]
		}
		from, to := "Anywhere", strings.Join(rest, " ")
		if len(rest) > 0 && rest[0] == "from" {
			from, to = "", "Anywhere"
			for i := 1; i < len(rest); i++ {
				if rest[i] == "to" || rest[i] == "port" || rest[i] == "proto" {
					to = strings.TrimPrefix(strings.Join(rest[i:], " "), "to ")
					break
				}
				from = strings.TrimSpace(from + " " + rest[i])
			}
		}
		rules = append(rules, &pb.FirewallRule{
			To:      to,
			Action:  action,
			From:    from,
			Comment: comment,
			Spec:    spec,
		})
	}
	return rules
}

func validAddress(v string) bool {
	if v == "" || v == "any" {
		return true
	}
	if net.ParseIP(v) != nil {
		return true
	}
	_, _, err := net.ParseCIDR(v)
	return err == nil
}

func (s *systemAdminServer) FirewallAction(ctx context.Context, req *pb.FirewallRequest) (*pb.CommandOutput, error) {
	ufw := func(args ...string) *pb.CommandOutput {
		return adminRun(ctx, 30*time.Second, "", "ufw", args...)
	}

	if req.Op == pb.FirewallOp_FW_INSTALL {
		return adminRun(ctx, 10*time.Minute, "", "apt-get", "install", "-y", "ufw"), nil
	}
	if _, err := exec.LookPath("ufw"); err != nil {
		return adminFail("ufw is not installed"), nil
	}

	switch req.Op {
	case pb.FirewallOp_FW_ENABLE:
		// Never lock the app out: allow the SSH port before enabling
		status, _ := s.GetFirewall(ctx, &pb.Empty{})
		ports := sshListenPorts(adminOutput(ctx, "ss", "-Htlnp"))
		if len(ports) == 0 {
			ports = []int32{status.SshPort}
		}
		var out strings.Builder
		for _, p := range ports {
			if !firewallAllowsPort(status.Rules, p) {
				res := ufw("allow", fmt.Sprintf("%d/tcp", p), "comment", "SSH (added by Pi Control)")
				out.WriteString(res.Output + "\n")
			}
		}
		res := ufw("--force", "enable")
		res.Output = strings.TrimSpace(out.String() + res.Output)
		return res, nil
	case pb.FirewallOp_FW_DISABLE:
		return ufw("disable"), nil
	case pb.FirewallOp_FW_RELOAD:
		return ufw("reload"), nil
	case pb.FirewallOp_FW_RESET:
		return ufw("--force", "reset"), nil
	case pb.FirewallOp_FW_DELETE_RULE:
		if req.Number <= 0 && req.RuleSpec != "" {
			// A rule of an inactive firewall: only delete one ufw actually lists
			for _, r := range ufwAddedRules(adminOutput(ctx, "ufw", "show", "added")) {
				if r.Spec == req.RuleSpec {
					body := ufwComment.ReplaceAllString(r.Spec, "")
					return ufw(append([]string{"--force", "delete"}, strings.Fields(body)...)...), nil
				}
			}
			return adminFail("rule not found; refresh and try again"), nil
		}
		if req.Number <= 0 {
			return adminFail("rule number is required"), nil
		}
		return ufw("--force", "delete", strconv.Itoa(int(req.Number))), nil
	case pb.FirewallOp_FW_SET_DEFAULT:
		if !map[string]bool{"allow": true, "deny": true, "reject": true}[req.Policy] ||
			!map[string]bool{"incoming": true, "outgoing": true, "routed": true}[req.Chain] {
			return adminFail("invalid default policy"), nil
		}
		return ufw("default", req.Policy, req.Chain), nil
	case pb.FirewallOp_FW_SET_LOGGING:
		if !map[string]bool{"off": true, "on": true, "low": true, "medium": true, "high": true, "full": true}[req.Logging] {
			return adminFail("invalid logging level"), nil
		}
		return ufw("logging", req.Logging), nil
	case pb.FirewallOp_FW_ADD_RULE:
		args, err := firewallRuleArgs(req)
		if err != nil {
			return adminFail("%v", err), nil
		}
		return ufw(args...), nil
	}
	return adminFail("unknown firewall operation"), nil
}

// firewallRuleArgs builds `ufw allow ...` from validated fields
func firewallRuleArgs(req *pb.FirewallRequest) ([]string, error) {
	action := req.RuleAction
	if !map[string]bool{"allow": true, "deny": true, "reject": true, "limit": true}[action] {
		return nil, fmt.Errorf("rule action must be allow, deny, reject or limit")
	}
	args := []string{action}
	if req.Direction == "in" || req.Direction == "out" {
		args = append(args, req.Direction)
	}
	if req.Interface != "" {
		if !adminIfacePattern.MatchString(req.Interface) {
			return nil, fmt.Errorf("invalid interface name %q", req.Interface)
		}
		args = append(args, "on", req.Interface)
	}

	port := strings.TrimSpace(req.Port)
	if port != "" && !adminPortPattern.MatchString(port) {
		// An application profile such as "OpenSSH"
		if !adminAppPattern.MatchString(port) {
			return nil, fmt.Errorf("invalid port %q (use 80, 8000:8100 or an app profile)", port)
		}
		args = append(args, port)
	} else {
		if !validAddress(req.From) || !validAddress(req.To) {
			return nil, fmt.Errorf("invalid address: use an IP like 192.168.1.20 or a subnet like 192.168.1.0/24")
		}
		proto := req.Protocol
		if proto != "tcp" && proto != "udp" {
			proto = ""
		}
		if proto != "" {
			args = append(args, "proto", proto)
		}
		from, to := req.From, req.To
		if from == "" {
			from = "any"
		}
		if to == "" {
			to = "any"
		}
		args = append(args, "from", from, "to", to)
		if port != "" {
			args = append(args, "port", port)
		}
	}
	if c := strings.TrimSpace(req.Comment); c != "" {
		args = append(args, "comment", c)
	}
	return args, nil
}

// ==================== Users ====================

func (s *systemAdminServer) ListUsers(ctx context.Context, req *pb.Empty) (*pb.UserList, error) {
	result := &pb.UserList{AgentUser: adminAgentUser()}

	groupMembers := map[string][]string{}
	primaryGroup := map[int]string{}
	for _, line := range strings.Split(adminOutput(ctx, "getent", "group"), "\n") {
		f := strings.Split(line, ":")
		if len(f) < 4 {
			continue
		}
		gid, _ := strconv.Atoi(f[2])
		var members []string
		if f[3] != "" {
			members = strings.Split(f[3], ",")
		}
		primaryGroup[gid] = f[0]
		for _, m := range members {
			groupMembers[m] = append(groupMembers[m], f[0])
		}
		result.Groups = append(result.Groups, &pb.SystemGroup{
			Name: f[0], Gid: int32(gid), Members: members, IsSystem: gid < 1000 && gid != 0,
		})
	}

	status := map[string]string{}
	for _, line := range strings.Split(adminOutput(ctx, "passwd", "-Sa"), "\n") {
		f := strings.Fields(line)
		if len(f) >= 2 {
			status[f[0]] = f[1]
		}
	}

	for _, line := range strings.Split(adminOutput(ctx, "getent", "passwd"), "\n") {
		f := strings.Split(line, ":")
		if len(f) < 7 {
			continue
		}
		uid, _ := strconv.Atoi(f[2])
		gid, _ := strconv.Atoi(f[3])
		groups := groupMembers[f[0]]
		if pg, ok := primaryGroup[gid]; ok {
			groups = append([]string{pg}, groups...)
		}
		canSudo := uid == 0
		for _, g := range groups {
			if g == "sudo" || g == "wheel" || g == "admin" {
				canSudo = true
			}
		}
		st := status[f[0]]
		result.Users = append(result.Users, &pb.SystemUser{
			Name:        f[0],
			Uid:         int32(uid),
			Gid:         int32(gid),
			FullName:    strings.Split(f[4], ",")[0],
			Home:        f[5],
			Shell:       f[6],
			Groups:      groups,
			Locked:      st == "L" || st == "LK",
			IsSystem:    uid != 0 && (uid < 1000 || uid == 65534),
			CanSudo:     canSudo,
			HasPassword: st == "P" || st == "PS",
		})
	}
	sort.Slice(result.Users, func(i, j int) bool { return result.Users[i].Uid < result.Users[j].Uid })

	if data, err := os.ReadFile("/etc/shells"); err == nil {
		for _, line := range strings.Split(string(data), "\n") {
			line = strings.TrimSpace(line)
			if strings.HasPrefix(line, "/") {
				result.Shells = append(result.Shells, line)
			}
		}
	}
	return result, nil
}

func (s *systemAdminServer) UserAction(ctx context.Context, req *pb.UserRequest) (*pb.CommandOutput, error) {
	run := func(stdin string, name string, args ...string) *pb.CommandOutput {
		return adminRun(ctx, 60*time.Second, stdin, name, args...)
	}
	isGroupOp := req.Op == pb.UserOp_GROUP_CREATE || req.Op == pb.UserOp_GROUP_DELETE
	if !isGroupOp {
		if err := adminCheckUser(req.Username); err != nil {
			return adminFail("%v", err), nil
		}
	}
	checkGroup := func(g string) error {
		if !adminUserPattern.MatchString(g) {
			return fmt.Errorf("invalid group name %q", g)
		}
		return nil
	}
	protected := req.Username == "root" || req.Username == adminAgentUser()

	switch req.Op {
	case pb.UserOp_USER_CREATE:
		args := []string{"-m", "-s", "/bin/bash"}
		if req.Shell != "" {
			if !strings.HasPrefix(req.Shell, "/") {
				return adminFail("invalid shell"), nil
			}
			args[2] = req.Shell
		}
		if req.FullName != "" {
			args = append(args, "-c", strings.ReplaceAll(req.FullName, ":", " "))
		}
		groups := append([]string{}, req.Groups...)
		if req.Sudo {
			groups = append(groups, "sudo")
		}
		for _, g := range groups {
			if err := checkGroup(g); err != nil {
				return adminFail("%v", err), nil
			}
		}
		if len(groups) > 0 {
			args = append(args, "-G", strings.Join(groups, ","))
		}
		args = append(args, req.Username)
		if strings.ContainsAny(req.Password, "\r\n") {
			return adminFail("invalid password"), nil
		}
		res := run("", "useradd", args...)
		if res.Success && req.Password != "" {
			pw := run(req.Username+":"+req.Password+"\n", "chpasswd")
			res.Output = strings.TrimSpace(res.Output + "\n" + pw.Output)
			res.Success = pw.Success
		}
		return res, nil

	case pb.UserOp_USER_DELETE:
		if protected {
			return adminFail("%s cannot be deleted from the app", req.Username), nil
		}
		if req.RemoveHome {
			return run("", "userdel", "-r", req.Username), nil
		}
		return run("", "userdel", req.Username), nil

	case pb.UserOp_USER_SET_PASSWORD:
		if req.Password == "" || strings.ContainsAny(req.Password, "\r\n") {
			return adminFail("invalid password"), nil
		}
		return run(req.Username+":"+req.Password+"\n", "chpasswd"), nil

	case pb.UserOp_USER_LOCK:
		if protected {
			return adminFail("%s cannot be locked from the app", req.Username), nil
		}
		return run("", "usermod", "-L", req.Username), nil
	case pb.UserOp_USER_UNLOCK:
		return run("", "usermod", "-U", req.Username), nil

	case pb.UserOp_USER_ADD_GROUP:
		if err := checkGroup(req.Group); err != nil {
			return adminFail("%v", err), nil
		}
		return run("", "gpasswd", "-a", req.Username, req.Group), nil
	case pb.UserOp_USER_REMOVE_GROUP:
		if err := checkGroup(req.Group); err != nil {
			return adminFail("%v", err), nil
		}
		if req.Username == adminAgentUser() && (req.Group == "sudo" || req.Group == "wheel") {
			return adminFail("removing sudo from %s would break the app's access", req.Username), nil
		}
		return run("", "gpasswd", "-d", req.Username, req.Group), nil

	case pb.UserOp_USER_SET_SHELL:
		if !strings.HasPrefix(req.Shell, "/") {
			return adminFail("invalid shell"), nil
		}
		return run("", "usermod", "-s", req.Shell, req.Username), nil
	case pb.UserOp_USER_SET_FULL_NAME:
		return run("", "usermod", "-c", strings.ReplaceAll(req.FullName, ":", " "), req.Username), nil

	case pb.UserOp_GROUP_CREATE:
		if err := checkGroup(req.Group); err != nil {
			return adminFail("%v", err), nil
		}
		return run("", "groupadd", req.Group), nil
	case pb.UserOp_GROUP_DELETE:
		if err := checkGroup(req.Group); err != nil {
			return adminFail("%v", err), nil
		}
		if map[string]bool{"root": true, "sudo": true, "wheel": true, "adm": true}[req.Group] {
			return adminFail("%s cannot be deleted from the app", req.Group), nil
		}
		return run("", "groupdel", req.Group), nil
	}
	return adminFail("unknown user operation"), nil
}

// ==================== Hardware ====================

var throttleFlags = []struct {
	bit  uint
	text string
}{
	{0, "Under-voltage"},
	{1, "ARM frequency capped"},
	{2, "Throttled"},
	{3, "Soft temperature limit"},
}

func (s *systemAdminServer) GetHardwareInfo(ctx context.Context, req *pb.Empty) (*pb.HardwareInfo, error) {
	info := &pb.HardwareInfo{
		Architecture: adminOutput(ctx, "uname", "-m"),
		Kernel:       adminOutput(ctx, "uname", "-r"),
		Hostname:     adminOutput(ctx, "hostname"),
		Os:           adminOutput(ctx, "sh", "-c", `. /etc/os-release 2>/dev/null; echo "$PRETTY_NAME"`),
	}

	if data, err := os.ReadFile("/proc/device-tree/model"); err == nil {
		info.Model = strings.TrimRight(string(data), "\x00\n")
		info.IsRaspberryPi = strings.Contains(info.Model, "Raspberry Pi")
	}

	if data, err := os.ReadFile("/proc/cpuinfo"); err == nil {
		for _, line := range strings.Split(string(data), "\n") {
			k, v, ok := strings.Cut(line, ":")
			if !ok {
				continue
			}
			k, v = strings.TrimSpace(k), strings.TrimSpace(v)
			switch k {
			case "Serial":
				info.Serial = v
			case "Revision":
				info.Revision = v
			case "Hardware":
				info.Soc = v
			case "processor":
				info.CpuCores++
			case "model name":
				if info.Soc == "" {
					info.Soc = v
				}
			}
		}
	}
	if compat, err := os.ReadFile("/proc/device-tree/compatible"); err == nil {
		for _, c := range strings.Split(string(compat), "\x00") {
			if strings.HasPrefix(c, "brcm,bcm") {
				info.Soc = strings.ToUpper(strings.TrimPrefix(c, "brcm,"))
			}
		}
	}

	readMHz := func(path string) int64 {
		data, err := os.ReadFile(path)
		if err != nil {
			return 0
		}
		khz, _ := strconv.ParseInt(strings.TrimSpace(string(data)), 10, 64)
		return khz / 1000
	}
	for i := 0; i < int(info.CpuCores); i++ {
		info.CpuFreqMhz = append(info.CpuFreqMhz, readMHz(fmt.Sprintf("/sys/devices/system/cpu/cpu%d/cpufreq/scaling_cur_freq", i)))
	}
	info.CpuMinMhz = readMHz("/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq")
	info.CpuMaxMhz = readMHz("/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq")
	if g, err := os.ReadFile("/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor"); err == nil {
		info.Governor = strings.TrimSpace(string(g))
	}
	if t, err := os.ReadFile("/sys/class/thermal/thermal_zone0/temp"); err == nil {
		milli, _ := strconv.ParseFloat(strings.TrimSpace(string(t)), 64)
		info.CpuTemp = milli / 1000
	}
	if data, err := os.ReadFile("/proc/meminfo"); err == nil {
		for _, line := range strings.Split(string(data), "\n") {
			if strings.HasPrefix(line, "MemTotal:") {
				kb, _ := strconv.ParseUint(strings.Fields(line)[1], 10, 64)
				info.MemoryTotal = kb * 1024
			}
		}
	}

	if _, err := exec.LookPath("vcgencmd"); err == nil {
		info.VcgencmdAvailable = true
		vc := func(args ...string) string { return adminOutput(ctx, "vcgencmd", args...) }

		throttled := vc("get_throttled")
		info.ThrottledRaw = strings.TrimPrefix(throttled, "throttled=")
		if v, err := strconv.ParseUint(strings.TrimPrefix(info.ThrottledRaw, "0x"), 16, 64); err == nil {
			for _, f := range throttleFlags {
				if v&(1<<f.bit) != 0 {
					info.ThrottledNow = append(info.ThrottledNow, f.text)
				}
				if v&(1<<(f.bit+16)) != 0 {
					info.ThrottledPast = append(info.ThrottledPast, f.text)
				}
			}
		}

		info.Voltages = map[string]string{}
		for _, id := range []string{"core", "sdram_c", "sdram_i", "sdram_p"} {
			if v := strings.TrimPrefix(vc("measure_volts", id), "volt="); v != "" && !strings.Contains(v, "error") {
				info.Voltages[id] = v
			}
		}
		info.Clocks = map[string]string{}
		for _, id := range []string{"arm", "core", "v3d", "emmc"} {
			out := vc("measure_clock", id)
			if _, hz, ok := strings.Cut(out, "="); ok {
				if n, err := strconv.ParseInt(hz, 10, 64); err == nil && n > 0 {
					info.Clocks[id] = fmt.Sprintf("%d MHz", n/1000000)
				}
			}
		}
		info.GpuMemory = strings.TrimPrefix(vc("get_mem", "gpu"), "gpu=")
		if fw := strings.Split(vc("version"), "\n"); len(fw) > 0 {
			info.Firmware = strings.TrimSpace(fw[0])
		}
	}

	if _, err := exec.LookPath("rpi-eeprom-update"); err == nil {
		out := adminOutput(ctx, "rpi-eeprom-update")
		for _, line := range strings.Split(out, "\n") {
			line = strings.TrimSpace(line)
			if strings.HasPrefix(line, "BOOTLOADER:") || strings.HasPrefix(line, "CURRENT:") {
				info.Bootloader = strings.TrimSpace(info.Bootloader + " " + line)
			}
		}
	}

	if _, err := exec.LookPath("lsusb"); err == nil {
		scanner := bufio.NewScanner(bytes.NewBufferString(adminOutput(ctx, "lsusb")))
		for scanner.Scan() {
			line := scanner.Text()
			if i := strings.Index(line, "ID "); i >= 0 {
				line = strings.TrimSpace(line[i+3:])
				if len(line) > 10 {
					line = strings.TrimSpace(line[10:])
				}
			}
			if line != "" && !strings.Contains(strings.ToLower(line), "root hub") {
				info.UsbDevices = append(info.UsbDevices, line)
			}
		}
	}

	return info, nil
}

// pinctrl: " 4: op dh pn | hi // GPIO4 = output"
var pinctrlLine = regexp.MustCompile(`^\s*(\d+):\s+(\w+)\s+(?:(dh|dl)\s+)?(pu|pd|pn|--)?\s*\|\s*(hi|lo|--)\s*//\s*(.*?)\s*=\s*(.*)$`)

// raspi-gpio: "GPIO 4: level=1 fsel=0 func=INPUT pull=UP"
var raspiGpioLine = regexp.MustCompile(`^GPIO (\d+): level=(\d) (?:alt=\d )?fsel=(\d+)(?: alt=\d)? func=(\S+)(?: pull=(\S+))?`)

func (s *systemAdminServer) GetGpio(ctx context.Context, req *pb.Empty) (*pb.GpioState, error) {
	state := &pb.GpioState{}
	if _, err := exec.LookPath("pinctrl"); err == nil {
		state.Tool = "pinctrl"
		out := adminOutput(ctx, "pinctrl", "get", "0-27")
		for _, line := range strings.Split(out, "\n") {
			m := pinctrlLine.FindStringSubmatch(line)
			if m == nil {
				continue
			}
			n, _ := strconv.Atoi(m[1])
			mode := map[string]string{"ip": "input", "op": "output", "no": "none"}[m[2]]
			if mode == "" {
				mode = strings.Replace(m[2], "a", "alt", 1)
			}
			name := m[6]
			if i := strings.LastIndex(name, "/"); i >= 0 {
				name = name[i+1:]
			}
			fn := strings.TrimSpace(m[7])
			if fn == "input" || fn == "output" || fn == "none" {
				fn = name
			}
			state.Pins = append(state.Pins, &pb.GpioPin{
				Gpio:     int32(n),
				Mode:     mode,
				Pull:     map[string]string{"pu": "up", "pd": "down", "pn": "none"}[m[4]],
				Level:    m[5] == "hi",
				Function: fn,
			})
		}
	} else if _, err := exec.LookPath("raspi-gpio"); err == nil {
		state.Tool = "raspi-gpio"
		for _, line := range strings.Split(adminOutput(ctx, "raspi-gpio", "get", "0-27"), "\n") {
			m := raspiGpioLine.FindStringSubmatch(line)
			if m == nil {
				continue
			}
			n, _ := strconv.Atoi(m[1])
			mode := strings.ToLower(m[4])
			if mode != "input" && mode != "output" {
				mode = "alt"
			}
			state.Pins = append(state.Pins, &pb.GpioPin{
				Gpio:     int32(n),
				Mode:     mode,
				Pull:     strings.ToLower(m[5]),
				Level:    m[2] == "1",
				Function: m[4],
			})
		}
	} else {
		state.Error = "Neither pinctrl nor raspi-gpio is installed. GPIO control needs a Raspberry Pi."
		return state, nil
	}
	state.Supported = len(state.Pins) > 0
	if !state.Supported {
		state.Error = "No GPIO pins found on this device."
	}
	return state, nil
}

func (s *systemAdminServer) SetGpio(ctx context.Context, req *pb.GpioRequest) (*pb.CommandOutput, error) {
	if req.Gpio < 0 || req.Gpio > 27 {
		return adminFail("GPIO must be between 0 and 27"), nil
	}
	pin := strconv.Itoa(int(req.Gpio))
	level := "dl"
	if req.Level {
		level = "dh"
	}
	pull := map[string]string{"up": "pu", "down": "pd", "none": "pn"}[req.Pull]

	tool := "pinctrl"
	if _, err := exec.LookPath("pinctrl"); err != nil {
		tool = "raspi-gpio"
	}
	switch req.Mode {
	case "output":
		return adminRun(ctx, 10*time.Second, "", tool, "set", pin, "op", level), nil
	case "input":
		args := []string{"set", pin, "ip"}
		if pull != "" {
			args = append(args, pull)
		}
		return adminRun(ctx, 10*time.Second, "", tool, args...), nil
	}
	return adminFail("mode must be input or output"), nil
}

// ==================== Power ====================

func (s *systemAdminServer) Power(ctx context.Context, req *pb.PowerRequest) (*pb.CommandOutput, error) {
	action := "reboot"
	if req.Op == pb.PowerOp_POWER_SHUTDOWN {
		action = "poweroff"
	}
	// Answer first, act a moment later so the reply reaches the app
	cmd := exec.Command("sh", "-c", "sleep 2; systemctl "+action+" || shutdown -"+map[string]string{"reboot": "r", "poweroff": "h"}[action]+" now")
	if err := cmd.Start(); err != nil {
		return adminFail("%v", err), nil
	}
	go cmd.Wait()
	return &pb.CommandOutput{Success: true, Output: "The device will " + map[string]string{"reboot": "restart", "poweroff": "shut down"}[action] + " in a few seconds.", Command: "systemctl " + action}, nil
}

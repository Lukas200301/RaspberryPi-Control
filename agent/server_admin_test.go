package main

import (
	"strings"
	"testing"

	pb "pi_agent/proto"
)

func TestUfwNumberedRule(t *testing.T) {
	cases := []struct {
		line, to, action, from string
	}{
		{"[ 1] 22/tcp                     ALLOW IN    Anywhere", "22/tcp", "ALLOW IN", "Anywhere"},
		{"[ 2] 80,443/tcp                 ALLOW IN    192.168.1.0/24             # web", "80,443/tcp", "ALLOW IN", "192.168.1.0/24             # web"},
		{"[ 3] OpenSSH                    LIMIT IN    Anywhere", "OpenSSH", "LIMIT IN", "Anywhere"},
		{"[10] 22/tcp (v6)                ALLOW IN    Anywhere (v6)", "22/tcp (v6)", "ALLOW IN", "Anywhere (v6)"},
		{"[ 4] Anywhere                   DENY OUT    10.0.0.5", "Anywhere", "DENY OUT", "10.0.0.5"},
	}
	for _, c := range cases {
		m := ufwNumberedRule.FindStringSubmatch(c.line)
		if m == nil {
			t.Errorf("no match: %q", c.line)
			continue
		}
		if strings.TrimSpace(m[2]) != c.to || m[3] != c.action || m[4] != c.from {
			t.Errorf("%q: got to=%q action=%q from=%q", c.line, m[2], m[3], m[4])
		}
	}
}

func TestFirewallRuleArgs(t *testing.T) {
	cases := []struct {
		req  *pb.FirewallRequest
		want string
	}{
		{&pb.FirewallRequest{RuleAction: "allow", Port: "22", Protocol: "tcp"}, "allow proto tcp from any to any port 22"},
		{&pb.FirewallRequest{RuleAction: "deny", Direction: "in", From: "10.0.0.0/8", Port: "8000:8100", Protocol: "udp", Comment: "lab"},
			"deny in proto udp from 10.0.0.0/8 to any port 8000:8100 comment lab"},
		{&pb.FirewallRequest{RuleAction: "limit", Port: "OpenSSH"}, "limit OpenSSH"},
		{&pb.FirewallRequest{RuleAction: "allow", From: "192.168.1.20"}, "allow from 192.168.1.20 to any"},
		{&pb.FirewallRequest{RuleAction: "drop", Port: "22"}, "error"},
		{&pb.FirewallRequest{RuleAction: "allow", From: "1.2.3.4; rm -rf /"}, "error"},
		{&pb.FirewallRequest{RuleAction: "allow", Port: "22; reboot"}, "error"},
	}
	for _, c := range cases {
		args, err := firewallRuleArgs(c.req)
		got := strings.Join(args, " ")
		if err != nil {
			got = "error"
		}
		if got != c.want {
			t.Errorf("got %q, want %q", got, c.want)
		}
	}
}

func TestPinctrlLine(t *testing.T) {
	cases := []struct {
		line        string
		gpio        string
		mode, pull  string
		level, name string
	}{
		{" 4: ip    pu | hi // GPIO4 = input", "4", "ip", "pu", "hi", "GPIO4"},
		{"17: op dh pn | hi // GPIO17 = output", "17", "op", "pn", "hi", "GPIO17"},
		{"14: a0    pn | hi // TXD0/GPIO14 = TXD0", "14", "a0", "pn", "hi", "TXD0/GPIO14"},
		{" 2: no    pu | -- // GPIO2 = none", "2", "no", "pu", "--", "GPIO2"},
	}
	for _, c := range cases {
		m := pinctrlLine.FindStringSubmatch(c.line)
		if m == nil {
			t.Errorf("no match: %q", c.line)
			continue
		}
		if m[1] != c.gpio || m[2] != c.mode || m[4] != c.pull || m[5] != c.level || m[6] != c.name {
			t.Errorf("%q: got %q", c.line, m[1:])
		}
	}
}

func TestRaspiGpioLine(t *testing.T) {
	m := raspiGpioLine.FindStringSubmatch("GPIO 4: level=1 fsel=0 func=INPUT pull=UP")
	if m == nil || m[1] != "4" || m[2] != "1" || m[4] != "INPUT" || m[5] != "UP" {
		t.Fatalf("got %q", m)
	}
	m = raspiGpioLine.FindStringSubmatch("GPIO 14: level=1 fsel=4 alt=0 func=TXD0 pull=NONE")
	if m == nil || m[1] != "14" || m[4] != "TXD0" {
		t.Fatalf("got %q", m)
	}
}

func TestUfwAddedRules(t *testing.T) {
	out := "Added user rules (see 'ufw status' for running firewall):\n" +
		"ufw allow 443/tcp comment 'HTTPS'\n" +
		"ufw limit in 22/tcp\n" +
		"ufw deny from 10.0.0.0/8 to any port 8080 proto tcp\n"
	rules := ufwAddedRules(out)
	if len(rules) != 3 {
		t.Fatalf("got %d rules", len(rules))
	}
	if r := rules[0]; r.To != "443/tcp" || r.Action != "ALLOW" || r.From != "Anywhere" || r.Comment != "HTTPS" || r.Spec != "allow 443/tcp comment 'HTTPS'" {
		t.Errorf("rule 0: %+v", r)
	}
	if r := rules[1]; r.To != "22/tcp" || r.Action != "LIMIT IN" {
		t.Errorf("rule 1: %+v", r)
	}
	if r := rules[2]; r.From != "10.0.0.0/8" || r.To != "any port 8080 proto tcp" || r.Action != "DENY" {
		t.Errorf("rule 2: %+v", r)
	}
}

func TestSshListenPorts(t *testing.T) {
	out := `LISTEN 0      128          0.0.0.0:2222      0.0.0.0:*    users:(("sshd",pid=812,fd=3))
LISTEN 0      128             [::]:2222         [::]:*    users:(("sshd",pid=812,fd=4))
LISTEN 0      4096       127.0.0.1:50051     0.0.0.0:*    users:(("agent",pid=900,fd=7))
LISTEN 0      128          0.0.0.0:22        0.0.0.0:*    users:(("sshd",pid=10,fd=3))`
	got := sshListenPorts(out)
	if len(got) != 2 || got[0] != 2222 || got[1] != 22 {
		t.Fatalf("got %v", got)
	}
}

func TestFirewallAllowsPort(t *testing.T) {
	rules := []*pb.FirewallRule{
		{To: "443/tcp", Action: "ALLOW IN", From: "Anywhere"},
		{To: "2222/tcp (v6)", Action: "ALLOW IN", From: "Anywhere (v6)"},
		{To: "8080", Action: "ALLOW IN", From: "10.0.0.0/8"},
		{To: "OpenSSH", Action: "LIMIT IN", From: "Anywhere"},
	}
	cases := map[int32]bool{443: true, 2222: true, 8080: false, 22: true, 80: false}
	for port, want := range cases {
		if got := firewallAllowsPort(rules, port); got != want {
			t.Errorf("port %d: got %v", port, got)
		}
	}
}

func TestParseJournalLine(t *testing.T) {
	e := parseJournalLine([]byte(`{"__REALTIME_TIMESTAMP":"1792000000123456","PRIORITY":"3","SYSLOG_IDENTIFIER":"sshd","_PID":"812","MESSAGE":"Failed password for pi"}`), "")
	if e.Timestamp != 1792000000 || e.Level != "err" || e.Service != "sshd[812]" || e.Message != "Failed password for pi" {
		t.Fatalf("got %+v", e)
	}
	// Binary messages arrive as byte arrays; units without identifier use the unit name
	e = parseJournalLine([]byte(`{"PRIORITY":"6","_SYSTEMD_UNIT":"web.service","MESSAGE":[104,105]}`), "")
	if e.Message != "hi" || e.Service != "web" || e.Level != "info" {
		t.Fatalf("got %+v", e)
	}
	if parseJournalLine([]byte("   "), "") != nil {
		t.Fatal("blank line should be skipped")
	}
	if e := parseJournalLine([]byte("plain text"), "x"); e.Message != "plain text" || e.Service != "x" {
		t.Fatalf("got %+v", e)
	}
}

func TestParseUpgradableLine(t *testing.T) {
	p := parseUpgradableLine("openssl/bookworm-security,bookworm 3.0.15-1~deb12u1 arm64 [upgradable from: 3.0.14-1~deb12u2]")
	if p == nil || p.Name != "openssl" || p.NewVersion != "3.0.15-1~deb12u1" || p.CurrentVersion != "3.0.14-1~deb12u2" ||
		!p.Security || p.Source != "bookworm-security" || p.Architecture != "arm64" {
		t.Fatalf("got %+v", p)
	}
	p = parseUpgradableLine("vim/stable 2:9.0 amd64 [upgradable from: 2:8.2]")
	if p == nil || p.Security || p.Source != "stable" {
		t.Fatalf("got %+v", p)
	}
}

func TestParseRdepends(t *testing.T) {
	got := parseRdepends("cowsay\nReverse Depends:\n  cowsay-off\n |presentty\n  cowsay-off\n  ansible\n")
	if len(got) != 3 || got[0] != "cowsay-off" || got[1] != "presentty" || got[2] != "ansible" {
		t.Fatalf("got %v", got)
	}
}

func TestValidators(t *testing.T) {
	hosts := map[string]bool{
		"1.1.1.1": true, "::1": true, "raspberrypi.local": true, "example.com.": true, "my-pi": true,
		"": false, "-c1": false, "1.1.1.1; rm -rf /": false, "a b": false, "$(id)": false, "host`x`": false,
	}
	for h, want := range hosts {
		if validHost(h) != want {
			t.Errorf("validHost(%q) = %v", h, !want)
		}
	}
	pkgs := map[string]bool{
		"nginx": true, "libc6:arm64": true, "g++": true, "python3.11": true, "curl=8.5.0-2": true,
		"-oAPT::Update::Pre-Invoke::=id": false, "Nginx": false, "a b": false, "x;y": false, "": false,
	}
	for p, want := range pkgs {
		if validPackageName(p) != want {
			t.Errorf("validPackageName(%q) = %v", p, !want)
		}
	}
	units := map[string]bool{
		"ssh.service": true, "getty@tty1.service": true, "systemd-networkd": true,
		"--now": false, "a b": false, "x;y": false,
	}
	for u, want := range units {
		if validUnitName(u) != want {
			t.Errorf("validUnitName(%q) = %v", u, !want)
		}
	}
	if validSearchTerm("-oFoo") || !validSearchTerm("web server") {
		t.Error("validSearchTerm")
	}
}

func TestPingParsing(t *testing.T) {
	m := pingReply.FindStringSubmatch("64 bytes from one.one.one.one (1.1.1.1): icmp_seq=3 ttl=58 time=24.0 ms")
	if m == nil || m[2] != "1.1.1.1" || m[3] != "3" || m[4] != "58" || m[5] != "24.0" {
		t.Fatalf("named reply: %q", m)
	}
	m = pingReply.FindStringSubmatch("64 bytes from 1.1.1.1: icmp_seq=1 ttl=58 time=20.1 ms")
	if m == nil || m[1] != "1.1.1.1" || m[2] != "" {
		t.Fatalf("plain reply: %q", m)
	}
	m = pingSummary.FindStringSubmatch("4 packets transmitted, 3 received, 25% packet loss, time 3004ms")
	if m == nil || m[1] != "4" || m[2] != "3" || m[3] != "25" {
		t.Fatalf("summary: %q", m)
	}
	m = pingRtt.FindStringSubmatch("rtt min/avg/max/mdev = 20.101/22.045/23.989/1.944 ms")
	if m == nil || m[1] != "20.101" || m[3] != "23.989" {
		t.Fatalf("rtt: %q", m)
	}
}

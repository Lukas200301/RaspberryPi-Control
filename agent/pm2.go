package main

import (
	"bufio"
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"os"
	"os/exec"
	"os/user"
	"path/filepath"
	"regexp"
	"sort"
	"strconv"
	"strings"
	"sync"
	"time"
)

const pm2SystemPath = "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

var ansiPattern = regexp.MustCompile(`\x1b\[[0-9;?]*[ -/]*[@-~]`)

func stripANSI(s string) string {
	return ansiPattern.ReplaceAllString(s, "")
}

// pm2Runtime describes how PM2 is run for the target user.
//
// PM2 keeps one daemon per user (~/.pm2), and the agent runs as root via
// sudo. So every pm2 command runs as the user that started the agent
// (SUDO_USER), with that user's PATH so nvm/volta installs of node are found.
type pm2Runtime struct {
	user       *user.User
	uid, gid   uint32
	groups     []uint32
	switchUser bool // agent is root and must drop to the PM2 user
	shell      string
	pm2Path    string // empty when PM2 is not installed
	nodePath   string
	npmPath    string
	pm2Home    string
	path       string
}

func resolvePm2User() (*user.User, error) {
	if os.Geteuid() == 0 {
		if name := os.Getenv("SUDO_USER"); name != "" {
			return user.Lookup(name)
		}
	}
	return user.Current()
}

// loginShell returns the login shell of username from /etc/passwd.
func loginShell(username string) string {
	data, err := os.ReadFile("/etc/passwd")
	if err != nil {
		return ""
	}
	for _, line := range strings.Split(string(data), "\n") {
		fields := strings.Split(line, ":")
		if len(fields) >= 7 && fields[0] == username {
			return fields[6]
		}
	}
	return ""
}

func newPm2Runtime(ctx context.Context) (*pm2Runtime, error) {
	u, err := resolvePm2User()
	if err != nil {
		return nil, fmt.Errorf("failed to resolve PM2 user: %v", err)
	}

	rt := &pm2Runtime{user: u, path: pm2SystemPath}

	uid, _ := strconv.ParseUint(u.Uid, 10, 32)
	gid, _ := strconv.ParseUint(u.Gid, 10, 32)
	rt.uid, rt.gid = uint32(uid), uint32(gid)
	rt.switchUser = os.Geteuid() == 0 && rt.uid != 0
	if rt.switchUser {
		if ids, err := u.GroupIds(); err == nil {
			for _, id := range ids {
				if g, err := strconv.ParseUint(id, 10, 32); err == nil {
					rt.groups = append(rt.groups, uint32(g))
				}
			}
		}
	}

	rt.shell = loginShell(u.Username)
	if base := filepath.Base(rt.shell); base != "bash" && base != "zsh" {
		rt.shell = "/bin/bash"
	}

	probe := rt.probeLoginShell(ctx)

	rt.pm2Path = firstExecutable(append([]string{probe["pm2"]}, rt.binCandidates("pm2")...))
	rt.nodePath = firstExecutable(append([]string{siblingOf(rt.pm2Path, "node"), probe["node"]}, rt.binCandidates("node")...))
	rt.npmPath = firstExecutable(append([]string{siblingOf(rt.nodePath, "npm"), probe["npm"]}, rt.binCandidates("npm")...))

	rt.pm2Home = probe["PM2_HOME"]
	if rt.pm2Home == "" {
		rt.pm2Home = filepath.Join(u.HomeDir, ".pm2")
	}

	var dirs []string
	for _, bin := range []string{rt.pm2Path, rt.nodePath, rt.npmPath} {
		if bin != "" {
			dirs = append(dirs, filepath.Dir(bin))
		}
	}
	dirs = append(dirs, strings.Split(probe["PATH"], ":")...)
	dirs = append(dirs, strings.Split(pm2SystemPath, ":")...)
	rt.path = joinUniquePath(dirs)

	return rt, nil
}

// probeLoginShell asks an interactive login shell of the PM2 user where
// pm2, node and npm are, which picks up nvm and other version managers.
func (rt *pm2Runtime) probeLoginShell(ctx context.Context) map[string]string {
	result := map[string]string{}

	ctx, cancel := context.WithTimeout(ctx, 15*time.Second)
	defer cancel()

	script := `for b in pm2 node npm; do echo "__PICONTROL__$b=$(command -v $b 2>/dev/null)"; done; ` +
		`echo "__PICONTROL__PATH=$PATH"; echo "__PICONTROL__PM2_HOME=$PM2_HOME"`

	cmd := rt.command(ctx, false, "", nil, rt.shell, "-lic", script)
	out, _ := cmd.Output()

	for _, line := range strings.Split(string(out), "\n") {
		idx := strings.Index(line, "__PICONTROL__")
		if idx < 0 {
			continue
		}
		kv := strings.SplitN(line[idx+len("__PICONTROL__"):], "=", 2)
		if len(kv) == 2 {
			result[kv[0]] = strings.TrimSpace(kv[1])
		}
	}

	// command -v can return an alias or function name instead of a path
	for _, bin := range []string{"pm2", "node", "npm"} {
		if !strings.HasPrefix(result[bin], "/") {
			delete(result, bin)
		}
	}

	return result
}

// binCandidates lists well-known install locations of a node binary.
func (rt *pm2Runtime) binCandidates(bin string) []string {
	home := rt.user.HomeDir

	var candidates []string

	// nvm, newest node version first
	nvmBins, _ := filepath.Glob(filepath.Join(home, ".nvm", "versions", "node", "*", "bin", bin))
	sort.Slice(nvmBins, func(i, j int) bool {
		return compareNodeVersions(nodeVersionOf(nvmBins[i]), nodeVersionOf(nvmBins[j])) > 0
	})
	candidates = append(candidates, nvmBins...)

	for _, dir := range []string{
		filepath.Join(home, ".volta", "bin"),
		filepath.Join(home, ".npm-global", "bin"),
		filepath.Join(home, ".local", "bin"),
		filepath.Join(home, "n", "bin"),
		filepath.Join(home, ".local", "share", "pnpm"),
		filepath.Join(home, ".bun", "bin"),
		"/usr/local/bin",
		"/usr/bin",
		"/opt/nodejs/bin",
	} {
		candidates = append(candidates, filepath.Join(dir, bin))
	}

	return candidates
}

func nodeVersionOf(binPath string) string {
	// .../versions/node/v20.11.1/bin/pm2
	return filepath.Base(filepath.Dir(filepath.Dir(binPath)))
}

func compareNodeVersions(a, b string) int {
	pa := strings.Split(strings.TrimPrefix(a, "v"), ".")
	pb := strings.Split(strings.TrimPrefix(b, "v"), ".")
	for i := 0; i < 3; i++ {
		var x, y int
		if i < len(pa) {
			x, _ = strconv.Atoi(pa[i])
		}
		if i < len(pb) {
			y, _ = strconv.Atoi(pb[i])
		}
		if x != y {
			if x > y {
				return 1
			}
			return -1
		}
	}
	return 0
}

func siblingOf(binPath, name string) string {
	if binPath == "" {
		return ""
	}
	return filepath.Join(filepath.Dir(binPath), name)
}

func firstExecutable(paths []string) string {
	for _, p := range paths {
		if p == "" {
			continue
		}
		if info, err := os.Stat(p); err == nil && !info.IsDir() && info.Mode()&0111 != 0 {
			return p
		}
	}
	return ""
}

func joinUniquePath(dirs []string) string {
	seen := map[string]bool{}
	var result []string
	for _, d := range dirs {
		d = strings.TrimSpace(d)
		if d == "" || seen[d] {
			continue
		}
		seen[d] = true
		result = append(result, d)
	}
	return strings.Join(result, ":")
}

// environ builds the environment for a command. User commands get a clean
// login-like environment; root commands keep the agent environment.
func (rt *pm2Runtime) environ(asRoot bool, extra map[string]string) []string {
	var env []string

	if asRoot {
		for _, kv := range os.Environ() {
			if !strings.HasPrefix(kv, "PATH=") && !strings.HasPrefix(kv, "PM2_HOME=") {
				env = append(env, kv)
			}
		}
	} else {
		env = []string{
			"HOME=" + rt.user.HomeDir,
			"USER=" + rt.user.Username,
			"LOGNAME=" + rt.user.Username,
			"SHELL=" + rt.shell,
		}
		if lang := os.Getenv("LANG"); lang != "" {
			env = append(env, "LANG="+lang)
		}
		if rt.pm2Home != "" && rt.pm2Home != filepath.Join(rt.user.HomeDir, ".pm2") {
			env = append(env, "PM2_HOME="+rt.pm2Home)
		}
	}

	env = append(env, "PATH="+rt.path, "TERM=dumb", "FORCE_COLOR=0", "NO_COLOR=1")
	for k, v := range extra {
		env = append(env, k+"="+v)
	}
	return env
}

// command builds a command that runs as the PM2 user, or as the agent
// itself when asRoot is set.
func (rt *pm2Runtime) command(ctx context.Context, asRoot bool, dir string, extraEnv map[string]string, name string, args ...string) *exec.Cmd {
	cmd := exec.CommandContext(ctx, name, args...)
	cmd.Env = rt.environ(asRoot, extraEnv)
	cmd.Dir = dir
	if cmd.Dir == "" {
		cmd.Dir = rt.user.HomeDir
	}
	if !asRoot && rt.switchUser {
		runAsUser(cmd, rt.uid, rt.gid, rt.groups)
	}
	return cmd
}

func (rt *pm2Runtime) pm2(ctx context.Context, dir string, extraEnv map[string]string, args ...string) *exec.Cmd {
	return rt.command(ctx, false, dir, extraEnv, rt.pm2Path, args...)
}

// pm2PackageDir returns the pm2 npm package directory (contains package.json).
func (rt *pm2Runtime) pm2PackageDir() string {
	if rt.pm2Path == "" {
		return ""
	}
	real, err := filepath.EvalSymlinks(rt.pm2Path)
	if err != nil {
		return ""
	}
	// .../node_modules/pm2/bin/pm2
	return filepath.Dir(filepath.Dir(real))
}

func (rt *pm2Runtime) pm2Version(ctx context.Context) string {
	if dir := rt.pm2PackageDir(); dir != "" {
		if data, err := os.ReadFile(filepath.Join(dir, "package.json")); err == nil {
			var pkg struct {
				Version string `json:"version"`
			}
			if json.Unmarshal(data, &pkg) == nil && pkg.Version != "" {
				return pkg.Version
			}
		}
	}

	ctx, cancel := context.WithTimeout(ctx, 15*time.Second)
	defer cancel()
	out, _, _, _ := runCommand(rt.pm2(ctx, "", nil, "-v"))
	lines := strings.Split(strings.TrimSpace(out), "\n")
	return strings.TrimSpace(lines[len(lines)-1])
}

// jlist returns the parsed output of `pm2 jlist`.
func (rt *pm2Runtime) jlist(ctx context.Context) ([]map[string]interface{}, error) {
	ctx, cancel := context.WithTimeout(ctx, 60*time.Second)
	defer cancel()

	stdout, stderr, code, err := runCommand(rt.pm2(ctx, "", nil, "jlist"))
	if err != nil {
		return nil, fmt.Errorf("failed to run pm2 jlist: %v", err)
	}

	// PM2 can print notices (e.g. "In-memory PM2 is out-of-date") before the JSON
	lines := strings.Split(stdout, "\n")
	for i := len(lines) - 1; i >= 0; i-- {
		line := strings.TrimSpace(lines[i])
		if !strings.HasPrefix(line, "[") {
			continue
		}
		var list []map[string]interface{}
		if err := json.Unmarshal([]byte(line), &list); err == nil {
			return list, nil
		}
	}

	return nil, fmt.Errorf("pm2 jlist failed (exit %d): %s", code, strings.TrimSpace(stderr+"\n"+stdout))
}

// runCommand runs cmd and returns its stdout, stderr and exit code. err is
// only set when the command could not run at all.
func runCommand(cmd *exec.Cmd) (string, string, int, error) {
	var stdout, stderr bytes.Buffer
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr
	code, err := exitCode(cmd.Run())
	return stripANSI(stdout.String()), stripANSI(stderr.String()), code, err
}

// runCombined runs cmd and returns stdout and stderr interleaved.
func runCombined(cmd *exec.Cmd) (string, int, error) {
	var out bytes.Buffer
	cmd.Stdout = &out
	cmd.Stderr = &out
	code, err := exitCode(cmd.Run())
	return stripANSI(out.String()), code, err
}

// streamPm2Command runs cmd and calls emit for every output line.
func streamPm2Command(cmd *exec.Cmd, emit func(text string, isErr bool)) (int, error) {
	stdout, err := cmd.StdoutPipe()
	if err != nil {
		return -1, err
	}
	stderr, err := cmd.StderrPipe()
	if err != nil {
		return -1, err
	}
	if err := cmd.Start(); err != nil {
		return -1, err
	}

	var mu sync.Mutex
	var wg sync.WaitGroup
	scan := func(r io.Reader, isErr bool) {
		defer wg.Done()
		scanner := bufio.NewScanner(r)
		scanner.Buffer(make([]byte, 64*1024), 1024*1024)
		for scanner.Scan() {
			mu.Lock()
			emit(stripANSI(scanner.Text()), isErr)
			mu.Unlock()
		}
	}
	wg.Add(2)
	go scan(stdout, false)
	go scan(stderr, true)
	wg.Wait()

	return exitCode(cmd.Wait())
}

func exitCode(err error) (int, error) {
	if err == nil {
		return 0, nil
	}
	var exitErr *exec.ExitError
	if errors.As(err, &exitErr) {
		return exitErr.ExitCode(), nil
	}
	return -1, err
}

// ---------- jlist JSON helpers ----------

func jMap(m map[string]interface{}, key string) map[string]interface{} {
	if m == nil {
		return nil
	}
	v, _ := m[key].(map[string]interface{})
	return v
}

func jNum(m map[string]interface{}, key string) float64 {
	if m == nil {
		return 0
	}
	switch v := m[key].(type) {
	case float64:
		return v
	case string:
		f, _ := strconv.ParseFloat(v, 64)
		return f
	case bool:
		if v {
			return 1
		}
	}
	return 0
}

func jStr(m map[string]interface{}, key string) string {
	if m == nil {
		return ""
	}
	return jValueString(m[key])
}

func jValueString(v interface{}) string {
	switch t := v.(type) {
	case nil:
		return ""
	case string:
		return t
	case float64:
		return strconv.FormatFloat(t, 'f', -1, 64)
	case bool:
		return strconv.FormatBool(t)
	default:
		data, _ := json.Marshal(t)
		return string(data)
	}
}

func jBool(m map[string]interface{}, key string, fallback bool) bool {
	if m == nil {
		return fallback
	}
	switch v := m[key].(type) {
	case bool:
		return v
	case string:
		return v == "true"
	case []interface{}:
		return len(v) > 0
	case float64:
		return v != 0
	}
	return fallback
}

// jStrings returns an array value or a space separated string as a list.
func jStrings(v interface{}) []string {
	switch t := v.(type) {
	case []interface{}:
		var result []string
		for _, item := range t {
			result = append(result, jValueString(item))
		}
		return result
	case string:
		return strings.Fields(t)
	}
	return nil
}

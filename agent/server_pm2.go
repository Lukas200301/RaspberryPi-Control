package main

import (
	"context"
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"sort"
	"strconv"
	"strings"
	"sync"
	"time"

	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"

	pb "pi_agent/proto"
)

const pm2LogrotateTemplate = `%HOME_PATH%/pm2.log %HOME_PATH%/logs/*.log {
        rotate 12
        weekly
        missingok
        notifempty
        compress
        delaycompress
        copytruncate
        create 0640 %USER% %USER%
}
`

var (
	pm2ScalePattern  = regexp.MustCompile(`^[+-]?\d+$`)
	pm2SignalPattern = regexp.MustCompile(`^(SIG[A-Z0-9]+|\d+)$`)
	pm2EnvKeyPattern = regexp.MustCompile(`^[A-Za-z_][A-Za-z0-9_]*$`)
)

type pm2ServiceServer struct {
	pb.UnimplementedPm2ServiceServer

	mu     sync.Mutex
	rt     *pm2Runtime
	rtTime time.Time

	listMu   sync.Mutex
	list     []map[string]interface{}
	listTime time.Time
}

func newPm2Service() *pm2ServiceServer {
	return &pm2ServiceServer{}
}

// runtime returns the cached PM2 runtime. It is resolved again when forced,
// after ten minutes, or after 15 seconds while PM2 is not installed.
func (s *pm2ServiceServer) runtime(ctx context.Context, force bool) (*pm2Runtime, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	if !force && s.rt != nil {
		age := time.Since(s.rtTime)
		if (s.rt.pm2Path != "" && age < 10*time.Minute) || age < 15*time.Second {
			return s.rt, nil
		}
	}

	rt, err := newPm2Runtime(ctx)
	if err != nil {
		return nil, err
	}
	s.rt, s.rtTime = rt, time.Now()
	return rt, nil
}

func (s *pm2ServiceServer) installedRuntime(ctx context.Context) (*pm2Runtime, error) {
	rt, err := s.runtime(ctx, false)
	if err != nil {
		return nil, status.Error(codes.Internal, err.Error())
	}
	if rt.pm2Path == "" {
		return nil, status.Errorf(codes.FailedPrecondition, "PM2 is not installed for user %s", rt.user.Username)
	}
	return rt, nil
}

// processes returns the jlist output, shared between callers for a moment
// so a list refresh and an open detail screen spawn pm2 only once.
func (s *pm2ServiceServer) processes(ctx context.Context, rt *pm2Runtime) ([]map[string]interface{}, error) {
	s.listMu.Lock()
	defer s.listMu.Unlock()

	if s.list != nil && time.Since(s.listTime) < 1500*time.Millisecond {
		return s.list, nil
	}

	list, err := rt.jlist(ctx)
	if err != nil {
		return nil, err
	}
	s.list, s.listTime = list, time.Now()
	return list, nil
}

func (s *pm2ServiceServer) invalidateList() {
	s.listMu.Lock()
	s.list = nil
	s.listMu.Unlock()
}

// GetPm2Info returns installation, daemon, startup and dump status
func (s *pm2ServiceServer) GetPm2Info(ctx context.Context, req *pb.Empty) (*pb.Pm2Info, error) {
	rt, err := s.runtime(ctx, true)
	if err != nil {
		return &pb.Pm2Info{Error: err.Error(), AgentIsRoot: os.Geteuid() == 0}, nil
	}

	info := &pb.Pm2Info{
		Installed:      rt.pm2Path != "",
		Pm2Path:        rt.pm2Path,
		User:           rt.user.Username,
		Home:           rt.user.HomeDir,
		Pm2Home:        rt.pm2Home,
		NpmAvailable:   rt.npmPath != "",
		AgentIsRoot:    os.Geteuid() == 0,
		StartupService: "pm2-" + rt.user.Username,
	}

	if rt.nodePath != "" {
		vctx, cancel := context.WithTimeout(ctx, 10*time.Second)
		out, _, _, _ := runCommand(rt.command(vctx, false, "", nil, rt.nodePath, "-v"))
		cancel()
		info.NodeVersion = strings.TrimSpace(out)
	}

	if info.Installed {
		info.Version = rt.pm2Version(ctx)
	}

	if data, err := os.ReadFile(filepath.Join(rt.pm2Home, "pm2.pid")); err == nil {
		pid, _ := strconv.Atoi(strings.TrimSpace(string(data)))
		if processAlive(pid) {
			info.DaemonRunning = true
			info.DaemonPid = int32(pid)
		}
	}

	info.StartupEnabled = pm2StartupEnabled(ctx, info.StartupService)

	if data, err := os.ReadFile(filepath.Join(rt.pm2Home, "dump.pm2")); err == nil {
		info.DumpExists = true
		var dump []interface{}
		if json.Unmarshal(data, &dump) == nil {
			info.DumpProcessCount = int32(len(dump))
		}
	}

	if data, err := os.ReadFile(filepath.Join(rt.pm2Home, "module_conf.json")); err == nil {
		info.ModuleConfigJson = string(data)
	}

	return info, nil
}

func pm2StartupEnabled(ctx context.Context, service string) bool {
	if _, err := os.Stat("/etc/systemd/system/" + service + ".service"); err == nil {
		ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
		defer cancel()
		out, _ := exec.CommandContext(ctx, "systemctl", "is-enabled", service).Output()
		return strings.TrimSpace(string(out)) == "enabled"
	}
	for _, path := range []string{"/etc/init.d/" + service, "/etc/init.d/pm2"} {
		if _, err := os.Stat(path); err == nil {
			return true
		}
	}
	return false
}

// ListPm2Processes returns all processes and modules (pm2 jlist)
func (s *pm2ServiceServer) ListPm2Processes(ctx context.Context, req *pb.Empty) (*pb.Pm2ProcessList, error) {
	rt, err := s.installedRuntime(ctx)
	if err != nil {
		return nil, err
	}

	list, err := s.processes(ctx, rt)
	if err != nil {
		return nil, status.Error(codes.Internal, err.Error())
	}

	result := &pb.Pm2ProcessList{}
	for _, entry := range list {
		result.Processes = append(result.Processes, pm2ProcessFromEntry(entry))
	}
	return result, nil
}

// DescribePm2Process returns one process with its environment and raw data
func (s *pm2ServiceServer) DescribePm2Process(ctx context.Context, req *pb.Pm2Target) (*pb.Pm2ProcessDetails, error) {
	rt, err := s.installedRuntime(ctx)
	if err != nil {
		return nil, err
	}

	list, err := s.processes(ctx, rt)
	if err != nil {
		return nil, status.Error(codes.Internal, err.Error())
	}

	for _, entry := range list {
		if pm2EntryID(entry) != req.Target && jStr(entry, "name") != req.Target {
			continue
		}

		details := &pb.Pm2ProcessDetails{
			Process: pm2ProcessFromEntry(entry),
			Env:     map[string]string{},
		}

		pm2Env := jMap(entry, "pm2_env")
		if env := jMap(pm2Env, "env"); len(env) > 0 {
			for k, v := range env {
				details.Env[k] = jValueString(v)
			}
		} else {
			// Older PM2 versions only expose the flattened pm2_env
			for k, v := range pm2Env {
				switch v.(type) {
				case string, float64, bool:
					details.Env[k] = jValueString(v)
				}
			}
		}

		if raw, err := json.MarshalIndent(entry, "", "  "); err == nil {
			details.RawJson = string(raw)
		}
		return details, nil
	}

	return nil, status.Errorf(codes.NotFound, "PM2 process %s not found", req.Target)
}

// StartPm2Process starts a script/binary, an ecosystem file or `pm2 serve`
func (s *pm2ServiceServer) StartPm2Process(ctx context.Context, req *pb.Pm2StartRequest) (*pb.Pm2CommandResult, error) {
	rt, err := s.installedRuntime(ctx)
	if err != nil {
		return nil, err
	}

	var args []string
	dir := req.Cwd
	extraEnv := map[string]string{}

	switch req.Mode {
	case pb.Pm2StartMode_PM2_START_ECOSYSTEM:
		if err := pm2CheckArg("ecosystem file", req.ConfigFile); err != nil {
			return pm2Failure(err), nil
		}
		args = []string{"start", req.ConfigFile}
		if req.EnvName != "" {
			args = append(args, "--env", req.EnvName)
		}
		if req.Only != "" {
			args = append(args, "--only", req.Only)
		}
		if req.UpdateEnv {
			args = append(args, "--update-env")
		}
		if dir == "" && filepath.IsAbs(req.ConfigFile) {
			dir = filepath.Dir(req.ConfigFile)
		}

	case pb.Pm2StartMode_PM2_START_SERVE:
		path := req.ServePath
		if path == "" {
			path = "."
		}
		port := req.ServePort
		if port <= 0 {
			port = 8080
		}
		args = []string{"serve", path, strconv.Itoa(int(port))}
		if req.Name != "" {
			args = append(args, "--name", req.Name)
		}
		if req.Spa {
			args = append(args, "--spa")
		}
		if req.BasicAuthUsername != "" {
			args = append(args, "--basic-auth-username", req.BasicAuthUsername,
				"--basic-auth-password", req.BasicAuthPassword)
		}
		if req.Watch {
			args = append(args, "--watch")
		}

	default:
		if err := pm2CheckArg("script", req.Script); err != nil {
			return pm2Failure(err), nil
		}
		args = append([]string{"start", req.Script}, pm2StartFlags(req)...)
		for k, v := range req.Env {
			if !pm2EnvKeyPattern.MatchString(k) {
				return pm2Failure(fmt.Errorf("invalid environment variable name: %q", k)), nil
			}
			extraEnv[k] = v
		}
		if len(req.Args) > 0 {
			args = append(args, "--")
			args = append(args, req.Args...)
		}
	}

	if dir != "" {
		if info, err := os.Stat(dir); err != nil || !info.IsDir() {
			return pm2Failure(fmt.Errorf("working directory %s does not exist", dir)), nil
		}
	}

	defer s.invalidateList()
	return s.runPm2(ctx, rt, dir, extraEnv, args), nil
}

// pm2StartFlags translates the start options into pm2 CLI flags
func pm2StartFlags(req *pb.Pm2StartRequest) []string {
	var f []string
	add := func(flag, value string) {
		if value != "" {
			f = append(f, flag, value)
		}
	}
	addInt := func(flag string, value int32) {
		if value > 0 {
			f = append(f, flag, strconv.Itoa(int(value)))
		}
	}
	addBool := func(flag string, value bool) {
		if value {
			f = append(f, flag)
		}
	}

	add("--name", req.Name)
	add("--namespace", req.Namespace)
	add("--interpreter", req.Interpreter)
	add("--interpreter-args", req.InterpreterArgs)
	add("--instances", req.Instances)

	addBool("--watch", req.Watch)
	add("--ignore-watch", req.IgnoreWatch)
	add("--watch-delay", req.WatchDelay)

	add("--max-memory-restart", req.MaxMemoryRestart)
	add("--cron-restart", req.CronRestart)
	addBool("--no-autorestart", req.NoAutorestart)
	addInt("--restart-delay", req.RestartDelay)
	addInt("--exp-backoff-restart-delay", req.ExpBackoffRestartDelay)
	addInt("--max-restarts", req.MaxRestarts)

	addBool("--time", req.Time)
	add("--log-date-format", req.LogDateFormat)
	addBool("--merge-logs", req.MergeLogs)
	add("--output", req.OutputLog)
	add("--error", req.ErrorLog)
	add("--log", req.CombinedLog)
	addBool("--disable-logs", req.DisableLogs)

	addInt("--kill-timeout", req.KillTimeout)
	addInt("--listen-timeout", req.ListenTimeout)
	addBool("--wait-ready", req.WaitReady)
	addBool("--shutdown-with-message", req.ShutdownWithMessage)
	addBool("--no-treekill", req.NoTreekill)
	addBool("--no-autostart", req.NoAutostart)
	addBool("--no-vizion", req.NoVizion)
	addBool("--force", req.Force)

	// Variadic, so it goes last (right before "--")
	if exitCodes := strings.Fields(req.StopExitCodes); len(exitCodes) > 0 {
		f = append(f, "--stop-exit-codes")
		f = append(f, exitCodes...)
	}

	return f
}

// ControlPm2Process acts on existing processes
func (s *pm2ServiceServer) ControlPm2Process(ctx context.Context, req *pb.Pm2ControlRequest) (*pb.Pm2CommandResult, error) {
	rt, err := s.installedRuntime(ctx)
	if err != nil {
		return nil, err
	}

	if err := pm2CheckArg("target", req.Target); err != nil {
		return pm2Failure(err), nil
	}
	target := req.Target

	// Lifecycle actions also accept ecosystem files
	lifecycle := func(command string) []string {
		args := []string{command, target}
		if req.UpdateEnv {
			args = append(args, "--update-env")
		}
		if req.EnvName != "" {
			args = append(args, "--env", req.EnvName)
		}
		if req.Only != "" {
			args = append(args, "--only", req.Only)
		}
		return args
	}

	var args []string
	switch req.Action {
	case pb.Pm2Action_PM2_ACTION_START:
		args = lifecycle("start")
	case pb.Pm2Action_PM2_ACTION_RESTART:
		args = lifecycle("restart")
	case pb.Pm2Action_PM2_ACTION_RELOAD:
		args = lifecycle("reload")
	case pb.Pm2Action_PM2_ACTION_STOP:
		args = lifecycle("stop")
	case pb.Pm2Action_PM2_ACTION_DELETE:
		args = lifecycle("delete")
	case pb.Pm2Action_PM2_ACTION_RESET:
		args = []string{"reset", target}
	case pb.Pm2Action_PM2_ACTION_SCALE:
		if !pm2ScalePattern.MatchString(req.Value) {
			return pm2Failure(fmt.Errorf("invalid instance count %q (use e.g. 4, +2 or -1)", req.Value)), nil
		}
		args = []string{"scale", target, req.Value}
	case pb.Pm2Action_PM2_ACTION_SEND_SIGNAL:
		if !pm2SignalPattern.MatchString(req.Value) {
			return pm2Failure(fmt.Errorf("invalid signal %q", req.Value)), nil
		}
		args = []string{"sendSignal", req.Value, target}
	case pb.Pm2Action_PM2_ACTION_TRIGGER:
		if err := pm2CheckArg("action name", req.ActionName); err != nil {
			return pm2Failure(err), nil
		}
		args = []string{"trigger", target, req.ActionName}
		if req.ActionParam != "" {
			args = append(args, req.ActionParam)
		}
	case pb.Pm2Action_PM2_ACTION_FLUSH:
		args = []string{"flush", target}
	case pb.Pm2Action_PM2_ACTION_SEND_STDIN:
		args = []string{"send", target, req.Value}
	case pb.Pm2Action_PM2_ACTION_TOGGLE_WATCH:
		args = []string{"restart", target, "--watch"}
	case pb.Pm2Action_PM2_ACTION_PULL:
		args = []string{"pull", target}
		if req.Value != "" {
			args = append(args, req.Value)
		}
	case pb.Pm2Action_PM2_ACTION_FORWARD:
		args = []string{"forward", target}
	case pb.Pm2Action_PM2_ACTION_BACKWARD:
		args = []string{"backward", target}
	default:
		return pm2Failure(fmt.Errorf("unknown PM2 action %v", req.Action)), nil
	}

	dir := ""
	if filepath.IsAbs(target) {
		dir = filepath.Dir(target)
	}

	defer s.invalidateList()
	return s.runPm2(ctx, rt, dir, nil, args), nil
}

func (s *pm2ServiceServer) runPm2(ctx context.Context, rt *pm2Runtime, dir string, extraEnv map[string]string, args []string) *pb.Pm2CommandResult {
	ctx, cancel := context.WithTimeout(ctx, 2*time.Minute)
	defer cancel()

	output, code, err := runCombined(rt.pm2(ctx, dir, extraEnv, args...))
	result := &pb.Pm2CommandResult{
		Command:  pm2CommandLine("pm2", args),
		Output:   strings.TrimSpace(output),
		ExitCode: int32(code),
	}
	if err != nil {
		result.Output = strings.TrimSpace(result.Output + "\n" + err.Error())
	}
	result.Success = err == nil && code == 0 && !strings.Contains(output, "[PM2][ERROR]")
	return result
}

// StreamPm2Logs sends the last lines of the selected log files and then
// follows them
func (s *pm2ServiceServer) StreamPm2Logs(req *pb.Pm2LogRequest, stream pb.Pm2Service_StreamPm2LogsServer) error {
	ctx, cancel := context.WithCancel(stream.Context())
	defer cancel()

	rt, err := s.installedRuntime(ctx)
	if err != nil {
		return err
	}

	sources := map[string]pm2LogSource{}
	var files []string
	addFile := func(path string, src pm2LogSource) {
		if path == "" || path == "/dev/null" {
			return
		}
		if _, seen := sources[path]; seen {
			return
		}
		if _, err := os.Stat(path); err != nil && !req.Follow {
			return
		}
		sources[path] = src
		files = append(files, path)
	}

	if req.IncludeOut || req.IncludeErr {
		list, err := s.processes(ctx, rt)
		if err != nil {
			return status.Error(codes.Internal, err.Error())
		}
		for _, entry := range list {
			if !pm2TargetMatches(entry, req.Target) {
				continue
			}
			env := jMap(entry, "pm2_env")
			name := jStr(entry, "name")
			id := int32(jNum(entry, "pm_id"))
			if req.IncludeOut {
				addFile(jStr(env, "pm_out_log_path"), pm2LogSource{name, id, "out"})
			}
			if req.IncludeErr {
				addFile(jStr(env, "pm_err_log_path"), pm2LogSource{name, id, "err"})
			}
		}
	}
	if req.IncludeDaemon {
		addFile(filepath.Join(rt.pm2Home, "pm2.log"), pm2LogSource{"PM2", -1, "pm2"})
	}

	if len(files) == 0 {
		return status.Error(codes.NotFound, "no PM2 log files found")
	}

	lines := int(req.Lines)
	if lines <= 0 {
		lines = 100
	}
	if lines > 10000 {
		lines = 10000
	}

	// History is read up to a fixed offset per file and following starts at
	// exactly that offset, so no line is lost or sent twice
	var history []pm2LogEntry
	offsets := map[string]int64{}
	allTimed := true
	for _, path := range files {
		entries, offset, timed := readPm2LogHistory(path, lines, sources[path])
		offsets[path] = offset
		allTimed = allTimed && timed
		history = append(history, entries...)
	}
	if allTimed {
		sort.SliceStable(history, func(i, j int) bool {
			return history[i].sortKey < history[j].sortKey
		})
	}
	for _, e := range history {
		if err := stream.Send(e.toProto(true)); err != nil {
			return nil
		}
	}

	if !req.Follow {
		return nil
	}

	events := make(chan pm2LogEntry, 256)
	var wg sync.WaitGroup
	for _, path := range files {
		wg.Add(1)
		go func(path string) {
			defer wg.Done()
			followPm2LogFile(ctx, path, offsets[path], sources[path], events)
		}(path)
	}
	go func() {
		wg.Wait()
		close(events)
	}()

	for e := range events {
		if err := stream.Send(e.toProto(false)); err != nil {
			cancel()
			for range events {
			}
			return nil
		}
	}
	return nil
}

// RunPm2Operation runs daemon, persistence, module, config, deploy and
// diagnostic commands and streams their output
func (s *pm2ServiceServer) RunPm2Operation(req *pb.Pm2OperationRequest, stream pb.Pm2Service_RunPm2OperationServer) error {
	ctx := stream.Context()
	defer s.invalidateList()

	var sendMu sync.Mutex
	emit := func(text string, isErr bool) {
		sendMu.Lock()
		defer sendMu.Unlock()
		stream.Send(&pb.Pm2OutputLine{Text: text, IsError: isErr})
	}
	finish := func(success bool, code int) error {
		sendMu.Lock()
		defer sendMu.Unlock()
		return stream.Send(&pb.Pm2OutputLine{Done: true, Success: success, ExitCode: int32(code)})
	}
	fail := func(format string, a ...interface{}) error {
		emit(fmt.Sprintf(format, a...), true)
		return finish(false, 1)
	}

	rt, err := s.runtime(ctx, false)
	if err != nil {
		return fail("%v", err)
	}

	// Installing PM2 itself works without PM2
	if req.Operation == pb.Pm2Operation_PM2_OP_INSTALL_PM2 {
		return s.installPm2(ctx, rt, emit, finish, fail)
	}

	if rt.pm2Path == "" {
		return fail("PM2 is not installed for user %s", rt.user.Username)
	}

	isRoot := os.Geteuid() == 0
	userArgs := []string{"-u", rt.user.Username, "--hp", rt.user.HomeDir}

	type step struct {
		asRoot bool
		dir    string
		args   []string
	}
	var steps []step
	pm2Step := func(args ...string) {
		steps = append(steps, step{args: args})
	}

	switch req.Operation {
	case pb.Pm2Operation_PM2_OP_SAVE:
		if req.Force {
			pm2Step("save", "--force")
		} else {
			pm2Step("save")
		}
	case pb.Pm2Operation_PM2_OP_RESURRECT:
		pm2Step("resurrect")
	case pb.Pm2Operation_PM2_OP_CLEAR_DUMP:
		pm2Step("cleardump")
	case pb.Pm2Operation_PM2_OP_UPDATE:
		pm2Step("update")
	case pb.Pm2Operation_PM2_OP_KILL:
		pm2Step("kill")
	case pb.Pm2Operation_PM2_OP_PING:
		pm2Step("ping")
	case pb.Pm2Operation_PM2_OP_FLUSH_ALL:
		pm2Step("flush")
	case pb.Pm2Operation_PM2_OP_RELOAD_LOGS:
		pm2Step("reloadLogs")

	case pb.Pm2Operation_PM2_OP_STARTUP:
		if !isRoot {
			emit("The agent is not running as root, so PM2 can only print the command to run with sudo:", true)
			pm2Step("startup")
			break
		}
		// startup/unstartup do not connect to a daemon, so running them as
		// root does not spawn a root PM2
		steps = append(steps, step{asRoot: true, args: append([]string{"startup"}, userArgs...)})
		pm2Step("save")
	case pb.Pm2Operation_PM2_OP_UNSTARTUP:
		if !isRoot {
			emit("The agent is not running as root, so PM2 can only print the command to run with sudo:", true)
			pm2Step("unstartup")
			break
		}
		steps = append(steps, step{asRoot: true, args: append([]string{"unstartup"}, userArgs...)})

	case pb.Pm2Operation_PM2_OP_INSTALL_MODULE:
		if err := pm2CheckArg("module", req.Name); err != nil {
			return fail("%v", err)
		}
		pm2Step("install", req.Name)
	case pb.Pm2Operation_PM2_OP_UPDATE_MODULE:
		if err := pm2CheckArg("module", req.Name); err != nil {
			return fail("%v", err)
		}
		pm2Step("module:update", req.Name)
	case pb.Pm2Operation_PM2_OP_UNINSTALL_MODULE:
		if err := pm2CheckArg("module", req.Name); err != nil {
			return fail("%v", err)
		}
		pm2Step("uninstall", req.Name)

	case pb.Pm2Operation_PM2_OP_SET_CONFIG:
		if err := pm2CheckArg("config key", req.Name); err != nil {
			return fail("%v", err)
		}
		pm2Step("set", req.Name, req.Value)
	case pb.Pm2Operation_PM2_OP_UNSET_CONFIG:
		if err := pm2CheckArg("config key", req.Name); err != nil {
			return fail("%v", err)
		}
		pm2Step("unset", req.Name)

	case pb.Pm2Operation_PM2_OP_DEPLOY:
		if err := pm2CheckArg("ecosystem file", req.ConfigFile); err != nil {
			return fail("%v", err)
		}
		if err := pm2CheckArg("deploy environment", req.DeployEnv); err != nil {
			return fail("%v", err)
		}
		args := []string{"deploy", req.ConfigFile, req.DeployEnv}
		switch req.DeployCommand {
		case "", "update", "setup", "curr", "current", "prev", "previous", "list":
			if req.DeployCommand != "" {
				args = append(args, req.DeployCommand)
			}
		case "revert":
			args = append(args, "revert")
			if req.DeployArgs != "" {
				args = append(args, req.DeployArgs)
			}
		case "exec":
			if req.DeployArgs == "" {
				return fail("deploy exec needs a command")
			}
			args = append(args, "exec", req.DeployArgs)
		case "ref":
			if err := pm2CheckArg("ref", req.DeployArgs); err != nil {
				return fail("%v", err)
			}
			args = append(args, req.DeployArgs)
		default:
			return fail("unknown deploy command %q", req.DeployCommand)
		}
		if req.Force {
			args = append(args, "--force")
		}
		dir := ""
		if filepath.IsAbs(req.ConfigFile) {
			dir = filepath.Dir(req.ConfigFile)
		}
		steps = append(steps, step{dir: dir, args: args})

	case pb.Pm2Operation_PM2_OP_REPORT:
		pm2Step("report")

	case pb.Pm2Operation_PM2_OP_INIT_ECOSYSTEM:
		dir := req.Cwd
		if dir == "" {
			dir = rt.user.HomeDir
		}
		file := filepath.Join(dir, "ecosystem.config.js")
		if _, err := os.Stat(file); err == nil && !req.Force {
			return fail("%s already exists", file)
		}
		args := []string{"init"}
		if req.Mode != "full" {
			args = append(args, "simple")
		}
		steps = append(steps, step{dir: dir, args: args})

	case pb.Pm2Operation_PM2_OP_PROFILE_CPU, pb.Pm2Operation_PM2_OP_PROFILE_MEM:
		command := "profile:cpu"
		if req.Operation == pb.Pm2Operation_PM2_OP_PROFILE_MEM {
			command = "profile:mem"
		}
		args := []string{command}
		if req.Value != "" {
			if _, err := strconv.Atoi(req.Value); err != nil {
				return fail("invalid profiling duration %q", req.Value)
			}
			args = append(args, req.Value)
		}
		steps = append(steps, step{dir: rt.user.HomeDir, args: args})

	case pb.Pm2Operation_PM2_OP_LOGROTATE:
		return s.writeLogrotateConfig(rt, emit, finish, fail)

	default:
		return fail("unknown PM2 operation %v", req.Operation)
	}

	code := 0
	for _, st := range steps {
		prefix := "$ "
		if st.asRoot {
			prefix = "# "
		}
		emit(prefix+pm2CommandLine("pm2", st.args), false)

		cmd := rt.command(ctx, st.asRoot, st.dir, nil, rt.pm2Path, st.args...)
		code, err = streamPm2Command(cmd, emit)
		if err != nil {
			return fail("%v", err)
		}
		if code != 0 {
			return finish(false, code)
		}
	}

	return finish(true, code)
}

// installPm2 runs `npm install -g pm2@latest` and updates a running daemon
func (s *pm2ServiceServer) installPm2(ctx context.Context, rt *pm2Runtime, emit func(string, bool),
	finish func(bool, int) error, fail func(string, ...interface{}) error) error {

	if rt.npmPath == "" {
		return fail("npm was not found for user %s. Install Node.js first (e.g. with nvm or apt install nodejs npm).", rt.user.Username)
	}

	wasInstalled := rt.pm2Path != ""

	// Install as the user when npm installs globals into their home (nvm,
	// volta, ~/.npm-global), otherwise the global prefix needs root
	asRoot := false
	pctx, cancel := context.WithTimeout(ctx, 30*time.Second)
	prefix, _, _, _ := runCommand(rt.command(pctx, false, "", nil, rt.npmPath, "prefix", "-g"))
	cancel()
	prefix = strings.TrimSpace(prefix)
	if os.Geteuid() == 0 && !strings.HasPrefix(prefix, rt.user.HomeDir+"/") {
		asRoot = true
	}

	args := []string{"install", "-g", "pm2@latest"}
	marker := "$ "
	if asRoot {
		marker = "# "
	}
	emit(marker+pm2CommandLine("npm", args), false)

	code, err := streamPm2Command(rt.command(ctx, asRoot, "", nil, rt.npmPath, args...), emit)
	if err != nil {
		return fail("%v", err)
	}
	if code != 0 {
		return finish(false, code)
	}

	newRt, err := s.runtime(ctx, true)
	if err != nil {
		return fail("%v", err)
	}
	if newRt.pm2Path == "" {
		return fail("npm finished, but pm2 was not found afterwards")
	}

	if wasInstalled {
		emit("$ pm2 update", false)
		code, err = streamPm2Command(newRt.pm2(ctx, "", nil, "update"), emit)
		if err != nil {
			return fail("%v", err)
		}
	}

	return finish(code == 0, code)
}

// writeLogrotateConfig is `pm2 logrotate -u <user>` done by the agent:
// pm2 would take the log path from the HOME of root instead of the user.
func (s *pm2ServiceServer) writeLogrotateConfig(rt *pm2Runtime, emit func(string, bool),
	finish func(bool, int) error, fail func(string, ...interface{}) error) error {

	if os.Geteuid() != 0 {
		return fail("Writing /etc/logrotate.d needs root, but the agent is not running as root")
	}
	if _, err := os.Stat("/etc/logrotate.d"); err != nil {
		return fail("/etc/logrotate.d does not exist, is logrotate installed?")
	}

	template := pm2LogrotateTemplate
	if dir := rt.pm2PackageDir(); dir != "" {
		if data, err := os.ReadFile(filepath.Join(dir, "lib", "templates", "logrotate.d", "pm2")); err == nil {
			template = string(data)
		}
	}

	config := strings.ReplaceAll(template, "%HOME_PATH%", rt.pm2Home)
	config = strings.ReplaceAll(config, "%USER%", rt.user.Username)

	dest := "/etc/logrotate.d/pm2-" + rt.user.Username
	if err := os.WriteFile(dest, []byte(config), 0644); err != nil {
		return fail("Failed to write %s: %v", dest, err)
	}

	emit("Logrotate configuration written to "+dest+":", false)
	for _, line := range strings.Split(strings.TrimRight(config, "\n"), "\n") {
		emit(line, false)
	}
	return finish(true, 0)
}

// ---------- helpers ----------

func pm2Failure(err error) *pb.Pm2CommandResult {
	return &pb.Pm2CommandResult{Success: false, Output: err.Error(), ExitCode: 1}
}

// pm2CheckArg rejects empty values and values pm2 would parse as a flag
func pm2CheckArg(what, value string) error {
	if strings.TrimSpace(value) == "" {
		return fmt.Errorf("%s is required", what)
	}
	if strings.HasPrefix(value, "-") {
		return fmt.Errorf("%s must not start with '-'", what)
	}
	return nil
}

func pm2CommandLine(bin string, args []string) string {
	parts := []string{bin}
	hide := false
	for _, a := range args {
		if hide {
			a = "******"
			hide = false
		} else if a == "--basic-auth-password" {
			hide = true
		}
		if a == "" || strings.ContainsAny(a, " \t\"'$") {
			a = strconv.Quote(a)
		}
		parts = append(parts, a)
	}
	return strings.Join(parts, " ")
}

func pm2EntryID(entry map[string]interface{}) string {
	return strconv.Itoa(int(jNum(entry, "pm_id")))
}

func pm2TargetMatches(entry map[string]interface{}, target string) bool {
	if target == "" || target == "all" {
		return true
	}
	return pm2EntryID(entry) == target ||
		jStr(entry, "name") == target ||
		jStr(jMap(entry, "pm2_env"), "namespace") == target
}

func pm2ProcessFromEntry(entry map[string]interface{}) *pb.Pm2Process {
	env := jMap(entry, "pm2_env")
	monit := jMap(entry, "monit")

	p := &pb.Pm2Process{
		PmId:             int32(jNum(entry, "pm_id")),
		Name:             jStr(entry, "name"),
		Namespace:        jStr(env, "namespace"),
		Pid:              int32(jNum(entry, "pid")),
		Status:           jStr(env, "status"),
		Cpu:              jNum(monit, "cpu"),
		Memory:           uint64(jNum(monit, "memory")),
		StartedAt:        int64(jNum(env, "pm_uptime")),
		CreatedAt:        int64(jNum(env, "created_at")),
		Restarts:         int32(jNum(env, "restart_time")),
		UnstableRestarts: int32(jNum(env, "unstable_restarts")),
		ExecMode:         strings.TrimSuffix(jStr(env, "exec_mode"), "_mode"),
		Instances:        int32(jNum(env, "instances")),
		Watch:            jBool(env, "watch", false),
		Autorestart:      jBool(env, "autorestart", true),
		Version:          jStr(env, "version"),
		Script:           jStr(env, "pm_exec_path"),
		Cwd:              jStr(env, "pm_cwd"),
		Interpreter:      jStr(env, "exec_interpreter"),
		InterpreterArgs:  strings.Join(jStrings(env["node_args"]), " "),
		NodeVersion:      jStr(env, "node_version"),
		IsModule:         jBool(env, "pmx_module", false),
		User:             jStr(env, "username"),
		OutLog:           jStr(env, "pm_out_log_path"),
		ErrLog:           jStr(env, "pm_err_log_path"),
		MaxMemoryRestart: int64(jNum(env, "max_memory_restart")),
		CronRestart:      jStr(env, "cron_restart"),
		Args:             jStrings(env["args"]),
		ExitCode:         int32(jNum(env, "exit_code")),
	}

	if actions, ok := env["axm_actions"].([]interface{}); ok {
		for _, a := range actions {
			if m, ok := a.(map[string]interface{}); ok {
				if name := jStr(m, "action_name"); name != "" {
					p.CustomActions = append(p.CustomActions, name)
				}
			}
		}
	}

	if monitor := jMap(env, "axm_monitor"); monitor != nil {
		names := make([]string, 0, len(monitor))
		for name := range monitor {
			names = append(names, name)
		}
		sort.Strings(names)
		for _, name := range names {
			metric := &pb.Pm2Metric{Name: name}
			if m, ok := monitor[name].(map[string]interface{}); ok {
				metric.Value = jStr(m, "value")
				metric.Unit = jStr(m, "unit")
			} else {
				metric.Value = jValueString(monitor[name])
			}
			p.Metrics = append(p.Metrics, metric)
		}
	}

	if v := jMap(env, "versioning"); v != nil {
		p.Versioning = &pb.Pm2Versioning{
			Present:  true,
			Type:     jStr(v, "type"),
			Url:      jStr(v, "url"),
			Branch:   jStr(v, "branch"),
			Revision: jStr(v, "revision"),
			Comment:  strings.TrimSpace(jStr(v, "comment")),
			Unstaged: jBool(v, "unstaged", false),
			RepoPath: jStr(v, "repo_path"),
		}
		if t, err := time.Parse(time.RFC3339, jStr(v, "update_time")); err == nil {
			p.Versioning.UpdateTime = t.UnixMilli()
		}
	}

	return p
}

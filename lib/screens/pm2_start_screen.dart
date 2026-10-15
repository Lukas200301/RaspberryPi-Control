import 'package:flutter/material.dart';
import '../ui/ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../generated/pi_control.pb.dart';
import '../services/pm2_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/pm2_widgets.dart';

/// Starts a script/binary (`pm2 start`), an ecosystem file or a static file
/// server (`pm2 serve`) with every option PM2 offers.
class Pm2StartScreen extends ConsumerStatefulWidget {
  final Pm2Info info;

  const Pm2StartScreen({super.key, required this.info});

  @override
  ConsumerState<Pm2StartScreen> createState() => _Pm2StartScreenState();
}

class _EnvRow {
  final TextEditingController key = TextEditingController();
  final TextEditingController value = TextEditingController();

  void dispose() {
    key.dispose();
    value.dispose();
  }
}

class _Pm2StartScreenState extends ConsumerState<Pm2StartScreen> {
  Pm2StartMode _mode = Pm2StartMode.PM2_START_SCRIPT;
  bool _starting = false;

  // General
  final _script = TextEditingController();
  final _name = TextEditingController();
  late final _cwd = TextEditingController(text: widget.info.home);
  final _args = TextEditingController();
  final _interpreter = TextEditingController();
  final _interpreterArgs = TextEditingController();
  final _namespace = TextEditingController();
  final List<_EnvRow> _env = [];

  // Scaling
  final _instances = TextEditingController();

  // Restart strategy
  bool _autorestart = true;
  final _maxMemory = TextEditingController();
  final _cron = TextEditingController();
  final _restartDelay = TextEditingController();
  final _expBackoff = TextEditingController();
  final _maxRestarts = TextEditingController();
  final _stopExitCodes = TextEditingController();

  // Watch
  bool _watch = false;
  final _ignoreWatch = TextEditingController(text: 'node_modules');
  final _watchDelay = TextEditingController();

  // Logs
  bool _time = false;
  bool _mergeLogs = false;
  bool _disableLogs = false;
  final _logDateFormat = TextEditingController();
  final _outLog = TextEditingController();
  final _errLog = TextEditingController();
  final _combinedLog = TextEditingController();

  // Control flow
  final _killTimeout = TextEditingController();
  final _listenTimeout = TextEditingController();
  bool _waitReady = false;
  bool _shutdownWithMessage = false;
  bool _noTreekill = false;
  bool _noAutostart = false;
  bool _noVizion = false;
  bool _force = false;

  // Ecosystem
  late final _configFile = TextEditingController(
    text: '${widget.info.home}/ecosystem.config.js',
  );
  final _envName = TextEditingController();
  final _only = TextEditingController();
  bool _updateEnv = false;

  // Serve
  late final _servePath = TextEditingController(text: widget.info.home);
  final _servePort = TextEditingController(text: '8080');
  bool _spa = false;
  final _authUser = TextEditingController();
  final _authPassword = TextEditingController();

  late final List<TextEditingController> _controllers = [
    _script,
    _name,
    _cwd,
    _args,
    _interpreter,
    _interpreterArgs,
    _namespace,
    _instances,
    _maxMemory,
    _cron,
    _restartDelay,
    _expBackoff,
    _maxRestarts,
    _stopExitCodes,
    _ignoreWatch,
    _watchDelay,
    _logDateFormat,
    _outLog,
    _errLog,
    _combinedLog,
    _killTimeout,
    _listenTimeout,
    _configFile,
    _envName,
    _only,
    _servePath,
    _servePort,
    _authUser,
    _authPassword,
  ];

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final row in _env) {
      row.dispose();
    }
    super.dispose();
  }

  int _int(TextEditingController c) => int.tryParse(c.text.trim()) ?? 0;

  String? _validate() {
    switch (_mode) {
      case Pm2StartMode.PM2_START_ECOSYSTEM:
        if (_configFile.text.trim().isEmpty) {
          return 'Enter the path of the ecosystem file';
        }
      case Pm2StartMode.PM2_START_SERVE:
        if (_servePath.text.trim().isEmpty) return 'Enter the folder to serve';
        final port = int.tryParse(_servePort.text.trim());
        if (port == null || port <= 0 || port > 65535) {
          return 'Enter a valid port';
        }
      default:
        if (_script.text.trim().isEmpty) {
          return 'Enter a script, binary or command';
        }
        for (final row in _env) {
          final key = row.key.text.trim();
          if (key.isNotEmpty &&
              !RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$').hasMatch(key)) {
            return 'Invalid environment variable name: $key';
          }
        }
    }
    return null;
  }

  Pm2StartRequest _buildRequest() {
    final r = Pm2StartRequest()..mode = _mode;
    switch (_mode) {
      case Pm2StartMode.PM2_START_ECOSYSTEM:
        r
          ..configFile = _configFile.text.trim()
          ..envName = _envName.text.trim()
          ..only = _only.text.trim()
          ..updateEnv = _updateEnv;
      case Pm2StartMode.PM2_START_SERVE:
        r
          ..servePath = _servePath.text.trim()
          ..servePort = int.parse(_servePort.text.trim())
          ..name = _name.text.trim()
          ..spa = _spa
          ..basicAuthUsername = _authUser.text.trim()
          ..basicAuthPassword = _authPassword.text
          ..watch = _watch;
      default:
        r
          ..script = _script.text.trim()
          ..name = _name.text.trim()
          ..cwd = _cwd.text.trim()
          ..interpreter = _interpreter.text.trim()
          ..interpreterArgs = _interpreterArgs.text.trim()
          ..namespace = _namespace.text.trim()
          ..instances = _instances.text.trim()
          ..watch = _watch
          ..ignoreWatch = _watch ? _ignoreWatch.text.trim() : ''
          ..watchDelay = _watch ? _watchDelay.text.trim() : ''
          ..maxMemoryRestart = _maxMemory.text.trim()
          ..cronRestart = _cron.text.trim()
          ..noAutorestart = !_autorestart
          ..restartDelay = _int(_restartDelay)
          ..expBackoffRestartDelay = _int(_expBackoff)
          ..maxRestarts = _int(_maxRestarts)
          ..stopExitCodes = _stopExitCodes.text.trim()
          ..time = _time
          ..logDateFormat = _logDateFormat.text.trim()
          ..mergeLogs = _mergeLogs
          ..outputLog = _outLog.text.trim()
          ..errorLog = _errLog.text.trim()
          ..combinedLog = _combinedLog.text.trim()
          ..disableLogs = _disableLogs
          ..killTimeout = _int(_killTimeout)
          ..listenTimeout = _int(_listenTimeout)
          ..waitReady = _waitReady
          ..shutdownWithMessage = _shutdownWithMessage
          ..noTreekill = _noTreekill
          ..noAutostart = _noAutostart
          ..noVizion = _noVizion
          ..force = _force;
        r.args.addAll(splitShellArgs(_args.text));
        for (final row in _env) {
          final key = row.key.text.trim();
          if (key.isNotEmpty) r.env[key] = row.value.text;
        }
    }
    return r;
  }

  Future<void> _start() async {
    final problem = _validate();
    if (problem != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(problem),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() => _starting = true);
    try {
      final result = await ref.read(pm2ServiceProvider).start(_buildRequest());
      if (!mounted) return;
      if (result.success) {
        ref.read(pm2ProcessesProvider.notifier).refresh();
        final messenger = ScaffoldMessenger.of(context);
        Navigator.pop(context);
        messenger.showSnackBar(
          SnackBar(content: Text(pm2Summary(result.output))),
        );
      } else {
        await showPm2OutputDialog(
          context,
          title: 'Start failed',
          command: result.command,
          output: result.output,
          isError: true,
        );
      }
    } catch (e) {
      if (mounted) showPm2Error(context, e);
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start with PM2'),
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          SegmentedButton<Pm2StartMode>(
            segments: const [
              ButtonSegment(
                value: Pm2StartMode.PM2_START_SCRIPT,
                icon: Icon(Icons.code),
                label: Text('Script'),
              ),
              ButtonSegment(
                value: Pm2StartMode.PM2_START_ECOSYSTEM,
                icon: Icon(Icons.description_outlined),
                label: Text('Ecosystem'),
              ),
              ButtonSegment(
                value: Pm2StartMode.PM2_START_SERVE,
                icon: Icon(Icons.public),
                label: Text('Serve'),
              ),
            ],
            selected: {_mode},
            onSelectionChanged: (s) => setState(() => _mode = s.first),
          ),
          const Gap(16),
          ...switch (_mode) {
            Pm2StartMode.PM2_START_ECOSYSTEM => _ecosystemFields(),
            Pm2StartMode.PM2_START_SERVE => _serveFields(),
            _ => _scriptFields(),
          },
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _starting ? null : _start,
        icon: _starting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.play_arrow),
        label: Text(_starting ? 'Starting…' : 'Start'),
      ),
    );
  }

  // ==================== Script ====================

  List<Widget> _scriptFields() => [
    GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Pm2SectionTitle(icon: Icons.code, title: 'Application'),
          _field(
            _script,
            'Script, binary or command *',
            hint: 'app.js, npm, ./server.py, /usr/bin/myapp',
            helper: 'Relative paths are resolved from the working directory',
          ),
          _field(_name, 'Name', hint: 'Defaults to the script name'),
          _field(_cwd, 'Working directory', mono: true),
          _field(
            _args,
            'Arguments',
            hint: 'start --port 3000',
            helper: 'Passed to the script after --. Quotes are supported.',
          ),
          _field(_interpreter, 'Interpreter', hint: 'node (default)'),
          _chips(
            ['node', 'python3', 'bash', 'bun', 'none'],
            _interpreter,
            helper: '"none" runs binaries directly',
          ),
          _field(
            _interpreterArgs,
            'Interpreter arguments',
            hint: '--max-old-space-size=512',
          ),
          _field(_namespace, 'Namespace', hint: 'default'),
        ],
      ),
    ),
    const Gap(12),
    _section(Icons.call_split, 'Cluster mode', [
      _field(
        _instances,
        'Instances',
        hint: 'empty = 1 instance in fork mode',
        helper:
            'Starts Node.js apps in cluster mode with load balancing. max = one per CPU core.',
      ),
      _chips(
        ['max', '2', '4', '-1'],
        _instances,
        helper: '-1 = all cores but one',
      ),
    ]),
    _section(Icons.key, 'Environment variables', [
      for (final row in _env)
        Row(
          children: [
            Expanded(flex: 2, child: _field(row.key, 'Name', mono: true)),
            const Gap(8),
            Expanded(flex: 3, child: _field(row.value, 'Value', mono: true)),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () => setState(() {
                _env.remove(row);
                row.dispose();
              }),
            ),
          ],
        ),
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Add variable'),
          onPressed: () => setState(() => _env.add(_EnvRow())),
        ),
      ),
    ], initiallyExpanded: _env.isNotEmpty),
    _section(Icons.replay, 'Restart strategy', [
      _switch(
        'Auto restart',
        'Restart the app when it crashes or exits',
        _autorestart,
        (v) => _autorestart = v,
      ),
      _field(
        _maxMemory,
        'Max memory restart',
        hint: '300M, 1G',
        helper: 'Restart when the app uses more memory than this',
      ),
      _field(
        _cron,
        'Cron restart',
        hint: '0 3 * * *',
        helper: 'Restart on a schedule',
      ),
      _field(_restartDelay, 'Restart delay (ms)', number: true),
      _field(
        _expBackoff,
        'Exponential backoff restart delay (ms)',
        number: true,
        helper: 'Grows the delay between restarts up to 15s, e.g. 100',
      ),
      _field(
        _maxRestarts,
        'Max unstable restarts',
        number: true,
        helper:
            'Mark the app errored after this many quick restarts (default 16)',
      ),
      _field(_stopExitCodes, 'Exit codes that skip restart', hint: '0 2'),
    ]),
    _section(Icons.visibility, 'Watch & reload', [
      _switch(
        'Watch files',
        'Restart when files in the working directory change',
        _watch,
        (v) => _watch = v,
      ),
      if (_watch) ...[
        _field(
          _ignoreWatch,
          'Ignore',
          hint: 'node_modules logs',
          helper: 'Space separated names or patterns',
        ),
        _field(_watchDelay, 'Watch delay', hint: '1000ms or 2'),
      ],
    ]),
    _section(Icons.receipt_long_outlined, 'Logs', [
      _switch(
        'Timestamps',
        'Prefix every log line with the time (--time)',
        _time,
        (v) => _time = v,
      ),
      _field(_logDateFormat, 'Custom date format', hint: 'YYYY-MM-DD HH:mm:ss'),
      _switch(
        'Merge cluster logs',
        'One log file for all instances',
        _mergeLogs,
        (v) => _mergeLogs = v,
      ),
      _switch(
        'Disable logs',
        'Do not store any log',
        _disableLogs,
        (v) => _disableLogs = v,
      ),
      _field(
        _outLog,
        'Output log file',
        hint: '~/.pm2/logs/<name>-out.log',
        mono: true,
      ),
      _field(
        _errLog,
        'Error log file',
        hint: '~/.pm2/logs/<name>-error.log',
        mono: true,
      ),
      _field(
        _combinedLog,
        'Combined log file',
        hint: 'stdout and stderr in one file',
        mono: true,
      ),
    ]),
    _section(Icons.tune, 'Advanced', [
      _field(
        _killTimeout,
        'Kill timeout (ms)',
        number: true,
        helper: 'Time before SIGKILL after a stop (default 1600)',
      ),
      _field(
        _listenTimeout,
        'Listen timeout (ms)',
        number: true,
        helper: 'Time to wait for the app to listen on reload',
      ),
      _switch(
        'Wait ready',
        'Wait for process.send("ready") instead of listen',
        _waitReady,
        (v) => _waitReady = v,
      ),
      _switch(
        'Shutdown with message',
        'Stop via process.send("shutdown") instead of SIGINT',
        _shutdownWithMessage,
        (v) => _shutdownWithMessage = v,
      ),
      _switch(
        'No treekill',
        'Only kill the main process, not its children',
        _noTreekill,
        (v) => _noTreekill = v,
      ),
      _switch(
        'Do not start now',
        'Add the app to PM2 without starting it',
        _noAutostart,
        (v) => _noAutostart = v,
      ),
      _switch(
        'No vizion',
        'Disable git versioning metadata',
        _noVizion,
        (v) => _noVizion = v,
      ),
      _switch(
        'Force',
        'Start even if the script already runs',
        _force,
        (v) => _force = v,
      ),
    ]),
  ];

  // ==================== Ecosystem ====================

  List<Widget> _ecosystemFields() => [
    GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Pm2SectionTitle(
            icon: Icons.description_outlined,
            title: 'Ecosystem file',
          ),
          Text(
            'An ecosystem file declares one or more apps with all their options and environments.',
            style: TextStyle(fontSize: 12, color: context.cs.onSurfaceVariant),
          ),
          const Gap(8),
          _field(
            _configFile,
            'File *',
            hint: 'ecosystem.config.js / .json / .yml',
            mono: true,
          ),
          _field(
            _envName,
            'Environment (--env)',
            hint: 'production',
            helper: 'Injects the env_<name> block of each app',
          ),
          _field(_only, 'Only these apps (--only)', hint: 'api,worker'),
          _switch(
            'Update environment',
            'Apply changed variables to running apps (--update-env)',
            _updateEnv,
            (v) => _updateEnv = v,
          ),
          const Gap(8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Edit file'),
                onPressed: () =>
                    openPm2FileEditor(context, _configFile.text.trim()),
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.note_add_outlined, size: 18),
                label: const Text('Generate new'),
                onPressed: () async {
                  final path = await showPm2EcosystemDialog(
                    context,
                    ref,
                    defaultDir: widget.info.home,
                  );
                  if (path != null && mounted) {
                    setState(() => _configFile.text = path);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    ),
  ];

  // ==================== Serve ====================

  List<Widget> _serveFields() => [
    GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Pm2SectionTitle(
            icon: Icons.public,
            title: 'Static file server',
          ),
          Text(
            'pm2 serve exposes a folder over HTTP, e.g. a built React or Vue app.',
            style: TextStyle(fontSize: 12, color: context.cs.onSurfaceVariant),
          ),
          const Gap(8),
          _field(_servePath, 'Folder *', mono: true),
          _field(_servePort, 'Port *', number: true),
          _field(_name, 'Name', hint: 'static-page-server-<port>'),
          _switch(
            'Single page app',
            'Serve index.html for unknown paths (--spa)',
            _spa,
            (v) => _spa = v,
          ),
          _switch(
            'Watch files',
            'Restart when files change',
            _watch,
            (v) => _watch = v,
          ),
          const Gap(8),
          Text(
            'Basic auth (optional)',
            style: TextStyle(fontSize: 12, color: context.cs.onSurfaceVariant),
          ),
          _field(_authUser, 'Username'),
          _field(_authPassword, 'Password', obscure: true),
        ],
      ),
    ),
  ];

  // ==================== Building blocks ====================

  Widget _section(
    IconData icon,
    String title,
    List<Widget> children, {
    bool initiallyExpanded = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: initiallyExpanded,
            leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
            title: Text(title, style: Theme.of(context).textTheme.titleSmall),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    String? hint,
    String? helper,
    bool number = false,
    bool mono = false,
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        autocorrect: false,
        style: mono
            ? const TextStyle(fontFamily: 'monospace', fontSize: 13)
            : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          helperText: helper,
          helperMaxLines: 2,
        ),
      ),
    );
  }

  Widget _chips(
    List<String> values,
    TextEditingController controller, {
    String? helper,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final v in values)
                ActionChip(
                  visualDensity: VisualDensity.compact,
                  label: Text(v, style: const TextStyle(fontSize: 12)),
                  onPressed: () => setState(() => controller.text = v),
                ),
            ],
          ),
          if (helper != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                helper,
                style: TextStyle(
                  fontSize: 11,
                  color: context.cs.outline,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _switch(
    String title,
    String subtitle,
    bool value,
    void Function(bool) apply,
  ) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: context.cs.onSurfaceVariant),
      ),
      value: value,
      onChanged: (v) => setState(() => apply(v)),
    );
  }
}

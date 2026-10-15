import 'dart:async';
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../ui/ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../generated/pi_control.pb.dart';
import '../services/pm2_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/pm2_widgets.dart';
import 'pm2_logs_screen.dart';

/// Details, live monitoring and every action for one PM2 process
class Pm2ProcessScreen extends ConsumerStatefulWidget {
  final int pmId;
  final String name;

  const Pm2ProcessScreen({super.key, required this.pmId, required this.name});

  @override
  ConsumerState<Pm2ProcessScreen> createState() => _Pm2ProcessScreenState();
}

class _Pm2ProcessScreenState extends ConsumerState<Pm2ProcessScreen> {
  static const _refreshInterval = Duration(seconds: 3);
  static const _maxPoints = 40;

  Pm2ProcessDetails? _details;
  Object? _error;
  bool _gone = false;
  bool _fetching = false;
  Timer? _timer;

  final List<double> _cpuHistory = [];
  final List<double> _memoryHistory = [];

  bool _showEnvValues = false;
  String _envSearch = '';

  String get _target => '${widget.pmId}';

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(_refreshInterval, (_) => _load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    if (_fetching || _gone) return;
    _fetching = true;
    try {
      final details = await ref.read(pm2ServiceProvider).describe(_target);
      if (!mounted) return;
      setState(() {
        _details = details;
        _error = null;
        final p = details.process;
        _cpuHistory.add(p.status == 'online' ? p.cpu : 0);
        _memoryHistory.add(
          p.status == 'online' ? p.memory.toDouble() / (1024 * 1024) : 0,
        );
        if (_cpuHistory.length > _maxPoints) _cpuHistory.removeAt(0);
        if (_memoryHistory.length > _maxPoints) _memoryHistory.removeAt(0);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        if (e is Pm2Exception && e.notFound) _gone = true;
      });
    } finally {
      _fetching = false;
    }
  }

  Future<void> _control(
    Pm2Action action, {
    required String progress,
    String? success,
    bool updateEnv = false,
    String value = '',
    String actionName = '',
    String actionParam = '',
  }) async {
    final ok = await pm2Control(
      context,
      ref,
      action,
      _target,
      progress: progress,
      success: success,
      updateEnv: updateEnv,
      value: value,
      actionName: actionName,
      actionParam: actionParam,
    );
    if (ok && action == Pm2Action.PM2_ACTION_DELETE && mounted) {
      Navigator.pop(context);
      return;
    }
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final details = _details;
    final name = details?.process.name ?? widget.name;

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.article_outlined),
            tooltip: 'Logs',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    Pm2LogsScreen(target: _target, title: '$name logs'),
              ),
            ),
          ),
          if (details != null)
            IconButton(
              icon: const Icon(Icons.data_object),
              tooltip: 'pm2 describe (raw)',
              onPressed: () => showPm2OutputDialog(
                context,
                title: 'pm2 describe $name',
                output: details.rawJson,
              ),
            ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final details = _details;

    if (_gone) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.delete_outline,
              size: 56,
              color: context.cs.onSurfaceVariant,
            ),
            const Gap(16),
            const Text('This process no longer exists in PM2'),
            const Gap(16),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back'),
            ),
          ],
        ),
      );
    }

    if (details == null) {
      if (_error != null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              Pm2Exception.from(_error!).message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        );
      }
      return const Center(child: CircularProgressIndicator());
    }

    final p = details.process;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(context, p),
          const Gap(16),
          _buildActions(context, p),
          const Gap(16),
          _buildMonitor(context, p),
          if (p.metrics.isNotEmpty) ...[
            const Gap(16),
            _buildMetrics(context, p),
          ],
          const Gap(16),
          _buildInfo(context, p),
          if (p.hasVersioning() && p.versioning.present) ...[
            const Gap(16),
            _buildVersioning(context, p.versioning),
          ],
          const Gap(16),
          _buildEnvironment(context, details.env),
          const Gap(24),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Pm2Process p) {
    final online = p.status == 'online';

    Widget stat(String label, String value, {Color? color}) => Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const Gap(2),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: context.cs.onSurfaceVariant),
          ),
        ],
      ),
    );

    return GlassCard(
      glowColor: pm2StatusColor(context, p.status),
      child: Column(
        children: [
          Row(
            children: [
              Pm2StatusDot(status: p.status, size: 14),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      [
                        '#${p.pmId}',
                        p.execMode.isEmpty ? 'fork' : p.execMode,
                        if (online && p.pid > 0) 'pid ${p.pid}',
                        if (p.namespace.isNotEmpty) 'ns ${p.namespace}',
                      ].join(' · '),
                      style: TextStyle(
                        fontSize: 12,
                        color: context.cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Pm2StatusBadge(status: p.status),
            ],
          ),
          const Gap(16),
          Row(
            children: [
              stat(
                'CPU',
                Pm2Format.cpu(p.cpu),
                color: Theme.of(context).colorScheme.primary,
              ),
              stat(
                'Memory',
                Pm2Format.bytes(p.memory.toInt()),
                color: Theme.of(context).colorScheme.secondary,
              ),
              stat(
                'Uptime',
                online ? Pm2Format.uptime(p.startedAt.toInt()) : '-',
              ),
              stat(
                'Restarts',
                '${p.restarts}',
                color: p.unstableRestarts > 0 ? context.ac.warning : null,
              ),
            ],
          ),
          if (p.status == 'errored' || (!online && p.exitCode != 0)) ...[
            const Gap(12),
            Text(
              'Last exit code: ${p.exitCode}${p.unstableRestarts > 0 ? ' · ${p.unstableRestarts} unstable restarts' : ''}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, Pm2Process p) {
    final online = p.status == 'online';
    final name = p.name;
    final error = Theme.of(context).colorScheme.error;

    final buttons = <Widget>[
      if (online) ...[
        _ActionButton(Icons.restart_alt, 'Restart', context.ac.warning, () {
          _control(
            Pm2Action.PM2_ACTION_RESTART,
            progress: 'Restarting $name…',
            success: '$name restarted',
          );
        }),
        _ActionButton(Icons.autorenew, 'Reload', context.ac.success, () {
          _control(
            Pm2Action.PM2_ACTION_RELOAD,
            progress: 'Reloading $name…',
            success: '$name reloaded',
          );
        }),
        _ActionButton(Icons.stop, 'Stop', error, () {
          _control(
            Pm2Action.PM2_ACTION_STOP,
            progress: 'Stopping $name…',
            success: '$name stopped',
          );
        }),
      ] else
        _ActionButton(Icons.play_arrow, 'Start', context.ac.success, () {
          _control(
            Pm2Action.PM2_ACTION_START,
            progress: 'Starting $name…',
            success: '$name started',
          );
        }),
      _ActionButton(
        Icons.settings_backup_restore,
        'Restart + env',
        context.ac.warning,
        () {
          _control(
            Pm2Action.PM2_ACTION_RESTART,
            updateEnv: true,
            progress: 'Restarting $name with updated environment…',
            success: '$name restarted with updated environment',
          );
        },
      ),
      if (p.execMode == 'cluster')
        _ActionButton(
          Icons.call_split,
          'Scale',
          Theme.of(context).colorScheme.primary,
          () => _scale(p),
        ),
      _ActionButton(
        p.watch ? Icons.visibility_off : Icons.visibility,
        p.watch ? 'Stop watch' : 'Watch',
        Theme.of(context).colorScheme.primary,
        () => _control(
          Pm2Action.PM2_ACTION_TOGGLE_WATCH,
          progress: '${p.watch ? 'Disabling' : 'Enabling'} watch…',
          success: 'Watch ${p.watch ? 'disabled' : 'enabled'} for $name',
        ),
      ),
      _ActionButton(
        Icons.bolt,
        'Signal',
        Theme.of(context).colorScheme.primary,
        () => _sendSignal(p),
      ),
      _ActionButton(
        Icons.keyboard,
        'Stdin',
        Theme.of(context).colorScheme.primary,
        () => _sendStdin(p),
      ),
      _ActionButton(Icons.exposure_zero, 'Reset', context.cs.onSurfaceVariant, () {
        _control(
          Pm2Action.PM2_ACTION_RESET,
          progress: 'Resetting counters…',
          success: 'Counters of $name reset',
        );
      }),
      _ActionButton(
        Icons.cleaning_services,
        'Flush logs',
        context.cs.onSurfaceVariant,
        () async {
          if (await confirmPm2(
            context,
            title: 'Flush logs of $name?',
            message: 'The log files of this process are emptied.',
            confirmLabel: 'Flush',
          )) {
            await _control(
              Pm2Action.PM2_ACTION_FLUSH,
              progress: 'Flushing logs…',
              success: 'Logs of $name flushed',
            );
          }
        },
      ),
      _ActionButton(Icons.delete_outline, 'Delete', error, () async {
        if (await confirmPm2(
          context,
          title: 'Delete $name?',
          message:
              'The process is stopped and removed from PM2. Its log files stay on disk.',
          confirmLabel: 'Delete',
          destructive: true,
        )) {
          await _control(
            Pm2Action.PM2_ACTION_DELETE,
            progress: 'Deleting $name…',
            success: '$name deleted',
          );
        }
      }),
      if (p.hasVersioning() && p.versioning.present) ...[
        _ActionButton(
          Icons.download,
          'Git pull',
          Theme.of(context).colorScheme.secondary,
          () async {
            final commit = await promptPm2Text(
              context,
              title: 'Pull & restart',
              label: 'Commit id (optional)',
              helper:
                  'Empty pulls the latest commit of the current branch, then restarts.',
              confirmLabel: 'Pull',
            );
            if (commit == null) return;
            await _control(
              Pm2Action.PM2_ACTION_PULL,
              value: commit,
              progress: 'Pulling $name…',
            );
          },
        ),
        _ActionButton(
          Icons.fast_forward,
          'Forward',
          Theme.of(context).colorScheme.secondary,
          () {
            _control(
              Pm2Action.PM2_ACTION_FORWARD,
              progress: 'Moving $name to the next commit…',
            );
          },
        ),
        _ActionButton(
          Icons.fast_rewind,
          'Backward',
          Theme.of(context).colorScheme.secondary,
          () {
            _control(
              Pm2Action.PM2_ACTION_BACKWARD,
              progress: 'Moving $name to the previous commit…',
            );
          },
        ),
      ],
    ];

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Pm2SectionTitle(
            icon: Icons.touch_app_outlined,
            title: 'Actions',
          ),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.95,
            children: buttons,
          ),
          if (p.customActions.isNotEmpty) ...[
            const Gap(16),
            Text(
              'Custom actions (pm2 trigger)',
              style: TextStyle(fontSize: 12, color: context.cs.onSurfaceVariant),
            ),
            const Gap(8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final action in p.customActions)
                  ActionChip(
                    avatar: const Icon(Icons.play_circle_outline, size: 16),
                    label: Text(action),
                    onPressed: () => _trigger(p, action),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _scale(Pm2Process p) async {
    final processes = ref.read(pm2ProcessesProvider).valueOrNull;
    final current = processes?.where((x) => x.name == p.name).length;
    final value = await promptPm2Text(
      context,
      title: 'Scale ${p.name}',
      label: 'Instances',
      hint: '4, +2 or -1',
      initial: current != null ? '$current' : '',
      helper:
          'A number sets the instance count, +n / -n adds or removes instances.',
      confirmLabel: 'Scale',
      suggestions: const ['+1', '-1', '2', '4'],
    );
    if (value == null || value.isEmpty) return;
    await _control(
      Pm2Action.PM2_ACTION_SCALE,
      value: value,
      progress: 'Scaling ${p.name} to $value…',
      success: '${p.name} scaled to $value',
    );
  }

  Future<void> _sendSignal(Pm2Process p) async {
    final signal = await promptPm2Text(
      context,
      title: 'Send signal to ${p.name}',
      label: 'Signal',
      hint: 'SIGUSR2',
      confirmLabel: 'Send',
      suggestions: const [
        'SIGUSR1',
        'SIGUSR2',
        'SIGHUP',
        'SIGINT',
        'SIGTERM',
        'SIGKILL',
      ],
    );
    if (signal == null || signal.isEmpty) return;
    await _control(
      Pm2Action.PM2_ACTION_SEND_SIGNAL,
      value: signal.toUpperCase(),
      progress: 'Sending ${signal.toUpperCase()}…',
      success: '${signal.toUpperCase()} sent to ${p.name}',
    );
  }

  Future<void> _sendStdin(Pm2Process p) async {
    final line = await promptPm2Text(
      context,
      title: 'Send to stdin of ${p.name}',
      label: 'Line',
      helper: 'pm2 send writes the line to the standard input of the process.',
      confirmLabel: 'Send',
    );
    if (line == null) return;
    await _control(
      Pm2Action.PM2_ACTION_SEND_STDIN,
      value: line,
      progress: 'Sending…',
      success: 'Line sent to ${p.name}',
    );
  }

  Future<void> _trigger(Pm2Process p, String action) async {
    final param = await promptPm2Text(
      context,
      title: 'Trigger $action',
      label: 'Parameter (optional)',
      confirmLabel: 'Trigger',
    );
    if (param == null || !mounted) return;
    try {
      final result = await ref
          .read(pm2ServiceProvider)
          .control(
            Pm2Action.PM2_ACTION_TRIGGER,
            _target,
            actionName: action,
            actionParam: param,
          );
      if (!mounted) return;
      await showPm2OutputDialog(
        context,
        title: action,
        command: result.command,
        output: result.output,
        isError: !result.success,
      );
    } catch (e) {
      if (mounted) showPm2Error(context, e);
    }
  }

  Widget _buildMonitor(BuildContext context, Pm2Process p) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Pm2SectionTitle(
            icon: Icons.monitor_heart_outlined,
            title: 'Live monitor',
            trailing: Text(
              'every ${_refreshInterval.inSeconds}s',
              style: TextStyle(
                fontSize: 11,
                color: context.cs.outline,
              ),
            ),
          ),
          _MiniChart(
            label: 'CPU',
            value: Pm2Format.cpu(p.cpu),
            values: _cpuHistory,
            color: Theme.of(context).colorScheme.primary,
            minMax: 10,
            unit: '%',
          ),
          const Gap(16),
          _MiniChart(
            label: 'Memory',
            value: Pm2Format.bytes(p.memory.toInt()),
            values: _memoryHistory,
            color: Theme.of(context).colorScheme.secondary,
            minMax: 16,
            unit: ' MB',
            limit: p.maxMemoryRestart > 0
                ? p.maxMemoryRestart.toDouble() / (1024 * 1024)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildMetrics(BuildContext context, Pm2Process p) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Pm2SectionTitle(icon: Icons.insights, title: 'Metrics'),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.6,
            children: [
              for (final m in p.metrics)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: context.cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: context.cs.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        m.name,
                        style: TextStyle(
                          fontSize: 11,
                          color: context.cs.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${m.value}${m.unit.isNotEmpty ? ' ${m.unit}' : ''}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfo(BuildContext context, Pm2Process p) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Pm2SectionTitle(icon: Icons.info_outline, title: 'Details'),
          Pm2InfoRow(label: 'Script', value: p.script, monospace: true),
          Pm2InfoRow(label: 'Working dir', value: p.cwd, monospace: true),
          Pm2InfoRow(
            label: 'Arguments',
            value: p.args.join(' '),
            monospace: true,
          ),
          Pm2InfoRow(
            label: 'Interpreter',
            value: [
              p.interpreter,
              p.interpreterArgs,
            ].where((s) => s.isNotEmpty).join(' '),
          ),
          if (p.nodeVersion.isNotEmpty)
            Pm2InfoRow(label: 'Node.js', value: p.nodeVersion),
          if (p.version.isNotEmpty && p.version != 'N/A')
            Pm2InfoRow(label: 'App version', value: p.version),
          Pm2InfoRow(label: 'Exec mode', value: p.execMode),
          if (p.execMode == 'cluster')
            Pm2InfoRow(label: 'Instances', value: '${p.instances}'),
          Pm2InfoRow(label: 'User', value: p.user),
          Pm2InfoRow(label: 'Namespace', value: p.namespace),
          Pm2InfoRow(
            label: 'Created',
            value: Pm2Format.dateTime(p.createdAt.toInt()),
          ),
          Pm2InfoRow(
            label: 'Started',
            value: Pm2Format.dateTime(p.startedAt.toInt()),
          ),
          Pm2InfoRow(label: 'Autorestart', value: p.autorestart ? 'yes' : 'no'),
          Pm2InfoRow(label: 'Watch', value: p.watch ? 'enabled' : 'disabled'),
          Pm2InfoRow(
            label: 'Max memory',
            value: p.maxMemoryRestart > 0
                ? Pm2Format.bytes(p.maxMemoryRestart.toInt())
                : '-',
          ),
          Pm2InfoRow(label: 'Cron restart', value: p.cronRestart),
          Pm2InfoRow(
            label: 'Unstable restarts',
            value: '${p.unstableRestarts}',
          ),
          Pm2InfoRow(label: 'Out log', value: p.outLog, monospace: true),
          Pm2InfoRow(label: 'Error log', value: p.errLog, monospace: true),
          const Gap(4),
          Text(
            'Long-press a value to copy it.',
            style: TextStyle(fontSize: 11, color: context.cs.outline),
          ),
        ],
      ),
    );
  }

  Widget _buildVersioning(BuildContext context, Pm2Versioning v) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Pm2SectionTitle(
            icon: Icons.commit,
            title: 'Source control',
            trailing: v.unstaged
                ? Text(
                    'unstaged changes',
                    style: TextStyle(
                      color: context.ac.warning,
                      fontSize: 11,
                    ),
                  )
                : null,
          ),
          Pm2InfoRow(label: 'Repository', value: v.url, monospace: true),
          Pm2InfoRow(label: 'Branch', value: v.branch),
          Pm2InfoRow(label: 'Revision', value: v.revision, monospace: true),
          Pm2InfoRow(label: 'Comment', value: v.comment),
          if (v.updateTime > 0)
            Pm2InfoRow(
              label: 'Updated',
              value: Pm2Format.dateTime(v.updateTime.toInt()),
            ),
        ],
      ),
    );
  }

  Widget _buildEnvironment(BuildContext context, Map<String, String> env) {
    final query = _envSearch.toLowerCase();
    final keys =
        env.keys
            .where((k) => query.isEmpty || k.toLowerCase().contains(query))
            .toList()
          ..sort();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Pm2SectionTitle(
            icon: Icons.key,
            title: 'Environment (${env.length})',
            trailing: IconButton(
              tooltip: _showEnvValues ? 'Hide values' : 'Show values',
              icon: Icon(
                _showEnvValues ? Icons.visibility_off : Icons.visibility,
                size: 20,
              ),
              onPressed: () => setState(() => _showEnvValues = !_showEnvValues),
            ),
          ),
          TextField(
            decoration: const InputDecoration(
              hintText: 'Filter variables',
              prefixIcon: Icon(Icons.search, size: 20),
              isDense: true,
            ),
            onChanged: (v) => setState(() => _envSearch = v),
          ),
          const Gap(8),
          for (final key in keys)
            InkWell(
              onLongPress: () {
                Clipboard.setData(ClipboardData(text: '$key=${env[key]}'));
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('$key copied')));
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        key,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const Gap(8),
                    Expanded(
                      flex: 3,
                      child: Text(
                        _showEnvValues ? env[key]! : '••••••••',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const Gap(4),
          Text(
            'Change variables with Start or the ecosystem file, then use Restart + env.',
            style: TextStyle(fontSize: 11, color: context.cs.outline),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton(this.icon, this.label, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: color.withValues(alpha: 0.12),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const Gap(5),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniChart extends StatelessWidget {
  final String label;
  final String value;
  final List<double> values;
  final Color color;
  final double minMax;
  final String unit;
  final double? limit;

  const _MiniChart({
    required this.label,
    required this.value,
    required this.values,
    required this.color,
    required this.minMax,
    required this.unit,
    this.limit,
  });

  @override
  Widget build(BuildContext context) {
    final peak = values.isEmpty ? 0.0 : values.reduce(math.max);
    final maxY = math.max(minMax, peak * 1.25);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: context.cs.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
            Text(
              '  peak ${peak.toStringAsFixed(1)}$unit',
              style: TextStyle(
                fontSize: 11,
                color: context.cs.outline,
              ),
            ),
          ],
        ),
        const Gap(6),
        SizedBox(
          height: 80,
          child: values.length < 2
              ? Center(
                  child: Text(
                    'Collecting data…',
                    style: TextStyle(
                      fontSize: 11,
                      color: context.cs.outline,
                    ),
                  ),
                )
              : LineChart(
                  LineChartData(
                    minY: 0,
                    maxY: maxY,
                    minX: 0,
                    maxX: (_Pm2ProcessScreenState._maxPoints - 1).toDouble(),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: maxY / 2,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: context.cs.outlineVariant,
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineTouchData: const LineTouchData(enabled: false),
                    extraLinesData: limit != null && limit! <= maxY
                        ? ExtraLinesData(
                            horizontalLines: [
                              HorizontalLine(
                                y: limit!,
                                color: Theme.of(
                                  context,
                                ).colorScheme.error.withValues(alpha: 0.6),
                                strokeWidth: 1,
                                dashArray: [4, 4],
                              ),
                            ],
                          )
                        : null,
                    lineBarsData: [
                      LineChartBarData(
                        // Right-align so new values always enter at the right edge
                        spots: [
                          for (var i = 0; i < values.length; i++)
                            FlSpot(
                              (_Pm2ProcessScreenState._maxPoints -
                                      values.length +
                                      i)
                                  .toDouble(),
                              values[i],
                            ),
                        ],
                        isCurved: true,
                        preventCurveOverShooting: true,
                        color: color,
                        barWidth: 2,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: color.withValues(alpha: 0.15),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import '../ui/ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../generated/pi_control.pb.dart';
import '../services/pm2_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/pm2_widgets.dart';
import 'pm2_logs_screen.dart';
import 'pm2_process_screen.dart';
import 'pm2_start_screen.dart';

class Pm2Screen extends ConsumerStatefulWidget {
  const Pm2Screen({super.key});

  @override
  ConsumerState<Pm2Screen> createState() => _Pm2ScreenState();
}

class _Pm2ScreenState extends ConsumerState<Pm2Screen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this)
      ..addListener(() {
        if (!_tabController.indexIsChanging) setState(() {});
      });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final infoAsync = ref.watch(pm2InfoProvider);
    final info = infoAsync.valueOrNull;
    final installed = info?.installed ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PM2'),
        scrolledUnderElevation: 0,
        actions: [
          if (installed)
            IconButton(
              icon: const Icon(Icons.receipt_long),
              tooltip: 'All logs',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const Pm2LogsScreen(target: 'all', title: 'All logs'),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              ref.invalidate(pm2InfoProvider);
              ref.invalidate(pm2ProcessesProvider);
            },
          ),
        ],
        bottom: installed
            ? TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(icon: Icon(Icons.apps, size: 20), text: 'Processes'),
                  Tab(icon: Icon(Icons.extension, size: 20), text: 'Modules'),
                  Tab(icon: Icon(Icons.tune, size: 20), text: 'Manage'),
                ],
              )
            : null,
      ),
      body: infoAsync.when(
        skipLoadingOnRefresh: true,
        data: (info) {
          if (info.error.isNotEmpty) {
            return _Pm2ErrorView(error: Pm2Exception(info.error));
          }
          if (!info.installed) return _NotInstalledView(info: info);
          return TabBarView(
            controller: _tabController,
            children: [
              const _ProcessesTab(),
              _ModulesTab(info: info),
              _ManageTab(info: info),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _Pm2ErrorView(error: Pm2Exception.from(e)),
      ),
      floatingActionButton: installed && _tabController.index == 0
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => Pm2StartScreen(info: info!)),
              ),
            )
          : null,
    );
  }
}

// ==================== Error / not installed ====================

class _Pm2ErrorView extends ConsumerWidget {
  final Pm2Exception error;

  const _Pm2ErrorView({required this.error});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              error.agentOutdated ? Icons.system_update : Icons.error_outline,
              size: 56,
              color: error.agentOutdated
                  ? context.ac.warning
                  : Theme.of(context).colorScheme.error,
            ),
            const Gap(16),
            Text(
              error.agentOutdated ? 'Agent update required' : 'PM2 unavailable',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Gap(8),
            Text(
              error.agentOutdated
                  ? '${error.message}\n\nUse the update banner on the dashboard or Settings → Reinstall Agent.'
                  : error.message,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.cs.onSurfaceVariant),
            ),
            const Gap(16),
            FilledButton.icon(
              onPressed: () => ref.invalidate(pm2InfoProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotInstalledView extends ConsumerWidget {
  final Pm2Info info;

  const _NotInstalledView({required this.info});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.rocket_launch,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const Gap(12),
                  Expanded(
                    child: Text(
                      'PM2 is not installed',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
              const Gap(12),
              Text(
                'PM2 was not found for user "${info.user}". PM2 is a process '
                'manager for Node.js (and any other) apps: it keeps them '
                'running, restarts them on crash, clusters them and manages '
                'their logs.',
                style: TextStyle(color: context.cs.onSurfaceVariant),
              ),
              const Gap(16),
              Pm2InfoRow(label: 'User', value: info.user),
              Pm2InfoRow(
                label: 'Node.js',
                value: info.nodeVersion.isEmpty
                    ? 'not found'
                    : info.nodeVersion,
              ),
              Pm2InfoRow(
                label: 'npm',
                value: info.npmAvailable ? 'available' : 'not found',
              ),
              const Gap(16),
              if (info.npmAvailable)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.download),
                    label: const Text('Install PM2'),
                    onPressed: () => runPm2Operation(
                      context,
                      ref,
                      title: 'Installing PM2',
                      request: Pm2OperationRequest()
                        ..operation = Pm2Operation.PM2_OP_INSTALL_PM2,
                    ),
                  ),
                )
              else ...[
                Text(
                  'Install Node.js first, then come back here. For example over SSH:',
                  style: TextStyle(color: context.cs.onSurfaceVariant),
                ),
                const Gap(8),
                const Pm2TextPanel(
                  text:
                      'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash\n'
                      'nvm install --lts\n\n'
                      '# or with apt\n'
                      'sudo apt install nodejs npm',
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ==================== Processes tab ====================

enum _Pm2Sort { id, name, cpu, memory, uptime, restarts, status }

class _ProcessesTab extends ConsumerStatefulWidget {
  const _ProcessesTab();

  @override
  ConsumerState<_ProcessesTab> createState() => _ProcessesTabState();
}

class _ProcessesTabState extends ConsumerState<_ProcessesTab> {
  String _search = '';
  String _filter = 'all';
  _Pm2Sort _sort = _Pm2Sort.id;
  bool _descending = false;

  @override
  Widget build(BuildContext context) {
    final processesAsync = ref.watch(pm2ProcessesProvider);

    return processesAsync.when(
      skipLoadingOnRefresh: true,
      skipLoadingOnReload: true,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _Pm2ErrorView(error: Pm2Exception.from(e)),
      data: (all) {
        final apps = all.where((p) => !p.isModule).toList();
        final visible = _apply(apps);

        return RefreshIndicator(
          onRefresh: () => ref.read(pm2ProcessesProvider.notifier).refresh(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              _SummaryCard(processes: apps),
              const Gap(12),
              _buildToolbar(apps),
              const Gap(12),
              if (apps.isEmpty)
                _buildEmpty()
              else if (visible.isEmpty)
                Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      'No processes match the filter',
                      style: TextStyle(color: context.cs.onSurfaceVariant),
                    ),
                  ),
                )
              else
                for (final p in visible) _ProcessCard(process: p),
            ],
          ),
        );
      },
    );
  }

  List<Pm2Process> _apply(List<Pm2Process> processes) {
    final query = _search.toLowerCase();
    final result = processes.where((p) {
      if (query.isNotEmpty &&
          !p.name.toLowerCase().contains(query) &&
          !p.namespace.toLowerCase().contains(query) &&
          !p.script.toLowerCase().contains(query) &&
          '${p.pmId}' != query) {
        return false;
      }
      switch (_filter) {
        case 'online':
          return p.status == 'online';
        case 'stopped':
          return p.status == 'stopped';
        case 'errored':
          return p.status == 'errored';
      }
      return true;
    }).toList();

    int compare(Pm2Process a, Pm2Process b) {
      switch (_sort) {
        case _Pm2Sort.id:
          return a.pmId.compareTo(b.pmId);
        case _Pm2Sort.name:
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case _Pm2Sort.cpu:
          return a.cpu.compareTo(b.cpu);
        case _Pm2Sort.memory:
          return a.memory.compareTo(b.memory);
        case _Pm2Sort.uptime:
          // Longest running first when ascending
          return b.startedAt.compareTo(a.startedAt);
        case _Pm2Sort.restarts:
          return a.restarts.compareTo(b.restarts);
        case _Pm2Sort.status:
          return a.status.compareTo(b.status);
      }
    }

    result.sort((a, b) => _descending ? compare(b, a) : compare(a, b));
    return result;
  }

  Widget _buildToolbar(List<Pm2Process> apps) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search name, namespace, script, id...',
                  prefixIcon: Icon(
                    Icons.search,
                    color: context.cs.outline,
                  ),
                  isDense: true,
                  filled: true,
                  fillColor: context.cs.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.cs.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.cs.outlineVariant),
                  ),
                ),
                onChanged: (v) => setState(() => _search = v),
              ),
            ),
            PopupMenuButton<_Pm2Sort>(
              icon: const Icon(Icons.sort),
              tooltip: 'Sort',
              onSelected: (s) => setState(() {
                if (_sort == s) {
                  _descending = !_descending;
                } else {
                  _sort = s;
                  _descending =
                      s == _Pm2Sort.cpu ||
                      s == _Pm2Sort.memory ||
                      s == _Pm2Sort.restarts;
                }
              }),
              itemBuilder: (_) => [
                for (final s in _Pm2Sort.values)
                  PopupMenuItem(
                    value: s,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 24,
                          child: _sort == s
                              ? Icon(
                                  _descending
                                      ? Icons.arrow_downward
                                      : Icons.arrow_upward,
                                  size: 16,
                                )
                              : null,
                        ),
                        Text(s.name[0].toUpperCase() + s.name.substring(1)),
                      ],
                    ),
                  ),
              ],
            ),
            _BulkActionsButton(enabled: apps.isNotEmpty),
          ],
        ),
        const Gap(10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final f in const [
                ('all', 'All'),
                ('online', 'Online'),
                ('stopped', 'Stopped'),
                ('errored', 'Errored'),
              ]) ...[
                ChoiceChip(
                  label: Text(
                    f.$1 == 'all'
                        ? '${f.$2} (${apps.length})'
                        : '${f.$2} (${apps.where((p) => p.status == f.$1).length})',
                  ),
                  selected: _filter == f.$1,
                  onSelected: (_) => setState(() => _filter = f.$1),
                ),
                const Gap(8),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(
            Icons.rocket_launch_outlined,
            size: 64,
            color: context.cs.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const Gap(16),
          Text(
            'No processes yet',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: context.cs.onSurfaceVariant),
          ),
          const Gap(8),
          Text(
            'Tap Start to run a script, an ecosystem file or a static server.\n'
            'Saved processes can be brought back with Manage → Resurrect.',
            textAlign: TextAlign.center,
            style: TextStyle(color: context.cs.outline, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _BulkActionsButton extends ConsumerWidget {
  final bool enabled;

  const _BulkActionsButton({required this.enabled});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      tooltip: 'All processes',
      enabled: enabled,
      onSelected: (value) => _run(context, ref, value),
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: 'restart',
          child: ListTile(
            leading: Icon(Icons.restart_alt),
            title: Text('Restart all'),
          ),
        ),
        PopupMenuItem(
          value: 'reload',
          child: ListTile(
            leading: Icon(Icons.autorenew),
            title: Text('Reload all (zero downtime)'),
          ),
        ),
        PopupMenuItem(
          value: 'restart-env',
          child: ListTile(
            leading: Icon(Icons.settings_backup_restore),
            title: Text('Restart all + update env'),
          ),
        ),
        PopupMenuItem(
          value: 'stop',
          child: ListTile(leading: Icon(Icons.stop), title: Text('Stop all')),
        ),
        PopupMenuItem(
          value: 'reset',
          child: ListTile(
            leading: Icon(Icons.exposure_zero),
            title: Text('Reset all counters'),
          ),
        ),
        PopupMenuItem(
          value: 'flush',
          child: ListTile(
            leading: Icon(Icons.cleaning_services),
            title: Text('Flush all logs'),
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete_forever),
            title: Text('Delete all'),
          ),
        ),
      ],
    );
  }

  Future<void> _run(BuildContext context, WidgetRef ref, String value) async {
    switch (value) {
      case 'restart':
        await pm2Control(
          context,
          ref,
          Pm2Action.PM2_ACTION_RESTART,
          'all',
          progress: 'Restarting all processes…',
          success: 'All processes restarted',
        );
      case 'reload':
        await pm2Control(
          context,
          ref,
          Pm2Action.PM2_ACTION_RELOAD,
          'all',
          progress: 'Reloading all processes…',
          success: 'All processes reloaded',
        );
      case 'restart-env':
        await pm2Control(
          context,
          ref,
          Pm2Action.PM2_ACTION_RESTART,
          'all',
          updateEnv: true,
          progress: 'Restarting all processes…',
          success: 'All processes restarted with updated environment',
        );
      case 'stop':
        if (await confirmPm2(
          context,
          title: 'Stop all processes?',
          message:
              'Every PM2 process will be stopped. They stay in the list and can be started again.',
          confirmLabel: 'Stop all',
        )) {
          if (!context.mounted) return;
          await pm2Control(
            context,
            ref,
            Pm2Action.PM2_ACTION_STOP,
            'all',
            progress: 'Stopping all processes…',
            success: 'All processes stopped',
          );
        }
      case 'reset':
        await pm2Control(
          context,
          ref,
          Pm2Action.PM2_ACTION_RESET,
          'all',
          progress: 'Resetting counters…',
          success: 'Restart counters reset',
        );
      case 'flush':
        await pm2Control(
          context,
          ref,
          Pm2Action.PM2_ACTION_FLUSH,
          'all',
          progress: 'Flushing logs…',
          success: 'All logs flushed',
        );
      case 'delete':
        if (await confirmPm2(
          context,
          title: 'Delete all processes?',
          message:
              'Every process is stopped and removed from PM2. Run Save afterwards if they should not come back after a reboot.',
          confirmLabel: 'Delete all',
          destructive: true,
        )) {
          if (!context.mounted) return;
          await pm2Control(
            context,
            ref,
            Pm2Action.PM2_ACTION_DELETE,
            'all',
            progress: 'Deleting all processes…',
            success: 'All processes deleted',
          );
        }
    }
  }
}

class _SummaryCard extends StatelessWidget {
  final List<Pm2Process> processes;

  const _SummaryCard({required this.processes});

  @override
  Widget build(BuildContext context) {
    final online = processes.where((p) => p.status == 'online').length;
    final errored = processes.where((p) => p.status == 'errored').length;
    final stopped = processes.length - online - errored;
    final cpu = processes.fold<double>(0, (sum, p) => sum + p.cpu);
    final memory = processes.fold<int>(0, (sum, p) => sum + p.memory.toInt());

    Widget stat(String label, String value, Color color) => Expanded(
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
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
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Row(
        children: [
          stat('Online', '$online', context.ac.success),
          stat('Stopped', '$stopped', context.cs.onSurfaceVariant),
          stat(
            'Errored',
            '$errored',
            errored > 0
                ? Theme.of(context).colorScheme.error
                : context.cs.onSurfaceVariant,
          ),
          stat(
            'CPU',
            Pm2Format.cpu(cpu),
            Theme.of(context).colorScheme.primary,
          ),
          stat(
            'Memory',
            Pm2Format.bytes(memory),
            Theme.of(context).colorScheme.secondary,
          ),
        ],
      ),
    );
  }
}

class _ProcessCard extends ConsumerWidget {
  final Pm2Process process;

  const _ProcessCard({required this.process});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = process;
    final online = p.status == 'online';
    final target = '${p.pmId}';

    Widget metric(IconData icon, String value, {Color? color}) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color ?? context.cs.onSurfaceVariant),
        const Gap(4),
        Text(value, style: TextStyle(fontSize: 12, color: color)),
      ],
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 6),
        glowColor: p.status == 'errored'
            ? Theme.of(context).colorScheme.error
            : null,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => Pm2ProcessScreen(pmId: p.pmId, name: p.name),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Pm2StatusDot(status: p.status),
                const Gap(10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        [
                          '#${p.pmId}',
                          p.execMode.isEmpty ? 'fork' : p.execMode,
                          if (online && p.pid > 0) 'pid ${p.pid}',
                          if (p.namespace.isNotEmpty &&
                              p.namespace != 'default')
                            p.namespace,
                          if (p.watch) 'watching',
                        ].join(' · '),
                        style: TextStyle(
                          fontSize: 11.5,
                          color: context.cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(8),
                Pm2StatusBadge(status: p.status),
                const Gap(8),
              ],
            ),
            const Gap(12),
            Wrap(
              spacing: 16,
              runSpacing: 6,
              children: [
                metric(Icons.memory, Pm2Format.cpu(p.cpu)),
                metric(Icons.storage, Pm2Format.bytes(p.memory.toInt())),
                metric(
                  Icons.timer_outlined,
                  online ? Pm2Format.uptime(p.startedAt.toInt()) : '-',
                ),
                metric(
                  Icons.replay,
                  '${p.restarts}${p.unstableRestarts > 0 ? ' (${p.unstableRestarts} unstable)' : ''}',
                  color: p.unstableRestarts > 0 ? context.ac.warning : null,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (online) ...[
                  IconButton(
                    tooltip: 'Restart',
                    icon: Icon(
                      Icons.restart_alt,
                      color: context.ac.warning,
                    ),
                    onPressed: () => pm2Control(
                      context,
                      ref,
                      Pm2Action.PM2_ACTION_RESTART,
                      target,
                      progress: 'Restarting ${p.name}…',
                      success: '${p.name} restarted',
                    ),
                  ),
                  if (p.execMode == 'cluster')
                    IconButton(
                      tooltip: 'Reload (zero downtime)',
                      icon: Icon(
                        Icons.autorenew,
                        color: context.ac.success,
                      ),
                      onPressed: () => pm2Control(
                        context,
                        ref,
                        Pm2Action.PM2_ACTION_RELOAD,
                        target,
                        progress: 'Reloading ${p.name}…',
                        success: '${p.name} reloaded',
                      ),
                    ),
                  IconButton(
                    tooltip: 'Stop',
                    icon: Icon(
                      Icons.stop,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    onPressed: () => pm2Control(
                      context,
                      ref,
                      Pm2Action.PM2_ACTION_STOP,
                      target,
                      progress: 'Stopping ${p.name}…',
                      success: '${p.name} stopped',
                    ),
                  ),
                ] else ...[
                  IconButton(
                    tooltip: 'Start',
                    icon: Icon(
                      Icons.play_arrow,
                      color: context.ac.success,
                    ),
                    onPressed: () => pm2Control(
                      context,
                      ref,
                      Pm2Action.PM2_ACTION_START,
                      target,
                      progress: 'Starting ${p.name}…',
                      success: '${p.name} started',
                    ),
                  ),
                  IconButton(
                    tooltip: 'Delete',
                    icon: Icon(
                      Icons.delete_outline,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    onPressed: () async {
                      if (await confirmPm2(
                        context,
                        title: 'Delete ${p.name}?',
                        message:
                            'The process is removed from PM2. Its log files stay on disk.',
                        confirmLabel: 'Delete',
                        destructive: true,
                      )) {
                        if (!context.mounted) return;
                        await pm2Control(
                          context,
                          ref,
                          Pm2Action.PM2_ACTION_DELETE,
                          target,
                          progress: 'Deleting ${p.name}…',
                          success: '${p.name} deleted',
                        );
                      }
                    },
                  ),
                ],
                IconButton(
                  tooltip: 'Logs',
                  icon: Icon(
                    Icons.article_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Pm2LogsScreen(
                        target: target,
                        title: '${p.name} logs',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== Modules tab ====================

/// Parsed ~/.pm2/module_conf.json (module or "pm2" -> key -> value)
Map<String, Map<String, String>> _parseModuleConfig(String json) {
  final result = <String, Map<String, String>>{};
  if (json.trim().isEmpty) return result;
  try {
    final decoded = jsonDecode(json);
    if (decoded is! Map) return result;
    decoded.forEach((key, value) {
      if (key == 'module-db-v2' || value is! Map) return;
      result['$key'] = {
        for (final e in value.entries)
          '${e.key}': e.value is String
              ? e.value as String
              : jsonEncode(e.value),
      };
    });
  } catch (_) {}
  return result;
}

class _ModulesTab extends ConsumerWidget {
  final Pm2Info info;

  const _ModulesTab({required this.info});

  static const _suggestions = ['pm2-logrotate', 'pm2-server-monit'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final processesAsync = ref.watch(pm2ProcessesProvider);
    final config = _parseModuleConfig(info.moduleConfigJson);

    return processesAsync.when(
      skipLoadingOnRefresh: true,
      skipLoadingOnReload: true,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _Pm2ErrorView(error: Pm2Exception.from(e)),
      data: (all) {
        final modules = all.where((p) => p.isModule).toList();
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Pm2SectionTitle(
                    icon: Icons.add_box_outlined,
                    title: 'Install a module',
                  ),
                  Text(
                    'Modules extend PM2 and run like processes. They are installed from npm or a git URL.',
                    style: TextStyle(
                      color: context.cs.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  const Gap(12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final s in _suggestions)
                        if (!modules.any((m) => m.name == s))
                          ActionChip(
                            avatar: const Icon(Icons.download, size: 16),
                            label: Text(s),
                            onPressed: () => _install(context, ref, s),
                          ),
                      ActionChip(
                        avatar: const Icon(Icons.edit, size: 16),
                        label: const Text('Other module…'),
                        onPressed: () async {
                          final name = await promptPm2Text(
                            context,
                            title: 'Install module',
                            label: 'Module name or git URL',
                            hint: 'pm2-logrotate',
                            confirmLabel: 'Install',
                          );
                          if (name != null &&
                              name.isNotEmpty &&
                              context.mounted) {
                            await _install(context, ref, name);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Gap(16),
            if (modules.isEmpty)
              Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    'No modules installed',
                    style: TextStyle(color: context.cs.onSurfaceVariant),
                  ),
                ),
              )
            else
              for (final m in modules)
                _ModuleCard(module: m, config: config[m.name] ?? const {}),
          ],
        );
      },
    );
  }

  Future<void> _install(BuildContext context, WidgetRef ref, String name) {
    return runPm2Operation(
      context,
      ref,
      title: 'Installing $name',
      request: Pm2OperationRequest()
        ..operation = Pm2Operation.PM2_OP_INSTALL_MODULE
        ..name = name,
    );
  }
}

class _ModuleCard extends ConsumerWidget {
  final Pm2Process module;
  final Map<String, String> config;

  const _ModuleCard({required this.module, required this.config});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final m = module;
    final online = m.status == 'online';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Pm2StatusDot(status: m.status),
                const Gap(10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        [
                          if (m.version.isNotEmpty && m.version != 'N/A')
                            'v${m.version}',
                          Pm2Format.cpu(m.cpu),
                          Pm2Format.bytes(m.memory.toInt()),
                          if (online)
                            'up ${Pm2Format.uptime(m.startedAt.toInt())}',
                        ].join(' · '),
                        style: TextStyle(
                          fontSize: 11.5,
                          color: context.cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Pm2StatusBadge(status: m.status),
                const Gap(8),
              ],
            ),
            if (config.isNotEmpty) ...[
              const Gap(10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final e in config.entries.take(6))
                    Chip(
                      visualDensity: VisualDensity.compact,
                      label: Text(
                        '${e.key}: ${e.value}',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  if (config.length > 6)
                    Chip(label: Text('+${config.length - 6} more')),
                ],
              ),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  tooltip: 'Configure',
                  icon: const Icon(Icons.settings),
                  onPressed: () => showPm2ConfigSheet(
                    context,
                    ref,
                    scope: m.name,
                    values: config,
                  ),
                ),
                IconButton(
                  tooltip: 'Logs',
                  icon: const Icon(Icons.article_outlined),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Pm2LogsScreen(
                        target: '${m.pmId}',
                        title: '${m.name} logs',
                      ),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: online ? 'Restart' : 'Start',
                  icon: Icon(
                    online ? Icons.restart_alt : Icons.play_arrow,
                    color: context.ac.warning,
                  ),
                  onPressed: () => pm2Control(
                    context,
                    ref,
                    online
                        ? Pm2Action.PM2_ACTION_RESTART
                        : Pm2Action.PM2_ACTION_START,
                    m.name,
                    progress:
                        '${online ? 'Restarting' : 'Starting'} ${m.name}…',
                    success: '${m.name} ${online ? 'restarted' : 'started'}',
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    switch (value) {
                      case 'stop':
                        await pm2Control(
                          context,
                          ref,
                          Pm2Action.PM2_ACTION_STOP,
                          m.name,
                          progress: 'Stopping ${m.name}…',
                          success: '${m.name} stopped',
                        );
                      case 'update':
                        await runPm2Operation(
                          context,
                          ref,
                          title: 'Updating ${m.name}',
                          request: Pm2OperationRequest()
                            ..operation = Pm2Operation.PM2_OP_UPDATE_MODULE
                            ..name = m.name,
                        );
                      case 'uninstall':
                        if (await confirmPm2(
                          context,
                          title: 'Uninstall ${m.name}?',
                          message: 'The module is stopped and removed.',
                          confirmLabel: 'Uninstall',
                          destructive: true,
                        )) {
                          if (!context.mounted) return;
                          await runPm2Operation(
                            context,
                            ref,
                            title: 'Uninstalling ${m.name}',
                            request: Pm2OperationRequest()
                              ..operation = Pm2Operation.PM2_OP_UNINSTALL_MODULE
                              ..name = m.name,
                          );
                        }
                    }
                  },
                  itemBuilder: (_) => [
                    if (online)
                      const PopupMenuItem(value: 'stop', child: Text('Stop')),
                    const PopupMenuItem(value: 'update', child: Text('Update')),
                    const PopupMenuItem(
                      value: 'uninstall',
                      child: Text('Uninstall'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Edits the `pm2 set <scope>:<key> <value>` configuration of a module or
/// of PM2 itself (scope "pm2").
Future<void> showPm2ConfigSheet(
  BuildContext context,
  WidgetRef ref, {
  required String scope,
  required Map<String, String> values,
}) {
  Future<void> setValue(String key, String value) => runPm2Operation(
    context,
    ref,
    title: 'pm2 set $scope:$key',
    request: Pm2OperationRequest()
      ..operation = Pm2Operation.PM2_OP_SET_CONFIG
      ..name = '$scope:$key'
      ..value = value,
  );

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$scope configuration',
              style: Theme.of(sheetContext).textTheme.titleMedium,
            ),
            const Gap(4),
            Text(
              'Values are stored with pm2 set $scope:<key> <value>.',
              style: TextStyle(
                color: context.cs.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
            const Gap(8),
            if (values.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No values set',
                  style: TextStyle(color: context.cs.onSurfaceVariant),
                ),
              ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final e in values.entries)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        e.key,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13,
                        ),
                      ),
                      subtitle: Text(e.value),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () async {
                              final value = await promptPm2Text(
                                sheetContext,
                                title: e.key,
                                label: 'Value',
                                initial: e.value,
                                confirmLabel: 'Save',
                              );
                              if (value == null || !sheetContext.mounted) {
                                return;
                              }
                              Navigator.pop(sheetContext);
                              await setValue(e.key, value);
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: Theme.of(sheetContext).colorScheme.error,
                            ),
                            onPressed: () async {
                              Navigator.pop(sheetContext);
                              await runPm2Operation(
                                context,
                                ref,
                                title: 'pm2 unset $scope:${e.key}',
                                request: Pm2OperationRequest()
                                  ..operation = Pm2Operation.PM2_OP_UNSET_CONFIG
                                  ..name = '$scope:${e.key}',
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const Gap(8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add value'),
                onPressed: () async {
                  final key = await promptPm2Text(
                    sheetContext,
                    title: 'New key',
                    label: 'Key',
                    hint: 'max_size',
                  );
                  if (key == null || key.isEmpty || !sheetContext.mounted) {
                    return;
                  }
                  final value = await promptPm2Text(
                    sheetContext,
                    title: key,
                    label: 'Value',
                    hint: '10M',
                  );
                  if (value == null || !sheetContext.mounted) return;
                  Navigator.pop(sheetContext);
                  await setValue(key, value);
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ==================== Manage tab ====================

class _ManageTab extends ConsumerWidget {
  final Pm2Info info;

  const _ManageTab({required this.info});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pm2Settings =
        _parseModuleConfig(info.moduleConfigJson)['pm2'] ?? const {};

    Future<bool> op(
      String title,
      Pm2Operation operation, {
      bool force = false,
      String value = '',
    }) {
      return runPm2Operation(
        context,
        ref,
        title: title,
        request: Pm2OperationRequest()
          ..operation = operation
          ..force = force
          ..value = value,
      );
    }

    Widget action(
      IconData icon,
      String title,
      String subtitle,
      VoidCallback onTap, {
      Color? color,
    }) => ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: color ?? Theme.of(context).colorScheme.primary,
      ),
      title: Text(title, style: color != null ? TextStyle(color: color) : null),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: context.cs.onSurfaceVariant),
      ),
      onTap: onTap,
    );

    final danger = Theme.of(context).colorScheme.error;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Pm2SectionTitle(icon: Icons.info_outline, title: 'PM2'),
              Pm2InfoRow(label: 'Version', value: info.version),
              Pm2InfoRow(label: 'Node.js', value: info.nodeVersion),
              Pm2InfoRow(label: 'User', value: info.user),
              Pm2InfoRow(
                label: 'Daemon',
                value: info.daemonRunning
                    ? 'running (pid ${info.daemonPid})'
                    : 'not running',
              ),
              Pm2InfoRow(
                label: 'PM2 home',
                value: info.pm2Home,
                monospace: true,
              ),
              Pm2InfoRow(label: 'Binary', value: info.pm2Path, monospace: true),
            ],
          ),
        ),
        const Gap(16),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Pm2SectionTitle(
                icon: Icons.power_settings_new,
                title: 'Startup on boot',
                trailing: _StatusPill(
                  label: info.startupEnabled ? 'Enabled' : 'Disabled',
                  color: info.startupEnabled
                      ? context.ac.success
                      : context.cs.onSurfaceVariant,
                ),
              ),
              Text(
                info.startupEnabled
                    ? 'The ${info.startupService} service resurrects the saved process list when the Pi boots.'
                    : 'Install a system service that starts PM2 and your saved processes when the Pi boots.',
                style: TextStyle(
                  color: context.cs.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              if (!info.agentIsRoot)
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'The agent is not running as root, so PM2 can only print the command to run with sudo.',
                    style: TextStyle(
                      color: context.ac.warning,
                      fontSize: 12,
                    ),
                  ),
                ),
              const Gap(12),
              Row(
                children: [
                  if (!info.startupEnabled)
                    FilledButton.icon(
                      icon: const Icon(Icons.check),
                      label: const Text('Enable startup'),
                      onPressed: () =>
                          op('pm2 startup', Pm2Operation.PM2_OP_STARTUP),
                    )
                  else ...[
                    OutlinedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Regenerate'),
                      onPressed: () =>
                          op('pm2 startup', Pm2Operation.PM2_OP_STARTUP),
                    ),
                    const Gap(8),
                    TextButton.icon(
                      icon: Icon(Icons.close, color: danger),
                      label: Text('Disable', style: TextStyle(color: danger)),
                      onPressed: () async {
                        if (await confirmPm2(
                          context,
                          title: 'Disable startup?',
                          message:
                              'PM2 and your processes will no longer start automatically when the Pi boots.',
                          confirmLabel: 'Disable',
                          destructive: true,
                        )) {
                          await op(
                            'pm2 unstartup',
                            Pm2Operation.PM2_OP_UNSTARTUP,
                          );
                        }
                      },
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        const Gap(16),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Pm2SectionTitle(
                icon: Icons.save_outlined,
                title: 'Process list',
              ),
              Text(
                info.dumpExists
                    ? '${info.dumpProcessCount} process(es) saved for resurrect.'
                    : 'Nothing saved yet.',
                style: TextStyle(
                  color: context.cs.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              action(
                Icons.save,
                'Save',
                'pm2 save: remember the current processes',
                () async {
                  final force = await _saveNeedsForce(ref);
                  if (context.mounted) {
                    await op(
                      'pm2 save',
                      Pm2Operation.PM2_OP_SAVE,
                      force: force,
                    );
                  }
                },
              ),
              action(
                Icons.history,
                'Resurrect',
                'pm2 resurrect: start the saved processes',
                () {
                  op('pm2 resurrect', Pm2Operation.PM2_OP_RESURRECT);
                },
              ),
              action(
                Icons.layers_clear,
                'Clear saved list',
                'pm2 cleardump: empty the dump file',
                () async {
                  if (await confirmPm2(
                    context,
                    title: 'Clear saved list?',
                    message:
                        'The saved process list is emptied. Running processes are not affected, but they will not come back after a reboot until you save again.',
                    confirmLabel: 'Clear',
                    destructive: true,
                  )) {
                    await op('pm2 cleardump', Pm2Operation.PM2_OP_CLEAR_DUMP);
                  }
                },
                color: danger,
              ),
            ],
          ),
        ),
        const Gap(16),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Pm2SectionTitle(
                icon: Icons.description_outlined,
                title: 'Ecosystem & deploy',
              ),
              action(
                Icons.note_add_outlined,
                'Generate ecosystem file',
                'pm2 init: create ecosystem.config.js',
                () {
                  showPm2EcosystemDialog(context, ref, defaultDir: info.home);
                },
              ),
              action(
                Icons.cloud_upload_outlined,
                'Deploy',
                'pm2 deploy: setup, update, revert and more',
                () async {
                  final request = await showDialog<Pm2OperationRequest>(
                    context: context,
                    builder: (_) => _DeployDialog(
                      defaultFile: '${info.home}/ecosystem.config.js',
                    ),
                  );
                  if (request == null || !context.mounted) return;
                  await runPm2Operation(
                    context,
                    ref,
                    title:
                        'pm2 deploy ${request.deployEnv} ${request.deployCommand}',
                    request: request,
                  );
                },
              ),
            ],
          ),
        ),
        const Gap(16),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Pm2SectionTitle(
                icon: Icons.receipt_long_outlined,
                title: 'Logs',
              ),
              action(
                Icons.article_outlined,
                'Daemon log',
                'Live output of ~/.pm2/pm2.log',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const Pm2LogsScreen(
                        target: 'all',
                        title: 'PM2 daemon log',
                        daemonOnly: true,
                      ),
                    ),
                  );
                },
              ),
              action(
                Icons.cleaning_services,
                'Flush all logs',
                'pm2 flush: empty every log file',
                () async {
                  if (await confirmPm2(
                    context,
                    title: 'Flush all logs?',
                    message: 'All PM2 log files are emptied.',
                    confirmLabel: 'Flush',
                    destructive: true,
                  )) {
                    await op('pm2 flush', Pm2Operation.PM2_OP_FLUSH_ALL);
                  }
                },
              ),
              action(
                Icons.sync,
                'Reload logs',
                'pm2 reloadLogs: reopen log files after rotation',
                () {
                  op('pm2 reloadLogs', Pm2Operation.PM2_OP_RELOAD_LOGS);
                },
              ),
              action(
                Icons.rotate_right,
                'Log rotation',
                'pm2-logrotate module or system logrotate',
                () {
                  _showLogRotation(context, ref);
                },
              ),
            ],
          ),
        ),
        const Gap(16),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Pm2SectionTitle(
                icon: Icons.settings_suggest_outlined,
                title: 'Daemon',
              ),
              action(
                Icons.network_ping,
                'Ping',
                'pm2 ping: check the daemon (starts it if needed)',
                () {
                  op('pm2 ping', Pm2Operation.PM2_OP_PING);
                },
              ),
              action(
                Icons.update,
                'Update in-memory PM2',
                'pm2 update: reload the daemon after an upgrade',
                () {
                  op('pm2 update', Pm2Operation.PM2_OP_UPDATE);
                },
              ),
              action(
                Icons.upgrade,
                'Upgrade PM2',
                'npm install -g pm2@latest, then pm2 update',
                () async {
                  if (await confirmPm2(
                    context,
                    title: 'Upgrade PM2?',
                    message:
                        'Installs the latest PM2 with npm and hands your running processes over to the new daemon.',
                    confirmLabel: 'Upgrade',
                  )) {
                    await op('Upgrading PM2', Pm2Operation.PM2_OP_INSTALL_PM2);
                  }
                },
              ),
              action(
                Icons.power_off,
                'Kill daemon',
                'pm2 kill: stop PM2 and all processes',
                () async {
                  if (await confirmPm2(
                    context,
                    title: 'Kill the PM2 daemon?',
                    message:
                        'PM2 and every process it manages are stopped. Save first if you want to resurrect them.',
                    confirmLabel: 'Kill',
                    destructive: true,
                  )) {
                    await op('pm2 kill', Pm2Operation.PM2_OP_KILL);
                  }
                },
                color: danger,
              ),
            ],
          ),
        ),
        const Gap(16),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Pm2SectionTitle(
                icon: Icons.tune,
                title: 'PM2 settings',
                trailing: IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => showPm2ConfigSheet(
                    context,
                    ref,
                    scope: 'pm2',
                    values: pm2Settings,
                  ),
                ),
              ),
              if (pm2Settings.isEmpty)
                Text(
                  'No settings changed. For example pm2:sysmonit false hides the host metrics line.',
                  style: TextStyle(color: context.cs.onSurfaceVariant, fontSize: 12),
                )
              else
                for (final e in pm2Settings.entries)
                  Pm2InfoRow(label: e.key, value: e.value),
            ],
          ),
        ),
        const Gap(16),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Pm2SectionTitle(
                icon: Icons.bug_report_outlined,
                title: 'Diagnostics',
              ),
              action(
                Icons.summarize_outlined,
                'Report',
                'pm2 report: full diagnostic report',
                () {
                  op('pm2 report', Pm2Operation.PM2_OP_REPORT);
                },
              ),
              action(
                Icons.speed,
                'Profile CPU',
                'pm2 profile:cpu: profile the PM2 daemon',
                () {
                  _profile(
                    context,
                    ref,
                    Pm2Operation.PM2_OP_PROFILE_CPU,
                    'CPU',
                  );
                },
              ),
              action(
                Icons.memory,
                'Profile memory',
                'pm2 profile:mem: sample the PM2 daemon heap',
                () {
                  _profile(
                    context,
                    ref,
                    Pm2Operation.PM2_OP_PROFILE_MEM,
                    'memory',
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// pm2 save refuses an empty list unless forced
  Future<bool> _saveNeedsForce(WidgetRef ref) async {
    final processes = ref.read(pm2ProcessesProvider).valueOrNull;
    return processes != null && processes.isEmpty;
  }

  Future<void> _profile(
    BuildContext context,
    WidgetRef ref,
    Pm2Operation operation,
    String what,
  ) async {
    final seconds = await promptPm2Text(
      context,
      title: 'Profile $what',
      label: 'Duration in seconds',
      initial: '10',
      helper:
          'The profile is written to ${info.home} and can be opened in Chrome DevTools.',
      keyboardType: TextInputType.number,
      confirmLabel: 'Start',
    );
    final value = int.tryParse(seconds ?? '');
    if (value == null || value <= 0 || !context.mounted) return;
    await runPm2Operation(
      context,
      ref,
      title: 'Profiling $what for ${value}s',
      request: Pm2OperationRequest()
        ..operation = operation
        ..value = '${value * 1000}',
    );
  }

  void _showLogRotation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log rotation'),
        content: const Text(
          'pm2-logrotate is a PM2 module that rotates logs by size or schedule and is the usual choice.\n\n'
          'Alternatively, write a system logrotate config to /etc/logrotate.d (weekly, 12 rotations).',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              runPm2Operation(
                context,
                ref,
                title: 'System logrotate config',
                request: Pm2OperationRequest()
                  ..operation = Pm2Operation.PM2_OP_LOGROTATE,
              );
            },
            child: const Text('System logrotate'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              runPm2Operation(
                context,
                ref,
                title: 'Installing pm2-logrotate',
                request: Pm2OperationRequest()
                  ..operation = Pm2Operation.PM2_OP_INSTALL_MODULE
                  ..name = 'pm2-logrotate',
              );
            },
            child: const Text('Install pm2-logrotate'),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ==================== Ecosystem & deploy ====================

/// Collects the options of `pm2 deploy` and pops with the request.
class _DeployDialog extends StatefulWidget {
  final String defaultFile;

  const _DeployDialog({required this.defaultFile});

  @override
  State<_DeployDialog> createState() => _DeployDialogState();
}

class _DeployDialogState extends State<_DeployDialog> {
  late final TextEditingController _file = TextEditingController(
    text: widget.defaultFile,
  );
  final TextEditingController _env = TextEditingController(text: 'production');
  final TextEditingController _args = TextEditingController();
  String _command = 'update';
  bool _force = false;

  static const _commands = {
    'update': 'Deploy latest (update)',
    'setup': 'Setup remote hosts',
    'revert': 'Revert to previous deploy',
    'curr': 'Show current commit',
    'prev': 'Show previous commit',
    'list': 'List previous deploys',
    'exec': 'Run a command on the hosts',
    'ref': 'Deploy a specific ref',
  };

  @override
  void dispose() {
    _file.dispose();
    _env.dispose();
    _args.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final argsLabel = switch (_command) {
      'revert' => 'Number of deploys to go back (optional)',
      'exec' => 'Command',
      'ref' => 'Ref, e.g. origin/main or a commit',
      _ => null,
    };

    return AlertDialog(
      title: const Text('pm2 deploy'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _file,
              decoration: const InputDecoration(labelText: 'Ecosystem file'),
            ),
            TextField(
              controller: _env,
              decoration: const InputDecoration(
                labelText: 'Environment',
                helperText: 'A key of the "deploy" section',
              ),
            ),
            const Gap(8),
            DropdownButtonFormField<String>(
              initialValue: _command,
              decoration: const InputDecoration(labelText: 'Command'),
              items: [
                for (final e in _commands.entries)
                  DropdownMenuItem(value: e.key, child: Text(e.value)),
              ],
              onChanged: (v) => setState(() => _command = v ?? 'update'),
            ),
            if (argsLabel != null)
              TextField(
                controller: _args,
                decoration: InputDecoration(labelText: argsLabel),
              ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Force (--force)'),
              subtitle: const Text('Deploy even with local changes'),
              value: _force,
              onChanged: (v) => setState(() => _force = v),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Edit ecosystem file'),
                onPressed: () => openPm2FileEditor(context, _file.text.trim()),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(
            context,
            Pm2OperationRequest()
              ..operation = Pm2Operation.PM2_OP_DEPLOY
              ..configFile = _file.text.trim()
              ..deployEnv = _env.text.trim()
              ..deployCommand = _command
              ..deployArgs = _args.text.trim()
              ..force = _force,
          ),
          child: const Text('Run'),
        ),
      ],
    );
  }
}

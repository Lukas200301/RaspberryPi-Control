import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../../generated/pi_control.pb.dart';
import '../../services/docker_service.dart';
import '../../theme/app_theme.dart';
import '../../ui/ui.dart';
import '../docker_screen.dart';
import '../journal_screen.dart';

/// One container: live usage, configuration, logs and actions
class ContainerScreen extends ConsumerStatefulWidget {
  final ContainerInfo container;

  const ContainerScreen({super.key, required this.container});

  @override
  ConsumerState<ContainerScreen> createState() => _ContainerScreenState();
}

class _ContainerScreenState extends ConsumerState<ContainerScreen> {
  bool _busy = false;
  bool _showValues = false;

  String get _id => widget.container.id;

  Future<void> _run(String done, Future<void> Function(DockerService s) action, {bool leave = false}) async {
    setState(() => _busy = true);
    try {
      await action(ref.read(dockerServiceProvider));
      if (!mounted) return;
      showToast(context, done, tone: Tone.success);
      ref
        ..invalidate(containerDetailsProvider(_id))
        ..invalidate(containerListProvider)
        ..invalidate(dockerInfoProvider);
      if (leave) Navigator.pop(context);
    } catch (e) {
      if (mounted) showToast(context, describeError(e), tone: Tone.danger);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _remove(String name, bool running) async {
    var volumes = false;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialog) => StatefulBuilder(
        builder: (dialog, setDialog) => AlertDialog(
          icon: const Icon(Icons.delete_forever_outlined),
          title: Text('Remove $name?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(running
                  ? 'The container is running and will be stopped first. Its writable layer is deleted.'
                  : 'The container and its writable layer are deleted. The image stays.'),
              const Gap(Insets.sm),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: volumes,
                onChanged: (v) => setDialog(() => volumes = v ?? false),
                title: const Text('Also delete its anonymous volumes'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialog, false), child: const Text('Cancel')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: dialog.cs.error, foregroundColor: dialog.cs.onError),
              onPressed: () => Navigator.pop(dialog, true),
              child: const Text('Remove'),
            ),
          ],
        ),
      ),
    );
    if (ok != true) return;
    await _run(
      'Removed $name',
      (s) => s.containerAction(_id, ContainerOp.CONTAINER_REMOVE, force: running, removeVolumes: volumes),
      leave: true,
    );
  }

  void _logs(String name) => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => JournalScreen.custom(
        title: name,
        kind: 'Container logs',
        open: (tail) => ref.read(dockerServiceProvider).getContainerLogs(_id, follow: true, tail: tail),
      ),
    ),
  );

  String _date(int seconds) =>
      seconds <= 0 ? '—' : DateFormat.yMMMd().add_Hms().format(DateTime.fromMillisecondsSinceEpoch(seconds * 1000));

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(containerDetailsProvider(_id));
    final d = async.valueOrNull;
    final info = d?.info;
    final name = info == null ? containerName(widget.container) : containerName(info);
    final state = info?.state ?? widget.container.state;
    final running = state == 'running';
    final paused = state == 'paused';
    final tone = containerTone(state, health: d?.health ?? '');

    return PageScaffold(
      title: name,
      subtitle: info?.image ?? widget.container.image,
      actions: [
        IconButton(tooltip: 'Logs', icon: const Icon(Icons.receipt_long_outlined), onPressed: () => _logs(name)),
        IconButton(
          tooltip: 'Refresh',
          icon: const Icon(Icons.refresh),
          onPressed: () => ref.invalidate(containerDetailsProvider(_id)),
        ),
      ],
      body: AsyncView(
        value: async,
        onRetry: () => ref.invalidate(containerDetailsProvider(_id)),
        loadingMessage: 'Inspecting container…',
        data: (d) => PageList(
          onRefresh: () async => ref.invalidate(containerDetailsProvider(_id)),
          children: [
            AppCard(
              variant: CardVariant.raised,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: Insets.xs,
                    runSpacing: Insets.xs,
                    children: [
                      StatusPill(state, tone: tone, dot: true),
                      if (d.health.isNotEmpty)
                        StatusPill(d.health, icon: Icons.monitor_heart_outlined, tone: containerTone(state, health: d.health)),
                      if (d.info.composeProject.isNotEmpty)
                        StatusPill('${d.info.composeProject} / ${d.info.composeService}', icon: Icons.layers_outlined),
                      if (d.restartCount > 0) StatusPill('${d.restartCount} restarts', icon: Icons.replay, tone: Tone.warning),
                      if (!running && d.finishedAt > 0)
                        StatusPill('exit code ${d.exitCode}', tone: d.exitCode == 0 ? Tone.neutral : Tone.danger),
                    ],
                  ),
                  const Gap(Insets.lg),
                  if (_busy)
                    const LinearProgressIndicator()
                  else
                    Row(
                      children: [
                        Expanded(
                          child: running || paused
                              ? FilledButton.tonalIcon(
                                  onPressed: () => _run('Stopped $name', (s) => s.stopContainer(_id)),
                                  icon: const Icon(Icons.stop),
                                  label: const Text('Stop'),
                                )
                              : FilledButton.icon(
                                  onPressed: () => _run('Started $name', (s) => s.startContainer(_id)),
                                  icon: const Icon(Icons.play_arrow),
                                  label: const Text('Start'),
                                ),
                        ),
                        const Gap(Insets.sm),
                        Expanded(
                          child: FilledButton.tonalIcon(
                            onPressed: () => _run('Restarted $name', (s) => s.restartContainer(_id)),
                            icon: const Icon(Icons.restart_alt),
                            label: const Text('Restart'),
                          ),
                        ),
                        if (running || paused) ...[
                          const Gap(Insets.sm),
                          IconButton.filledTonal(
                            tooltip: paused ? 'Resume' : 'Pause',
                            onPressed: () => _run(
                              paused ? 'Resumed $name' : 'Paused $name',
                              (s) => s.containerAction(
                                _id,
                                paused ? ContainerOp.CONTAINER_UNPAUSE : ContainerOp.CONTAINER_PAUSE,
                              ),
                            ),
                            icon: Icon(paused ? Icons.play_arrow : Icons.pause),
                          ),
                        ],
                      ],
                    ),
                ],
              ),
            ),
            if (running) ...[const SectionHeader(title: 'Usage'), _StatsCard(id: _id)],
            const SectionHeader(title: 'Details'),
            AppCard(
              child: Column(
                children: [
                  InfoRow(
                    'ID',
                    d.info.id.length > 12 ? d.info.id.substring(0, 12) : d.info.id,
                    mono: true,
                    trailing: IconButton(
                      tooltip: 'Copy full ID',
                      icon: const Icon(Icons.copy, size: 18),
                      onPressed: () => Clipboard.setData(ClipboardData(text: d.info.id)),
                    ),
                  ),
                  InfoRow('Image', d.info.image),
                  InfoRow('Created', _date(d.info.created.toInt())),
                  InfoRow(running ? 'Started' : 'Last started', _date(d.startedAt.toInt())),
                  if (!running && d.finishedAt > 0) InfoRow('Stopped', _date(d.finishedAt.toInt())),
                  InfoRow('Restart policy', d.restartPolicy.isEmpty || d.restartPolicy == 'no' ? 'never' : d.restartPolicy),
                  if (d.hostname.isNotEmpty) InfoRow('Hostname', d.hostname, mono: true),
                  if (d.command.isNotEmpty) InfoRow('Command', d.command, mono: true),
                ],
              ),
            ),
            if (d.info.ports.isNotEmpty || d.networks.isNotEmpty) ...[
              const SectionHeader(title: 'Network'),
              TileGroup(
                children: [
                  for (final p in d.info.ports.toSet())
                    ListTile(
                      leading: const Icon(Icons.lan_outlined),
                      title: Text(p, style: AppTheme.mono()),
                      subtitle: const Text('host port : container port'),
                    ),
                  for (var i = 0; i < d.networks.length; i++)
                    ListTile(
                      leading: const Icon(Icons.hub_outlined),
                      title: Text(d.networks[i]),
                      subtitle: i < d.ipAddresses.length ? Text(d.ipAddresses[i], style: AppTheme.mono(size: 12)) : null,
                    ),
                ],
              ),
            ],
            if (d.mounts.isNotEmpty) ...[
              const SectionHeader(title: 'Storage'),
              TileGroup(
                children: [
                  for (final m in d.mounts)
                    ListTile(
                      leading: Icon(m.type == 'volume' ? Icons.inventory_2_outlined : Icons.folder_outlined),
                      title: Text(m.destination, style: AppTheme.mono(size: 13)),
                      subtitle: Text(
                        '${m.type == 'volume' && m.name.isNotEmpty ? 'volume ${m.name.length > 24 ? '${m.name.substring(0, 12)}…' : m.name}' : m.source}'
                        '${m.readWrite ? '' : ' · read-only'}',
                      ),
                    ),
                ],
              ),
            ],
            if (d.env.isNotEmpty) ...[
              SectionHeader(
                title: 'Environment',
                trailing: TextButton.icon(
                  onPressed: () => setState(() => _showValues = !_showValues),
                  icon: Icon(_showValues ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18),
                  label: Text(_showValues ? 'Hide values' : 'Show values'),
                ),
              ),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final e in d.env)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: e.split('=').first,
                                style: TextStyle(color: context.cs.primary),
                              ),
                              TextSpan(
                                // Values often hold passwords and tokens
                                text: '=${_showValues ? e.substring(e.indexOf('=') + 1) : '••••••'}',
                              ),
                            ],
                          ),
                          style: AppTheme.mono(size: 12),
                        ),
                      ),
                  ],
                ),
              ),
            ],
            const SectionHeader(title: 'Danger zone'),
            TileGroup(
              children: [
                if (running)
                  ActionTile(
                    icon: Icons.dangerous_outlined,
                    title: 'Kill',
                    subtitle: 'Stop immediately with SIGKILL',
                    destructive: true,
                    onTap: () async {
                      if (await showConfirmDialog(
                        context,
                        title: 'Kill $name?',
                        message: 'The processes get no chance to shut down cleanly.',
                        confirmLabel: 'Kill',
                        destructive: true,
                      )) {
                        await _run('Killed $name', (s) => s.containerAction(_id, ContainerOp.CONTAINER_KILL));
                      }
                    },
                  ),
                ActionTile(
                  icon: Icons.delete_forever_outlined,
                  title: 'Remove container',
                  subtitle: 'The image and named volumes stay',
                  destructive: true,
                  onTap: () => _remove(name, running || paused),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsCard extends ConsumerWidget {
  final String id;

  const _StatsCard({required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(containerStatsProvider(id));
    final s = stats.valueOrNull;
    if (s == null) {
      return AppCard(
        child: stats.hasError
            ? Text('Usage unavailable: ${describeError(stats.error!)}')
            : const LoadingState(message: 'Measuring…'),
      );
    }
    final mem = s.memoryLimit > 0 ? s.memoryUsage.toDouble() / s.memoryLimit.toDouble() : 0.0;
    return ResponsiveGrid(
      minItemWidth: 160,
      maxColumns: 4,
      children: [
        MetricTile(
          icon: Icons.speed,
          label: 'CPU',
          value: s.cpuPercent.toStringAsFixed(1),
          unit: '%',
          caption: '${s.pids} processes',
          tone: usageTone(s.cpuPercent),
        ),
        MetricTile(
          icon: Icons.memory,
          label: 'Memory',
          value: formatBytes(s.memoryUsage.toInt()),
          caption: s.memoryLimit > 0 ? 'of ${formatBytes(s.memoryLimit.toInt())}' : null,
          tone: usageTone(mem * 100, warn: 80),
          progress: mem,
        ),
        MetricTile(
          icon: Icons.swap_vert,
          label: 'Network',
          value: '↓ ${formatBytes(s.netRx.toInt())}',
          caption: '↑ ${formatBytes(s.netTx.toInt())} since start',
          tone: Tone.info,
        ),
        MetricTile(
          icon: Icons.storage,
          label: 'Disk I/O',
          value: '↓ ${formatBytes(s.blockRead.toInt())}',
          caption: '↑ ${formatBytes(s.blockWrite.toInt())} since start',
          tone: Tone.neutral,
        ),
      ],
    );
  }
}

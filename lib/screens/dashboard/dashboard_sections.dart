import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../generated/pi_control.pb.dart';
import '../../providers/app_providers.dart';
import '../../providers/settings_provider.dart';
import '../../providers/stats_history_provider.dart';
import '../../services/docker_service.dart';
import '../../services/pm2_service.dart';
import '../../services/session_actions.dart';
import '../../ui/ui.dart';
import '../tools/tool_registry.dart';

// ==================== Header ====================

class DeviceHeader extends ConsumerWidget {
  const DeviceHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final device = ref.watch(currentConnectionProvider);
    final stats = ref.watch(statsHistoryProvider).latest;
    final live = stats != null;

    return AppCard(
      variant: CardVariant.raised,
      padding: const EdgeInsets.fromLTRB(Insets.lg, Insets.lg, Insets.sm, Insets.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const IconBadge(Icons.developer_board, size: 52),
              const Gap(Insets.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device?.name ?? 'Not connected',
                      style: context.tt.headlineSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      device?.address ?? '',
                      style: context.tt.bodyMedium?.copyWith(color: context.cs.onSurfaceVariant),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Switch device',
                icon: const Icon(Icons.swap_horiz),
                onPressed: () => disconnectAndLeave(context, ref, confirm: false),
              ),
              PopupMenuButton<String>(
                tooltip: 'More',
                onSelected: (v) => v == 'disconnect'
                    ? disconnectAndLeave(context, ref)
                    : confirmPower(context, ref, v == 'reboot' ? PowerOp.POWER_REBOOT : PowerOp.POWER_SHUTDOWN),
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'reboot',
                    child: ListTile(leading: Icon(Icons.restart_alt), title: Text('Reboot')),
                  ),
                  PopupMenuItem(
                    value: 'shutdown',
                    child: ListTile(leading: Icon(Icons.power_settings_new), title: Text('Shut down')),
                  ),
                  PopupMenuItem(
                    value: 'disconnect',
                    child: ListTile(leading: Icon(Icons.link_off), title: Text('Disconnect')),
                  ),
                ],
              ),
            ],
          ),
          const Gap(Insets.md),
          Wrap(
            spacing: Insets.xs,
            runSpacing: Insets.xs,
            children: [
              StatusPill(live ? 'Live' : 'Waiting for data', tone: live ? Tone.success : Tone.neutral, dot: true),
              if (live) ...[
                StatusPill('Up ${formatDuration(Duration(seconds: stats.uptime.toInt()))}', icon: Icons.schedule),
                StatusPill(
                  'Load ${stats.load1min.toStringAsFixed(2)} · ${stats.load5min.toStringAsFixed(2)} · ${stats.load15min.toStringAsFixed(2)}',
                  icon: Icons.speed,
                ),
              ],
              if (device?.agentVersion != null) StatusPill('Agent ${device!.agentVersion}', icon: Icons.memory),
            ],
          ),
        ],
      ),
    );
  }
}

// ==================== Vitals ====================

class VitalsSection extends ConsumerWidget {
  const VitalsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final h = ref.watch(statsHistoryProvider);
    final settings = ref.watch(settingsProvider);
    final s = h.latest;
    final disk = ref.watch(diskInfoProvider).valueOrNull;
    final root = disk?.partitions.where((p) => p.mountPoint == '/').firstOrNull;

    final cpu = s?.cpuUsage ?? 0;
    final mem = h.memoryPercent;
    final temp = s?.cpuTemp ?? 0;
    final tempTone = temp >= settings.tempCritical
        ? Tone.danger
        : temp >= settings.tempWarning
        ? Tone.warning
        : Tone.success;

    return ResponsiveGrid(
      minItemWidth: 160,
      maxColumns: 4,
      children: [
        _GaugeCard(
          label: 'CPU',
          value: cpu / 100,
          center: '${cpu.toStringAsFixed(0)}%',
          caption: s == null ? '' : '${s.cpuPerCore.length} cores',
          tone: usageTone(cpu),
          onTap: () => toolById('stats')?.open(context),
        ),
        _GaugeCard(
          label: 'Memory',
          value: mem / 100,
          center: '${mem.toStringAsFixed(0)}%',
          caption: s == null ? '' : '${formatBytes(s.ramUsed.toInt())} of ${formatBytes(s.ramTotal.toInt())}',
          tone: usageTone(mem, warn: 80),
          onTap: () => toolById('processes')?.open(context),
        ),
        _GaugeCard(
          label: 'Temperature',
          value: temp <= 0 ? 0 : temp / (settings.tempCritical + 10),
          center: temp <= 0 ? 'n/a' : settings.formatTemperature(temp, digits: 0),
          caption: (s?.gpuTemp ?? 0) > 0 ? 'GPU ${settings.formatTemperature(s!.gpuTemp, digits: 0)}' : 'CPU',
          tone: temp <= 0 ? Tone.neutral : tempTone,
          onTap: () => toolById('stats')?.open(context),
        ),
        _GaugeCard(
          label: 'Disk',
          value: (root?.usagePercent ?? 0) / 100,
          center: root == null ? '–' : '${root.usagePercent.toStringAsFixed(0)}%',
          caption: root == null ? '' : '${formatBytes(root.freeBytes.toInt())} free',
          tone: usageTone(root?.usagePercent ?? 0, warn: 80),
        ),
      ],
    );
  }
}

class _GaugeCard extends StatelessWidget {
  final String label;
  final double value;
  final String center;
  final String caption;
  final Tone tone;
  final VoidCallback? onTap;

  const _GaugeCard({
    required this.label,
    required this.value,
    required this.center,
    required this.caption,
    required this.tone,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: Insets.lg, horizontal: Insets.sm),
      child: Column(
        children: [
          RingGauge(
            value: value,
            size: 92,
            stroke: 9,
            color: context.tone(tone),
            center: Text(
              center,
              style: context.tt.titleLarge?.copyWith(fontFeatures: tabularFigures, fontWeight: FontWeight.w700),
            ),
          ),
          const Gap(Insets.sm),
          Text(label, style: context.tt.titleSmall),
          Text(
            caption,
            style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ==================== Activity ====================

class ActivitySection extends ConsumerWidget {
  const ActivitySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final h = ref.watch(statsHistoryProvider);
    final s = h.latest;
    final series = context.ac.series;
    final capacity = ref.watch(settingsProvider.select((s) => s.statsHistory));

    return ResponsiveGrid(
      minItemWidth: 340,
      maxColumns: 2,
      children: [
        LineChartCard(
          title: 'CPU & memory',
          capacity: capacity,
          maxY: 100,
          series: [
            ChartSeries(
              label: 'CPU',
              color: series[0],
              values: h.cpu,
              current: '${(s?.cpuUsage ?? 0).toStringAsFixed(0)}%',
            ),
            ChartSeries(
              label: 'Memory',
              color: series[1],
              values: h.memory,
              current: '${h.memoryPercent.toStringAsFixed(0)}%',
            ),
          ],
          footer: s == null || s.cpuPerCore.isEmpty
              ? null
              : Row(
                  children: [
                    for (var i = 0; i < s.cpuPerCore.length; i++) ...[
                      if (i > 0) const Gap(3),
                      Expanded(
                        child: Tooltip(
                          message: 'Core $i: ${s.cpuPerCore[i].toStringAsFixed(0)}%',
                          child: UsageBar(
                            value: s.cpuPerCore[i] / 100,
                            height: 6,
                            color: context.tone(usageTone(s.cpuPerCore[i])),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
        ),
        LineChartCard(
          title: 'Network',
          capacity: capacity,
          series: [
            ChartSeries(
              label: 'Down',
              color: series[4],
              values: h.netDown,
              current: '${formatBytes(s?.netBytesRecv.toInt() ?? 0)}/s',
            ),
            ChartSeries(
              label: 'Up',
              color: series[2],
              values: h.netUp,
              current: '${formatBytes(s?.netBytesSent.toInt() ?? 0)}/s',
            ),
          ],
          footer: Text(
            'Disk  ↓ ${formatBytes(h.diskRead.isEmpty ? 0 : h.diskRead.last)}/s   ↑ ${formatBytes(h.diskWrite.isEmpty ? 0 : h.diskWrite.last)}/s',
            style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant, fontFeatures: tabularFigures),
          ),
        ),
      ],
    );
  }
}

class AppsSummary {
  final int? dockerRunning;
  final int? dockerTotal;
  final int? pm2Online;
  final int? pm2Errored;
  final int? pm2Total;

  const AppsSummary({this.dockerRunning, this.dockerTotal, this.pm2Online, this.pm2Errored, this.pm2Total});
}

final appsSummaryProvider = FutureProvider.autoDispose<AppsSummary>((ref) async {
  ref.watch(grpcSessionProvider);
  final timer = Timer(const Duration(seconds: 30), ref.invalidateSelf);
  ref.onDispose(timer.cancel);

  int? dockerRunning, dockerTotal, pm2Online, pm2Errored, pm2Total;
  await Future.wait([
    () async {
      try {
        final containers = await ref.read(dockerServiceProvider).listContainers(all: true);
        dockerTotal = containers.length;
        dockerRunning = containers.where((c) => c.state == 'running').length;
      } catch (_) {}
    }(),
    () async {
      try {
        final apps = (await ref.read(pm2ServiceProvider).listProcesses()).where((p) => !p.isModule).toList();
        pm2Total = apps.length;
        pm2Online = apps.where((p) => p.status == 'online').length;
        pm2Errored = apps.where((p) => p.status == 'errored').length;
      } catch (_) {}
    }(),
  ]);
  return AppsSummary(
    dockerRunning: dockerRunning,
    dockerTotal: dockerTotal,
    pm2Online: pm2Online,
    pm2Errored: pm2Errored,
    pm2Total: pm2Total,
  );
});

class AppsSection extends ConsumerWidget {
  const AppsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(appsSummaryProvider).valueOrNull;
    final docker = toolById('docker')!;
    final pm2 = toolById('pm2')!;

    Widget tile(ToolDef tool, String value, String caption, Tone tone) => AppCard(
      onTap: () => tool.open(context),
      padding: const EdgeInsets.all(Insets.md),
      child: Row(
        children: [
          IconBadge(tool.icon, color: tool.color, size: 44),
          const Gap(Insets.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tool.title, style: context.tt.titleSmall),
                Text(value, style: context.tt.titleLarge?.copyWith(fontFeatures: tabularFigures)),
                Text(caption, style: context.tt.bodySmall?.copyWith(color: context.tone(tone))),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: context.cs.onSurfaceVariant),
        ],
      ),
    );

    return ResponsiveGrid(
      minItemWidth: 260,
      maxColumns: 2,
      children: [
        if (summary?.dockerTotal == null)
          tile(docker, '–', summary == null ? 'Loading…' : 'Not available', Tone.neutral)
        else
          tile(
            docker,
            '${summary!.dockerRunning} / ${summary.dockerTotal}',
            'containers running',
            summary.dockerRunning == summary.dockerTotal ? Tone.success : Tone.warning,
          ),
        if (summary?.pm2Total == null)
          tile(pm2, '–', summary == null ? 'Loading…' : 'Not installed', Tone.neutral)
        else
          tile(
            pm2,
            '${summary!.pm2Online} / ${summary.pm2Total}',
            summary.pm2Errored! > 0 ? '${summary.pm2Errored} errored' : 'apps online',
            summary.pm2Errored! > 0
                ? Tone.danger
                : summary.pm2Online == summary.pm2Total
                ? Tone.success
                : Tone.warning,
          ),
      ],
    );
  }
}

// ==================== Pinned tools ====================

class PinnedToolsSection extends ConsumerWidget {
  const PinnedToolsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tools = [for (final id in ref.watch(pinnedToolsProvider)) ?toolById(id)];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = (constraints.maxWidth / 96).floor().clamp(3, 8);
        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: Insets.sm,
          crossAxisSpacing: Insets.sm,
          childAspectRatio: 0.95,
          children: [
            for (final t in tools)
              _ToolTile(icon: t.icon, label: t.title, color: t.color, onTap: () => t.open(context)),
          ],
        );
      },
    );
  }
}

class _ToolTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ToolTile({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(Insets.sm),
      borderRadius: Radii.lgAll,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconBadge(icon, color: color, size: 40),
          const Gap(Insets.sm),
          Text(
            label,
            style: context.tt.labelMedium,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ==================== Top processes ====================

class TopProcessesSection extends ConsumerWidget {
  const TopProcessesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(statsHistoryProvider).latest;
    final top = [...?s?.topProcesses]..sort((a, b) => b.cpuPercent.compareTo(a.cpuPercent));
    final shown = top.take(5).toList();

    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: Insets.sm),
      onTap: () => toolById('processes')?.open(context),
      child: shown.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(Insets.lg),
              child: Text(
                'Waiting for data…',
                style: context.tt.bodyMedium?.copyWith(color: context.cs.onSurfaceVariant),
              ),
            )
          : Column(children: [for (final p in shown) _ProcessRow(process: p)]),
    );
  }
}

class _ProcessRow extends StatelessWidget {
  final ProcessInfo process;

  const _ProcessRow({required this.process});

  @override
  Widget build(BuildContext context) {
    final p = process;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Insets.lg, vertical: Insets.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name, style: context.tt.titleSmall, overflow: TextOverflow.ellipsis),
                Text(
                  'PID ${p.pid} · ${p.username}',
                  style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${p.cpuPercent.toStringAsFixed(1)}% CPU',
                  style: context.tt.labelLarge?.copyWith(fontFeatures: tabularFigures),
                ),
                const Gap(Insets.xs),
                UsageBar(value: p.cpuPercent / 100, height: 4, color: context.tone(usageTone(p.cpuPercent))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== Storage ====================

class StorageSection extends ConsumerWidget {
  const StorageSection({super.key});

  static const _virtual = {'tmpfs', 'devtmpfs', 'squashfs', 'overlay', 'proc', 'sysfs', 'efivarfs'};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final disk = ref.watch(diskInfoProvider);
    return AppCard(
      child: AsyncView<DiskInfo>(
        value: disk,
        onRetry: () => ref.invalidate(diskInfoProvider),
        data: (info) {
          final seen = <String>{};
          final parts =
              info.partitions
                  .where((p) => !_virtual.contains(p.filesystem) && p.totalBytes.toInt() > 0)
                  .where((p) => seen.add('${p.device}|${p.totalBytes}'))
                  .toList()
                ..sort((a, b) => a.mountPoint.length.compareTo(b.mountPoint.length));
          if (parts.isEmpty) return const Text('No partitions');
          return Column(
            children: [
              for (var i = 0; i < parts.length && i < 5; i++) ...[
                if (i > 0) const Gap(Insets.lg),
                _PartitionRow(partition: parts[i]),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _PartitionRow extends StatelessWidget {
  final DiskPartition partition;

  const _PartitionRow({required this.partition});

  @override
  Widget build(BuildContext context) {
    final p = partition;
    final tone = usageTone(p.usagePercent, warn: 80);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.storage, size: 18, color: context.cs.onSurfaceVariant),
            const Gap(Insets.sm),
            Expanded(
              child: Text(p.mountPoint, style: context.tt.titleSmall, overflow: TextOverflow.ellipsis),
            ),
            Text(
              '${formatBytes(p.usedBytes.toInt())} / ${formatBytes(p.totalBytes.toInt())}',
              style: context.tt.labelMedium?.copyWith(color: context.cs.onSurfaceVariant, fontFeatures: tabularFigures),
            ),
          ],
        ),
        const Gap(Insets.sm),
        UsageBar(value: p.usagePercent / 100, color: context.tone(tone)),
        const Gap(Insets.xs),
        Text(
          '${p.device} · ${p.filesystem} · ${p.usagePercent.toStringAsFixed(0)}% used',
          style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant),
        ),
      ],
    );
  }
}

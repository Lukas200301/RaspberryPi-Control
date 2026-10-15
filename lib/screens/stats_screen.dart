import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../generated/pi_control.pb.dart';
import '../models/app_settings.dart';
import '../providers/app_providers.dart';
import '../providers/settings_provider.dart';
import '../providers/stats_history_provider.dart';
import '../ui/ui.dart';

/// Live system statistics with history charts
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final live = ref.watch(liveStatsProvider);
    final history = ref.watch(statsHistoryProvider);
    final s = history.latest ?? live.valueOrNull;

    return PageScaffold(
      title: 'System stats',
      subtitle: s == null ? null : 'Live · up ${formatDuration(Duration(seconds: s.uptime.toInt()))}',
      body: s == null
          ? live.hasError
                ? ErrorState(
                    title: 'Stats are not available',
                    error: live.error!,
                    onRetry: () => ref.invalidate(liveStatsProvider),
                  )
                : const LoadingState(message: 'Waiting for the agent…')
          : _StatsBody(stats: s, history: history),
    );
  }
}

class _StatsBody extends ConsumerWidget {
  final LiveStats stats;
  final StatsHistory history;

  const _StatsBody({required this.stats, required this.history});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final s = stats;
    final h = history;
    final series = context.ac.series;
    final cores = s.cpuPerCore.isEmpty ? 1 : s.cpuPerCore.length;
    final memPercent = h.memoryPercent;
    final swapPercent = s.swapTotal.toInt() > 0 ? s.swapUsed.toDouble() / s.swapTotal.toDouble() * 100 : 0.0;

    Tone tempTone(double c) => c >= settings.tempCritical
        ? Tone.danger
        : c >= settings.tempWarning
        ? Tone.warning
        : Tone.success;

    return PageList(
      onRefresh: () async => ref.invalidate(diskInfoProvider),
      children: [
        ResponsiveGrid(
          minItemWidth: 165,
          maxColumns: 4,
          children: [
            MetricTile(
              icon: Icons.memory,
              label: 'CPU',
              value: s.cpuUsage.toStringAsFixed(0),
              unit: '%',
              caption: '$cores ${cores == 1 ? 'core' : 'cores'} · load ${s.load1min.toStringAsFixed(2)}',
              tone: usageTone(s.cpuUsage),
              history: h.cpu,
              historyMax: 100,
            ),
            MetricTile(
              icon: Icons.developer_board,
              label: 'Memory',
              value: memPercent.toStringAsFixed(0),
              unit: '%',
              caption: '${formatBytes(s.ramUsed.toInt())} of ${formatBytes(s.ramTotal.toInt())}',
              tone: usageTone(memPercent, warn: 80),
              history: h.memory,
              historyMax: 100,
            ),
            MetricTile(
              icon: Icons.thermostat,
              label: 'Temperature',
              value: s.cpuTemp > 0 ? settings.formatTemperature(s.cpuTemp, digits: 1) : 'n/a',
              caption: s.gpuTemp > 0 ? 'GPU ${settings.formatTemperature(s.gpuTemp, digits: 1)}' : 'CPU',
              tone: s.cpuTemp > 0 ? tempTone(s.cpuTemp) : Tone.neutral,
              history: s.cpuTemp > 0 ? h.temperature : null,
              historyMax: settings.tempCritical + 10,
            ),
            MetricTile(
              icon: Icons.swap_horiz,
              label: 'Swap',
              value: s.swapTotal.toInt() > 0 ? swapPercent.toStringAsFixed(0) : 'off',
              unit: s.swapTotal.toInt() > 0 ? '%' : null,
              caption: s.swapTotal.toInt() > 0
                  ? '${formatBytes(s.swapUsed.toInt())} of ${formatBytes(s.swapTotal.toInt())}'
                  : 'No swap configured',
              tone: s.swapTotal.toInt() > 0 ? usageTone(swapPercent, warn: 50, critical: 80) : Tone.neutral,
              progress: s.swapTotal.toInt() > 0 ? swapPercent / 100 : null,
            ),
          ],
        ),
        const SectionHeader(title: 'History'),
        ResponsiveGrid(
          minItemWidth: 340,
          maxColumns: 2,
          children: [
            LineChartCard(
              title: 'CPU & memory',
              icon: Icons.show_chart,
              capacity: settings.statsHistory,
              maxY: 100,
              height: 160,
              axisLabel: (v) => '${v.round()}%',
              series: [
                ChartSeries(label: 'CPU', color: series[0], values: h.cpu, current: '${s.cpuUsage.toStringAsFixed(0)}%'),
                ChartSeries(label: 'Memory', color: series[1], values: h.memory, current: '${memPercent.toStringAsFixed(0)}%'),
              ],
            ),
            if (s.cpuTemp > 0)
              LineChartCard(
                title: 'Temperature',
                icon: Icons.thermostat,
                capacity: settings.statsHistory,
                maxY: (settings.tempCritical + 10).ceilToDouble(),
                height: 160,
                axisLabel: (v) => settings.formatTemperature(v, digits: 0),
                series: [
                  ChartSeries(
                    label: 'CPU',
                    color: context.tone(tempTone(s.cpuTemp)),
                    values: h.temperature,
                    current: settings.formatTemperature(s.cpuTemp, digits: 1),
                  ),
                ],
              ),
            LineChartCard(
              title: 'Network',
              icon: Icons.swap_vert,
              capacity: settings.statsHistory,
              height: 160,
              axisLabel: (v) => formatBytes(v, decimals: 0),
              series: [
                ChartSeries(label: 'Down', color: series[4], values: h.netDown, current: '${formatBytes(s.netBytesRecv.toInt())}/s'),
                ChartSeries(label: 'Up', color: series[2], values: h.netUp, current: '${formatBytes(s.netBytesSent.toInt())}/s'),
              ],
            ),
            LineChartCard(
              title: 'Disk activity',
              icon: Icons.storage,
              capacity: settings.statsHistory,
              height: 160,
              axisLabel: (v) => formatBytes(v, decimals: 0),
              series: [
                ChartSeries(
                  label: 'Read',
                  color: series[3],
                  values: h.diskRead,
                  current: '${formatBytes(h.diskRead.isEmpty ? 0 : h.diskRead.last)}/s',
                ),
                ChartSeries(
                  label: 'Write',
                  color: series[5 % series.length],
                  values: h.diskWrite,
                  current: '${formatBytes(h.diskWrite.isEmpty ? 0 : h.diskWrite.last)}/s',
                ),
              ],
            ),
          ],
        ),
        if (s.cpuPerCore.isNotEmpty) ...[
          const SectionHeader(title: 'CPU cores'),
          AppCard(
            child: ResponsiveGrid(
              minItemWidth: 220,
              maxColumns: 2,
              spacing: Insets.md,
              children: [
                for (var i = 0; i < s.cpuPerCore.length; i++)
                  _BarRow(
                    label: 'Core $i',
                    value: s.cpuPerCore[i] / 100,
                    trailing: '${s.cpuPerCore[i].toStringAsFixed(0)}%',
                    tone: usageTone(s.cpuPerCore[i]),
                  ),
              ],
            ),
          ),
        ],
        const SectionHeader(title: 'Memory'),
        _MemoryCard(stats: s),
        const SectionHeader(title: 'Load'),
        _LoadCard(stats: s, cores: cores),
        const SectionHeader(title: 'Storage'),
        _StorageSection(stats: s, settings: settings),
      ],
    );
  }
}

class _BarRow extends StatelessWidget {
  final String label;
  final double value;
  final String trailing;
  final Tone tone;

  const _BarRow({required this.label, required this.value, required this.trailing, required this.tone});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 64,
          child: Text(label, style: context.tt.labelMedium?.copyWith(color: context.cs.onSurfaceVariant)),
        ),
        Expanded(child: UsageBar(value: value.clamp(0, 1), color: context.tone(tone), height: 8)),
        SizedBox(
          width: 48,
          child: Text(
            trailing,
            textAlign: TextAlign.right,
            style: context.tt.labelMedium?.copyWith(fontFeatures: tabularFigures, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _MemoryCard extends StatelessWidget {
  final LiveStats stats;

  const _MemoryCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final s = stats;
    final total = s.ramTotal.toDouble();
    if (total <= 0) return const AppCard(child: Text('No memory information'));
    final used = s.ramUsed.toDouble();
    final cached = s.ramCached.toDouble();
    final free = s.ramFree.toDouble();
    final other = (total - used - cached - free).clamp(0, total).toDouble();
    final parts = [
      ('Used by apps', used, context.cs.primary),
      ('Cache', cached, context.ac.info),
      ('Buffers & other', other, context.cs.tertiary),
      ('Free', free, context.cs.surfaceContainerHighest),
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: Radii.smAll,
            child: SizedBox(
              height: 14,
              child: Row(
                children: [
                  for (final p in parts)
                    if (p.$2 > 0) Expanded(flex: (p.$2 / total * 1000).round().clamp(1, 1000), child: ColoredBox(color: p.$3)),
                ],
              ),
            ),
          ),
          const Gap(Insets.md),
          for (final p in parts)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Insets.xxs),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: p.$3,
                      shape: BoxShape.circle,
                      border: Border.all(color: context.cs.outlineVariant),
                    ),
                  ),
                  const Gap(Insets.sm),
                  Expanded(child: Text(p.$1, style: context.tt.bodyMedium)),
                  Text(
                    '${formatBytes(p.$2)}  ·  ${(p.$2 / total * 100).toStringAsFixed(0)}%',
                    style: context.tt.bodyMedium?.copyWith(fontFeatures: tabularFigures),
                  ),
                ],
              ),
            ),
          const Divider(height: Insets.xl),
          InfoRow('Total', formatBytes(total)),
          if (s.swapTotal.toInt() > 0)
            InfoRow('Swap', '${formatBytes(s.swapUsed.toInt())} of ${formatBytes(s.swapTotal.toInt())}'),
        ],
      ),
    );
  }
}

class _LoadCard extends StatelessWidget {
  final LiveStats stats;
  final int cores;

  const _LoadCard({required this.stats, required this.cores});

  @override
  Widget build(BuildContext context) {
    final loads = [('1 min', stats.load1min), ('5 min', stats.load5min), ('15 min', stats.load15min)];
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final l in loads) ...[
            _BarRow(
              label: l.$1,
              value: l.$2 / cores,
              trailing: l.$2.toStringAsFixed(2),
              tone: usageTone(l.$2 / cores * 100),
            ),
            const Gap(Insets.sm),
          ],
          Text(
            'Load counts processes running or waiting. With $cores ${cores == 1 ? 'core' : 'cores'}, '
            '$cores.00 means the CPU is fully busy.',
            style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _StorageSection extends ConsumerWidget {
  final LiveStats stats;
  final AppSettings settings;

  const _StorageSection({required this.stats, required this.settings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final disks = ref.watch(diskInfoProvider);
    return Column(
      children: [
        disks.when(
          loading: () => const AppCard(child: LoadingState(message: 'Reading partitions…')),
          error: (e, _) => AppCard(child: Text('Partitions unavailable: ${describeError(e)}')),
          data: (info) => info.partitions.isEmpty
              ? const AppCard(child: Text('No partitions reported'))
              : TileGroup(
                  children: [
                    for (final p in info.partitions)
                      Padding(
                        padding: const EdgeInsets.all(Insets.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                IconBadge(Icons.storage, tone: usageTone(p.usagePercent, warn: 75), size: 36),
                                const Gap(Insets.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(p.mountPoint, style: context.tt.titleSmall),
                                      Text(
                                        '${p.device} · ${p.filesystem}',
                                        style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${p.usagePercent.toStringAsFixed(0)}%',
                                  style: context.tt.titleMedium?.copyWith(
                                    color: context.tone(usageTone(p.usagePercent, warn: 75)),
                                    fontFeatures: tabularFigures,
                                  ),
                                ),
                              ],
                            ),
                            const Gap(Insets.sm),
                            UsageBar(
                              value: p.usagePercent / 100,
                              color: context.tone(usageTone(p.usagePercent, warn: 75)),
                            ),
                            const Gap(Insets.xs),
                            Text(
                              '${formatBytes(p.usedBytes.toInt())} used · '
                              '${formatBytes((p.totalBytes - p.usedBytes).toInt())} free · '
                              '${formatBytes(p.totalBytes.toInt())} total',
                              style: context.tt.bodySmall?.copyWith(
                                color: context.cs.onSurfaceVariant,
                                fontFeatures: tabularFigures,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
        ),
        if (stats.diskIo.isNotEmpty) ...[
          const Gap(Insets.md),
          TileGroup(
            children: [
              for (final d in [...stats.diskIo]..sort((a, b) => a.device.compareTo(b.device)))
                ListTile(
                  leading: const Icon(Icons.sd_storage_outlined),
                  title: Text(d.device),
                  subtitle: Text(
                    'Read ${formatBytes(d.readBytes.toInt())}/s (${d.readCount} ops) · '
                    'Write ${formatBytes(d.writeBytes.toInt())}/s (${d.writeCount} ops)',
                    style: context.tt.bodySmall?.copyWith(fontFeatures: tabularFigures),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

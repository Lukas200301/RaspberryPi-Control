import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/stat_card.dart';
import '../providers/app_providers.dart';
import '../generated/pi_control.pb.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  final Queue<double> _cpuHistory = Queue();
  final Queue<double> _memHistory = Queue();
  final Queue<double> _uploadHistory = Queue();
  final Queue<double> _downloadHistory = Queue();
  final int _maxDataPoints = 30;

  @override
  Widget build(BuildContext context) {
    final liveStatsAsync = ref.watch(liveStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('System Stats'),
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(liveStatsProvider);
            },
          ),
        ],
      ),
      body: liveStatsAsync.when(
        data: (stats) {
          _updateHistory(stats);
          return _buildStats(context, stats);
        },
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppTheme.primaryIndigo),
              Gap(16),
              Text('Connecting to agent...'),
            ],
          ),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppTheme.errorRose,
                ),
                const Gap(16),
                Text(
                  'Error loading stats',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Gap(8),
                Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const Gap(16),
                ElevatedButton.icon(
                  onPressed: () => ref.invalidate(liveStatsProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _updateHistory(LiveStats stats) {
    _cpuHistory.add(stats.cpuUsage);
    final memPercent = stats.ramTotal > 0 ? (stats.ramUsed.toDouble() / stats.ramTotal.toDouble() * 100) : 0.0;
    _memHistory.add(memPercent);

    // Convert bytes/sec to KB/sec for better readability
    _uploadHistory.add(stats.netBytesSent.toDouble() / 1024);
    _downloadHistory.add(stats.netBytesRecv.toDouble() / 1024);

    if (_cpuHistory.length > _maxDataPoints) {
      _cpuHistory.removeFirst();
    }
    if (_memHistory.length > _maxDataPoints) {
      _memHistory.removeFirst();
    }
    if (_uploadHistory.length > _maxDataPoints) {
      _uploadHistory.removeFirst();
    }
    if (_downloadHistory.length > _maxDataPoints) {
      _downloadHistory.removeFirst();
    }
  }

  Widget _buildStats(BuildContext context, LiveStats stats) {
    final diskInfoAsync = ref.watch(diskInfoProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // System Info Header
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'System Uptime',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      _formatUptime(stats.uptime.toInt()),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryIndigo,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Load Average',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      '${stats.load1min.toStringAsFixed(2)} / ${stats.load5min.toStringAsFixed(2)} / ${stats.load15min.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: stats.load1min > 4.0 ? AppTheme.errorRose : AppTheme.successGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Gap(16),

          // Hero Stats
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'CPU',
                  value: '${stats.cpuUsage.toStringAsFixed(1)}%',
                  icon: Icons.memory,
                  color: AppTheme.getCPUColor(stats.cpuUsage),
                ),
              ),
              const Gap(12),
              Expanded(
                child: StatCard(
                  title: 'RAM',
                  value: '${(stats.ramUsed.toDouble() / stats.ramTotal.toDouble() * 100).toStringAsFixed(1)}%',
                  icon: Icons.storage,
                  color: AppTheme.getMemoryColor(stats.ramUsed.toDouble() / stats.ramTotal.toDouble() * 100),
                ),
              ),
            ],
          ),
          const Gap(12),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'CPU Temp',
                  value: '${stats.cpuTemp.toStringAsFixed(1)}°C',
                  icon: Icons.thermostat,
                  color: AppTheme.getTempColor(stats.cpuTemp),
                ),
              ),
              const Gap(12),
              Expanded(
                child: StatCard(
                  title: stats.gpuTemp > 0 ? 'GPU Temp' : 'Swap',
                  value: stats.gpuTemp > 0
                    ? '${stats.gpuTemp.toStringAsFixed(1)}°C'
                    : stats.swapTotal > 0
                      ? '${(stats.swapUsed.toDouble() / stats.swapTotal.toDouble() * 100).toStringAsFixed(1)}%'
                      : 'N/A',
                  icon: stats.gpuTemp > 0 ? Icons.thermostat : Icons.swap_horiz,
                  color: stats.gpuTemp > 0
                    ? AppTheme.getTempColor(stats.gpuTemp)
                    : stats.swapTotal > 0
                      ? AppTheme.getMemoryColor(stats.swapUsed.toDouble() / stats.swapTotal.toDouble() * 100)
                      : AppTheme.textTertiary,
                ),
              ),
            ],
          ),
          const Gap(24),

          // Per-Core CPU Usage
          if (stats.cpuPerCore.isNotEmpty) ...[
            Text(
              'CPU Cores',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Gap(12),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  for (int i = 0; i < stats.cpuPerCore.length; i++) ...[
                    Row(
                      children: [
                        SizedBox(
                          width: 60,
                          child: Text(
                            'Core $i',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: stats.cpuPerCore[i] / 100,
                              minHeight: 20,
                              backgroundColor: AppTheme.glassLight,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.getCPUColor(stats.cpuPerCore[i]),
                              ),
                            ),
                          ),
                        ),
                        const Gap(12),
                        SizedBox(
                          width: 50,
                          child: Text(
                            '${stats.cpuPerCore[i].toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.getCPUColor(stats.cpuPerCore[i]),
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    if (i < stats.cpuPerCore.length - 1) const Gap(8),
                  ],
                ],
              ),
            ),
            const Gap(24),
          ],

          // Memory Details
          Text(
            'Memory Details',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Gap(12),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildMemoryRow('Used', stats.ramUsed, stats.ramTotal, AppTheme.primaryIndigo),
                const Gap(8),
                _buildMemoryRow('Cached', stats.ramCached, stats.ramTotal, AppTheme.secondaryTeal),
                const Gap(8),
                _buildMemoryRow('Free', stats.ramFree, stats.ramTotal, AppTheme.successGreen),
                if (stats.swapTotal > 0) ...[
                  const Gap(12),
                  const Divider(color: AppTheme.glassBorder),
                  const Gap(12),
                  _buildMemoryRow('Swap Used', stats.swapUsed, stats.swapTotal, AppTheme.warningAmber),
                ],
              ],
            ),
          ),
          const Gap(24),

          // CPU Chart
          Text(
            'CPU Usage',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Gap(12),
          GlassCard(
            child: SizedBox(
              height: 200,
              child: _cpuHistory.length > 1
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 25,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: AppTheme.glassBorder,
                              strokeWidth: 1,
                            ),
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) => Text(
                                  '${value.toStringAsFixed(2)}%',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.textTertiary,
                                  ),
                                ),
                              ),
                            ),
                            bottomTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          minY: 0,
                          maxY: 100,
                          lineBarsData: [
                            LineChartBarData(
                              spots: _cpuHistory
                                  .toList()
                                  .asMap()
                                  .entries
                                  .map((e) => FlSpot(e.key.toDouble(), e.value))
                                  .toList(),
                              isCurved: true,
                              color: AppTheme.primaryIndigo,
                              barWidth: 3,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: AppTheme.primaryIndigo.withValues(alpha: 0.2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const Center(
                      child: CircularProgressIndicator(color: AppTheme.primaryIndigo),
                    ),
            ),
          ),
          const Gap(24),

          // Memory Chart
          Text(
            'Memory Usage',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Gap(12),
          GlassCard(
            child: SizedBox(
              height: 200,
              child: _memHistory.length > 1
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 25,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: AppTheme.glassBorder,
                              strokeWidth: 1,
                            ),
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) => Text(
                                  '${value.toStringAsFixed(2)}%',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.textTertiary,
                                  ),
                                ),
                              ),
                            ),
                            bottomTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          minY: 0,
                          maxY: 100,
                          lineBarsData: [
                            LineChartBarData(
                              spots: _memHistory
                                  .toList()
                                  .asMap()
                                  .entries
                                  .map((e) => FlSpot(e.key.toDouble(), e.value))
                                  .toList(),
                              isCurved: true,
                              color: AppTheme.secondaryTeal,
                              barWidth: 3,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: AppTheme.secondaryTeal.withValues(alpha: 0.2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const Center(
                      child: CircularProgressIndicator(color: AppTheme.secondaryTeal),
                    ),
            ),
          ),
          const Gap(24),

          // Memory Details
          Text(
            'Memory Details',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Gap(12),
          GlassCard(
            child: Column(
              children: [
                _buildMemoryBar(
                  'Used',
                  stats.ramUsed.toDouble() / 1024 / 1024 / 1024,
                  stats.ramTotal.toDouble() / 1024 / 1024 / 1024,
                  AppTheme.primaryIndigo,
                ),
                const Gap(8),
                _buildMemoryBar(
                  'Cached',
                  stats.ramCached.toDouble() / 1024 / 1024 / 1024,
                  stats.ramTotal.toDouble() / 1024 / 1024 / 1024,
                  AppTheme.secondaryTeal,
                ),
                const Gap(8),
                _buildMemoryBar(
                  'Free',
                  stats.ramFree.toDouble() / 1024 / 1024 / 1024,
                  stats.ramTotal.toDouble() / 1024 / 1024 / 1024,
                  AppTheme.successGreen,
                ),
              ],
            ),
          ),
          const Gap(24),

          // Network
          Text(
            'Network',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Gap(12),
          GlassCard(
            child: SizedBox(
              height: 250,
              child: _uploadHistory.length > 1 && _downloadHistory.length > 1
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.arrow_upward, color: AppTheme.primaryIndigo, size: 16),
                                  const Gap(4),
                                  Text(
                                    'Upload: ${_formatBytes(stats.netBytesSent.toDouble())}',
                                    style: const TextStyle(fontSize: 12, color: AppTheme.primaryIndigo),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.arrow_downward, color: AppTheme.secondaryTeal, size: 16),
                                  const Gap(4),
                                  Text(
                                    'Download: ${_formatBytes(stats.netBytesRecv.toDouble())}',
                                    style: const TextStyle(fontSize: 12, color: AppTheme.secondaryTeal),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Gap(12),
                          Expanded(
                            child: LineChart(
                              LineChartData(
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  getDrawingHorizontalLine: (value) => FlLine(
                                    color: AppTheme.glassBorder,
                                    strokeWidth: 1,
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 50,
                                      getTitlesWidget: (value, meta) => Text(
                                        '${value.toStringAsFixed(0)} KB/s',
                                        style: const TextStyle(
                                          fontSize: 9,
                                          color: AppTheme.textTertiary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  bottomTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                minY: 0,
                                lineBarsData: [
                                  // Upload line
                                  LineChartBarData(
                                    spots: _uploadHistory
                                        .toList()
                                        .asMap()
                                        .entries
                                        .map((e) => FlSpot(e.key.toDouble(), e.value))
                                        .toList(),
                                    isCurved: true,
                                    color: AppTheme.primaryIndigo,
                                    barWidth: 2,
                                    dotData: const FlDotData(show: false),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: AppTheme.primaryIndigo.withValues(alpha: 0.1),
                                    ),
                                  ),
                                  // Download line
                                  LineChartBarData(
                                    spots: _downloadHistory
                                        .toList()
                                        .asMap()
                                        .entries
                                        .map((e) => FlSpot(e.key.toDouble(), e.value))
                                        .toList(),
                                    isCurved: true,
                                    color: AppTheme.secondaryTeal,
                                    barWidth: 2,
                                    dotData: const FlDotData(show: false),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: AppTheme.secondaryTeal.withValues(alpha: 0.1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const Center(
                      child: CircularProgressIndicator(color: AppTheme.primaryIndigo),
                    ),
            ),
          ),
          const Gap(24),

          // Disk Usage
          diskInfoAsync.when(
            data: (diskInfo) {
              if (diskInfo.partitions.isEmpty) {
                return const SizedBox.shrink();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Disk Usage',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Gap(12),
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        for (int i = 0; i < diskInfo.partitions.length; i++) ...[
                          _buildDiskPartition(diskInfo.partitions[i]),
                          if (i < diskInfo.partitions.length - 1) ...[
                            const Gap(12),
                            const Divider(color: AppTheme.glassBorder),
                            const Gap(12),
                          ],
                        ],
                      ],
                    ),
                  ),
                  const Gap(24),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoryBar(String label, double used, double total, Color color) {
    final percent = (used / total * 100).clamp(0, 100);

    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: used / total,
              backgroundColor: AppTheme.glassLight,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 8,
            ),
          ),
        ),
        const Gap(12),
        SizedBox(
          width: 120,
          child: Text(
            '${used.toStringAsFixed(2)}GB / ${total.toStringAsFixed(2)}GB (${percent.toStringAsFixed(0)}%)',
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 11),
          ),
        ),
      ],
    );
  }

  String _formatBytes(double bytesPerSec) {
    if (bytesPerSec < 1024) {
      return '${bytesPerSec.toStringAsFixed(0)} B/s';
    } else if (bytesPerSec < 1024 * 1024) {
      return '${(bytesPerSec / 1024).toStringAsFixed(1)} KB/s';
    } else {
      return '${(bytesPerSec / 1024 / 1024).toStringAsFixed(2)} MB/s';
    }
  }

  String _formatUptime(int seconds) {
    final days = seconds ~/ 86400;
    final hours = (seconds % 86400) ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;

    if (days > 0) {
      return '${days}d ${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  Widget _buildMemoryRow(String label, dynamic usedBytes, dynamic totalBytes, Color color) {
    if (totalBytes.toInt() == 0) return const SizedBox.shrink();

    final percent = (usedBytes.toDouble() / totalBytes.toDouble() * 100);
    final usedMB = (usedBytes.toDouble() / 1024 / 1024);
    final totalMB = (totalBytes.toDouble() / 1024 / 1024);

    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: usedBytes.toDouble() / totalBytes.toDouble(),
              minHeight: 16,
              backgroundColor: AppTheme.glassLight,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const Gap(12),
        SizedBox(
          width: 140,
          child: Text(
            '${usedMB.toStringAsFixed(0)} MB / ${totalMB.toStringAsFixed(0)} MB (${percent.toStringAsFixed(1)}%)',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildDiskPartition(DiskPartition partition) {
    final usedGB = partition.usedBytes.toDouble() / 1024 / 1024 / 1024;
    final totalGB = partition.totalBytes.toDouble() / 1024 / 1024 / 1024;
    final percent = partition.usagePercent;

    Color getColor() {
      if (percent > 90) return AppTheme.errorRose;
      if (percent > 75) return AppTheme.warningAmber;
      return AppTheme.successGreen;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    partition.mountPoint,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const Gap(2),
                  Text(
                    '${partition.device} (${partition.filesystem})',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${percent.toStringAsFixed(1)}%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: getColor(),
              ),
            ),
          ],
        ),
        const Gap(8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent / 100,
            minHeight: 20,
            backgroundColor: AppTheme.glassLight,
            valueColor: AlwaysStoppedAnimation<Color>(getColor()),
          ),
        ),
        const Gap(4),
        Text(
          '${usedGB.toStringAsFixed(2)} GB / ${totalGB.toStringAsFixed(2)} GB',
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

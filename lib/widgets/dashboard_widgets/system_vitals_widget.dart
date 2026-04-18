import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../providers/app_providers.dart';

class SystemVitalsWidget extends ConsumerWidget {
  const SystemVitalsWidget({super.key});

  String _formatUptime(int seconds) {
    final days = seconds ~/ 86400;
    final hours = (seconds % 86400) ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    if (days > 0) return '${days}d ${hours}h ${minutes}m';
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveStatsAsync = ref.watch(liveStatsProvider);

    return liveStatsAsync.when(
      data: (stats) {
        final ramUsedGB = stats.ramUsed.toDouble() / 1024 / 1024 / 1024;
        final ramTotalGB = stats.ramTotal.toDouble() / 1024 / 1024 / 1024;
        final tempColor = AppTheme.getTempColor(stats.cpuTemp);
        final cpuColor = AppTheme.getCPUColor(stats.cpuUsage);

        return GlassCard(
          glowColor: stats.cpuTemp > 70 ? AppTheme.errorRose : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const Gap(12),
              _buildVitalRow(
                context,
                icon: Icons.memory,
                label: 'CPU',
                value: '${stats.cpuUsage.toStringAsFixed(1)}%',
                color: cpuColor,
                progress: stats.cpuUsage / 100,
              ),
              const Gap(8),
              _buildVitalRow(
                context,
                icon: Icons.storage,
                label: 'RAM',
                value:
                    '${ramUsedGB.toStringAsFixed(1)} / ${ramTotalGB.toStringAsFixed(1)} GB',
                color: AppTheme.getMemoryColor(
                  stats.ramUsed.toDouble() / stats.ramTotal.toDouble() * 100,
                ),
                progress: stats.ramUsed.toDouble() / stats.ramTotal.toDouble(),
              ),
              const Gap(8),
              _buildVitalRow(
                context,
                icon: Icons.thermostat,
                label: 'Temp',
                value: '${stats.cpuTemp.toStringAsFixed(1)}°C',
                color: tempColor,
                progress: (stats.cpuTemp / 90).clamp(0.0, 1.0),
              ),
              const Gap(8),
              _buildVitalRow(
                context,
                icon: Icons.access_time,
                label: 'Uptime',
                value: _formatUptime(stats.uptime.toInt()),
                color: AppTheme.textSecondary,
                progress: null,
              ),
            ],
          ),
        );
      },
      loading: () => GlassCard(
        child: SizedBox(
          height: 120,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  color: AppTheme.primaryIndigo,
                  strokeWidth: 2,
                ),
                const Gap(12),
                Text(
                  'Loading vitals…',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
      error: (e, _) => GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Error: $e',
            style: const TextStyle(color: AppTheme.errorRose),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.monitor_heart,
          color: AppTheme.primaryIndigo,
          size: 18,
        ),
        const Gap(8),
        Text('System Vitals', style: Theme.of(context).textTheme.titleSmall),
      ],
    );
  }

  Widget _buildVitalRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required double? progress,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const Gap(8),
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.bodySmall),
            ),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(color: color),
            ),
          ],
        ),
        if (progress != null) ...[
          const Gap(4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppTheme.glassBorder,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
            ),
          ),
        ],
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../controllers/dashboard_controller.dart';
import '../../../../controllers/stats_controller.dart';
import '../../../../pages/stats/widgets/system_processes_widget.dart';

/// System Processes Card - Shows top processes by CPU/Memory usage
/// Glassmorphism design for v3.0
class SystemProcessesCard extends GetView<DashboardController> {
  const SystemProcessesCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      // Get processes from StatsController
      final statsController = Get.find<StatsController>();
      final currentStats = statsController.currentStats;
      final processes = currentStats['processes'] as List? ?? [];

      // Sort by CPU usage descending
      final sortedProcesses = List.from(processes);
      sortedProcesses.sort((a, b) {
        final cpuA = (a['cpu'] as num?)?.toDouble() ?? 0.0;
        final cpuB = (b['cpu'] as num?)?.toDouble() ?? 0.0;
        return cpuB.compareTo(cpuA);
      });

      final topProcesses = sortedProcesses.take(5).toList();

      return Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.spaceMD),
        padding: const EdgeInsets.all(AppDimensions.spaceLG),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ]
                : [
                    Colors.white.withOpacity(0.8),
                    Colors.white.withOpacity(0.4),
                  ],
          ),
          border: Border.all(
            color: AppColors.accentBlue.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            AppColors.indigoGlow(blur: 20, opacity: 0.2),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.spaceSM),
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                  ),
                  child: const Icon(
                    Icons.memory,
                    color: AppColors.accentBlue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceMD),
                Expanded(
                  child: Text(
                    'System Processes',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textPrimary : Colors.black87,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spaceSM,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
                    border: Border.all(
                      color: AppColors.accentBlue,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${processes.length}',
                    style: const TextStyle(
                      color: AppColors.accentBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.spaceMD),

            // Process list
            if (topProcesses.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.spaceLG),
                  child: Column(
                    children: [
                      Icon(
                        Icons.hourglass_empty,
                        size: 32,
                        color: isDark ? AppColors.textTertiary : Colors.black38,
                      ),
                      const SizedBox(height: AppDimensions.spaceSM),
                      Text(
                        'No process information available',
                        style: TextStyle(
                          color: isDark ? AppColors.textSecondary : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...topProcesses.map((process) {
                final command = process['command']?.toString() ?? 'Unknown';
                final pid = process['pid']?.toString() ?? '?';
                final user = process['user']?.toString() ?? '';
                final cpu = (process['cpu'] as num?)?.toDouble() ?? 0.0;
                final memory = (process['memory'] as num?)?.toDouble() ?? 0.0;

                return _buildProcessItem(
                  context,
                  command,
                  pid,
                  user,
                  cpu,
                  memory,
                  isDark,
                );
              }),

            // Show all button
            if (processes.length > 5)
              Padding(
                padding: const EdgeInsets.only(top: AppDimensions.spaceSM),
                child: Center(
                  child: TextButton.icon(
                    onPressed: () {
                      // Show full processes page
                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.8,
                            padding: const EdgeInsets.all(AppDimensions.spaceMD),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'All Processes',
                                      style: theme.textTheme.titleLarge,
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppDimensions.spaceMD),
                                Expanded(
                                  child: SystemProcessesWidget(
                                    processes: processes,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.expand_more, size: 18),
                    label: Text('Show all ${processes.length} processes'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.accentBlue,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildProcessItem(
    BuildContext context,
    String command,
    String pid,
    String user,
    double cpu,
    double memory,
    bool isDark,
  ) {
    final processColor = _getProcessColor(cpu);
    final commandName = command.split(' ')[0].split('/').last;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceSM),
      padding: const EdgeInsets.all(AppDimensions.spaceMD),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        border: Border.all(
          color: processColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Process icon
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: processColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.widgets,
              color: processColor,
              size: 16,
            ),
          ),

          const SizedBox(width: AppDimensions.spaceMD),

          // Process info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  commandName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isDark ? AppColors.textPrimary : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'PID: $pid${user.isNotEmpty ? ' • $user' : ''}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.textTertiary : Colors.black45,
                  ),
                ),
              ],
            ),
          ),

          // Usage badges
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildUsageBadge('CPU', cpu, AppColors.accentBlue),
              const SizedBox(height: 4),
              _buildUsageBadge('MEM', memory, AppColors.warning),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsageBadge(String label, double value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
        border: Border.all(
          color: color,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            '${value.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getProcessColor(double cpu) {
    if (cpu >= 80) return AppColors.error;
    if (cpu >= 50) return AppColors.warning;
    if (cpu >= 20) return AppColors.accentBlue;
    return AppColors.success;
  }
}

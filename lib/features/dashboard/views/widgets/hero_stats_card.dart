import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../controllers/dashboard_controller.dart';

/// Hero Stats Card - Large overview card showing key system metrics
/// Glassmorphism design for v3.0
class HeroStatsCard extends GetView<DashboardController> {
  const HeroStatsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      return Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.spaceLG),
        padding: const EdgeInsets.all(AppDimensions.spaceLG),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    AppColors.accentIndigo.withOpacity(0.15),
                    AppColors.accentTeal.withOpacity(0.1),
                  ]
                : [
                    Colors.white.withOpacity(0.9),
                    Colors.white.withOpacity(0.6),
                  ],
          ),
          border: Border.all(
            color: AppColors.accentIndigo.withOpacity(0.3),
            width: AppDimensions.borderMedium,
          ),
          boxShadow: [
            AppColors.indigoGlow(blur: 30, opacity: 0.3),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.dashboard,
                  color: AppColors.accentIndigo,
                  size: AppDimensions.iconLG,
                ),
                const SizedBox(width: AppDimensions.spaceMD),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'System Overview',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textPrimary : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spaceXS),
                      Text(
                        'Uptime: ${controller.uptime.value}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.textSecondary : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spaceMD,
                    vertical: AppDimensions.spaceSM,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                    border: Border.all(
                      color: AppColors.success,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spaceSM),
                      const Text(
                        'Online',
                        style: TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.spaceLG),

            // Key metrics grid
            Row(
              children: [
                // CPU
                Expanded(
                  child: _buildMetricGauge(
                    context,
                    icon: Icons.speed,
                    label: 'CPU',
                    value: controller.cpuUsage.value,
                    unit: '%',
                    color: AppColors.accentIndigo,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceMD),

                // Memory
                Expanded(
                  child: _buildMetricGauge(
                    context,
                    icon: Icons.memory,
                    label: 'Memory',
                    value: controller.memoryUsage.value,
                    unit: '%',
                    color: AppColors.accentTeal,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceMD),

                // Temperature
                Expanded(
                  child: _buildMetricGauge(
                    context,
                    icon: Icons.thermostat,
                    label: 'Temp',
                    value: controller.cpuTemperature.value,
                    unit: '°C',
                    color: _getTemperatureColor(controller.cpuTemperature.value),
                    isDark: isDark,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.spaceLG),

            // Additional stats
            Row(
              children: [
                Expanded(
                  child: _buildStatChip(
                    context,
                    icon: Icons.arrow_downward,
                    label: 'Network In',
                    value: _formatBytes(controller.networkIn.value),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceSM),
                Expanded(
                  child: _buildStatChip(
                    context,
                    icon: Icons.arrow_upward,
                    label: 'Network Out',
                    value: _formatBytes(controller.networkOut.value),
                    isDark: isDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  /// Build circular metric gauge
  Widget _buildMetricGauge(
    BuildContext context, {
    required IconData icon,
    required String label,
    required double value,
    required String unit,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceMD),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // Icon
          Icon(
            icon,
            color: color,
            size: AppDimensions.iconMD,
          ),
          const SizedBox(height: AppDimensions.spaceSM),

          // Circular progress
          SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background circle
                CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 6,
                  color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                ),
                // Progress circle
                CircularProgressIndicator(
                  value: value / 100,
                  strokeWidth: 6,
                  color: color,
                  backgroundColor: Colors.transparent,
                ),
                // Value text
                Text(
                  '${value.toStringAsFixed(0)}$unit',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimary : Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.spaceSM),

          // Label
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.textSecondary : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  /// Build stat chip for additional info
  Widget _buildStatChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceMD,
        vertical: AppDimensions.spaceSM,
      ),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.accentTeal,
          ),
          const SizedBox(width: AppDimensions.spaceSM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? AppColors.textSecondary : Colors.black54,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimary : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Get temperature color based on value
  Color _getTemperatureColor(double temp) {
    if (temp >= 80) return AppColors.error;
    if (temp >= 70) return AppColors.warning;
    return AppColors.success;
  }

  /// Format bytes to human readable
  String _formatBytes(double bytes) {
    if (bytes < 1024) return '${bytes.toStringAsFixed(0)} B/s';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB/s';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB/s';
  }
}

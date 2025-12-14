import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../controllers/dashboard_controller.dart';

/// Network Chart Card - Network In/Out traffic monitoring
/// Glassmorphism design for v3.0
class NetworkChartCard extends GetView<DashboardController> {
  const NetworkChartCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final networkIn = controller.networkIn.value;
      final networkOut = controller.networkOut.value;

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
            color: AppColors.accentCyan.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            AppColors.cyanGlow(blur: 20, opacity: 0.2),
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
                    color: AppColors.accentCyan.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                  ),
                  child: const Icon(
                    Icons.network_check,
                    color: AppColors.accentCyan,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceMD),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Network Activity',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textPrimary : Colors.black87,
                        ),
                      ),
                      Text(
                        'Real-time traffic monitoring',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.textSecondary : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.spaceLG),

            // Traffic badges
            Row(
              children: [
                Expanded(
                  child: _buildTrafficBadge(
                    context,
                    'Download',
                    networkIn,
                    Icons.arrow_downward,
                    AppColors.accentTeal,
                    isDark,
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceSM),
                Expanded(
                  child: _buildTrafficBadge(
                    context,
                    'Upload',
                    networkOut,
                    Icons.arrow_upward,
                    AppColors.accentIndigo,
                    isDark,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.spaceLG),

            // Chart
            SizedBox(
              height: 150,
              child: controller.networkInHistory.isEmpty
                  ? Center(
                      child: Text(
                        'Collecting data...',
                        style: TextStyle(
                          color: isDark ? AppColors.textSecondary : Colors.black54,
                        ),
                      ),
                    )
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: isDark
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.black.withOpacity(0.1),
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 50,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  _formatBytes(value),
                                  style: TextStyle(
                                    color: isDark ? AppColors.textSecondary : Colors.black54,
                                    fontSize: 9,
                                  ),
                                );
                              },
                            ),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        minY: 0,
                        lineBarsData: [
                          // Network In (Download)
                          LineChartBarData(
                            spots: controller.networkInHistory,
                            isCurved: true,
                            color: AppColors.accentTeal,
                            barWidth: 3,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppColors.accentTeal.withOpacity(0.3),
                                  AppColors.accentTeal.withOpacity(0.0),
                                ],
                              ),
                            ),
                          ),
                          // Network Out (Upload)
                          LineChartBarData(
                            spots: controller.networkOutHistory,
                            isCurved: true,
                            color: AppColors.accentIndigo,
                            barWidth: 2,
                            dotData: const FlDotData(show: false),
                            dashArray: [5, 5], // Dashed line for upload
                          ),
                        ],
                      ),
                    ),
            ),

            const SizedBox(height: AppDimensions.spaceMD),

            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Download', AppColors.accentTeal, false),
                const SizedBox(width: AppDimensions.spaceLG),
                _buildLegendItem('Upload', AppColors.accentIndigo, true),
              ],
            ),
          ],
        ),
      );
    });
  }

  /// Build traffic badge
  Widget _buildTrafficBadge(
    BuildContext context,
    String label,
    double bytesPerSec,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceMD),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.03) : Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: AppDimensions.spaceSM),
          Text(
            _formatBytes(bytesPerSec),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.textSecondary : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  /// Build chart legend item
  Widget _buildLegendItem(String label, Color color, bool isDashed) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: isDashed ? Colors.transparent : color,
            border: isDashed ? Border.all(color: color, width: 2) : null,
          ),
        ),
        const SizedBox(width: AppDimensions.spaceXS),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Format bytes to human readable
  String _formatBytes(double bytes) {
    if (bytes < 1024) return '${bytes.toStringAsFixed(0)} B/s';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB/s';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB/s';
  }
}

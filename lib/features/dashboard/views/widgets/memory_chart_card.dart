import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../controllers/dashboard_controller.dart';

/// Memory Chart Card - Real-time memory usage graph
/// Glassmorphism design for v3.0
class MemoryChartCard extends GetView<DashboardController> {
  const MemoryChartCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final memoryPercent = controller.memoryUsage.value;
      final memoryUsedMB = (controller.memoryUsed.value / 1024).toStringAsFixed(0);
      final memoryTotalMB = (controller.memoryTotal.value / 1024).toStringAsFixed(0);

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
            color: AppColors.accentTeal.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            AppColors.tealGlow(blur: 20, opacity: 0.2),
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
                    color: AppColors.accentTeal.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                  ),
                  child: const Icon(
                    Icons.memory,
                    color: AppColors.accentTeal,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceMD),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Memory Usage',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textPrimary : Colors.black87,
                        ),
                      ),
                      Text(
                        '$memoryUsedMB MB / $memoryTotalMB MB',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.accentTeal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Percentage badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spaceMD,
                    vertical: AppDimensions.spaceSM,
                  ),
                  decoration: BoxDecoration(
                    color: _getMemoryColor(memoryPercent).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                    border: Border.all(
                      color: _getMemoryColor(memoryPercent),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${memoryPercent.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: _getMemoryColor(memoryPercent),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.spaceLG),

            // Chart
            SizedBox(
              height: 150,
              child: controller.memoryHistory.isEmpty
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
                          horizontalInterval: 25,
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
                              reservedSize: 35,
                              interval: 25,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${value.toInt()}%',
                                  style: TextStyle(
                                    color: isDark ? AppColors.textSecondary : Colors.black54,
                                    fontSize: 10,
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
                        maxY: 100,
                        lineBarsData: [
                          LineChartBarData(
                            spots: controller.memoryHistory,
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
                        ],
                      ),
                    ),
            ),
          ],
        ),
      );
    });
  }

  /// Get memory color based on usage
  Color _getMemoryColor(double usage) {
    if (usage >= 90) return AppColors.error;
    if (usage >= 75) return AppColors.warning;
    return AppColors.success;
  }
}

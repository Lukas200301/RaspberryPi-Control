import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../controllers/dashboard_controller.dart';

/// Temperature Chart Card - CPU & GPU temperature monitoring
/// Glassmorphism design for v3.0
class TemperatureChartCard extends GetView<DashboardController> {
  const TemperatureChartCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final cpuTemp = controller.cpuTemperature.value;
      final gpuTemp = controller.gpuTemperature.value;

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
            color: _getTemperatureColor(cpuTemp).withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _getTemperatureColor(cpuTemp).withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
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
                    color: _getTemperatureColor(cpuTemp).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                  ),
                  child: Icon(
                    Icons.thermostat,
                    color: _getTemperatureColor(cpuTemp),
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceMD),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Temperature',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textPrimary : Colors.black87,
                        ),
                      ),
                      Text(
                        'CPU & GPU Monitoring',
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

            // Temperature badges
            Row(
              children: [
                Expanded(
                  child: _buildTempBadge(
                    context,
                    'CPU',
                    cpuTemp,
                    Icons.speed,
                    isDark,
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceSM),
                Expanded(
                  child: _buildTempBadge(
                    context,
                    'GPU',
                    gpuTemp,
                    Icons.videogame_asset,
                    isDark,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.spaceLG),

            // Chart
            SizedBox(
              height: 150,
              child: controller.cpuTempHistory.isEmpty
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
                          horizontalInterval: 20,
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
                              interval: 20,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${value.toInt()}°C',
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
                          // CPU Temperature
                          LineChartBarData(
                            spots: controller.cpuTempHistory,
                            isCurved: true,
                            color: _getTemperatureColor(cpuTemp),
                            barWidth: 3,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  _getTemperatureColor(cpuTemp).withOpacity(0.3),
                                  _getTemperatureColor(cpuTemp).withOpacity(0.0),
                                ],
                              ),
                            ),
                          ),
                          // GPU Temperature (if available)
                          if (controller.gpuTempHistory.isNotEmpty)
                            LineChartBarData(
                              spots: controller.gpuTempHistory,
                              isCurved: true,
                              color: AppColors.accentPurple,
                              barWidth: 2,
                              dotData: const FlDotData(show: false),
                              dashArray: [5, 5], // Dashed line for GPU
                            ),
                        ],
                      ),
                    ),
            ),

            const SizedBox(height: AppDimensions.spaceMD),

            // Legend
            if (controller.gpuTempHistory.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem('CPU', _getTemperatureColor(cpuTemp), false),
                  const SizedBox(width: AppDimensions.spaceLG),
                  _buildLegendItem('GPU', AppColors.accentPurple, true),
                ],
              ),
          ],
        ),
      );
    });
  }

  /// Build temperature badge
  Widget _buildTempBadge(
    BuildContext context,
    String label,
    double temp,
    IconData icon,
    bool isDark,
  ) {
    final color = _getTemperatureColor(temp);

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
            '${temp.toStringAsFixed(1)}°C',
            style: TextStyle(
              fontSize: 18,
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

  /// Get temperature color based on value
  Color _getTemperatureColor(double temp) {
    if (temp >= 80) return AppColors.error;
    if (temp >= 70) return AppColors.warning;
    if (temp >= 60) return AppColors.accentTeal;
    return AppColors.success;
  }
}

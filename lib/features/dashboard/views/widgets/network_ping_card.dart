import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../controllers/dashboard_controller.dart';

/// Network Ping/Latency Card - Shows network latency over time
/// Glassmorphism design for v3.0
class NetworkPingCard extends GetView<DashboardController> {
  const NetworkPingCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final pingHistory = controller.pingLatencyHistory;
      final currentLatency = controller.pingLatency.value;

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
                    Icons.network_ping,
                    color: AppColors.accentCyan,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceMD),
                Expanded(
                  child: Text(
                    'Network Latency',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textPrimary : Colors.black87,
                    ),
                  ),
                ),
                _buildLatencyBadge(currentLatency, isDark),
              ],
            ),

            const SizedBox(height: AppDimensions.spaceMD),

            // Latency Chart
            if (pingHistory.isEmpty)
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
                        'Loading network data...',
                        style: TextStyle(
                          color: isDark ? AppColors.textSecondary : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: [
                  // Chart
                  SizedBox(
                    height: 150,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 50,
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
                          show: false,
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.black.withOpacity(0.1),
                          ),
                        ),
                        minX: pingHistory.first.x,
                        maxX: pingHistory.last.x,
                        minY: 0,
                        maxY: _calculateMaxY(pingHistory),
                        lineBarsData: [
                          LineChartBarData(
                            spots: pingHistory,
                            isCurved: true,
                            curveSmoothness: 0.3,
                            color: AppColors.accentCyan,
                            barWidth: 2,
                            isStrokeCapRound: true,
                            dotData: FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.accentCyan.withOpacity(0.3),
                                  AppColors.accentCyan.withOpacity(0.0),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ],
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipColor: (touchedSpot) => isDark
                                ? Colors.black87
                                : Colors.white,
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots.map((spot) {
                                return LineTooltipItem(
                                  '${spot.y.toStringAsFixed(1)} ms',
                                  TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }).toList();
                            },
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spaceMD),

                  // Connection Quality Indicator
                  _buildQualityIndicator(currentLatency, isDark),
                ],
              ),
          ],
        ),
      );
    });
  }

  Widget _buildLatencyBadge(double latency, bool isDark) {
    final Color color = _getLatencyColor(latency);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceSM,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
        border: Border.all(
          color: color,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.network_ping, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            '${latency.toStringAsFixed(1)} ms',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityIndicator(double latency, bool isDark) {
    String quality;
    Color color;
    IconData icon;

    if (latency < 50) {
      quality = 'Excellent';
      color = AppColors.success;
      icon = Icons.sentiment_very_satisfied;
    } else if (latency < 100) {
      quality = 'Good';
      color = AppColors.success;
      icon = Icons.sentiment_satisfied;
    } else if (latency < 200) {
      quality = 'Fair';
      color = AppColors.warning;
      icon = Icons.sentiment_neutral;
    } else {
      quality = 'Poor';
      color = AppColors.error;
      icon = Icons.sentiment_dissatisfied;
    }

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceMD),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: AppDimensions.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Connection Quality',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.textTertiary : Colors.black45,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  quality,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getLatencyColor(double latency) {
    if (latency < 50) return AppColors.success;
    if (latency < 100) return AppColors.success;
    if (latency < 200) return AppColors.warning;
    return AppColors.error;
  }

  double _calculateMaxY(List<FlSpot> spots) {
    if (spots.isEmpty) return 100;
    final maxValue = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    return (maxValue * 1.2).ceilToDouble();
  }
}

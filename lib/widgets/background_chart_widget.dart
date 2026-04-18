import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';

class BackgroundChartWidget extends ConsumerStatefulWidget {
  const BackgroundChartWidget({super.key});

  @override
  ConsumerState<BackgroundChartWidget> createState() =>
      _BackgroundChartWidgetState();
}

class _BackgroundChartWidgetState extends ConsumerState<BackgroundChartWidget> {
  final Queue<double> _cpuHistory = Queue();
  final int maxDataPoints = 30; // 60 seconds at 2s interval

  @override
  Widget build(BuildContext context) {
    ref.listen(liveStatsProvider, (previous, next) {
      if (next.hasValue && next.value != null) {
        if (mounted) {
          setState(() {
            _cpuHistory.add(next.value!.cpuUsage);
            if (_cpuHistory.length > maxDataPoints) {
              _cpuHistory.removeFirst();
            }
          });
        }
      }
    });

    if (_cpuHistory.isEmpty) {
      return Container(color: AppTheme.background);
    }

    return Container(
      color: AppTheme.background,
      child: Opacity(
        opacity: 0.15, // Subtle background
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(show: false),
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
                barWidth: 2,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: AppTheme.primaryIndigo.withValues(alpha: 0.2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

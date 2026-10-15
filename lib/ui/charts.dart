import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../theme/tokens.dart';
import 'cards.dart';

/// One series of a [LineChartCard]
class ChartSeries {
  final String label;
  final Color color;
  final List<double> values;

  /// Current value as text, shown in the legend
  final String current;

  const ChartSeries({required this.label, required this.color, required this.values, required this.current});
}

/// A card with a title, legend and a live line chart whose newest point is
/// at the right edge
class LineChartCard extends StatelessWidget {
  final String title;
  final List<ChartSeries> series;

  /// Points the x axis holds; older values scroll out on the left
  final int capacity;

  /// Fixed top of the y axis (e.g. 100 for percentages); otherwise it follows
  /// the data with [minTop] as the smallest top
  final double? maxY;
  final double minTop;
  final double height;

  /// Labels on the y axis; none when null
  final String Function(double value)? axisLabel;
  final Widget? footer;
  final IconData? icon;

  const LineChartCard({
    super.key,
    required this.title,
    required this.series,
    required this.capacity,
    this.maxY,
    this.minTop = 1024,
    this.height = 120,
    this.axisLabel,
    this.footer,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final peak = series.expand((s) => s.values).fold<double>(0, math.max);
    final top = maxY ?? math.max(minTop, peak * 1.25);
    final legendStyle = context.tt.labelMedium?.copyWith(fontFeatures: tabularFigures);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: context.cs.onSurfaceVariant),
                const Gap(Insets.sm),
              ],
              Expanded(child: Text(title, style: context.tt.titleMedium)),
            ],
          ),
          const Gap(Insets.xs),
          Wrap(
            spacing: Insets.md,
            runSpacing: Insets.xxs,
            children: [
              for (final s in series)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: s.color, shape: BoxShape.circle)),
                    const Gap(Insets.xs),
                    Text('${s.label} ${s.current}', style: legendStyle),
                  ],
                ),
            ],
          ),
          const Gap(Insets.md),
          SizedBox(
            height: height,
            child: series.every((s) => s.values.length < 2)
                ? Center(
                    child: Text(
                      'Collecting data…',
                      style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant),
                    ),
                  )
                : LineChart(
                    duration: Duration.zero,
                    LineChartData(
                      minY: 0,
                      maxY: top,
                      minX: 0,
                      maxX: (capacity - 1).toDouble(),
                      gridData: FlGridData(
                        drawVerticalLine: false,
                        horizontalInterval: top / 4,
                        getDrawingHorizontalLine: (_) =>
                            FlLine(color: context.cs.outlineVariant.withValues(alpha: 0.4), strokeWidth: 1),
                      ),
                      titlesData: axisLabel == null
                          ? const FlTitlesData(show: false)
                          : FlTitlesData(
                              topTitles: const AxisTitles(),
                              rightTitles: const AxisTitles(),
                              bottomTitles: const AxisTitles(),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 64,
                                  interval: top / 2,
                                  getTitlesWidget: (v, meta) => Text(
                                    axisLabel!(v),
                                    style: context.tt.labelSmall?.copyWith(
                                      color: context.cs.onSurfaceVariant,
                                      fontFeatures: tabularFigures,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                      borderData: FlBorderData(show: false),
                      lineTouchData: const LineTouchData(enabled: false),
                      lineBarsData: [
                        for (final s in series)
                          LineChartBarData(
                            spots: [
                              for (var j = 0; j < s.values.length; j++)
                                FlSpot((capacity - s.values.length + j).toDouble(), s.values[j]),
                            ],
                            isCurved: true,
                            preventCurveOverShooting: true,
                            color: s.color,
                            barWidth: 2,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [s.color.withValues(alpha: 0.22), s.color.withValues(alpha: 0)],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
          if (footer != null) ...[const Gap(Insets.md), footer!],
        ],
      ),
    );
  }
}

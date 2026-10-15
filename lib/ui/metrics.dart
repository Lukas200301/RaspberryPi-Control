import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../theme/tokens.dart';
import 'cards.dart';

/// Tone of a usage percentage: green, amber above [warn], red above [critical]
Tone usageTone(double percent, {double warn = 70, double critical = 90}) {
  if (percent >= critical) return Tone.danger;
  if (percent >= warn) return Tone.warning;
  return Tone.success;
}

/// Circular gauge for a 0..1 value with something in the middle
class RingGauge extends StatelessWidget {
  final double value;
  final double size;
  final double stroke;
  final Color? color;
  final Widget? center;

  const RingGauge({
    super.key,
    required this.value,
    this.size = 88,
    this.stroke = 9,
    this.color,
    this.center,
  });

  @override
  Widget build(BuildContext context) {
    final fg = color ?? context.cs.primary;
    final track = context.cs.surfaceContainerHighest;
    final target = value.isNaN ? 0.0 : value.clamp(0.0, 1.0);
    final animate = !MediaQuery.disableAnimationsOf(context);

    Widget ring(double v) => CustomPaint(
      size: Size.square(size),
      painter: _RingPainter(v, fg, track, stroke),
      child: SizedBox.square(
        dimension: size,
        child: Center(child: center),
      ),
    );

    if (!animate) return ring(target);
    return TweenAnimationBuilder<double>(
      tween: Tween(end: target),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (_, v, _) => ring(v),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double value;
  final Color color;
  final Color track;
  final double stroke;

  _RingPainter(this.value, this.color, this.track, this.stroke);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final arc = rect.deflate(stroke / 2);
    const start = math.pi * 0.75;
    const sweep = math.pi * 1.5;
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(arc, start, sweep, false, base..color = track);
    if (value > 0) {
      canvas.drawArc(arc, start, sweep * value, false, base..color = color);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.color != color || old.track != track;
}

/// Thin rounded progress bar
class UsageBar extends StatelessWidget {
  final double value;
  final Color? color;
  final double height;

  const UsageBar({super.key, required this.value, this.color, this.height = 8});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        value: value.isNaN ? 0 : value.clamp(0.0, 1.0),
        minHeight: height,
        color: color ?? context.cs.primary,
        backgroundColor: context.cs.surfaceContainerHighest,
      ),
    );
  }
}

/// Small line chart without axes
class Sparkline extends StatelessWidget {
  final List<double> values;
  final Color? color;
  final double height;
  final double? maxY;
  final int capacity;

  const Sparkline({
    super.key,
    required this.values,
    this.color,
    this.height = 40,
    this.maxY,
    this.capacity = 30,
  });

  @override
  Widget build(BuildContext context) {
    final fg = color ?? context.cs.primary;
    if (values.length < 2) return SizedBox(height: height);
    final peak = values.reduce(math.max);
    final top = maxY ?? math.max(1.0, peak * 1.2);
    final count = math.max(capacity, values.length);
    return SizedBox(
      height: height,
      child: LineChart(
        duration: Duration.zero,
        LineChartData(
          minY: 0,
          maxY: top,
          minX: 0,
          maxX: (count - 1).toDouble(),
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var i = 0; i < values.length; i++)
                  FlSpot((count - values.length + i).toDouble(), values[i]),
              ],
              isCurved: true,
              preventCurveOverShooting: true,
              color: fg,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [fg.withValues(alpha: 0.28), fg.withValues(alpha: 0)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A labeled metric: icon, big value, optional bar and sparkline
class MetricTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? unit;
  final String? caption;
  final Tone tone;
  final double? progress;
  final List<double>? history;
  final double? historyMax;
  final VoidCallback? onTap;

  const MetricTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.unit,
    this.caption,
    this.tone = Tone.primary,
    this.progress,
    this.history,
    this.historyMax,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = context.tone(tone);
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const Gap(Insets.sm),
              Expanded(
                child: Text(
                  label,
                  style: context.tt.labelLarge?.copyWith(
                    color: context.cs.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Gap(Insets.sm),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: value),
                if (unit != null)
                  TextSpan(
                    text: ' $unit',
                    style: context.tt.titleSmall?.copyWith(
                      color: context.cs.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
            style: context.tt.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              fontFeatures: tabularFigures,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (caption != null)
            Text(
              caption!,
              style: context.tt.bodySmall?.copyWith(
                color: context.cs.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          if (progress != null) ...[
            const Gap(Insets.md),
            UsageBar(value: progress!, color: color, height: 6),
          ],
          if (history != null) ...[
            const Gap(Insets.sm),
            Sparkline(values: history!, color: color, height: 36, maxY: historyMax),
          ],
        ],
      ),
    );
  }
}

/// Human readable byte size
String formatBytes(num bytes, {int decimals = 1}) {
  if (bytes <= 0) return '0 B';
  const units = ['B', 'KB', 'MB', 'GB', 'TB'];
  var value = bytes.toDouble();
  var unit = 0;
  while (value >= 1024 && unit < units.length - 1) {
    value /= 1024;
    unit++;
  }
  return '${value.toStringAsFixed(unit == 0 ? 0 : decimals)} ${units[unit]}';
}

/// Uptime like 3d 4h, 5h 12m or 42s
String formatDuration(Duration d) {
  if (d.isNegative) return '0s';
  if (d.inDays > 0) return '${d.inDays}d ${d.inHours % 24}h';
  if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes % 60}m';
  if (d.inMinutes > 0) return '${d.inMinutes}m';
  return '${d.inSeconds}s';
}

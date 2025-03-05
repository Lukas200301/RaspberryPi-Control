import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CpuChartWidget extends StatelessWidget {
  final List<FlSpot> cpuHistory;
  final List<FlSpot> cpuUserHistory;
  final List<FlSpot> cpuSystemHistory;
  final List<FlSpot> cpuNiceHistory;
  final List<FlSpot> cpuIoWaitHistory;
  final List<FlSpot> cpuIrqHistory;
  final double timeIndex;

  const CpuChartWidget({
    Key? key,
    required this.cpuHistory,
    required this.cpuUserHistory,
    required this.cpuSystemHistory,
    required this.cpuNiceHistory,
    required this.cpuIoWaitHistory,
    required this.cpuIrqHistory,
    required this.timeIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'CPU Usage',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Max: 100%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${cpuHistory.isEmpty ? 0 : cpuHistory.last.y.toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: true),
                  minX: cpuHistory.isEmpty ? 0 : cpuHistory.first.x,
                  maxX: cpuHistory.isEmpty ? timeIndex : cpuHistory.last.x,
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: cpuUserHistory,
                      isCurved: true,
                      colors: [Colors.yellow],
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: cpuSystemHistory,
                      isCurved: true,
                      colors: [Colors.red],
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: cpuNiceHistory,
                      isCurved: true,
                      colors: [Colors.green],
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: cpuIoWaitHistory,
                      isCurved: true,
                      colors: [Colors.orange],
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: cpuIrqHistory,
                      isCurved: true,
                      colors: [Colors.purple],
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _buildLegendItem('User', Colors.yellow),
                _buildLegendItem('System', Colors.red),
                _buildLegendItem('Nice', Colors.green),
                _buildLegendItem('I/O Wait', Colors.orange),
                _buildLegendItem('IRQ', Colors.purple),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TemperatureChartWidget extends StatelessWidget {
  final List<FlSpot> cpuTempHistory;
  final List<FlSpot> gpuTempHistory;
  final double timeIndex;

  const TemperatureChartWidget({
    Key? key,
    required this.cpuTempHistory,
    required this.gpuTempHistory,
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
            const Text(
              'Temperature',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'CPU: ${cpuTempHistory.isEmpty ? "N/A" : "${cpuTempHistory.last.y.toStringAsFixed(1)}°C"}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                Text(
                  'GPU: ${gpuTempHistory.isEmpty ? "N/A" : "${gpuTempHistory.last.y.toStringAsFixed(1)}°C"}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: true),
                  minX: cpuTempHistory.isEmpty ? 0 : cpuTempHistory.first.x,
                  maxX: cpuTempHistory.isEmpty ? timeIndex : cpuTempHistory.last.x,
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: cpuTempHistory,
                      isCurved: true,
                      colors: [Colors.red],
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        colors: [Colors.red.withOpacity(0.1), Colors.red.withOpacity(0)],
                      ),
                    ),
                    LineChartBarData(
                      spots: gpuTempHistory,
                      isCurved: true,
                      colors: [Colors.orange],
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        colors: [Colors.orange.withOpacity(0.1), Colors.orange.withOpacity(0)],
                      ),
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
                _buildLegendItem('CPU', Colors.red),
                _buildLegendItem('GPU', Colors.orange),
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

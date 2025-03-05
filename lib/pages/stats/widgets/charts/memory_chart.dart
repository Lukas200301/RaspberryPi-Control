import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MemoryChartWidget extends StatelessWidget {
  final List<FlSpot> memoryHistory;
  final double memoryTotal;
  final double timeIndex;

  const MemoryChartWidget({
    Key? key,
    required this.memoryHistory,
    required this.memoryTotal,
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
              children: [
                const Text(
                  'Memory Usage',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Max: ${memoryTotal.toStringAsFixed(0)} MB',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${memoryHistory.isEmpty ? 0 : memoryHistory.last.y.toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
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
                  minX: memoryHistory.isEmpty ? 0 : memoryHistory.first.x,
                  maxX: memoryHistory.isEmpty ? timeIndex : memoryHistory.last.x,
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: memoryHistory,
                      isCurved: true,
                      colors: [Colors.green],
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        colors: [Colors.green.withOpacity(0.1), Colors.green.withOpacity(0)],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class NetworkChartWidget extends StatelessWidget {
  final List<FlSpot> networkInHistory;
  final List<FlSpot> networkOutHistory;
  final double timeIndex;

  const NetworkChartWidget({
    Key? key,
    required this.networkInHistory,
    required this.networkOutHistory,
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
              'Network Traffic',
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
                  'IN: ${networkInHistory.isEmpty ? "0" : networkInHistory.last.y.toStringAsFixed(2)} KB/s',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                Text(
                  'OUT: ${networkOutHistory.isEmpty ? "0" : networkOutHistory.last.y.toStringAsFixed(2)} KB/s',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
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
                  minX: networkInHistory.isEmpty ? 0 : networkInHistory.first.x,
                  maxX: networkInHistory.isEmpty ? timeIndex : networkInHistory.last.x,
                  minY: 0,
                  maxY: _calculateMaxY(),
                  lineBarsData: [
                    LineChartBarData(
                      spots: networkInHistory,
                      isCurved: true,
                      colors: [Colors.blue],
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        colors: [Colors.blue.withOpacity(0.1), Colors.blue.withOpacity(0)],
                      ),
                    ),
                    LineChartBarData(
                      spots: networkOutHistory,
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
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _buildLegendItem('Download', Colors.blue),
                _buildLegendItem('Upload', Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _calculateMaxY() {
    double maxIn = 10.0;
    double maxOut = 10.0;
    
    if (networkInHistory.isNotEmpty) {
      maxIn = networkInHistory.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    }
    
    if (networkOutHistory.isNotEmpty) {
      maxOut = networkOutHistory.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    }
    
    return (maxIn > maxOut ? maxIn : maxOut) * 1.1;
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

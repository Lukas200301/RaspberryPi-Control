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
    final memoryPercentage = memoryHistory.isEmpty ? 0.0 : memoryHistory.last.y;
    
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Memory Usage',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildMemoryChip(
                  '${memoryPercentage.toStringAsFixed(1)}%',
                  _getMemoryColor(memoryPercentage),
                  '${memoryTotal.toStringAsFixed(0)} MB',
                ),
              ],
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(height: 1),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
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
                      color: Colors.green,
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.green.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMemoryChip(String percentage, Color color, String totalMemory) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.memory, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            percentage,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getMemoryColor(double percentage) {
    if (percentage >= 90) {
      return Colors.red;
    } else if (percentage >= 70) {
      return Colors.orange;
    } else if (percentage >= 50) {
      return Colors.amber;
    } else {
      return Colors.green;
    }
  }
}

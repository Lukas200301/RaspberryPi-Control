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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'CPU Usage',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildPercentageChip(
                  cpuHistory.isEmpty ? "0.0" : cpuHistory.last.y.toStringAsFixed(1),
                  getCpuLoadColor(cpuHistory.isEmpty ? 0 : cpuHistory.last.y)
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                          color: Colors.yellow,
                          barWidth: 2,
                          dotData: FlDotData(show: false),
                        ),
                        LineChartBarData(
                          spots: cpuSystemHistory,
                          isCurved: true,
                          color: Colors.red,
                          barWidth: 2,
                          dotData: FlDotData(show: false),
                        ),
                        LineChartBarData(
                          spots: cpuNiceHistory,
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 2,
                          dotData: FlDotData(show: false),
                        ),
                        LineChartBarData(
                          spots: cpuIoWaitHistory,
                          isCurved: true,
                          color: Colors.orange,
                          barWidth: 2,
                          dotData: FlDotData(show: false),
                        ),
                        LineChartBarData(
                          spots: cpuIrqHistory,
                          isCurved: true,
                          color: Colors.purple,
                          barWidth: 2,
                          dotData: FlDotData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _buildLegendItem('User', Colors.yellow),
                    _buildLegendItem('System', Colors.red),
                    _buildLegendItem('Nice', Colors.blue),
                    _buildLegendItem('I/O Wait', Colors.orange),
                    _buildLegendItem('IRQ', Colors.purple),
                  ],
                ),
              ],
            ),
          ),
        ],
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
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
  
  Widget _buildPercentageChip(String percentage, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.speed, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            '$percentage%',
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
  
  Color getCpuLoadColor(double cpuPercentage) {
    if (cpuPercentage >= 90) {
      return Colors.red;
    } else if (cpuPercentage >= 70) {
      return Colors.orange;
    } else if (cpuPercentage >= 40) {
      return Colors.amber;
    } else {
      return Colors.green;
    }
  }
}

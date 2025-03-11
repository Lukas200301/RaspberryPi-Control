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
    final cpuTemp = cpuTempHistory.isEmpty ? 0.0 : cpuTempHistory.last.y;
    final gpuTemp = gpuTempHistory.isEmpty ? 0.0 : gpuTempHistory.last.y;
    
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
                  'Temperature',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    _buildTempChip('CPU: ${cpuTemp.toStringAsFixed(1)}°C', _getTempColor(cpuTemp)),
                    const SizedBox(width: 8),
                    _buildTempChip('GPU: ${gpuTemp.toStringAsFixed(1)}°C', _getTempColor(gpuTemp)),
                  ],
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
                      minX: cpuTempHistory.isEmpty ? 0 : cpuTempHistory.first.x,
                      maxX: cpuTempHistory.isEmpty ? timeIndex : cpuTempHistory.last.x,
                      minY: 0,
                      maxY: 100,
                      lineBarsData: [
                        LineChartBarData(
                          spots: cpuTempHistory,
                          isCurved: true,
                          color: Colors.red,
                          barWidth: 2,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.red.withOpacity(0.1),
                          ),
                        ),
                        LineChartBarData(
                          spots: gpuTempHistory,
                          isCurved: true,
                          color: Colors.orange,
                          barWidth: 2,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.orange.withOpacity(0.1),
                          ),
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
                    _buildLegendItem('CPU', Colors.red),
                    _buildLegendItem('GPU', Colors.orange),
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
  
  Widget _buildTempChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
  
  Color _getTempColor(double temp) {
    if (temp >= 80) {
      return Colors.red;
    } else if (temp >= 70) {
      return Colors.orange;
    } else if (temp >= 60) {
      return Colors.amber;
    } else {
      return Colors.green;
    }
  }
}

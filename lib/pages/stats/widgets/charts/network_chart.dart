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
    final inRate = networkInHistory.isEmpty ? 0.0 : networkInHistory.last.y;
    final outRate = networkOutHistory.isEmpty ? 0.0 : networkOutHistory.last.y;
    
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
                  'Network Traffic',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    _buildNetworkChip('↓ ${inRate.toStringAsFixed(2)} KB/s', Colors.blue),
                    const SizedBox(width: 8),
                    _buildNetworkChip('↑ ${outRate.toStringAsFixed(2)} KB/s', Colors.green),
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
                      minX: networkInHistory.isEmpty ? 0 : networkInHistory.first.x,
                      maxX: networkInHistory.isEmpty ? timeIndex : networkInHistory.last.x,
                      minY: 0,
                      maxY: _calculateMaxY(),
                      lineBarsData: [
                        LineChartBarData(
                          spots: networkInHistory,
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 2,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.blue.withOpacity(0.1),
                          ),
                        ),
                        LineChartBarData(
                          spots: networkOutHistory,
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
                const SizedBox(height: 16),
                
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _buildLegendItem('Download', Colors.blue),
                    _buildLegendItem('Upload', Colors.green),
                  ],
                ),
              ],
            ),
          ),
        ],
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
  
  Widget _buildNetworkChip(String text, Color color) {
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
}

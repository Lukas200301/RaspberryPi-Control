import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class NetworkPingWidget extends StatelessWidget {
  final List<FlSpot> pingHistory;
  final double timeIndex;
  final double currentLatency;

  const NetworkPingWidget({
    Key? key,
    required this.pingHistory,
    required this.timeIndex,
    required this.currentLatency,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color getLatencyColor(double latency) {
      if (latency < 50) {
        return Colors.green;
      } else if (latency < 100) {
        return Colors.orange;
      } else {
        return Colors.red;
      }
    }

    final latencyColor = getLatencyColor(currentLatency);

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
                  'Network Latency',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildLatencyChip(currentLatency, latencyColor),
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
                      minX: pingHistory.isEmpty ? 0 : pingHistory.first.x,
                      maxX: pingHistory.isEmpty ? timeIndex : pingHistory.last.x,
                      minY: 0,
                      maxY: pingHistory.isEmpty ? 100 : 
                        (pingHistory.map((e) => e.y).reduce((a, b) => a > b ? a : b) * 1.2),
                      lineBarsData: [
                        LineChartBarData(
                          spots: pingHistory,
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 2,
                          dotData: FlDotData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildQualityIndicator(currentLatency),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityIndicator(double latency) {
    String quality;
    Color color;
    IconData icon;
    
    if (latency < 50) {
      quality = 'Excellent';
      color = Colors.green;
      icon = Icons.sentiment_very_satisfied;
    } else if (latency < 100) {
      quality = 'Good';
      color = Colors.lime;
      icon = Icons.sentiment_satisfied;
    } else if (latency < 200) {
      quality = 'Fair';
      color = Colors.orange;
      icon = Icons.sentiment_neutral;
    } else {
      quality = 'Poor';
      color = Colors.red;
      icon = Icons.sentiment_dissatisfied;
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Connection Quality',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                quality,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildLatencyChip(double latency, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.network_ping, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            '${latency.toStringAsFixed(1)} ms',
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
}

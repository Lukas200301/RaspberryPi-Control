import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DiskIOWidget extends StatelessWidget {
  final Map<String, dynamic> ioStats;
  final List<FlSpot> readHistory;
  final List<FlSpot> writeHistory;
  final double timeIndex;

  const DiskIOWidget({
    Key? key,
    required this.ioStats,
    required this.readHistory,
    required this.writeHistory,
    required this.timeIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentRead = ioStats['read_bytes_per_sec'] ?? 0.0;
    final currentWrite = ioStats['write_bytes_per_sec'] ?? 0.0;
    final totalRead = ioStats['total_read'] ?? 'N/A';
    final totalWrite = ioStats['total_write'] ?? 'N/A';
    final iopsRead = ioStats['iops_read'] ?? 0;
    final iopsWrite = ioStats['iops_write'] ?? 0;
    
    String formatBytes(double bytes) {
      if (bytes < 1024) return bytes.toStringAsFixed(1) + ' B/s';
      if (bytes < 1048576) return (bytes / 1024).toStringAsFixed(1) + ' KB/s';
      return (bytes / 1048576).toStringAsFixed(1) + ' MB/s';
    }
    
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
                  'Disk I/O',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    _buildIoChip('R', formatBytes(currentRead), Colors.blue),
                    const SizedBox(width: 8),
                    _buildIoChip('W', formatBytes(currentWrite), Colors.green),
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
                      minX: readHistory.isEmpty ? 0 : readHistory.first.x,
                      maxX: readHistory.isEmpty ? timeIndex : readHistory.last.x,
                      minY: 0,
                      maxY: readHistory.isEmpty && writeHistory.isEmpty ? 100 : 
                        ((readHistory + writeHistory)
                            .map((e) => e.y)
                            .reduce((a, b) => a > b ? a : b) * 1.2),
                      lineBarsData: [
                        LineChartBarData(
                          spots: readHistory,
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 2,
                          dotData: FlDotData(show: false),
                        ),
                        LineChartBarData(
                          spots: writeHistory,
                          isCurved: true,
                          color: Colors.green,
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
                    _buildLegendItem('Read', Colors.blue),
                    const SizedBox(width: 16),
                    _buildLegendItem('Write', Colors.green),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        'Total Read', 
                        totalRead,
                        Icons.arrow_downward,
                        Colors.blue
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoCard(
                        'Total Write', 
                        totalWrite,
                        Icons.arrow_upward,
                        Colors.green
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        'Read IOPS', 
                        iopsRead.toStringAsFixed(1) + ' ops/s',
                        Icons.speed,
                        Colors.blue
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoCard(
                        'Write IOPS', 
                        iopsWrite.toStringAsFixed(1) + ' ops/s',
                        Icons.speed,
                        Colors.green
                      ),
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
  
  Widget _buildIoChip(String direction, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            direction == 'R' ? Icons.arrow_downward : Icons.arrow_upward,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

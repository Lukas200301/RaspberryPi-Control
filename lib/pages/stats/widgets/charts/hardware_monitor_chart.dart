import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class HardwareMonitorChart extends StatelessWidget {
  final List<FlSpot> cpuFreqHistory;
  final List<FlSpot> wifiSignalHistory;
  final double timeIndex;
  final double currentFreq;
  final double coreVoltage;
  final Map<String, bool>? throttlingStatus;

  const HardwareMonitorChart({
    Key? key,
    required this.cpuFreqHistory,
    required this.wifiSignalHistory,
    required this.timeIndex,
    required this.currentFreq,
    required this.coreVoltage,
    this.throttlingStatus,
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
                  'Hardware Monitor',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildFrequencyChip(currentFreq),
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
                _buildThrottlingIndicators(),
                
                const SizedBox(height: 16),
                
                SizedBox(
                  height: 150,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(show: false),
                      borderData: FlBorderData(show: true),
                      minX: cpuFreqHistory.isEmpty ? 0 : cpuFreqHistory.first.x,
                      maxX: cpuFreqHistory.isEmpty ? timeIndex : cpuFreqHistory.last.x,
                      minY: 0,
                      maxY: cpuFreqHistory.isEmpty ? 1500 : 
                          (cpuFreqHistory.map((e) => e.y).reduce((a, b) => a > b ? a : b) * 1.2),
                      lineBarsData: [
                        LineChartBarData(
                          spots: cpuFreqHistory,
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
                
                const Text(
                  'WiFi Signal Strength',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                _buildWifiSignalIndicator(),
                
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        'CPU Frequency', 
                        '${currentFreq.toStringAsFixed(0)} MHz',
                        Colors.purple,
                        Icons.speed
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoCard(
                        'Core Voltage', 
                        '${coreVoltage.toStringAsFixed(2)} V',
                        Colors.orange,
                        Icons.electric_bolt
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

  Widget _buildThrottlingIndicators() {
    if (throttlingStatus == null) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Throttling Status',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildStatusChip('Under Voltage', throttlingStatus!['under_voltage'] ?? false, Colors.red),
            _buildStatusChip('Frequency Capped', throttlingStatus!['freq_capped'] ?? false, Colors.orange),
            _buildStatusChip('Throttled', throttlingStatus!['throttled'] ?? false, Colors.red),
          ],
        ),
      ],
    );
  }

  Widget _buildWifiSignalIndicator() {
    final signalStrength = wifiSignalHistory.isEmpty ? 0.0 : wifiSignalHistory.last.y;
    
    Color signalColor;
    if (signalStrength >= 70) {
      signalColor = Colors.green;
    } else if (signalStrength >= 40) {
      signalColor = Colors.orange;
    } else {
      signalColor = Colors.red;
    }
    
    return Column(
      children: [
        Row(
          children: [
            Icon(
              Icons.wifi,
              color: signalColor,
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: LinearProgressIndicator(
                value: signalStrength / 100,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(signalColor),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${signalStrength.toStringAsFixed(0)}%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: signalColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
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
          const SizedBox(height: 4),
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

  Widget _buildStatusChip(String label, bool isActive, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.2) : Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? color : Colors.grey,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.error_outline : Icons.check_circle_outline,
            color: isActive ? color : Colors.grey,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? color : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFrequencyChip(double frequency) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.speed, size: 14, color: Colors.purple),
          const SizedBox(width: 4),
          Text(
            '${frequency.toStringAsFixed(0)} MHz',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
        ],
      ),
    );
  }
}

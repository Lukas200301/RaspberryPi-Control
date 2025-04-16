import 'package:flutter/material.dart';

class BootPerformanceWidget extends StatelessWidget {
  final Map<String, dynamic> systemInfo;

  const BootPerformanceWidget({
    Key? key,
    required this.systemInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bootStats = systemInfo['boot_stats'] as Map<String, dynamic>? ?? {};
    final bootTime = bootStats['boot_time'] ?? 'Unknown';
    final systemdTime = bootStats['systemd_time'] ?? 'N/A';
    final kernelLoadTime = bootStats['kernel_time'] ?? 'N/A';
    final lastBoot = bootStats['last_boot'] ?? 'Unknown';
    final kernelVersion = systemInfo['kernel_version'] ?? 'Unknown';
    
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
                  'Boot & Kernel',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildChip(
                  text: kernelVersion.toString().length > 10 
                      ? kernelVersion.toString().substring(0, 10) + '...'
                      : kernelVersion.toString(),
                  icon: Icons.architecture,
                  color: Colors.deepPurple,
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
              children: [
                _buildMetricRow(
                  'Last Boot', 
                  lastBoot.toString(),
                  icon: Icons.history,
                  iconColor: Colors.blue,
                ),
                const SizedBox(height: 12),
                _buildMetricRow(
                  'Kernel Version', 
                  kernelVersion.toString(),
                  icon: Icons.architecture,
                  iconColor: Colors.deepPurple,
                ),
                const SizedBox(height: 16),
                
                const Text(
                  'Boot Performance',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                
                _buildPerformanceBar(
                  'Total Boot Time',
                  bootTime,
                  0.8,
                  Colors.red,
                ),
                const SizedBox(height: 8),
                _buildPerformanceBar(
                  'Kernel Load',
                  kernelLoadTime,
                  0.4,
                  Colors.orange,
                ),
                const SizedBox(height: 8),
                _buildPerformanceBar(
                  'Systemd Init',
                  systemdTime,
                  0.6,
                  Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMetricRow(String label, String value, {
    required IconData icon,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildPerformanceBar(String label, String value, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
  
  Widget _buildChip({
    required String text,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
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
}

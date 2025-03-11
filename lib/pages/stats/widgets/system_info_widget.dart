import 'package:flutter/material.dart';

class SystemInfoWidget extends StatelessWidget {
  final Map<String, dynamic> systemInfo;

  const SystemInfoWidget({
    Key? key,
    required this.systemInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String formatUptime(String uptime) {
      if (uptime.isEmpty) return 'N/A';
      
      int days = 0, hours = 0, minutes = 0;
      
      final daysMatch = RegExp(r'(\d+)\s+day').firstMatch(uptime);
      if (daysMatch != null) {
        days = int.parse(daysMatch.group(1) ?? '0');
      }
      
      final timeMatch = RegExp(r'(\d+):(\d+)').firstMatch(uptime);
      if (timeMatch != null) {
        hours = int.parse(timeMatch.group(1) ?? '0');
        minutes = int.parse(timeMatch.group(2) ?? '0');
      } else {
        final hoursMatch = RegExp(r'(\d+)\s+hour').firstMatch(uptime);
        if (hoursMatch != null) {
          hours = int.parse(hoursMatch.group(1) ?? '0');
        }
        
        final minutesMatch = RegExp(r'(\d+)\s+min').firstMatch(uptime);
        if (minutesMatch != null) {
          minutes = int.parse(minutesMatch.group(1) ?? '0');
        }
      }
      
      return '${days}d ${hours}h ${minutes}m';
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
                  'System Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildChip(
                  text: systemInfo['os']?.toString().contains('Debian') ?? false ? 'Debian' : 'Linux',
                  icon: Icons.computer,
                  color: Colors.blue,
                ),
              ],
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(height: 1),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildInfoRow(
                  icon: Icons.computer,
                  label: 'Hostname',
                  value: systemInfo['hostname']?.toString() ?? 'N/A',
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  icon: Icons.tune,
                  label: 'Operating System',
                  value: systemInfo['os']?.toString().replaceAll('Description:', '').trim() ?? 'N/A',
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  icon: Icons.router,
                  label: 'IP Address',
                  value: systemInfo['ip_address']?.toString() ?? 'N/A',
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  icon: Icons.timer_outlined,
                  label: 'Uptime',
                  value: formatUptime(systemInfo['uptime']?.toString() ?? ''),
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  icon: Icons.memory,
                  label: 'CPU Model',
                  value: systemInfo['cpu_model']?.toString() ?? 'N/A',
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  icon: Icons.storage,
                  label: 'Total Disk Space',
                  value: systemInfo['total_disk_space']?.toString() ?? 'N/A',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.blue, size: 20),
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

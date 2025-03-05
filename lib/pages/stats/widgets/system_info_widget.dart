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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'System Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Table(
              border: TableBorder.all(
                color: Colors.grey,
                width: 1,
                style: BorderStyle.solid,
              ),
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(2),
              },
              children: [
                _buildTableRow('Hostname', systemInfo['hostname']?.toString() ?? 'N/A'),
                _buildTableRow('Operating System', systemInfo['os']?.toString().replaceAll('Description:', '').trim() ?? 'N/A'),
                _buildTableRow('IP Address', systemInfo['ip_address']?.toString() ?? 'N/A'),
                _buildTableRow('Uptime', formatUptime(systemInfo['uptime']?.toString() ?? '')),
                _buildTableRow('CPU Model', systemInfo['cpu_model']?.toString() ?? 'N/A'),
                _buildTableRow('Total Disk Space', systemInfo['total_disk_space']?.toString() ?? 'N/A'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
            textAlign: TextAlign.end,
            overflow: TextOverflow.visible,
          ),
        ),
      ],
    );
  }
}

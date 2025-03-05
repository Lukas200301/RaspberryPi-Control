import 'package:flutter/material.dart';

class DiskUsageWidget extends StatelessWidget {
  final List<dynamic> disks;

  const DiskUsageWidget({
    Key? key,
    required this.disks,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Disk Usage',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (disks.isEmpty)
              const Text('No disk information available')
            else
              ...disks.map<Widget>((disk) {
                final usedPercentage = double.tryParse(
                    disk['used_percentage']?.replaceAll('%', '') ?? '0') ?? 0.0;
                Color progressColor;
                if (usedPercentage >= 90) {
                  progressColor = Colors.red;
                } else if (usedPercentage >= 75) {
                  progressColor = Colors.orange;
                } else if (usedPercentage >= 50) {
                  progressColor = Colors.yellow;
                } else {
                  progressColor = Colors.green;
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${disk['name']} - ${disk['size']}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 8,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: usedPercentage / 100,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${disk['used']} used of ${disk['size']} (${disk['used_percentage']})',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Disk Usage',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${disks.length} Volumes',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
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
            child: disks.isEmpty
              ? const Center(
                  child: Text(
                    'No disk information available',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : Column(
                  children: disks.map<Widget>((disk) {
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

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: progressColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.storage,
                                  color: progressColor, 
                                  size: 20
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${disk['name']}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          '${disk['used_percentage']}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: progressColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
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
                                    const SizedBox(height: 6),
                                    Text(
                                      '${disk['used']} used of ${disk['size']}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
          ),
        ],
      ),
    );
  }
}

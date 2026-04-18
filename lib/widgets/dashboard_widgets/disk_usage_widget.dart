import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../providers/app_providers.dart';

class DiskUsageWidget extends ConsumerWidget {
  const DiskUsageWidget({super.key});

  String _formatSize(int bytes) {
    if (bytes > 1e9) return '${(bytes / 1e9).toStringAsFixed(1)} GB';
    if (bytes > 1e6) return '${(bytes / 1e6).toStringAsFixed(0)} MB';
    return '$bytes B';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diskAsync = ref.watch(diskInfoProvider);

    return diskAsync.when(
      data: (disk) {
        if (disk.partitions.isEmpty) {
          return GlassCard(
            child: Row(
              children: [
                const Icon(
                  Icons.storage,
                  color: AppTheme.textTertiary,
                  size: 18,
                ),
                const Gap(8),
                Text(
                  'No disk info',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          );
        }

        return GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.storage,
                    color: AppTheme.secondaryTeal,
                    size: 18,
                  ),
                  const Gap(8),
                  Text(
                    'Disk Usage',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              ),
              const Gap(12),
              ...disk.partitions.take(3).map((p) {
                final total = p.totalBytes.toInt();
                final used = p.usedBytes.toInt();
                final pct = total > 0 ? used / total : 0.0;
                final color = AppTheme.getMemoryColor(pct * 100);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              p.mountPoint,
                              style: Theme.of(context).textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${_formatSize(used)} / ${_formatSize(total)}',
                            style: Theme.of(
                              context,
                            ).textTheme.labelSmall?.copyWith(color: color),
                          ),
                        ],
                      ),
                      const Gap(4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pct.clamp(0.0, 1.0),
                          backgroundColor: AppTheme.glassBorder,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                          minHeight: 5,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
      loading: () => GlassCard(
        child: SizedBox(
          height: 80,
          child: Center(
            child: CircularProgressIndicator(
              color: AppTheme.secondaryTeal,
              strokeWidth: 2,
            ),
          ),
        ),
      ),
      error: (e, _) => GlassCard(
        child: Text(
          'Disk error',
          style: const TextStyle(color: AppTheme.errorRose),
        ),
      ),
    );
  }
}

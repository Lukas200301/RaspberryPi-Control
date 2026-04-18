import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';

class StorageBar extends ConsumerWidget {
  const StorageBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diskInfoAsync = ref.watch(diskInfoProvider);

    return diskInfoAsync.when(
      data: (diskInfo) {
        if (diskInfo.partitions.isEmpty) return const SizedBox.shrink();

        // Find the root partition or the one with the most space
        final partition = diskInfo.partitions.firstWhere(
          (p) => p.mountPoint == '/',
          orElse: () => diskInfo.partitions.first,
        );

        final percent = partition.usagePercent / 100;
        final color = AppTheme.getMemoryColor(partition.usagePercent);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Storage',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${(partition.usedBytes.toDouble() / 1024 / 1024 / 1024).toStringAsFixed(1)} GB / ${(partition.totalBytes.toDouble() / 1024 / 1024 / 1024).toStringAsFixed(1)} GB',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const Gap(8),
              Container(
                height: 6,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.glassBorder,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: percent.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.5),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: LinearProgressIndicator(
          minHeight: 2,
          backgroundColor: AppTheme.glassBorder,
        ),
      ),
      error: (err, st) => const SizedBox.shrink(),
    );
  }
}

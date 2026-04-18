import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/animated_status_badge.dart';
import '../../services/docker_service.dart' as docker;

class DockerStatusWidget extends ConsumerWidget {
  const DockerStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final containersAsync = ref.watch(docker.containerListProvider);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.view_in_ar, color: Color(0xFF2196F3), size: 18),
              const Gap(8),
              Text('Docker', style: Theme.of(context).textTheme.titleSmall),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh, size: 16),
                color: AppTheme.textTertiary,
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                onPressed: () => ref.invalidate(docker.containerListProvider),
              ),
            ],
          ),
          const Gap(10),
          containersAsync.when(
            data: (containers) {
              if (containers.isEmpty) {
                return Text(
                  'No containers found',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppTheme.textTertiary),
                );
              }
              final top4 = containers.take(4).toList();
              return Column(
                children: top4.map((c) {
                  final isRunning = c.state.toLowerCase() == 'running';
                  final name = c.names.isNotEmpty
                      ? c.names.first.replaceFirst('/', '')
                      : c.id.substring(0, 8);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        AnimatedStatusBadge(
                          state: isRunning
                              ? ServiceAnimState.running
                              : ServiceAnimState.stopped,
                          size: 8,
                        ),
                        const Gap(10),
                        Expanded(
                          child: Text(
                            name,
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                (isRunning
                                        ? AppTheme.successGreen
                                        : AppTheme.textTertiary)
                                    .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            c.state,
                            style: TextStyle(
                              fontSize: 9,
                              color: isRunning
                                  ? AppTheme.successGreen
                                  : AppTheme.textTertiary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const SizedBox(
              height: 60,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF2196F3),
                ),
              ),
            ),
            error: (e, _) => Text(
              'Docker unavailable',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.textTertiary),
            ),
          ),
        ],
      ),
    );
  }
}

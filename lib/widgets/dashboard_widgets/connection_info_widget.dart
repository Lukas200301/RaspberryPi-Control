import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../providers/app_providers.dart';
import '../../widgets/animated_status_badge.dart';

class ConnectionInfoWidget extends ConsumerWidget {
  final VoidCallback onDisconnect;

  const ConnectionInfoWidget({super.key, required this.onDisconnect});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentConnection = ref.watch(currentConnectionProvider);

    return GlassCard(
      glowColor: AppTheme.successGreen,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppTheme.primaryIndigo, AppTheme.secondaryTeal],
              ),
            ),
            child: const Icon(Icons.computer, color: Colors.white, size: 22),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      currentConnection?.name ?? 'Not connected',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const Gap(8),
                    const AnimatedStatusBadge(
                      state: ServiceAnimState.running,
                      size: 7,
                    ),
                  ],
                ),
                const Gap(2),
                if (currentConnection != null)
                  Text(
                    '${currentConnection.username}@${currentConnection.host}',
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, size: 20),
            color: AppTheme.errorRose,
            tooltip: 'Disconnect',
            onPressed: onDisconnect,
          ),
        ],
      ),
    );
  }
}

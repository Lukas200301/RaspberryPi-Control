import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../screens/stats_screen.dart';
import '../../screens/services_screen.dart';
import '../../screens/processes_screen.dart';
import '../../screens/docker_screen.dart';
import '../../screens/logs_screen.dart';
import '../../screens/network_tools_screen.dart';
import '../../screens/network_connections_screen.dart';
import '../../screens/packages_screen.dart';
import '../../screens/system_update_screen.dart';

class QuickActionsWidget extends ConsumerWidget {
  const QuickActionsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = _buildActions(context);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.grid_view_rounded, color: AppTheme.warningAmber, size: 18),
              const Gap(8),
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
          const Gap(12),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.95,
            children: actions
                .map(
                  (a) =>
                      _actionTile(context, a.icon, a.label, a.color, a.onTap),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  List<_Action> _buildActions(BuildContext context) => [
    _Action(
      Icons.analytics,
      'Stats',
      AppTheme.primaryIndigo,
      () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const StatsScreen()),
      ),
    ),
    _Action(
      Icons.settings_applications,
      'Services',
      AppTheme.secondaryTeal,
      () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ServicesScreen()),
      ),
    ),
    _Action(
      Icons.apps,
      'Processes',
      AppTheme.errorRose,
      () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProcessesScreen()),
      ),
    ),
    _Action(
      Icons.view_in_ar,
      'Docker',
      const Color(0xFF0D47A1),
      () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DockerScreen()),
      ),
    ),
    _Action(
      Icons.receipt_long,
      'Logs',
      const Color(0xFF8B5CF6),
      () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LogsScreen()),
      ),
    ),
    _Action(
      Icons.network_check,
      'Network',
      const Color(0xFF06B6D4),
      () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const NetworkToolsScreen()),
      ),
    ),
    _Action(
      Icons.cable,
      'Connections',
      const Color(0xFF10B981),
      () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const NetworkConnectionsScreen()),
      ),
    ),
    _Action(
      Icons.inventory_2,
      'Packages',
      const Color(0xFFEC4899),
      () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PackagesScreen()),
      ),
    ),
    _Action(
      Icons.system_update,
      'Updates',
      const Color(0xFFFF6B35),
      () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SystemUpdateScreen()),
      ),
    ),
  ];

  Widget _actionTile(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: color.withValues(alpha: 0.12),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const Gap(5),
            Text(
              label,
              style: TextStyle(
                fontSize: 9.5,
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _Action {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _Action(this.icon, this.label, this.color, this.onTap);
}

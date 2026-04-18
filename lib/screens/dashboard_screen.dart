import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';
import '../providers/file_providers.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/dashboard_widgets/system_vitals_widget.dart';
import '../widgets/dashboard_widgets/disk_usage_widget.dart';
import '../widgets/dashboard_widgets/quick_actions_widget.dart';
import '../widgets/dashboard_widgets/connection_info_widget.dart';
import '../services/agent_version_service.dart';
import '../widgets/agent_update_banner.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final widgetOrder = ref.watch(dashboardLayoutProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        actions: [
          Builder(
            builder: (innerContext) => IconButton(
              icon: const Icon(Icons.widgets_outlined),
              tooltip: 'Customize Widgets',
              onPressed: () => _showWidgetPicker(innerContext, ref),
            ),
          ),
        ],
      ),
      body: _buildBody(context, ref, widgetOrder),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    List<DashboardWidgetType> order,
  ) {
    final currentConnection = ref.watch(currentConnectionProvider);

    Widget buildWidgetForType(DashboardWidgetType type) {
      switch (type) {
        case DashboardWidgetType.connectionInfo:
          return ConnectionInfoWidget(
            key: const Key('connectionInfo'),
            onDisconnect: () => _disconnect(context, ref),
          );
        case DashboardWidgetType.systemVitals:
          return const SystemVitalsWidget(key: Key('systemVitals'));
        case DashboardWidgetType.diskUsage:
          return const DiskUsageWidget(key: Key('diskUsage'));
        case DashboardWidgetType.quickActions:
          return const QuickActionsWidget(key: Key('quickActions'));
      }
    }

    // Build agent update banner if needed
    Widget? updateBanner;
    if (currentConnection != null &&
        AgentVersionService.checkVersion(currentConnection.agentVersion) ==
            AgentVersionStatus.outdated) {
      updateBanner = Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: AgentUpdateBanner(
          connection: currentConnection,
          onDismiss: () {},
        ),
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      header: updateBanner,
      itemCount: order.length,
      onReorder: (oldIndex, newIndex) {
        ref.read(dashboardLayoutProvider.notifier).reorder(oldIndex, newIndex);
      },
      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Material(
              elevation: 6 * animation.value,
              borderRadius: BorderRadius.circular(16),
              shadowColor: AppTheme.primaryIndigo.withValues(alpha: 0.5),
              color: Colors.transparent,
              child: child,
            );
          },
          child: child,
        );
      },
      itemBuilder: (context, index) {
        final type = order[index];
        return Padding(
          key: Key(type.name),
          padding: const EdgeInsets.only(bottom: 12),
          child: buildWidgetForType(type),
        );
      },
    );
  }

  void _showWidgetPicker(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(dashboardLayoutProvider.notifier);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final order = ref.watch(dashboardLayoutProvider);
          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              border: Border.all(color: AppTheme.glassBorder),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.widgets_outlined,
                      color: AppTheme.primaryIndigo,
                      size: 20,
                    ),
                    const Gap(8),
                    Text(
                      'Dashboard Widgets',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const Gap(4),
                Text(
                  'Long-press on the dashboard to reorder. Toggle visibility here.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Gap(16),
                ...DashboardWidgetType.values.map((type) {
                  final isVisible = order.contains(type);
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      _iconForWidget(type),
                      color: isVisible
                          ? AppTheme.primaryIndigo
                          : AppTheme.textTertiary,
                    ),
                    title: Text(type.displayName),
                    trailing: Switch(
                      value: isVisible,
                      onChanged: (_) => notifier.toggleWidget(type),
                      activeColor: AppTheme.primaryIndigo,
                    ),
                  );
                }),
                const Gap(8),
              ],
            ),
          );
        },
      ),
    );
  }

  IconData _iconForWidget(DashboardWidgetType type) {
    switch (type) {
      case DashboardWidgetType.connectionInfo:
        return Icons.computer;
      case DashboardWidgetType.systemVitals:
        return Icons.monitor_heart;
      case DashboardWidgetType.diskUsage:
        return Icons.storage;
      case DashboardWidgetType.quickActions:
        return Icons.bolt;
    }
  }

  Future<void> _disconnect(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.background,
        title: const Text('Disconnect?'),
        content: const Text(
          'Are you sure you want to disconnect from this device?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRose,
            ),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      ref.read(fileTransfersProvider.notifier).clearAll();
      ref.read(currentConnectionProvider.notifier).setConnection(null);
      final connectionManager = ref.read(connectionManagerProvider);
      connectionManager
          .disconnect()
          .timeout(
            const Duration(seconds: 2),
            onTimeout: () => debugPrint('Disconnect timeout'),
          )
          .catchError((e) => debugPrint('Disconnect error: $e'));
      Navigator.of(context).pushReplacementNamed('/');
    }
  }
}

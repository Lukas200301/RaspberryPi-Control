import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../providers/app_providers.dart';
import '../providers/dashboard_provider.dart';
import '../services/agent_version_service.dart';
import '../ui/ui.dart';
import '../widgets/agent_update_banner.dart';
import 'alerts/alerts_screen.dart';
import 'dashboard/dashboard_sections.dart';
import 'tools/tool_registry.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout = ref.watch(dashboardLayoutProvider);
    final connection = ref.watch(currentConnectionProvider);
    final outdated = connection != null &&
        AgentVersionService.checkVersion(connection.agentVersion) == AgentVersionStatus.outdated;

    Widget section(DashboardSection s) {
      switch (s) {
        case DashboardSection.vitals:
          return const VitalsSection();
        case DashboardSection.activity:
          return const ActivitySection();
        case DashboardSection.apps:
          return const AppsSection();
        case DashboardSection.tools:
          return const PinnedToolsSection();
        case DashboardSection.processes:
          return const TopProcessesSection();
        case DashboardSection.storage:
          return const StorageSection();
      }
    }

    Widget? trailing(DashboardSection s) {
      if (s == DashboardSection.tools) {
        return TextButton(
          onPressed: () => ref.read(currentScreenProvider.notifier).setScreen(1),
          child: const Text('All tools'),
        );
      }
      final tool = switch (s) {
        DashboardSection.activity => toolById('stats'),
        DashboardSection.processes => toolById('processes'),
        _ => null,
      };
      if (tool == null) return null;
      return TextButton(onPressed: () => tool.open(context), child: const Text('Details'));
    }

    return PageScaffold(
      title: 'Home',
      automaticallyImplyLeading: false,
      actions: [
        const AlertsButton(),
        IconButton(
          tooltip: 'Customize dashboard',
          icon: const Icon(Icons.tune),
          onPressed: () => _customize(context),
        ),
      ],
      body: PageList(
        onRefresh: () async {
          ref.invalidate(diskInfoProvider);
          ref.invalidate(appsSummaryProvider);
        },
        children: [
          if (outdated) ...[
            AgentUpdateBanner(connection: connection, onDismiss: () {}),
            const Gap(Insets.md),
          ],
          const DeviceHeader(),
          for (final s in layout.visible) ...[
            SectionHeader(title: s.label, trailing: trailing(s)),
            section(s),
          ],
          if (layout.visible.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: Insets.xxl),
              child: EmptyState(
                icon: Icons.dashboard_customize_outlined,
                title: 'Your dashboard is empty',
                action: FilledButton.tonal(onPressed: () => _customize(context), child: const Text('Add sections')),
              ),
            ),
        ],
      ),
    );
  }

  void _customize(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _CustomizeSheet(),
    );
  }
}

class _CustomizeSheet extends ConsumerWidget {
  const _CustomizeSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout = ref.watch(dashboardLayoutProvider);
    final notifier = ref.read(dashboardLayoutProvider.notifier);

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(Insets.xl, 0, Insets.md, Insets.sm),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Customize dashboard', style: context.tt.titleLarge),
                        Text(
                          'Drag to reorder, switch sections on or off',
                          style: context.tt.bodyMedium?.copyWith(color: context.cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  TextButton(onPressed: notifier.reset, child: const Text('Reset')),
                ],
              ),
            ),
            Flexible(
              child: ReorderableListView(
                shrinkWrap: true,
                buildDefaultDragHandles: false,
                onReorderItem: notifier.reorderItem,
                children: [
                  for (var i = 0; i < layout.order.length; i++)
                    ListTile(
                      key: ValueKey(layout.order[i]),
                      leading: ReorderableDragStartListener(
                        index: i,
                        child: const Icon(Icons.drag_indicator),
                      ),
                      title: Text(layout.order[i].label),
                      subtitle: Text(layout.order[i].description),
                      trailing: Switch(
                        value: !layout.hidden.contains(layout.order[i]),
                        onChanged: (v) => notifier.setVisible(layout.order[i], v),
                      ),
                    ),
                ],
              ),
            ),
            const Gap(Insets.sm),
          ],
        ),
      ),
    );
  }
}

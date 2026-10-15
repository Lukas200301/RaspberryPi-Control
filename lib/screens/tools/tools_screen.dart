import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../ui/ui.dart';
import 'tool_registry.dart';

/// Hub with every tool, grouped by category and searchable
class ToolsScreen extends ConsumerStatefulWidget {
  const ToolsScreen({super.key});

  @override
  ConsumerState<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends ConsumerState<ToolsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final pinned = ref.watch(pinnedToolsProvider);
    final pinnedTools = [for (final id in pinned) ?toolById(id)];
    final results = allTools.where((t) => t.matches(_query)).toList();

    return PageScaffold(
      title: 'Tools',
      automaticallyImplyLeading: false,
      body: PageList(
        children: [
          SearchField(
            hint: 'Search tools',
            onChanged: (v) => setState(() => _query = v),
          ),
          if (_query.isNotEmpty) ...[
            const Gap(Insets.lg),
            if (results.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: Insets.xxl),
                child: EmptyState(
                  icon: Icons.search_off,
                  title: 'No tool found',
                  message: 'Try another word, e.g. "cpu", "port" or "apt".',
                ),
              )
            else
              ResponsiveGrid(
                minItemWidth: 300,
                children: [for (final t in results) _ToolCard(tool: t)],
              ),
          ] else ...[
            if (pinnedTools.isNotEmpty) ...[
              const SectionHeader(
                title: 'Pinned',
                subtitle: 'Also shown on the dashboard. Long-press a tool to pin or unpin it.',
              ),
              ResponsiveGrid(
                minItemWidth: 300,
                children: [for (final t in pinnedTools) _ToolCard(tool: t)],
              ),
            ],
            for (final category in ToolCategory.values) ...[
              SectionHeader(title: category.label),
              ResponsiveGrid(
                minItemWidth: 300,
                children: [
                  for (final t in allTools.where((t) => t.category == category))
                    _ToolCard(tool: t),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _ToolCard extends ConsumerWidget {
  final ToolDef tool;

  const _ToolCard({required this.tool});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pinned = ref.watch(pinnedToolsProvider).contains(tool.id);

    return AppCard(
      padding: const EdgeInsets.all(Insets.md),
      onTap: () => tool.open(context),
      onLongPress: () => showActionSheet(
        context,
        title: tool.title,
        subtitle: tool.description,
        actions: [
          SheetAction(
            icon: Icons.open_in_new,
            label: 'Open',
            onTap: () => tool.open(context),
          ),
          SheetAction(
            icon: pinned ? Icons.push_pin_outlined : Icons.push_pin,
            label: pinned ? 'Unpin' : 'Pin to dashboard',
            onTap: () => ref.read(pinnedToolsProvider.notifier).toggle(tool.id),
          ),
        ],
      ),
      child: Row(
        children: [
          IconBadge(tool.icon, color: tool.color, size: 48),
          const Gap(Insets.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        tool.title,
                        style: context.tt.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (pinned) ...[
                      const Gap(Insets.xs),
                      Icon(Icons.push_pin, size: 14, color: context.cs.primary),
                    ],
                  ],
                ),
                const Gap(2),
                Text(
                  tool.description,
                  style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: context.cs.onSurfaceVariant),
        ],
      ),
    );
  }
}

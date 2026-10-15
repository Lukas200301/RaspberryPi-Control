import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../theme/tokens.dart';

/// Centers its child and limits it to a readable width on large screens
class ContentWidth extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ContentWidth({
    super.key,
    required this.child,
    this.maxWidth = Breakpoints.maxContent,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// Standard page: app bar, optional bar below it (search, filters), content
/// limited to a readable width and an optional FAB.
class PageScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final Widget body;
  final Widget? floatingActionButton;
  final PreferredSizeWidget? bottom;

  /// Pinned below the content (the FAB floats above it)
  final Widget? bottomBar;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final double maxWidth;

  const PageScaffold({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    required this.body,
    this.floatingActionButton,
    this.bottom,
    this.bottomBar,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.maxWidth = Breakpoints.maxContent,
  });

  @override
  Widget build(BuildContext context) {
    // Top-level pages (no back button) get a larger title
    final large = !automaticallyImplyLeading;
    final titleStyle = large ? context.tt.headlineSmall?.copyWith(fontWeight: FontWeight.w700) : null;
    return Scaffold(
      appBar: AppBar(
        leading: leading,
        automaticallyImplyLeading: automaticallyImplyLeading,
        toolbarHeight: large ? 68 : null,
        title: subtitle == null
            ? Text(title, style: titleStyle)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: titleStyle),
                  Text(
                    subtitle!,
                    style: context.tt.bodySmall?.copyWith(
                      color: context.cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
        actions: [...actions, const Gap(Insets.xs)],
        bottom: bottom,
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomBar,
      body: ContentWidth(maxWidth: maxWidth, child: body),
    );
  }
}

/// A list page body with the standard padding (room for a FAB at the end)
class PageList extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final Future<void> Function()? onRefresh;
  final ScrollController? controller;

  const PageList({
    super.key,
    required this.children,
    this.padding,
    this.onRefresh,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final list = ListView(
      controller: controller,
      physics: const AlwaysScrollableScrollPhysics(),
      padding:
          padding ??
          const EdgeInsets.fromLTRB(Insets.page, Insets.sm, Insets.page, 96),
      children: children,
    );
    if (onRefresh == null) return list;
    return RefreshIndicator(onRefresh: onRefresh!, child: list);
  }
}

/// Lays children out in as many columns as fit [minItemWidth]
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double minItemWidth;
  final double spacing;
  final int maxColumns;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.minItemWidth = 320,
    this.spacing = Insets.md,
    this.maxColumns = 4,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = (constraints.maxWidth / minItemWidth).floor().clamp(
          1,
          maxColumns,
        );
        if (columns == 1) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) Gap(spacing),
                children[i],
              ],
            ],
          );
        }
        final itemWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}

/// Title above a group of content, with an optional action on the right
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(
      Insets.xs,
      Insets.lg,
      Insets.xs,
      Insets.sm,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.tt.titleSmall?.copyWith(
                    color: context.cs.primary,
                    letterSpacing: 0.2,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: context.tt.bodySmall?.copyWith(
                      color: context.cs.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

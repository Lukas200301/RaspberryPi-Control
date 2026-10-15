import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';

enum CardVariant {
  /// Tonal surface, the default
  filled,

  /// Transparent with an outline
  outlined,

  /// Brighter surface for emphasis
  raised,
}

/// The basic container of the app
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final CardVariant variant;

  /// Tints the border (and slightly the surface) with a status color
  final Color? accent;
  final BorderRadius borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Insets.lg),
    this.onTap,
    this.onLongPress,
    this.variant = CardVariant.filled,
    this.accent,
    this.borderRadius = Radii.cardAll,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final background = switch (variant) {
      CardVariant.filled => cs.surfaceContainerLow,
      CardVariant.outlined => Colors.transparent,
      CardVariant.raised => cs.surfaceContainerHigh,
    };
    final color = accent == null
        ? background
        : Color.alphaBlend(accent!.withValues(alpha: 0.06), background);

    final side = accent != null
        ? BorderSide(color: accent!.withValues(alpha: 0.45))
        : variant == CardVariant.outlined
        ? BorderSide(color: cs.outlineVariant)
        : BorderSide.none;

    return Material(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: borderRadius, side: side),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Rounded square with a tinted icon
class IconBadge extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final Tone tone;
  final double size;

  const IconBadge(
    this.icon, {
    super.key,
    this.color,
    this.tone = Tone.primary,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final fg = color ?? context.tone(tone);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: fg.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Icon(icon, color: fg, size: size * 0.52),
    );
  }
}

/// Small rounded status label
class StatusPill extends StatelessWidget {
  final String label;
  final Tone tone;
  final IconData? icon;
  final bool dot;

  const StatusPill(
    this.label, {
    super.key,
    this.tone = Tone.neutral,
    this.icon,
    this.dot = false,
  });

  @override
  Widget build(BuildContext context) {
    final fg = context.tone(tone);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: fg.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
            const Gap(6),
          ] else if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const Gap(4),
          ],
          Text(
            label,
            style: context.tt.labelMedium?.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// A list row with an icon badge, title, subtitle and optional trailing
/// widget. The workhorse for menus, settings and lists.
class ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Tone tone;
  final Color? color;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool destructive;
  final bool dense;

  const ActionTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.tone = Tone.primary,
    this.color,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.destructive = false,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTone = destructive ? Tone.danger : tone;
    return ListTile(
      onTap: onTap,
      onLongPress: onLongPress,
      dense: dense,
      contentPadding: const EdgeInsets.symmetric(horizontal: Insets.md),
      leading: IconBadge(
        icon,
        tone: effectiveTone,
        color: destructive ? null : color,
        size: dense ? 34 : 40,
      ),
      title: Text(
        title,
        style: context.tt.titleSmall?.copyWith(
          color: destructive ? context.cs.error : null,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: context.tt.bodySmall?.copyWith(
                color: context.cs.onSurfaceVariant,
              ),
            ),
      trailing:
          trailing ??
          (onTap != null
              ? Icon(Icons.chevron_right, color: context.cs.onSurfaceVariant)
              : null),
    );
  }
}

/// Groups tiles in one card, separated by thin dividers
class TileGroup extends StatelessWidget {
  final List<Widget> children;

  const TileGroup({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final visible = children.toList();
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: Insets.xs),
      child: Column(
        children: [
          for (var i = 0; i < visible.length; i++) ...[
            if (i > 0)
              Divider(
                indent: 64,
                endIndent: Insets.lg,
                color: context.cs.outlineVariant.withValues(alpha: 0.4),
              ),
            visible[i],
          ],
        ],
      ),
    );
  }
}

/// Label and value in one row. Long-press copies the value.
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool mono;
  final double labelWidth;
  final Widget? trailing;

  const InfoRow(
    this.label,
    this.value, {
    super.key,
    this.mono = false,
    this.labelWidth = 120,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: Radii.smAll,
      onLongPress: value.isEmpty
          ? null
          : () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text('$label copied')));
            },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: labelWidth,
              child: Text(
                label,
                style: context.tt.bodyMedium?.copyWith(
                  color: context.cs.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value.isEmpty ? '–' : value,
                style: mono
                    ? AppTheme.mono(size: 13, color: context.cs.onSurface)
                    : context.tt.bodyMedium,
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../ui/cards.dart';

/// Former frosted-glass card, now the standard [AppCard]. Kept so existing
/// screens pick up the new design without changes.
class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? glowColor;

  /// Dialog backgrounds use the brighter surface
  final bool solid;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding,
    this.onTap,
    this.glowColor,
    this.solid = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: padding ?? const EdgeInsets.all(16),
      onTap: onTap,
      accent: glowColor,
      variant: solid ? CardVariant.raised : CardVariant.filled,
      borderRadius: BorderRadius.circular(borderRadius),
      child: child,
    );
  }
}

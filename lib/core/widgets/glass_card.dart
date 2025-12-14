import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/theme_controller.dart';

/// Glass Morphism Card Widget
/// Provides frosted glass effect with backdrop blur
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final double? borderRadius;
  final Color? borderColor;
  final double? borderWidth;
  final double? opacity;
  final double? blur;
  final Gradient? gradient;

  const GlassCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
    this.borderRadius,
    this.borderColor,
    this.borderWidth,
    this.opacity,
    this.blur,
    this.gradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeController = Get.find<ThemeController>();

    // Effective blur (respects reduce transparency setting)
    final effectiveBlur = blur ?? themeController.getEffectiveBlur();

    // Effective opacity (respects reduce transparency setting)
    final baseOpacity = opacity ?? (isDark ? 0.15 : 0.4);
    final effectiveOpacity = themeController.getEffectiveOpacity(baseOpacity);

    final effectiveRadius = borderRadius ?? AppDimensions.radiusCard;

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(effectiveRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: effectiveBlur,
            sigmaY: effectiveBlur,
          ),
          child: Container(
            padding: padding ?? const EdgeInsets.all(AppDimensions.cardPadding),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.glassDark(opacity: effectiveOpacity)
                  : AppColors.glassLight(opacity: effectiveOpacity),
              borderRadius: BorderRadius.circular(effectiveRadius),
              border: Border.all(
                color: borderColor ?? AppColors.glassBorder(theme.brightness),
                width: borderWidth ?? AppDimensions.borderMedium,
              ),
              gradient: gradient ?? AppColors.glassGradientDark,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: onTap != null
                ? InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(effectiveRadius),
                    child: child,
                  )
                : child,
          ),
        ),
      ),
    );
  }
}

/// Glass Container - simpler variant without padding defaults
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? borderRadius;
  final double? blur;
  final double? opacity;
  final Color? color;
  final Border? border;

  const GlassContainer({
    Key? key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.blur,
    this.opacity,
    this.color,
    this.border,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeController = Get.find<ThemeController>();

    final effectiveBlur = blur ?? themeController.getEffectiveBlur();
    final effectiveRadius = borderRadius ?? AppDimensions.radiusMD;
    final baseOpacity = opacity ?? (isDark ? 0.15 : 0.4);
    final effectiveOpacity = themeController.getEffectiveOpacity(baseOpacity);

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(effectiveRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: effectiveBlur,
            sigmaY: effectiveBlur,
          ),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: color ??
                  (isDark
                      ? AppColors.glassDark(opacity: effectiveOpacity)
                      : AppColors.glassLight(opacity: effectiveOpacity)),
              borderRadius: BorderRadius.circular(effectiveRadius),
              border: border ??
                  Border.all(
                    color: AppColors.glassBorder(theme.brightness),
                    width: AppDimensions.borderMedium,
                  ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

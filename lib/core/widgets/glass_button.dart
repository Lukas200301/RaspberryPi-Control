import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/theme_controller.dart';

/// Glass Morphism Button
class GlassButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  final Color? textColor;
  final double? width;
  final double? height;
  final double? borderRadius;
  final bool isLoading;
  final bool isOutlined;

  const GlassButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.color,
    this.textColor,
    this.width,
    this.height,
    this.borderRadius,
    this.isLoading = false,
    this.isOutlined = false,
  }) : super(key: key);

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    final effectiveBlur = themeController.getEffectiveBlur();
    final effectiveRadius =
        widget.borderRadius ?? AppDimensions.radiusButton;
    final effectiveColor = widget.color ?? AppColors.accentBlue;

    return GestureDetector(
      onTapDown: widget.onPressed != null ? _handleTapDown : null,
      onTapUp: widget.onPressed != null ? _handleTapUp : null,
      onTapCancel: widget.onPressed != null ? _handleTapCancel : null,
      onTap: widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.width,
          height: widget.height ?? AppDimensions.buttonHeightMedium,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(effectiveRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: effectiveBlur,
                sigmaY: effectiveBlur,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: widget.isOutlined
                      ? Colors.transparent
                      : effectiveColor.withOpacity(widget.onPressed != null ? 1.0 : 0.5),
                  borderRadius: BorderRadius.circular(effectiveRadius),
                  border: Border.all(
                    color: effectiveColor,
                    width: widget.isOutlined ? 2 : 1,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onPressed,
                    borderRadius: BorderRadius.circular(effectiveRadius),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.buttonPaddingHorizontal,
                        vertical: AppDimensions.buttonPaddingVertical,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.isLoading)
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  widget.textColor ?? Colors.white,
                                ),
                              ),
                            )
                          else if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              color: widget.textColor ?? Colors.white,
                              size: AppDimensions.iconSM,
                            ),
                            const SizedBox(width: AppDimensions.spaceSM),
                          ],
                          Text(
                            widget.text,
                            style: TextStyle(
                              color: widget.textColor ?? Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Glass Icon Button
class GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final double? size;
  final String? tooltip;

  const GlassIconButton({
    Key? key,
    required this.icon,
    this.onPressed,
    this.color,
    this.size,
    this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeController = Get.find<ThemeController>();

    final effectiveBlur = themeController.getEffectiveBlur();
    final effectiveColor = color ?? AppColors.accentBlue;
    final effectiveSize = size ?? AppDimensions.iconMD;

    final button = ClipRRect(
      borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: effectiveBlur,
          sigmaY: effectiveBlur,
        ),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.glassBackground(theme.brightness, opacity: 0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
            border: Border.all(
              color: AppColors.glassBorder(theme.brightness),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed != null
                  ? () {
                      HapticFeedback.lightImpact();
                      onPressed!();
                    }
                  : null,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              child: Icon(
                icon,
                color: effectiveColor,
                size: effectiveSize,
              ),
            ),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}

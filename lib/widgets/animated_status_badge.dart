import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum ServiceAnimState { running, stopped, starting }

class AnimatedStatusBadge extends StatefulWidget {
  final ServiceAnimState state;
  final double size;

  const AnimatedStatusBadge({super.key, required this.state, this.size = 10});

  @override
  State<AnimatedStatusBadge> createState() => _AnimatedStatusBadgeState();
}

class _AnimatedStatusBadgeState extends State<AnimatedStatusBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulse = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _updateAnimation();
  }

  @override
  void didUpdateWidget(AnimatedStatusBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _updateAnimation();
    }
  }

  void _updateAnimation() {
    if (widget.state == ServiceAnimState.running ||
        widget.state == ServiceAnimState.starting) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _dotColor {
    switch (widget.state) {
      case ServiceAnimState.running:
        return AppTheme.successGreen;
      case ServiceAnimState.stopped:
        return AppTheme.textTertiary;
      case ServiceAnimState.starting:
        return AppTheme.warningAmber;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) {
        final isAnimating = widget.state != ServiceAnimState.stopped;
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer ring pulse
            if (isAnimating)
              AnimatedOpacity(
                opacity: _pulse.value,
                duration: Duration.zero,
                child: Container(
                  width: widget.size * 2.2,
                  height: widget.size * 2.2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _dotColor.withValues(alpha: 0.2 * _pulse.value),
                  ),
                ),
              ),
            // Inner dot
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _dotColor,
                boxShadow: isAnimating
                    ? [
                        BoxShadow(
                          color: _dotColor.withValues(alpha: 0.6),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

/// Glass Morphism App Bar (No Drawer Menu)
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showConnectionStatus;
  final bool isConnected;
  final VoidCallback? onConnectionTap;

  const GlassAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.showConnectionStatus = true,
    this.isConnected = false,
    this.onConnectionTap,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(AppDimensions.appBarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      color: isDark
          ? const Color(0xFF000000) // Pure AMOLED Black - solid, no transparency
          : const Color(0xFFFFFFFF),
      child: SafeArea(
        bottom: false,
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF000000) // Pure AMOLED Black
                : const Color(0xFFFFFFFF),
            border: Border(
              bottom: BorderSide(
                color: AppColors.glassBorder(theme.brightness, opacity: 0.2),
                width: 1,
              ),
            ),
          ),
          child: AppBar(
            title: Text(
              title,
              style: TextStyle(
                color: AppColors.textColor(theme.brightness),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
            backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
            surfaceTintColor: Colors.transparent, // Remove Material 3 surface tint
            elevation: 0,
            scrolledUnderElevation: 0, // Keep elevation 0 even when scrolled
            leading: leading,
            automaticallyImplyLeading: false, // No back button by default
            actions: [
              if (showConnectionStatus)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: GestureDetector(
                      onTap: onConnectionTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: (isConnected
                                  ? AppColors.connectedGreen
                                  : AppColors.disconnectedRed)
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isConnected
                                ? AppColors.connectedGreen
                                : AppColors.disconnectedRed,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: isConnected
                                    ? AppColors.connectedGreen
                                    : AppColors.disconnectedRed,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isConnected ? 'Connected' : 'Offline',
                              style: TextStyle(
                                color: AppColors.textColor(theme.brightness),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              if (actions != null) ...actions!,
            ],
          ),
        ),
      ),
    );
  }
}

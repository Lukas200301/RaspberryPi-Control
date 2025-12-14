import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

/// Glass Morphism Bottom Navigation Bar
class GlassBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isConnected;

  const GlassBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.isConnected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Navigation items
    final items = [
      _NavItem(Icons.analytics_outlined, Icons.analytics, 'Dashboard'),
      _NavItem(Icons.terminal_outlined, Icons.terminal, 'Terminal'),
      _NavItem(Icons.link_outlined, Icons.link, 'Connections'),
      _NavItem(Icons.folder_outlined, Icons.folder, 'Files'),
      _NavItem(Icons.settings_outlined, Icons.settings, 'Settings'),
    ];

    return Container(
      margin: const EdgeInsets.all(AppDimensions.bottomNavMargin),
      height: AppDimensions.bottomNavHeight,
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF000000) // Pure AMOLED Black - no transparency
              : const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(AppDimensions.radiusBottomNav),
          border: Border.all(
            color: AppColors.glassBorder(theme.brightness),
            width: AppDimensions.borderMedium,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusBottomNav),
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                items.length,
                (index) => _buildNavItem(
                  context,
                  items[index],
                  index,
                  isDark,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    _NavItem item,
    int index,
    bool isDark,
  ) {
    final isSelected = currentIndex == index;
    final isEnabled = _isItemEnabled(index);

    return Expanded(
      child: GestureDetector(
        onTap: isEnabled
            ? () {
                HapticFeedback.lightImpact();
                onTap(index);
              }
            : null,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accentBlue.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  isSelected ? item.selectedIcon : item.icon,
                  color: isEnabled
                      ? (isSelected
                          ? AppColors.accentBlue
                          : AppColors.textColor(
                              isDark ? Brightness.dark : Brightness.light,
                              secondary: true,
                            ))
                      : AppColors.textColor(
                          isDark ? Brightness.dark : Brightness.light,
                          secondary: true,
                        ).withOpacity(0.3),
                  size: AppDimensions.bottomNavIconSize,
                ),
              ),
              const SizedBox(height: 2),
              // Label
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isEnabled
                      ? (isSelected
                          ? AppColors.accentBlue
                          : AppColors.textColor(
                              isDark ? Brightness.dark : Brightness.light,
                              secondary: true,
                            ))
                      : AppColors.textColor(
                          isDark ? Brightness.dark : Brightness.light,
                          secondary: true,
                        ).withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isItemEnabled(int index) {
    // Dashboard (0), Terminal (1), Files (3) require connection
    // Connections (2) and Settings (4) are always available
    if (index == 2 || index == 4) return true;
    return isConnected;
  }
}

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _NavItem(this.icon, this.selectedIcon, this.label);
}

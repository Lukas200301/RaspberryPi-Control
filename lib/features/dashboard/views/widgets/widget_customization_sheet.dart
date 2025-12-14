import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../models/dashboard_widget_type.dart';
import '../../services/widget_customization_service.dart';

/// Widget Customization Bottom Sheet
/// Allows users to show/hide and reorder dashboard widgets
class WidgetCustomizationSheet extends StatelessWidget {
  const WidgetCustomizationSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get or create the service and ensure it's initialized
    final customizationService = Get.isRegistered<WidgetCustomizationService>()
        ? Get.find<WidgetCustomizationService>()
        : Get.put(WidgetCustomizationService(), permanent: true);

    return FutureBuilder(
      future: customizationService.widgetConfigs.isEmpty
          ? customizationService.loadConfiguration()
          : Future.value(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            customizationService.widgetConfigs.isEmpty) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF000000) : const Color(0xFFF8F9FA),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppDimensions.radiusXL),
              ),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return _buildSheet(context, customizationService, theme, isDark);
      },
    );
  }

  Widget _buildSheet(
    BuildContext context,
    WidgetCustomizationService customizationService,
    ThemeData theme,
    bool isDark,
  ) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF000000) : const Color(0xFFF8F9FA),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXL),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: AppDimensions.spaceSM),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.textSecondary
                  : AppColors.lightTextSecondary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: AppDimensions.spaceMD),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spaceLG,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.spaceSM),
                  decoration: BoxDecoration(
                    color: AppColors.accentIndigo.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                  ),
                  child: const Icon(
                    Icons.tune,
                    color: AppColors.accentIndigo,
                    size: AppDimensions.iconLG,
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceMD),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customize Dashboard',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.textPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Obx(() {
                        return Text(
                          '${customizationService.visibleWidgetCount} of ${customizationService.totalWidgetCount} widgets visible',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.textSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                  tooltip: 'Close',
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.spaceMD),

          // Quick actions
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spaceLG,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    context,
                    icon: Icons.visibility,
                    label: 'Show All',
                    color: AppColors.success,
                    onTap: () {
                      customizationService.showAllWidgets();
                      Get.snackbar(
                        'Success',
                        'All widgets are now visible',
                        snackPosition: SnackPosition.BOTTOM,
                        duration: const Duration(seconds: 1),
                      );
                    },
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceSM),
                Expanded(
                  child: _buildQuickActionButton(
                    context,
                    icon: Icons.star,
                    label: 'Essentials',
                    color: AppColors.warning,
                    onTap: () {
                      customizationService.showEssentialsOnly();
                      Get.snackbar(
                        'Success',
                        'Showing essential widgets only',
                        snackPosition: SnackPosition.BOTTOM,
                        duration: const Duration(seconds: 1),
                      );
                    },
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceSM),
                Expanded(
                  child: _buildQuickActionButton(
                    context,
                    icon: Icons.restart_alt,
                    label: 'Reset',
                    color: AppColors.error,
                    onTap: () {
                      Get.dialog(
                        AlertDialog(
                          title: const Text('Reset to Defaults'),
                          content: const Text(
                            'This will reset all widget settings to their default values. Continue?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                customizationService.resetToDefaults();
                                Get.back();
                                Get.snackbar(
                                  'Success',
                                  'Widgets reset to defaults',
                                  snackPosition: SnackPosition.BOTTOM,
                                  duration: const Duration(seconds: 1),
                                );
                              },
                              child: const Text('Reset'),
                            ),
                          ],
                        ),
                      );
                    },
                    isDark: isDark,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.spaceLG),

          // Widget list
          Expanded(
            child: Obx(() {
              final configs = customizationService.widgetConfigs;

              return ReorderableListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spaceLG,
                  vertical: AppDimensions.spaceSM,
                ),
                itemCount: configs.length,
                onReorder: (oldIndex, newIndex) {
                  customizationService.reorderWidgets(oldIndex, newIndex);
                },
                itemBuilder: (context, index) {
                  final config = configs[index];
                  return _buildWidgetItem(
                    context,
                    config,
                    customizationService,
                    isDark,
                  );
                },
              );
            }),
          ),

          // Bottom padding for safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  /// Build quick action button
  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceSM,
        vertical: AppDimensions.spaceMD,
      ),
      onTap: onTap,
      borderColor: color.withOpacity(0.3),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build widget item
  Widget _buildWidgetItem(
    BuildContext context,
    DashboardWidgetConfig config,
    WidgetCustomizationService service,
    bool isDark,
  ) {
    final type = config.type;

    return GlassCard(
      key: ValueKey(type.name),
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceSM),
      padding: const EdgeInsets.all(AppDimensions.spaceMD),
      borderColor: config.isVisible
          ? AppColors.accentIndigo.withOpacity(0.3)
          : null,
      child: Row(
        children: [
          // Drag handle
          Icon(
            Icons.drag_indicator,
            color: isDark
                ? AppColors.textSecondary
                : AppColors.lightTextSecondary,
            size: 20,
          ),

          const SizedBox(width: AppDimensions.spaceSM),

          // Widget icon
          Container(
            padding: const EdgeInsets.all(AppDimensions.spaceSM),
            decoration: BoxDecoration(
              color: _getWidgetColor(type).withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
            ),
            child: Icon(
              _getWidgetIcon(type),
              color: _getWidgetColor(type),
              size: AppDimensions.iconMD,
            ),
          ),

          const SizedBox(width: AppDimensions.spaceMD),

          // Widget info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type.displayName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  type.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textSecondary
                        : AppColors.lightTextSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Toggle switch
          Switch(
            value: config.isVisible,
            onChanged: (value) {
              service.toggleWidgetVisibility(type);
            },
            activeColor: AppColors.accentIndigo,
          ),
        ],
      ),
    );
  }

  /// Get widget icon
  IconData _getWidgetIcon(DashboardWidgetType type) {
    switch (type) {
      case DashboardWidgetType.heroStats:
        return Icons.dashboard;
      case DashboardWidgetType.cpuChart:
        return Icons.speed;
      case DashboardWidgetType.memoryChart:
        return Icons.memory;
      case DashboardWidgetType.temperatureChart:
        return Icons.thermostat;
      case DashboardWidgetType.networkChart:
        return Icons.network_check;
      case DashboardWidgetType.diskUsage:
        return Icons.storage;
      case DashboardWidgetType.networkPing:
        return Icons.wifi_tethering;
      case DashboardWidgetType.systemProcesses:
        return Icons.widgets;
      case DashboardWidgetType.activeConnections:
        return Icons.cable;
      case DashboardWidgetType.systemLogs:
        return Icons.article;
      case DashboardWidgetType.serviceControl:
        return Icons.settings_applications;
    }
  }

  /// Get widget color
  Color _getWidgetColor(DashboardWidgetType type) {
    switch (type) {
      case DashboardWidgetType.heroStats:
        return AppColors.accentIndigo;
      case DashboardWidgetType.cpuChart:
        return AppColors.accentIndigo;
      case DashboardWidgetType.memoryChart:
        return AppColors.accentTeal;
      case DashboardWidgetType.temperatureChart:
        return AppColors.warning;
      case DashboardWidgetType.networkChart:
        return AppColors.accentCyan;
      case DashboardWidgetType.diskUsage:
        return AppColors.accentPurple;
      case DashboardWidgetType.networkPing:
        return AppColors.accentCyan;
      case DashboardWidgetType.systemProcesses:
        return AppColors.accentBlue;
      case DashboardWidgetType.activeConnections:
        return AppColors.success;
      case DashboardWidgetType.systemLogs:
        return AppColors.warning;
      case DashboardWidgetType.serviceControl:
        return AppColors.accentTeal;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/dashboard_widget_type.dart';
import '../../services/widget_customization_service.dart';
import './widget_customization_sheet.dart';

// Import all widget cards
import './hero_stats_card.dart';
import './cpu_chart_card.dart';
import './memory_chart_card.dart';
import './temperature_chart_card.dart';
import './network_chart_card.dart';
import './disk_usage_card.dart';
import './network_ping_card.dart';
import './system_processes_card.dart';
import './active_connections_card.dart';
import './system_logs_card.dart';
import './service_control_card.dart';

/// Customizable Dashboard Layout
/// Renders widgets based on user preferences with drag-to-reorder support
class CustomizableDashboardLayout extends StatelessWidget {
  const CustomizableDashboardLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get or create the service and ensure it's initialized
    final customizationService = Get.isRegistered<WidgetCustomizationService>()
        ? Get.find<WidgetCustomizationService>()
        : Get.put(WidgetCustomizationService(), permanent: true);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return FutureBuilder(
      future: customizationService.widgetConfigs.isEmpty
          ? customizationService.loadConfiguration()
          : Future.value(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            customizationService.widgetConfigs.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return _buildLayout(context, customizationService, theme, isDark);
      },
    );
  }

  Widget _buildLayout(
    BuildContext context,
    WidgetCustomizationService customizationService,
    ThemeData theme,
    bool isDark,
  ) {

    return Stack(
      children: [
        // Main scrollable content
        Obx(() {
          // Access widgetConfigs directly to trigger reactivity
          final allConfigs = customizationService.widgetConfigs;
          final visibleWidgets = allConfigs
              .where((config) => config.isVisible)
              .toList()
            ..sort((a, b) => a.order.compareTo(b.order));

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.spaceMD,
              AppDimensions.spaceMD,
              AppDimensions.spaceMD,
              100,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Empty state if no widgets
                if (visibleWidgets.isEmpty)
                  _buildEmptyState(context, isDark)
                else
                  ...visibleWidgets.map((config) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppDimensions.spaceMD,
                      ),
                      child: _buildWidget(config.type),
                    );
                  }),

                const SizedBox(height: 100),
              ],
            ),
          );
        }),

        // Floating customize button
        Positioned(
          right: AppDimensions.spaceLG,
          bottom: AppDimensions.spaceLG + 80, // Above bottom nav
          child: FloatingActionButton.extended(
            onPressed: () {
              Get.bottomSheet(
                const WidgetCustomizationSheet(),
                isScrollControlled: true,
                enableDrag: true,
              );
            },
            backgroundColor: AppColors.accentIndigo,
            icon: const Icon(Icons.tune),
            label: const Text('Customize'),
          ),
        ),
      ],
    );
  }

  /// Build empty state
  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spaceLG * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.spaceLG),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.accentIndigo.withOpacity(0.3),
                    AppColors.accentTeal.withOpacity(0.3),
                  ],
                ),
              ),
              child: Icon(
                Icons.dashboard_customize,
                size: 64,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceLG),
            Text(
              'No Widgets Visible',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppDimensions.spaceSM),
            Text(
              'Tap "Customize" to add widgets to your dashboard',
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spaceLG),
            ElevatedButton.icon(
              onPressed: () {
                Get.bottomSheet(
                  const WidgetCustomizationSheet(),
                  isScrollControlled: true,
                  enableDrag: true,
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Widgets'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentIndigo,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spaceLG,
                  vertical: AppDimensions.spaceMD,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build widget based on type
  Widget _buildWidget(DashboardWidgetType type) {
    switch (type) {
      case DashboardWidgetType.heroStats:
        return const HeroStatsCard();
      case DashboardWidgetType.cpuChart:
        return const CpuChartCard();
      case DashboardWidgetType.memoryChart:
        return const MemoryChartCard();
      case DashboardWidgetType.temperatureChart:
        return const TemperatureChartCard();
      case DashboardWidgetType.networkChart:
        return const NetworkChartCard();
      case DashboardWidgetType.diskUsage:
        return const DiskUsageCard();
      case DashboardWidgetType.networkPing:
        return const NetworkPingCard();
      case DashboardWidgetType.systemProcesses:
        return const SystemProcessesCard();
      case DashboardWidgetType.activeConnections:
        return const ActiveConnectionsCard();
      case DashboardWidgetType.systemLogs:
        return const SystemLogsCard();
      case DashboardWidgetType.serviceControl:
        return const ServiceControlCard();
    }
  }
}

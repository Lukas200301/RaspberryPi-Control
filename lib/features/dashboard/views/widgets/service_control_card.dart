import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../controllers/dashboard_controller.dart';
import '../../../../core/services/ssh_service_controller.dart';
import '../../../../pages/stats/service_control_page.dart';

/// Service Control Card - Manage system services
/// Glassmorphism design for v3.0
class ServiceControlCard extends GetView<DashboardController> {
  const ServiceControlCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sshController = Get.find<SSHServiceController>();

    return Obx(() {
      final services = controller.services;

      return Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.spaceMD),
        padding: const EdgeInsets.all(AppDimensions.spaceLG),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ]
                : [
                    Colors.white.withOpacity(0.8),
                    Colors.white.withOpacity(0.4),
                  ],
          ),
          border: Border.all(
            color: AppColors.accentPurple.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            AppColors.purpleGlow(blur: 20, opacity: 0.2),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.spaceSM),
                  decoration: BoxDecoration(
                    color: AppColors.accentPurple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                  ),
                  child: const Icon(
                    Icons.miscellaneous_services,
                    color: AppColors.accentPurple,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceMD),
                Expanded(
                  child: Text(
                    'System Services',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textPrimary : Colors.black87,
                    ),
                  ),
                ),
                // Service count badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spaceSM,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentPurple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
                    border: Border.all(
                      color: AppColors.accentPurple,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${services.length}',
                    style: const TextStyle(
                      color: AppColors.accentPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.spaceMD),

            // Services list
            if (services.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.spaceLG),
                  child: Column(
                    children: [
                      Icon(
                        Icons.hourglass_empty,
                        size: 32,
                        color: isDark ? AppColors.textTertiary : Colors.black38,
                      ),
                      const SizedBox(height: AppDimensions.spaceSM),
                      Text(
                        'Loading services...',
                        style: TextStyle(
                          color: isDark ? AppColors.textSecondary : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...services.take(5).map((service) {
                final name = service['name']?.toString() ?? 'Unknown';
                final status = service['status']?.toString() ?? 'unknown';
                final description = service['description']?.toString() ?? '';

                return _buildServiceItem(
                  context,
                  name,
                  status,
                  description,
                  isDark,
                  sshController,
                );
              }),

            // Show more button if there are more services
            if (services.length > 5)
              Padding(
                padding: const EdgeInsets.only(top: AppDimensions.spaceSM),
                child: Center(
                  child: TextButton.icon(
                    onPressed: () {
                      // Navigate to full services page with all functionality
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ServiceControlPage(
                            initialServices: services,
                            onStartService: (name) => _controlService(context, sshController, name, 'start'),
                            onStopService: (name) => _controlService(context, sshController, name, 'stop'),
                            onRestartService: (name) => _controlService(context, sshController, name, 'restart'),
                            getServiceLogs: (name) async {
                              if (sshController.service == null) {
                                return 'SSH service not available';
                              }
                              try {
                                return await sshController.service!.getServiceStatus(name);
                              } catch (e) {
                                return 'Failed to fetch logs: $e';
                              }
                            },
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.view_list, size: 18),
                    label: Text('View All ${services.length} Services'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.accentPurple,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildServiceItem(
    BuildContext context,
    String name,
    String status,
    String description,
    bool isDark,
    SSHServiceController sshController,
  ) {
    final isActive = status.toLowerCase().contains('active') ||
        status.toLowerCase().contains('running');
    final isFailed = status.toLowerCase().contains('failed');

    Color statusColor;
    IconData statusIcon;

    if (isFailed) {
      statusColor = AppColors.error;
      statusIcon = Icons.error;
    } else if (isActive) {
      statusColor = AppColors.success;
      statusIcon = Icons.check_circle;
    } else {
      statusColor = AppColors.textSecondary;
      statusIcon = Icons.stop_circle;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceSM),
      padding: const EdgeInsets.all(AppDimensions.spaceMD),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Status indicator
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              statusIcon,
              color: statusColor,
              size: 16,
            ),
          ),

          const SizedBox(width: AppDimensions.spaceMD),

          // Service info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isDark ? AppColors.textPrimary : Colors.black87,
                  ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.textTertiary : Colors.black45,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Control buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Start button
              if (!isActive)
                IconButton(
                  icon: const Icon(Icons.play_arrow, size: 18),
                  color: AppColors.success,
                  tooltip: 'Start',
                  onPressed: () => _controlService(
                    context,
                    sshController,
                    name,
                    'start',
                  ),
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  padding: EdgeInsets.zero,
                ),

              // Stop button
              if (isActive)
                IconButton(
                  icon: const Icon(Icons.stop, size: 18),
                  color: AppColors.error,
                  tooltip: 'Stop',
                  onPressed: () => _controlService(
                    context,
                    sshController,
                    name,
                    'stop',
                  ),
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  padding: EdgeInsets.zero,
                ),

              // Restart button
              IconButton(
                icon: const Icon(Icons.refresh, size: 18),
                color: AppColors.accentBlue,
                tooltip: 'Restart',
                onPressed: () => _controlService(
                  context,
                  sshController,
                  name,
                  'restart',
                ),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _controlService(
    BuildContext context,
    SSHServiceController sshController,
    String serviceName,
    String action,
  ) async {
    if (sshController.service == null) {
      Get.snackbar(
        'Error',
        'Not connected to SSH',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(AppDimensions.spaceMD),
      );
      return;
    }

    try {
      // Show loading
      Get.snackbar(
        'Service Control',
        '${action.capitalize}ing $serviceName...',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(AppDimensions.spaceMD),
        showProgressIndicator: true,
        duration: const Duration(seconds: 2),
      );

      // Execute action
      switch (action) {
        case 'start':
          await sshController.service!.startService(serviceName);
          break;
        case 'stop':
          await sshController.service!.stopService(serviceName);
          break;
        case 'restart':
          await sshController.service!.restartService(serviceName);
          break;
      }

      // Show success
      Get.snackbar(
        'Success',
        'Service $serviceName ${action}ed successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(AppDimensions.spaceMD),
        duration: const Duration(seconds: 2),
      );

      // Refresh stats
      await Future.delayed(const Duration(milliseconds: 500));
      controller.stopMonitoring();
      await controller.startMonitoring();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to $action $serviceName: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(AppDimensions.spaceMD),
      );
    }
  }
}

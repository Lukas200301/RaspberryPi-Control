import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../controllers/dashboard_controller.dart';

/// Disk Usage Card - Shows disk space usage for all mounted drives
/// Glassmorphism design for v3.0
class DiskUsageCard extends GetView<DashboardController> {
  const DiskUsageCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
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
            color: AppColors.accentTeal.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            AppColors.tealGlow(blur: 20, opacity: 0.2),
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
                    color: AppColors.accentTeal.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                  ),
                  child: const Icon(
                    Icons.storage,
                    color: AppColors.accentTeal,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceMD),
                Expanded(
                  child: Text(
                    'Disk Usage',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textPrimary : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.spaceMD),

            // Disk list
            if (controller.disks.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.spaceLG),
                  child: Text(
                    'No disk information available',
                    style: TextStyle(
                      color: isDark ? AppColors.textSecondary : Colors.black54,
                    ),
                  ),
                ),
              )
            else
              ...controller.disks.map((disk) => _buildDiskItem(
                    context,
                    disk['filesystem'] ?? '/',
                    disk['mounted'] ?? '/',
                    _parseSize(disk['used']),
                    _parseSize(disk['available']),
                    _parseSize(disk['total']),
                    _parsePercent(disk['use_percent']),
                    isDark,
                  )),
          ],
        ),
      );
    });
  }

  Widget _buildDiskItem(
    BuildContext context,
    String filesystem,
    String mountPoint,
    double used,
    double available,
    double total,
    double usePercent,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceMD),
      padding: const EdgeInsets.all(AppDimensions.spaceMD),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        border: Border.all(
          color: _getDiskColor(usePercent).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mount point and usage
          Row(
            children: [
              Icon(
                Icons.folder,
                size: 16,
                color: isDark ? AppColors.textSecondary : Colors.black54,
              ),
              const SizedBox(width: AppDimensions.spaceXS),
              Expanded(
                child: Text(
                  mountPoint,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? AppColors.textPrimary : Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spaceSM,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: _getDiskColor(usePercent).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
                  border: Border.all(
                    color: _getDiskColor(usePercent),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${usePercent.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: _getDiskColor(usePercent),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spaceXS),

          // Filesystem type
          Text(
            filesystem,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.textTertiary : Colors.black45,
            ),
          ),

          const SizedBox(height: AppDimensions.spaceSM),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
            child: LinearProgressIndicator(
              value: usePercent / 100,
              minHeight: 8,
              backgroundColor: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                _getDiskColor(usePercent),
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.spaceXS),

          // Size info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Used: ${_formatBytes(used)}',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppColors.textSecondary : Colors.black54,
                ),
              ),
              Text(
                'Free: ${_formatBytes(available)}',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppColors.textSecondary : Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Get disk color based on usage percentage
  Color _getDiskColor(double usePercent) {
    if (usePercent >= 90) return AppColors.error;
    if (usePercent >= 75) return AppColors.warning;
    return AppColors.success;
  }

  /// Parse size from string (e.g., "18G") or number to bytes
  double _parseSize(dynamic size) {
    if (size == null) return 0.0;
    if (size is int || size is double) return size.toDouble();
    if (size is! String) return 0.0;

    final sizeStr = size.toString().trim().toUpperCase();
    final numStr = sizeStr.replaceAll(RegExp(r'[A-Z]'), '');
    final num = double.tryParse(numStr) ?? 0.0;

    if (sizeStr.endsWith('T')) {
      return num * 1099511627776; // TB
    } else if (sizeStr.endsWith('G')) {
      return num * 1073741824; // GB
    } else if (sizeStr.endsWith('M')) {
      return num * 1048576; // MB
    } else if (sizeStr.endsWith('K')) {
      return num * 1024; // KB
    }
    return num;
  }

  /// Parse percentage from string (e.g., "75%") or number
  double _parsePercent(dynamic percent) {
    if (percent == null) return 0.0;
    if (percent is int || percent is double) return percent.toDouble();
    if (percent is! String) return 0.0;

    final percentStr = percent.toString().replaceAll('%', '').trim();
    return double.tryParse(percentStr) ?? 0.0;
  }

  /// Format bytes to human readable format
  String _formatBytes(double bytes) {
    if (bytes >= 1099511627776) {
      return '${(bytes / 1099511627776).toStringAsFixed(1)} TB';
    } else if (bytes >= 1073741824) {
      return '${(bytes / 1073741824).toStringAsFixed(1)} GB';
    } else if (bytes >= 1048576) {
      return '${(bytes / 1048576).toStringAsFixed(1)} MB';
    } else if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${bytes.toStringAsFixed(0)} B';
  }
}

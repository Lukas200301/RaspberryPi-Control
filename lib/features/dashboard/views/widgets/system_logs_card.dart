import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../controllers/dashboard_controller.dart';

/// System Logs Card - Shows recent system logs
/// Glassmorphism design for v3.0
class SystemLogsCard extends GetView<DashboardController> {
  const SystemLogsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final logs = controller.systemLogs;

      // Count log types
      int errors = 0;
      int warnings = 0;
      for (var log in logs.take(50)) {
        final logStr = log.toString().toLowerCase();
        if (logStr.contains('error') || logStr.contains('fail') || logStr.contains('critical')) {
          errors++;
        } else if (logStr.contains('warn')) {
          warnings++;
        }
      }

      final recentLogs = logs.take(5).toList();

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
            color: AppColors.accentIndigo.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            AppColors.indigoGlow(blur: 20, opacity: 0.2),
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
                    color: AppColors.accentIndigo.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                  ),
                  child: const Icon(
                    Icons.article,
                    color: AppColors.accentIndigo,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceMD),
                Expanded(
                  child: Text(
                    'System Logs',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textPrimary : Colors.black87,
                    ),
                  ),
                ),
                // Status badges
                if (errors > 0)
                  _buildStatusBadge(errors.toString(), AppColors.error, Icons.error_outline),
                if (warnings > 0)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: _buildStatusBadge(warnings.toString(), AppColors.warning, Icons.warning_amber_outlined),
                  ),
              ],
            ),

            const SizedBox(height: AppDimensions.spaceMD),

            // Logs list
            if (recentLogs.isEmpty)
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
                        'No logs available',
                        style: TextStyle(
                          color: isDark ? AppColors.textSecondary : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...recentLogs.map((log) {
                final logStr = log.toString();
                return _buildLogItem(logStr, isDark);
              }),

            // View all button
            if (logs.length > 5)
              Padding(
                padding: const EdgeInsets.only(top: AppDimensions.spaceSM),
                child: Center(
                  child: TextButton.icon(
                    onPressed: () {
                      // Show full logs widget
                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.8,
                            padding: const EdgeInsets.all(AppDimensions.spaceMD),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'System Logs',
                                      style: theme.textTheme.titleLarge,
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppDimensions.spaceMD),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: logs.length,
                                    itemBuilder: (context, index) {
                                      final log = logs[index].toString();
                                      return _buildLogItem(log, isDark);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.expand_more, size: 18),
                    label: Text('Show all ${logs.length} logs'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.accentIndigo,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildStatusBadge(String count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
        border: Border.all(
          color: color,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 2),
          Text(
            count,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogItem(String log, bool isDark) {
    // Determine severity
    final logLower = log.toLowerCase();
    Color severityColor;
    IconData severityIcon;

    if (logLower.contains('error') || logLower.contains('fail') || logLower.contains('critical')) {
      severityColor = AppColors.error;
      severityIcon = Icons.error_outline;
    } else if (logLower.contains('warn')) {
      severityColor = AppColors.warning;
      severityIcon = Icons.warning_amber_outlined;
    } else {
      severityColor = AppColors.accentBlue;
      severityIcon = Icons.info_outline;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceXS),
      padding: const EdgeInsets.all(AppDimensions.spaceSM),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        border: Border.all(
          color: severityColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            severityIcon,
            size: 14,
            color: severityColor,
          ),
          const SizedBox(width: AppDimensions.spaceSM),
          Expanded(
            child: Text(
              log,
              style: TextStyle(
                fontSize: 11,
                fontFamily: 'monospace',
                color: isDark ? AppColors.textSecondary : Colors.black54,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

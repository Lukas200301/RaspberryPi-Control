import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../controllers/dashboard_controller.dart';
import '../../../../controllers/stats_controller.dart';
import '../../../../pages/stats/widgets/active_connections_widget.dart';

/// Active Connections Card - Shows active network connections
/// Glassmorphism design for v3.0
class ActiveConnectionsCard extends GetView<DashboardController> {
  const ActiveConnectionsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final statsController = Get.find<StatsController>();
      final currentStats = statsController.currentStats;
      final connections = currentStats['connections'] as List? ?? [];

      // Count connection types
      int established = 0;
      int listening = 0;
      for (var conn in connections.take(100)) {
        if (conn is Map<String, dynamic>) {
          final state = (conn['state'] ?? '').toString().toUpperCase();
          if (state == 'ESTABLISHED') {
            established++;
          } else if (state == 'LISTEN') {
            listening++;
          }
        }
      }

      final recentConnections = connections.take(5).toList();

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
                    Icons.device_hub,
                    color: AppColors.accentTeal,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceMD),
                Expanded(
                  child: Text(
                    'Network Connections',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textPrimary : Colors.black87,
                    ),
                  ),
                ),
                // Connection stats
                Row(
                  children: [
                    if (established > 0)
                      _buildStatBadge(established.toString(), AppColors.success, Icons.link),
                    if (listening > 0)
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: _buildStatBadge(listening.toString(), AppColors.accentBlue, Icons.hearing),
                      ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.spaceMD),

            // Connections list
            if (recentConnections.isEmpty)
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
                        'No connections available',
                        style: TextStyle(
                          color: isDark ? AppColors.textSecondary : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...recentConnections.map((conn) {
                if (conn is Map<String, dynamic>) {
                  return _buildConnectionItem(conn, isDark);
                }
                return const SizedBox.shrink();
              }),

            // View all button
            if (connections.length > 5)
              Padding(
                padding: const EdgeInsets.only(top: AppDimensions.spaceSM),
                child: Center(
                  child: TextButton.icon(
                    onPressed: () {
                      // Show full connections widget
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
                                      'Active Connections',
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
                                  child: ActiveConnectionsWidget(
                                    connections: connections,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.expand_more, size: 18),
                    label: Text('Show all ${connections.length} connections'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.accentTeal,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildStatBadge(String count, Color color, IconData icon) {
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

  Widget _buildConnectionItem(Map<String, dynamic> conn, bool isDark) {
    final protocol = conn['protocol']?.toString() ?? '';
    final localIp = conn['local_ip']?.toString() ?? '';
    final localPort = conn['local_port']?.toString() ?? '';
    final remoteIp = conn['remote_ip']?.toString() ?? '';
    final remotePort = conn['remote_port']?.toString() ?? '';
    final state = conn['state']?.toString() ?? '';

    final Color stateColor = _getStateColor(state);

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceXS),
      padding: const EdgeInsets.all(AppDimensions.spaceSM),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        border: Border.all(
          color: stateColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Protocol and state
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
                ),
                child: Text(
                  protocol.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentBlue,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: stateColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
                  border: Border.all(
                    color: stateColor,
                    width: 1,
                  ),
                ),
                child: Text(
                  state.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: stateColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Connection info
          Row(
            children: [
              Expanded(
                child: Text(
                  '$localIp:$localPort',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: isDark ? AppColors.textPrimary : Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.arrow_forward,
                size: 12,
                color: isDark ? AppColors.textTertiary : Colors.black45,
              ),
              Expanded(
                child: Text(
                  '$remoteIp:$remotePort',
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    color: isDark ? AppColors.textSecondary : Colors.black54,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStateColor(String state) {
    switch (state.toUpperCase()) {
      case 'ESTABLISHED':
        return AppColors.success;
      case 'LISTEN':
        return AppColors.accentBlue;
      case 'TIME_WAIT':
      case 'CLOSE_WAIT':
        return AppColors.warning;
      case 'CLOSED':
      case 'CLOSING':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}

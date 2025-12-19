import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../providers/app_providers.dart';
import '../providers/file_providers.dart';
import 'stats_screen.dart';
import 'services_screen.dart';
import 'logs_screen.dart';
import 'network_connections_screen.dart';
import 'processes_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  String _formatUptime(int seconds) {
    final days = seconds ~/ 86400;
    final hours = (seconds % 86400) ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;

    if (days > 0) {
      return '${days}d ${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentConnection = ref.watch(currentConnectionProvider);
    final liveStatsAsync = ref.watch(liveStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Connection status card
            GlassCard(
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryIndigo, AppTheme.secondaryTeal],
                      ),
                    ),
                    child: const Icon(
                      Icons.computer,
                      color: Colors.white,
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentConnection?.name ?? 'Not connected',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Gap(4),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.successGreen,
                              ),
                            ),
                            const Gap(8),
                            Text(
                              'Connected',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.successGreen,
                                  ),
                            ),
                          ],
                        ),
                        const Gap(4),
                        Text(
                          currentConnection != null
                              ? '${currentConnection.username}@${currentConnection.host}'
                              : '',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: AppTheme.background,
                          title: const Text('Disconnect?'),
                          content: const Text('Are you sure you want to disconnect from this device?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.errorRose,
                              ),
                              child: const Text('Disconnect'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true && context.mounted) {
                        // Clear file transfers before disconnecting
                        ref.read(fileTransfersProvider.notifier).clearAll();

                        // Clear current connection
                        ref.read(currentConnectionProvider.notifier).setConnection(null);

                        // Disconnect using connection manager
                        final connectionManager = ref.read(connectionManagerProvider);
                        connectionManager.disconnect().timeout(
                          const Duration(seconds: 2),
                          onTimeout: () {
                            debugPrint('Disconnect timeout, navigating anyway');
                          },
                        ).catchError((e) {
                          debugPrint('Error during disconnect: $e');
                        });

                        // Navigate immediately
                        Navigator.of(context).pushReplacementNamed('/');
                      }
                    },
                    icon: const Icon(Icons.logout),
                    color: AppTheme.errorRose,
                    tooltip: 'Disconnect',
                  ),
                ],
              ),
            ),
            const Gap(32),

            // Quick Info
            Text(
              'Quick Info',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Gap(16),

            liveStatsAsync.when(
              data: (stats) {
                final ramUsedGB = stats.ramUsed.toDouble() / 1024 / 1024 / 1024;
                final ramTotalGB = stats.ramTotal.toDouble() / 1024 / 1024 / 1024;

                return GlassCard(
                  child: Column(
                    children: [
                      _buildInfoRow(
                        context,
                        icon: Icons.memory,
                        label: 'CPU Usage',
                        value: '${stats.cpuUsage.toStringAsFixed(1)}%',
                        color: AppTheme.getCPUColor(stats.cpuUsage),
                      ),
                      const Divider(color: AppTheme.glassBorder),
                      _buildInfoRow(
                        context,
                        icon: Icons.storage,
                        label: 'RAM Usage',
                        value: '${ramUsedGB.toStringAsFixed(1)} / ${ramTotalGB.toStringAsFixed(1)} GB',
                        color: AppTheme.getMemoryColor(stats.ramUsed.toDouble() / stats.ramTotal.toDouble() * 100),
                      ),
                      const Divider(color: AppTheme.glassBorder),
                      _buildInfoRow(
                        context,
                        icon: Icons.thermostat,
                        label: 'Temperature',
                        value: '${stats.cpuTemp.toStringAsFixed(1)}°C',
                        color: AppTheme.getTempColor(stats.cpuTemp),
                      ),
                      const Divider(color: AppTheme.glassBorder),
                      _buildInfoRow(
                        context,
                        icon: Icons.access_time,
                        label: 'Uptime',
                        value: _formatUptime(stats.uptime.toInt()),
                        color: AppTheme.textSecondary,
                      ),
                    ],
                  ),
                );
              },
              loading: () => GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        const CircularProgressIndicator(color: AppTheme.primaryIndigo),
                        const Gap(16),
                        Text(
                          'Loading system info...',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              error: (error, stack) => GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: AppTheme.errorRose),
                        const Gap(16),
                        Text(
                          'Failed to load stats',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.errorRose,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const Gap(32),

            // Menu Title
            Text(
              'Monitoring',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Gap(16),

            // Stats Option
            _buildMenuCard(
              context,
              icon: Icons.analytics,
              title: 'System Stats',
              subtitle: 'CPU, RAM, Temperature & Network',
              color: AppTheme.primaryIndigo,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StatsScreen()),
                );
              },
            ),
            const Gap(12),

            // Services Option
            _buildMenuCard(
              context,
              icon: Icons.settings_applications,
              title: 'Services',
              subtitle: 'Manage systemd services',
              color: AppTheme.secondaryTeal,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ServicesScreen()),
                );
              },
            ),
            const Gap(12),

            // Logs Option
            _buildMenuCard(
              context,
              icon: Icons.article,
              title: 'System Logs',
              subtitle: 'View real-time logs',
              color: AppTheme.warningAmber,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LogsScreen()),
                );
              },
            ),
            const Gap(12),

            // Network Connections Option
            _buildMenuCard(
              context,
              icon: Icons.lan,
              title: 'Network Connections',
              subtitle: 'View active connections',
              color: AppTheme.successGreen,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NetworkConnectionsScreen()),
                );
              },
            ),
            const Gap(12),

            // Processes Option
            _buildMenuCard(
              context,
              icon: Icons.apps,
              title: 'Processes',
              subtitle: 'Manage running processes',
              color: AppTheme.errorRose,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProcessesScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GlassCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 32,
            ),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Gap(4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            color: AppTheme.textTertiary,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GlassCard(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.2),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const Gap(12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const Gap(12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

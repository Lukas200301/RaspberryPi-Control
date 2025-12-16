import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../providers/app_providers.dart';
import '../providers/file_providers.dart';
import 'login_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentConnection = ref.watch(currentConnectionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Connection Info
          Text(
            'Connection',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const Gap(12),
          GlassCard(
            child: Column(
              children: [
                _buildSettingTile(
                  context,
                  icon: Icons.computer,
                  title: 'Connected Device',
                  subtitle: currentConnection?.name ?? 'Not connected',
                  trailing: const Icon(Icons.check_circle, color: AppTheme.successGreen),
                ),
                const Divider(color: AppTheme.glassBorder),
                _buildSettingTile(
                  context,
                  icon: Icons.dns,
                  title: 'Host',
                  subtitle: currentConnection?.host ?? 'N/A',
                ),
                const Divider(color: AppTheme.glassBorder),
                _buildSettingTile(
                  context,
                  icon: Icons.person,
                  title: 'Username',
                  subtitle: currentConnection?.username ?? 'N/A',
                ),
              ],
            ),
          ),
          const Gap(24),

          // App Settings
          Text(
            'Appearance',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const Gap(12),
          GlassCard(
            child: Column(
              children: [
                _buildSettingTile(
                  context,
                  icon: Icons.dark_mode,
                  title: 'Dark Mode',
                  subtitle: 'AMOLED Black theme',
                  trailing: Switch(
                    value: true,
                    onChanged: null, // Always dark mode
                    activeColor: AppTheme.primaryIndigo,
                  ),
                ),
                const Divider(color: AppTheme.glassBorder),
                _buildSettingTile(
                  context,
                  icon: Icons.animation,
                  title: 'Animations',
                  subtitle: 'Smooth transitions',
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {},
                    activeColor: AppTheme.primaryIndigo,
                  ),
                ),
              ],
            ),
          ),
          const Gap(24),

          // Monitoring
          Text(
            'Monitoring',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const Gap(12),
          GlassCard(
            child: Column(
              children: [
                _buildSettingTile(
                  context,
                  icon: Icons.speed,
                  title: 'Update Interval',
                  subtitle: '500ms (Real-time)',
                  onTap: () {},
                ),
                const Divider(color: AppTheme.glassBorder),
                _buildSettingTile(
                  context,
                  icon: Icons.timeline,
                  title: 'Stats History',
                  subtitle: '60 seconds',
                  onTap: () {},
                ),
              ],
            ),
          ),
          const Gap(24),

          // Agent
          Text(
            'Agent',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const Gap(12),
          GlassCard(
            child: Column(
              children: [
                _buildSettingTile(
                  context,
                  icon: Icons.info_outline,
                  title: 'Agent Version',
                  subtitle: '3.0.0',
                ),
                const Divider(color: AppTheme.glassBorder),
                _buildSettingTile(
                  context,
                  icon: Icons.refresh,
                  title: 'Reinstall Agent',
                  subtitle: 'Update or fix agent installation',
                  onTap: () {
                    // TODO: Reinstall agent
                  },
                ),
              ],
            ),
          ),
          const Gap(24),

          // About
          Text(
            'About',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const Gap(12),
          GlassCard(
            child: Column(
              children: [
                _buildSettingTile(
                  context,
                  icon: Icons.app_settings_alt,
                  title: 'App Version',
                  subtitle: '3.0.0',
                ),
                const Divider(color: AppTheme.glassBorder),
                _buildSettingTile(
                  context,
                  icon: Icons.code,
                  title: 'Open Source',
                  subtitle: 'View on GitHub',
                  onTap: () {},
                ),
              ],
            ),
          ),
          const Gap(24),

          // Logout
          GlassCard(
            child: ListTile(
              leading: const Icon(Icons.logout, color: AppTheme.errorRose),
              title: Text(
                'Disconnect',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.errorRose,
                    ),
              ),
              onTap: () {
                // Clear file transfers before disconnecting
                ref.read(fileTransfersProvider.notifier).clearAll();

                // Disconnect in background without waiting
                Future.wait([
                  ref.read(sshServiceProvider).disconnect(),
                  ref.read(grpcServiceProvider).disconnect(),
                ], eagerError: true).timeout(
                  const Duration(seconds: 2),
                  onTimeout: () => [],
                ).catchError((e) {
                  debugPrint('Error during disconnect: $e');
                });

                ref.read(currentConnectionProvider.notifier).setConnection(null);

                // Navigate immediately
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryIndigo),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall,
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}

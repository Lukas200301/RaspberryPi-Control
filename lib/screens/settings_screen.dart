import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;import 'package:open_filex/open_filex.dart';import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../providers/app_providers.dart';
import '../providers/file_providers.dart';
import '../constants/app_constants.dart';
import '../services/update_service.dart';
import '../models/app_settings.dart';
import 'login_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _appVersion = '';
  bool _checkingForUpdates = false;
  final UpdateService _updateService = UpdateService();

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
    _checkForUpdatesOnStart();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = packageInfo.version;
      });
    }
  }

  Future<void> _checkForUpdatesOnStart() async {
    // Delay check to not interfere with initial load
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      final updateInfo = await _updateService.checkForUpdates();
      if (updateInfo != null && updateInfo.updateAvailable && mounted) {
        _showUpdateAvailableDialog(updateInfo);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentConnection = ref.watch(currentConnectionProvider);
    final settings = ref.watch(appSettingsProvider);

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
                    activeTrackColor: AppTheme.primaryIndigo,
                  ),
                ),
                const Divider(color: AppTheme.glassBorder),
                _buildSettingTile(
                  context,
                  icon: Icons.animation,
                  title: 'Animations',
                  subtitle: 'Smooth transitions',
                  trailing: Switch(
                    value: settings.animationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        settings.animationsEnabled = value;
                      });
                    },
                    activeTrackColor: AppTheme.primaryIndigo,
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
                  icon: Icons.timeline,
                  title: 'Stats History',
                  subtitle: '${settings.statsHistory} seconds',
                  onTap: () => _showStatsHistoryDialog(context, settings),
                ),
              ],
            ),
          ),
          const Gap(24),

          // Terminal
          Text(
            'Terminal',
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
                  icon: Icons.text_fields,
                  title: 'Font Size',
                  subtitle: '${settings.terminalFontSize.toInt()}px',
                  onTap: () => _showTerminalFontSizeDialog(context, settings),
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
                  subtitle: AppConstants.agentVersion,
                ),
                const Divider(color: AppTheme.glassBorder),
                _buildSettingTile(
                  context,
                  icon: Icons.refresh,
                  title: 'Reinstall Agent',
                  subtitle: 'Update or fix agent installation',
                  onTap: () => _reinstallAgent(context),
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
                  subtitle: _appVersion.isEmpty ? 'Loading...' : _appVersion,
                ),
                const Divider(color: AppTheme.glassBorder),
                _buildSettingTile(
                  context,
                  icon: Icons.system_update,
                  title: 'Check for Updates',
                  subtitle: _checkingForUpdates ? 'Checking...' : 'Tap to check',
                  onTap: _checkingForUpdates ? null : _checkForUpdates,
                ),
                const Divider(color: AppTheme.glassBorder),
                _buildSettingTile(
                  context,
                  icon: Icons.code,
                  title: 'Open Source',
                  subtitle: 'View on GitHub',
                  onTap: () => _launchURL('https://github.com/Lukas200301/RaspberryPi-Control'),
                ),
                const Divider(color: AppTheme.glassBorder),
                _buildSettingTile(
                  context,
                  icon: Icons.delete_outline,
                  title: 'Reset Settings',
                  subtitle: 'Clear all app settings',
                  onTap: () => _resetSettings(context),
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
                  return [];
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

  void _showStatsHistoryDialog(BuildContext context, settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.background,
        title: const Text('Stats History'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('30 seconds'),
              onTap: () {
                setState(() => settings.statsHistory = 30);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Settings saved.',
                        style: TextStyle(color: Colors.white)),
                    backgroundColor: AppTheme.successGreen,
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('60 seconds'),
              onTap: () {
                setState(() => settings.statsHistory = 60);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Settings saved.',
                        style: TextStyle(color: Colors.white)),
                    backgroundColor: AppTheme.successGreen,
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('120 seconds'),
              onTap: () {
                setState(() => settings.statsHistory = 120);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Settings saved.',
                        style: TextStyle(color: Colors.white)),
                    backgroundColor: AppTheme.successGreen,
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('300 seconds'),
              onTap: () {
                setState(() => settings.statsHistory = 300);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Settings saved.',
                        style: TextStyle(color: Colors.white)),
                    backgroundColor: AppTheme.successGreen,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showTerminalFontSizeDialog(BuildContext context, settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.background,
        title: const Text('Terminal Font Size'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppSettings.availableFontSizes.map((size) => ListTile(
            title: Text('${size.toInt()}px'),
            trailing: settings.terminalFontSize == size
                ? const Icon(Icons.check, color: AppTheme.primaryIndigo)
                : null,
            onTap: () {
              setState(() => settings.terminalFontSize = size);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Font size updated',
                      style: TextStyle(color: Colors.white)),
                  backgroundColor: AppTheme.successGreen,
                ),
              );
            },
          )).toList(),
        ),
      ),
    );
  }

  Future<void> _reinstallAgent(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.background,
        title: const Text('Reinstall Agent?'),
        content: const Text('This will reinstall the agent on your Raspberry Pi.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reinstall'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      final agentManager = ref.read(agentManagerProvider);
      await agentManager.installAgent();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Agent reinstalled successfully',
                style: TextStyle(color: Colors.white)),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reinstall agent: $e',
                style: const TextStyle(color: Colors.white)),
            backgroundColor: AppTheme.errorRose,
          ),
        );
      }
    }
  }

  Future<void> _resetSettings(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.background,
        title: const Text('Reset Settings?'),
        content: const Text('This will reset all app settings to defaults.'),
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
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(appSettingsProvider).resetAll();
      if (context.mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings reset successfully',
                style: TextStyle(color: Colors.white)),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reset settings: $e',
                style: const TextStyle(color: Colors.white)),
            backgroundColor: AppTheme.errorRose,
          ),
        );
      }
    }
  }

  Future<void> _launchURL(String url) async {
    try {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open link: $e',
                style: const TextStyle(color: Colors.white)),
            backgroundColor: AppTheme.errorRose,
          ),
        );
      }
    }
  }

  Future<void> _checkForUpdates() async {
    setState(() => _checkingForUpdates = true);

    try {
      final updateInfo = await _updateService.checkForUpdates();

      if (!mounted) return;

      setState(() => _checkingForUpdates = false);

      if (updateInfo == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not check for updates',
                style: TextStyle(color: Colors.white)),
            backgroundColor: AppTheme.errorRose,
          ),
        );
        return;
      }

      if (updateInfo.updateAvailable) {
        _showUpdateAvailableDialog(updateInfo);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You are on the latest version!',
                style: TextStyle(color: Colors.white)),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _checkingForUpdates = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking for updates: $e',
                style: const TextStyle(color: Colors.white)),
            backgroundColor: AppTheme.errorRose,
          ),
        );
      }
    }
  }

  void _showUpdateAvailableDialog(UpdateInfo updateInfo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.background,
        title: Row(
          children: [
            const Icon(Icons.system_update, color: AppTheme.primaryIndigo),
            const Gap(12),
            const Text('Update Available'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Version ${updateInfo.latestVersion} is available!',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.successGreen,
                    ),
              ),
              const Gap(8),
              Text(
                'Current: ${updateInfo.currentVersion}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              const Gap(16),
              const Divider(color: AppTheme.glassBorder),
              const Gap(16),
              Text(
                'Release Notes:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const Gap(12),
              ...updateInfo.releaseNotes.map((note) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryIndigo.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'v${note.version}',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: AppTheme.primaryIndigo,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        const Gap(8),
                        Text(
                          note.title,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const Gap(4),
                        Text(
                          note.body,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _downloadAndInstallUpdate(updateInfo);
            },
            icon: const Icon(Icons.download),
            label: const Text('Update Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryIndigo,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadAndInstallUpdate(UpdateInfo updateInfo) async {
    if (updateInfo.downloadUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Download URL not found',
              style: TextStyle(color: Colors.white)),
          backgroundColor: AppTheme.errorRose,
        ),
      );
      return;
    }

    // Show progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        backgroundColor: AppTheme.background,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppTheme.primaryIndigo),
            Gap(16),
            Text('Downloading update...'),
          ],
        ),
      ),
    );

    try {
      // Download APK
      final response = await http.get(Uri.parse(updateInfo.downloadUrl));
      
      if (response.statusCode == 200) {
        // Get download directory
        final dir = await getExternalStorageDirectory();
        final file = File('${dir!.path}/raspberrypi_control_update.apk');
        
        // Delete old APK if exists
        if (await file.exists()) {
          await file.delete();
        }
        
        // Write file
        await file.writeAsBytes(response.bodyBytes);
        
        if (mounted) {
          Navigator.pop(context); // Close progress dialog
          
          // Automatically open installer using open_filex
          try {
            debugPrint('Opening APK: ${file.path}');
            final result = await OpenFilex.open(
              file.path,
              type: 'application/vnd.android.package-archive',
            );
            
            debugPrint('APK open result: ${result.type} - ${result.message}');
            
            if (result.type == ResultType.done) {
              // Successfully opened installer
              // Schedule file deletion after a delay (installer should have copied it by then)
              Future.delayed(const Duration(seconds: 30), () async {
                try {
                  if (await file.exists()) {
                    await file.delete();
                    debugPrint('Update APK deleted successfully');
                  }
                } catch (e) {
                  debugPrint('Failed to delete update APK: $e');
                }
              });
            } else {
              // Failed to open installer
              throw Exception('Failed to open installer: ${result.message}');
            }
            
          } catch (e) {
            debugPrint('Failed to open installer: $e');
            
            // Show manual install dialog as fallback
            if (mounted) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppTheme.background,
                  title: const Text('Install Update'),
                  content: Text(
                    'Update downloaded. Please manually install:\n${file.path}\n\nThe file will be automatically deleted after 30 seconds.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close progress dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: $e',
                style: const TextStyle(color: Colors.white)),
            backgroundColor: AppTheme.errorRose,
          ),
        );
      }
    }
  }
}

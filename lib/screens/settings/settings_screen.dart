import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../providers/app_providers.dart';
import '../../services/session_actions.dart';
import '../../ui/ui.dart';
import '../alerts/alert_settings_page.dart';
import 'about_page.dart';
import 'agent_page.dart';
import 'appearance_page.dart';
import 'preference_pages.dart';
import 'security_page.dart';

class SettingsScreen extends ConsumerWidget {
  /// True when shown as a tab of the main screen; opened from the device
  /// list it is a normal page with a back button
  final bool asTab;

  const SettingsScreen({super.key, this.asTab = false});

  void _open(BuildContext context, Widget page) => Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connection = ref.watch(currentConnectionProvider);

    return PageScaffold(
      title: 'Settings',
      automaticallyImplyLeading: !asTab,
      maxWidth: 760,
      body: PageList(
        children: [
          if (connection != null)
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const IconBadge(Icons.developer_board, size: 48),
                      const Gap(Insets.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(connection.name, style: context.tt.titleMedium),
                            Text(
                              '${connection.username}@${connection.host}:${connection.port}',
                              style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      const StatusPill('Connected', tone: Tone.success, dot: true),
                    ],
                  ),
                  const Gap(Insets.md),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => disconnectAndLeave(context, ref),
                          icon: const Icon(Icons.swap_horiz),
                          label: const Text('Switch device'),
                        ),
                      ),
                      const Gap(Insets.sm),
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: () => disconnectAndLeave(context, ref),
                          icon: const Icon(Icons.link_off),
                          label: const Text('Disconnect'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          const SectionHeader(title: 'Preferences'),
          TileGroup(
            children: [
              ActionTile(
                icon: Icons.palette_outlined,
                title: 'Appearance',
                subtitle: 'Theme, colors, text size, animations',
                onTap: () => _open(context, const AppearancePage()),
              ),
              ActionTile(
                icon: Icons.space_dashboard_outlined,
                title: 'Dashboard & monitoring',
                subtitle: 'Units, thresholds, history, refresh rate',
                tone: Tone.info,
                onTap: () => _open(context, const MonitoringSettingsPage()),
              ),
              ActionTile(
                icon: Icons.notifications_outlined,
                title: 'Alerts & notifications',
                subtitle: 'Offline, temperature, disk, failed services, background checks',
                tone: Tone.danger,
                onTap: () => _open(context, const AlertSettingsPage()),
              ),
              ActionTile(
                icon: Icons.terminal,
                title: 'Terminal',
                subtitle: 'Font, color scheme, cursor, extra keys',
                tone: Tone.success,
                onTap: () => _open(context, const TerminalSettingsPage()),
              ),
              ActionTile(
                icon: Icons.folder_outlined,
                title: 'Files',
                subtitle: 'Hidden files, confirmations',
                tone: Tone.warning,
                onTap: () => _open(context, const FilesSettingsPage()),
              ),
            ],
          ),
          const SectionHeader(title: 'Connection'),
          TileGroup(
            children: [
              ActionTile(
                icon: Icons.wifi_tethering,
                title: 'Connection',
                subtitle: 'Reconnect, keep-alive, timeouts',
                onTap: () => _open(context, const ConnectionSettingsPage()),
              ),
              // The agent page talks to the connected device
              if (connection != null)
                ActionTile(
                  icon: Icons.memory,
                  title: 'Agent',
                  subtitle: connection.agentVersion != null
                      ? 'Version ${connection.agentVersion} · status, log, reinstall'
                      : 'Status, log, reinstall',
                  tone: Tone.info,
                  onTap: () => _open(context, const AgentPage()),
                ),
            ],
          ),
          const SectionHeader(title: 'Privacy'),
          TileGroup(
            children: [
              ActionTile(
                icon: Icons.shield_outlined,
                title: 'Security & backup',
                subtitle: 'App lock, saved logins, encrypted backup',
                tone: Tone.success,
                onTap: () => _open(context, const SecurityPage()),
              ),
            ],
          ),
          const SectionHeader(title: 'About'),
          TileGroup(
            children: [
              ActionTile(
                icon: Icons.info_outline,
                title: 'About & updates',
                subtitle: 'Version, updates, source code, licenses',
                tone: Tone.neutral,
                onTap: () => _open(context, const AboutPage()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

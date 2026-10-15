import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/settings_provider.dart';
import '../../ui/ui.dart';
import 'update_flow.dart';

final _packageInfoProvider = FutureProvider<PackageInfo>((ref) => PackageInfo.fromPlatform());

class AboutPage extends ConsumerStatefulWidget {
  const AboutPage({super.key});

  @override
  ConsumerState<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends ConsumerState<AboutPage> {
  bool _checking = false;

  static const _repo = 'https://github.com/Lukas200301/RaspberryPi-Control';

  Future<void> _open(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) showToast(context, 'Could not open the link', tone: Tone.danger);
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = ref.watch(_packageInfoProvider).valueOrNull;

    return PageScaffold(
      title: 'About',
      maxWidth: 760,
      body: PageList(
        children: [
          AppCard(
            variant: CardVariant.raised,
            child: Column(
              children: [
                const Gap(Insets.sm),
                const IconBadge(Icons.developer_board, size: 72),
                const Gap(Insets.md),
                Text('Raspberry Pi Control', style: context.tt.titleLarge),
                Text(
                  info == null ? '' : 'Version ${info.version} (${info.buildNumber})',
                  style: context.tt.bodyMedium?.copyWith(color: context.cs.onSurfaceVariant),
                ),
                const Gap(Insets.lg),
                FilledButton.icon(
                  onPressed: _checking
                      ? null
                      : () async {
                          setState(() => _checking = true);
                          await checkForAppUpdate(context);
                          if (mounted) setState(() => _checking = false);
                        },
                  icon: _checking
                      ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.system_update),
                  label: Text(_checking ? 'Checking…' : 'Check for updates'),
                ),
                const Gap(Insets.sm),
              ],
            ),
          ),
          const SectionHeader(title: 'Links'),
          TileGroup(
            children: [
              ActionTile(
                icon: Icons.code,
                title: 'Source code',
                subtitle: 'github.com/Lukas200301/RaspberryPi-Control',
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: () => _open(_repo),
              ),
              ActionTile(
                icon: Icons.bug_report_outlined,
                tone: Tone.warning,
                title: 'Report a problem',
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: () => _open('$_repo/issues/new/choose'),
              ),
              ActionTile(
                icon: Icons.gavel_outlined,
                tone: Tone.neutral,
                title: 'Open source licenses',
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: 'Raspberry Pi Control',
                  applicationVersion: info?.version,
                ),
              ),
            ],
          ),
          const SectionHeader(title: 'Reset'),
          TileGroup(
            children: [
              ActionTile(
                icon: Icons.restart_alt,
                destructive: true,
                title: 'Reset all settings',
                subtitle: 'Saved devices are kept',
                onTap: () async {
                  if (await showConfirmDialog(
                    context,
                    title: 'Reset all settings?',
                    message: 'Appearance, terminal, monitoring and all other settings go back to their defaults.',
                    confirmLabel: 'Reset',
                    destructive: true,
                  )) {
                    ref.read(settingsProvider.notifier).reset();
                    if (context.mounted) showToast(context, 'Settings reset', tone: Tone.success);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../constants/app_constants.dart';
import '../../providers/app_providers.dart';
import '../../services/agent_version_service.dart';
import '../../services/session_actions.dart';
import '../../theme/app_theme.dart';
import '../../ui/ui.dart';

/// Version and state of the Go agent, its log, restart and reinstall
final _agentStatusProvider = FutureProvider.autoDispose<({String version, bool isRoot})>((ref) async {
  final info = await ref.watch(grpcServiceProvider).getVersion();
  return (version: info.version, isRoot: info.isRoot);
});

class AgentPage extends ConsumerWidget {
  const AgentPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(_agentStatusProvider);
    final required = AgentVersionService.requiredAgentVersion;

    return PageScaffold(
      title: 'Agent',
      maxWidth: 760,
      actions: [
        IconButton(
          tooltip: 'Refresh',
          icon: const Icon(Icons.refresh),
          onPressed: () => ref.invalidate(_agentStatusProvider),
        ),
      ],
      body: PageList(
        children: [
          AppCard(
            child: status.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(Insets.lg),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Row(
                children: [
                  const IconBadge(Icons.cloud_off, tone: Tone.danger, size: 48),
                  const Gap(Insets.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Agent not reachable', style: context.tt.titleMedium),
                        Text(
                          describeError(e),
                          style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              data: (s) {
                final upToDate = AgentVersionService.compareVersions(s.version, required) >= 0;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const IconBadge(Icons.memory, tone: Tone.success, size: 48),
                        const Gap(Insets.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Pi Control Agent', style: context.tt.titleMedium),
                              Text(
                                'Version ${s.version}',
                                style: context.tt.bodyMedium?.copyWith(color: context.cs.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Gap(Insets.md),
                    Wrap(
                      spacing: Insets.sm,
                      runSpacing: Insets.sm,
                      children: [
                        const StatusPill('Running', tone: Tone.success, dot: true),
                        StatusPill(
                          s.isRoot ? 'Running as root' : 'Not root',
                          tone: s.isRoot ? Tone.success : Tone.warning,
                          icon: s.isRoot ? Icons.verified_user : Icons.gpp_maybe,
                        ),
                        StatusPill(
                          upToDate ? 'Up to date' : 'Update to $required',
                          tone: upToDate ? Tone.success : Tone.warning,
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          const SectionHeader(title: 'Actions'),
          TileGroup(
            children: [
              ActionTile(
                icon: Icons.article_outlined,
                title: 'Agent log',
                subtitle: AppConstants.agentInstallPath.replaceAll('/agent', '/agent.log'),
                onTap: () => _showLog(context, ref),
              ),
              ActionTile(
                icon: Icons.restart_alt,
                tone: Tone.warning,
                title: 'Restart agent',
                subtitle: 'Running streams reconnect afterwards',
                onTap: () => _restart(context, ref),
              ),
              ActionTile(
                icon: Icons.build_outlined,
                tone: Tone.danger,
                title: 'Reinstall agent',
                subtitle: 'Removes the agent; it is installed again on the next connection',
                onTap: () => _reinstall(context, ref),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showLog(BuildContext context, WidgetRef ref) async {
    final log = ref
        .read(sshServiceProvider)
        .execute('tail -n 300 /opt/pi-control/agent.log 2>&1 || echo "No log found"');
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.8,
        child: FutureBuilder<String>(
          future: log,
          builder: (context, snapshot) {
            if (!snapshot.hasData && !snapshot.hasError) return const LoadingState();
            final text = snapshot.hasError ? describeError(snapshot.error!) : snapshot.data!;
            return Padding(
              padding: const EdgeInsets.fromLTRB(Insets.lg, 0, Insets.lg, Insets.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Agent log', style: context.tt.titleLarge),
                  const Gap(Insets.md),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(color: context.ac.codeBackground, borderRadius: Radii.lgAll),
                      child: SingleChildScrollView(
                        reverse: true,
                        padding: const EdgeInsets.all(Insets.md),
                        child: SelectableText(
                          text.trim().isEmpty ? '(empty)' : text,
                          style: AppTheme.mono(size: 12, color: context.ac.codeForeground),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _restart(BuildContext context, WidgetRef ref) async {
    if (!await showConfirmDialog(
      context,
      title: 'Restart agent?',
      message: 'Live charts and log streams pause for a few seconds.',
      confirmLabel: 'Restart',
      icon: Icons.restart_alt,
    )) {
      return;
    }
    if (!context.mounted) return;
    showToast(context, 'Restarting agent…');
    try {
      await ref.read(agentManagerProvider).startAgent();
      ref.invalidate(_agentStatusProvider);
      if (context.mounted) showToast(context, 'Agent restarted', tone: Tone.success);
    } catch (e) {
      if (context.mounted) showToast(context, 'Restart failed: ${describeError(e)}', tone: Tone.danger);
    }
  }

  Future<void> _reinstall(BuildContext context, WidgetRef ref) async {
    if (!await showConfirmDialog(
      context,
      title: 'Reinstall agent?',
      message: 'The agent is removed from your Pi and installed fresh the next time you connect. You will be disconnected.',
      confirmLabel: 'Reinstall',
      destructive: true,
      icon: Icons.build_outlined,
    )) {
      return;
    }
    if (!context.mounted) return;
    showToast(context, 'Removing agent…', duration: const Duration(minutes: 1));

    final ssh = ref.read(sshServiceProvider);
    try {
      await ssh.execute('sudo pkill -f "^/opt/pi-control/agent " || true');
      await ssh.execute('sudo fuser -k 50051/tcp 2>/dev/null || true');
      await Future.delayed(const Duration(seconds: 1));
      await ssh.execute('sudo rm -rf /opt/pi-control /tmp/pi-control-agent');
      final check = await ssh.execute('ls /opt/pi-control/agent 2>&1 || echo "NOT_FOUND"');
      if (!check.contains('NOT_FOUND') && !check.contains('No such file')) {
        throw Exception('The old agent could not be removed');
      }
      if (context.mounted) {
        showToast(context, 'Agent removed. Connect again to install it.', tone: Tone.success);
        await disconnectAndLeave(context, ref, confirm: false);
      }
    } catch (e) {
      if (context.mounted) showToast(context, 'Reinstall failed: ${describeError(e)}', tone: Tone.danger);
    }
  }
}

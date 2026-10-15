import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../generated/pi_control.pb.dart';
import '../providers/app_providers.dart';
import '../services/session_actions.dart';
import '../theme/app_theme.dart';
import '../ui/ui.dart';
import 'packages_screen.dart';

/// Upgradable packages, OS info and whether a reboot is needed
final updateStatusProvider = FutureProvider.autoDispose<SystemUpdateStatus>((ref) {
  ref.watch(grpcSessionProvider);
  return ref.read(grpcServiceProvider).getSystemUpdateStatus();
});

String _ago(int unix) {
  if (unix <= 0) return 'never';
  final d = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(unix * 1000));
  if (d.inMinutes < 1) return 'just now';
  if (d.inHours < 1) return '${d.inMinutes} min ago';
  if (d.inDays < 1) return '${d.inHours} h ago';
  return '${d.inDays} ${d.inDays == 1 ? 'day' : 'days'} ago';
}

/// The Updates tab of the Packages screen: install all or single updates,
/// reboot when needed
class UpdatesView extends ConsumerStatefulWidget {
  const UpdatesView({super.key});

  @override
  ConsumerState<UpdatesView> createState() => _UpdatesViewState();
}

class _UpdatesViewState extends ConsumerState<UpdatesView> {
  bool _checking = false;
  bool _upgrading = false;
  bool? _upgradeOk;
  String _phase = '';
  int _total = 0;
  int _done = 0;
  bool _showLog = false;
  String _query = '';
  final List<String> _log = [];
  final Set<String> _single = {};
  StreamSubscription<UpgradeProgress>? _sub;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  /// apt-get update, then read the list again
  Future<void> _check() async {
    setState(() => _checking = true);
    try {
      final r = await ref.read(grpcServiceProvider).updatePackageList();
      if (mounted && !r.success) showToast(context, r.message, tone: Tone.danger);
    } catch (e) {
      if (mounted) showToast(context, describeError(e), tone: Tone.danger);
    } finally {
      ref.invalidate(updateStatusProvider);
      if (mounted) setState(() => _checking = false);
    }
  }

  void _upgradeAll(int count) {
    setState(() {
      _upgrading = true;
      _upgradeOk = null;
      _log.clear();
      _phase = 'update';
      _total = count;
      _done = 0;
    });
    _sub = ref
        .read(grpcServiceProvider)
        .streamSystemUpgrade()
        .listen(
          (p) {
            if (!mounted) return;
            setState(() {
              if (p.line.isNotEmpty) _log.add(p.line);
              if (p.line.startsWith('Setting up ')) _done++;
              _phase = p.phase;
              if (p.isComplete) {
                _upgrading = false;
                _upgradeOk = p.success;
              }
            });
            if (p.isComplete) ref.invalidate(updateStatusProvider);
          },
          onError: (Object e) {
            if (!mounted) return;
            setState(() {
              _upgrading = false;
              _upgradeOk = false;
              _log.add('Error: ${describeError(e)}');
            });
          },
          onDone: () {
            if (mounted && _upgrading) setState(() => _upgrading = false);
          },
        );
  }

  Future<void> _upgradeOne(String name) async {
    setState(() => _single.add(name));
    try {
      final r = await ref.read(grpcServiceProvider).updatePackage(name);
      if (!mounted) return;
      showToast(context, r.success ? 'Updated $name' : r.message, tone: r.success ? Tone.success : Tone.danger);
      if (r.success) ref.invalidate(updateStatusProvider);
    } catch (e) {
      if (mounted) showToast(context, describeError(e), tone: Tone.danger);
    } finally {
      if (mounted) setState(() => _single.remove(name));
    }
  }

  String get _phaseLabel => switch (_phase) {
    'update' => 'Refreshing package lists…',
    'upgrade' => _total > 0 ? 'Installing ($_done of $_total)…' : 'Installing…',
    'done' => 'Done',
    'error' => 'Failed',
    _ => 'Working…',
  };

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(updateStatusProvider);

    return PopScope(
      // Leaving does not stop apt, but the progress would be lost
      canPop: !_upgrading,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) showToast(context, 'Wait until the upgrade has finished');
      },
      child: Stack(
        children: [
          AsyncView(
            value: async,
            onRetry: () => ref.invalidate(updateStatusProvider),
            loadingMessage: 'Reading package status…',
            data: (s) => _content(s),
          ),
          if (_checking) const Positioned(top: 0, left: 0, right: 0, child: LinearProgressIndicator()),
        ],
      ),
    );
  }

  Widget _content(SystemUpdateStatus s) {
    final packages = [...s.upgradablePackages]
      ..sort((a, b) => a.security != b.security ? (a.security ? -1 : 1) : a.name.compareTo(b.name));
    final security = packages.where((p) => p.security).length;
    final q = _query.toLowerCase();
    final shown = q.isEmpty ? packages : packages.where((p) => p.name.toLowerCase().contains(q)).toList();
    final count = packages.length;

    return PageList(
      onRefresh: _check,
      children: [
        if (s.rebootRequired)
          Padding(
            padding: const EdgeInsets.only(bottom: Insets.md),
            child: AppCard(
              accent: context.ac.warning,
              child: Row(
                children: [
                  const IconBadge(Icons.restart_alt, tone: Tone.warning),
                  const Gap(Insets.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Restart required', style: context.tt.titleSmall),
                        Text(
                          s.rebootPackages.isEmpty
                              ? 'Installed updates take effect after a reboot.'
                              : 'For ${s.rebootPackages.take(4).join(', ')}${s.rebootPackages.length > 4 ? ' and ${s.rebootPackages.length - 4} more' : ''}.',
                          style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _upgrading ? null : () => confirmPower(context, ref, PowerOp.POWER_REBOOT),
                    child: const Text('Reboot'),
                  ),
                ],
              ),
            ),
          ),
        AppCard(
          variant: CardVariant.raised,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconBadge(
                    _upgrading
                        ? Icons.downloading
                        : count == 0
                        ? Icons.verified_outlined
                        : Icons.system_update_alt,
                    tone: _upgrading
                        ? Tone.info
                        : count == 0
                        ? Tone.success
                        : (security > 0 ? Tone.danger : Tone.warning),
                    size: 48,
                  ),
                  const Gap(Insets.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _upgrading
                              ? _phaseLabel
                              : count == 0
                              ? 'Up to date'
                              : '$count ${count == 1 ? 'update' : 'updates'} available',
                          style: context.tt.titleMedium,
                        ),
                        Text(
                          _upgrading
                              ? 'Keep the app open until it has finished.'
                              : count == 0
                              ? 'Checked ${_ago(s.lastUpdateUnix.toInt())}. Pull down to check again.'
                              : security > 0
                              ? '$security security ${security == 1 ? 'update' : 'updates'} included'
                              : 'Checked ${_ago(s.lastUpdateUnix.toInt())}',
                          style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_upgrading) ...[
                const Gap(Insets.md),
                LinearProgressIndicator(
                  value: _phase == 'upgrade' && _total > 0 ? (_done / _total).clamp(0.0, 1.0) : null,
                ),
              ] else if (count > 0) ...[
                const Gap(Insets.lg),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () async {
                      if (await showConfirmDialog(
                        context,
                        title: 'Install $count ${count == 1 ? 'update' : 'updates'}?',
                        message:
                            'Runs apt-get update and apt-get upgrade. Changed configuration files are kept. '
                            'Services may restart briefly.',
                        confirmLabel: 'Install',
                        icon: Icons.system_update_alt,
                      )) {
                        _upgradeAll(count);
                      }
                    },
                    icon: const Icon(Icons.system_update_alt),
                    label: const Text('Install all'),
                  ),
                ),
              ],
              if (_upgradeOk != null && !_upgrading) ...[
                const Gap(Insets.md),
                StatusPill(
                  _upgradeOk! ? 'Last upgrade finished' : 'Last upgrade failed, see the log',
                  tone: _upgradeOk! ? Tone.success : Tone.danger,
                  icon: _upgradeOk! ? Icons.check : Icons.error_outline,
                ),
              ],
            ],
          ),
        ),
        if (_log.isNotEmpty) ...[
          SectionHeader(
            title: 'Output',
            trailing: TextButton(
              onPressed: () => setState(() => _showLog = !_showLog),
              child: Text(_showLog ? 'Hide' : 'Show ${_log.length} lines'),
            ),
          ),
          if (_showLog || _upgrading)
            Container(
              height: 260,
              decoration: BoxDecoration(color: context.ac.codeBackground, borderRadius: Radii.mdAll),
              padding: const EdgeInsets.all(Insets.md),
              child: ListView.builder(
                reverse: true,
                itemCount: _log.length,
                itemBuilder: (context, i) {
                  final line = _log[_log.length - 1 - i];
                  return Text(
                    line,
                    style: AppTheme.mono(
                      size: 11.5,
                      color: line.startsWith('Error') || line.startsWith('E:')
                          ? context.cs.error
                          : context.ac.codeForeground,
                    ),
                  );
                },
              ),
            ),
        ],
        if (count > 0) ...[
          SectionHeader(title: 'Packages', subtitle: security > 0 ? 'Security updates first' : null),
          if (count > 8) ...[
            SearchField(hint: 'Search packages', onChanged: (v) => setState(() => _query = v)),
            const Gap(Insets.sm),
          ],
          if (shown.isEmpty)
            AppCard(
              child: Text(
                'No update for "$_query".',
                style: context.tt.bodyMedium?.copyWith(color: context.cs.onSurfaceVariant),
              ),
            )
          else
            TileGroup(
              children: [
                for (final p in shown)
                  ListTile(
                    leading: Icon(
                      p.security ? Icons.shield_outlined : Icons.arrow_circle_up_outlined,
                      color: p.security ? context.cs.error : context.cs.onSurfaceVariant,
                    ),
                    title: Row(
                      children: [
                        Flexible(child: Text(p.name, overflow: TextOverflow.ellipsis)),
                        if (p.security) ...[const Gap(Insets.xs), const StatusPill('security', tone: Tone.danger)],
                      ],
                    ),
                    subtitle: Text(
                      '${p.currentVersion.isEmpty ? '?' : p.currentVersion}  →  ${p.newVersion}',
                      style: AppTheme.mono(size: 11.5, color: context.cs.onSurfaceVariant),
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: _single.contains(p.name)
                        ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : IconButton(
                            tooltip: 'Update ${p.name}',
                            icon: const Icon(Icons.download_outlined),
                            onPressed: _upgrading ? null : () => _upgradeOne(p.name),
                          ),
                  ),
              ],
            ),
        ],
        const SectionHeader(title: 'System'),
        AppCard(
          child: Column(
            children: [
              InfoRow('Operating system', s.osName),
              InfoRow('Kernel', s.kernelVersion, mono: true),
              InfoRow('Architecture', s.architecture),
              InfoRow('Uptime', s.uptime),
            ],
          ),
        ),
      ],
    );
  }
}

/// Old entry point: opens the Packages screen on its Updates tab
class SystemUpdateScreen extends StatelessWidget {
  const SystemUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) => const PackagesScreen(initialTab: PackagesTab.updates);
}

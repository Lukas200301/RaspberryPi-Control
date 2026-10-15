import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../generated/pi_control.pb.dart';
import '../providers/app_providers.dart';
import '../ui/ui.dart';
import 'journal_screen.dart';

enum _Filter { all, running, failed, stopped, boot }

/// Units whose stop or restart can cut the app off from the device
const _critical = ['ssh', 'sshd', 'networking', 'NetworkManager', 'dhcpcd', 'systemd-networkd', 'wpa_supplicant'];

bool _isCritical(ServiceInfo s) => _critical.contains(s.name.replaceAll('.service', ''));

Tone _tone(ServiceInfo s) => switch ((s.status, s.subState)) {
  ('failed', _) => Tone.danger,
  (_, 'running') => Tone.success,
  ('active', _) => Tone.info,
  _ => Tone.neutral,
};

String _stateLabel(ServiceInfo s) => s.status == 'failed'
    ? 'failed'
    : s.subState.isEmpty
    ? s.status
    : s.subState;

/// systemd services: status, start/stop/restart, boot behaviour and logs
class ServicesScreen extends ConsumerStatefulWidget {
  const ServicesScreen({super.key});

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen> {
  String _query = '';
  _Filter _filter = _Filter.all;
  final _busy = <String>{};

  bool _matches(ServiceInfo s, _Filter f) => switch (f) {
    _Filter.all => true,
    _Filter.running => s.subState == 'running',
    _Filter.failed => s.status == 'failed',
    _Filter.stopped => s.subState != 'running' && s.status != 'failed',
    _Filter.boot => s.enabled,
  };

  Future<void> _run(ServiceInfo s, ServiceAction action) async {
    final verb = switch (action) {
      ServiceAction.START => 'Start',
      ServiceAction.STOP => 'Stop',
      ServiceAction.RESTART => 'Restart',
      ServiceAction.RELOAD => 'Reload',
      ServiceAction.ENABLE => 'Enable',
      ServiceAction.DISABLE => 'Disable',
      _ => action.name,
    };
    if ((action == ServiceAction.STOP || action == ServiceAction.RESTART || action == ServiceAction.DISABLE) &&
        _isCritical(s) &&
        !await showConfirmDialog(
          context,
          title: '$verb ${s.name}?',
          message: 'The app reaches this device through this service. '
              '${action == ServiceAction.DISABLE ? 'After a reboot' : 'Right away'} you may lose the connection '
              'and need physical access to get it back.',
          confirmLabel: verb,
          destructive: true,
          icon: Icons.warning_amber_rounded,
        )) {
      return;
    }
    setState(() => _busy.add(s.name));
    try {
      final result = await ref.read(grpcServiceProvider).manageService(s.name, action);
      if (!mounted) return;
      showToast(
        context,
        result.success ? '$verb ${s.name}: done' : result.message,
        tone: result.success ? Tone.success : Tone.danger,
      );
      if (result.success) ref.invalidate(serviceListProvider);
    } catch (e) {
      if (mounted) showToast(context, describeError(e), tone: Tone.danger);
    } finally {
      if (mounted) setState(() => _busy.remove(s.name));
    }
  }

  void _openLogs(ServiceInfo s) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => JournalScreen(service: s.name)));

  void _details(ServiceInfo s) {
    final running = s.subState == 'running';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheet) {
        Widget action(IconData icon, String label, ServiceAction a, {Tone tone = Tone.primary}) => Expanded(
          child: FilledButton.tonalIcon(
            style: FilledButton.styleFrom(
              backgroundColor: sheet.toneContainer(tone),
              foregroundColor: sheet.tone(tone),
              padding: const EdgeInsets.symmetric(vertical: Insets.md),
            ),
            onPressed: () {
              Navigator.pop(sheet);
              _run(s, a);
            },
            icon: Icon(icon),
            label: Text(label),
          ),
        );

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Insets.xl, 0, Insets.xl, Insets.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconBadge(Icons.settings_applications_outlined, tone: _tone(s), size: 48),
                    const Gap(Insets.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.name, style: sheet.tt.titleLarge, overflow: TextOverflow.ellipsis),
                          if (s.description.isNotEmpty)
                            Text(
                              s.description,
                              style: sheet.tt.bodySmall?.copyWith(color: sheet.cs.onSurfaceVariant),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Gap(Insets.md),
                Wrap(
                  spacing: Insets.xs,
                  runSpacing: Insets.xs,
                  children: [
                    StatusPill(_stateLabel(s), tone: _tone(s), dot: true),
                    StatusPill(s.status, icon: Icons.info_outline),
                    StatusPill(
                      s.enabled ? 'Starts at boot' : 'Not started at boot',
                      icon: s.enabled ? Icons.power_settings_new : Icons.power_off_outlined,
                      tone: s.enabled ? Tone.primary : Tone.neutral,
                    ),
                  ],
                ),
                const Gap(Insets.lg),
                Row(
                  children: [
                    if (!running) action(Icons.play_arrow, 'Start', ServiceAction.START, tone: Tone.success),
                    if (running) action(Icons.stop, 'Stop', ServiceAction.STOP, tone: Tone.danger),
                    const Gap(Insets.sm),
                    action(Icons.restart_alt, 'Restart', ServiceAction.RESTART, tone: Tone.warning),
                  ],
                ),
                if (running) ...[
                  const Gap(Insets.sm),
                  Row(children: [action(Icons.sync, 'Reload configuration', ServiceAction.RELOAD, tone: Tone.info)]),
                ],
                const Gap(Insets.md),
                TileGroup(
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.power_settings_new),
                      title: const Text('Start at boot'),
                      subtitle: Text(s.enabled ? 'Enabled' : 'Disabled'),
                      value: s.enabled,
                      onChanged: (v) {
                        Navigator.pop(sheet);
                        _run(s, v ? ServiceAction.ENABLE : ServiceAction.DISABLE);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.receipt_long_outlined),
                      title: const Text('Logs'),
                      subtitle: const Text('Live journal of this service'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.pop(sheet);
                        _openLogs(s);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(serviceListProvider);
    final all = async.valueOrNull?.services ?? const <ServiceInfo>[];
    final q = _query.toLowerCase();
    final shown = all.where((s) {
      if (!_matches(s, _filter)) return false;
      return q.isEmpty || s.name.toLowerCase().contains(q) || s.description.toLowerCase().contains(q);
    }).toList()
      // Problems first, then running, then the rest by name
      ..sort((a, b) {
        int rank(ServiceInfo s) => s.status == 'failed' ? 0 : (s.subState == 'running' ? 1 : 2);
        final r = rank(a).compareTo(rank(b));
        return r != 0 ? r : a.name.compareTo(b.name);
      });

    final running = all.where((s) => s.subState == 'running').length;
    final failed = all.where((s) => s.status == 'failed').length;

    return PageScaffold(
      title: 'Services',
      subtitle: all.isEmpty ? null : '$running running${failed > 0 ? ' · $failed failed' : ''} · ${all.length} total',
      actions: [
        IconButton(
          tooltip: 'Refresh',
          icon: const Icon(Icons.refresh),
          onPressed: () => ref.invalidate(serviceListProvider),
        ),
      ],
      bottom: SearchFilterBar<_Filter>(
        hint: 'Search services',
        onSearch: (v) => setState(() => _query = v),
        selected: _filter,
        onFilter: (f) => setState(() => _filter = f),
        filters: [
          FilterOption(_Filter.all, 'All', count: all.length),
          FilterOption(_Filter.running, 'Running', count: running),
          if (failed > 0) FilterOption(_Filter.failed, 'Failed', count: failed, icon: Icons.error_outline),
          FilterOption(_Filter.stopped, 'Stopped', count: all.where((s) => _matches(s, _Filter.stopped)).length),
          FilterOption(_Filter.boot, 'At boot', count: all.where((s) => s.enabled).length),
        ],
      ),
      body: AsyncView(
        value: async,
        onRetry: () => ref.invalidate(serviceListProvider),
        loadingMessage: 'Loading services…',
        data: (_) => shown.isEmpty
            ? EmptyState(
                icon: Icons.search_off,
                title: all.isEmpty ? 'No services' : 'No services match',
                message: all.isEmpty ? null : 'Try another search or filter.',
              )
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(serviceListProvider),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(Insets.page, Insets.xs, Insets.page, 96),
                  itemCount: shown.length,
                  itemBuilder: (context, i) => Padding(
                    padding: const EdgeInsets.only(bottom: Insets.sm),
                    child: _ServiceTile(
                      service: shown[i],
                      busy: _busy.contains(shown[i].name),
                      onTap: () => _details(shown[i]),
                      onStart: () => _run(shown[i], ServiceAction.START),
                      onRestart: () => _run(shown[i], ServiceAction.RESTART),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final ServiceInfo service;
  final bool busy;
  final VoidCallback onTap;
  final VoidCallback onStart;
  final VoidCallback onRestart;

  const _ServiceTile({
    required this.service,
    required this.busy,
    required this.onTap,
    required this.onStart,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final s = service;
    final tone = _tone(s);
    final running = s.subState == 'running';
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(Insets.lg, Insets.md, Insets.xs, Insets.md),
      accent: s.status == 'failed' ? context.cs.error : null,
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: context.tone(tone), shape: BoxShape.circle),
          ),
          const Gap(Insets.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        s.name.replaceAll('.service', ''),
                        style: context.tt.titleSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (s.enabled) ...[
                      const Gap(Insets.xs),
                      Tooltip(
                        message: 'Starts at boot',
                        child: Icon(Icons.power_settings_new, size: 14, color: context.cs.primary),
                      ),
                    ],
                  ],
                ),
                if (s.description.isNotEmpty)
                  Text(
                    s.description,
                    style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const Gap(Insets.sm),
          StatusPill(_stateLabel(s), tone: tone),
          SizedBox(
            width: 44,
            child: busy
                ? const Center(child: SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)))
                : s.status == 'failed'
                ? IconButton(tooltip: 'Restart', icon: const Icon(Icons.restart_alt), onPressed: onRestart)
                : !running
                ? IconButton(tooltip: 'Start', icon: const Icon(Icons.play_arrow), onPressed: onStart)
                : const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}

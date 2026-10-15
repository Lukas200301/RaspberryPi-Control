import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../../models/alerts.dart';
import '../../services/alert_center.dart';
import '../../ui/ui.dart';
import 'alert_settings_page.dart';

IconData alertIcon(AlertKind kind) => switch (kind) {
  AlertKind.offline => Icons.cloud_off_outlined,
  AlertKind.load => Icons.speed,
  AlertKind.memory => Icons.memory,
  AlertKind.disk => Icons.storage,
  AlertKind.temperature => Icons.thermostat,
  AlertKind.service => Icons.settings_applications_outlined,
  AlertKind.pm2 => Icons.rocket_launch_outlined,
  AlertKind.container => Icons.view_in_ar_outlined,
  AlertKind.reboot => Icons.restart_alt,
};

Tone alertTone(AlertEvent e) => e.resolved
    ? Tone.success
    : switch (e.severity) {
        AlertSeverity.critical => Tone.danger,
        AlertSeverity.warning => Tone.warning,
        AlertSeverity.info => Tone.info,
      };

void openAlerts(BuildContext context) =>
    Navigator.push(context, MaterialPageRoute(builder: (_) => const AlertsScreen()));

enum _Filter { all, problems, resolved }

class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({super.key});

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen> {
  _Filter _filter = _Filter.all;
  String? _device;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    // Seeing the list counts as reading it
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(alertCenterProvider.notifier).markAllRead();
    });
  }

  @override
  void deactivate() {
    ref.read(alertCenterProvider.notifier).markAllRead();
    super.deactivate();
  }

  Future<void> _checkNow() async {
    setState(() => _checking = true);
    try {
      await ref.read(alertCenterProvider.notifier).checkDue(force: true);
      if (mounted) showToast(context, 'All devices checked', tone: Tone.success);
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(alertCenterProvider);
    final center = ref.read(alertCenterProvider.notifier);
    final active = center.active;
    final rules = data.rules;

    final devices = {for (final e in data.history) e.deviceId: e.deviceName};
    final history = data.history.where((e) {
      if (_device != null && e.deviceId != _device) return false;
      return switch (_filter) {
        _Filter.all => true,
        _Filter.problems => !e.resolved,
        _Filter.resolved => e.resolved,
      };
    }).toList();

    return PageScaffold(
      title: 'Alerts',
      subtitle: !rules.enabled
          ? 'Off'
          : active.isEmpty
          ? 'All good'
          : '${active.length} active',
      maxWidth: 900,
      actions: [
        if (rules.enabled)
          IconButton(
            tooltip: 'Check now',
            onPressed: _checking ? null : _checkNow,
            icon: _checking
                ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.refresh),
          ),
        IconButton(
          tooltip: 'Alert settings',
          icon: const Icon(Icons.tune),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AlertSettingsPage())),
        ),
        PopupMenuButton<String>(
          onSelected: (v) async {
            if (v == 'clear' &&
                await showConfirmDialog(
                  context,
                  title: 'Clear the history?',
                  message: 'Active alerts stay until they are resolved.',
                  confirmLabel: 'Clear',
                  destructive: true,
                )) {
              await center.clearHistory();
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'clear',
              child: ListTile(leading: Icon(Icons.delete_sweep_outlined), title: Text('Clear history')),
            ),
          ],
        ),
      ],
      body: !rules.enabled
          ? EmptyState(
              icon: Icons.notifications_off_outlined,
              title: 'Alerts are off',
              message: 'Turn them on to hear about devices that go offline, overheat, run out of space or have failing services.',
              action: FilledButton.icon(
                onPressed: () =>
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AlertSettingsPage())),
                icon: const Icon(Icons.notifications_active_outlined),
                label: const Text('Set up alerts'),
              ),
            )
          : PageList(
              onRefresh: _checkNow,
              children: [
                SectionHeader(title: 'Now'),
                if (active.isEmpty)
                  AppCard(
                    child: Row(
                      children: [
                        const IconBadge(Icons.verified_outlined, tone: Tone.success),
                        const Gap(Insets.md),
                        Expanded(
                          child: Text(
                            'No active alerts.',
                            style: context.tt.bodyMedium?.copyWith(color: context.cs.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  for (final e in active) ...[
                    _ActiveAlertCard(event: e),
                    const Gap(Insets.sm),
                  ],
                SectionHeader(title: 'History', subtitle: data.history.isEmpty ? null : 'Last ${data.history.length} events'),
                if (data.history.isNotEmpty) ...[
                  FilterChips<_Filter>(
                    options: const [
                      FilterOption(_Filter.all, 'All'),
                      FilterOption(_Filter.problems, 'Problems', icon: Icons.error_outline),
                      FilterOption(_Filter.resolved, 'Resolved', icon: Icons.check_circle_outline),
                    ],
                    selected: _filter,
                    onSelected: (f) => setState(() => _filter = f),
                  ),
                  if (devices.length > 1) ...[
                    const Gap(Insets.sm),
                    FilterChips<String?>(
                      options: [
                        const FilterOption(null, 'All devices'),
                        for (final d in devices.entries) FilterOption(d.key, d.value, icon: Icons.developer_board),
                      ],
                      selected: _device,
                      onSelected: (d) => setState(() => _device = d),
                    ),
                  ],
                  const Gap(Insets.md),
                ],
                if (history.isEmpty)
                  AppCard(
                    child: Text(
                      data.history.isEmpty ? 'Nothing has happened yet.' : 'No events match the filter.',
                      style: context.tt.bodyMedium?.copyWith(color: context.cs.onSurfaceVariant),
                    ),
                  )
                else
                  ..._grouped(context, history),
              ],
            ),
    );
  }

  List<Widget> _grouped(BuildContext context, List<AlertEvent> events) {
    final widgets = <Widget>[];
    final now = DateTime.now();
    String day(DateTime t) {
      final d = DateTime(t.year, t.month, t.day);
      final today = DateTime(now.year, now.month, now.day);
      final diff = today.difference(d).inDays;
      if (diff == 0) return 'Today';
      if (diff == 1) return 'Yesterday';
      return DateFormat.yMMMEd().format(t);
    }

    String? current;
    var group = <AlertEvent>[];
    void flush() {
      if (group.isEmpty) return;
      widgets.add(Padding(
        padding: const EdgeInsets.fromLTRB(Insets.xs, Insets.md, Insets.xs, Insets.sm),
        child: Text(current!, style: context.tt.labelLarge?.copyWith(color: context.cs.onSurfaceVariant)),
      ));
      widgets.add(TileGroup(children: [for (final e in group) _HistoryTile(event: e)]));
      group = [];
    }

    for (final e in events) {
      final d = day(e.time);
      if (d != current) {
        flush();
        current = d;
      }
      group.add(e);
    }
    flush();
    return widgets;
  }
}

class _ActiveAlertCard extends StatelessWidget {
  final AlertEvent event;

  const _ActiveAlertCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final tone = alertTone(event);
    return AppCard(
      accent: context.tone(tone),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(alertIcon(event.kind), tone: tone),
          const Gap(Insets.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, style: context.tt.titleSmall),
                const Gap(Insets.xxs),
                Text(event.message, style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant)),
                const Gap(Insets.sm),
                Wrap(
                  spacing: Insets.xs,
                  runSpacing: Insets.xs,
                  children: [
                    StatusPill(event.deviceName, icon: Icons.developer_board),
                    StatusPill('since ${_since(event.time)}', icon: Icons.schedule, tone: tone),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final AlertEvent event;

  const _HistoryTile({required this.event});

  @override
  Widget build(BuildContext context) {
    final tone = alertTone(event);
    return ListTile(
      leading: IconBadge(event.resolved ? Icons.check_circle_outline : alertIcon(event.kind), tone: tone, size: 36),
      title: Text(event.title, style: context.tt.bodyLarge?.copyWith(
        fontWeight: event.read ? FontWeight.w400 : FontWeight.w600,
      )),
      subtitle: Text(
        '${event.message}\n${event.deviceName} · ${DateFormat.Hm().format(event.time)}',
        style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant),
      ),
      isThreeLine: true,
    );
  }
}

String _since(DateTime t) {
  final d = DateTime.now().difference(t);
  if (d.inMinutes < 1) return 'just now';
  if (d.inHours < 1) return '${d.inMinutes} min';
  if (d.inDays < 1) return '${d.inHours} h ${d.inMinutes % 60} min';
  return '${d.inDays} d ${d.inHours % 24} h';
}

/// Bell for app bars: shows unread alerts, or active ones once read
class AlertsButton extends ConsumerWidget {
  const AlertsButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(alertCenterProvider);
    final center = ref.read(alertCenterProvider.notifier);
    final unread = center.unread;
    final active = center.active.length;
    final count = unread > 0 ? unread : active;
    return IconButton(
      tooltip: 'Alerts',
      onPressed: () => openAlerts(context),
      icon: Badge(
        isLabelVisible: data.rules.enabled && count > 0,
        label: Text('$count'),
        backgroundColor: active > 0 ? context.cs.error : context.cs.primary,
        textColor: active > 0 ? context.cs.onError : context.cs.onPrimary,
        child: Icon(
          !data.rules.enabled
              ? Icons.notifications_none
              : active > 0
              ? Icons.notifications_active
              : Icons.notifications_outlined,
        ),
      ),
    );
  }
}

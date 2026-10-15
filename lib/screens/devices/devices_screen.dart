import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../models/ssh_connection.dart';
import '../../providers/app_providers.dart';
import '../../providers/settings_provider.dart';
import '../../services/alert_center.dart';
import '../../services/device_probe.dart';
import '../../services/network_discovery_service.dart';
import '../../ui/ui.dart';
import '../alerts/alerts_screen.dart';
import '../settings/settings_screen.dart';
import 'connect_sheet.dart';
import 'device_form.dart';

/// Start screen: every saved device with live status, health and quick
/// connect
class DevicesScreen extends ConsumerStatefulWidget {
  const DevicesScreen({super.key});

  @override
  ConsumerState<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends ConsumerState<DevicesScreen> {
  String _query = '';
  String _group = '';

  @override
  Widget build(BuildContext context) {
    final devices = ref.watch(connectionListProvider);
    final statuses = ref.watch(deviceStatusProvider);
    final groups = {for (final d in devices) if (d.group.isNotEmpty) d.group}.toList()..sort();

    final q = _query.toLowerCase();
    final visible = devices.where((d) {
      if (_group.isNotEmpty && d.group != _group) return false;
      if (q.isEmpty) return true;
      return d.name.toLowerCase().contains(q) ||
          d.host.toLowerCase().contains(q) ||
          d.username.toLowerCase().contains(q);
    }).toList()
      ..sort((a, b) {
        if (a.isFavorite != b.isFavorite) return a.isFavorite ? -1 : 1;
        final la = a.lastConnected?.millisecondsSinceEpoch ?? 0;
        final lb = b.lastConnected?.millisecondsSinceEpoch ?? 0;
        if (la != lb) return lb.compareTo(la);
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

    final online = devices.where((d) => statuses[d.id]?.reachability == Reachability.online).length;

    return PageScaffold(
      title: 'Devices',
      subtitle: devices.isEmpty ? null : '$online of ${devices.length} online',
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          tooltip: 'Scan network',
          icon: const Icon(Icons.radar),
          onPressed: () => _scan(context),
        ),
        IconButton(
          tooltip: 'Refresh',
          icon: const Icon(Icons.refresh),
          onPressed: () => ref.read(deviceStatusProvider.notifier).refreshAll(),
        ),
        const AlertsButton(),
        IconButton(
          tooltip: 'Settings',
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
        ),
      ],
      floatingActionButton: devices.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => showDeviceForm(context),
              icon: const Icon(Icons.add),
              label: const Text('Add device'),
            ),
      body: devices.isEmpty
          ? EmptyState(
              icon: Icons.developer_board,
              title: 'Add your first Pi',
              message:
                  'Connect over SSH with a password or key. The app installs a small agent '
                  'for live stats and system control.',
              action: Column(
                children: [
                  FilledButton.icon(
                    onPressed: () => showDeviceForm(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add device'),
                  ),
                  const Gap(Insets.sm),
                  TextButton.icon(
                    onPressed: () => _scan(context),
                    icon: const Icon(Icons.radar),
                    label: const Text('Find devices on this network'),
                  ),
                ],
              ),
            )
          : PageList(
              onRefresh: () => ref.read(deviceStatusProvider.notifier).refreshAll(),
              children: [
                if (devices.length > 4) ...[
                  SearchField(hint: 'Search devices', onChanged: (v) => setState(() => _query = v)),
                  const Gap(Insets.md),
                ],
                if (groups.isNotEmpty) ...[
                  FilterChips<String>(
                    options: [
                      FilterOption('', 'All', count: devices.length),
                      for (final g in groups)
                        FilterOption(g, g, count: devices.where((d) => d.group == g).length),
                    ],
                    selected: _group,
                    onSelected: (g) => setState(() => _group = g),
                  ),
                  const Gap(Insets.md),
                ],
                ResponsiveGrid(
                  minItemWidth: 360,
                  children: [
                    for (final d in visible) _DeviceCard(device: d, status: statuses[d.id]),
                  ],
                ),
              ],
            ),
    );
  }

  Future<void> _scan(BuildContext context) async {
    final picked = await showModalBottomSheet<DiscoveredDevice>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _ScanSheet(),
    );
    if (picked != null && context.mounted) {
      await showDeviceForm(
        context,
        host: picked.host,
        port: picked.port,
        name: picked.name == picked.host ? null : picked.name,
      );
    }
  }
}

class _DeviceCard extends ConsumerWidget {
  final SSHConnection device;
  final DeviceStatus? status;

  const _DeviceCard({required this.device, this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final alerts = ref.watch(alertCenterProvider);
    final activeAlerts = alerts.rules.monitors(device.id)
        ? ref.read(alertCenterProvider.notifier).activeFor(device.id)
        : const [];
    final reach = status?.reachability ?? Reachability.unknown;
    final snap = status?.snapshot;

    final (Tone tone, String label) = switch (reach) {
      Reachability.online => (Tone.success, status?.latencyMs != null ? 'Online · ${status!.latencyMs} ms' : 'Online'),
      Reachability.offline => (Tone.danger, 'Offline'),
      Reachability.checking when snap == null && status?.checkedAt == null => (Tone.neutral, 'Checking…'),
      Reachability.checking => (Tone.success, 'Online'),
      Reachability.unknown => (Tone.neutral, 'Checking…'),
    };
    final offline = reach == Reachability.offline;

    Widget metric(String label, double percent, String text, Tone tone) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: context.tt.labelSmall?.copyWith(color: context.cs.onSurfaceVariant)),
          const Gap(2),
          Text(text, style: context.tt.titleSmall?.copyWith(fontFeatures: tabularFigures)),
          const Gap(Insets.xs),
          UsageBar(value: percent / 100, color: context.tone(tone), height: 5),
        ],
      ),
    );

    return AppCard(
      onTap: () => connectToDevice(context, device),
      onLongPress: () => _menu(context, ref),
      padding: const EdgeInsets.fromLTRB(Insets.lg, Insets.md, Insets.xs, Insets.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(Icons.developer_board, tone: offline ? Tone.neutral : Tone.primary, size: 44),
              const Gap(Insets.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(device.name, style: context.tt.titleMedium, overflow: TextOverflow.ellipsis),
                        ),
                        if (device.isFavorite) ...[
                          const Gap(Insets.xs),
                          Icon(Icons.star_rounded, size: 18, color: context.ac.warning),
                        ],
                      ],
                    ),
                    Text(
                      device.address,
                      style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'More',
                icon: const Icon(Icons.more_vert),
                onPressed: () => _menu(context, ref),
              ),
            ],
          ),
          const Gap(Insets.sm),
          Padding(
            padding: const EdgeInsets.only(right: Insets.md),
            child: Wrap(
              spacing: Insets.xs,
              runSpacing: Insets.xs,
              children: [
                StatusPill(label, tone: tone, dot: true),
                if (activeAlerts.isNotEmpty)
                  StatusPill(
                    activeAlerts.length == 1 ? activeAlerts.first.kind.label : '${activeAlerts.length} alerts',
                    tone: Tone.danger,
                    icon: Icons.notifications_active,
                  ),
                if (snap != null && snap.uptimeSeconds > 0)
                  StatusPill('Up ${formatDuration(Duration(seconds: snap.uptimeSeconds))}', icon: Icons.schedule),
                if (device.group.isNotEmpty) StatusPill(device.group, icon: Icons.folder_outlined),
                if (device.usesKey) const StatusPill('Key', icon: Icons.key),
              ],
            ),
          ),
          if (snap != null && !offline) ...[
            const Gap(Insets.md),
            Padding(
              padding: const EdgeInsets.only(right: Insets.md),
              child: Row(
                children: [
                  metric('Load', snap.loadPercent, '${snap.loadPercent.toStringAsFixed(0)}%', usageTone(snap.loadPercent)),
                  const Gap(Insets.md),
                  metric('RAM', snap.memPercent, '${snap.memPercent.toStringAsFixed(0)}%', usageTone(snap.memPercent, warn: 80)),
                  const Gap(Insets.md),
                  metric('Disk', snap.diskPercent, '${snap.diskPercent.toStringAsFixed(0)}%', usageTone(snap.diskPercent, warn: 80)),
                  if (snap.hasTemp) ...[
                    const Gap(Insets.md),
                    metric(
                      'Temp',
                      (snap.tempC / settings.tempCritical * 100).clamp(0, 100),
                      settings.formatTemperature(snap.tempC, digits: 0),
                      snap.tempC >= settings.tempCritical
                          ? Tone.danger
                          : snap.tempC >= settings.tempWarning
                          ? Tone.warning
                          : Tone.success,
                    ),
                  ],
                ],
              ),
            ),
            if (snap.model.isNotEmpty || snap.os.isNotEmpty) ...[
              const Gap(Insets.sm),
              Text(
                [snap.model, snap.os].where((s) => s.isNotEmpty).join(' · '),
                style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ] else if (status?.error != null && !offline) ...[
            const Gap(Insets.sm),
            Text(
              status!.error!,
              style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant),
            ),
          ],
          if (device.lastConnected != null) ...[
            const Gap(Insets.sm),
            Text(
              'Last connected ${_ago(device.lastConnected!)}',
              style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }

  static String _ago(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'just now';
    if (d.inHours < 1) return '${d.inMinutes} min ago';
    if (d.inDays < 1) return '${d.inHours} h ago';
    if (d.inDays < 30) return '${d.inDays} d ago';
    return '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';
  }

  void _menu(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(connectionListProvider.notifier);
    showActionSheet(
      context,
      title: device.name,
      subtitle: device.address,
      actions: [
        SheetAction(icon: Icons.login, label: 'Connect', onTap: () => connectToDevice(context, device)),
        SheetAction(
          icon: device.isFavorite ? Icons.star_outline_rounded : Icons.star_rounded,
          label: device.isFavorite ? 'Remove from favorites' : 'Add to favorites',
          tone: Tone.warning,
          onTap: () => notifier.toggleFavorite(device.id),
        ),
        SheetAction(icon: Icons.edit_outlined, label: 'Edit', onTap: () => showDeviceForm(context, device: device)),
        SheetAction(
          icon: Icons.copy_all_outlined,
          label: 'Duplicate',
          onTap: () => notifier.addConnection(
            device.copyWith(
              id: DateTime.now().microsecondsSinceEpoch.toString(),
              name: '${device.name} (copy)',
              isFavorite: false,
            ),
          ),
        ),
        if (ref.read(alertCenterProvider).rules.enabled)
          SheetAction(
            icon: ref.read(alertCenterProvider).rules.mutedDevices.contains(device.id)
                ? Icons.notifications_active_outlined
                : Icons.notifications_off_outlined,
            label: ref.read(alertCenterProvider).rules.mutedDevices.contains(device.id)
                ? 'Watch for alerts'
                : 'Mute alerts',
            onTap: () => ref
                .read(alertCenterProvider.notifier)
                .setMuted(device.id, !ref.read(alertCenterProvider).rules.mutedDevices.contains(device.id)),
          ),
        SheetAction(
          icon: Icons.refresh,
          label: 'Check status now',
          tone: Tone.info,
          onTap: () => ref.read(deviceStatusProvider.notifier).refresh(device),
        ),
        SheetAction(
          icon: Icons.delete_outline,
          label: 'Delete',
          destructive: true,
          onTap: () async {
            if (await showConfirmDialog(
              context,
              title: 'Delete ${device.name}?',
              message: 'The saved login is removed from this phone. Nothing changes on the device.',
              confirmLabel: 'Delete',
              destructive: true,
            )) {
              await notifier.deleteConnection(device.id);
              await ref.read(alertCenterProvider.notifier).forgetDevice(device.id);
            }
          },
        ),
      ],
    );
  }
}

class _ScanSheet extends ConsumerStatefulWidget {
  const _ScanSheet();

  @override
  ConsumerState<_ScanSheet> createState() => _ScanSheetState();
}

class _ScanSheetState extends ConsumerState<_ScanSheet> {
  late final Future<List<DiscoveredDevice>> _scan =
      ref.read(networkDiscoveryServiceProvider).discoverSSHDevices();

  @override
  Widget build(BuildContext context) {
    final saved = {for (final d in ref.watch(connectionListProvider)) '${d.host}:${d.port}'};

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.7,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Insets.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Insets.sm),
                child: Text('Devices on this network', style: context.tt.titleLarge),
              ),
              const Gap(Insets.md),
              Expanded(
                child: FutureBuilder<List<DiscoveredDevice>>(
                  future: _scan,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData && !snapshot.hasError) {
                      return const LoadingState(message: 'Scanning your network for SSH devices…');
                    }
                    final found = snapshot.data ?? const <DiscoveredDevice>[];
                    if (found.isEmpty) {
                      return const EmptyState(
                        icon: Icons.wifi_find,
                        title: 'Nothing found',
                        message: 'Make sure this phone is on the same Wi-Fi as your Pi and SSH is enabled.',
                      );
                    }
                    return ListView(
                      children: [
                        for (final d in found)
                          ActionTile(
                            icon: Icons.developer_board,
                            title: d.name,
                            subtitle: '${d.host}:${d.port}${d.type == null ? '' : ' · ${d.type}'}',
                            trailing: saved.contains('${d.host}:${d.port}')
                                ? const StatusPill('Saved', tone: Tone.success)
                                : const Icon(Icons.add),
                            onTap: () => Navigator.pop(context, d),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

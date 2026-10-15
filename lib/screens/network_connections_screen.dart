import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../generated/pi_control.pb.dart';
import '../providers/app_providers.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../ui/ui.dart';

final _connectionsProvider = FutureProvider.autoDispose<List<NetworkConnection>>((ref) async {
  ref.watch(grpcSessionProvider);
  final seconds = ref.watch(settingsProvider.select((s) => s.refreshSeconds)).clamp(2, 60);
  final timer = Timer(Duration(seconds: seconds), ref.invalidateSelf);
  ref.onDispose(timer.cancel);
  return (await ref.read(grpcServiceProvider).getNetworkConnections()).connections;
});

enum _View { listening, connections }

enum _Proto { all, tcp, udp }

bool _isListening(NetworkConnection c) =>
    c.status == 'LISTEN' || (c.protocol.toLowerCase().startsWith('udp') && c.remotePort == 0);

/// Where a listening socket can be reached from
(String, Tone) _exposure(String address) {
  if (address.startsWith('127.') || address == '::1' || address == 'localhost') return ('this device only', Tone.success);
  if (address == '0.0.0.0' || address == '::' || address == '*' || address.isEmpty) return ('all networks', Tone.warning);
  return ('$address only', Tone.info);
}

String _wellKnown(int port) => switch (port) {
  22 => 'SSH',
  53 => 'DNS',
  80 => 'HTTP',
  443 => 'HTTPS',
  1883 => 'MQTT',
  3000 => 'web app',
  3306 => 'MySQL',
  5432 => 'PostgreSQL',
  5900 => 'VNC',
  6379 => 'Redis',
  8080 => 'HTTP alt',
  8123 => 'Home Assistant',
  27017 => 'MongoDB',
  50051 => 'Pi Control agent',
  _ => '',
};

/// Open ports and live connections
class NetworkConnectionsScreen extends ConsumerStatefulWidget {
  const NetworkConnectionsScreen({super.key});

  @override
  ConsumerState<NetworkConnectionsScreen> createState() => _NetworkConnectionsScreenState();
}

class _NetworkConnectionsScreenState extends ConsumerState<NetworkConnectionsScreen> {
  _View _view = _View.listening;
  _Proto _proto = _Proto.all;
  String _query = '';

  bool _match(NetworkConnection c) {
    final p = c.protocol.toLowerCase();
    if (_proto == _Proto.tcp && !p.startsWith('tcp')) return false;
    if (_proto == _Proto.udp && !p.startsWith('udp')) return false;
    final q = _query.toLowerCase();
    if (q.isEmpty) return true;
    return '${c.localPort}' == q ||
        '${c.remotePort}' == q ||
        c.processName.toLowerCase().contains(q) ||
        c.remoteAddress.contains(q) ||
        c.localAddress.contains(q) ||
        _wellKnown(c.localPort).toLowerCase().contains(q);
  }

  void _details(NetworkConnection c) {
    final listening = _isListening(c);
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Insets.xl, 0, Insets.xl, Insets.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                listening ? 'Port ${c.localPort}/${c.protocol.toLowerCase()}' : '${c.remoteAddress}:${c.remotePort}',
                style: sheet.tt.titleLarge,
              ),
              const Gap(Insets.md),
              InfoRow('Protocol', c.protocol),
              InfoRow('State', c.status.isEmpty ? '—' : c.status),
              InfoRow('Local', '${c.localAddress}:${c.localPort}', mono: true),
              if (!listening) InfoRow('Remote', '${c.remoteAddress}:${c.remotePort}', mono: true),
              InfoRow('Process', c.pid > 0 ? '${c.processName.isEmpty ? '?' : c.processName} (PID ${c.pid})' : 'unknown'),
              if (_wellKnown(c.localPort).isNotEmpty) InfoRow('Usually', _wellKnown(c.localPort)),
              const Gap(Insets.md),
              OutlinedButton.icon(
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(text: listening ? '${c.localAddress}:${c.localPort}' : '${c.remoteAddress}:${c.remotePort}'),
                  );
                  Navigator.pop(sheet);
                  showToast(context, 'Address copied');
                },
                icon: const Icon(Icons.copy),
                label: const Text('Copy address'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_connectionsProvider);
    final all = async.valueOrNull ?? const <NetworkConnection>[];
    final listening = all.where(_isListening).toList();
    final active = all.where((c) => !_isListening(c)).toList();
    final established = active.where((c) => c.status == 'ESTABLISHED').length;

    return PageScaffold(
      title: 'Network connections',
      subtitle: all.isEmpty ? null : '${listening.length} listening · $established established',
      actions: [
        IconButton(
          tooltip: 'Refresh',
          icon: const Icon(Icons.refresh),
          onPressed: () => ref.invalidate(_connectionsProvider),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(170),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Insets.page),
              child: SegmentedButton<_View>(
                segments: [
                  ButtonSegment(
                    value: _View.listening,
                    icon: const Icon(Icons.sensors),
                    label: Text('Listening · ${listening.length}'),
                  ),
                  ButtonSegment(
                    value: _View.connections,
                    icon: const Icon(Icons.swap_horiz),
                    label: Text('Connections · ${active.length}'),
                  ),
                ],
                selected: {_view},
                onSelectionChanged: (v) => setState(() => _view = v.first),
              ),
            ),
            SearchFilterBar<_Proto>(
              hint: 'Search port, process or address',
              onSearch: (v) => setState(() => _query = v),
              selected: _proto,
              onFilter: (p) => setState(() => _proto = p),
              filters: const [
                FilterOption(_Proto.all, 'All'),
                FilterOption(_Proto.tcp, 'TCP'),
                FilterOption(_Proto.udp, 'UDP'),
              ],
            ),
          ],
        ),
      ),
      body: AsyncView(
        value: async,
        onRetry: () => ref.invalidate(_connectionsProvider),
        loadingMessage: 'Reading sockets…',
        data: (_) => _view == _View.listening ? _listening(listening) : _connections(active),
      ),
    );
  }

  Widget _listening(List<NetworkConnection> list) {
    // One row per port and protocol (IPv4 and IPv6 sockets of the same service)
    final byPort = <String, List<NetworkConnection>>{};
    for (final c in list.where(_match)) {
      byPort.putIfAbsent('${c.protocol.toLowerCase().replaceAll('6', '')}:${c.localPort}', () => []).add(c);
    }
    final keys = byPort.keys.toList()
      ..sort((a, b) => byPort[a]!.first.localPort.compareTo(byPort[b]!.first.localPort));
    if (keys.isEmpty) return const EmptyState(icon: Icons.sensors_off, title: 'No listening ports match');

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(_connectionsProvider),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(Insets.page, Insets.xs, Insets.page, 96),
        itemCount: keys.length,
        itemBuilder: (context, i) {
          final group = byPort[keys[i]]!;
          final c = group.first;
          // The widest exposure of the group counts
          final exposures = group.map((g) => _exposure(g.localAddress)).toList();
          final exposure = exposures.firstWhere((e) => e.$2 == Tone.warning, orElse: () => exposures.first);
          final known = _wellKnown(c.localPort);
          return Padding(
            padding: const EdgeInsets.only(bottom: Insets.xs),
            child: Material(
              color: context.cs.surfaceContainer,
              borderRadius: Radii.mdAll,
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                onTap: () => _details(c),
                leading: SizedBox(
                  width: 64,
                  child: Text(
                    '${c.localPort}',
                    style: AppTheme.mono(size: 16, weight: FontWeight.w600, color: context.cs.primary),
                  ),
                ),
                title: Text(
                  c.processName.isNotEmpty ? c.processName : (known.isNotEmpty ? known : 'unknown process'),
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  [c.protocol.toUpperCase().replaceAll('6', ''), if (known.isNotEmpty && c.processName.isNotEmpty) known]
                      .join(' · '),
                ),
                trailing: StatusPill(exposure.$1, tone: exposure.$2),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _connections(List<NetworkConnection> list) {
    final shown = list.where(_match).toList()
      ..sort((a, b) {
        if ((a.status == 'ESTABLISHED') != (b.status == 'ESTABLISHED')) return a.status == 'ESTABLISHED' ? -1 : 1;
        return a.remoteAddress.compareTo(b.remoteAddress);
      });
    if (shown.isEmpty) return const EmptyState(icon: Icons.swap_horiz, title: 'No connections match');
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(_connectionsProvider),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(Insets.page, Insets.xs, Insets.page, 96),
        itemCount: shown.length,
        itemBuilder: (context, i) {
          final c = shown[i];
          final established = c.status == 'ESTABLISHED';
          return Padding(
            padding: const EdgeInsets.only(bottom: Insets.xs),
            child: Material(
              color: context.cs.surfaceContainer,
              borderRadius: Radii.mdAll,
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                onTap: () => _details(c),
                leading: Icon(
                  established ? Icons.link : Icons.hourglass_bottom,
                  color: established ? context.ac.success : context.cs.onSurfaceVariant,
                ),
                title: Text('${c.remoteAddress}:${c.remotePort}', style: AppTheme.mono(size: 13.5)),
                subtitle: Text(
                  '${c.processName.isEmpty ? '?' : c.processName} · local port ${c.localPort} · ${c.protocol.toUpperCase()}',
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: StatusPill(
                  c.status.isEmpty ? '—' : c.status.toLowerCase().replaceAll('_', ' '),
                  tone: established ? Tone.success : Tone.neutral,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

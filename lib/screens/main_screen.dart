import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../providers/app_providers.dart';
import '../providers/file_providers.dart';
import '../providers/settings_provider.dart';
import '../services/connect_flow.dart';
import '../services/session_actions.dart';
import '../services/ssh_service.dart' as ssh;
import '../ui/ui.dart';
import 'dashboard_screen.dart';
import 'files_screen.dart';
import 'settings/settings_screen.dart';
import 'settings/update_flow.dart';
import 'terminal_screen.dart';
import 'tools/tools_screen.dart';

class _Destination {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _Destination(this.icon, this.selectedIcon, this.label);
}

const _destinations = [
  _Destination(Icons.space_dashboard_outlined, Icons.space_dashboard, 'Home'),
  _Destination(Icons.grid_view_outlined, Icons.grid_view_rounded, 'Tools'),
  _Destination(Icons.folder_outlined, Icons.folder, 'Files'),
  _Destination(Icons.terminal_outlined, Icons.terminal, 'Terminal'),
  _Destination(Icons.settings_outlined, Icons.settings, 'Settings'),
];

/// The app shell after connecting: bottom navigation on phones, a side rail
/// on tablets and desktops
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> with WidgetsBindingObserver {
  StreamSubscription<ssh.ConnectionState>? _sshState;
  bool _resuming = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) checkForAppUpdateOnStart(context);
    });
    // The device dropped the connection while the app was open
    _sshState = ref.read(sshServiceProvider).connectionState.listen((state) {
      if (state == ssh.ConnectionState.error) _connectionLost();
    });
  }

  @override
  void dispose() {
    _sshState?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state != AppLifecycleState.resumed) return;
    final service = ref.read(sshServiceProvider);
    if (ref.read(currentConnectionProvider) != null && service.currentState != ssh.ConnectionState.connected) {
      _connectionLost();
    }
  }

  /// Reconnects on its own when the setting allows it, otherwise offers it
  Future<void> _connectionLost() async {
    if (_resuming || !mounted || ref.read(currentConnectionProvider) == null) return;
    if (ref.read(settingsProvider).autoReconnect) {
      await _resume(quiet: true);
    } else {
      _offerReconnect();
    }
  }

  void _offerReconnect() {
    if (!mounted) return;
    showToast(
      context,
      'Connection to ${ref.read(currentConnectionProvider)?.name ?? 'the device'} lost',
      tone: Tone.danger,
      actionLabel: 'Reconnect',
      duration: const Duration(seconds: 30),
      onAction: () => _resume(quiet: false),
    );
  }

  Future<void> _resume({required bool quiet}) async {
    if (_resuming) return;
    _resuming = true;
    try {
      // A few tries: the network may still be coming back after sleep
      for (var attempt = 0; attempt < (quiet ? 3 : 1); attempt++) {
        try {
          if (attempt > 0) await Future<void>.delayed(Duration(seconds: 2 * attempt));
          await resumeSession(ref);
          if (mounted && !quiet) showToast(context, 'Reconnected', tone: Tone.success);
          return;
        } catch (e) {
          debugPrint('Reconnect attempt ${attempt + 1} failed: $e');
        }
      }
      _offerReconnect();
    } finally {
      _resuming = false;
    }
  }

  void _select(int index) => ref.read(currentScreenProvider.notifier).setScreen(index);

  /// Back: previous folder in Files, then the Home tab, then leave the device
  void _back() {
    final index = ref.read(currentScreenProvider);
    if (index == 2) {
      final history = ref.read(navigationHistoryProvider);
      if (history.isNotEmpty) {
        ref.read(currentDirectoryProvider.notifier).state = history.last;
        ref.read(navigationHistoryProvider.notifier).state = history.sublist(0, history.length - 1);
        ref.read(selectedFilesProvider.notifier).state = {};
        return;
      }
    }
    if (index != 0) {
      _select(0);
      return;
    }
    disconnectAndLeave(context, ref);
  }

  Widget _withBack(Widget child) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) _back();
    },
    child: child,
  );

  @override
  Widget build(BuildContext context) {
    final index = ref.watch(currentScreenProvider).clamp(0, _destinations.length - 1);

    final pages = IndexedStack(
      index: index,
      children: const [DashboardScreen(), ToolsScreen(), FilesScreen(), TerminalScreen(), SettingsScreen(asTab: true)],
    );

    if (!context.isMediumUp) {
      return _withBack(
        Scaffold(
          body: pages,
          bottomNavigationBar: NavigationBar(
            selectedIndex: index,
            onDestinationSelected: _select,
            destinations: [
              for (final d in _destinations)
                NavigationDestination(icon: Icon(d.icon), selectedIcon: Icon(d.selectedIcon), label: d.label),
            ],
          ),
        ),
      );
    }

    final connection = ref.watch(currentConnectionProvider);
    final extended = context.isExpanded;

    return _withBack(
      Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: index,
              onDestinationSelected: _select,
              extended: extended,
              minExtendedWidth: 220,
              labelType: extended ? NavigationRailLabelType.none : NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: Insets.md),
                child: extended
                    ? SizedBox(
                        width: 188,
                        child: Row(
                          children: [
                            const IconBadge(Icons.developer_board, size: 40),
                            const Gap(Insets.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    connection?.name ?? 'Pi Control',
                                    style: context.tt.titleSmall,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    connection?.host ?? '',
                                    style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : const IconBadge(Icons.developer_board, size: 40),
              ),
              destinations: [
                for (final d in _destinations)
                  NavigationRailDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: Text(d.label),
                  ),
              ],
            ),
            Expanded(child: pages),
          ],
        ),
      ),
    );
  }
}

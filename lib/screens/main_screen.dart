import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';
import '../providers/file_providers.dart';
import '../services/ssh_service.dart' as ssh;
import 'dashboard_screen.dart';
import 'files_screen.dart';
import 'terminal_screen.dart';
import 'settings_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        // App came to foreground
        _checkAndReconnect();
        break;
      case AppLifecycleState.paused:
        // App went to background
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  Future<void> _checkAndReconnect() async {
    final sshService = ref.read(sshServiceProvider);

    // If we have a connection but it's in error state, try to reconnect
    if (sshService.currentConnection != null &&
        sshService.currentState != ssh.ConnectionState.connected) {
      try {
        await sshService.reconnect();

        // Refresh file list after reconnection
        ref.invalidate(fileListProvider);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Connection lost. Please reconnect.'),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'Reconnect',
                textColor: Colors.white,
                onPressed: () async {
                  try {
                    await sshService.reconnect();
                    ref.invalidate(fileListProvider);
                  } catch (e) {
                    debugPrint('Manual reconnection failed: $e');
                  }
                },
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentScreen = ref.watch(currentScreenProvider);

    return Scaffold(
      body: IndexedStack(
        index: currentScreen,
        children: const [
          DashboardScreen(),
          FilesScreen(),
          TerminalScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentScreen,
        onDestinationSelected: (index) {
          ref.read(currentScreenProvider.notifier).setScreen(index);
        },
        backgroundColor: AppTheme.glassLight,
        indicatorColor: AppTheme.primaryIndigo,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder),
            label: 'Files',
          ),
          NavigationDestination(
            icon: Icon(Icons.terminal),
            selectedIcon: Icon(Icons.terminal),
            label: 'Terminal',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

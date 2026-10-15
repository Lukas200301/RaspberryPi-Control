import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'models/app_settings.dart';
import 'providers/app_providers.dart';
import 'providers/settings_provider.dart';
import 'screens/security/lock_screen.dart';
import 'services/alert_center.dart';
import 'services/alert_notifications.dart';
import 'services/alert_store.dart';
import 'services/app_lock.dart';
import 'services/background_monitor.dart';
import 'services/storage_service.dart';
import 'screens/devices/devices_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage
  final storage = StorageService();
  await storage.init();

  // App lock: decide before the first frame so nothing shows unlocked
  final saved = GetStorage().read('app_settings_v2');
  final lockEnabled = saved is Map && saved['appLock'] == true;
  AppLockController.startLocked = await appLockReady(lockEnabled);

  // Alerts: rules and history are needed for the first frame
  AlertCenter.preloaded = await AlertStore.read();
  if (AlertCenter.preloaded.rules.enabled) {
    await AlertNotifications.init();
    // Restart background monitoring if the system stopped it
    BackgroundMonitor.apply(AlertCenter.preloaded.rules);
  }

  runApp(const ProviderScope(child: RaspberryPiControlApp()));
}

class RaspberryPiControlApp extends ConsumerWidget {
  const RaspberryPiControlApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    // Keeps the alert monitor running for the whole session
    ref.listen(alertCenterProvider, (_, _) {});
    // Keeps the connection alive while the app is in the background
    ref.watch(sessionKeepAliveProvider);

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        final useDynamic = settings.colorSource == ColorSource.dynamic;
        return MaterialApp(
          title: 'Raspberry Pi Control',
          navigatorKey: appNavigatorKey,
          debugShowCheckedModeBanner: false,
          themeMode: settings.themeMode,
          theme: AppTheme.build(
            Brightness.light,
            settings,
            dynamicScheme: useDynamic ? lightDynamic?.harmonized() : null,
          ),
          darkTheme: AppTheme.build(
            Brightness.dark,
            settings,
            dynamicScheme: useDynamic ? darkDynamic?.harmonized() : null,
          ),
          builder: (context, child) {
            final media = MediaQuery.of(context);
            return MediaQuery(
              data: media.copyWith(
                textScaler: TextScaler.linear(
                  media.textScaler.scale(1) * settings.textScale,
                ),
                disableAnimations:
                    media.disableAnimations || !settings.animations,
              ),
              child: AppLockGate(lockScreen: (_) => const LockScreen(), child: child!),
            );
          },
          home: const DevicesScreen(),
        );
      },
    );
  }
}

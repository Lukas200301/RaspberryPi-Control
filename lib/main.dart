import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io' show Platform;
import 'package:window_manager/window_manager.dart';
import 'core/bindings/initial_binding.dart';
import 'core/theme/app_theme.dart';
import 'core/services/storage_service.dart';
import 'routes/app_routes.dart';
import 'routes/app_pages.dart';

/// RaspberryPi Control v3.0
/// Modern glassmorphism UI with GetX state management
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize StorageService first (required by window manager and other services)
  final storage = StorageService();
  await storage.init();
  Get.put(storage, permanent: true);

  // Initialize desktop window manager
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await _initializeDesktopWindow();
  }

  runApp(const RaspberryPiControlApp());
}

/// Initialize desktop window with saved position/size
Future<void> _initializeDesktopWindow() async {
  await windowManager.ensureInitialized();

  // Get the already initialized storage service
  final storage = Get.find<StorageService>();

  final left = storage.windowLeft;
  final top = storage.windowTop;
  final width = storage.windowWidth;
  final height = storage.windowHeight;

  final windowOptions = WindowOptions(
    size: width != null && height != null
        ? Size(width, height)
        : const Size(1000, 800),
    center: (left == null || top == null),
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();

    if (left != null && top != null) {
      await windowManager.setPosition(Offset(left, top));
    }

    await windowManager.focus();
  });

  // Save window position on close
  windowManager.addListener(_DesktopWindowListener());
}

/// Desktop window listener to save position/size
class _DesktopWindowListener extends WindowListener {
  @override
  void onWindowMoved() {
    _saveWindowBounds();
  }

  @override
  void onWindowResized() {
    _saveWindowBounds();
  }

  Future<void> _saveWindowBounds() async {
    final position = await windowManager.getPosition();
    final size = await windowManager.getSize();
    final storage = Get.find<StorageService>();

    await storage.setWindowBounds(
      position.dx,
      position.dy,
      size.width,
      size.height,
    );
  }
}

/// Main App Widget
class RaspberryPiControlApp extends StatelessWidget {
  const RaspberryPiControlApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Raspberry Pi Control',
      debugShowCheckedModeBanner: false,

      // Themes
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Will be managed by ThemeController

      // GetX Configuration
      initialBinding: InitialBinding(),
      initialRoute: AppRoutes.home,
      getPages: AppPages.pages,

      // Transitions
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),

      // Disable default route transition animation on first load
      navigatorObservers: [],
    );
  }
}

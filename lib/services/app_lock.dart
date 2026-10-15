import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import '../providers/settings_provider.dart';
import 'secure_store.dart';

/// The app's root navigator, so the lock screen can cover every page
final appNavigatorKey = GlobalKey<NavigatorState>();

/// Locks the app at start and after it was in the background for longer than
/// the configured timeout. State: true while locked.
final appLockProvider = NotifierProvider<AppLockController, bool>(AppLockController.new);

class AppLockController extends Notifier<bool> {
  /// Decided in main(): lock enabled and a PIN exists
  static bool startLocked = false;

  AppLifecycleListener? _lifecycle;
  DateTime? _hiddenSince;
  int _suspended = 0;

  @override
  bool build() {
    _lifecycle = AppLifecycleListener(onHide: _onHide, onShow: _onShow);
    ref.onDispose(() => _lifecycle?.dispose());
    return startLocked;
  }

  bool get _enabled => ref.read(settingsProvider).appLock;

  void _onHide() {
    if (!state && _suspended == 0) _hiddenSince ??= DateTime.now();
  }

  void _onShow() {
    final since = _hiddenSince;
    _hiddenSince = null;
    if (since == null || state || !_enabled || _suspended > 0) return;
    final timeout = Duration(seconds: ref.read(settingsProvider).appLockTimeoutSeconds);
    if (DateTime.now().difference(since) >= timeout) lock();
  }

  void lock() {
    if (_enabled) state = true;
  }

  void unlock() => state = false;

  /// Runs [action] (file picker, share sheet, installer) without locking when
  /// the app comes back from it
  Future<T> withoutLocking<T>(Future<T> Function() action) async {
    _suspended++;
    try {
      return await action();
    } finally {
      // The resume event arrives right after the other screen closes
      Future.delayed(const Duration(milliseconds: 800), () {
        _suspended--;
        _hiddenSince = null;
      });
    }
  }
}

/// Fingerprint / face unlock
class Biometrics {
  static final _auth = LocalAuthentication();

  static Future<bool> available() async {
    try {
      return await _auth.isDeviceSupported() && (await _auth.getAvailableBiometrics()).isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(localizedReason: reason, biometricOnly: true, persistAcrossBackgrounding: true);
    } catch (e) {
      debugPrint('Biometric unlock failed: $e');
      return false;
    }
  }
}

/// Shows the lock screen above everything while [appLockProvider] is true
class AppLockGate extends ConsumerStatefulWidget {
  final Widget child;
  final WidgetBuilder lockScreen;

  const AppLockGate({super.key, required this.child, required this.lockScreen});

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate> {
  Route<void>? _route;

  @override
  void initState() {
    super.initState();
    if (ref.read(appLockProvider)) WidgetsBinding.instance.addPostFrameCallback((_) => _show());
  }

  void _show() {
    final nav = appNavigatorKey.currentState;
    if (nav == null || _route != null) {
      if (nav == null) WidgetsBinding.instance.addPostFrameCallback((_) => _show());
      return;
    }
    final route = PageRouteBuilder<void>(
      opaque: true,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (context, _, _) => widget.lockScreen(context),
    );
    _route = route;
    nav.push(route).whenComplete(() {
      if (_route == route) _route = null;
    });
    setState(() {});
  }

  void _hide() {
    final route = _route;
    if (route == null) return;
    _route = null;
    if (route.isActive) appNavigatorKey.currentState?.removeRoute(route);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(appLockProvider, (_, locked) => locked ? _show() : _hide());
    final locked = ref.watch(appLockProvider);
    return Stack(
      children: [
        widget.child,
        // Covers the app until the lock route is on screen (first frame)
        if (locked && _route == null) Positioned.fill(child: ColoredBox(color: Theme.of(context).colorScheme.surface)),
      ],
    );
  }
}

/// Whether the lock can be used at all: on and a PIN set
Future<bool> appLockReady(bool enabled) async => enabled && await SecureStore.hasPin();

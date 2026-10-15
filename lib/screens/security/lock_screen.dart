import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../providers/settings_provider.dart';
import '../../services/app_lock.dart';
import '../../services/secure_store.dart';
import '../../ui/ui.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  static const _maxLength = 8;
  static const _minLength = 4;

  // Kept across lock screens so closing the app does not reset the wait
  static int _failures = 0;
  static DateTime? _blockedUntil;

  String _pin = '';
  String? _error;
  bool _checking = false;
  bool _biometrics = false;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _initBiometrics();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_blockedUntil != null && mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _initBiometrics() async {
    if (!ref.read(settingsProvider).appLockBiometrics) return;
    final available = await Biometrics.available();
    if (!mounted) return;
    setState(() => _biometrics = available);
    if (available) _useBiometrics();
  }

  Future<void> _useBiometrics() async {
    final ok = await ref
        .read(appLockProvider.notifier)
        .withoutLocking(() => Biometrics.authenticate('Unlock Raspberry Pi Control'));
    if (ok && mounted) _unlock();
  }

  void _unlock() {
    _failures = 0;
    _blockedUntil = null;
    ref.read(appLockProvider.notifier).unlock();
  }

  int get _waitSeconds {
    final until = _blockedUntil;
    if (until == null) return 0;
    final s = until.difference(DateTime.now()).inSeconds;
    if (s <= 0) {
      _blockedUntil = null;
      return 0;
    }
    return s + 1;
  }

  void _type(String digit) {
    if (_checking || _waitSeconds > 0 || _pin.length >= _maxLength) return;
    HapticFeedback.selectionClick();
    setState(() {
      _pin += digit;
      _error = null;
    });
  }

  void _backspace() {
    if (_pin.isEmpty || _checking) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _submit() async {
    if (_pin.length < _minLength || _checking || _waitSeconds > 0) return;
    setState(() => _checking = true);
    final ok = await SecureStore.verifyPin(_pin);
    if (!mounted) return;
    if (ok) {
      _unlock();
      return;
    }
    HapticFeedback.heavyImpact();
    _failures++;
    // After 5 wrong PINs, wait 30 s, doubling each further miss
    if (_failures >= 5) {
      _blockedUntil = DateTime.now().add(Duration(seconds: 30 * (1 << (_failures - 5).clamp(0, 6))));
    }
    setState(() {
      _checking = false;
      _pin = '';
      _error = 'Wrong PIN';
    });
  }

  @override
  Widget build(BuildContext context) {
    final wait = _waitSeconds;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return PopScope(
      canPop: false,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        // No app bar here, so set the status bar icons ourselves
        value: (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark).copyWith(
          statusBarColor: Colors.transparent,
        ),
        child: Scaffold(
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(Insets.xl),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const IconBadge(Icons.lock_outline, size: 64),
                      const Gap(Insets.lg),
                      Text('Raspberry Pi Control is locked', style: context.tt.titleLarge, textAlign: TextAlign.center),
                      const Gap(Insets.xs),
                      Text(
                        wait > 0
                            ? 'Too many wrong PINs. Try again in $wait s.'
                            : _error ?? 'Enter your PIN${_biometrics ? ' or use your fingerprint' : ''}',
                        style: context.tt.bodyMedium?.copyWith(
                          color: _error != null || wait > 0 ? context.cs.error : context.cs.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Gap(Insets.xl),
                      SizedBox(
                        height: 20,
                        child: _checking
                            ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  for (var i = 0; i < (_pin.length < _minLength ? _minLength : _pin.length); i++)
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 120),
                                      margin: const EdgeInsets.symmetric(horizontal: 6),
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: i < _pin.length ? context.cs.primary : Colors.transparent,
                                        border: Border.all(color: context.cs.outline, width: 1.5),
                                      ),
                                    ),
                                ],
                              ),
                      ),
                      const Gap(Insets.xl),
                      _Keypad(
                        onDigit: _type,
                        onBackspace: _backspace,
                        onSubmit: _pin.length >= _minLength ? _submit : null,
                        onBiometrics: _biometrics ? _useBiometrics : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback? onSubmit;
  final VoidCallback? onBiometrics;

  const _Keypad({required this.onDigit, required this.onBackspace, this.onSubmit, this.onBiometrics});

  @override
  Widget build(BuildContext context) {
    Widget key(Widget child, VoidCallback? onTap, {String? label, bool filled = false}) => Padding(
      padding: const EdgeInsets.all(Insets.xs),
      child: SizedBox.square(
        dimension: 72,
        child: Semantics(
          button: true,
          label: label,
          child: Material(
            color: filled ? context.cs.primaryContainer : context.cs.surfaceContainerHigh,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );

    Widget digit(String d) => key(Text(d, style: context.tt.headlineSmall), () => onDigit(d), label: d);

    return Column(
      children: [
        for (final row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [for (final d in row) digit(d)]),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            onBiometrics != null
                ? key(
                    Icon(Icons.fingerprint, color: context.cs.primary, size: 30),
                    onBiometrics,
                    label: 'Use fingerprint',
                  )
                : key(const Icon(Icons.backspace_outlined), onBackspace, label: 'Delete'),
            digit('0'),
            key(
              Icon(Icons.arrow_forward, color: onSubmit == null ? context.cs.outline : context.cs.onPrimaryContainer),
              onSubmit,
              label: 'Unlock',
              filled: onSubmit != null,
            ),
          ],
        ),
        if (onBiometrics != null)
          TextButton.icon(
            onPressed: onBackspace,
            icon: const Icon(Icons.backspace_outlined),
            label: const Text('Delete'),
          ),
      ],
    );
  }
}

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../providers/app_providers.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/alert_center.dart';
import '../../services/app_lock.dart';
import '../../services/backup_service.dart';
import '../../services/secure_store.dart';
import '../../ui/ui.dart';
import '../tools/tool_registry.dart';

class SecurityPage extends ConsumerStatefulWidget {
  const SecurityPage({super.key});

  @override
  ConsumerState<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends ConsumerState<SecurityPage> {
  bool _hasPin = false;
  bool _biometricsAvailable = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final hasPin = await SecureStore.hasPin();
    final bio = await Biometrics.available();
    if (mounted) {
      setState(() {
        _hasPin = hasPin;
        _biometricsAvailable = bio;
      });
    }
  }

  String get _vault => kIsWeb
      ? 'the browser'
      : Platform.isAndroid
      ? 'the Android Keystore'
      : Platform.isIOS || Platform.isMacOS
      ? 'the Keychain'
      : Platform.isWindows
      ? 'Windows Credential Manager'
      : 'the system keyring';

  // ---------------- App lock ----------------

  Future<String?> _askNewPin() async {
    final pin = await showTextPrompt(
      context,
      title: 'Choose a PIN',
      label: 'PIN',
      helper: '4 to 8 digits',
      obscure: true,
      keyboardType: TextInputType.number,
      confirmLabel: 'Next',
      validator: (v) => RegExp(r'^\d{4,8}$').hasMatch(v) ? null : 'Use 4 to 8 digits',
    );
    if (pin == null || !mounted) return null;
    final again = await showTextPrompt(
      context,
      title: 'Repeat the PIN',
      label: 'PIN',
      obscure: true,
      keyboardType: TextInputType.number,
      confirmLabel: 'Save',
      validator: (v) => v == pin ? null : 'The PINs do not match',
    );
    return again == null ? null : pin;
  }

  Future<bool> _confirmPin(String title) async {
    final pin = await showTextPrompt(
      context,
      title: title,
      label: 'Current PIN',
      obscure: true,
      keyboardType: TextInputType.number,
    );
    if (pin == null) return false;
    final ok = await SecureStore.verifyPin(pin);
    if (!ok && mounted) showToast(context, 'Wrong PIN', tone: Tone.danger);
    return ok;
  }

  Future<void> _toggleLock(bool on) async {
    final settings = ref.read(settingsProvider.notifier);
    if (on) {
      final pin = await _askNewPin();
      if (pin == null) return;
      await SecureStore.setPin(pin);
      settings.update((s) => s.copyWith(appLock: true));
      if (mounted) showToast(context, 'App lock is on', tone: Tone.success);
    } else {
      if (_hasPin && !await _confirmPin('Turn off the app lock')) return;
      await SecureStore.clearPin();
      settings.update((s) => s.copyWith(appLock: false));
    }
    await _load();
  }

  Future<void> _changePin() async {
    if (!await _confirmPin('Change PIN')) return;
    final pin = await _askNewPin();
    if (pin == null) return;
    await SecureStore.setPin(pin);
    if (mounted) showToast(context, 'PIN changed', tone: Tone.success);
  }

  // ---------------- Backup ----------------

  Future<void> _export() async {
    final includeSecrets = await showChoiceSheet<bool>(
      context,
      title: 'What should the backup contain?',
      value: true,
      choices: const [
        (true, 'Devices with passwords and keys, settings, alert rules'),
        (false, 'Devices without passwords and keys, settings, alert rules'),
      ],
    );
    if (includeSecrets == null || !mounted) return;
    final password = await showTextPrompt(
      context,
      title: 'Protect the backup',
      label: 'Backup password',
      helper: 'At least 8 characters. Without it the backup cannot be opened.',
      obscure: true,
      confirmLabel: 'Next',
      validator: (v) => v.length >= 8 ? null : 'Use at least 8 characters',
    );
    if (password == null || !mounted) return;
    final again = await showTextPrompt(
      context,
      title: 'Repeat the password',
      label: 'Backup password',
      obscure: true,
      confirmLabel: 'Create backup',
      validator: (v) => v == password ? null : 'The passwords do not match',
    );
    if (again == null || !mounted) return;

    setState(() => _busy = true);
    try {
      final devices = ref.read(connectionListProvider);
      final info = await PackageInfo.fromPlatform();
      final contents = BackupContents(
        created: DateTime.now(),
        appVersion: info.version,
        includesSecrets: includeSecrets,
        devices: includeSecrets
            ? devices
            : [for (final d in devices) d.copyWith(password: '', privateKey: '', passphrase: '')],
        storage: BackupService.collectStorage(),
        alertRules: ref.read(alertCenterProvider).rules,
      );
      final bytes = await BackupService.encrypt(contents, password);
      final saved = await ref.read(appLockProvider.notifier).withoutLocking(
        () => FilePicker.saveFile(
          fileName: BackupService.suggestedFileName(),
          bytes: bytes,
          dialogTitle: 'Save backup',
        ),
      );
      if (mounted && saved != null) {
        showToast(context, 'Backup saved: ${devices.length} devices', tone: Tone.success);
      }
    } catch (e) {
      if (mounted) showToast(context, 'Backup failed: $e', tone: Tone.danger);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    final file = await ref.read(appLockProvider.notifier).withoutLocking(
      () => FilePicker.pickFile(dialogTitle: 'Open backup'),
    );
    if (file == null || !mounted) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;

    BackupContents? backup;
    while (backup == null) {
      if (!mounted) return;
      final password = await showTextPrompt(
        context,
        title: 'Open backup',
        label: 'Backup password',
        helper: file.name,
        obscure: true,
        confirmLabel: 'Open',
      );
      if (password == null || !mounted) return;
      setState(() => _busy = true);
      try {
        backup = await BackupService.decrypt(bytes, password);
      } on BackupException catch (e) {
        if (!mounted) return;
        showToast(context, e.message, tone: Tone.danger);
        // A foreign file will not open with another password either
        if (!e.message.startsWith('Wrong password')) return;
      } finally {
        if (mounted) setState(() => _busy = false);
      }
    }
    if (!mounted) return;

    final current = ref.read(connectionListProvider);
    final known = backup.devices.where((d) => current.any((c) => c.id == d.id)).length;
    final mode = await showChoiceSheet<String>(
      context,
      title: 'Restore backup from ${DateFormat.yMMMd().add_Hm().format(backup.created)}',
      value: 'merge',
      choices: [
        (
          'merge',
          [
            if (backup.devices.length > known) 'Add ${backup.devices.length - known} new devices',
            if (known > 0) 'update $known ${known == 1 ? 'device' : 'devices'} already here',
            'restore settings',
          ].join(', ').replaceFirstMapped(RegExp(r'^\w'), (m) => m[0]!.toUpperCase()),
        ),
        ('replace', 'Replace all devices and settings'),
        ('settings', 'Only restore settings'),
      ],
    );
    if (mode == null || !mounted) return;
    if (mode == 'replace' &&
        !await showConfirmDialog(
          context,
          title: 'Replace everything?',
          message: 'Devices that are not in the backup are removed from this app.',
          confirmLabel: 'Replace',
          destructive: true,
        )) {
      return;
    }

    setState(() => _busy = true);
    try {
      await BackupService.restoreStorage(backup.storage);
      if (mode != 'settings') {
        final devices = BackupService.mergeDevices(current, backup, replace: mode == 'replace');
        await ref.read(storageServiceProvider).saveConnections(devices);
      }
      final needLogin = mode == 'settings'
          ? 0
          : backup.devices
                .where((d) => d.password.isEmpty && d.privateKey.isEmpty && !current.any((c) => c.id == d.id))
                .length;
      if (backup.alertRules != null) await ref.read(alertCenterProvider.notifier).setRules(backup.alertRules!);
      // Re-read everything that came from storage
      ref
        ..invalidate(settingsProvider)
        ..invalidate(connectionListProvider)
        ..invalidate(dashboardLayoutProvider)
        ..invalidate(pinnedToolsProvider);
      if (!mounted) return;
      showToast(
        context,
        mode == 'settings'
            ? 'Settings restored'
            : 'Restored ${backup.devices.length} devices'
                  '${needLogin > 0 ? '; enter the password of $needLogin new ${needLogin == 1 ? 'device' : 'devices'} when connecting' : ''}',
        tone: Tone.success,
      );
    } catch (e) {
      if (mounted) showToast(context, 'Restore failed: $e', tone: Tone.danger);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(settingsProvider);
    final lockOn = s.appLock && _hasPin;

    return PageScaffold(
      title: 'Security & backup',
      maxWidth: 760,
      body: Stack(
        children: [
          PageList(
            children: [
              SettingsSection(
                title: 'App lock',
                footer: 'The lock protects the app on this phone. Forgot the PIN? Clear the app data; devices are then lost unless you have a backup.',
                children: [
                  SwitchSettingTile(
                    icon: Icons.lock_outline,
                    title: 'Lock the app',
                    subtitle: 'Ask for a PIN when the app opens',
                    value: lockOn,
                    onChanged: _toggleLock,
                  ),
                  if (lockOn) ...[
                    if (_biometricsAvailable)
                      SwitchSettingTile(
                        icon: Icons.fingerprint,
                        tone: Tone.success,
                        title: 'Unlock with fingerprint or face',
                        value: s.appLockBiometrics,
                        onChanged: (v) => ref.read(settingsProvider.notifier).update((s) => s.copyWith(appLockBiometrics: v)),
                      ),
                    ChoiceSettingTile<int>(
                      icon: Icons.timer_outlined,
                      title: 'Lock after leaving the app',
                      value: s.appLockTimeoutSeconds,
                      choices: const [
                        (0, 'Immediately'),
                        (30, 'After 30 seconds'),
                        (60, 'After 1 minute'),
                        (300, 'After 5 minutes'),
                        (900, 'After 15 minutes'),
                      ],
                      onChanged: (v) =>
                          ref.read(settingsProvider.notifier).update((s) => s.copyWith(appLockTimeoutSeconds: v)),
                    ),
                    ActionTile(icon: Icons.password, title: 'Change PIN', tone: Tone.neutral, onTap: _changePin),
                    ActionTile(
                      icon: Icons.lock_clock_outlined,
                      title: 'Lock now',
                      tone: Tone.neutral,
                      onTap: () => ref.read(appLockProvider.notifier).lock(),
                    ),
                  ],
                ],
              ),
              SettingsSection(
                title: 'Saved logins',
                children: [
                  ActionTile(
                    icon: SecureStore.available ? Icons.verified_user_outlined : Icons.warning_amber_rounded,
                    tone: SecureStore.available ? Tone.success : Tone.warning,
                    title: SecureStore.available ? 'Encrypted on this device' : 'Not encrypted',
                    subtitle: SecureStore.available
                        ? 'Passwords, keys and passphrases are kept in $_vault.'
                        : 'This system has no secure storage, so passwords are kept in the app storage.',
                  ),
                ],
              ),
              SettingsSection(
                title: 'Backup',
                footer: 'Backups are encrypted with AES-256 and your password. Use them to move to a new phone '
                    'or to keep your devices safe.',
                children: [
                  ActionTile(
                    icon: Icons.upload_file_outlined,
                    title: 'Create backup',
                    subtitle: 'Devices, settings, dashboard and alert rules',
                    onTap: _busy ? null : _export,
                  ),
                  ActionTile(
                    icon: Icons.settings_backup_restore,
                    tone: Tone.info,
                    title: 'Restore backup',
                    subtitle: 'Add devices or replace everything',
                    onTap: _busy ? null : _import,
                  ),
                ],
              ),
            ],
          ),
          if (_busy)
            Positioned.fill(
              child: ColoredBox(
                color: context.cs.scrim.withValues(alpha: 0.3),
                child: const Center(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(Insets.xl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [CircularProgressIndicator(), Gap(Insets.md), Text('Working…')],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

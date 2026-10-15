import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../providers/file_providers.dart';
import '../screens/devices/devices_screen.dart';
import '../generated/pi_control.pb.dart';
import '../ui/ui.dart';
import 'admin_service.dart';

/// Ends the session with the current Pi and returns to the device list
Future<void> disconnectAndLeave(
  BuildContext context,
  WidgetRef ref, {
  bool confirm = true,
}) async {
  final name = ref.read(currentConnectionProvider)?.name ?? 'the device';
  if (confirm &&
      !await showConfirmDialog(
        context,
        title: 'Disconnect?',
        message: 'You will be disconnected from $name.',
        confirmLabel: 'Disconnect',
        icon: Icons.link_off,
      )) {
    return;
  }

  ref.read(fileTransfersProvider.notifier).clearAll();
  ref.read(currentConnectionProvider.notifier).setConnection(null);

  // Do not keep the user waiting for a slow or dead connection
  ref
      .read(connectionManagerProvider)
      .disconnect()
      .timeout(const Duration(seconds: 2), onTimeout: () {})
      .catchError((e) => debugPrint('Disconnect error: $e'));
  ref.read(currentScreenProvider.notifier).setScreen(0);

  if (context.mounted) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const DevicesScreen()),
      (_) => false,
    );
  }
}

/// Asks, then reboots or shuts down the connected device and leaves it
Future<void> confirmPower(BuildContext context, WidgetRef ref, PowerOp op) async {
  final reboot = op == PowerOp.POWER_REBOOT;
  final name = ref.read(currentConnectionProvider)?.name ?? 'the device';
  if (!await showConfirmDialog(
    context,
    title: reboot ? 'Reboot $name?' : 'Shut down $name?',
    message: reboot
        ? 'Running programs are stopped. The app reconnects when you open the device again (about a minute).'
        : 'You need physical access to switch it on again (unplug and replug the power).',
    confirmLabel: reboot ? 'Reboot' : 'Shut down',
    destructive: !reboot,
    icon: reboot ? Icons.restart_alt : Icons.power_settings_new,
  )) {
    return;
  }
  try {
    final result = await ref.read(adminServiceProvider).power(op);
    if (!context.mounted) return;
    if (result.success) {
      showToast(context, result.output, tone: Tone.success);
      await disconnectAndLeave(context, ref, confirm: false);
    } else {
      showToast(context, result.output, tone: Tone.danger);
    }
  } catch (e) {
    if (context.mounted) showToast(context, describeError(e), tone: Tone.danger);
  }
}

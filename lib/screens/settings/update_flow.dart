import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import '../../services/update_service.dart';
import '../../ui/ui.dart';

bool _checkedOnStart = false;

/// Checks GitHub for a newer app version once per app start
Future<void> checkForAppUpdateOnStart(BuildContext context) async {
  if (_checkedOnStart || !Platform.isAndroid) return;
  _checkedOnStart = true;
  await Future.delayed(const Duration(seconds: 2));
  final info = await UpdateService().checkForUpdates();
  if (info != null && info.updateAvailable && context.mounted) {
    await showUpdateDialog(context, info);
  }
}

/// Checks for an update and reports the result
Future<void> checkForAppUpdate(BuildContext context) async {
  final info = await UpdateService().checkForUpdates();
  if (!context.mounted) return;
  if (info == null) {
    showToast(context, 'Could not check for updates', tone: Tone.danger);
  } else if (info.updateAvailable) {
    await showUpdateDialog(context, info);
  } else {
    showToast(context, 'You are on the latest version (${info.currentVersion})', tone: Tone.success);
  }
}

Future<void> showUpdateDialog(BuildContext context, UpdateInfo info) {
  return showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon: Icon(Icons.system_update, color: context.cs.primary),
      title: Text('Version ${info.latestVersion} is available'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 420, maxWidth: 520),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You have ${info.currentVersion}.',
                style: dialogContext.tt.bodyMedium?.copyWith(
                  color: dialogContext.cs.onSurfaceVariant,
                ),
              ),
              for (final note in info.releaseNotes) ...[
                const Gap(Insets.lg),
                Row(
                  children: [
                    StatusPill('v${note.version}', tone: Tone.primary),
                    const Gap(Insets.sm),
                    Expanded(
                      child: Text(note.title, style: dialogContext.tt.titleSmall),
                    ),
                  ],
                ),
                const Gap(Insets.xs),
                Text(
                  note.body,
                  style: dialogContext.tt.bodySmall?.copyWith(
                    color: dialogContext.cs.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Later'),
        ),
        FilledButton.icon(
          onPressed: () {
            Navigator.pop(dialogContext);
            downloadAndInstallUpdate(context, info);
          },
          icon: const Icon(Icons.download),
          label: const Text('Update now'),
        ),
      ],
    ),
  );
}

/// Downloads the APK with a progress dialog and opens the installer
Future<void> downloadAndInstallUpdate(BuildContext context, UpdateInfo info) async {
  if (info.downloadUrl.isEmpty) {
    showToast(context, 'No download found for this release', tone: Tone.danger);
    return;
  }

  final progress = ValueNotifier<double?>(null);
  var cancelled = false;
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Downloading update'),
      content: ValueListenableBuilder<double?>(
        valueListenable: progress,
        builder: (_, value, _) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            UsageBar(value: value ?? 0),
            const Gap(Insets.md),
            Text(value == null ? 'Starting…' : '${(value * 100).toStringAsFixed(0)} %'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            cancelled = true;
            Navigator.pop(dialogContext);
          },
          child: const Text('Cancel'),
        ),
      ],
    ),
  );

  File? file;
  try {
    final response = await http.Client().send(http.Request('GET', Uri.parse(info.downloadUrl)));
    if (response.statusCode != 200) throw Exception('HTTP ${response.statusCode}');

    final dir = await getExternalStorageDirectory();
    file = File('${dir!.path}/raspberrypi_control_update.apk');
    if (await file.exists()) await file.delete();

    final sink = file.openWrite();
    final total = response.contentLength ?? 0;
    var received = 0;
    await for (final chunk in response.stream) {
      if (cancelled) break;
      sink.add(chunk);
      received += chunk.length;
      if (total > 0) progress.value = received / total;
    }
    await sink.close();
    if (cancelled) return;

    if (context.mounted) Navigator.of(context, rootNavigator: true).pop();

    final result = await OpenFilex.open(
      file.path,
      type: 'application/vnd.android.package-archive',
    );
    if (result.type != ResultType.done) {
      throw Exception('Could not open the installer: ${result.message}');
    }
    final downloaded = file;
    Future.delayed(const Duration(seconds: 30), () async {
      try {
        if (await downloaded.exists()) await downloaded.delete();
      } catch (e) {
        debugPrint('Failed to delete update APK: $e');
      }
    });
  } catch (e) {
    if (!context.mounted || cancelled) return;
    Navigator.of(context, rootNavigator: true).maybePop();
    showToast(context, 'Update failed: $e', tone: Tone.danger);
  } finally {
    progress.dispose();
  }
}

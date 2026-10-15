import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import '../generated/pi_control.pb.dart';
import '../theme/app_theme.dart';
import '../ui/ui.dart';

/// Shows the outcome of a command: a toast on success, the full output on
/// failure. Returns whether it succeeded.
bool reportCommand(BuildContext context, CommandOutput result, {required String success}) {
  if (!context.mounted) return result.success;
  if (result.success) {
    showToast(context, success, tone: Tone.success);
  } else {
    showOutputDialog(
      context,
      title: 'Something went wrong',
      command: result.command,
      output: result.output.isEmpty ? 'Exit code ${result.exitCode}' : result.output,
      isError: true,
    );
  }
  return result.success;
}

Future<void> showOutputDialog(
  BuildContext context, {
  required String title,
  String command = '',
  required String output,
  bool isError = false,
}) {
  return showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon: Icon(
        isError ? Icons.error_outline : Icons.terminal,
        color: isError ? dialogContext.cs.error : dialogContext.cs.primary,
      ),
      title: Text(title),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (command.isNotEmpty) ...[
              Text(
                '\$ $command',
                style: AppTheme.mono(size: 12, color: dialogContext.cs.onSurfaceVariant),
              ),
              const Gap(Insets.sm),
            ],
            Flexible(
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 360),
                decoration: BoxDecoration(color: dialogContext.ac.codeBackground, borderRadius: Radii.mdAll),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(Insets.md),
                  child: SelectableText(
                    output.isEmpty ? '(no output)' : output,
                    style: AppTheme.mono(size: 12, color: dialogContext.ac.codeForeground),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: output));
            showToast(dialogContext, 'Copied');
          },
          child: const Text('Copy'),
        ),
        FilledButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Close')),
      ],
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../theme/tokens.dart';
import 'cards.dart';

/// Floating message at the bottom of the screen
void showToast(
  BuildContext context,
  String message, {
  Tone tone = Tone.neutral,
  String? actionLabel,
  VoidCallback? onAction,
  Duration duration = const Duration(seconds: 4),
}) {
  if (!context.mounted) return;
  final icon = switch (tone) {
    Tone.success => Icons.check_circle,
    Tone.danger => Icons.error,
    Tone.warning => Icons.warning_amber_rounded,
    Tone.info => Icons.info,
    _ => null,
  };
  final cs = context.cs;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: duration,
        backgroundColor: tone == Tone.danger ? cs.errorContainer : null,
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 20,
                color: tone == Tone.danger ? cs.onErrorContainer : cs.inversePrimary,
              ),
              const Gap(Insets.md),
            ],
            Expanded(
              child: Text(
                message,
                style: tone == Tone.danger ? TextStyle(color: cs.onErrorContainer) : null,
              ),
            ),
          ],
        ),
        action: actionLabel == null
            ? null
            : SnackBarAction(label: actionLabel, onPressed: onAction ?? () {}),
      ),
    );
}

Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  bool destructive = false,
  IconData? icon,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      icon: icon == null
          ? null
          : Icon(icon, color: destructive ? context.cs.error : context.cs.primary),
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: destructive
              ? FilledButton.styleFrom(
                  backgroundColor: context.cs.error,
                  foregroundColor: context.cs.onError,
                )
              : null,
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

Future<String?> showTextPrompt(
  BuildContext context, {
  required String title,
  required String label,
  String hint = '',
  String initial = '',
  String? helper,
  String confirmLabel = 'OK',
  bool obscure = false,
  TextInputType keyboardType = TextInputType.text,
  List<String> suggestions = const [],
  String? Function(String)? validator,
}) {
  final controller = TextEditingController(text: initial);
  String? error;
  return showDialog<String>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        void submit() {
          final text = controller.text.trim();
          final problem = validator?.call(text);
          if (problem != null) {
            setState(() => error = problem);
            return;
          }
          Navigator.pop(context, text);
        }

        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                obscureText: obscure,
                keyboardType: keyboardType,
                decoration: InputDecoration(
                  labelText: label,
                  hintText: hint,
                  helperText: helper,
                  helperMaxLines: 3,
                  errorText: error,
                ),
                onSubmitted: (_) => submit(),
              ),
              if (suggestions.isNotEmpty) ...[
                const Gap(Insets.md),
                Wrap(
                  spacing: Insets.sm,
                  runSpacing: Insets.sm,
                  children: [
                    for (final s in suggestions)
                      ActionChip(
                        label: Text(s),
                        onPressed: () => setState(() => controller.text = s),
                      ),
                  ],
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(onPressed: submit, child: Text(confirmLabel)),
          ],
        );
      },
    ),
  );
}

/// Bottom sheet with radio choices; resolves to the picked value
Future<T?> showChoiceSheet<T>(
  BuildContext context, {
  required String title,
  required T value,
  required List<(T, String)> choices,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(Insets.xl, 0, Insets.xl, Insets.sm),
              child: Text(title, style: context.tt.titleLarge),
            ),
            Flexible(
              child: RadioGroup<T>(
                groupValue: value,
                onChanged: (v) => Navigator.pop(context, v),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    // A ListTile rather than RadioListTile, so picking the
                    // current value also confirms it
                    for (final c in choices)
                      ListTile(
                        leading: IgnorePointer(child: Radio<T>(value: c.$1)),
                        title: Text(c.$2),
                        onTap: () => Navigator.pop(context, c.$1),
                      ),
                  ],
                ),
              ),
            ),
            const Gap(Insets.sm),
          ],
        ),
      ),
    ),
  );
}

/// One entry of [showActionSheet]
class SheetAction {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final bool destructive;
  final Tone tone;

  const SheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.destructive = false,
    this.tone = Tone.primary,
  });
}

/// Bottom sheet listing actions (instead of crowded popup menus)
Future<void> showActionSheet(
  BuildContext context, {
  required String title,
  String? subtitle,
  required List<SheetAction> actions,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(Insets.xl, 0, Insets.xl, Insets.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.tt.titleLarge),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: context.tt.bodyMedium?.copyWith(color: context.cs.onSurfaceVariant),
                    ),
                ],
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: Insets.sm),
                children: [
                  for (final a in actions)
                    ActionTile(
                      icon: a.icon,
                      title: a.label,
                      subtitle: a.subtitle,
                      tone: a.tone,
                      destructive: a.destructive,
                      trailing: const SizedBox.shrink(),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        a.onTap();
                      },
                    ),
                ],
              ),
            ),
            const Gap(Insets.sm),
          ],
        ),
      ),
    ),
  );
}

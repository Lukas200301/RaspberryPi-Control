import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../models/file_item.dart';
import '../../theme/app_theme.dart';
import '../../ui/ui.dart';

/// Edits the rwx bits of [file]; returns the new mode or null
Future<int?> showPermissionsDialog(BuildContext context, FileItem file) {
  return showDialog<int>(context: context, builder: (_) => _PermissionsDialog(file: file));
}

class _PermissionsDialog extends StatefulWidget {
  final FileItem file;

  const _PermissionsDialog({required this.file});

  @override
  State<_PermissionsDialog> createState() => _PermissionsDialogState();
}

class _PermissionsDialogState extends State<_PermissionsDialog> {
  late int _mode = widget.file.permissions & 0x1FF;

  static const _who = ['Owner', 'Group', 'Others'];
  static const _what = [('Read', 4), ('Write', 2), ('Run', 1)];

  bool _has(int who, int bit) => _mode & (bit << (3 * (2 - who))) != 0;

  void _toggle(int who, int bit) => setState(() => _mode ^= bit << (3 * (2 - who)));

  String get _octal => _mode.toRadixString(8).padLeft(3, '0');

  @override
  Widget build(BuildContext context) {
    final presets = widget.file.isDirectory
        ? const [('755', 0x1ED), ('750', 0x1E8), ('700', 0x1C0), ('775', 0x1FD)]
        : const [('644', 0x1A4), ('600', 0x180), ('755', 0x1ED), ('664', 0x1B4)];
    return AlertDialog(
      title: Text('Permissions of ${widget.file.name}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Table(
              columnWidths: const {0: IntrinsicColumnWidth()},
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(
                  children: [
                    const SizedBox(),
                    for (final w in _what)
                      Center(
                        child: Text(
                          w.$1,
                          style: context.tt.labelMedium?.copyWith(color: context.cs.onSurfaceVariant),
                        ),
                      ),
                  ],
                ),
                for (var who = 0; who < 3; who++)
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: Insets.md),
                        child: Text(
                          who == 0 && widget.file.owner.isNotEmpty && widget.file.owner != 'unknown'
                              ? '${_who[who]} (${widget.file.owner})'
                              : who == 1 && widget.file.group.isNotEmpty && widget.file.group != 'unknown'
                              ? '${_who[who]} (${widget.file.group})'
                              : _who[who],
                        ),
                      ),
                      for (final w in _what)
                        Center(
                          child: Checkbox(value: _has(who, w.$2), onChanged: (_) => _toggle(who, w.$2)),
                        ),
                    ],
                  ),
              ],
            ),
            const Gap(Insets.md),
            Row(
              children: [
                Text('Mode ', style: context.tt.bodyMedium),
                Text(_octal, style: AppTheme.mono(size: 16, weight: FontWeight.w600, color: context.cs.primary)),
              ],
            ),
            const Gap(Insets.sm),
            Wrap(
              spacing: Insets.xs,
              children: [
                for (final p in presets)
                  ChoiceChip(
                    label: Text(p.$1),
                    selected: _mode == p.$2,
                    onSelected: (_) => setState(() => _mode = p.$2),
                  ),
              ],
            ),
            if (widget.file.isDirectory) ...[
              const Gap(Insets.sm),
              Text(
                'For folders, "Run" means opening the folder.',
                style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(context, _mode), child: const Text('Apply')),
      ],
    );
  }
}

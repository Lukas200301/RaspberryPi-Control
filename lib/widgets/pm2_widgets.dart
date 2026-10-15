import 'dart:async';

import 'package:flutter/material.dart';
import '../ui/ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../generated/pi_control.pb.dart';
import '../models/file_item.dart';
import '../services/pm2_service.dart';
import 'file_editor_dialog.dart';

// ==================== Formatting ====================

class Pm2Format {
  static String bytes(num bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024) return '${bytes.toInt()} B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// Uptime since a unix ms timestamp, like `pm2 ls` (12s, 5m, 3h, 2D)
  static String uptime(int sinceMs) {
    if (sinceMs <= 0) return '-';
    final d = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(sinceMs),
    );
    if (d.isNegative) return '0s';
    if (d.inSeconds < 60) return '${d.inSeconds}s';
    if (d.inMinutes < 60) return '${d.inMinutes}m';
    if (d.inHours < 24) return '${d.inHours}h ${d.inMinutes % 60}m';
    return '${d.inDays}d ${d.inHours % 24}h';
  }

  static String dateTime(int ms) {
    if (ms <= 0) return '-';
    return DateFormat(
      'yyyy-MM-dd HH:mm:ss',
    ).format(DateTime.fromMillisecondsSinceEpoch(ms));
  }

  static String cpu(double cpu) => '${cpu.toStringAsFixed(cpu < 10 ? 1 : 0)}%';
}

// ==================== Status ====================

Color pm2StatusColor(BuildContext context, String status) {
  switch (status) {
    case 'online':
      return context.ac.success;
    case 'errored':
      return Theme.of(context).colorScheme.error;
    case 'launching':
    case 'stopping':
    case 'waiting restart':
      return context.ac.warning;
    case 'one-launch-status':
      return Colors.lightBlue;
    default:
      return context.cs.onSurfaceVariant;
  }
}

class Pm2StatusBadge extends StatelessWidget {
  final String status;

  const Pm2StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = pm2StatusColor(context, status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        (status.isEmpty ? 'unknown' : status).toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class Pm2StatusDot extends StatelessWidget {
  final String status;
  final double size;

  const Pm2StatusDot({super.key, required this.status, this.size = 10});

  @override
  Widget build(BuildContext context) {
    final color = pm2StatusColor(context, status);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: status == 'online'
            ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 6)]
            : null,
      ),
    );
  }
}

// ==================== Command output ====================

/// The line of pm2 output worth showing in a snackbar: skips tables, the
/// host metrics footer of PM2 7 and blank lines.
String pm2Summary(String output) {
  final lines = output
      .split('\n')
      .map((l) => l.trim())
      .where(
        (l) =>
            l.isNotEmpty &&
            !RegExp(r'^[│├└┌┐┘┬┴┼─║╔╚═]').hasMatch(l) &&
            !l.startsWith('host metrics') &&
            !l.contains('pm2 set pm2:sysmonit'),
      )
      .toList();
  if (lines.isEmpty) return '';
  final errors = lines.where((l) => l.contains('[ERROR]')).toList();
  if (errors.isNotEmpty) return errors.last;
  return lines.last;
}

/// Shows the outcome of a pm2 command: a snackbar when it worked (with the
/// full output one tap away) and a dialog when it failed.
void showPm2Result(
  BuildContext context,
  Pm2CommandResult result, {
  String? successMessage,
}) {
  if (!context.mounted) return;
  if (result.success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(successMessage ?? pm2Summary(result.output)),
        action: result.output.isEmpty
            ? null
            : SnackBarAction(
                label: 'Output',
                onPressed: () {
                  if (!context.mounted) return;
                  showPm2OutputDialog(
                    context,
                    title: 'Output',
                    command: result.command,
                    output: result.output,
                  );
                },
              ),
      ),
    );
  } else {
    showPm2OutputDialog(
      context,
      title: 'Command failed',
      command: result.command,
      output: result.output,
      isError: true,
    );
  }
}

void showPm2Error(BuildContext context, Object error) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(Pm2Exception.from(error).message),
      backgroundColor: Theme.of(context).colorScheme.error,
    ),
  );
}

Future<void> showPm2OutputDialog(
  BuildContext context, {
  required String title,
  String command = '',
  required String output,
  bool isError = false,
}) {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.terminal,
            color: isError
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.primary,
          ),
          const Gap(8),
          Expanded(child: Text(title)),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (command.isNotEmpty) ...[
              Text(
                '\$ $command',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: context.cs.onSurfaceVariant,
                ),
              ),
              const Gap(8),
            ],
            Flexible(
              child: Pm2TextPanel(
                text: output.isEmpty ? '(no output)' : output,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: output));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Copied to clipboard')),
            );
          },
          child: const Text('Copy'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

/// Whether pm2 output contains one of its box-drawn tables
bool pm2HasTable(String text) => RegExp('[│┌└├┬┼]').hasMatch(text);

/// Wraps text unless it holds a PM2 table, which scrolls sideways instead
Widget _pm2HorizontalIfTable(bool table, Widget child) => table
    ? SingleChildScrollView(scrollDirection: Axis.horizontal, child: child)
    : SizedBox(width: double.infinity, child: child);

/// Monospace output; PM2 tables scroll sideways, everything else wraps
class Pm2TextPanel extends StatelessWidget {
  final String text;
  final double maxHeight;

  const Pm2TextPanel({super.key, required this.text, this.maxHeight = 420});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.cs.outlineVariant),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: _pm2HorizontalIfTable(
          pm2HasTable(text),
          SelectableText(
            text,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 11.5,
              color: Colors.white,
              height: 1.35,
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== Operations ====================

/// Runs a streamed PM2 operation in a bottom sheet that shows the live
/// output. Resolves to whether it succeeded.
Future<bool> runPm2Operation(
  BuildContext context,
  WidgetRef ref, {
  required String title,
  required Pm2OperationRequest request,
}) async {
  final success = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    builder: (_) => _Pm2OperationSheet(
      title: title,
      stream: ref.read(pm2ServiceProvider).runOperation(request),
    ),
  );
  if (context.mounted) {
    ref.invalidate(pm2InfoProvider);
    ref.invalidate(pm2ProcessesProvider);
  }
  return success ?? false;
}

/// Runs a control action on a process (or "all") and reports the result.
Future<bool> pm2Control(
  BuildContext context,
  WidgetRef ref,
  Pm2Action action,
  String target, {
  required String progress,
  String? success,
  bool updateEnv = false,
  String value = '',
  String actionName = '',
  String actionParam = '',
}) async {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(content: Text(progress), duration: const Duration(minutes: 1)),
  );

  try {
    final result = await ref
        .read(pm2ServiceProvider)
        .control(
          action,
          target,
          updateEnv: updateEnv,
          value: value,
          actionName: actionName,
          actionParam: actionParam,
        );
    messenger.hideCurrentSnackBar();
    if (context.mounted) {
      showPm2Result(context, result, successMessage: success);
      ref.read(pm2ProcessesProvider.notifier).refresh();
    }
    return result.success;
  } catch (e) {
    messenger.hideCurrentSnackBar();
    if (context.mounted) showPm2Error(context, e);
    return false;
  }
}

class _Pm2OperationSheet extends StatefulWidget {
  final String title;
  final Stream<Pm2OutputLine> stream;

  const _Pm2OperationSheet({required this.title, required this.stream});

  @override
  State<_Pm2OperationSheet> createState() => _Pm2OperationSheetState();
}

class _Pm2OperationSheetState extends State<_Pm2OperationSheet> {
  final List<Pm2OutputLine> _lines = [];
  final ScrollController _scroll = ScrollController();
  StreamSubscription<Pm2OutputLine>? _subscription;
  bool _done = false;
  bool _success = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _subscription = widget.stream.listen(
      (line) {
        if (!mounted) return;
        setState(() {
          if (line.done) {
            _done = true;
            _success = line.success;
          } else {
            _lines.add(line);
          }
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scroll.hasClients) {
            _scroll.jumpTo(_scroll.position.maxScrollExtent);
          }
        });
      },
      onError: (Object e) {
        if (!mounted) return;
        setState(() {
          _done = true;
          _success = false;
          _error = Pm2Exception.from(e).message;
        });
      },
      onDone: () {
        if (mounted && !_done) setState(() => _done = true);
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  /// Closing the stream makes the agent kill the running command
  Future<void> _cancel() async {
    final confirmed = await confirmPm2(
      context,
      title: 'Cancel operation?',
      message: 'The command is stopped on the Pi. It may be left half done.',
      confirmLabel: 'Stop it',
      destructive: true,
    );
    if (confirmed && mounted && !_done) Navigator.pop(context, false);
  }

  @override
  Widget build(BuildContext context) {
    final color = !_done
        ? Theme.of(context).colorScheme.primary
        : _success
        ? context.ac.success
        : Theme.of(context).colorScheme.error;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (!_done)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: color,
                      ),
                    )
                  else
                    Icon(
                      _success ? Icons.check_circle : Icons.error,
                      color: color,
                    ),
                  const Gap(12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Text(
                    !_done ? 'Running…' : (_success ? 'Done' : 'Failed'),
                    style: TextStyle(color: color, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const Gap(12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: context.cs.outlineVariant),
                  ),
                  child: SingleChildScrollView(
                    controller: _scroll,
                    padding: const EdgeInsets.all(10),
                    child: _pm2HorizontalIfTable(
                      _lines.any((l) => pm2HasTable(l.text)),
                      SelectableText.rich(
                        TextSpan(
                          children: [
                            for (final line in _lines)
                              TextSpan(
                                text: '${line.text}\n',
                                style: TextStyle(
                                  color: line.isError
                                      ? const Color(0xFFFCA5A5)
                                      : (line.text.startsWith('\$ ') ||
                                            line.text.startsWith('# '))
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.white,
                                ),
                              ),
                            if (_error != null)
                              TextSpan(
                                text: _error,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                          ],
                        ),
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11.5,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Gap(12),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: _lines.isEmpty
                        ? null
                        : () {
                            Clipboard.setData(
                              ClipboardData(
                                text: _lines.map((l) => l.text).join('\n'),
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Copied to clipboard'),
                              ),
                            );
                          },
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('Copy'),
                  ),
                  const Spacer(),
                  if (_done)
                    FilledButton(
                      onPressed: () => Navigator.pop(context, _success),
                      child: const Text('Close'),
                    )
                  else
                    OutlinedButton(
                      onPressed: _cancel,
                      child: const Text('Cancel'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== Ecosystem files ====================

/// Generates an ecosystem file with `pm2 init` and offers to edit it.
/// Resolves to the path of the file, or null.
Future<String?> showPm2EcosystemDialog(
  BuildContext context,
  WidgetRef ref, {
  required String defaultDir,
}) async {
  final dirController = TextEditingController(text: defaultDir);
  var full = false;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setState) => AlertDialog(
        title: const Text('Generate ecosystem file'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: dirController,
              decoration: const InputDecoration(
                labelText: 'Folder',
                helperText: 'ecosystem.config.js is created in this folder',
              ),
            ),
            const Gap(12),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Simple')),
                ButtonSegment(value: true, label: Text('With deploy')),
              ],
              selected: {full},
              onSelectionChanged: (s) => setState(() => full = s.first),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Generate'),
          ),
        ],
      ),
    ),
  );
  if (confirmed != true || !context.mounted) return null;

  final dir = dirController.text.trim().replaceAll(RegExp(r'/+$'), '');
  final ok = await runPm2Operation(
    context,
    ref,
    title: 'pm2 init',
    request: Pm2OperationRequest()
      ..operation = Pm2Operation.PM2_OP_INIT_ECOSYSTEM
      ..cwd = dir
      ..mode = full ? 'full' : 'simple',
  );
  final path = '$dir/ecosystem.config.js';
  if (ok && context.mounted) await openPm2FileEditor(context, path);
  return ok ? path : null;
}

Future<void> openPm2FileEditor(BuildContext context, String path) {
  return showDialog(
    context: context,
    builder: (_) => FileEditorDialog(
      file: FileItem(
        name: path.split('/').last,
        path: path,
        isDirectory: false,
        size: 0,
        permissions: 0,
        modified: DateTime.now(),
        owner: '',
        group: '',
      ),
    ),
  );
}

// ==================== Dialogs ====================

Future<bool> confirmPm2(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
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
                  backgroundColor: Theme.of(context).colorScheme.error,
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

Future<String?> promptPm2Text(
  BuildContext context, {
  required String title,
  required String label,
  String hint = '',
  String initial = '',
  String? helper,
  String confirmLabel = 'OK',
  TextInputType keyboardType = TextInputType.text,
  List<String> suggestions = const [],
}) {
  final controller = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                labelText: label,
                hintText: hint,
                helperText: helper,
                helperMaxLines: 3,
              ),
              onSubmitted: (v) => Navigator.pop(context, v.trim()),
            ),
            if (suggestions.isNotEmpty) ...[
              const Gap(12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
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
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(confirmLabel),
          ),
        ],
      ),
    ),
  );
}

// ==================== Layout helpers ====================

class Pm2SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;

  const Pm2SectionTitle({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const Gap(8),
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleSmall),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// A label/value row; tapping copies the value.
class Pm2InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool monospace;

  const Pm2InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.monospace = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onLongPress: value.isEmpty
          ? null
          : () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('$label copied')));
            },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Text(
                label,
                style: TextStyle(
                  color: context.cs.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value.isEmpty ? '-' : value,
                style: TextStyle(
                  fontSize: 12.5,
                  fontFamily: monospace ? 'monospace' : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== Arguments ====================

/// Splits a command line into arguments, honouring single and double quotes
/// and backslash escapes, like a POSIX shell does.
List<String> splitShellArgs(String input) {
  final args = <String>[];
  final current = StringBuffer();
  var inArg = false;
  String? quote;

  for (var i = 0; i < input.length; i++) {
    final c = input[i];
    if (quote != null) {
      if (c == quote) {
        quote = null;
      } else if (c == '\\' && quote == '"' && i + 1 < input.length) {
        current.write(input[++i]);
      } else {
        current.write(c);
      }
    } else if (c == '"' || c == "'") {
      quote = c;
      inArg = true;
    } else if (c == '\\' && i + 1 < input.length) {
      current.write(input[++i]);
      inArg = true;
    } else if (c == ' ' || c == '\t' || c == '\n') {
      if (inArg) {
        args.add(current.toString());
        current.clear();
        inArg = false;
      }
    } else {
      current.write(c);
      inArg = true;
    }
  }
  if (inArg) args.add(current.toString());
  return args;
}

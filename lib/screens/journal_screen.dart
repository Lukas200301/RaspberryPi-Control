import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../generated/pi_control.pb.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../ui/ui.dart';

enum _Level {
  all('All', null),
  error('Errors', Icons.error_outline),
  warning('Warnings', Icons.warning_amber_rounded),
  info('Info', Icons.info_outline),
  debug('Debug', Icons.bug_report_outlined);

  final String label;
  final IconData? icon;

  const _Level(this.label, this.icon);

  static _Level of(LogEntry e) {
    final l = e.level.toLowerCase();
    if (l.contains('err') || l.contains('crit') || l.contains('alert') || l.contains('emerg')) return error;
    if (l.contains('warn')) return warning;
    if (l.contains('debug')) return debug;
    return info;
  }
}

/// Live systemd journal, for the whole system or one [service]
class JournalScreen extends ConsumerStatefulWidget {
  final String? service;

  /// Any other log stream (e.g. a container); [tail] is the history wanted
  final Stream<LogEntry> Function(int tail)? open;
  final String? title;
  final String? kind;

  const JournalScreen({super.key, this.service}) : open = null, title = null, kind = null;

  const JournalScreen.custom({
    super.key,
    required Stream<LogEntry> Function(int tail) this.open,
    required String this.title,
    required String this.kind,
  }) : service = null;

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  static const _historyChoices = [100, 500, 2000];

  final _scroll = ScrollController();
  final List<LogEntry> _entries = [];
  final List<LogEntry> _pending = [];
  StreamSubscription<LogEntry>? _sub;

  int _history = 500;
  String _query = '';
  _Level _level = _Level.all;
  bool _follow = true;
  bool _paused = false;
  bool _connected = false;
  bool _ended = false;
  Object? _error;

  bool get _systemWide => widget.open == null && (widget.service == null || widget.service!.isEmpty);

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _start();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  void _start() {
    _sub?.cancel();
    setState(() {
      _entries.clear();
      _pending.clear();
      _connected = false;
      _ended = false;
      _error = null;
    });
    final stream =
        widget.open?.call(_history) ??
        ref.read(grpcServiceProvider).streamLogs(service: widget.service ?? '', tailLines: _history);
    _sub = stream.listen(
      (e) {
        if (!mounted) return;
        if (_paused) {
          _pending.add(e);
          if (_pending.length > _history) _pending.removeAt(0);
          return;
        }
        setState(() {
          _connected = true;
          _add(e);
        });
        if (_follow) _jumpToEnd();
      },
      onError: (Object e) {
        if (mounted) setState(() => _error = e);
      },
      onDone: () {
        if (mounted) setState(() => _ended = true);
      },
    );
  }

  void _add(LogEntry e) {
    _entries.add(e);
    if (_entries.length > _history) _entries.removeRange(0, _entries.length - _history);
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final atEnd = _scroll.position.pixels >= _scroll.position.maxScrollExtent - 48;
    // Scrolling up stops following; scrolling back down resumes it
    if (atEnd != _follow) setState(() => _follow = atEnd);
  }

  void _jumpToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  void _togglePause() {
    setState(() {
      _paused = !_paused;
      if (!_paused) {
        for (final e in _pending) {
          _add(e);
        }
        _pending.clear();
      }
    });
    if (!_paused && _follow) _jumpToEnd();
  }

  List<LogEntry> get _visible {
    final q = _query.toLowerCase();
    return _entries.where((e) {
      if (_level != _Level.all && _Level.of(e) != _level) return false;
      if (q.isEmpty) return true;
      return e.message.toLowerCase().contains(q) || e.service.toLowerCase().contains(q);
    }).toList();
  }

  String _line(LogEntry e) {
    final t = DateTime.fromMillisecondsSinceEpoch(e.timestamp.toInt() * 1000);
    return '${DateFormat('yyyy-MM-dd HH:mm:ss').format(t)} ${e.level.toUpperCase()} '
        '${e.service.isEmpty ? '' : '${e.service}: '}${e.message}';
  }

  Future<void> _copy(List<LogEntry> entries) async {
    await Clipboard.setData(ClipboardData(text: entries.map(_line).join('\n')));
    if (mounted) showToast(context, 'Copied ${entries.length} ${entries.length == 1 ? 'line' : 'lines'}');
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    final counts = {for (final l in _Level.values) l: 0};
    for (final e in _entries) {
      counts[_Level.of(e)] = counts[_Level.of(e)]! + 1;
    }

    final status = _error != null
        ? 'Stream failed'
        : _ended
        ? 'Stream ended'
        : _paused
        ? 'Paused · ${_pending.length} new'
        : _connected
        ? 'Live · ${_entries.length} lines'
        : 'Connecting…';

    return PageScaffold(
      title: widget.title ?? (_systemWide ? 'System logs' : widget.service!),
      subtitle: _systemWide ? status : '${widget.kind ?? 'Service logs'} · $status',
      actions: [
        IconButton(
          tooltip: _paused ? 'Resume' : 'Pause',
          icon: Icon(_paused ? Icons.play_arrow : Icons.pause),
          onPressed: _togglePause,
        ),
        PopupMenuButton<String>(
          onSelected: (v) async {
            switch (v) {
              case 'copy':
                await _copy(visible);
              case 'clear':
                setState(_entries.clear);
              case 'reconnect':
                _start();
              case 'history':
                final picked = await showChoiceSheet<int>(
                  context,
                  title: 'Lines to keep',
                  value: _history,
                  choices: [for (final c in _historyChoices) (c, '$c lines')],
                );
                if (picked != null && picked != _history) {
                  _history = picked;
                  _start();
                }
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'copy',
              child: ListTile(leading: Icon(Icons.copy_all), title: Text('Copy shown lines')),
            ),
            const PopupMenuItem(
              value: 'clear',
              child: ListTile(leading: Icon(Icons.clear_all), title: Text('Clear screen')),
            ),
            PopupMenuItem(
              value: 'history',
              child: ListTile(leading: const Icon(Icons.history), title: Text('Lines to keep ($_history)')),
            ),
            const PopupMenuItem(
              value: 'reconnect',
              child: ListTile(leading: Icon(Icons.refresh), title: Text('Reload')),
            ),
          ],
        ),
      ],
      bottom: SearchFilterBar<_Level>(
        hint: _systemWide ? 'Search messages or services' : 'Search messages',
        onSearch: (v) => setState(() => _query = v),
        filters: [
          for (final l in _Level.values)
            FilterOption(l, l.label, icon: l.icon, count: l == _Level.all ? _entries.length : counts[l]),
        ],
        selected: _level,
        onFilter: (l) => setState(() => _level = l),
      ),
      floatingActionButton: _follow
          ? null
          : FloatingActionButton.small(
              tooltip: 'Jump to newest',
              onPressed: () {
                setState(() => _follow = true);
                _jumpToEnd();
              },
              child: const Icon(Icons.vertical_align_bottom),
            ),
      body: _body(context, visible),
    );
  }

  Widget _body(BuildContext context, List<LogEntry> visible) {
    if (_error != null && _entries.isEmpty) {
      return ErrorState(title: 'Logs are not available', error: _error!, onRetry: _start);
    }
    if (!_connected && _entries.isEmpty && !_ended) return const LoadingState(message: 'Opening the journal…');
    if (_entries.isEmpty) {
      return EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'No log entries',
        message: _systemWide
            ? 'Nothing was logged yet.'
            : '${widget.title ?? widget.service} has not logged anything recently.',
        action: OutlinedButton.icon(onPressed: _start, icon: const Icon(Icons.refresh), label: const Text('Reload')),
      );
    }
    return Column(
      children: [
        if (_ended || _error != null)
          MaterialBanner(
            content: Text(
              _error != null ? 'The log stream failed: ${describeError(_error!)}' : 'The log stream ended.',
            ),
            leading: const Icon(Icons.link_off),
            actions: [TextButton(onPressed: _start, child: const Text('Reconnect'))],
          ),
        Expanded(
          child: visible.isEmpty
              ? const EmptyState(icon: Icons.filter_alt_off_outlined, title: 'No lines match the filter')
              : Container(
                  margin: const EdgeInsets.fromLTRB(Insets.sm, 0, Insets.sm, Insets.sm),
                  decoration: BoxDecoration(color: context.ac.codeBackground, borderRadius: Radii.mdAll),
                  child: ClipRRect(
                    borderRadius: Radii.mdAll,
                    child: SelectionArea(
                      child: ListView.builder(
                        controller: _scroll,
                        padding: const EdgeInsets.symmetric(vertical: Insets.sm),
                        itemCount: visible.length,
                        itemBuilder: (context, i) => _LogLine(
                          entry: visible[i],
                          showService: _systemWide,
                          onLongPress: () => _copy([visible[i]]),
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class _LogLine extends StatelessWidget {
  final LogEntry entry;
  final bool showService;
  final VoidCallback onLongPress;

  const _LogLine({required this.entry, required this.showService, required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    final level = _Level.of(entry);
    final color = switch (level) {
      _Level.error => context.cs.error,
      _Level.warning => context.ac.warning,
      _Level.debug => context.ac.codeForeground.withValues(alpha: 0.55),
      _ => context.ac.info,
    };
    final t = DateTime.fromMillisecondsSinceEpoch(entry.timestamp.toInt() * 1000);
    final fg = context.ac.codeForeground;

    return InkWell(
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: color, width: 3)),
        ),
        padding: const EdgeInsets.fromLTRB(Insets.sm, 3, Insets.md, 3),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '${DateFormat('MMM dd HH:mm:ss').format(t)}  ',
                style: TextStyle(color: fg.withValues(alpha: 0.5)),
              ),
              if (showService && entry.service.isNotEmpty)
                TextSpan(
                  text: '${entry.service}  ',
                  style: TextStyle(color: context.ac.series[2], fontWeight: FontWeight.w600),
                ),
              TextSpan(
                text: entry.message,
                style: TextStyle(color: level == _Level.error ? context.cs.error : fg),
              ),
            ],
          ),
          style: AppTheme.mono(size: 12.5, color: fg),
        ),
      ),
    );
  }
}

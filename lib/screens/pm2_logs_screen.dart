import 'dart:async';

import 'package:flutter/material.dart';
import '../ui/ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../generated/pi_control.pb.dart';
import '../services/pm2_service.dart';
import '../widgets/pm2_widgets.dart';

/// Live PM2 logs (pm2 logs) of one process or all processes
class Pm2LogsScreen extends ConsumerStatefulWidget {
  /// pm_id, name or "all"
  final String target;
  final String title;

  /// Only show ~/.pm2/pm2.log
  final bool daemonOnly;

  const Pm2LogsScreen({
    super.key,
    required this.target,
    required this.title,
    this.daemonOnly = false,
  });

  @override
  ConsumerState<Pm2LogsScreen> createState() => _Pm2LogsScreenState();
}

class _Pm2LogsScreenState extends ConsumerState<Pm2LogsScreen> {
  static const _maxEntries = 5000;
  static const _appColors = [
    Color(0xFF60A5FA),
    Color(0xFF34D399),
    Color(0xFFFBBF24),
    Color(0xFFF472B6),
    Color(0xFFA78BFA),
    Color(0xFF22D3EE),
    Color(0xFFFB923C),
    Color(0xFFA3E635),
  ];

  final ScrollController _scroll = ScrollController();
  final List<Pm2LogLine> _entries = [];
  final List<Pm2LogLine> _pending = [];
  StreamSubscription<Pm2LogLine>? _subscription;

  late bool _out = !widget.daemonOnly;
  late bool _err = !widget.daemonOnly;
  late bool _daemon = widget.daemonOnly;
  int _lines = 200;
  bool _paused = false;
  bool _autoScroll = true;
  bool _wrap = true;
  bool _showTime = true;
  bool _timeHintDismissed = false;
  String _search = '';
  String? _error;
  bool _connecting = true;

  bool get _multiApp => widget.target == 'all';

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (!_scroll.hasClients) return;
      final atBottom =
          _scroll.position.pixels >= _scroll.position.maxScrollExtent - 40;
      if (atBottom != _autoScroll &&
          _scroll.position.userScrollDirection != ScrollDirection.idle) {
        setState(() => _autoScroll = atBottom);
      }
    });
    _start();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  void _start() {
    _subscription?.cancel();
    setState(() {
      _entries.clear();
      _pending.clear();
      _error = null;
      _connecting = true;
    });

    if (!_out && !_err && !_daemon) {
      setState(() => _connecting = false);
      return;
    }

    _subscription = ref
        .read(pm2ServiceProvider)
        .streamLogs(
          target: widget.target,
          lines: _lines,
          follow: true,
          includeOut: _out,
          includeErr: _err,
          includeDaemon: _daemon,
        )
        .listen(
          (line) {
            if (!mounted) return;
            if (_paused) {
              _pending.add(line);
              if (_pending.length > _maxEntries) _pending.removeAt(0);
              setState(() => _connecting = false);
              return;
            }
            setState(() {
              _connecting = false;
              _append([line]);
            });
            _scrollToEnd();
          },
          onError: (Object e) {
            if (mounted) {
              setState(() {
                _connecting = false;
                _error = Pm2Exception.from(e).message;
              });
            }
          },
          onDone: () {
            if (mounted) setState(() => _connecting = false);
          },
        );

    // The stream only delivers once a log line exists
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _connecting) setState(() => _connecting = false);
    });
  }

  void _append(List<Pm2LogLine> lines) {
    _entries.addAll(lines);
    if (_entries.length > _maxEntries) {
      _entries.removeRange(0, _entries.length - _maxEntries);
    }
  }

  void _scrollToEnd() {
    if (!_autoScroll) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  void _togglePause() {
    setState(() {
      _paused = !_paused;
      if (!_paused) {
        _append(_pending);
        _pending.clear();
      }
    });
    if (!_paused) _scrollToEnd();
  }

  Color _colorFor(String app) =>
      _appColors[app.hashCode.abs() % _appColors.length];

  List<Pm2LogLine> get _visible {
    if (_search.isEmpty) return _entries;
    final query = _search.toLowerCase();
    return _entries
        .where(
          (e) =>
              e.text.toLowerCase().contains(query) ||
              e.appName.toLowerCase().contains(query),
        )
        .toList();
  }

  static final _timeFormat = DateFormat('HH:mm:ss');
  static final _dateTimeFormat = DateFormat('MM-dd HH:mm:ss');

  static bool _isToday(DateTime t) {
    final now = DateTime.now();
    return t.year == now.year && t.month == now.month && t.day == now.day;
  }

  /// Show the date only when some lines are not from today
  bool _needsDate(List<Pm2LogLine> lines) => lines.any(
    (l) =>
        l.timestamp > 0 &&
        !_isToday(DateTime.fromMillisecondsSinceEpoch(l.timestamp.toInt())),
  );

  String _timeLabel(Pm2LogLine line, bool withDate) {
    if (line.timestamp <= 0) return withDate ? '--------------' : '--:--:--';
    final t = DateTime.fromMillisecondsSinceEpoch(line.timestamp.toInt());
    return (withDate ? _dateTimeFormat : _timeFormat).format(t);
  }

  Future<void> _flush() async {
    final all = widget.target == 'all';
    if (!await confirmPm2(
      context,
      title: all ? 'Flush all logs?' : 'Flush these logs?',
      message: 'The log files on the Pi are emptied.',
      confirmLabel: 'Flush',
      destructive: true,
    )) {
      return;
    }
    if (!mounted) return;
    final ok = await pm2Control(
      context,
      ref,
      Pm2Action.PM2_ACTION_FLUSH,
      widget.target,
      progress: 'Flushing logs…',
      success: 'Logs flushed',
    );
    if (ok && mounted) setState(_entries.clear);
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            tooltip: _paused ? 'Resume' : 'Pause',
            icon: Badge(
              isLabelVisible: _paused && _pending.isNotEmpty,
              label: Text('${_pending.length}'),
              child: Icon(_paused ? Icons.play_arrow : Icons.pause),
            ),
            onPressed: _togglePause,
          ),
          IconButton(
            tooltip: 'Auto-scroll',
            icon: Icon(
              _autoScroll
                  ? Icons.vertical_align_bottom
                  : Icons.vertical_align_center,
            ),
            onPressed: () {
              setState(() => _autoScroll = !_autoScroll);
              _scrollToEnd();
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'wrap':
                  setState(() => _wrap = !_wrap);
                case 'time':
                  setState(() => _showTime = !_showTime);
                case 'copy':
                  final withDate = _needsDate(visible);
                  Clipboard.setData(
                    ClipboardData(
                      text: visible.map((l) => _plain(l, withDate)).join('\n'),
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${visible.length} lines copied')),
                  );
                case 'clear':
                  setState(_entries.clear);
                case 'flush':
                  _flush();
                default:
                  final lines = int.tryParse(value);
                  if (lines != null) {
                    _lines = lines;
                    _start();
                  }
              }
            },
            itemBuilder: (_) => [
              for (final n in const [50, 200, 1000, 5000])
                CheckedPopupMenuItem(
                  value: '$n',
                  checked: _lines == n,
                  child: Text('Last $n lines'),
                ),
              const PopupMenuDivider(),
              CheckedPopupMenuItem(
                value: 'time',
                checked: _showTime,
                child: const Text('Show timestamps'),
              ),
              CheckedPopupMenuItem(
                value: 'wrap',
                checked: _wrap,
                child: const Text('Wrap lines'),
              ),
              const PopupMenuItem(
                value: 'copy',
                child: Text('Copy visible lines'),
              ),
              const PopupMenuItem(value: 'clear', child: Text('Clear view')),
              if (!widget.daemonOnly)
                const PopupMenuItem(
                  value: 'flush',
                  child: Text('Flush log files'),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
            child: Column(
              children: [
                if (!widget.daemonOnly)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _streamChip(
                          'stdout',
                          _out,
                          context.cs.onSurface,
                          (v) => _out = v,
                        ),
                        const Gap(8),
                        _streamChip(
                          'stderr',
                          _err,
                          context.ac.logStderr,
                          (v) => _err = v,
                        ),
                        const Gap(8),
                        _streamChip(
                          'PM2 daemon',
                          _daemon,
                          context.ac.logDaemon,
                          (v) => _daemon = v,
                        ),
                      ],
                    ),
                  ),
                const Gap(8),
                TextField(
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Filter lines',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    filled: true,
                    fillColor: context.cs.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (v) => setState(() => _search = v),
                ),
              ],
            ),
          ),
          if (_showTime &&
              !_timeHintDismissed &&
              _entries.any((l) => l.history && l.timestamp <= 0))
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const Gap(10),
                  const Expanded(
                    child: Text(
                      'Older lines were written without a timestamp (--:--:--). '
                      'New lines show the time they arrived in italics. Start the '
                      'app with the "Timestamps" option (--time) so PM2 stores the '
                      'time in the log.',
                      style: TextStyle(fontSize: 11.5),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => setState(() => _timeHintDismissed = true),
                  ),
                ],
              ),
            ),
          if (_error != null)
            Container(
              width: double.infinity,
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.2),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(_error!, style: const TextStyle(fontSize: 12)),
                  ),
                  TextButton(onPressed: _start, child: const Text('Retry')),
                ],
              ),
            ),
          Expanded(
            child: _connecting && _entries.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : visible.isEmpty
                ? Center(
                    child: Text(
                      _entries.isEmpty
                          ? 'Waiting for log output…'
                          : 'No lines match the filter',
                      style: TextStyle(color: context.cs.onSurfaceVariant),
                    ),
                  )
                : Container(
                    margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                    decoration: BoxDecoration(
                      color: context.ac.codeBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _buildList(visible),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<Pm2LogLine> visible) {
    final withDate = _showTime && _needsDate(visible);
    final list = ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 16),
      itemCount: visible.length,
      itemBuilder: (context, index) => _buildLine(visible[index], withDate),
    );
    if (_wrap) return list;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(width: 1600, child: list),
    );
  }

  static const _lineStyle = TextStyle(
    fontFamily: 'monospace',
    fontSize: 11.5,
    height: 1.3,
  );

  Widget _buildLine(Pm2LogLine line, bool withDate) {
    final textColor = switch (line.stream) {
      'err' => context.ac.logStderr,
      'pm2' => context.ac.logDaemon,
      _ => context.ac.logStdout,
    };

    final text = Text.rich(
      TextSpan(
        children: [
          if (_multiApp || line.stream == 'pm2')
            TextSpan(
              text: line.stream == 'pm2'
                  ? 'PM2 │ '
                  : '${line.pmId}|${line.appName} │ ',
              style: TextStyle(
                color: line.stream == 'pm2'
                    ? const Color(0xFFC4B5FD)
                    : _colorFor(line.appName),
                fontWeight: FontWeight.w600,
              ),
            ),
          TextSpan(
            // The timestamp column replaces the one inside the line
            text: _showTime ? _message(line) : line.text,
            style: TextStyle(color: textColor),
          ),
        ],
      ),
      softWrap: _wrap,
      style: _lineStyle,
    );

    if (!_showTime) {
      return Padding(padding: const EdgeInsets.only(bottom: 2), child: text);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _timeLabel(line, withDate),
            style: _lineStyle.copyWith(
              color: line.timestampFromLog
                  ? context.cs.onSurfaceVariant
                  : context.cs.outline,
              fontStyle: line.timestampFromLog || line.timestamp <= 0
                  ? FontStyle.normal
                  : FontStyle.italic,
            ),
          ),
          const Gap(8),
          Expanded(child: text),
        ],
      ),
    );
  }

  String _plain(Pm2LogLine line, bool withDate) {
    final app = _multiApp ? '${line.pmId}|${line.appName} | ' : '';
    if (!_showTime) return '$app${line.text}';
    return '${_timeLabel(line, withDate)}  $app${_message(line)}';
  }

  /// The line without its timestamp (older agents only send the raw text)
  String _message(Pm2LogLine line) =>
      line.timestampFromLog || line.message.isNotEmpty ? line.message : line.text;

  Widget _streamChip(
    String label,
    bool selected,
    Color color,
    void Function(bool) apply,
  ) {
    // A plain toggle pill: Material chips clip a custom label, and colored
    // text on the selected chip background is unreadable
    return Material(
      color: selected ? color.withValues(alpha: 0.18) : Colors.transparent,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? color.withValues(alpha: 0.7) : context.cs.outlineVariant,
        ),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: () {
          apply(!selected);
          _start();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? Icons.check_circle : Icons.circle_outlined,
                size: 16,
                color: color,
              ),
              const Gap(8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? context.cs.onSurface : context.cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

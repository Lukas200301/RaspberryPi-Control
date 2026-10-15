import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../generated/pi_control.pb.dart';
import '../providers/app_providers.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../ui/ui.dart';

/// Process list, refreshed on the configured interval while [live]
final _processesProvider = AsyncNotifierProvider.autoDispose<_ProcessesNotifier, List<ProcessInfo>>(
  _ProcessesNotifier.new,
);

class _ProcessesNotifier extends AutoDisposeAsyncNotifier<List<ProcessInfo>> {
  Timer? _timer;
  bool live = true;

  @override
  Future<List<ProcessInfo>> build() async {
    ref.watch(grpcSessionProvider);
    final seconds = ref.watch(settingsProvider.select((s) => s.refreshSeconds)).clamp(1, 60);
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: seconds), (_) {
      if (live) refresh();
    });
    ref.onDispose(() => _timer?.cancel());
    return _load();
  }

  Future<List<ProcessInfo>> _load() async =>
      (await ref.read(grpcServiceProvider).listProcesses()).processes.toList();

  Future<void> refresh() async {
    try {
      state = AsyncData(await _load());
    } catch (e, st) {
      if (!state.hasValue) state = AsyncError(e, st);
    }
  }
}

enum _Sort {
  cpu('CPU', Icons.speed),
  memory('Memory', Icons.memory),
  name('Name', Icons.sort_by_alpha),
  pid('PID', Icons.tag);

  final String label;
  final IconData icon;

  const _Sort(this.label, this.icon);
}

(String, Tone) _status(ProcessInfo p) => switch (p.status) {
  'running' => ('running', Tone.success),
  'stop' => ('paused', Tone.warning),
  'zombie' => ('zombie', Tone.danger),
  'blocked' || 'wait' || 'lock' => (p.status, Tone.info),
  'idle' => ('idle', Tone.neutral),
  '' => ('', Tone.neutral),
  _ => ('sleeping', Tone.neutral),
};

/// Kernel threads have no command line and hang off kthreadd (PID 2)
bool _isKernelThread(ProcessInfo p) => p.pid == 2 || (p.ppid == 2 && p.cmdline.isEmpty);

class _Row {
  final ProcessInfo process;
  final int depth;
  final int children;

  const _Row(this.process, this.depth, this.children);
}

class ProcessesScreen extends ConsumerStatefulWidget {
  const ProcessesScreen({super.key});

  @override
  ConsumerState<ProcessesScreen> createState() => _ProcessesScreenState();
}

class _ProcessesScreenState extends ConsumerState<ProcessesScreen> {
  String _query = '';
  _Sort _sort = _Sort.cpu;
  bool _tree = false;
  bool _kernel = false;
  final _collapsed = <int>{};

  int _compare(ProcessInfo a, ProcessInfo b) => switch (_sort) {
    _Sort.cpu => b.cpuPercent.compareTo(a.cpuPercent),
    _Sort.memory => b.memoryBytes.compareTo(a.memoryBytes),
    _Sort.name => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    _Sort.pid => a.pid.compareTo(b.pid),
  };

  List<_Row> _rows(List<ProcessInfo> all) {
    final visible = _kernel ? all : all.where((p) => !_isKernelThread(p)).toList();
    final q = _query.toLowerCase();
    if (q.isNotEmpty || !_tree) {
      final list = visible.where((p) {
        if (q.isEmpty) return true;
        return p.name.toLowerCase().contains(q) ||
            p.pid.toString() == q ||
            p.username.toLowerCase().contains(q) ||
            p.cmdline.toLowerCase().contains(q);
      }).toList()..sort(_compare);
      return [for (final p in list) _Row(p, 0, 0)];
    }

    final byPid = {for (final p in visible) p.pid: p};
    final children = <int, List<ProcessInfo>>{};
    final roots = <ProcessInfo>[];
    for (final p in visible) {
      if (p.ppid != 0 && p.ppid != p.pid && byPid.containsKey(p.ppid)) {
        children.putIfAbsent(p.ppid, () => []).add(p);
      } else {
        roots.add(p);
      }
    }
    final rows = <_Row>[];
    void walk(ProcessInfo p, int depth) {
      final kids = [...?children[p.pid]]..sort(_compare);
      rows.add(_Row(p, depth, kids.length));
      if (_collapsed.contains(p.pid)) return;
      for (final k in kids) {
        walk(k, depth + 1);
      }
    }

    for (final r in roots..sort(_compare)) {
      walk(r, 0);
    }
    return rows;
  }

  Future<void> _act(ProcessInfo p, String verb, Future<ActionStatus> Function() call) async {
    try {
      final r = await call();
      if (!mounted) return;
      showToast(
        context,
        r.success ? '$verb ${p.name} (${p.pid})' : r.message,
        tone: r.success ? Tone.success : Tone.danger,
      );
      ref.read(_processesProvider.notifier).refresh();
    } catch (e) {
      if (mounted) showToast(context, describeError(e), tone: Tone.danger);
    }
  }

  Future<void> _kill(ProcessInfo p) async {
    final risky = p.pid == 1 || const ['sshd', 'systemd', 'agent', 'pi-agent', 'init'].contains(p.name);
    if (!await showConfirmDialog(
      context,
      title: 'Kill ${p.name}?',
      message: '${risky ? 'This is a system process; the device or the app connection may stop working. ' : ''}'
          'PID ${p.pid} is stopped immediately (SIGKILL) without a chance to save its work.',
      confirmLabel: 'Kill',
      destructive: true,
      icon: risky ? Icons.warning_amber_rounded : Icons.dangerous_outlined,
    )) {
      return;
    }
    final grpc = ref.read(grpcServiceProvider);
    await _act(p, 'Killed', () => grpc.killProcess(p.pid));
  }

  void _details(ProcessInfo p, List<ProcessInfo> all) {
    final grpc = ref.read(grpcServiceProvider);
    final parent = all.where((x) => x.pid == p.ppid).firstOrNull;
    final paused = p.status == 'stop';
    final (label, tone) = _status(p);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(Insets.xl, 0, Insets.xl, Insets.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconBadge(Icons.memory, tone: tone, size: 48),
                  const Gap(Insets.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.name, style: sheet.tt.titleLarge, overflow: TextOverflow.ellipsis),
                        Text(
                          'PID ${p.pid} · ${p.username}',
                          style: sheet.tt.bodySmall?.copyWith(color: sheet.cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  if (label.isNotEmpty) StatusPill(label, tone: tone, dot: true),
                ],
              ),
              const Gap(Insets.lg),
              InfoRow('CPU', '${p.cpuPercent.toStringAsFixed(1)} %'),
              InfoRow('Memory', '${formatBytes(p.memoryBytes.toInt())} · ${p.memoryPercent.toStringAsFixed(1)} %'),
              InfoRow('Parent', parent == null ? '${p.ppid}' : '${parent.name} (${p.ppid})'),
              InfoRow('Children', '${all.where((x) => x.ppid == p.pid).length}'),
              if (p.cmdline.isNotEmpty) ...[
                const Gap(Insets.md),
                Text('Command', style: sheet.tt.labelLarge),
                const Gap(Insets.xs),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(Insets.md, Insets.sm, Insets.xs, Insets.sm),
                  decoration: BoxDecoration(color: sheet.ac.codeBackground, borderRadius: Radii.smAll),
                  child: Row(
                    children: [
                      Expanded(
                        child: SelectableText(p.cmdline, style: AppTheme.mono(size: 12, color: sheet.ac.codeForeground)),
                      ),
                      IconButton(
                        tooltip: 'Copy',
                        icon: Icon(Icons.copy, size: 18, color: sheet.ac.codeForeground),
                        onPressed: () => Clipboard.setData(ClipboardData(text: p.cmdline)),
                      ),
                    ],
                  ),
                ),
              ],
              const Gap(Insets.lg),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: () {
                        Navigator.pop(sheet);
                        paused
                            ? _act(p, 'Resumed', () => grpc.resumeProcess(p.pid))
                            : _act(p, 'Paused', () => grpc.pauseProcess(p.pid));
                      },
                      icon: Icon(paused ? Icons.play_arrow : Icons.pause),
                      label: Text(paused ? 'Resume' : 'Pause'),
                    ),
                  ),
                  const Gap(Insets.sm),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: sheet.cs.error,
                        foregroundColor: sheet.cs.onError,
                      ),
                      onPressed: () {
                        Navigator.pop(sheet);
                        _kill(p);
                      },
                      icon: const Icon(Icons.close),
                      label: const Text('Kill'),
                    ),
                  ),
                ],
              ),
              const Gap(Insets.xs),
              Text(
                'Pause freezes the process (SIGSTOP) until you resume it.',
                style: sheet.tt.bodySmall?.copyWith(color: sheet.cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_processesProvider);
    final notifier = ref.read(_processesProvider.notifier);
    final all = async.valueOrNull ?? const <ProcessInfo>[];
    final rows = _rows(all);
    final totalCpu = all.fold<double>(0, (s, p) => s + p.cpuPercent);
    final running = all.where((p) => p.status == 'running').length;

    return PageScaffold(
      title: 'Processes',
      subtitle: all.isEmpty
          ? null
          : '${all.length} processes · $running running · CPU ${totalCpu.toStringAsFixed(0)} %',
      actions: [
        IconButton(
          tooltip: _tree ? 'Show as list' : 'Show as tree',
          isSelected: _tree,
          icon: const Icon(Icons.account_tree_outlined),
          selectedIcon: const Icon(Icons.account_tree),
          onPressed: () => setState(() => _tree = !_tree),
        ),
        IconButton(
          tooltip: notifier.live ? 'Pause updates' : 'Resume updates',
          icon: Icon(notifier.live ? Icons.pause_circle_outline : Icons.play_circle_outline),
          onPressed: () => setState(() {
            notifier.live = !notifier.live;
            if (notifier.live) notifier.refresh();
          }),
        ),
        PopupMenuButton<String>(
          onSelected: (v) => setState(() {
            if (v == 'kernel') _kernel = !_kernel;
            if (v == 'expand') _collapsed.clear();
          }),
          itemBuilder: (_) => [
            CheckedPopupMenuItem(value: 'kernel', checked: _kernel, child: const Text('Show kernel threads')),
            if (_tree) const PopupMenuItem(value: 'expand', child: Text('Expand all')),
          ],
        ),
      ],
      bottom: SearchFilterBar<_Sort>(
        hint: 'Search name, PID, user or command',
        onSearch: (v) => setState(() => _query = v),
        selected: _sort,
        onFilter: (s) => setState(() => _sort = s),
        filters: [for (final s in _Sort.values) FilterOption(s, s.label, icon: s.icon)],
      ),
      body: AsyncView(
        value: async,
        onRetry: () => ref.invalidate(_processesProvider),
        loadingMessage: 'Loading processes…',
        data: (_) => rows.isEmpty
            ? const EmptyState(icon: Icons.search_off, title: 'No processes match')
            : RefreshIndicator(
                onRefresh: notifier.refresh,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(Insets.page, Insets.xs, Insets.page, 96),
                  itemCount: rows.length,
                  itemBuilder: (context, i) {
                    final r = rows[i];
                    return _ProcessTile(
                      row: r,
                      collapsed: _collapsed.contains(r.process.pid),
                      onToggle: r.children == 0
                          ? null
                          : () => setState(() {
                              _collapsed.contains(r.process.pid)
                                  ? _collapsed.remove(r.process.pid)
                                  : _collapsed.add(r.process.pid);
                            }),
                      onTap: () => _details(r.process, all),
                    );
                  },
                ),
              ),
      ),
    );
  }
}

class _ProcessTile extends StatelessWidget {
  final _Row row;
  final bool collapsed;
  final VoidCallback? onToggle;
  final VoidCallback onTap;

  const _ProcessTile({required this.row, required this.collapsed, required this.onToggle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = row.process;
    final (label, tone) = _status(p);
    final cpuTone = usageTone(p.cpuPercent, warn: 50, critical: 80);
    final indent = (row.depth * 18.0).clamp(0.0, 144.0);

    return Padding(
      padding: EdgeInsets.only(left: indent, bottom: Insets.xs),
      child: Material(
        color: context.cs.surfaceContainer,
        borderRadius: Radii.mdAll,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: row.depth > 0
                ? BoxDecoration(border: Border(left: BorderSide(color: context.cs.outlineVariant, width: 2)))
                : null,
            padding: const EdgeInsets.fromLTRB(Insets.xs, Insets.sm, Insets.md, Insets.sm),
            child: Row(
              children: [
                SizedBox(
                  width: 36,
                  child: onToggle == null
                      ? Center(
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(color: context.tone(tone), shape: BoxShape.circle),
                          ),
                        )
                      : IconButton(
                          visualDensity: VisualDensity.compact,
                          tooltip: collapsed ? 'Show ${row.children} children' : 'Hide children',
                          icon: Icon(collapsed ? Icons.chevron_right : Icons.expand_more, size: 20),
                          onPressed: onToggle,
                        ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(p.name, style: context.tt.titleSmall, overflow: TextOverflow.ellipsis),
                          ),
                          if (collapsed && row.children > 0) ...[
                            const Gap(Insets.xs),
                            StatusPill('+${row.children}'),
                          ],
                          if (label == 'paused' || label == 'zombie') ...[
                            const Gap(Insets.xs),
                            StatusPill(label, tone: tone),
                          ],
                        ],
                      ),
                      Text(
                        '${p.pid} · ${p.username}',
                        style: context.tt.bodySmall?.copyWith(
                          color: context.cs.onSurfaceVariant,
                          fontFeatures: tabularFigures,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Gap(Insets.sm),
                SizedBox(
                  width: 64,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${p.cpuPercent.toStringAsFixed(1)}%',
                        style: context.tt.labelLarge?.copyWith(
                          color: p.cpuPercent >= 1 ? context.tone(cpuTone) : context.cs.onSurfaceVariant,
                          fontFeatures: tabularFigures,
                        ),
                      ),
                      Text(
                        'CPU',
                        style: context.tt.labelSmall?.copyWith(color: context.cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 72,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatBytes(p.memoryBytes.toInt(), decimals: 0),
                        style: context.tt.labelLarge?.copyWith(fontFeatures: tabularFigures),
                      ),
                      Text(
                        'RAM',
                        style: context.tt.labelSmall?.copyWith(color: context.cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

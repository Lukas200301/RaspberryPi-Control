import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../../generated/pi_control.pb.dart';
import '../../models/cron.dart';
import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';
import '../../ui/ui.dart';
import '../../widgets/command_result.dart';

/// Cron jobs of a user: list, add, edit, enable/disable, run now
class CronScreen extends ConsumerStatefulWidget {
  const CronScreen({super.key});

  @override
  ConsumerState<CronScreen> createState() => _CronScreenState();
}

class _CronScreenState extends ConsumerState<CronScreen> {
  String _user = '';
  Crontab? _crontab;
  CrontabDocument _doc = const CrontabDocument([]);
  Object? _error;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final tab = await ref.read(adminServiceProvider).getCrontab(_user);
      if (!mounted) return;
      setState(() {
        _crontab = tab;
        _user = tab.user;
        _doc = CrontabDocument.parse(tab.content);
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e;
          _loading = false;
        });
      }
    }
  }

  Future<bool> _save(CrontabDocument doc, String message) async {
    setState(() => _saving = true);
    try {
      final result = await ref.read(adminServiceProvider).setCrontab(_user, doc.render());
      if (!mounted) return false;
      final ok = reportCommand(context, result, success: message);
      if (ok) setState(() => _doc = doc);
      return ok;
    } catch (e) {
      if (mounted) showToast(context, describeError(e), tone: Tone.danger);
      return false;
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _edit([CronJob? job]) async {
    final result = await Navigator.push<CronJob>(
      context,
      MaterialPageRoute(fullscreenDialog: true, builder: (_) => _JobEditor(job: job)),
    );
    if (result == null) return;
    await _save(
      job == null ? _doc.add(result) : _doc.replace(job, result),
      job == null ? 'Job added' : 'Job saved',
    );
  }

  Future<void> _runNow(CronJob job) async {
    showToast(context, 'Running…', duration: const Duration(minutes: 1));
    try {
      final result = await ref.read(adminServiceProvider).runAsUser(_user, job.command, timeoutSeconds: 120);
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      await showOutputDialog(
        context,
        title: result.success ? 'Finished' : 'Failed (exit ${result.exitCode})',
        command: job.command,
        output: result.output,
        isError: !result.success,
      );
    } catch (e) {
      if (mounted) showToast(context, describeError(e), tone: Tone.danger);
    }
  }

  void _jobMenu(CronJob job) {
    showActionSheet(
      context,
      title: job.comment.isNotEmpty ? job.comment : job.command,
      subtitle: '${job.schedule}  ·  ${job.parsed?.describe() ?? ''}',
      actions: [
        SheetAction(icon: Icons.edit_outlined, label: 'Edit', onTap: () => _edit(job)),
        SheetAction(icon: Icons.play_arrow, label: 'Run now', tone: Tone.success, onTap: () => _runNow(job)),
        SheetAction(
          icon: job.enabled ? Icons.pause_circle_outline : Icons.play_circle_outline,
          label: job.enabled ? 'Disable' : 'Enable',
          tone: Tone.warning,
          onTap: () => _save(_doc.replace(job, job.copyWith(enabled: !job.enabled)), job.enabled ? 'Job disabled' : 'Job enabled'),
        ),
        SheetAction(
          icon: Icons.copy_all_outlined,
          label: 'Duplicate',
          onTap: () => _save(_doc.add(job.copyWith()), 'Job duplicated'),
        ),
        SheetAction(
          icon: Icons.delete_outline,
          label: 'Delete',
          destructive: true,
          onTap: () async {
            if (await showConfirmDialog(
              context,
              title: 'Delete this job?',
              message: job.command,
              confirmLabel: 'Delete',
              destructive: true,
            )) {
              await _save(_doc.replace(job, null), 'Job deleted');
            }
          },
        ),
      ],
    );
  }

  Future<void> _editRaw() async {
    final controller = TextEditingController(text: _doc.render());
    final text = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('crontab of $_user'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Save')),
              const Gap(Insets.sm),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(Insets.md),
            child: TextField(
              controller: controller,
              maxLines: null,
              expands: true,
              autocorrect: false,
              enableSuggestions: false,
              textAlignVertical: TextAlignVertical.top,
              style: AppTheme.mono(size: 13, color: context.cs.onSurface),
              decoration: const InputDecoration(hintText: '# m h dom mon dow command'),
            ),
          ),
        ),
      ),
    );
    if (text != null) await _save(CrontabDocument.parse(text), 'Crontab saved');
  }

  Future<void> _pickUser() async {
    final users = {
      _user,
      ...?_crontab?.usersWithCrontab,
      'root',
    }.where((u) => u.isNotEmpty).toList()
      ..sort();
    final picked = await showTextPrompt(
      context,
      title: 'Show cron jobs of',
      label: 'User name',
      initial: _user,
      suggestions: users,
      confirmLabel: 'Show',
    );
    if (picked != null && picked.isNotEmpty && picked != _user) {
      _user = picked;
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobs = _doc.jobs;
    return PageScaffold(
      title: 'Cron jobs',
      subtitle: _user.isEmpty ? null : 'User $_user',
      actions: [
        IconButton(tooltip: 'Switch user', icon: const Icon(Icons.manage_accounts_outlined), onPressed: _pickUser),
        IconButton(tooltip: 'Edit as text', icon: const Icon(Icons.code), onPressed: _crontab == null ? null : _editRaw),
        IconButton(tooltip: 'Refresh', icon: const Icon(Icons.refresh), onPressed: _load),
      ],
      floatingActionButton: _crontab == null
          ? null
          : FloatingActionButton.extended(
              onPressed: _saving ? null : () => _edit(),
              icon: const Icon(Icons.add),
              label: const Text('New job'),
            ),
      body: _loading
          ? const LoadingState()
          : _error != null
          ? ErrorState(error: _error!, onRetry: _load)
          : PageList(
              onRefresh: _load,
              children: [
                if (_saving) const LinearProgressIndicator(),
                if (jobs.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: Insets.xl),
                    child: EmptyState(
                      icon: Icons.schedule,
                      title: 'No cron jobs yet',
                      message: 'Run scripts on a schedule, e.g. a nightly backup or a script at startup.',
                    ),
                  )
                else
                  ResponsiveGrid(
                    minItemWidth: 380,
                    maxColumns: 2,
                    children: [for (final j in jobs) _JobCard(job: j, onTap: () => _jobMenu(j))],
                  ),
                if (_crontab!.systemFiles.isNotEmpty) ...[
                  const SectionHeader(title: 'System cron files', subtitle: 'Read only'),
                  TileGroup(
                    children: [
                      for (final f in _crontab!.systemFiles)
                        if (!f.path.endsWith('.placeholder'))
                          ActionTile(
                            icon: Icons.description_outlined,
                            tone: Tone.neutral,
                            title: f.path,
                            subtitle: '${CrontabDocument.parse(f.content).jobs.length} entries',
                            onTap: () => showOutputDialog(context, title: f.path, output: f.content),
                          ),
                    ],
                  ),
                ],
              ],
            ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final CronJob job;
  final VoidCallback onTap;

  const _JobCard({required this.job, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final schedule = job.parsed;
    final next = job.enabled ? schedule?.nextRuns(count: 1) : null;
    final fmt = DateFormat('EEE d MMM, HH:mm');
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(
                schedule?.isReboot == true ? Icons.power_settings_new : Icons.schedule,
                tone: job.enabled ? Tone.primary : Tone.neutral,
              ),
              const Gap(Insets.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      schedule?.describe() ?? job.schedule,
                      style: context.tt.titleMedium?.copyWith(
                        color: job.enabled ? null : context.cs.onSurfaceVariant,
                      ),
                    ),
                    Text(job.schedule, style: AppTheme.mono(size: 12, color: context.cs.onSurfaceVariant)),
                  ],
                ),
              ),
              if (!job.enabled) const StatusPill('Disabled', tone: Tone.warning),
            ],
          ),
          if (job.comment.isNotEmpty) ...[
            const Gap(Insets.md),
            Text(job.comment, style: context.tt.bodyMedium),
          ],
          const Gap(Insets.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(Insets.sm),
            decoration: BoxDecoration(color: context.ac.codeBackground, borderRadius: Radii.smAll),
            child: Text(
              job.command,
              style: AppTheme.mono(size: 12, color: context.ac.codeForeground),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (next != null && next.isNotEmpty) ...[
            const Gap(Insets.sm),
            Text(
              'Next run ${fmt.format(next.first)}',
              style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}

enum _Preset { everyMinutes, hourly, daily, weekly, monthly, reboot, custom }

class _JobEditor extends StatefulWidget {
  final CronJob? job;

  const _JobEditor({this.job});

  @override
  State<_JobEditor> createState() => _JobEditorState();
}

class _JobEditorState extends State<_JobEditor> {
  late final _command = TextEditingController(text: widget.job?.command ?? '');
  late final _comment = TextEditingController(text: widget.job?.comment ?? '');
  late final _custom = TextEditingController(text: widget.job?.schedule ?? '0 3 * * *');
  late _Preset _preset = widget.job == null ? _Preset.daily : _Preset.custom;
  int _minutes = 5;
  TimeOfDay _time = const TimeOfDay(hour: 3, minute: 0);
  int _minute = 0;
  final Set<int> _weekdays = {1};
  int _dayOfMonth = 1;
  late bool _enabled = widget.job?.enabled ?? true;

  @override
  void dispose() {
    _command.dispose();
    _comment.dispose();
    _custom.dispose();
    super.dispose();
  }

  String get _schedule {
    final m = _time.minute, h = _time.hour;
    switch (_preset) {
      case _Preset.everyMinutes:
        return _minutes == 1 ? '* * * * *' : '*/$_minutes * * * *';
      case _Preset.hourly:
        return '$_minute * * * *';
      case _Preset.daily:
        return '$m $h * * *';
      case _Preset.weekly:
        final days = (_weekdays.isEmpty ? {1} : _weekdays).toList()..sort();
        return '$m $h * * ${days.join(',')}';
      case _Preset.monthly:
        return '$m $h $_dayOfMonth * *';
      case _Preset.reboot:
        return '@reboot';
      case _Preset.custom:
        return _custom.text.trim();
    }
  }

  @override
  Widget build(BuildContext context) {
    final schedule = CronSchedule.tryParse(_schedule);
    final next = schedule?.nextRuns(count: 3) ?? const <DateTime>[];
    final fmt = DateFormat('EEE d MMM yyyy, HH:mm');
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.job == null ? 'New cron job' : 'Edit cron job'),
        actions: [
          TextButton(
            onPressed: schedule == null || _command.text.trim().isEmpty
                ? null
                : () => Navigator.pop(
                    context,
                    CronJob(
                      schedule: _schedule,
                      command: _command.text.trim(),
                      comment: _comment.text.trim(),
                      enabled: _enabled,
                    ),
                  ),
            child: const Text('Save'),
          ),
          const Gap(Insets.sm),
        ],
      ),
      body: ContentWidth(
        maxWidth: 680,
        child: ListView(
          padding: const EdgeInsets.all(Insets.page),
          children: [
            TextField(
              controller: _command,
              autocorrect: false,
              enableSuggestions: false,
              minLines: 1,
              maxLines: 4,
              style: AppTheme.mono(size: 13, color: context.cs.onSurface),
              decoration: const InputDecoration(
                labelText: 'Command',
                hintText: '/home/pi/backup.sh >> /home/pi/backup.log 2>&1',
                prefixIcon: Icon(Icons.terminal),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const Gap(Insets.md),
            TextField(
              controller: _comment,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Nightly backup',
                prefixIcon: Icon(Icons.notes),
              ),
            ),
            const SectionHeader(title: 'When'),
            Wrap(
              spacing: Insets.sm,
              runSpacing: Insets.sm,
              children: [
                for (final p in [
                  (_Preset.everyMinutes, 'Every N minutes'),
                  (_Preset.hourly, 'Hourly'),
                  (_Preset.daily, 'Daily'),
                  (_Preset.weekly, 'Weekly'),
                  (_Preset.monthly, 'Monthly'),
                  (_Preset.reboot, 'At startup'),
                  (_Preset.custom, 'Custom'),
                ])
                  ChoiceChip(
                    label: Text(p.$2),
                    selected: _preset == p.$1,
                    onSelected: (_) => setState(() {
                      if (p.$1 == _Preset.custom && _preset != _Preset.custom) _custom.text = _schedule;
                      _preset = p.$1;
                    }),
                  ),
              ],
            ),
            const Gap(Insets.lg),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_preset == _Preset.everyMinutes)
                    SliderSettingTile(
                      icon: Icons.timer_outlined,
                      title: 'Every',
                      value: _minutes.toDouble(),
                      min: 1,
                      max: 30,
                      divisions: 29,
                      format: (v) => '${v.round()} min',
                      onChanged: (v) => setState(() => _minutes = v.round()),
                    ),
                  if (_preset == _Preset.hourly)
                    SliderSettingTile(
                      icon: Icons.timer_outlined,
                      title: 'At minute',
                      value: _minute.toDouble(),
                      min: 0,
                      max: 59,
                      divisions: 59,
                      format: (v) => ':${v.round().toString().padLeft(2, '0')}',
                      onChanged: (v) => setState(() => _minute = v.round()),
                    ),
                  if (_preset == _Preset.weekly) ...[
                    Text('On', style: context.tt.labelLarge),
                    const Gap(Insets.sm),
                    Wrap(
                      spacing: Insets.xs,
                      children: [
                        for (var d = 1; d <= 7; d++)
                          FilterChip(
                            label: Text(days[d % 7]),
                            selected: _weekdays.contains(d % 7),
                            onSelected: (v) => setState(() => v ? _weekdays.add(d % 7) : _weekdays.remove(d % 7)),
                          ),
                      ],
                    ),
                    const Gap(Insets.md),
                  ],
                  if (_preset == _Preset.monthly)
                    SliderSettingTile(
                      icon: Icons.calendar_month_outlined,
                      title: 'On day',
                      value: _dayOfMonth.toDouble(),
                      min: 1,
                      max: 28,
                      divisions: 27,
                      format: (v) => '${v.round()}.',
                      onChanged: (v) => setState(() => _dayOfMonth = v.round()),
                    ),
                  if (_preset == _Preset.daily || _preset == _Preset.weekly || _preset == _Preset.monthly)
                    ActionTile(
                      icon: Icons.access_time,
                      title: 'Time',
                      trailing: Text(
                        _time.format(context),
                        style: context.tt.titleMedium?.copyWith(color: context.cs.primary),
                      ),
                      onTap: () async {
                        final t = await showTimePicker(context: context, initialTime: _time);
                        if (t != null) setState(() => _time = t);
                      },
                    ),
                  if (_preset == _Preset.custom)
                    TextField(
                      controller: _custom,
                      autocorrect: false,
                      style: AppTheme.mono(size: 15, color: context.cs.onSurface),
                      decoration: InputDecoration(
                        labelText: 'Schedule',
                        helperText: 'minute hour day-of-month month day-of-week, e.g. */10 6-22 * * 1-5',
                        helperMaxLines: 2,
                        errorText: schedule == null ? 'Not a valid schedule' : null,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  if (_preset == _Preset.reboot)
                    Text(
                      'Runs once every time the device boots.',
                      style: context.tt.bodyMedium?.copyWith(color: context.cs.onSurfaceVariant),
                    ),
                ],
              ),
            ),
            const Gap(Insets.lg),
            AppCard(
              variant: CardVariant.raised,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(schedule?.describe() ?? 'Invalid schedule', style: context.tt.titleMedium),
                  Text(_schedule, style: AppTheme.mono(size: 13, color: context.cs.onSurfaceVariant)),
                  if (next.isNotEmpty) ...[
                    const Gap(Insets.md),
                    Text('Next runs', style: context.tt.labelLarge),
                    for (final n in next)
                      Text(fmt.format(n), style: context.tt.bodyMedium?.copyWith(fontFeatures: tabularFigures)),
                  ],
                ],
              ),
            ),
            const Gap(Insets.md),
            SwitchListTile(
              title: const Text('Enabled'),
              value: _enabled,
              onChanged: (v) => setState(() => _enabled = v),
            ),
            const Gap(Insets.xxl),
          ],
        ),
      ),
    );
  }
}

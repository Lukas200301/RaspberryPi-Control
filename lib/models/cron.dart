/// Crontab parsing, editing and schedule helpers.
///
/// A crontab is kept as a list of lines so that comments, environment
/// variables and anything the app does not understand survive a save.
library;

const _months = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec'];
const _days = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat'];
const _dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

const _specials = {
  '@reboot': 'At startup',
  '@yearly': 'Once a year (Jan 1, 00:00)',
  '@annually': 'Once a year (Jan 1, 00:00)',
  '@monthly': 'Once a month (1st, 00:00)',
  '@weekly': 'Once a week (Sunday, 00:00)',
  '@daily': 'Every day at 00:00',
  '@midnight': 'Every day at 00:00',
  '@hourly': 'Every hour',
};

const _specialExpressions = {
  '@yearly': '0 0 1 1 *',
  '@annually': '0 0 1 1 *',
  '@monthly': '0 0 1 * *',
  '@weekly': '0 0 * * 0',
  '@daily': '0 0 * * *',
  '@midnight': '0 0 * * *',
  '@hourly': '0 * * * *',
};

/// One cron schedule, e.g. "*/5 * * * *" or "@daily"
class CronSchedule {
  final String expression;
  final List<Set<int>>? _fields;
  final bool _domRestricted;
  final bool _dowRestricted;

  CronSchedule._(this.expression, this._fields, this._domRestricted, this._dowRestricted);

  /// Returns null when [expression] is not a valid schedule
  static CronSchedule? tryParse(String expression) {
    final e = expression.trim().toLowerCase();
    if (e == '@reboot') return CronSchedule._(e, null, false, false);
    final normalized = _specialExpressions[e] ?? e;
    final parts = normalized.split(RegExp(r'\s+'));
    if (parts.length != 5) return null;
    const ranges = [(0, 59), (0, 23), (1, 31), (1, 12), (0, 7)];
    final fields = <Set<int>>[];
    for (var i = 0; i < 5; i++) {
      final set = _parseField(parts[i], ranges[i].$1, ranges[i].$2, i == 3 ? _months : i == 4 ? _days : null);
      if (set == null) return null;
      if (i == 4 && set.remove(7)) set.add(0);
      fields.add(set);
    }
    return CronSchedule._(e, fields, parts[2] != '*', parts[4] != '*');
  }

  static Set<int>? _parseField(String field, int min, int max, List<String>? names) {
    final result = <int>{};
    for (final part in field.split(',')) {
      var range = part;
      var step = 1;
      final slash = part.indexOf('/');
      if (slash >= 0) {
        step = int.tryParse(part.substring(slash + 1)) ?? 0;
        if (step <= 0) return null;
        range = part.substring(0, slash);
      }
      int? value(String s) {
        final n = int.tryParse(s);
        if (n != null) return n;
        if (names != null) {
          final i = names.indexOf(s);
          if (i >= 0) return names == _months ? i + 1 : i;
        }
        return null;
      }

      int lo, hi;
      if (range == '*') {
        lo = min;
        hi = max;
      } else if (range.contains('-')) {
        final ends = range.split('-');
        if (ends.length != 2) return null;
        final a = value(ends[0]), b = value(ends[1]);
        if (a == null || b == null || a > b) return null;
        lo = a;
        hi = b;
      } else {
        final v = value(range);
        if (v == null) return null;
        lo = v;
        hi = slash >= 0 ? max : v;
      }
      if (lo < min || hi > max) return null;
      for (var v = lo; v <= hi; v += step) {
        result.add(v);
      }
    }
    return result;
  }

  bool get isReboot => _fields == null;

  bool _matches(DateTime t) {
    final f = _fields!;
    if (!f[0].contains(t.minute) || !f[1].contains(t.hour) || !f[3].contains(t.month)) return false;
    final dom = f[2].contains(t.day);
    final dow = f[4].contains(t.weekday % 7);
    // cron: when both day fields are restricted, either may match
    if (_domRestricted && _dowRestricted) return dom || dow;
    if (_domRestricted) return dom;
    if (_dowRestricted) return dow;
    return true;
  }

  /// The next [count] run times after [from] (empty for @reboot)
  List<DateTime> nextRuns({DateTime? from, int count = 3}) {
    if (isReboot) return const [];
    final runs = <DateTime>[];
    final start = from ?? DateTime.now();
    var t = DateTime(start.year, start.month, start.day, start.hour, start.minute).add(const Duration(minutes: 1));
    // Search at most ~4 years minute by minute, skipping whole hours and days that cannot match
    final limit = t.add(const Duration(days: 366 * 4));
    while (runs.length < count && t.isBefore(limit)) {
      final f = _fields!;
      if (!f[3].contains(t.month)) {
        t = DateTime(t.year, t.month + 1);
        continue;
      }
      if (!f[1].contains(t.hour)) {
        t = DateTime(t.year, t.month, t.day, t.hour + 1);
        continue;
      }
      if (_matches(t)) runs.add(t);
      t = t.add(const Duration(minutes: 1));
    }
    return runs;
  }

  /// A sentence like "Every day at 03:00"
  String describe() {
    final special = _specials[expression];
    if (special != null) return special;
    final p = expression.split(RegExp(r'\s+'));
    final m = p[0], h = p[1], dom = p[2], mon = p[3], dow = p[4];
    String two(String s) => s.padLeft(2, '0');
    final simpleMinute = int.tryParse(m) != null;
    final simpleHour = int.tryParse(h) != null;
    final at = simpleMinute && simpleHour ? 'at ${two(h)}:${two(m)}' : null;

    if (m == '*' && h == '*' && dom == '*' && mon == '*' && dow == '*') return 'Every minute';
    if (m.startsWith('*/') && h == '*' && dom == '*' && mon == '*' && dow == '*') {
      return 'Every ${m.substring(2)} minutes';
    }
    if (simpleMinute && h == '*' && dom == '*' && mon == '*' && dow == '*') {
      return 'Every hour at minute $m';
    }
    if (simpleMinute && h.startsWith('*/') && dom == '*' && mon == '*' && dow == '*') {
      return 'Every ${h.substring(2)} hours at minute $m';
    }
    if (at != null && dom == '*' && mon == '*') {
      if (dow == '*') return 'Every day $at';
      if (dow == '1-5' || dow == 'mon-fri') return 'Weekdays $at';
      if (dow == '0,6' || dow == '6,0' || dow == 'sat,sun') return 'Weekends $at';
      final days = _fields![4].toList()..sort();
      return 'Every ${days.map((d) => _dayNames[d]).join(', ')} $at';
    }
    if (at != null && int.tryParse(dom) != null && mon == '*' && dow == '*') {
      return 'Monthly on day $dom $at';
    }
    if (at != null && int.tryParse(dom) != null && int.tryParse(mon) != null && dow == '*') {
      return 'Every year on $dom.$mon. $at';
    }
    return 'Custom schedule';
  }
}

/// A line of a crontab: either a job or anything else, kept verbatim
sealed class CronLine {
  const CronLine();
  String render();
}

class RawCronLine extends CronLine {
  final String text;

  const RawCronLine(this.text);

  @override
  String render() => text;
}

class CronJob extends CronLine {
  final String schedule;
  final String command;
  final bool enabled;

  /// Comment line directly above the job
  final String comment;

  const CronJob({
    required this.schedule,
    required this.command,
    this.enabled = true,
    this.comment = '',
  });

  CronSchedule? get parsed => CronSchedule.tryParse(schedule);

  CronJob copyWith({String? schedule, String? command, bool? enabled, String? comment}) => CronJob(
    schedule: schedule ?? this.schedule,
    command: command ?? this.command,
    enabled: enabled ?? this.enabled,
    comment: comment ?? this.comment,
  );

  @override
  String render() {
    final line = '$schedule $command';
    final job = enabled ? line : '#$line';
    return comment.isEmpty ? job : '# $comment\n$job';
  }

  /// Parses a "schedule command" line; null when the line is not a job
  static CronJob? tryParseLine(String line, {bool enabled = true, String comment = ''}) {
    final t = line.trim();
    if (t.isEmpty) return null;
    if (t.startsWith('@')) {
      final i = t.indexOf(RegExp(r'\s'));
      if (i < 0) return null;
      final schedule = t.substring(0, i);
      if (CronSchedule.tryParse(schedule) == null) return null;
      return CronJob(schedule: schedule, command: t.substring(i).trim(), enabled: enabled, comment: comment);
    }
    final parts = t.split(RegExp(r'\s+'));
    if (parts.length < 6) return null;
    final schedule = parts.take(5).join(' ');
    if (CronSchedule.tryParse(schedule) == null) return null;
    final command = t.replaceFirst(RegExp(r'^(\S+\s+){5}'), '');
    return CronJob(schedule: schedule, command: command, enabled: enabled, comment: comment);
  }
}

class CrontabDocument {
  final List<CronLine> lines;

  const CrontabDocument(this.lines);

  List<CronJob> get jobs => lines.whereType<CronJob>().toList();

  static CrontabDocument parse(String content) {
    final raw = content.replaceAll('\r\n', '\n').split('\n');
    if (raw.isNotEmpty && raw.last.isEmpty) raw.removeLast();
    final lines = <CronLine>[];
    for (var i = 0; i < raw.length; i++) {
      final text = raw[i];
      final trimmed = text.trim();
      if (trimmed.startsWith('#')) {
        // A commented-out job is a disabled job
        final disabled = CronJob.tryParseLine(trimmed.substring(1), enabled: false);
        if (disabled != null) {
          lines.add(disabled);
          continue;
        }
        // A comment directly above a job describes it
        if (i + 1 < raw.length) {
          final next = raw[i + 1].trim();
          final comment = trimmed.replaceFirst(RegExp(r'^#+\s?'), '');
          final enabledJob = CronJob.tryParseLine(next, comment: comment);
          final disabledJob = next.startsWith('#')
              ? CronJob.tryParseLine(next.substring(1), enabled: false, comment: comment)
              : null;
          if ((enabledJob ?? disabledJob) != null && !comment.toLowerCase().startsWith('m h ')) {
            lines.add((enabledJob ?? disabledJob)!);
            i++;
            continue;
          }
        }
        lines.add(RawCronLine(text));
        continue;
      }
      lines.add(CronJob.tryParseLine(text) ?? RawCronLine(text));
    }
    return CrontabDocument(lines);
  }

  String render() {
    final text = lines.map((l) => l.render()).join('\n');
    return text.isEmpty ? '' : '$text\n';
  }

  CrontabDocument replace(CronJob old, CronJob? replacement) {
    final i = lines.indexOf(old);
    if (i < 0) return this;
    final next = [...lines];
    if (replacement == null) {
      next.removeAt(i);
    } else {
      next[i] = replacement;
    }
    return CrontabDocument(next);
  }

  CrontabDocument add(CronJob job) => CrontabDocument([...lines, job]);
}

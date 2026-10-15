import 'package:flutter_test/flutter_test.dart';
import 'package:raspberrypi_control/models/cron.dart';

void main() {
  group('CronSchedule', () {
    test('rejects invalid schedules', () {
      expect(CronSchedule.tryParse('* * * *'), isNull);
      expect(CronSchedule.tryParse('60 * * * *'), isNull);
      expect(CronSchedule.tryParse('*/0 * * * *'), isNull);
      expect(CronSchedule.tryParse('5-2 * * * *'), isNull);
      expect(CronSchedule.tryParse('@sometimes'), isNull);
    });

    test('describes common schedules', () {
      String d(String e) => CronSchedule.tryParse(e)!.describe();
      expect(d('* * * * *'), 'Every minute');
      expect(d('*/5 * * * *'), 'Every 5 minutes');
      expect(d('15 * * * *'), 'Every hour at minute 15');
      expect(d('0 */6 * * *'), 'Every 6 hours at minute 0');
      expect(d('30 3 * * *'), 'Every day at 03:30');
      expect(d('0 8 * * 1-5'), 'Weekdays at 08:00');
      expect(d('0 9 * * mon,wed'), 'Every Monday, Wednesday at 09:00');
      expect(d('0 4 1 * *'), 'Monthly on day 1 at 04:00');
      expect(d('@reboot'), 'At startup');
      expect(d('@daily'), 'Every day at 00:00');
    });

    test('computes next runs', () {
      final from = DateTime(2026, 10, 14, 10, 7);
      expect(CronSchedule.tryParse('*/15 * * * *')!.nextRuns(from: from), [
        DateTime(2026, 10, 14, 10, 15),
        DateTime(2026, 10, 14, 10, 30),
        DateTime(2026, 10, 14, 10, 45),
      ]);
      expect(CronSchedule.tryParse('30 3 * * *')!.nextRuns(from: from, count: 1), [DateTime(2026, 10, 15, 3, 30)]);
      // 2026-10-14 is a Wednesday; next Sunday is the 18th
      expect(CronSchedule.tryParse('0 0 * * 0')!.nextRuns(from: from, count: 1), [DateTime(2026, 10, 18)]);
      expect(CronSchedule.tryParse('0 0 * * 7')!.nextRuns(from: from, count: 1), [DateTime(2026, 10, 18)]);
      expect(CronSchedule.tryParse('0 12 29 2 *')!.nextRuns(from: from, count: 1), [DateTime(2028, 2, 29, 12)]);
      expect(CronSchedule.tryParse('@reboot')!.nextRuns(from: from), isEmpty);
    });

    test('day of month and day of week combine with OR', () {
      final runs = CronSchedule.tryParse('0 0 1 * 1')!.nextRuns(from: DateTime(2026, 10, 14), count: 3);
      // Monday 19th, Monday 26th, then the 1st of November
      expect(runs, [DateTime(2026, 10, 19), DateTime(2026, 10, 26), DateTime(2026, 11, 1)]);
    });
  });

  group('CrontabDocument', () {
    const content = '''# Edit this file to introduce tasks to be run by cron.
# m h  dom mon dow   command
SHELL=/bin/bash
MAILTO=""

# Backup the database
0 3 * * * /home/pi/backup.sh >> /var/log/backup.log 2>&1
#*/10 * * * * /home/pi/disabled.sh
@reboot /home/pi/start.sh
not a cron line
''';

    test('parses jobs and keeps everything else', () {
      final doc = CrontabDocument.parse(content);
      final jobs = doc.jobs;
      expect(jobs, hasLength(3));
      expect(jobs[0].schedule, '0 3 * * *');
      expect(jobs[0].command, '/home/pi/backup.sh >> /var/log/backup.log 2>&1');
      expect(jobs[0].comment, 'Backup the database');
      expect(jobs[1].enabled, isFalse);
      expect(jobs[1].command, '/home/pi/disabled.sh');
      expect(jobs[2].schedule, '@reboot');
      expect(doc.lines.whereType<RawCronLine>().map((l) => l.text), contains('not a cron line'));
    });

    test('renders back to the same text', () {
      expect(CrontabDocument.parse(content).render(), content);
    });

    test('edits jobs in place', () {
      final doc = CrontabDocument.parse(content);
      final backup = doc.jobs.first;
      final edited = doc.replace(backup, backup.copyWith(enabled: false)).render();
      expect(edited, contains('# Backup the database\n#0 3 * * * /home/pi/backup.sh'));
      final removed = doc.replace(backup, null).render();
      expect(removed, isNot(contains('backup.sh')));
      expect(removed, contains('SHELL=/bin/bash'));
      final added = doc.add(const CronJob(schedule: '*/5 * * * *', command: 'date', comment: 'Clock')).render();
      expect(added, endsWith('# Clock\n*/5 * * * * date\n'));
    });
  });
}

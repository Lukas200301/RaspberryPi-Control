import 'package:flutter_test/flutter_test.dart';
import 'package:raspberrypi_control/models/alerts.dart';
import 'package:raspberrypi_control/services/alert_engine.dart';
import 'package:raspberrypi_control/services/device_probe.dart';

const rules = AlertRules(enabled: true, offlineChecks: 2);
final t0 = DateTime(2026, 10, 14, 12);

DeviceSnapshot snap({
  double load = 0.2,
  int memUsedPercent = 30,
  double temp = 50,
  int uptime = 1000,
  List<String> failed = const [],
  Map<String, String>? pm2,
  Map<String, String>? containers,
}) => DeviceSnapshot(
  load1: load,
  cpus: 4,
  memTotalKb: 1000,
  memAvailableKb: 1000 - memUsedPercent * 10,
  tempC: temp,
  uptimeSeconds: uptime,
  diskUsedKb: 10,
  diskTotalKb: 100,
  failedUnits: failed,
  pm2: pm2,
  containers: containers,
);

/// Runs checks in order and returns every event plus the final state
(List<AlertEvent>, DeviceAlertState) run(List<ProbeResult> checks, {AlertRules r = rules}) {
  var state = const DeviceAlertState();
  final events = <AlertEvent>[];
  for (final c in checks) {
    final e = evaluateAlerts(deviceId: 'd1', deviceName: 'pi', previous: state, result: c, rules: r);
    state = e.state;
    events.addAll(e.events);
  }
  return (events, state);
}

ProbeResult ok(int minute, DeviceSnapshot s) =>
    ProbeResult(reachable: true, snapshot: s, time: t0.add(Duration(minutes: minute)));
ProbeResult down(int minute) => ProbeResult(reachable: false, time: t0.add(Duration(minutes: minute)));

void main() {
  test('offline after the configured number of failed checks, then resolved', () {
    final (events, state) = run([ok(0, snap()), down(1), down(2), down(3), ok(4, snap())]);
    expect(events.map((e) => (e.kind, e.resolved)), [(AlertKind.offline, false), (AlertKind.offline, true)]);
    expect(events.first.time, t0.add(const Duration(minutes: 2)));
    expect(state.active, isEmpty);
    expect(state.failures, 0);
  });

  test('a threshold alerts once and resolves with hysteresis', () {
    final (events, state) = run([
      ok(0, snap(temp: 82)),
      ok(1, snap(temp: 85)),
      ok(2, snap(temp: 78)), // below the limit but inside the margin
      ok(3, snap(temp: 70)),
    ]);
    expect(events.map((e) => (e.kind, e.resolved)), [(AlertKind.temperature, false), (AlertKind.temperature, true)]);
    expect(state.active, isEmpty);
  });

  test('memory severity and load threshold', () {
    final (events, _) = run([ok(0, snap(memUsedPercent: 98, load: 4.0))]);
    final memory = events.firstWhere((e) => e.kind == AlertKind.memory);
    expect(memory.severity, AlertSeverity.critical);
    expect(events.any((e) => e.kind == AlertKind.load), isTrue);
  });

  test('failed units alert per unit', () {
    final (events, state) = run([
      ok(0, snap(failed: ['nginx.service'])),
      ok(1, snap(failed: ['nginx.service', 'cron.service'])),
      ok(2, snap(failed: ['cron.service'])),
    ]);
    expect(events.map((e) => (e.subject, e.resolved)), [
      ('nginx.service', false),
      ('cron.service', false),
      ('nginx.service', true),
    ]);
    expect(state.active.keys, ['service:cron.service']);
  });

  test('PM2 errored apps alert; unknown PM2 state keeps alerts', () {
    final (events, state) = run([
      ok(0, snap(pm2: {'api': 'errored', 'web': 'online'})),
      ok(1, snap()), // PM2 not reachable this time: no change
    ]);
    expect(events.map((e) => e.subject), ['api']);
    expect(state.active.keys, ['pm2:api']);
  });

  test('containers: stopping after running alerts, never-running does not', () {
    final (events, _) = run([
      ok(0, snap(containers: {'db': 'running', 'old': 'exited'})),
      ok(1, snap(containers: {'db': 'exited', 'old': 'exited'})),
      ok(2, snap(containers: {'db': 'exited', 'old': 'exited'})),
      ok(3, snap(containers: {'db': 'running', 'old': 'exited'})),
    ]);
    expect(events.map((e) => (e.subject, e.resolved)), [('db', false), ('db', true)]);
  });

  test('unhealthy container alerts', () {
    final (events, _) = run([ok(0, snap(containers: {'web': 'unhealthy'}))]);
    expect(events.single.kind, AlertKind.container);
  });

  test('reboot is detected from uptime going backwards', () {
    final (events, _) = run([ok(0, snap(uptime: 5000)), ok(1, snap(uptime: 40))]);
    expect(events.single.kind, AlertKind.reboot);
  });

  test('disabled rules raise nothing and end active alerts silently', () {
    var (events, state) = run([ok(0, snap(temp: 90))]);
    expect(events, hasLength(1));
    final off = rules.copyWith(temperature: false);
    final next = evaluateAlerts(
      deviceId: 'd1',
      deviceName: 'pi',
      previous: state,
      result: ok(1, snap(temp: 95)),
      rules: off,
    );
    expect(next.events, isEmpty);
    expect(next.state.active, isEmpty);
  });

  test('state survives a JSON round trip', () {
    final (_, state) = run([ok(0, snap(temp: 90, containers: {'db': 'running'}))]);
    final copy = DeviceAlertState.fromJson(state.toJson());
    expect(copy.active.keys, state.active.keys);
    expect(copy.runningContainers, {'db'});
    expect(copy.lastUptime, 1000);
  });

  test('snapshot parses services, PM2 and Docker lines', () {
    final s = DeviceSnapshot.parse('''
LOAD 0.5
CPUS 4
FAILED nginx.service
PM2 online api server
PM2 errored worker
PM2_OK
DOCKER running|Up 2 hours (unhealthy)|web
DOCKER exited|Exited (0) 3 days ago|old
DOCKER_OK
''');
    expect(s.failedUnits, ['nginx.service']);
    expect(s.pm2, {'api server': 'online', 'worker': 'errored'});
    expect(s.containers, {'web': 'unhealthy', 'old': 'exited'});
    expect(DeviceSnapshot.parse('LOAD 1').pm2, isNull);
  });
}

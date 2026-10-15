import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grpc/grpc.dart';
import '../generated/pi_control.pbgrpc.dart';
import '../providers/app_providers.dart';
import '../providers/settings_provider.dart';
import 'grpc_service.dart';

final pm2ServiceProvider = Provider<Pm2Service>((ref) {
  ref.watch(grpcSessionProvider);
  return Pm2Service(ref.watch(grpcServiceProvider));
});

final pm2InfoProvider = FutureProvider.autoDispose<Pm2Info>((ref) async {
  return ref.watch(pm2ServiceProvider).getInfo();
});

/// PM2 process list (apps and modules), refreshed every few seconds while
/// something is listening.
final pm2ProcessesProvider =
    AsyncNotifierProvider.autoDispose<Pm2ProcessesNotifier, List<Pm2Process>>(
      Pm2ProcessesNotifier.new,
    );

class Pm2ProcessesNotifier extends AutoDisposeAsyncNotifier<List<Pm2Process>> {
  Timer? _timer;
  bool _refreshing = false;

  @override
  Future<List<Pm2Process>> build() async {
    final seconds = ref.watch(settingsProvider.select((s) => s.refreshSeconds));
    final service = ref.watch(pm2ServiceProvider);
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: seconds.clamp(1, 60)), (_) => refresh());
    ref.onDispose(() => _timer?.cancel());
    return service.listProcesses();
  }

  /// Reload the list without showing a loading state. Keeps the last list
  /// when a refresh fails.
  Future<void> refresh() async {
    if (_refreshing) return;
    _refreshing = true;
    try {
      final processes = await ref.read(pm2ServiceProvider).listProcesses();
      state = AsyncData(processes);
    } catch (e, st) {
      if (!state.hasValue) state = AsyncError(e, st);
    } finally {
      _refreshing = false;
    }
  }
}

/// Talks to the Pm2Service of the agent. The channel is looked up per call,
/// so a reconnect never leaves a stale client behind.
class Pm2Service {
  final GrpcService _grpc;

  Pm2Service(this._grpc);

  Pm2ServiceClient get _client {
    final channel = _grpc.channel;
    if (channel == null) {
      throw const Pm2Exception('Not connected to the agent');
    }
    return Pm2ServiceClient(channel);
  }

  static CallOptions _timeout(Duration d) => CallOptions(timeout: d);

  Future<Pm2Info> getInfo() => _guard(
    () => _client.getPm2Info(
      Empty(),
      options: _timeout(const Duration(seconds: 60)),
    ),
  );

  Future<List<Pm2Process>> listProcesses() => _guard(() async {
    final response = await _client.listPm2Processes(
      Empty(),
      options: _timeout(const Duration(seconds: 60)),
    );
    return response.processes;
  });

  Future<Pm2ProcessDetails> describe(String target) => _guard(
    () => _client.describePm2Process(
      Pm2Target()..target = target,
      options: _timeout(const Duration(seconds: 60)),
    ),
  );

  Future<Pm2CommandResult> start(Pm2StartRequest request) => _guard(
    () => _client.startPm2Process(
      request,
      options: _timeout(const Duration(minutes: 3)),
    ),
  );

  Future<Pm2CommandResult> control(
    Pm2Action action,
    String target, {
    bool updateEnv = false,
    String envName = '',
    String only = '',
    String value = '',
    String actionName = '',
    String actionParam = '',
  }) => _guard(
    () => _client.controlPm2Process(
      Pm2ControlRequest()
        ..action = action
        ..target = target
        ..updateEnv = updateEnv
        ..envName = envName
        ..only = only
        ..value = value
        ..actionName = actionName
        ..actionParam = actionParam,
      options: _timeout(const Duration(minutes: 3)),
    ),
  );

  Stream<Pm2LogLine> streamLogs({
    String target = 'all',
    int lines = 100,
    bool follow = true,
    bool includeOut = true,
    bool includeErr = true,
    bool includeDaemon = false,
  }) {
    final request = Pm2LogRequest()
      ..target = target
      ..lines = lines
      ..follow = follow
      ..includeOut = includeOut
      ..includeErr = includeErr
      ..includeDaemon = includeDaemon;
    return _guardStream(() => _client.streamPm2Logs(request));
  }

  Stream<Pm2OutputLine> runOperation(Pm2OperationRequest request) =>
      _guardStream(() => _client.runPm2Operation(request));

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } catch (e) {
      throw Pm2Exception.from(e);
    }
  }

  Stream<T> _guardStream<T>(Stream<T> Function() call) async* {
    try {
      yield* call();
    } catch (e) {
      throw Pm2Exception.from(e);
    }
  }
}

class Pm2Exception implements Exception {
  final String message;

  /// The agent on the Pi predates PM2 support
  final bool agentOutdated;

  /// PM2 is not installed for the agent user
  final bool notInstalled;

  /// The requested process does not exist (anymore)
  final bool notFound;

  const Pm2Exception(
    this.message, {
    this.agentOutdated = false,
    this.notInstalled = false,
    this.notFound = false,
  });

  factory Pm2Exception.from(Object error) {
    if (error is Pm2Exception) return error;
    if (error is GrpcError) {
      switch (error.code) {
        case StatusCode.unimplemented:
          return const Pm2Exception(
            'The agent on your Pi does not support PM2 yet. Update the agent to use PM2.',
            agentOutdated: true,
          );
        case StatusCode.failedPrecondition:
          return Pm2Exception(
            error.message ?? 'PM2 is not installed',
            notInstalled: true,
          );
        case StatusCode.notFound:
          return Pm2Exception(error.message ?? 'Not found', notFound: true);
        case StatusCode.unavailable:
          return const Pm2Exception(
            'The agent is not reachable. Check the connection.',
          );
        case StatusCode.deadlineExceeded:
          return const Pm2Exception('PM2 did not respond in time.');
        default:
          return Pm2Exception(error.message ?? error.toString());
      }
    }
    return Pm2Exception(error.toString());
  }

  @override
  String toString() => message;
}

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grpc/grpc.dart';
import '../generated/pi_control.pbgrpc.dart';
import '../providers/app_providers.dart';
import '../providers/settings_provider.dart';

final dockerServiceProvider = Provider<DockerService>((ref) {
  final grpcService = ref.watch(grpcServiceProvider);
  ref.watch(grpcSessionProvider);
  final channel = grpcService.channel;
  if (channel == null) {
    throw Exception('gRPC channel not initialized');
  }
  return DockerService(channel);
});

/// Every container, refreshed on the configured interval
final containerListProvider = FutureProvider.autoDispose<List<ContainerInfo>>((ref) async {
  final service = ref.watch(dockerServiceProvider);
  final seconds = ref.watch(settingsProvider.select((s) => s.refreshSeconds)).clamp(2, 60);
  final timer = Timer(Duration(seconds: seconds), ref.invalidateSelf);
  ref.onDispose(timer.cancel);
  return service.listContainers(all: true);
});

final dockerInfoProvider = FutureProvider.autoDispose<DockerInfo>((ref) {
  return ref.watch(dockerServiceProvider).info();
});

final dockerImagesProvider = FutureProvider.autoDispose<List<DockerImage>>((ref) {
  return ref.watch(dockerServiceProvider).listImages();
});

final containerDetailsProvider = FutureProvider.autoDispose.family<ContainerDetails, String>((ref, id) {
  return ref.watch(dockerServiceProvider).inspect(id);
});

/// Resource usage of a running container, sampled every few seconds
final containerStatsProvider = StreamProvider.autoDispose.family<ContainerStats, String>((ref, id) async* {
  final service = ref.watch(dockerServiceProvider);
  while (true) {
    yield await service.stats(id);
    await Future<void>.delayed(const Duration(seconds: 3));
  }
});

class DockerService {
  final ClientChannel _channel;
  late final DockerServiceClient _client;

  DockerService(this._channel) {
    _client = DockerServiceClient(_channel);
  }

  /// Turns "Unimplemented" into a hint that the agent needs an update
  Future<T> _call<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on GrpcError catch (e) {
      if (e.code == StatusCode.unimplemented) {
        throw Exception('The agent on this device is too old for this. Update it under Settings > Agent.');
      }
      throw Exception(e.message ?? e.toString());
    }
  }

  void _check(ActionStatus r) {
    if (!r.success) throw Exception(r.message);
  }

  Future<List<ContainerInfo>> listContainers({bool all = false}) =>
      _call(() async => (await _client.listContainers(DockerFilter()..all = all)).containers);

  Future<void> startContainer(String id) => _call(() async => _check(await _client.startContainer(ContainerId()..id = id)));

  Future<void> stopContainer(String id) => _call(() async => _check(await _client.stopContainer(ContainerId()..id = id)));

  Future<void> restartContainer(String id) =>
      _call(() async => _check(await _client.restartContainer(ContainerId()..id = id)));

  Future<void> containerAction(String id, ContainerOp op, {bool force = false, bool removeVolumes = false}) =>
      _call(() async => _check(await _client.containerAction(
        ContainerActionRequest()
          ..id = id
          ..op = op
          ..force = force
          ..removeVolumes = removeVolumes,
      )));

  Future<DockerInfo> info() => _call(() => _client.getDockerInfo(Empty()));

  Future<ContainerDetails> inspect(String id) => _call(() => _client.inspectContainer(ContainerId()..id = id));

  Future<ContainerStats> stats(String id) => _call(() => _client.getContainerStats(ContainerId()..id = id));

  Future<List<DockerImage>> listImages() => _call(() async => (await _client.listImages(Empty())).images);

  Future<void> removeImage(String id, {bool force = false}) => _call(() async => _check(await _client.removeImage(
    ImageRemoveRequest()
      ..id = id
      ..force = force,
  )));

  Future<PruneResult> prune(PruneTarget target) => _call(() async {
    final r = await _client.prune(PruneRequest()..target = target);
    if (!r.success) throw Exception(r.message);
    return r;
  });

  Stream<LogEntry> getContainerLogs(String id, {bool follow = false, int tail = 100}) {
    final request = LogRequest()
      ..containerId = id
      ..follow = follow
      ..tail = tail;
    return _client.getContainerLogs(request);
  }
}

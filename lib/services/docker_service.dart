import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grpc/grpc.dart';
import '../generated/pi_control.pbgrpc.dart';
import '../providers/app_providers.dart';

final dockerServiceProvider = Provider<DockerService>((ref) {
  final grpcService = ref.watch(grpcServiceProvider);
  final channel = grpcService.channel;
  if (channel == null) {
    throw Exception('gRPC channel not initialized');
  }
  return DockerService(channel);
});

final containerListProvider = FutureProvider.autoDispose<List<ContainerInfo>>((ref) async {
  final service = ref.watch(dockerServiceProvider);
  return service.listContainers(all: true);
});

class DockerService {
  final ClientChannel _channel;
  late final DockerServiceClient _client;

  DockerService(this._channel) {
    _client = DockerServiceClient(_channel);
  }

  Future<List<ContainerInfo>> listContainers({bool all = false}) async {
    try {
      final request = DockerFilter()..all = all;
      final response = await _client.listContainers(request);
      return response.containers;
    } catch (e) {
      throw Exception('Failed to list containers: $e');
    }
  }

  Future<void> startContainer(String id) async {
    try {
      final request = ContainerId()..id = id;
      final response = await _client.startContainer(request);
      if (!response.success) {
        throw Exception(response.message);
      }
    } catch (e) {
      throw Exception('Failed to start container: $e');
    }
  }

  Future<void> stopContainer(String id) async {
    try {
      final request = ContainerId()..id = id;
      final response = await _client.stopContainer(request);
      if (!response.success) {
        throw Exception(response.message);
      }
    } catch (e) {
      throw Exception('Failed to stop container: $e');
    }
  }

  Future<void> restartContainer(String id) async {
    try {
      final request = ContainerId()..id = id;
      final response = await _client.restartContainer(request);
      if (!response.success) {
        throw Exception(response.message);
      }
    } catch (e) {
      throw Exception('Failed to restart container: $e');
    }
  }

  Stream<LogEntry> getContainerLogs(String id, {bool follow = false, int tail = 100}) {
    final request = LogRequest()
      ..containerId = id
      ..follow = follow
      ..tail = tail;
    
    return _client.getContainerLogs(request);
  }
}

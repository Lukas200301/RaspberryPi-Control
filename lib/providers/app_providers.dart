import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ssh_service.dart';
import '../services/storage_service.dart';
import '../services/agent_manager.dart';
import '../services/grpc_service.dart';
import '../services/grpc_file_transfer_service.dart';
import '../services/session_keepalive.dart';
import '../services/network_discovery_service.dart';
import '../services/connection_manager.dart';
import '../models/ssh_connection.dart';
import '../models/agent_info.dart';
import '../models/app_settings.dart';
import 'settings_provider.dart';

// Services
final storageServiceProvider = Provider((ref) => StorageService());

final sshServiceProvider = Provider((ref) {
  final service = SSHService();
  void apply(AppSettings s) {
    service.connectTimeout = Duration(seconds: s.connectTimeoutSeconds);
    service.keepAliveInterval = Duration(seconds: s.keepAliveSeconds);
  }

  apply(ref.read(settingsProvider));
  ref.listen(settingsProvider, (_, s) => apply(s));
  return service;
});

final agentManagerProvider = Provider((ref) {
  final sshService = ref.watch(sshServiceProvider);
  return AgentManager(sshService);
});

final grpcServiceProvider = Provider((ref) => GrpcService());

/// The current agent connection; everything that loads data from the device
/// watches it so a device switch or reconnect starts fresh
final grpcSessionProvider = Provider<int>((ref) {
  final session = ref.watch(grpcServiceProvider).session;
  void changed() => ref.invalidateSelf();
  session.addListener(changed);
  ref.onDispose(() => session.removeListener(changed));
  return session.value;
});

final grpcFileTransferServiceProvider = ChangeNotifierProvider((ref) {
  final grpcService = ref.watch(grpcServiceProvider);
  return GrpcFileTransferService(grpcService);
});

/// Keeps the session (and transfers) alive while the app is in the
/// background; watched by the app root so it lives as long as the app
final sessionKeepAliveProvider = Provider<SessionKeepAlive>((ref) {
  // .notifier: the instance only. Watching the ChangeNotifier itself would
  // rebuild (and restart the service) on every progress update.
  final keepAlive = SessionKeepAlive(ref.watch(grpcFileTransferServiceProvider.notifier));
  ref.listen(currentConnectionProvider, (_, device) => keepAlive.device = device?.name, fireImmediately: true);
  ref.onDispose(keepAlive.dispose);
  return keepAlive;
});

final networkDiscoveryServiceProvider = Provider(
  (ref) => NetworkDiscoveryService(),
);

// Connection Manager - Central connection orchestrator
final connectionManagerProvider = Provider((ref) {
  final sshService = ref.watch(sshServiceProvider);
  final grpcService = ref.watch(grpcServiceProvider);
  final agentManager = ref.watch(agentManagerProvider);
  return ConnectionManager(
    sshService: sshService,
    grpcService: grpcService,
    agentManager: agentManager,
  );
});

// Connection Manager State Stream
final connectionManagerStateProvider = StreamProvider<ConnectionManagerState>((
  ref,
) {
  final connectionManager = ref.watch(connectionManagerProvider);
  return connectionManager.stateStream;
});

// Connection State
final connectionListProvider =
    NotifierProvider<ConnectionListNotifier, List<SSHConnection>>(
      ConnectionListNotifier.new,
    );

class ConnectionListNotifier extends Notifier<List<SSHConnection>> {
  @override
  List<SSHConnection> build() {
    final storage = ref.watch(storageServiceProvider);
    return storage.getConnections();
  }

  Future<void> addConnection(SSHConnection connection) async {
    final storage = ref.read(storageServiceProvider);
    await storage.addConnection(connection);
    state = storage.getConnections();
  }

  Future<void> updateConnection(SSHConnection connection) async {
    final storage = ref.read(storageServiceProvider);
    await storage.updateConnection(connection);
    state = storage.getConnections();
  }

  Future<void> deleteConnection(String id) async {
    final storage = ref.read(storageServiceProvider);
    await storage.deleteConnection(id);
    state = storage.getConnections();
  }

  Future<void> toggleFavorite(String id) async {
    final connection = state.firstWhere((c) => c.id == id);
    await updateConnection(
      connection.copyWith(isFavorite: !connection.isFavorite),
    );
  }
}

// Current Connection State
class CurrentConnectionNotifier extends Notifier<SSHConnection?> {
  @override
  SSHConnection? build() => null;

  void setConnection(SSHConnection? connection) {
    state = connection;
  }
}

final currentConnectionProvider =
    NotifierProvider<CurrentConnectionNotifier, SSHConnection?>(
      CurrentConnectionNotifier.new,
    );

final connectionStateProvider = StreamProvider<ConnectionState>((ref) {
  final sshService = ref.watch(sshServiceProvider);
  return sshService.connectionState;
});

// Agent State
class AgentInfoNotifier extends Notifier<AgentInfo> {
  @override
  AgentInfo build() => AgentInfo.notInstalled();

  void setAgentInfo(AgentInfo info) {
    state = info;
  }
}

final agentInfoProvider = NotifierProvider<AgentInfoNotifier, AgentInfo>(
  AgentInfoNotifier.new,
);

// Navigation
class CurrentScreenNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setScreen(int index) {
    state = index;
  }
}

final currentScreenProvider = NotifierProvider<CurrentScreenNotifier, int>(
  CurrentScreenNotifier.new,
);

// Live Stats Stream with keepAlive to maintain connection
final liveStatsProvider = StreamProvider.autoDispose((ref) {
  final grpcService = ref.watch(grpcServiceProvider);
  ref.watch(grpcSessionProvider);

  // Keep the provider alive for 30 seconds after last listener
  ref.keepAlive();

  return grpcService.streamStats();
});

// Service List Provider
final serviceListProvider = FutureProvider.autoDispose((ref) async {
  final grpcService = ref.watch(grpcServiceProvider);
  ref.watch(grpcSessionProvider);
  return await grpcService.listServices();
});

// Disk Info Provider
final diskInfoProvider = FutureProvider.autoDispose((ref) async {
  final grpcService = ref.watch(grpcServiceProvider);
  ref.watch(grpcSessionProvider);
  return await grpcService.getDiskInfo();
});

// Agent Elevation Status Provider (checks if agent is running as root)
// Using StateNotifierProvider for better control over refresh
class AgentElevationNotifier extends StateNotifier<AsyncValue<bool>> {
  AgentElevationNotifier(this.grpcService) : super(const AsyncValue.loading()) {
    _checkElevation();
  }

  final GrpcService grpcService;

  Future<void> _checkElevation() async {
    try {
      final versionInfo = await grpcService.getVersion();
      debugPrint(
        'Agent elevation check: isRoot = ${versionInfo.isRoot}, version = ${versionInfo.version}',
      );
      state = AsyncValue.data(versionInfo.isRoot);
    } catch (e) {
      // If check fails, assume not root to be safe
      state = const AsyncValue.data(false);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _checkElevation();
  }
}

final agentElevationProvider =
    StateNotifierProvider<AgentElevationNotifier, AsyncValue<bool>>((ref) {
      final grpcService = ref.watch(grpcServiceProvider);
      ref.watch(grpcSessionProvider);
      return AgentElevationNotifier(grpcService);
    });

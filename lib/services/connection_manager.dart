import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/ssh_connection.dart';
import '../models/agent_info.dart';
import 'ssh_service.dart';
import 'grpc_service.dart';
import 'agent_manager.dart';
import 'transfer_manager_service.dart';

/// Centralized connection manager that coordinates all connection services
/// Provides atomic connect/disconnect operations with proper cleanup
class ConnectionManager {
  final SSHService _sshService;
  final GrpcService _grpcService;
  final AgentManager _agentManager;

  ConnectionManager({
    required SSHService sshService,
    required GrpcService grpcService,
    required AgentManager agentManager,
  })  : _sshService = sshService,
        _grpcService = grpcService,
        _agentManager = agentManager;

  // Connection state
  final _stateController = StreamController<ConnectionManagerState>.broadcast();
  ConnectionManagerState _state = const ConnectionManagerState.disconnected();
  SSHConnection? _currentConnection;

  // Getters
  Stream<ConnectionManagerState> get stateStream => _stateController.stream;
  ConnectionManagerState get state => _state;
  SSHConnection? get currentConnection => _currentConnection;
  bool get isConnected => _state is ConnectedState;
  bool get isConnecting => _state is ConnectingState;
  bool get isDisconnected => _state is DisconnectedState;

  void _updateState(ConnectionManagerState newState) {
    _state = newState;
    _stateController.add(newState);
    debugPrint('ConnectionManager state: $newState');
  }

  /// Connect to a Raspberry Pi
  /// Returns ConnectionResult with success status and optional error
  Future<ConnectionResult> connect(
    SSHConnection connection, {
    bool installAgentIfNeeded = true,
    bool enableForwardingIfNeeded = true,
    Function(String)? onProgress,
  }) async {
    // Guard: prevent duplicate connections
    if (_state is ConnectingState) {
      return ConnectionResult.error('Already connecting to a device');
    }
    if (_state is ConnectedState) {
      final current = (_state as ConnectedState).connection;
      if (current.id == connection.id) {
        return ConnectionResult.error('Already connected to ${connection.name}');
      }
      // Disconnect from current connection first
      await disconnect();
    }

    _updateState(ConnectionManagerState.connecting(
      connection: connection,
      step: ConnectionStep.initializing,
    ));

    try {
      // Step 1: Establish SSH connection
      onProgress?.call('Connecting to SSH...');
      _updateState(ConnectionManagerState.connecting(
        connection: connection,
        step: ConnectionStep.connectingSSH,
      ));

      await _sshService.connect(connection);
      debugPrint('✓ SSH connected');

      // Step 1.5: Check if user is root (required for app to function)
      onProgress?.call('Checking user permissions...');
      _updateState(ConnectionManagerState.connecting(
        connection: connection,
        step: ConnectionStep.checkingPermissions,
      ));

      try {
        final hasSudo = await _agentManager.checkSudoAccess();
        debugPrint('Sudo access check result: $hasSudo');
        
        if (!hasSudo) {
          debugPrint('User does not have sudo access - blocking connection');
          throw Exception('SUDO_REQUIRED: This app requires sudo permissions. Please connect with a user that has sudo access.');
        }
        debugPrint('✓ User has sudo access');
      } catch (e) {
        if (e.toString().contains('SUDO_REQUIRED')) {
          rethrow;
        }
        // If command execution fails after successful SSH connection, it's a permission/shell issue
        debugPrint('Command execution error during sudo check: $e');
        throw Exception('SUDO_REQUIRED: User cannot execute commands. This app requires a user with full shell access and sudo permissions.');
      }

      // Step 2: Connect Transfer Manager (SFTP) in background
      onProgress?.call('Starting file transfer service...');
      _updateState(ConnectionManagerState.connecting(
        connection: connection,
        step: ConnectionStep.connectingSFTP,
      ));

      try {
        TransferManagerService.connect(
          host: connection.host,
          port: connection.port,
          username: connection.username,
          password: connection.password,
        );
        debugPrint('✓ SFTP connected');
      } catch (e) {
        debugPrint('⚠ SFTP connection failed (non-critical): $e');
        // Continue anyway - SFTP is nice to have but not essential
      }

      // Step 3: Check agent installation
      onProgress?.call('Checking agent status...');
      _updateState(ConnectionManagerState.connecting(
        connection: connection,
        step: ConnectionStep.checkingAgent,
      ));

      final agentInfo = await _agentManager.checkAgentVersion();
      debugPrint('Agent info: installed=${agentInfo.isInstalled}, version=${agentInfo.version}, needs update=${agentInfo.needsUpdate}');

      // If agent is not installed, return partial result
      if (!agentInfo.isInstalled) {
        if (!installAgentIfNeeded) {
          return ConnectionResult.agentSetupRequired(
            agentInfo: agentInfo,
            sshConnected: true,
          );
        }
        // Agent will be installed by caller, then they can call continueConnection
      }
      
      // Note: If agent just needs update, we continue connecting and show update banner

      // Step 4: Check SSH forwarding configuration
      onProgress?.call('Checking SSH configuration...');
      _updateState(ConnectionManagerState.connecting(
        connection: connection,
        step: ConnectionStep.checkingSSHConfig,
      ));

      final forwardingEnabled = await _checkSSHForwarding();
      if (!forwardingEnabled && !enableForwardingIfNeeded) {
        return ConnectionResult.sshForwardingRequired();
      }

      // Step 5: Start agent and setup tunnel
      final tunnelResult = await _setupAgentAndTunnel(onProgress);
      if (!tunnelResult.success) {
        throw Exception(tunnelResult.error ?? 'Failed to setup agent tunnel');
      }

      // Step 6: Connect gRPC
      onProgress?.call('Connecting to agent...');
      _updateState(ConnectionManagerState.connecting(
        connection: connection,
        step: ConnectionStep.connectingGRPC,
      ));

      await _grpcService.connect(50051);
      debugPrint('✓ gRPC connected');

      // Step 7: Get agent version
      var updatedConnection = connection;
      try {
        debugPrint('Fetching agent version via gRPC...');
        final versionInfo = await _grpcService.getVersion();
        debugPrint('✓ Agent version received: ${versionInfo.version}');
        updatedConnection = connection.copyWith(agentVersion: versionInfo.version);
        debugPrint('✓ Connection updated with agent version: ${updatedConnection.agentVersion}');
      } catch (e) {
        debugPrint('⚠ Could not get agent version: $e');
        // Continue anyway - version check is non-critical
      }

      // Success!
      _currentConnection = updatedConnection;
      _updateState(ConnectionManagerState.connected(connection: updatedConnection));
      
      debugPrint('Connection complete - returning connection with agentVersion: ${updatedConnection.agentVersion}');

      return ConnectionResult.success(connection: updatedConnection);
    } catch (e, stackTrace) {
      debugPrint('Connection failed: $e\n$stackTrace');

      // Cleanup on failure
      await _cleanupFailedConnection();

      _updateState(ConnectionManagerState.error(
        message: e.toString(),
        previousConnection: _currentConnection,
      ));

      return ConnectionResult.error(e.toString());
    }
  }

  /// Continue connection after agent installation or SSH config change
  Future<ConnectionResult> continueConnection({
    Function(String)? onProgress,
  }) async {
    if (_state is! ConnectingState) {
      return ConnectionResult.error('Not in connecting state');
    }

    final connectingState = _state as ConnectingState;
    final connection = connectingState.connection;

    try {
      // Setup agent and tunnel
      final tunnelResult = await _setupAgentAndTunnel(onProgress);
      if (!tunnelResult.success) {
        throw Exception(tunnelResult.error ?? 'Failed to setup agent tunnel');
      }

      // Connect gRPC
      onProgress?.call('Connecting to agent...');
      _updateState(ConnectionManagerState.connecting(
        connection: connection,
        step: ConnectionStep.connectingGRPC,
      ));

      await _grpcService.connect(50051);
      debugPrint('✓ gRPC connected');

      // Get agent version
      var updatedConnection = connection;
      try {
        final versionInfo = await _grpcService.getVersion();
        debugPrint('✓ Agent version: ${versionInfo.version}');
        updatedConnection = connection.copyWith(agentVersion: versionInfo.version);
      } catch (e) {
        debugPrint('⚠ Could not get agent version: $e');
        // Continue anyway - version check is non-critical
      }

      // Success!
      _currentConnection = updatedConnection;
      _updateState(ConnectionManagerState.connected(connection: updatedConnection));

      return ConnectionResult.success(connection: updatedConnection);
    } catch (e, stackTrace) {
      debugPrint('Continue connection failed: $e\n$stackTrace');

      await _cleanupFailedConnection();

      _updateState(ConnectionManagerState.error(
        message: e.toString(),
        previousConnection: _currentConnection,
      ));

      return ConnectionResult.error(e.toString());
    }
  }

  /// Setup agent and SSH tunnel
  Future<TunnelResult> _setupAgentAndTunnel(Function(String)? onProgress) async {
    try {
      // Start agent using AgentManager
      onProgress?.call('Starting agent...');
      try {
        final agentManager = AgentManager(_sshService);
        await agentManager.startAgent();
        debugPrint('✓ Agent started');
      } catch (e) {
        debugPrint('Error starting agent: $e');
        return TunnelResult.error('Failed to start agent: $e');
      }

      // Setup SSH tunnel
      onProgress?.call('Setting up secure tunnel...');
      try {
        final localPort = await _sshService.forwardLocal(50051, 'localhost', 50051);
        debugPrint('✓ SSH tunnel: localhost:$localPort -> Pi:50051');

        // Give tunnel time to establish
        await Future.delayed(const Duration(milliseconds: 800));

        return TunnelResult.success(localPort: localPort);
      } catch (e) {
        return TunnelResult.error('Failed to setup tunnel: $e');
      }
    } catch (e) {
      return TunnelResult.error('Unexpected error: $e');
    }
  }

  /// Check if SSH forwarding is enabled
  Future<bool> _checkSSHForwarding() async {
    try {
      final result = await _sshService.execute(
        'grep -i "^\\s*AllowTcpForwarding" /etc/ssh/sshd_config || echo "not_configured"',
      );

      final isDisabled = result.toLowerCase().contains('allowtcpforwarding no') ||
          result.toLowerCase().contains('allowtcpforwarding=no');

      return !isDisabled;
    } catch (e) {
      debugPrint('Could not check SSH config: $e');
      return true; // Assume enabled if we can't check
    }
  }

  /// Enable SSH forwarding
  Future<void> enableSSHForwarding() async {
    if (!_sshService.isConnected) {
      throw Exception('SSH not connected');
    }

    try {
      // Backup config
      await _sshService.execute('sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup');

      // Enable forwarding
      await _sshService.execute(
        'sudo sed -i "s/^\\s*AllowTcpForwarding.*/AllowTcpForwarding yes/" /etc/ssh/sshd_config',
      );

      // Add if not exists
      await _sshService.execute(
        'grep -q "^AllowTcpForwarding" /etc/ssh/sshd_config || echo "AllowTcpForwarding yes" | sudo tee -a /etc/ssh/sshd_config',
      );

      // Restart SSH
      await _sshService.execute('sudo systemctl restart sshd || sudo service ssh restart');

      debugPrint('✓ SSH forwarding enabled');
    } catch (e) {
      debugPrint('Failed to enable SSH forwarding: $e');
      rethrow;
    }
  }

  /// Cleanup after a failed connection attempt
  Future<void> _cleanupFailedConnection() async {
    debugPrint('Cleaning up failed connection...');

    try {
      await _grpcService.disconnect();
    } catch (e) {
      debugPrint('Error disconnecting gRPC: $e');
    }

    try {
      await _sshService.disconnect();
    } catch (e) {
      debugPrint('Error disconnecting SSH: $e');
    }

    try {
      TransferManagerService.disconnect();
    } catch (e) {
      debugPrint('Error disconnecting SFTP: $e');
    }
  }

  /// Disconnect from current connection
  Future<void> disconnect() async {
    if (_state is DisconnectedState) {
      return; // Already disconnected
    }

    _updateState(const ConnectionManagerState.disconnecting());

    try {
      // Disconnect in reverse order
      await _grpcService.disconnect();
      await _sshService.disconnect();
      TransferManagerService.disconnect();

      _currentConnection = null;
      _updateState(const ConnectionManagerState.disconnected());
      debugPrint('✓ Disconnected');
    } catch (e) {
      debugPrint('Error during disconnect: $e');
      _updateState(const ConnectionManagerState.disconnected());
    }
  }

  void dispose() {
    disconnect();
    _stateController.close();
  }
}

// Connection Manager State Machine
sealed class ConnectionManagerState {
  const ConnectionManagerState();

  const factory ConnectionManagerState.disconnected() = DisconnectedState;
  const factory ConnectionManagerState.connecting({
    required SSHConnection connection,
    required ConnectionStep step,
  }) = ConnectingState;
  const factory ConnectionManagerState.connected({
    required SSHConnection connection,
  }) = ConnectedState;
  const factory ConnectionManagerState.disconnecting() = DisconnectingState;
  const factory ConnectionManagerState.error({
    required String message,
    SSHConnection? previousConnection,
  }) = ErrorState;
}

class DisconnectedState extends ConnectionManagerState {
  const DisconnectedState();

  @override
  String toString() => 'Disconnected';
}

class ConnectingState extends ConnectionManagerState {
  final SSHConnection connection;
  final ConnectionStep step;

  const ConnectingState({required this.connection, required this.step});

  @override
  String toString() => 'Connecting: ${step.name}';
}

class ConnectedState extends ConnectionManagerState {
  final SSHConnection connection;

  const ConnectedState({required this.connection});

  @override
  String toString() => 'Connected to ${connection.name}';
}

class DisconnectingState extends ConnectionManagerState {
  const DisconnectingState();

  @override
  String toString() => 'Disconnecting';
}

class ErrorState extends ConnectionManagerState {
  final String message;
  final SSHConnection? previousConnection;

  const ErrorState({required this.message, this.previousConnection});

  @override
  String toString() => 'Error: $message';
}

// Connection steps for progress tracking
enum ConnectionStep {
  initializing,
  connectingSSH,
  checkingPermissions,
  connectingSFTP,
  checkingAgent,
  installingAgent,
  checkingSSHConfig,
  startingAgent,
  setupTunnel,
  connectingGRPC,
}

extension ConnectionStepName on ConnectionStep {
  String get name {
    switch (this) {
      case ConnectionStep.initializing:
        return 'Initializing...';
      case ConnectionStep.connectingSSH:
        return 'Connecting to SSH...';
      case ConnectionStep.checkingPermissions:
        return 'Checking user permissions...';
      case ConnectionStep.connectingSFTP:
        return 'Starting file transfer service...';
      case ConnectionStep.checkingAgent:
        return 'Checking agent status...';
      case ConnectionStep.installingAgent:
        return 'Installing agent...';
      case ConnectionStep.checkingSSHConfig:
        return 'Checking SSH configuration...';
      case ConnectionStep.startingAgent:
        return 'Starting agent...';
      case ConnectionStep.setupTunnel:
        return 'Setting up secure tunnel...';
      case ConnectionStep.connectingGRPC:
        return 'Connecting to agent...';
    }
  }
}

// Connection result types
sealed class ConnectionResult {
  final bool success;
  final String? error;

  const ConnectionResult({required this.success, this.error});

  factory ConnectionResult.success({required SSHConnection connection}) = SuccessResult;
  factory ConnectionResult.error(String message) = ErrorResult;
  factory ConnectionResult.agentSetupRequired({
    required AgentInfo agentInfo,
    required bool sshConnected,
  }) = AgentSetupRequiredResult;
  factory ConnectionResult.sshForwardingRequired() = SSHForwardingRequiredResult;
}

class SuccessResult extends ConnectionResult {
  final SSHConnection connection;

  SuccessResult({required this.connection}) : super(success: true);
}

class ErrorResult extends ConnectionResult {
  ErrorResult(String message) : super(success: false, error: message);
}

class AgentSetupRequiredResult extends ConnectionResult {
  final AgentInfo agentInfo;
  final bool sshConnected;

  AgentSetupRequiredResult({
    required this.agentInfo,
    required this.sshConnected,
  }) : super(success: false);
}

class SSHForwardingRequiredResult extends ConnectionResult {
  SSHForwardingRequiredResult() : super(success: false);
}

// Tunnel setup result
class TunnelResult {
  final bool success;
  final int? localPort;
  final String? error;

  TunnelResult({required this.success, this.localPort, this.error});

  factory TunnelResult.success({required int localPort}) =>
      TunnelResult(success: true, localPort: localPort);

  factory TunnelResult.error(String message) =>
      TunnelResult(success: false, error: message);
}

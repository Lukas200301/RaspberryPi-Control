import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/foundation.dart';
import '../models/ssh_connection.dart';
import '../constants/app_constants.dart';

class SSHService {
  SSHClient? _client;
  SSHConnection? _currentConnection;
  final _connectionStateController = StreamController<ConnectionState>.broadcast();
  ConnectionState _state = ConnectionState.disconnected;
  ServerSocket? _tunnelSocket;
  Timer? _keepaliveTimer;

  Stream<ConnectionState> get connectionState => _connectionStateController.stream;
  ConnectionState get currentState => _state;
  SSHConnection? get currentConnection => _currentConnection;
  SSHClient? get client => _client;
  bool get isConnected => _client != null && _state == ConnectionState.connected;

  void _updateState(ConnectionState state) {
    _state = state;
    _connectionStateController.add(state);
  }

  Future<void> connect(SSHConnection connection) async {
    try {
      _updateState(ConnectionState.connecting);
      _currentConnection = connection;

      final socket = await SSHSocket.connect(
        connection.host,
        connection.port,
        timeout: AppConstants.sshTimeout,
      );

      _client = SSHClient(
        socket,
        username: connection.username,
        onPasswordRequest: () => connection.password,
      );

      _updateState(ConnectionState.connected);
      _startKeepalive();
      debugPrint('SSH connected to ${connection.host}');
    } catch (e) {
      _updateState(ConnectionState.error);
      debugPrint('SSH connection failed: $e');
      rethrow;
    }
  }

  void _startKeepalive() {
    _stopKeepalive();
    // Send a keepalive command every 45 seconds to prevent connection timeout
    // Increased from 30s to reduce conflicts with long-running operations
    _keepaliveTimer = Timer.periodic(const Duration(seconds: 45), (timer) async {
      if (_client == null || _state != ConnectionState.connected) {
        timer.cancel();
        return;
      }

      try {
        // Send a simple echo command to keep connection alive
        // Use timeout to prevent blocking if connection is busy
        await _client!.run('echo "keepalive"').timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            debugPrint('SSH keepalive timeout (connection may be busy)');
            return Uint8List(0);
          },
        );
        debugPrint('SSH keepalive sent');
      } catch (e) {
        // Log error but don't immediately mark as error - could just be busy
        debugPrint('Keepalive error (connection may be busy): $e');
        // Only mark as error if we can't connect at all
        if (e.toString().contains('closed') || e.toString().contains('Closed')) {
          debugPrint('Connection is closed, marking as error');
          _updateState(ConnectionState.error);
          timer.cancel();
        }
      }
    });
  }

  void _stopKeepalive() {
    _keepaliveTimer?.cancel();
    _keepaliveTimer = null;
  }

  Future<void> reconnect() async {
    if (_currentConnection == null) {
      throw Exception('No previous connection to reconnect to');
    }

    debugPrint('Attempting to reconnect...');
    await disconnect();
    await connect(_currentConnection!);
  }

  Future<void> disconnect() async {
    try {
      _stopKeepalive();
      await _tunnelSocket?.close();
      _tunnelSocket = null;
      _client?.close();
      _client = null;
      _currentConnection = null;
      _updateState(ConnectionState.disconnected);
      debugPrint('SSH disconnected');
    } catch (e) {
      debugPrint('Error during disconnect: $e');
    }
  }

  Future<String> execute(String command) async {
    if (_client == null) {
      throw Exception('Not connected to SSH server');
    }

    try {
      final result = await _client!.run(command);
      return utf8.decode(result);
    } catch (e) {
      debugPrint('Error executing command: $e');
      rethrow;
    }
  }

  Future<SftpClient> getSftp() async {
    if (_client == null) {
      throw Exception('Not connected to SSH server');
    }

    return await _client!.sftp();
  }

  Future<SSHSession> openShell() async {
    if (_client == null) {
      throw Exception('Not connected to SSH server');
    }

    return _client!.shell();
  }

  Future<int> forwardLocal(int localPort, String remoteHost, int remotePort) async {
    if (_client == null) {
      throw Exception('Not connected to SSH server');
    }

    try {
      // Close existing tunnel if any
      await _tunnelSocket?.close();
      
      _tunnelSocket = await ServerSocket.bind(InternetAddress.loopbackIPv4, localPort);
      debugPrint('Local server bound to port ${_tunnelSocket!.port}');

      _tunnelSocket!.listen((localSocket) async {
        debugPrint('New connection on local port ${_tunnelSocket!.port}');
        
        try {
          final forward = await _client!.forwardLocal(remoteHost, remotePort);
          debugPrint('SSH tunnel established to $remoteHost:$remotePort');
          
          // Forward data from remote to local
          forward.stream.listen(
            (data) {
              try {
                localSocket.add(data);
              } catch (e) {
                debugPrint('Error writing to local socket: $e');
              }
            },
            onDone: () {
              debugPrint('Remote connection closed');
              localSocket.close();
            },
            onError: (error) {
              debugPrint('Error in remote stream: $error');
              localSocket.close();
            },
            cancelOnError: true,
          );

          // Forward data from local to remote
          localSocket.listen(
            (data) {
              try {
                forward.sink.add(data);
              } catch (e) {
                debugPrint('Error writing to remote: $e');
              }
            },
            onDone: () {
              debugPrint('Local connection closed');
              forward.close();
            },
            onError: (error) {
              debugPrint('Error in local stream: $error');
              forward.close();
            },
            cancelOnError: true,
          );
        } catch (e) {
          debugPrint('Error creating forward (may be normal): $e');
          localSocket.close();
          // Don't rethrow - this happens on every gRPC reconnect
        }
      });

      return _tunnelSocket!.port;
    } catch (e) {
      debugPrint('Error in forwardLocal: $e');
      rethrow;
    }
  }

  void dispose() {
    disconnect();
    _connectionStateController.close();
  }
}

enum ConnectionState {
  disconnected,
  connecting,
  connected,
  error,
}

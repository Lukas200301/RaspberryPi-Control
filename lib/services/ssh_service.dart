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
  final _connectionStateController =
      StreamController<ConnectionState>.broadcast();
  ConnectionState _state = ConnectionState.disconnected;
  ServerSocket? _tunnelSocket;

  Stream<ConnectionState> get connectionState =>
      _connectionStateController.stream;
  ConnectionState get currentState => _state;
  SSHConnection? get currentConnection => _currentConnection;
  SSHClient? get client => _client;
  bool get isConnected =>
      _client != null && _state == ConnectionState.connected;

  void _updateState(ConnectionState state) {
    _state = state;
    _connectionStateController.add(state);
  }

  /// Set from the connection settings
  Duration connectTimeout = AppConstants.sshTimeout;
  Duration keepAliveInterval = const Duration(seconds: 15);

  Future<void> connect(SSHConnection connection) async {
    try {
      _updateState(ConnectionState.connecting);
      _currentConnection = connection;

      final client = await openClient(
        connection,
        timeout: connectTimeout,
        keepAliveInterval: keepAliveInterval,
      );
      _client = client;

      // The keep-alive closes the client when the Pi stops answering
      client.done.then(
        (_) => _onClientClosed(client),
        onError: (_) => _onClientClosed(client),
      );

      _updateState(ConnectionState.connected);
      debugPrint('SSH connected to ${connection.host}');
    } catch (e) {
      _updateState(ConnectionState.error);
      debugPrint('SSH connection failed: $e');
      rethrow;
    }
  }

  /// Opens an authenticated SSH client without touching the session state.
  /// Used for the main session and for short device health checks.
  static Future<SSHClient> openClient(
    SSHConnection connection, {
    Duration timeout = const Duration(seconds: 10),
    Duration? keepAliveInterval = const Duration(seconds: 15),
  }) async {
    final socket = await SSHSocket.connect(
      connection.host,
      connection.port,
      timeout: timeout,
    );
    final identities = <SSHKeyPair>[];
    if (connection.usesKey) {
      identities.addAll(
        SSHKeyPair.fromPem(
          connection.privateKey,
          connection.passphrase.isEmpty ? null : connection.passphrase,
        ),
      );
    }
    final client = SSHClient(
      socket,
      username: connection.username,
      identities: identities,
      onPasswordRequest: connection.password.isEmpty ? null : () => connection.password,
      keepAliveInterval: keepAliveInterval,
    );
    await client.authenticated.timeout(timeout);
    return client;
  }

  /// Runs [command] and writes [stdin] to its standard input (e.g. a sudo
  /// password, which then never shows up in the process list)
  Future<({String stdout, String stderr, int exitCode})> executeWithStdin(
    String command,
    String stdin,
  ) async {
    if (_client == null) throw Exception('Not connected to SSH server');
    final session = await _client!.execute(command);
    session.stdin.add(utf8.encode(stdin));
    await session.stdin.close();
    final out = await utf8.decodeStream(session.stdout);
    final err = await utf8.decodeStream(session.stderr);
    await session.done;
    return (stdout: out, stderr: err, exitCode: session.exitCode ?? -1);
  }

  void _onClientClosed(SSHClient client) {
    if (identical(client, _client) && _state == ConnectionState.connected) {
      debugPrint('SSH connection closed by the remote side');
      _updateState(ConnectionState.error);
    }
  }

  Future<void> reconnect() async {
    final connection = _currentConnection;
    if (connection == null) {
      throw Exception('No previous connection to reconnect to');
    }

    debugPrint('Attempting to reconnect...');
    await disconnect();
    await connect(connection);
  }

  Future<void> disconnect() async {
    try {
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

  Future<int> forwardLocal(
    int localPort,
    String remoteHost,
    int remotePort,
  ) async {
    if (_client == null) {
      throw Exception('Not connected to SSH server');
    }

    try {
      // Close existing tunnel if any
      await _tunnelSocket?.close();

      _tunnelSocket = await ServerSocket.bind(
        InternetAddress.loopbackIPv4,
        localPort,
      );
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

enum ConnectionState { disconnected, connecting, connected, error }

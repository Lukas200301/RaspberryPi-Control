import 'dart:convert';
import 'package:dartssh2/dartssh2.dart';

class SSHService {
  final String name;
  final String host;
  final int port;
  final String username;
  final String password;
  SSHClient? _client;

  SSHService({
    required this.name,
    required this.host,
    required this.port,
    required this.username,
    required this.password,
  });

  Future<void> connect() async {
    try {
      final socket = await SSHSocket.connect(host, port, timeout: Duration(seconds: 10)); 
      _client = SSHClient(
        socket,
        username: username,
        onPasswordRequest: () => password,
      );
    } catch (e) {
      throw Exception('Failed to connect: $e');
    }
  }

  Future<String> executeCommand(String command) async {
  if (_client == null) {
    throw Exception('Not connected');
  }

  try {
    final session = await _client!.execute(command);
    final output = await utf8.decodeStream(session.stdout);
    session.close();
    return output;
  } catch (e) {
    if (e.toString().contains('SSHAuthFailError')) {
      throw Exception('Authentication failed: Please check your username and password.');
    } else {
      throw Exception('Failed to execute command: $e');
    }
  }
}

  Future<String> getStats() async {
    return await executeCommand(
      'vcgencmd measure_temp && vcgencmd get_mem arm && vcgencmd get_mem gpu && uptime && df -h && free -m && top -bn1 | head -n 10'
    );
  }

  void disconnect() {
    _client?.close();
    _client = null;
  }
}
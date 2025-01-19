import 'package:flutter/material.dart';
import 'ssh_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ConnectionScreen extends StatefulWidget {
  final Function(SSHService) setSSHService;
  final String connectionStatus;

  const ConnectionScreen({
    super.key,
    required this.setSSHService,
    required this.connectionStatus,
  });

  @override
  _ConnectionScreenState createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _hostController = TextEditingController();
  final TextEditingController _portController = TextEditingController(text: '22');
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  SSHService? sshService;
  bool isConnected = false;
  String connectionStatus = '';
  int? _editingIndex;
  List<Map<String, String>> connections = [];

  @override
  void initState() {
    super.initState();
    _loadConnections();
    connectionStatus = widget.connectionStatus;
    isConnected = widget.connectionStatus.startsWith('Connected');
  }

  @override
  void didUpdateWidget(ConnectionScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.connectionStatus != widget.connectionStatus) {
      setState(() {
        connectionStatus = widget.connectionStatus;
        isConnected = connectionStatus.startsWith('Connected');
      });
    }
  }

  void _loadConnections() async {
    final prefs = await SharedPreferences.getInstance();
    final connectionsString = prefs.getString('connections') ?? '[]';
    setState(() {
      connections = List<Map<String, String>>.from(
        (jsonDecode(connectionsString) as List).map(
          (connection) => Map<String, String>.from(connection),
        ),
      );
    });
  }

  void _saveConnections() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
      'connections',
      jsonEncode(connections),
    );
  }

  void _addConnection(Map<String, String> connection) {
    setState(() {
      connections.add(connection);
    });
    _saveConnections();
  }

  void _removeConnection(int index) {
    setState(() {
      connections.removeAt(index);
    });
    _saveConnections();
  }

  void _updateConnection(int index, Map<String, String> connection) {
    setState(() {
      connections[index] = connection;
    });
    _saveConnections();
  }

  void _connect() async {
  if (isConnected) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please disconnect from the current Raspberry Pi before connecting to a new one.')),
    );
    return;
  }

  setState(() {
    connectionStatus = 'Connecting...';
  });
    try {
      sshService = SSHService(
        name: _nameController.text,
        host: _hostController.text,
        port: int.parse(_portController.text),
        username: _usernameController.text,
        password: _passwordController.text,
      );
      await sshService!.connect();
      widget.setSSHService(sshService!);
      setState(() {
        isConnected = true;
        connectionStatus = 'Connected to ${_nameController.text}, (${_hostController.text})';
      });
    } catch (e) {
      setState(() {
        connectionStatus = 'Error: $e';
      });
    }
  }


  void _connectToSavedConnection(Map<String, String> connection) async {
    if (isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please disconnect from the current Raspberry Pi before connecting to a new one.')),
      );
      return;
    }

    setState(() {
      connectionStatus = 'Connecting...';
    });
    try {
      sshService = SSHService(
        name: connection['name']!,
        host: connection['host']!,
        port: int.parse(connection['port']!),
        username: connection['username']!,
        password: connection['password']!,
      );
      await sshService!.connect();
      widget.setSSHService(sshService!);
      setState(() {
        isConnected = true;
        connectionStatus = 'Connected to ${connection['name']}, (${connection['host']})';
      });
    } catch (e) {
      setState(() {
        connectionStatus = 'Error: $e';
      });
    }
  }


  void _saveConnection() {
    final connection = {
      'name': _nameController.text,
      'host': _hostController.text,
      'port': _portController.text,
      'username': _usernameController.text,
      'password': _passwordController.text,
    };
    if (_editingIndex != null) {
      _updateConnection(_editingIndex!, connection);
      _editingIndex = null;
    } else {
      _addConnection(connection);
    }
    _clearFields();
  }

  void _clearFields() {
    _nameController.clear();
    _hostController.clear();
    _portController.clear();
    _usernameController.clear();
    _passwordController.clear();
  }

  void _editConnectionFields(int index) {
    final connection = connections[index];
    _nameController.text = connection['name']!;
    _hostController.text = connection['host']!;
    _portController.text = connection['port']!;
    _usernameController.text = connection['username']!;
    _passwordController.text = connection['password']!;
    setState(() {
      _editingIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Connection Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _hostController,
              decoration: const InputDecoration(
                labelText: 'Host/IP',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _portController,
              decoration: const InputDecoration(
                labelText: 'Port',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveConnection,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Save Connection'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _connect,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Connect'),
            ),
            const SizedBox(height: 16),
            Text(
              connectionStatus,
              style: TextStyle(
                color: connectionStatus.startsWith('Error') ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Saved Connections:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: connections.length,
              itemBuilder: (context, index) {
                final connection = connections[index];
                return ListTile(
                  title: Text(connection['name']!),
                  subtitle: Text('Host: ${connection['host']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _editConnectionFields(index);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _removeConnection(index),
                      ),
                    ],
                  ),
                  onTap: () {
                    _connectToSavedConnection(connection);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
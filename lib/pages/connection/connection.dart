import 'package:flutter/material.dart';
import '../../services/ssh_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Connection extends StatefulWidget {
  final Function(SSHService) setSSHService;
  final String connectionStatus;

  const Connection({
    super.key,
    required this.setSSHService,
    required this.connectionStatus,
  });

  @override
  ConnectionState createState() => ConnectionState();
}

class ConnectionState extends State<Connection> {
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
  String _testConnectionStatus = '';

  @override
  void initState() {
    super.initState();
    _loadConnections();
    connectionStatus = widget.connectionStatus;
    isConnected = widget.connectionStatus.startsWith('Connected');
  }

  @override
  void didUpdateWidget(Connection oldWidget) {
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

  void _showEditDialog({Map<String, String>? connection, int? index}) {
    if (connection != null) {
      _nameController.text = connection['name']!;
      _hostController.text = connection['host']!;
      _portController.text = connection['port']!;
      _usernameController.text = connection['username']!;
      _passwordController.text = connection['password']!;
      _editingIndex = index;
    } else {
      _clearFields();
      _editingIndex = null;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(_editingIndex == null ? 'Add Connection' : 'Edit Connection'),
              content: SingleChildScrollView(
                child: Column(
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
                    Text(
                      _testConnectionStatus,
                      style: TextStyle(
                        color: _testConnectionStatus.startsWith('Error') ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _testConnection(setState);
                  },
                  child: const Text('Test Connection'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _saveConnection();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _testConnection(StateSetter setState) async {
    setState(() {
      _testConnectionStatus = 'Testing connection...';
    });
    try {
      final testSSHService = SSHService(
        name: _nameController.text,
        host: _hostController.text,
        port: int.parse(_portController.text),
        username: _usernameController.text,
        password: _passwordController.text,
      );
      await testSSHService.connect();
      setState(() {
        _testConnectionStatus = 'Connection successful!';
      });
      testSSHService.disconnect();
    } catch (e) {
      setState(() {
        _testConnectionStatus = 'Error: $e';
      });
    }
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Connection Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showEditDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                      return Card(
                        child: ListTile(
                          title: Text(connection['name']!),
                          subtitle: Text('Host: ${connection['host']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  _showEditDialog(connection: connection, index: index);
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
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    connectionStatus,
                    style: TextStyle(
                      color: connectionStatus.startsWith('Error') ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Version 1.2.3',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );  
  }
}
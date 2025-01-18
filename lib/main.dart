import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'ssh_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;
  runApp(MyApp(isDarkMode: isDarkMode));
}

class MyApp extends StatefulWidget {
  final bool isDarkMode;

  const MyApp({super.key, required this.isDarkMode});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool isDarkMode;

  @override
  void initState() {
    super.initState();
    isDarkMode = widget.isDarkMode;
  }

  void _toggleTheme() async {
    setState(() {
      isDarkMode = !isDarkMode;
    });
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Raspberry Pi Control',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blueAccent,
        colorScheme: ColorScheme.dark(
          primary: Colors.blueAccent,
          secondary: Colors.blueAccent,
        ),
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blueAccent,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.black, 
          ),
        ),
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: HomeScreen(
        isDarkMode: isDarkMode,
        toggleTheme: _toggleTheme,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback toggleTheme;

  const HomeScreen({
    super.key,
    required this.isDarkMode,
    required this.toggleTheme,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 2; 
  SSHService? sshService;
  List<Map<String, String>> connections = [];
  final TextEditingController _commandController = TextEditingController();
  String commandOutput = '';

  @override
  void initState() {
    super.initState();
    _loadConnections();
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

  void _editConnection(int index, Map<String, String> connection) {
    setState(() {
      connections[index] = connection;
    });
    _saveConnections();
  }

  void _onItemTapped(int index) {
    if (sshService != null || index == 2) {
      setState(() {
        _selectedIndex = index;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please connect first')),
      );
    }
  }

  void _setSSHService(SSHService service) {
    setState(() {
      sshService = service;
    });
  }

  void _logOff() {
    setState(() {
      sshService = null;
      _selectedIndex = 2; 
      commandOutput = ''; // Clear the command output when logging off
    });
  }

  void _sendCommand() async {
    if (sshService != null) {
      try {
        final result = await sshService!.executeCommand(_commandController.text);
        setState(() {
          commandOutput += '\n\$ ${_commandController.text}\n$result';
          _commandController.clear();
        });
      } catch (e) {
        setState(() {
          commandOutput += '\n\$ ${_commandController.text}\nError: $e';
          _commandController.clear();
        });
      }
    } else {
      setState(() {
        commandOutput += '\nError: Not connected. Please log in first.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Raspberry Pi Control'),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: widget.toggleTheme,
          ),
          if (sshService != null)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logOff,
            ),
        ],
      ),
      body: _selectedIndex == 0
          ? StatsScreen(sshService: sshService)
          : _selectedIndex == 1
              ? CommandScreen(
                  sshService: sshService,
                  commandController: _commandController,
                  commandOutput: commandOutput,
                  sendCommand: _sendCommand,
                )
              : ConnectionScreen(
                  setSSHService: _setSSHService,
                  connections: connections,
                  addConnection: _addConnection,
                  removeConnection: _removeConnection,
                  editConnection: _editConnection,
                ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.code),
            label: 'Commands',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.connect_without_contact),
            label: 'Connections',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class ConnectionScreen extends StatefulWidget {
  final Function(SSHService) setSSHService;
  final List<Map<String, String>> connections;
  final Function(Map<String, String>) addConnection;
  final Function(int) removeConnection;
  final Function(int, Map<String, String>) editConnection;

  const ConnectionScreen({
    super.key,
    required this.setSSHService,
    required this.connections,
    required this.addConnection,
    required this.removeConnection,
    required this.editConnection,
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

  void _connect() async {
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
        connectionStatus = 'Connected';
      });
    } catch (e) {
      setState(() {
        connectionStatus = 'Error: $e';
      });
    }
  }

  void _connectToSavedConnection(Map<String, String> connection) async {
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
        connectionStatus = 'Connected';
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
      widget.editConnection(_editingIndex!, connection);
      _editingIndex = null;
    } else {
      widget.addConnection(connection);
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

  void _editConnection(int index) {
    final connection = widget.connections[index];
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
            if (!isConnected) ...[
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
                itemCount: widget.connections.length,
                itemBuilder: (context, index) {
                  final connection = widget.connections[index];
                  return ListTile(
                    title: Text(connection['name']!),
                    subtitle: Text('Host: ${connection['host']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _editConnection(index);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => widget.removeConnection(index),
                        ),
                      ],
                    ),
                    onTap: () {
                      _connectToSavedConnection(connection);
                    },
                  );
                },
              ),
            ] else ...[
              const Text(
                'Connected',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class StatsScreen extends StatefulWidget {
  final SSHService? sshService;

  const StatsScreen({
    super.key,
    required this.sshService,
  });

  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  String stats = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.sshService != null) {
      _fetchStats();
      _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
        _fetchStats();
      });
    }
  }

  void _fetchStats() async {
    if (widget.sshService != null) {
      final result = await widget.sshService!.getStats();
      setState(() {
        stats = result;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Raspberry Pi Stats:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(stats),
        ],
      ),
    );
  }
}

class CommandScreen extends StatelessWidget {
  final SSHService? sshService;
  final TextEditingController commandController;
  final String commandOutput;
  final VoidCallback sendCommand;

  const CommandScreen({
    super.key,
    required this.sshService,
    required this.commandController,
    required this.commandOutput,
    required this.sendCommand,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              commandOutput,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(4.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              const Text(
                '\$',
                style: TextStyle(color: Colors.green, fontSize: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: commandController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter command',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  onSubmitted: (value) => sendCommand(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
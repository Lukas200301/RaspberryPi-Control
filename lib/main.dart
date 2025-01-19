import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ssh_service.dart';
import 'connection_screen.dart';
import 'command_screen.dart';
import 'stats_screen.dart';

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
      home: BarsScreen(
        isDarkMode: isDarkMode,
        toggleTheme: _toggleTheme,
      ),
    );
  }
}

class BarsScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback toggleTheme;

  const BarsScreen({
    super.key,
    required this.isDarkMode,
    required this.toggleTheme,
  });

  @override
  State<BarsScreen> createState() => _BarsScreenState();
}

class _BarsScreenState extends State<BarsScreen> {
  int _selectedIndex = 2;
  SSHService? sshService;
  final TextEditingController _commandController = TextEditingController();
  String commandOutput = '';
  String connectionStatus = '';

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

  void _setSSHService(SSHService? service) {
    setState(() {
      sshService = service;
      connectionStatus = service != null
          ? 'Connected to ${service.name} (${service.host})'
          : ''; // Clear status on logoff
  });
}

  void _logOff() {
    sshService?.disconnect();
    setState(() {
      connectionStatus = 'Disconnected out from ${sshService?.name} (${sshService?.host})';
      sshService = null;
      _selectedIndex = 2;
      commandOutput = '';
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
              connectionStatus: connectionStatus,
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
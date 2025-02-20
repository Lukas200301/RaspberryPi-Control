import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ssh_service.dart';
import 'connection_screen.dart';
import 'terminal_screen.dart';
import 'stats_screen.dart';
import 'file_explorer_screen.dart';

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

class _BarsScreenState extends State<BarsScreen> with WidgetsBindingObserver {
  int _selectedIndex = 2;
  SSHService? sshService;
  final TextEditingController _commandController = TextEditingController();
  String commandOutput = '';
  String connectionStatus = '';
  bool _isReconnecting = false;
  bool _wasConnectedBeforePause = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    sshService?.disconnect();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _wasConnectedBeforePause = sshService?.isConnected() ?? false;
    } else if (state == AppLifecycleState.resumed) {
      if (_wasConnectedBeforePause && sshService != null) {
        setState(() => _isReconnecting = true);
        sshService!.reconnect().then((_) {
          if (mounted) {
            setState(() => _isReconnecting = false);
          }
        }).catchError((_) {
          if (mounted) {
            setState(() => _isReconnecting = false);
          }
        });
      }
    }
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

  void _setSSHService(SSHService? service) {
    setState(() {
      sshService = service;
      connectionStatus = service != null
          ? 'Connected to ${service.name} (${service.host})'
          : ''; 
  });
}

  void _logOff() {
    sshService?.disconnect();
    setState(() {
      connectionStatus = 'Disconnected from ${sshService?.name} (${sshService?.host})';
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
    if (_isReconnecting) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Raspberry Pi Control'),
          actions: [
            IconButton(
              icon: Icon(widget.isDarkMode ? Icons.dark_mode : Icons.light_mode),
              onPressed: widget.toggleTheme,
            ),
          ],
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Reconnecting to server...'),
            ],
          ),
        ),
      );
    }

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
          ? TerminalScreen(
              sshService: sshService,
              commandController: _commandController,
              commandOutput: commandOutput,
              sendCommand: _sendCommand,
            )
          : _selectedIndex == 2
              ? ConnectionScreen(
                  setSSHService: _setSSHService,
                  connectionStatus: connectionStatus,
                )
              : FileExplorerScreen(
                  sshService: sshService,
                ),
            bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.code),
            label: 'Terminal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.connect_without_contact),
            label: 'Connections',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.file_copy),
            label: 'File Explorer',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
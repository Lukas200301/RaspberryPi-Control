import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter/services.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'services/ssh_service.dart';
import 'connection_screen.dart';
import 'terminal_screen.dart';
import 'stats_screen.dart';
import 'file_explorer_screen.dart';
import 'services/first_launch_notice.dart';

class BackgroundService {
  static final BackgroundService _instance = BackgroundService._internal();
  static BackgroundService get instance => _instance;
  bool _initialized = false;
  bool _isEnabled = false;
  final _platform = const MethodChannel('com.example.flutter_application_1/background');
  BuildContext? _context;

  BackgroundService._internal();

  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      const androidConfig = FlutterBackgroundAndroidConfig(
        notificationTitle: "Raspberry Pi Control",
        notificationText: "Running in background",
        notificationImportance: AndroidNotificationImportance.Default,
        notificationIcon: AndroidResource(name: 'ic_launcher', defType: 'mipmap'),
        enableWifiLock: true,
      );

      await _platform.invokeMethod('requestNotificationPermissions');
      
      final initialized = await FlutterBackground.initialize(androidConfig: androidConfig);
      if (!initialized) {
        throw Exception('Failed to initialize FlutterBackground');
      }

      _initialized = true;
      
      if (!await FlutterBackground.hasPermissions) {
        final intent = AndroidIntent(
          action: 'android.settings.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS',
          data: 'package:com.example.flutter_application_1',
        );
        await intent.launch();
      }
    } catch (e) {
      print('Failed to initialize background service: $e');
      _initialized = false;
      rethrow;
    }
  }

  void setContext(BuildContext context) {
    _context = context;
  }

  Future<void> _handleDisconnect() async {
    print("Handling disconnect from notification");

    await disableBackground();

    final state = _context?.findAncestorStateOfType<_BarsScreenState>();
    if (state != null && state.mounted) {
      await state._disconnectAndClose(); 
    }
  }


  static void resetAppState(BuildContext context) {
    final state = context.findAncestorStateOfType<_BarsScreenState>();
    if (state != null) {
      state._logOff(); 
    }
  }

  Future<void> enableBackground() async {
    print("Enabling background service...");
    
    if (!_initialized) {
      await initialize();
    }

    try {
      if (await FlutterBackground.hasPermissions) {
        await FlutterBackground.enableBackgroundExecution();
        _isEnabled = true;
        print("Background service enabled");

        await Future.delayed(const Duration(milliseconds: 500));
        await _platform.invokeMethod('updateNotification', {
          'title': 'Raspberry Pi Control',
          'text': 'Connected and running in background'
        });
      } else {
        print("No background permissions");
        throw Exception('Background permissions not granted');
      }
    } catch (e) {
      print("Error in enableBackground: $e");
      throw e;
    }
  }

  Future<void> disableBackground() async {
    if (_isEnabled) {
      _isEnabled = false;
      try {
        await _platform.invokeMethod('updateNotification', {
          'title': '',
          'text': '',
          'clear': true
        });
        await FlutterBackground.disableBackgroundExecution();
      } catch (e) {
        print('Error disabling background service: $e');
      }
    }
  }

  bool get isEnabled => _isEnabled;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await BackgroundService.instance.initialize();
  } catch (e) {
    print('Warning: Background service initialization failed, continuing without background support');
  }

  const platform = MethodChannel('com.example.flutter_application_1/background');
  try {
    await platform.invokeMethod('requestNotificationPermissions');
  } catch (e) {
    print('Failed to request notifications permission: $e');
  }

  runApp(const MyApp(isDarkMode: true));
}

class MyApp extends StatefulWidget {
  final bool isDarkMode;

  const MyApp({
    super.key,
    required this.isDarkMode,
  });

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
      home: Stack(
        children: [
          BarsScreen(
            isDarkMode: isDarkMode,
            toggleTheme: _toggleTheme,
          ),
          const FirstLaunchNotice(), 
        ],
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
    BackgroundService.instance.setContext(context);
    
    const platform = MethodChannel('com.example.flutter_application_1/background');
    platform.setMethodCallHandler((call) async {
      if (call.method == 'onDisconnectRequested' || call.method == 'onDisconnect') {
        if (mounted) {
           _logOff();
        }
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    sshService?.disconnect();
    _stopBackgroundExecution();
    super.dispose();
  }

  Future<void> _stopBackgroundExecution() async {
    await FlutterBackground.disableBackgroundExecution();
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
    print('Setting SSHService: ${service?.name ?? "NULL"}');
    setState(() {
      sshService = service;
      connectionStatus = service != null
          ? 'Connected to ${service.name} (${service.host})'
          : '';
    });
  }

  Future<void> _disconnectAndClose() async {
    if (mounted) {
      await BackgroundService.instance.disableBackground();
      
      if (_selectedIndex == 0) {
        setState(() => _selectedIndex = 2);
        await Future.delayed(const Duration(milliseconds: 300));
      }
      
      sshService?.disconnect();
      SystemNavigator.pop();
    }
  }

  void _logOff() async {
    if (mounted) {
      await BackgroundService.instance.disableBackground();
      setState(() => _selectedIndex = 2);
      await Future.delayed(const Duration(milliseconds: 100));
      sshService?.disconnect();
      
      setState(() {
        connectionStatus = 'Disconnected';
        sshService = null;
        commandOutput = '';
      });
    }
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
      body: IndexedStack(
        key: const ValueKey<String>('main_stack'),
        index: _selectedIndex,
        children: [
          sshService != null
        ? StatsScreen(
            key: const PageStorageKey('stats_screen'),
            sshService: sshService,
          )
        : const Center(child: Text('Please connect first.')),
          TerminalScreen(
            key: const PageStorageKey('terminal_screen'),
            sshService: sshService,
            commandController: _commandController,
            commandOutput: commandOutput,
            sendCommand: _sendCommand,
          ),
          ConnectionScreen(
            key: const PageStorageKey('connection_screen'),
            setSSHService: _setSSHService,
            connectionStatus: connectionStatus,
          ),
          FileExplorerScreen(
            key: const PageStorageKey('file_explorer_screen'),
            sshService: sshService,
          ),
        ],
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
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter/services.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'services/ssh_service.dart';
import 'pages/connection/connection.dart';
import 'pages/terminal/terminal.dart';
import 'pages/stats/stats.dart';
import 'pages/file_explorer/file_explorer.dart';
import 'widgets/first_launch_notice.dart';
import 'widgets/update_notice.dart';
import 'pages/settings/settings.dart';

class BackgroundService {
  static final BackgroundService _instance = BackgroundService._internal();
  static BackgroundService get instance => _instance;
  bool _initialized = false;
  bool _isEnabled = false;
  final _platform = const MethodChannel('com.lukas200301.raspberrypi_control');

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
          data: 'package:com.lukas200301.raspberrypi_control',
        );
        await intent.launch();
      }
    } catch (e) {
      print('Failed to initialize background service: $e');
      _initialized = false;
      rethrow;
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

  const platform = MethodChannel('com.lukas200301.raspberrypi_control');
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
  final GlobalKey<_BarsScreenState> _barsScreenKey = GlobalKey<_BarsScreenState>();

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
            key: _barsScreenKey,
            isDarkMode: isDarkMode,
            toggleTheme: _toggleTheme,
          ),
          const FirstLaunchNotice(),
          UpdateNotice(
            onNavigateToTab: (index) {
              if (_barsScreenKey.currentState != null) {
                _barsScreenKey.currentState!._onItemTapped(index);
              }
            },
          ),
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
  final GlobalKey<FileExplorerState> _fileExplorerKey = GlobalKey<FileExplorerState>();
  String commandOutput = '';
  String connectionStatus = '';
  bool _isReconnecting = false;
  bool _wasConnectedBeforePause = false;
  bool _appJustResumed = false;  
  
  Timer? _securityTimeoutTimer;
  DateTime _lastActivityTime = DateTime.now();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    const platform = MethodChannel('com.lukas200301.raspberrypi_control');
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
    _stopSecurityTimeoutMonitoring();
    WidgetsBinding.instance.removeObserver(this);
    sshService?.disconnect();
    _stopBackgroundExecution();
    super.dispose();
  }

  Future<void> _stopBackgroundExecution() async {
    await FlutterBackground.disableBackgroundExecution();
  }

  void _resetActivityTimer() {
    _lastActivityTime = DateTime.now();
  }
  
  void _startSecurityTimeoutMonitoring() async {
    _stopSecurityTimeoutMonitoring();
    
    final prefs = await SharedPreferences.getInstance();
    final securityTimeout = prefs.getInt('securityTimeout') ?? 0;
    
    if (securityTimeout <= 0) return; 
    
    _securityTimeoutTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (sshService != null && sshService!.isConnected()) {
        final idleMinutes = DateTime.now().difference(_lastActivityTime).inMinutes;
        if (idleMinutes >= securityTimeout) {
          print('Security timeout reached ($securityTimeout min). Logging off.');
          _logOff();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Disconnected due to $securityTimeout minutes of inactivity')),
          );
        }
      }
    });
  }
  
  void _stopSecurityTimeoutMonitoring() {
    _securityTimeoutTimer?.cancel();
    _securityTimeoutTimer = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _wasConnectedBeforePause = sshService?.isConnected() ?? false;
      _appJustResumed = false;
    } else if (state == AppLifecycleState.resumed) {
      _appJustResumed = true;
      
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _appJustResumed = false;
          });
        }
      });
      
      if (_wasConnectedBeforePause && sshService != null) {
        print("App resumed: Attempting reconnection");
        setState(() => _isReconnecting = true);
        
        sshService!.reconnect().then((_) {
          if (mounted) {
            print("Reconnection successful");
            setState(() {
              _isReconnecting = false;
              
              Future.delayed(const Duration(milliseconds: 200), () {
                if (mounted) {
                  setState(() {
                  });
                }
              });
            });
          }
        }).catchError((e) {
          print("Reconnection failed: $e");
          if (mounted) {
            setState(() => _isReconnecting = false);
          }
        });
      }
    }
  }

  void _onItemTapped(int index) {
    // Allow navigation to Connections (2) or Settings (4) without a connection
    // Restrict access to Stats (0), Terminal (1), and File Explorer (3) when not connected
    if (sshService == null && index != 2 && index != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please connect first')),
      );
      setState(() {
        _selectedIndex = 2;
      });
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Future<void> _applyScreenWakeLock(bool keepOn) async {
    if (keepOn) {
      if (await Permission.ignoreBatteryOptimizations.isGranted) {
        try {
          await SystemChannels.platform.invokeMethod('SystemChrome.setEnabledSystemUIMode', [SystemUiMode.immersiveSticky]);
          await SystemChannels.platform.invokeMethod('HapticFeedback.vibrate');
          print('Screen wake lock applied');
        } catch (e) {
          print('Error applying screen wake lock: $e');
        }
      } else {
        print('Battery optimization permission not granted, screen may turn off');
      }
    } else {
      try {
        await SystemChannels.platform.invokeMethod('SystemChrome.restoreSystemUIOverlays');
      } catch (e) {
        print('Error resetting screen wake lock: $e');
      }
    }
  }

  Future<void> _loadAndApplySettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    final connectionTimeout = prefs.getInt('connectionTimeout') ?? 30;
    SSHService.defaultConnectionTimeout = connectionTimeout;
    
    final keepScreenOn = prefs.getBool('keepScreenOn') ?? true;
    if (sshService != null && sshService!.isConnected()) {
      await _applyScreenWakeLock(keepScreenOn);
    }
    
    final keepAliveInterval = prefs.getString('sshKeepAliveInterval') ?? '60';
    if (sshService != null) {
      sshService!.setKeepAliveInterval(int.tryParse(keepAliveInterval) ?? 60);
    }
    
    _startSecurityTimeoutMonitoring();
  }

  void _setSSHService(SSHService? service) {
    print('Setting SSHService: ${service?.name ?? "NULL"}');
    
    final bool wasConnected = sshService != null;
    final bool willBeConnected = service != null;
    
    if (service == null && sshService != null) {
      print("Disconnected: Clearing SSH service reference");
      _applyScreenWakeLock(false); 
      sshService?.disconnect();
    }
    
    setState(() {
      sshService = service;
      connectionStatus = service != null
          ? 'Connected to ${service.name} (${service.host})'
          : 'Disconnected';
    });
    
    if (wasConnected && !willBeConnected) {
      print("Disconnected: Enforcing navigation to Connections tab");
      setState(() {
        _selectedIndex = 2;
      });
    }
    
    if (service != null) {
      _resetActivityTimer(); 
      _loadAndApplySettings();
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _fileExplorerKey.currentState != null) {
          _fileExplorerKey.currentState!.loadRootDirectory();
        }
      });
    } else {
      _stopSecurityTimeoutMonitoring(); 
    }
  }

  void _logOff() async {
    if (mounted) {
      await BackgroundService.instance.disableBackground();
      
      _fileExplorerKey.currentState?.resetToRoot();
      
      setState(() => _selectedIndex = 2);
      
      await Future.delayed(const Duration(milliseconds: 100));
      sshService?.disconnect();
      
      setState(() {
        connectionStatus = 'Disconnected';
        sshService = null;
        commandOutput = '';
        
        _enforceNavigationRestrictions();
      });
    }
  }

  void _enforceNavigationRestrictions() {
    if (!_isReconnecting && 
        !_appJustResumed && 
        sshService == null && 
        _selectedIndex != 2 && 
        _selectedIndex != 4) {
      print("Enforcing navigation restrictions: redirecting to Connections tab");
      setState(() {
        _selectedIndex = 2; 
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
    _resetActivityTimer();
    
    if (_isReconnecting) {
      return Scaffold(
        body: SafeArea(
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Reconnecting to server...'),
              ],
            ),
          ),
        ),
      );
    }

    final bool isReconnectionInProgress = _isReconnecting || _appJustResumed;
    final bool isReallyConnected = sshService?.isConnected() ?? false;
    
    if (!isReconnectionInProgress && 
        !isReallyConnected && 
        (_selectedIndex == 0 || _selectedIndex == 1 || _selectedIndex == 3)) {
      print("Not connected but on restricted page - enforcing navigation to Connections tab");
      Future.microtask(() {
        if (mounted) {
          setState(() {
            _selectedIndex = 2; 
          });
        }
      });
    }

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          key: const ValueKey<String>('main_stack'),
          index: _selectedIndex,
          children: [
            sshService != null
              ? Stats(
                  key: const PageStorageKey('stats_screen'),
                  sshService: sshService,
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Please connect first.'),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _onItemTapped(2),  
                        icon: const Icon(Icons.connect_without_contact),
                        label: const Text('Go to Connections'),
                      ),
                    ],
                  ),
                ),
            Terminal(
              key: const PageStorageKey('terminal_screen'),
              sshService: sshService,
              commandController: _commandController,
              commandOutput: commandOutput,
              sendCommand: _sendCommand,
            ),
            Connection(
              key: const PageStorageKey('connection_screen'),
              setSSHService: _setSSHService,
              connectionStatus: connectionStatus,
            ),
            FileExplorer(
              key: _fileExplorerKey,
              sshService: sshService,
            ),
            Settings(
              key: const PageStorageKey('settings_screen'),
              isDarkMode: widget.isDarkMode,
              toggleTheme: widget.toggleTheme,
              logOut: _logOff,
              isConnected: isReallyConnected, 
            ),
          ],
        ),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
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
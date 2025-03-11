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
  int _reconnectionAttempts = 0;
  int _maxReconnectionAttempts = 3;
  int _reconnectionDelay = 5;
  Timer? _reconnectionTimer;
  String _disconnectionReason = '';

  Timer? _securityTimeoutTimer;
  DateTime _lastActivityTime = DateTime.now();
  Timer? _countdownTimer;
  int _remainingSeconds = 0;
  StreamSubscription? _connectionStatusSubscription;
  
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
    _connectionStatusSubscription?.cancel();
    _stopSecurityTimeoutMonitoring();
    _cancelReconnection();
    WidgetsBinding.instance.removeObserver(this);
    sshService?.disconnect();
    _stopBackgroundExecution();
    super.dispose();
  }

  Future<void> _stopBackgroundExecution() async {
    await FlutterBackground.disableBackgroundExecution();
  }

  void _cancelReconnection() {
    _reconnectionTimer?.cancel();
    _reconnectionTimer = null;
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _isReconnecting = false;
    _disconnectionReason = '';
  }

  Future<void> _attemptReconnection() async {
    _cancelReconnection();
    
    final prefs = await SharedPreferences.getInstance();
    _maxReconnectionAttempts = prefs.getInt('autoReconnectAttempts') ?? 3;
    _reconnectionDelay = prefs.getInt('connectionRetryDelay') ?? 5;
    final autoReconnect = prefs.getBool('autoReconnect') ?? true;
    
    // If auto-reconnect is disabled or no service to reconnect to
    if (!autoReconnect || sshService == null) {
      if (mounted) {
        _disconnect();
        setState(() {
          _selectedIndex = 2; // Go to connection tab immediately
        });
      }
      return;
    }
    
    setState(() {
      _isReconnecting = true;
      _reconnectionAttempts = 0; // Reset counter
      _remainingSeconds = _reconnectionDelay;
    });
    
    // Start the countdown timer for the first reconnection attempt
    _startReconnectionTimer();
  }
  
  void _startReconnectionTimer() {
    _countdownTimer?.cancel();
    
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted && _remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
        
        if (_remainingSeconds == 0 && _isReconnecting) {
          timer.cancel();
          _executeReconnection();
        }
      }
    });
  }
  
  Future<void> _executeReconnection() async {
    if (!mounted || sshService == null) return;
    
    // Increment attempt counter before checking if we've exceeded maximum attempts
    setState(() {
      _reconnectionAttempts++;
    });
    
    // Check if we've reached or exceeded the maximum number of attempts
    if (_reconnectionAttempts > _maxReconnectionAttempts) {
      _giveUpReconnection();
      return;
    }
    
    try {
      await sshService!.reconnect().timeout(
        Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Connection timed out'),
      );
      
      if (mounted) {
        setState(() {
          _isReconnecting = false;
          connectionStatus = 'Connected to ${sshService!.name} (${sshService!.host})';
        });
        
        // Make sure the connection page gets updated with the new connection status
        _setSSHService(sshService);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully reconnected!'),
            backgroundColor: Colors.green,
          )
        );
      }
    } catch (e) {
      print("Reconnection attempt $_reconnectionAttempts failed: $e");
      
      if (mounted) {
        setState(() {
          _disconnectionReason = e.toString();
        });
        
        // Check if we've reached the maximum attempts
        if (_reconnectionAttempts >= _maxReconnectionAttempts) {
          _disconnect();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to reconnect after $_maxReconnectionAttempts attempts'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            )
          );
        } else {
          // Schedule next attempt
          setState(() {
            _remainingSeconds = _reconnectionDelay;
          });
          _startReconnectionTimer();
        }
      }
    }
  }
  
  void _giveUpReconnection() {
    // Force background service to disable immediately and clear notification
    BackgroundService.instance.disableBackground().then((_) {
      // Clean up any reconnection timers
      _cancelReconnection();

      if (sshService != null) {
        sshService!.disconnect();
        setState(() {
          sshService = null;
          connectionStatus = 'Disconnected';
          _selectedIndex = 2;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to reconnect after $_maxReconnectionAttempts attempts'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        )
      );
    });
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
    } else if (state == AppLifecycleState.resumed) {
      if (_wasConnectedBeforePause && sshService != null) {
        if (!sshService!.isConnected()) {
          _attemptReconnection();
        }
      }
    }
  }

  void _onItemTapped(int index) {
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
    
    _connectionStatusSubscription?.cancel();
    
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
      
      // Listen for connection status changes - make this more responsive
      _connectionStatusSubscription = service.connectionStatus.listen((isConnected) {
        if (!isConnected && mounted) {
          // React immediately to connection loss
          print("Connection lost detected via stream - starting reconnection immediately");
          
          // Only start reconnection if we're not already trying to reconnect
          if (!_isReconnecting) {
            setState(() {
              _disconnectionReason = "Connection lost";
            });
            _attemptReconnection();
          }
        }
      });
      
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
      _cancelReconnection();
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

  void _disconnect() {
    _cancelReconnection();
    
    // Force background service to disable immediately and clear notification
    BackgroundService.instance.disableBackground().then((_) {
      if (sshService != null) {
        sshService!.disconnect();
        setState(() {
          sshService = null;
          connectionStatus = 'Disconnected';
          _selectedIndex = 2; // Go to connections tab
        });
      }
    }).catchError((e) {
      print('Error disabling background service: $e');
      // Even if background service fails, still disconnect
      if (sshService != null) {
        sshService!.disconnect();
        setState(() {
          sshService = null;
          connectionStatus = 'Disconnected';
          _selectedIndex = 2;
        });
      }
    });
  }

  void _enforceNavigationRestrictions() {
    if (sshService == null && _selectedIndex != 2 && _selectedIndex != 4) {
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
    
    // Force reconnection UI immediately when connection is lost
    final bool isReallyConnected = sshService?.isConnected() ?? false;
    if (sshService != null && !isReallyConnected) {
      // Instead of waiting for next frame, immediately set up reconnection state
      if (!_isReconnecting) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_isReconnecting) {
            setState(() {
              _isReconnecting = true;
              _reconnectionAttempts = 0;
              _disconnectionReason = "Connection lost";
              _remainingSeconds = _reconnectionDelay;
            });
            _startReconnectionTimer();
          }
        });
        
        // Return reconnection UI immediately
        return _buildReconnectionUI();
      }
    }
    
    if (_isReconnecting) {
      return _buildReconnectionUI();
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

  Widget _buildReconnectionUI() {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Connection icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.wifi_off_rounded,
                    size: 48,
                    color: colorScheme.primary,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Status text
                Text(
                  'Connection Lost',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Show connection details if we have them
                if (sshService != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      '${sshService!.name} (${sshService!.host})',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                
                // Show disconnection reason if available
                if (_disconnectionReason.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 24),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        _disconnectionReason,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                  ),
                
                const SizedBox(height: 32),
                
                // Progress indicator
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: _maxReconnectionAttempts > 0 ? 
                        _reconnectionAttempts / _maxReconnectionAttempts : 0,
                      backgroundColor: colorScheme.surfaceVariant,
                      strokeWidth: 6,
                    ),
                    Text(
                      '$_reconnectionAttempts/$_maxReconnectionAttempts',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Attempt text and timer
                Text(
                  'Reconnection Attempt $_reconnectionAttempts of $_maxReconnectionAttempts',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Timer display
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 24),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Next attempt in $_remainingSeconds seconds',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        _countdownTimer?.cancel();
                        _executeReconnection();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                        // Improved disconnect flow
                        _disconnect();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Connection closed'),
                            backgroundColor: Colors.blue,
                          )
                        );
                      },
                      icon: const Icon(Icons.close),
                      label: const Text('Disconnect'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
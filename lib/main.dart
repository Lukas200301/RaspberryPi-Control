import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter/services.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:window_manager/window_manager.dart';
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
      if (Platform.isAndroid) {
        const androidConfig = FlutterBackgroundAndroidConfig(
          notificationTitle: "Raspberry Pi Control",
          notificationText: "Running in background",
          notificationImportance: AndroidNotificationImportance.normal,
          notificationIcon: AndroidResource(name: 'ic_launcher', defType: 'mipmap'),
          enableWifiLock: true,
        );
        
        try {
          await _platform.invokeMethod('requestNotificationPermissions');
        } catch (e) {
          print('Failed to request notifications permission: $e');
        }
        
        try {
          final initialized = await FlutterBackground.initialize(androidConfig: androidConfig);
          if (!initialized) {
            throw Exception('Failed to initialize FlutterBackground');
          }
          
          if (!await FlutterBackground.hasPermissions) {
            final intent = AndroidIntent(
              action: 'android.settings.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS',
              data: 'package:com.lukas200301.raspberrypi_control',
            );
            await intent.launch();
          }
        } catch (e) {
          print('Failed to initialize FlutterBackground: $e');
        }
      } else {
        print('Background services not supported on this platform, skipping initialization');
      }
      
      _initialized = true;
    } catch (e) {
      print('Failed to initialize background service: $e');
      _initialized = false;
      rethrow;
    }
  }

  static void resetAppState(BuildContext context) {
    final state = context.findAncestorStateOfType<_MainAppScreenState>();
    if (state != null) {
      state._logOff(); 
    }
  }
  Future<void> enableBackground() async {
    print("Enabling background service...");
    
    if (!_initialized) {
      await initialize();
    }

    if (Platform.isAndroid) {
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
      }
    } else {
      print("Background services not supported on this platform, skipping");
      _isEnabled = false;
    }
  }
  Future<void> disableBackground() async {
    if (_isEnabled) {
      _isEnabled = false;
      
      if (Platform.isAndroid) {
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
      } else {
        print('Background services not supported on this platform, nothing to disable');
      }
    }
  }

  bool get isEnabled => _isEnabled;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    
    final prefs = await SharedPreferences.getInstance();
    double? left = prefs.getDouble('window_left');
    double? top = prefs.getDouble('window_top');
    double? width = prefs.getDouble('window_width');
    double? height = prefs.getDouble('window_height');
    
    WindowOptions windowOptions = WindowOptions(
      size: width != null && height != null 
          ? Size(width, height) 
          : const Size(1000, 800),
      center: (left == null || top == null),
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );
    
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      
      if (left != null && top != null) {
        await windowManager.setPosition(Offset(left, top));
      }
      
      await windowManager.focus();
    });
  }
  
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? true;
  
  try {
    await BackgroundService.instance.initialize();
  } catch (e) {
    print('Warning: Background service initialization failed, continuing without background support');
  }
  const platform = MethodChannel('com.lukas200301.raspberrypi_control');
  if (Platform.isAndroid) {
    try {
      await platform.invokeMethod('requestNotificationPermissions');
    } catch (e) {
      print('Failed to request notifications permission: $e');
    }
  }

  runApp(MyApp(isDarkMode: isDarkMode));
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
  final GlobalKey<_MainAppScreenState> _mainScreenKey = GlobalKey<_MainAppScreenState>();

  @override
  void initState() {
    super.initState();
    isDarkMode = widget.isDarkMode;
  }

  void _toggleTheme() async {
    setState(() {
      isDarkMode = !isDarkMode;
    });
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', isDarkMode);
      print('Theme preference saved: isDarkMode=$isDarkMode');
    } catch (e) {
      print('Failed to save theme preference: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Raspberry Pi Control',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blueAccent,
        colorScheme: ColorScheme.dark(
          primary: Colors.blueAccent,
          secondary: Colors.blueAccent,
        ),
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
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
          MainAppScreen(
            key: _mainScreenKey,
            isDarkMode: isDarkMode,
            toggleTheme: _toggleTheme,
          ),
          const FirstLaunchNotice(),
          UpdateNotice(
            onNavigateToTab: (index) {
              if (_mainScreenKey.currentState != null) {
                _mainScreenKey.currentState!._navigateToPage(index);
              }
            },
          ),
        ],
      ),
    );
  }
}

class MainAppScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback toggleTheme;

  const MainAppScreen({
    super.key,
    required this.isDarkMode,
    required this.toggleTheme,
  });

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> with WidgetsBindingObserver {
  int _currentPageIndex = 2; 
  SSHService? sshService;
  final TextEditingController _commandController = TextEditingController();
  final GlobalKey<FileExplorerState> _fileExplorerKey = GlobalKey<FileExplorerState>();
  String connectionStatus = '';
  bool _isReconnecting = false;
  bool _wasConnectedBeforePause = false;
  bool _appJustResumed = false;  
  
  Timer? _securityTimeoutTimer;
  DateTime _lastActivityTime = DateTime.now();
  
  final List<String> _pageNames = [
    'System Statistics',
    'Terminal',
    'Connections',
    'File Explorer',
    'Settings'
  ];

  final List<IconData> _pageIcons = [
    Icons.analytics_outlined,
    Icons.code_outlined,
    Icons.connect_without_contact_outlined,
    Icons.folder_outlined,
    Icons.settings_outlined,
  ];

  final PageController _pageController = PageController(initialPage: 2);
  
  final GlobalKey<TerminalState> _terminalKey = GlobalKey<TerminalState>();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    _currentPageIndex = 2;
    
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
    WidgetsBinding.instance.removeObserver(this);
    sshService?.disconnect();
    _stopBackgroundExecution();
    _pageController.dispose();
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
      _wasConnectedBeforePause = sshService != null && sshService!.isConnected();
      print("App paused, connection state saved: $_wasConnectedBeforePause");
    } else if (state == AppLifecycleState.resumed) {
      print("App resumed, was connected before: $_wasConnectedBeforePause");
      
      if (sshService != null) {
        sshService!.handleAppResume().then((_) {
          if (mounted) {
            setState(() {
            });
          }
        }).catchError((e) {
          print("Error during app resume reconnection: $e");
        });
      }

      if (_wasConnectedBeforePause && sshService != null) {
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

  bool _isPageChangeAllowed(int index) {
    if (sshService == null || !sshService!.isConnected()) {
      return index == 2 || index == 4;
    }
    return true;
  }
  
  void _handlePageChange(int index) {
    FocusScope.of(context).unfocus();
    
    if (_currentPageIndex == index) return;
    
    if (_currentPageIndex == 1 && _terminalKey.currentState != null) {
      _terminalKey.currentState!.forceReleaseTerminalFocus();
    }
    
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_isPageChangeAllowed(index)) {
        setState(() {
          _currentPageIndex = index;
        });
      } else {
        _pageController.jumpToPage(2);
      }
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isOpeningDrawer = false;

  void _openDrawer() {
    if (_isOpeningDrawer) return;
    _isOpeningDrawer = true;
    
    if (_currentPageIndex == 1 && _terminalKey.currentState != null) {
      print("Releasing terminal focus before opening drawer");
      _terminalKey.currentState!.forceReleaseTerminalFocus();
    }
    
    FocusScope.of(context).unfocus();
    
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted && _scaffoldKey.currentState != null) {
        try {
          _scaffoldKey.currentState!.openDrawer();
        } catch (e) {
          print("Error opening drawer: $e");
        }
      }
      
      Future.delayed(const Duration(milliseconds: 500), () {
        _isOpeningDrawer = false;
      });
    });
  }

  Widget _buildDrawer() {
    final isConnected = sshService != null && sshService!.isConnected();
    final theme = Theme.of(context);
    
    return Drawer(
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
        ),
        child: Column(
          children: [
            Container(
              height: 170,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withBlue(
                      (theme.colorScheme.primary.blue + 30).clamp(0, 255)
                    ),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              alignment: Alignment.bottomLeft,
              child: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Image.asset(
                            'assets/icon/ic_launcher.png', 
                            width: 32,
                            height: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Raspberry Pi\nControl',
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isConnected 
                            ? Colors.green.withOpacity(0.2) 
                            : Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isConnected ? Icons.link : Icons.link_off,
                            size: 14,
                            color: theme.colorScheme.onPrimary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            connectionStatus,
                            style: TextStyle(
                              color: theme.colorScheme.onPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  const SizedBox(height: 8),
                  
                  for (int index = 0; index < _pageNames.length; index++)
                    _buildDrawerItem(index, isConnected, theme),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Divider(
                      color: theme.dividerColor.withOpacity(0.5),
                      thickness: 1,
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                    child: Text(
                      'Preferences',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: theme.colorScheme.primary.withOpacity(0.8),
                      ),
                    ),
                  ),
                  
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    title: Text(widget.isDarkMode ? 'Light Theme' : 'Dark Theme'),
                    onTap: () => _handleThemeToggle(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  ),
                  
                  if (isConnected)
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.logout,
                          color: Colors.red.shade700,
                          size: 20,
                        ),
                      ),
                      title: const Text('Disconnect'),
                      onTap: () => _handleDisconnect(),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(int index, bool isConnected, ThemeData theme) {
    final bool isDisabled = !isConnected && index != 2 && index != 4;
    final bool isSelected = _currentPageIndex == index;
    final primaryColor = theme.colorScheme.primary; 
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? primaryColor.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected 
                ? primaryColor 
                : (isDisabled 
                    ? theme.disabledColor.withOpacity(0.1) 
                    : theme.colorScheme.surface),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _pageIcons[index],
            color: isDisabled 
                ? theme.disabledColor 
                : (isSelected 
                    ? Colors.white 
                    : theme.iconTheme.color),
            size: 20,
          ),
        ),
        title: Text(
          _pageNames[index],
          style: TextStyle(
            color: isDisabled 
                ? theme.disabledColor 
                : (isSelected 
                    ? primaryColor 
                    : theme.textTheme.bodyLarge?.color),
            fontWeight: isSelected 
                ? FontWeight.w600 
                : FontWeight.normal,
          ),
        ),
        onTap: isDisabled ? null : () => _safeNavigateToPage(index),
        selected: isSelected,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _safeNavigateToPage(int index) {
    Navigator.pop(context);
    
    Future.microtask(() {
      if (mounted) {
        if (sshService == null || !sshService!.isConnected()) {
          if (index == 2 || index == 4) {
            _navigateToPage(index);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please connect to a Raspberry Pi first'),
                duration: Duration(seconds: 2),
              ),
            );
            _navigateToPage(2);
          }
        } else {
          _navigateToPage(index);
        }
      }
    });
  }

  void _handleThemeToggle() {
    Navigator.pop(context);
    Future.microtask(() {
      if (mounted) {
        widget.toggleTheme();
      }
    });
  }

  void _handleDisconnect() {
    Navigator.pop(context);
    Future.microtask(() {
      if (mounted) {
        _logOff();
      }
    });
  }

  void _navigateToPage(int index) {
    FocusScope.of(context).unfocus();
    
    if (!_isPageChangeAllowed(index)) {
      setState(() {
        _currentPageIndex = 2;
        _pageController.jumpToPage(2);
      });
    } else {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() {
            _currentPageIndex = index;
          });
          
          _pageController.jumpToPage(index);
        }
      });
    }
  }

  Future<void> _loadAndApplySettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    final connectionTimeout = prefs.getInt('connectionTimeout') ?? 30;
    SSHService.defaultConnectionTimeout = connectionTimeout;
    
    final keepAliveInterval = prefs.getString('sshKeepAliveInterval') ?? '60';
    if (sshService != null) {
      sshService!.setKeepAliveInterval(int.tryParse(keepAliveInterval) ?? 60);
    }
    
    _startSecurityTimeoutMonitoring();
  }

  void _setSSHService(SSHService? service) {    
    final bool wasConnected = sshService != null;
    final bool willBeConnected = service != null;
    
    if (service == null && sshService != null) {
      print("Disconnected: Clearing SSH service reference");
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
        _currentPageIndex = 2;
        _pageController.jumpToPage(2);
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
      
      setState(() => _currentPageIndex = 2);
      _pageController.jumpToPage(2);
      
      await Future.delayed(const Duration(milliseconds: 100));
      sshService?.disconnect();
      
      setState(() {
        connectionStatus = 'Disconnected';
        sshService = null;
        _enforceNavigationRestrictions();
      });
    }
  }

  void _enforceNavigationRestrictions() {
    if (!_isReconnecting && 
        !_appJustResumed && 
        sshService == null && 
        _currentPageIndex != 2 && 
        _currentPageIndex != 4) { 
      print("Enforcing navigation restrictions: redirecting to Connections tab");
      setState(() {
        _currentPageIndex = 2; 
      });
    }
  }

  void _sendCommand() async {
    if (sshService != null) {
      try {
        await sshService!.executeCommand(_commandController.text);
        _commandController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Command error: $e')),
        );
        _commandController.clear();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not connected. Please connect first.')),
      );
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
        _currentPageIndex != 2 && 
        _currentPageIndex != 4 && 
        (_currentPageIndex == 0 || _currentPageIndex == 1 || _currentPageIndex == 3)) {
      print("Not connected but on restricted page - enforcing navigation to Connections tab");
      Future.microtask(() {
        if (mounted) {
          setState(() {
            _currentPageIndex = 2; 
            _pageController.jumpToPage(2);
          });
        }
      });
    }

    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        title: Text(_pageNames[_currentPageIndex]),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: _openDrawer,
        ),
        backgroundColor: Colors.blueAccent, 
        foregroundColor: Colors.white, 
        elevation: 4.0, 
        surfaceTintColor: Colors.transparent, 
      ),
      drawer: Builder(
        builder: (context) => _buildDrawer(),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: PageView(
          controller: _pageController,
          physics: isReallyConnected 
              ? const ClampingScrollPhysics() 
              : const NeverScrollableScrollPhysics(),
          onPageChanged: _handlePageChange,
          children: [
            sshService != null && sshService!.isConnected()
              ? Stats(
                  key: const PageStorageKey('stats_screen'),
                  sshService: sshService,
                )
              : const Center(child: Text('Please connect to a Raspberry Pi first')),
                
            sshService != null && sshService!.isConnected()
              ? Terminal(
                  key: _terminalKey,
                  sshService: sshService,
                  commandController: _commandController,
                  commandOutput: '',
                  sendCommand: _sendCommand,
                )
              : const Center(child: Text('Please connect to a Raspberry Pi first')),
                        
            Connection(
              key: const PageStorageKey('connection_screen'),
              setSSHService: _setSSHService,
              connectionStatus: connectionStatus,
            ),
                
            sshService != null && sshService!.isConnected()
              ? FileExplorer(
                  key: _fileExplorerKey,
                  sshService: sshService,
                )
              : const Center(child: Text('Please connect to a Raspberry Pi first')),
                
            Settings(
              key: const PageStorageKey('settings_screen'),
              isDarkMode: widget.isDarkMode,
              toggleTheme: widget.toggleTheme,
              logOut: _logOff,
              isConnected: sshService != null && sshService!.isConnected(), 
            ),
          ],
        ),
      ),
    );
  }
}
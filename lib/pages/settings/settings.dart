import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/update_service.dart'; 
import 'dart:io'; 
import 'dart:async';
import 'sections/terminal_settings.dart';
import 'sections/stats_settings.dart';
import 'sections/connection_settings.dart';
import 'sections/file_explorer_settings.dart';
import 'sections/data_management.dart';
import 'sections/about_section.dart';
import 'models/dashboard_widget_info.dart';

class Settings extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback toggleTheme;
  final Function? logOut;
  final bool isConnected; 

  static final StreamController<bool> dashboardChangedController = 
      StreamController<bool>.broadcast();
  static Stream<bool> get dashboardChanged => dashboardChangedController.stream;

  static final GlobalKey updateSectionKey = GlobalKey();
  static final ScrollController scrollController = ScrollController();

  static void scrollToUpdates() {
    Future.delayed(const Duration(milliseconds: 1000), () {
      final double targetPosition = 3000; 
      
      scrollController.animateTo(
        targetPosition,
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut,
      );
    });
  }

  const Settings({
    Key? key,
    required this.isDarkMode,
    required this.toggleTheme,
    this.logOut,
    this.isConnected = false, 
  }) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String _appVersion = '';
  int _connectionTimeout = 30; 
  String _sshKeepAliveInterval = '60'; 
  bool _sshCompression = false;
  String _terminalFontSize = '14';
  bool _autoReconnect = true;
  int _autoReconnectAttempts = 3;
  String _defaultDownloadDirectory = '';
  bool _confirmBeforeOverwrite = true;
  int _securityTimeout = 0; 
  bool _showHiddenFiles = false;
  int _connectionRetryDelay = 5;
  bool _isCheckingForUpdates = false;
  Map<String, dynamic>? _updateInfo;
  bool _isDownloadingUpdate = false;
  double _downloadProgress = 0.0;
  String _defaultPort = '22';
  bool _highlightUpdateSection = false;
  
  List<DashboardWidgetInfo> _dashboardWidgets = [];

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _getAppVersion();
    _checkForUpdates();
    _loadDashboardWidgets(); 
  }
  
  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _connectionTimeout = prefs.getInt('connectionTimeout') ?? 30;
      _sshKeepAliveInterval = prefs.getString('sshKeepAliveInterval') ?? '60';
      _sshCompression = prefs.getBool('sshCompression') ?? false;
      _terminalFontSize = prefs.getString('terminalFontSize') ?? '14';
      _autoReconnect = prefs.getBool('autoReconnect') ?? true;
      _autoReconnectAttempts = prefs.getInt('autoReconnectAttempts') ?? 3;
      _defaultDownloadDirectory = prefs.getString('defaultDownloadDirectory') ?? '';
      _confirmBeforeOverwrite = prefs.getBool('confirmBeforeOverwrite') ?? true;
      _securityTimeout = prefs.getInt('securityTimeout') ?? 0;
      _showHiddenFiles = prefs.getBool('showHiddenFiles') ?? false;
      _connectionRetryDelay = prefs.getInt('connectionRetryDelay') ?? 5;
      _defaultPort = prefs.getString('defaultPort') ?? '22';
    });
  }

  Future<void> _getAppVersion() async {
    try {
      final PackageInfo info = await PackageInfo.fromPlatform();
      String version = info.version;
      if (version.contains("+")) {
        version = version.split("+")[0];
      }
      setState(() {
        _appVersion = version;
      });
    } catch (e) {
      setState(() {
        _appVersion = 'Error loading version';
      });
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('connectionTimeout', _connectionTimeout);
    await prefs.setString('sshKeepAliveInterval', _sshKeepAliveInterval);
    await prefs.setBool('sshCompression', _sshCompression);
    await prefs.setString('terminalFontSize', _terminalFontSize);
    
    await prefs.setBool('autoReconnect', _autoReconnect);
    await prefs.setInt('autoReconnectAttempts', _autoReconnectAttempts);
    await prefs.setString('defaultDownloadDirectory', _defaultDownloadDirectory);
    await prefs.setBool('confirmBeforeOverwrite', _confirmBeforeOverwrite);
    await prefs.setInt('securityTimeout', _securityTimeout);
    await prefs.setBool('showHiddenFiles', _showHiddenFiles);
    
    await prefs.setInt('connectionRetryDelay', _connectionRetryDelay);
    await prefs.setString('defaultPort', _defaultPort);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _pickDefaultDirectory() async {
    PermissionStatus status = await Permission.storage.request();
    if (Platform.isAndroid && await Permission.manageExternalStorage.isGranted == false) {
      status = await Permission.manageExternalStorage.request();
    }
    
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Storage permission is required to set a default download directory'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      
      if (selectedDirectory == null) {
        return;
      }
      
      final directory = Directory(selectedDirectory);
      if (!directory.existsSync()) {
        throw Exception('Selected directory does not exist');
      }
      
      try {
        final testFile = File('${directory.path}/testwrite.tmp');
        await testFile.writeAsString('test');
        await testFile.delete();
      } catch (e) {
        throw Exception('Cannot write to the selected directory. Please select a different location.');
      }
      
      setState(() {
        _defaultDownloadDirectory = selectedDirectory;
      });
      
      await _saveSettings();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Default download directory set to: $selectedDirectory'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error setting download directory: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _clearAppData() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear App Data'),
        content: const Text(
          'This will remove all saved connections and settings. This action cannot be undone. Are you sure?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              
              if (widget.logOut != null) {
                widget.logOut!();
              }
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All app data has been cleared'),
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Clear All Data'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchGitHub() async {
    final Uri url = Uri.parse('https://github.com/Lukas200301/RaspberryPi-Control');
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not open GitHub repository');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open GitHub repository: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _clearDefaultDirectory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Default Directory'),
        content: const Text('Are you sure you want to clear the default download directory?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() {
                _defaultDownloadDirectory = '';
              });
              await _saveSettings();
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Default download directory cleared'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  Future<void> _checkForUpdates() async {
    if (_isCheckingForUpdates) return;
    
    setState(() {
      _isCheckingForUpdates = true;
      _updateInfo = null;
    });
    
    try {
      final updateInfo = await UpdateService.checkForUpdates();
      
      if (mounted) {
        setState(() {
          _updateInfo = updateInfo;
          if (updateInfo['updateAvailable'] == true) {
            _highlightUpdateSection = true;
            
            Future.delayed(const Duration(seconds: 10), () {
              if (mounted) {
                setState(() {
                  _highlightUpdateSection = false;
                });
              }
            });
          }
        });
      }
      
      if (updateInfo['updateAvailable'] == true) {
        Settings.scrollToUpdates();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to check for updates: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingForUpdates = false;
        });
      }
    }
  }
  
  Future<void> _downloadAndInstallUpdate() async {
    if (_updateInfo == null || _updateInfo!['downloadUrl'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No download URL available. Opening release page instead.'),
          backgroundColor: Colors.orange,
        ),
      );
      _openReleasePage();
      return;
    }
    
    final downloadUrl = _updateInfo!['downloadUrl'] as String;
    
    setState(() {
      _isDownloadingUpdate = true;
      _downloadProgress = 0.0;
    });
    
    await UpdateService.downloadAndInstallUpdate(
      downloadUrl,
      (progress) {
        setState(() {
          _downloadProgress = progress;
        });
      },
      (error) {
        if (mounted) {
          setState(() {
            _isDownloadingUpdate = false;
          });
          
          if (error.contains('permanently denied') || 
              error.contains('Install unknown apps')) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Permission Required'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(error),
                    const SizedBox(height: 16),
                    const Text(
                      'To enable installation:\n'
                      '1. Tap "Open Settings"\n'
                      '2. Tap "Install unknown apps"\n'
                      '3. Find "Raspberry Pi Control"\n'
                      '4. Toggle "Allow from this source"',
                      style: TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'After enabling the permission, you\'ll need to download the update again.',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      final success = await UpdateService.openInstallPackageSettings();
                      if (!success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Could not open settings. Please enable "Install unknown apps" manually.'),
                            duration: Duration(seconds: 5),
                          ),
                        );
                      }
                    },
                    child: const Text('Open Settings'),
                  ),
                ],
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to download or install update: $error'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: 'Release Page',
                  onPressed: _openReleasePage,
                ),
              ),
            );
          }
        }
      },
      () {
        if (mounted) {
          setState(() {
            _isDownloadingUpdate = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Update download completed. Installation started.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
    );
  }
  
  void _openReleasePage() async {
    if (_updateInfo == null || _updateInfo!['releaseUrl'] == null) return;
    
    try {
      final url = Uri.parse(_updateInfo!['releaseUrl'] as String);
      
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch URL: ${url.toString()}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open release page: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _loadDashboardWidgets() async {
    final prefs = await SharedPreferences.getInstance();
    
    final Map<String, bool> visibilityMap = {};
    final hiddenWidgetsStr = prefs.getStringList('hiddenDashboardWidgets') ?? [];
    for (final widgetId in hiddenWidgetsStr) {
      visibilityMap[widgetId] = false;
    }
    
    final List<String>? savedOrder = prefs.getStringList('dashboardWidgetOrder');
    final allWidgets = DashboardWidgetInfo.getDefaultWidgets();

    if (savedOrder != null && savedOrder.isNotEmpty) {
      final List<DashboardWidgetInfo> orderedWidgets = [];
      
      for (String widgetId in savedOrder) {
        final widget = allWidgets.firstWhere(
          (w) => w.id == widgetId,
          orElse: () => DashboardWidgetInfo(
            id: widgetId,
            name: widgetId.split('_').map((word) => word.capitalize()).join(' '),
            icon: Icons.widgets,
          ),
        );
        
        if (visibilityMap.containsKey(widget.id)) {
          widget.visible = visibilityMap[widget.id]!;
        }
        
        orderedWidgets.add(widget);
      }
      
      for (final widget in allWidgets) {
        if (!orderedWidgets.any((w) => w.id == widget.id)) {
          if (visibilityMap.containsKey(widget.id)) {
            widget.visible = visibilityMap[widget.id]!;
          }
          orderedWidgets.add(widget);
        }
      }
      
      setState(() {
        _dashboardWidgets = orderedWidgets;
      });
    } else {
      for (final widget in allWidgets) {
        if (visibilityMap.containsKey(widget.id)) {
          widget.visible = visibilityMap[widget.id]!;
        }
      }
      
      setState(() {
        _dashboardWidgets = allWidgets;
      });
    }
  }
  
  Future<void> _saveDashboardWidgetSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> orderList = _dashboardWidgets.map((w) => w.id).toList();
    await prefs.setStringList('dashboardWidgetOrder', orderList);
    
    final List<String> hiddenList = _dashboardWidgets
        .where((w) => !w.visible)
        .map((w) => w.id)
        .toList();
    await prefs.setStringList('hiddenDashboardWidgets', hiddenList);

    Settings.dashboardChangedController.add(true);
  }
  
  Future<void> _resetDashboardWidgets() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Dashboard Layout'),
        content: const Text('Are you sure you want to reset all widgets to their default order and visibility?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final prefs = await SharedPreferences.getInstance();
              
              await prefs.remove('dashboardWidgetOrder');
              await prefs.remove('hiddenDashboardWidgets');
              
              setState(() {
                _dashboardWidgets = DashboardWidgetInfo.getDefaultWidgets();
              });
              
              Settings.dashboardChangedController.add(true);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Dashboard layout reset to defaults'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = 112.0;
    
    return Scaffold(
      body: ListView(
        controller: Settings.scrollController,
        padding: EdgeInsets.fromLTRB(16, topPadding, 16, 16),
        children: [
          TerminalSettings(
            terminalFontSize: _terminalFontSize,
            onFontSizeChanged: (value) {
              setState(() {
                _terminalFontSize = value;
              });
            },
            saveSettings: _saveSettings,
          ),
          
          StatsSettings(
            dashboardWidgets: _dashboardWidgets,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }
                final item = _dashboardWidgets.removeAt(oldIndex);
                _dashboardWidgets.insert(newIndex, item);
              });
              _saveDashboardWidgetSettings();
            },
            onVisibilityChanged: (widget, value) {
              setState(() {
                widget.visible = value;
              });
              _saveDashboardWidgetSettings();
            },
            resetDashboardWidgets: _resetDashboardWidgets,
          ),
          
          ConnectionSettings(
            defaultPort: _defaultPort,
            onDefaultPortChanged: (value) {
              setState(() {
                _defaultPort = value;
              });
            },
            autoReconnect: _autoReconnect,
            onAutoReconnectChanged: (value) {
              setState(() {
                _autoReconnect = value;
              });
            },
            autoReconnectAttempts: _autoReconnectAttempts,
            onAutoReconnectAttemptsChanged: (value) {
              setState(() {
                _autoReconnectAttempts = value!;
              });
            },
            connectionRetryDelay: _connectionRetryDelay,
            onConnectionRetryDelayChanged: (value) {
              setState(() {
                _connectionRetryDelay = value!;
              });
            },
            connectionTimeout: _connectionTimeout,
            onConnectionTimeoutChanged: (value) {
              setState(() {
                _connectionTimeout = value!;
              });
            },
            sshKeepAliveInterval: _sshKeepAliveInterval,
            onSshKeepAliveIntervalChanged: (value) {
              setState(() {
                _sshKeepAliveInterval = value;
              });
            },
            securityTimeout: _securityTimeout,
            onSecurityTimeoutChanged: (value) {
              setState(() {
                _securityTimeout = value!;
              });
            },
            sshCompression: _sshCompression,
            onSshCompressionChanged: (value) {
              setState(() {
                _sshCompression = value;
              });
            },
            saveSettings: _saveSettings,
          ),
          
          FileExplorerSettings(
            showHiddenFiles: _showHiddenFiles,
            onShowHiddenFilesChanged: (value) {
              setState(() {
                _showHiddenFiles = value;
              });
            },
            confirmBeforeOverwrite: _confirmBeforeOverwrite,
            onConfirmBeforeOverwriteChanged: (value) {
              setState(() {
                _confirmBeforeOverwrite = value;
              });
            },
            defaultDownloadDirectory: _defaultDownloadDirectory,
            pickDefaultDirectory: _pickDefaultDirectory,
            clearDefaultDirectory: _clearDefaultDirectory,
            saveSettings: _saveSettings,
          ),
          
          DataManagementSettings(
            clearAppData: _clearAppData,
          ),
          
          AboutSection(
            appVersion: _appVersion,
            isCheckingForUpdates: _isCheckingForUpdates,
            updateInfo: _updateInfo,
            isDownloadingUpdate: _isDownloadingUpdate,
            downloadProgress: _downloadProgress,
            highlightUpdateSection: _highlightUpdateSection,
            checkForUpdates: _checkForUpdates,
            downloadAndInstallUpdate: _downloadAndInstallUpdate,
            openReleasePage: _openReleasePage,
            launchGitHub: _launchGitHub,
            updateSectionKey: Settings.updateSectionKey,
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

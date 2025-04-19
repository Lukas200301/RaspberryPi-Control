import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/update_service.dart'; 
import 'dart:io'; 

class Settings extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback toggleTheme;
  final Function? logOut;
  final bool isConnected;  

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
    required this.isConnected,  
  }) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String _appVersion = '';
  int _connectionTimeout = 30; 
  bool _keepScreenOn = true;
  String _sshKeepAliveInterval = '60'; 
  bool _sshCompression = false;
  String _terminalFontSize = '14';
  String _defaultDownloadDirectory = '';
  bool _confirmBeforeOverwrite = true;
  int _securityTimeout = 0; 
  bool _showHiddenFiles = false;
  String _defaultPort = '22';
  bool _highlightUpdateSection = false;
  bool _isCheckingForUpdates = false;
  Map<String, dynamic>? _updateInfo;
  bool _isDownloadingUpdate = false;
  double _downloadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _getAppVersion();
    _checkForUpdates();
  }
  
  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _connectionTimeout = prefs.getInt('connectionTimeout') ?? 30;
      _keepScreenOn = prefs.getBool('keepScreenOn') ?? true;
      _sshKeepAliveInterval = prefs.getString('sshKeepAliveInterval') ?? '60';
      _sshCompression = prefs.getBool('sshCompression') ?? false;
      _terminalFontSize = prefs.getString('terminalFontSize') ?? '14';
      _defaultDownloadDirectory = prefs.getString('defaultDownloadDirectory') ?? '';
      _confirmBeforeOverwrite = prefs.getBool('confirmBeforeOverwrite') ?? true;
      _securityTimeout = prefs.getInt('securityTimeout') ?? 0;
      _showHiddenFiles = prefs.getBool('showHiddenFiles') ?? false;
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
    await prefs.setBool('keepScreenOn', _keepScreenOn);
    await prefs.setString('sshKeepAliveInterval', _sshKeepAliveInterval);
    await prefs.setBool('sshCompression', _sshCompression);
    await prefs.setString('terminalFontSize', _terminalFontSize);
    await prefs.setString('defaultDownloadDirectory', _defaultDownloadDirectory);
    await prefs.setBool('confirmBeforeOverwrite', _confirmBeforeOverwrite);
    await prefs.setInt('securityTimeout', _securityTimeout);
    await prefs.setBool('showHiddenFiles', _showHiddenFiles);
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

  String _cleanMarkdown(String markdown) {
    String text = markdown;
    
    text = text.replaceAllMapped(RegExp(r'#{1,6}\s+(.+?)$', multiLine: true), (match) {
      return '\n${match.group(1)}\n';
    });
    
    text = text.replaceAllMapped(RegExp(r'^(\s*[-*+]|\s*\d+\.)\s+(.+?)$', multiLine: true), (match) {
      return '• ${match.group(2)}\n';
    });
    
    text = text.replaceAllMapped(RegExp(r'\*\*(.+?)\*\*'), (match) {
      return match.group(1) ?? '';
    });
    text = text.replaceAllMapped(RegExp(r'__(.+?)__'), (match) {
      return match.group(1) ?? '';
    });
    text = text.replaceAllMapped(RegExp(r'\*(.+?)\*'), (match) {
      return match.group(1) ?? '';
    });
    text = text.replaceAllMapped(RegExp(r'_(.+?)_'), (match) {
      return match.group(1) ?? '';
    });
    text = text.replaceAllMapped(RegExp(r'\[([^\]]+)\]\([^\)]+\)'), (match) {
      return match.group(1) ?? '';
    });
    text = text.replaceAllMapped(RegExp(r'```(?:\w+)?\n(.*?)```', dotAll: true), (match) {
      return '\n${match.group(1)}\n';
    });
    text = text.replaceAllMapped(RegExp(r'`([^`]+)`'), (match) {
      return match.group(1) ?? '';
    });
    text = text.replaceAll(RegExp(r'^(---|\*\*\*|___)$', multiLine: true), '\n—————\n');
    text = text.replaceAllMapped(RegExp(r'^>\s+(.+?)$', multiLine: true), (match) {
      return '″${match.group(1)}″\n';
    });
    text = text.replaceAll(RegExp(r'<[^>]*>'), '');
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    return text.trim();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        controller: Settings.scrollController, 
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Appearance'),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            subtitle: const Text('Toggle between light and dark theme'),
            value: widget.isDarkMode,
            onChanged: (value) => widget.toggleTheme(),
          ),

          const SizedBox(height: 16),
          
          _buildSectionHeader('Terminal Settings'),
          ListTile(
            leading: const Icon(Icons.text_fields),
            title: const Text('Terminal Font Size'),
            subtitle: const Text('Adjust text size for better readability in terminal'),
            trailing: SizedBox(
              width: 70,
              child: TextFormField(
                initialValue: _terminalFontSize,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  setState(() {
                    _terminalFontSize = value;
                  });
                  _saveSettings();
                },
              ),
            ),
          ),

          const SizedBox(height: 16),
          
          _buildSectionHeader('Connection Settings'),
          ListTile(
            leading: const Icon(Icons.numbers),
            title: const Text('Default SSH Port'),
            subtitle: const Text('Default port used when adding new connections'),
            trailing: SizedBox(
              width: 70,
              child: TextFormField(
                initialValue: _defaultPort,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  setState(() {
                    _defaultPort = value.isEmpty ? '22' : value;
                  });
                  _saveSettings();
                },
              ),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.compress),
            title: const Text('SSH Compression'),
            subtitle: const Text('Save data usage on slow networks (may reduce performance)'),
            value: _sshCompression,
            onChanged: (value) {
              setState(() {
                _sshCompression = value;
              });
              _saveSettings();
            },
          ),

          const SizedBox(height: 16),
          _buildSectionHeader('File Explorer Settings'),
          
          SwitchListTile(
            secondary: const Icon(Icons.visibility),
            title: const Text('Show Hidden Files'),
            subtitle: const Text('Display files starting with a dot (.)'),
            value: _showHiddenFiles,
            onChanged: (value) {
              setState(() {
                _showHiddenFiles = value;
              });
              _saveSettings();
            },
          ),
          
          SwitchListTile(
            secondary: const Icon(Icons.warning),
            title: const Text('Confirm File Overwrite'),
            subtitle: const Text('Ask before replacing existing files'),
            value: _confirmBeforeOverwrite,
            onChanged: (value) {
              setState(() {
                _confirmBeforeOverwrite = value;
              });
              _saveSettings();
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.folder),
            title: const Text('Default Download Directory'),
            subtitle: Text(_defaultDownloadDirectory.isEmpty 
                ? 'Not set (will ask each time)' 
                : _defaultDownloadDirectory),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_defaultDownloadDirectory.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _clearDefaultDirectory,
                    tooltip: 'Clear default directory',
                  ),
                IconButton(
                  icon: const Icon(Icons.folder_open),
                  onPressed: _pickDefaultDirectory,
                  tooltip: 'Select default directory',
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          
          _buildSectionHeader('Data Management'),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Clear App Data'),
            subtitle: const Text('Reset all settings and delete saved connections (cannot be undone)'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: _clearAppData,
          ),
          
          const SizedBox(height: 16),
          _buildSectionHeader('About'),
          
          AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: _highlightUpdateSection ? [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  blurRadius: 15,
                  spreadRadius: 2,
                )
              ] : [],
            ),
            padding: _highlightUpdateSection ? const EdgeInsets.all(4) : EdgeInsets.zero,
            child: Card(
              key: Settings.updateSectionKey,
              shape: _highlightUpdateSection ? 
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ) : null,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'App Version',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _appVersion,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        _isCheckingForUpdates
                            ? const CircularProgressIndicator()
                            : ElevatedButton.icon(
                                icon: const Icon(Icons.refresh),
                                label: const Text('Check for Updates'),
                                onPressed: _checkForUpdates,
                              ),
                      ],
                    ),
                    
                    if (_updateInfo != null) ...[
                      const SizedBox(height: 16),
                      if (_updateInfo!['updateAvailable'] == true) ...[
                        Text(
                          'New version available: ${_updateInfo!['latestVersion']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        
                        if (_updateInfo!.containsKey('newerReleases') && (_updateInfo!['newerReleases'] as List).length > 1) ...[
                          Text(
                            'Contains ${(_updateInfo!['newerReleases'] as List).length} updates since your version',
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 12,
                            ),
                          ),
                        ],
                        
                        const SizedBox(height: 8),
                        if (_updateInfo!['releaseNotes'] != null)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _cleanMarkdown(_updateInfo!['releaseNotes']),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                        if (_isDownloadingUpdate) ...[
                          LinearProgressIndicator(value: _downloadProgress),
                          const SizedBox(height: 8),
                          Text(
                            'Downloading... ${(_downloadProgress * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ] else ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.file_download),
                                  label: const Text('Download & Install'),
                                  onPressed: _downloadAndInstallUpdate,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextButton.icon(
                                  icon: const Icon(Icons.open_in_new),
                                  label: const Text('Open Release Page'),
                                  onPressed: _openReleasePage,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ] else ...[
                        Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 8),
                            Text(
                              'You are using the latest version ($_appVersion).',
                              style: const TextStyle(color: Colors.green),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),
          
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('GitHub Repository'),
            subtitle: const Text('Report issues, view source code, suggest features or contribute code'),
            trailing: const Icon(Icons.open_in_new),
            onTap: _launchGitHub,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8, top: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
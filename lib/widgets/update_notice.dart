import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/update_service.dart';
import '../pages/settings/settings.dart';

class UpdateNotice extends StatefulWidget {
  final Function(int)? onNavigateToTab;
  
  const UpdateNotice({
    Key? key, 
    this.onNavigateToTab,
  }) : super(key: key);

  @override
  State<UpdateNotice> createState() => _UpdateNoticeState();
}

class _UpdateNoticeState extends State<UpdateNotice> {
  bool _showUpdateDialog = false;
  bool _checking = true;
  Map<String, dynamic>? _updateInfo;
  String? _dismissedVersion;

  @override
  void initState() {
    super.initState();
    _checkForUpdates();
  }

  Future<void> _checkForUpdates() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDismissed = prefs.getInt('update_dismissed_timestamp') ?? 0;
    _dismissedVersion = prefs.getString('update_dismissed_version');
    
    final sevenDaysInMs = 7 * 24 * 60 * 60 * 1000;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    try {
      final updateInfo = await UpdateService.checkForUpdates();
      
      setState(() {
        _updateInfo = updateInfo;
        _checking = false;
        
        final bool updateAvailable = updateInfo['updateAvailable'] == true;
        final bool timeExpired = now - lastDismissed >= sevenDaysInMs;
        final bool newerThanDismissed = _dismissedVersion == null || 
            (_dismissedVersion != updateInfo['latestVersion']);
            
        _showUpdateDialog = updateAvailable && (timeExpired || newerThanDismissed);
      });
    } catch (e) {
      print('Error checking for updates: $e');
      setState(() {
        _checking = false;
      });
    }
  }

  void _dismissUpdate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('update_dismissed_timestamp', DateTime.now().millisecondsSinceEpoch);
    
    if (_updateInfo != null && _updateInfo!['latestVersion'] != null) {
      await prefs.setString('update_dismissed_version', _updateInfo!['latestVersion']);
    }
    
    if (mounted) {
      setState(() {
        _showUpdateDialog = false;
      });
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

  @override
  Widget build(BuildContext context) {
    if (_checking || !_showUpdateDialog || _updateInfo == null) {
      return const SizedBox.shrink();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_showUpdateDialog && mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('New Version Available'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('An update for Raspberry Pi Control is ready to install.'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontSize: 13,
                      ),
                      children: [
                        TextSpan(text: 'Version: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: '${_updateInfo!['currentVersion']} → ${_updateInfo!['latestVersion']}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'You can install this update through the Settings.',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Patch Notes:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Container(
                  height: 120,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _cleanMarkdown(_updateInfo!['releaseNotes'] ?? 'No release notes available'),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _dismissUpdate();
                  Navigator.of(context).pop();
                },
                child: const Text('Remind me later'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  
                  if (widget.onNavigateToTab != null) {
                    widget.onNavigateToTab!(4); 
                    
                    Settings.scrollToUpdates();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please go to Settings to update the app'))
                    );
                  }
                },
                child: const Text('Go to Settings'),
              ),
            ],
          ),
        );
      }
    });

    return const SizedBox.shrink();
  }
}

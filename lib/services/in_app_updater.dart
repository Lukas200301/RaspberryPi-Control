import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class InAppUpdater {
  static final InAppUpdater _instance = InAppUpdater._internal();
  factory InAppUpdater() => _instance;
  InAppUpdater._internal();

  final StreamController<double> _progressController = StreamController<double>.broadcast();
  final StreamController<String> _statusController = StreamController<String>.broadcast();
  final StreamController<bool> _completedController = StreamController<bool>.broadcast();

  Stream<double> get progressStream => _progressController.stream;
  Stream<String> get statusStream => _statusController.stream;
  Stream<bool> get completedStream => _completedController.stream;

  bool _isUpdating = false;
  bool get isUpdating => _isUpdating;

  static Future<void> showUpdateDialog(
    BuildContext context, 
    String downloadUrl, 
    String version,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _UpdateProgressDialog(
        version: version,
        onClose: () {
          Navigator.of(context).pop();
        },
      ),
    );
    
    final updater = InAppUpdater();
    await updater.updateInApp(
      downloadUrl: downloadUrl,
      onRestartRequired: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Update complete. The app will restart momentarily.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
          ),
        );
      },
    );
  }

  Future<bool> updateInApp({
    required String downloadUrl,
    required VoidCallback onRestartRequired,
  }) async {
    if (_isUpdating) {
      _statusController.add('An update is already in progress');
      return false;
    }

    _isUpdating = true;
    _progressController.add(0.0);
    _statusController.add('Starting update...');

    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String fileName = downloadUrl.split('/').last;
      final String filePath = '${tempDir.path}\\$fileName';
      final File file = File(filePath);

      if (file.existsSync()) {
        await file.delete();
        _statusController.add('Preparing for download...');
      }

      _statusController.add('Downloading update...');

      final client = http.Client();
      try {
        final response = await client.send(http.Request('GET', Uri.parse(downloadUrl)));
        
        if (response.statusCode != 200) {
          throw Exception('Failed to download update: HTTP ${response.statusCode}');
        }
        
        final contentLength = response.contentLength ?? 0;
        int totalBytesDownloaded = 0;
        
        final fileStream = file.openWrite();
        
        await response.stream.forEach((data) {
          fileStream.add(data);
          totalBytesDownloaded += data.length;
          
          if (contentLength > 0) {
            final progress = totalBytesDownloaded / contentLength;
            _progressController.add(progress);
            
            if (progress < 0.3 && (totalBytesDownloaded % 50000) < 1000) {
              _statusController.add('Downloading update... ${(progress * 100).toStringAsFixed(1)}%');
            }
          }
        });
        
        await fileStream.flush();
        await fileStream.close();
        
        _statusController.add('Download complete, preparing installation...');
        _progressController.add(0.5); 
      } finally {
        client.close();
      }      final String restartBatchPath = '${tempDir.path}\\restart_after_update.bat';
      final File restartBatch = File(restartBatchPath);
      
      final String executablePath = Platform.resolvedExecutable;
      final String processId = pid.toString();
      
      final String batchContent = '''
@echo off
echo Starting background installation...
"${filePath}" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /NOICONS /CLOSEAPPLICATIONS=no
echo Installation completed, restarting application...
taskkill /F /PID ${processId} 2>nul
timeout /t 1 /nobreak > nul
start "" /b "${executablePath}"
del "${filePath}" 2>nul
exit
''';

      await restartBatch.writeAsString(batchContent);
      _statusController.add('Installing update...');
      _progressController.add(0.7);

      await Future.delayed(const Duration(milliseconds: 800));
      
      await Process.start(
        'cmd.exe',
        ['/c', 'start', '/min', restartBatchPath],
        mode: ProcessStartMode.detached,
        runInShell: true,
      );

      _statusController.add('Update will be applied shortly...');
      _progressController.add(1.0);
      _completedController.add(true);
      
      await Future.delayed(const Duration(seconds: 1));
      onRestartRequired();
      
      return true;
    } catch (e) {
      print('Error during in-app update: $e');
      _statusController.add('Update failed: $e');
      _completedController.add(false);
      return false;
    } finally {
      _isUpdating = false;
    }
  }

  void dispose() {
    _progressController.close();
    _statusController.close();
    _completedController.close();
  }
}

class _UpdateProgressDialog extends StatefulWidget {
  final String version;
  final VoidCallback onClose;

  const _UpdateProgressDialog({
    Key? key, 
    required this.version,
    required this.onClose,
  }) : super(key: key);

  @override
  State<_UpdateProgressDialog> createState() => _UpdateProgressDialogState();
}

class _UpdateProgressDialogState extends State<_UpdateProgressDialog> {
  double _progress = 0.0;
  String _status = 'Preparing...';
  bool _isCompleted = false;
  final InAppUpdater _updater = InAppUpdater();

  @override
  void initState() {
    super.initState();
    _subscribeToUpdates();
  }

  void _subscribeToUpdates() {
    _updater.progressStream.listen((progress) {
      setState(() {
        _progress = progress;
      });
    });

    _updater.statusStream.listen((status) {
      setState(() {
        _status = status;
      });
    });

    _updater.completedStream.listen((completed) {
      setState(() {
        _isCompleted = completed;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).dialogBackgroundColor,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: const Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  _isCompleted ? Icons.check_circle : Icons.system_update_alt,
                  color: _isCompleted ? Colors.green : Theme.of(context).primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _isCompleted 
                        ? 'Update Complete!' 
                        : 'Updating to version ${widget.version}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _isCompleted ? Colors.green : Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _status,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  '${(_progress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _isCompleted
                ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size.fromHeight(40),
                    ),
                    onPressed: widget.onClose,
                    child: const Text('Close'),
                  )
                : const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Please keep the app open while the update is being installed.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'transfer_manager_service.dart';

/// UI Bridge for Transfer Manager
/// Handles permissions, folder picking, and communication with background service
class TransferService {
  StreamSubscription? _eventSubscription;
  final List<Function(String type, Map<String, dynamic>? data)> _listeners = [];

  /// Initialize and start listening to events
  void initialize() {
    _eventSubscription = TransferManagerService.events.listen((event) {
      if (event == null) return;

      final type = event['type'] as String?;
      final data = event['data'] as Map<String, dynamic>?;

      if (type != null) {
        for (final listener in _listeners) {
          listener(type, data);
        }
      }
    });
  }

  /// Add an event listener
  void addListener(Function(String type, Map<String, dynamic>? data) listener) {
    _listeners.add(listener);
  }

  /// Remove an event listener
  void removeListener(Function(String type, Map<String, dynamic>? data) listener) {
    _listeners.remove(listener);
  }

  /// Dispose and clean up
  void dispose() {
    _eventSubscription?.cancel();
    _listeners.clear();
  }

  /// Request storage permissions
  Future<bool> requestStoragePermissions(BuildContext context) async {
    // For Android 11+, we need MANAGE_EXTERNAL_STORAGE
    if (await Permission.manageExternalStorage.isDenied) {
      if (context.mounted) {
        final shouldRequest = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Storage Permission Required'),
            content: const Text(
              'This app needs permission to access your device storage to download files. '
              'Please grant "Allow management of all files" permission.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Grant Permission'),
              ),
            ],
          ),
        );

        if (shouldRequest != true) return false;
      }

      final status = await Permission.manageExternalStorage.request();
      return status.isGranted;
    }

    return true;
  }

  /// Pick a folder and download a remote file
  Future<void> pickFolderAndDownloadFile({
    required BuildContext context,
    required String remotePath,
  }) async {
    try {
      // Check permissions
      final hasPermission = await requestStoragePermissions(context);
      if (!hasPermission) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Storage permission is required to download files'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Pick save location
      final fileName = remotePath.split('/').last;
      final localPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save $fileName',
        fileName: fileName,
      );

      if (localPath == null) {
        debugPrint('TransferService: User cancelled file save');
        return;
      }

      // Start download
      TransferManagerService.downloadFile(
        remotePath: remotePath,
        localPath: localPath,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Downloading $fileName...', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.blue.shade700,
          ),
        );
      }
    } catch (e) {
      debugPrint('TransferService: Error in pickFolderAndDownloadFile: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Pick a folder and download an entire directory recursively
  Future<void> pickFolderAndDownload({
    required BuildContext context,
    required String remotePath,
  }) async {
    try {
      // Check permissions
      final hasPermission = await requestStoragePermissions(context);
      if (!hasPermission) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Storage permission is required to download folders'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Pick destination folder
      final folderPath = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Select download destination',
      );

      if (folderPath == null) {
        debugPrint('TransferService: User cancelled folder selection');
        return;
      }

      // Create the target folder path
      final folderName = remotePath.split('/').last;
      final localPath = '$folderPath/$folderName';

      // Show confirmation
      if (context.mounted) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Download Folder'),
            content: Text(
              'Download "$folderName" to:\n$localPath\n\n'
              'This will recursively download all files and subfolders.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Download'),
              ),
            ],
          ),
        );

        if (confirmed != true) return;
      }

      // Start folder download
      TransferManagerService.downloadFolder(
        remotePath: remotePath,
        localPath: localPath,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Downloading folder: $folderName...', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.blue.shade700,
          ),
        );
      }
    } catch (e) {
      debugPrint('TransferService: Error in pickFolderAndDownload: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Pick a file and upload it
  Future<void> pickFileAndUpload({
    required BuildContext context,
    required String remoteDirectory,
  }) async {
    try {
      // Pick file
      final result = await FilePicker.platform.pickFiles();
      if (result == null) {
        debugPrint('TransferService: User cancelled file selection');
        return;
      }

      final localPath = result.files.single.path;
      if (localPath == null) {
        debugPrint('TransferService: No file path');
        return;
      }

      final fileName = localPath.split('/').last;
      final remotePath = '$remoteDirectory/$fileName';

      // Start upload
      TransferManagerService.uploadFile(
        localPath: localPath,
        remotePath: remotePath,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Uploading $fileName...')),
        );
      }
    } catch (e) {
      debugPrint('TransferService: Error in pickFileAndUpload: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Pick a folder and upload it recursively
  Future<void> pickFolderAndUpload({
    required BuildContext context,
    required String remoteDirectory,
  }) async {
    try {
      // Check permissions
      final hasPermission = await requestStoragePermissions(context);
      if (!hasPermission) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Storage permission is required to upload folders'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Pick local folder
      final localFolderPath = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Select folder to upload',
      );

      if (localFolderPath == null) {
        debugPrint('TransferService: User cancelled folder selection');
        return;
      }

      // Get folder name
      final folderName = localFolderPath.split('/').last;
      final remotePath = '$remoteDirectory/$folderName';

      // Show confirmation
      if (context.mounted) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Upload Folder'),
            content: Text(
              'Upload "$folderName" to:\n$remotePath\n\n'
              'This will recursively upload all files and subfolders.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Upload'),
              ),
            ],
          ),
        );

        if (confirmed != true) return;
      }

      // Start folder upload
      TransferManagerService.uploadFolder(
        localPath: localFolderPath,
        remotePath: remotePath,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Uploading folder: $folderName...', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.blue.shade700,
          ),
        );
      }
    } catch (e) {
      debugPrint('TransferService: Error in pickFolderAndUpload: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Connect to SFTP server
  void connect({
    required String host,
    required int port,
    required String username,
    required String password,
  }) {
    TransferManagerService.connect(
      host: host,
      port: port,
      username: username,
      password: password,
    );
  }

  /// Disconnect from SFTP server
  void disconnect() {
    TransferManagerService.disconnect();
  }

  /// Start the background service
  static Future<void> start() async {
    await TransferManagerService.start();
  }

  /// Stop the background service
  static Future<void> stop() async {
    await TransferManagerService.stop();
  }
}

import 'dart:async';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/foundation.dart';
import '../models/file_item.dart';

/// Service for handling SFTP file operations
class SftpService {
  final SSHClient sshClient;
  late final SftpClient _sftp;
  bool _isInitialized = false;

  SftpService(this.sshClient);

  /// Initialize SFTP client
  Future<void> initialize() async {
    if (_isInitialized) return;
    _sftp = await sshClient.sftp();
    _isInitialized = true;
  }

  /// List files in a directory
  Future<List<FileItem>> listDirectory(String path) async {
    await initialize();

    try {
      debugPrint('SFTP: Listing directory: $path');
      final items = await _sftp.listdir(path);
      debugPrint('SFTP: Found ${items.length} items in $path');
      final List<FileItem> fileItems = [];

      for (final item in items) {
        // Skip . and ..
        if (item.filename == '.' || item.filename == '..') continue;

        final fullPath = path.endsWith('/') 
            ? '$path${item.filename}' 
            : '$path/${item.filename}';

        final mode = item.attr.mode;
        final modeInt = mode?.value ?? 0;
        
        fileItems.add(FileItem(
          name: item.filename,
          path: fullPath,
          isDirectory: item.attr.isDirectory,
          size: item.attr.size ?? 0,
          permissions: modeInt,
          modified: item.attr.modifyTime != null 
              ? DateTime.fromMillisecondsSinceEpoch(item.attr.modifyTime! * 1000)
              : DateTime.now(),
          owner: 'unknown',
          group: 'unknown',
        ));
      }

      // Sort: directories first, then alphabetically
      fileItems.sort((a, b) {
        if (a.isDirectory && !b.isDirectory) return -1;
        if (!a.isDirectory && b.isDirectory) return 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

      return fileItems;
    } catch (e) {
      throw Exception('Failed to list directory: $e');
    }
  }

  /// Read file contents
  Future<Uint8List> readFile(String path) async {
    await initialize();
    
    try {
      final file = await _sftp.open(path);
      final List<int> bytes = [];
      
      await for (final chunk in file.read()) {
        bytes.addAll(chunk);
      }
      
      await file.close();
      return Uint8List.fromList(bytes);
    } catch (e) {
      throw Exception('Failed to read file: $e');
    }
  }

  /// Write file contents
  Future<void> writeFile(String path, Uint8List data) async {
    await initialize();
    
    try {
      final file = await _sftp.open(
        path,
        mode: SftpFileOpenMode.create | 
               SftpFileOpenMode.truncate | 
               SftpFileOpenMode.write,
      );
      
      await file.write(Stream.value(data));
      await file.close();
    } catch (e) {
      throw Exception('Failed to write file: $e');
    }
  }

  /// Upload file with progress tracking
  Future<void> uploadFile({
    required String localPath,
    required String remotePath,
    required Uint8List data,
    void Function(int sent, int total)? onProgress,
  }) async {
    await initialize();

    try {
      final file = await _sftp.open(
        remotePath,
        mode: SftpFileOpenMode.create |
               SftpFileOpenMode.truncate |
               SftpFileOpenMode.write,
      );

      // Write the entire file at once to avoid chunking issues
      await file.write(Stream.value(data));

      // Report progress
      onProgress?.call(data.length, data.length);

      await file.close();
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  /// Download file with progress tracking
  Future<Uint8List> downloadFile({
    required String remotePath,
    void Function(int received, int total)? onProgress,
  }) async {
    await initialize();
    
    try {
      // Get file size first
      final stat = await _sftp.stat(remotePath);
      final total = stat.size ?? 0;
      
      final file = await _sftp.open(remotePath);
      final List<int> bytes = [];
      
      await for (final chunk in file.read()) {
        bytes.addAll(chunk);
        onProgress?.call(bytes.length, total);
      }
      
      await file.close();
      return Uint8List.fromList(bytes);
    } catch (e) {
      throw Exception('Failed to download file: $e');
    }
  }

  /// Delete file or directory
  Future<void> delete(String path, {bool isDirectory = false}) async {
    await initialize();
    
    try {
      if (isDirectory) {
        // Recursively delete directory contents first
        await _deleteDirectoryRecursive(path);
      } else {
        await _sftp.remove(path);
      }
    } catch (e) {
      throw Exception('Failed to delete: $e');
    }
  }

  /// Recursively delete directory and all its contents
  Future<void> _deleteDirectoryRecursive(String path) async {
    // List directory contents
    final items = await _sftp.listdir(path);
    
    // Delete all items in the directory
    for (final item in items) {
      // Skip . and ..
      if (item.filename == '.' || item.filename == '..') continue;
      
      final itemPath = path.endsWith('/') 
          ? '$path${item.filename}' 
          : '$path/${item.filename}';
      
      if (item.attr.isDirectory) {
        // Recursively delete subdirectory
        await _deleteDirectoryRecursive(itemPath);
      } else {
        // Delete file
        await _sftp.remove(itemPath);
      }
    }
    
    // Finally delete the empty directory
    await _sftp.rmdir(path);
  }

  /// Rename/move file or directory
  Future<void> rename(String oldPath, String newPath) async {
    await initialize();
    
    try {
      await _sftp.rename(oldPath, newPath);
    } catch (e) {
      throw Exception('Failed to rename: $e');
    }
  }

  /// Create directory
  Future<void> createDirectory(String path) async {
    await initialize();
    
    try {
      await _sftp.mkdir(path);
    } catch (e) {
      throw Exception('Failed to create directory: $e');
    }
  }

  /// Change file permissions
  Future<void> chmod(String path, int mode) async {
    await initialize();
    
    try {
      // ✅ Correct: Use the named constructor '.value'
      final fileMode = SftpFileMode.value(mode);
      
      await _sftp.setStat(path, SftpFileAttrs(mode: fileMode));
    } catch (e) {
      throw Exception('Failed to change permissions: $e');
    }
  }

  /// Get file/directory stats
  Future<SftpFileAttrs> stat(String path) async {
    await initialize();
    
    try {
      return await _sftp.stat(path);
    } catch (e) {
      throw Exception('Failed to get stats: $e');
    }
  }

  /// Check if path exists
  Future<bool> exists(String path) async {
    await initialize();
    
    try {
      await _sftp.stat(path);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get home directory
  Future<String> getHomeDirectory() async {
    await initialize();
    
    try {
      return await _sftp.absolute('.');
    } catch (e) {
      return '/home';
    }
  }

  /// Dispose resources
  void dispose() {
    // SFTP client is automatically closed when SSH client closes
    _isInitialized = false;
  }
}

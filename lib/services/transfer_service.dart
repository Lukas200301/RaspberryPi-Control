import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data'; // Added this import for Uint8List
import 'package:path/path.dart' as path;
import 'package:dartssh2/dartssh2.dart';
import '../models/transfer_task.dart';

class TransferService {
  final Map<String, TransferTask> _activeTasks = {};
  final StreamController<TransferTask> _taskController = StreamController<TransferTask>.broadcast();

  Stream<TransferTask> get taskStream => _taskController.stream;
  Stream<TransferTask> get taskUpdates => _taskController.stream;
  
  // Helper methods first so they're declared before use
  Future<List<FileSystemEntity>> _getAllFilesInDirectory(String path) async {
    final List<FileSystemEntity> entities = [];
    final directory = Directory(path);
    
    if (!directory.existsSync()) return entities;

    await for (final entity in directory.list(recursive: true)) {
      entities.add(entity);
    }
    
    return entities;
  }

  Future<void> _uploadFile(String localPath, String remotePath, SftpClient sftp, [void Function(String, double)? onProgress]) async {
    final file = File(localPath);
    if (!file.existsSync()) {
      throw Exception("File does not exist: $localPath");
    }
    final fileSize = await file.length();
    int totalBytesWritten = 0;
    final chunkSize = 32768; // 32KB chunks
    final buffer = Uint8List(chunkSize);

    // Open local file for reading
    final fileHandle = await file.open(mode: FileMode.read);
    try {
      while (true) {
        // Read a chunk from the local file
        final bytesRead = await fileHandle.readInto(buffer);
        if (bytesRead <= 0) break;
        final bytesToWrite = bytesRead < chunkSize ? buffer.sublist(0, bytesRead) : buffer;

        // For the first chunk, open remote file with truncate mode.
        // For subsequent chunks, open in append mode.
        final mode = totalBytesWritten == 0
            ? (SftpFileOpenMode.create | SftpFileOpenMode.write | SftpFileOpenMode.truncate)
            : (SftpFileOpenMode.create | SftpFileOpenMode.write | SftpFileOpenMode.append);

        final remoteFile = await sftp.open(remotePath, mode: mode);
        try {
          await remoteFile.writeBytes(bytesToWrite);
        } finally {
          await remoteFile.close();
        }

        totalBytesWritten += bytesRead;
        if (onProgress != null) {
          onProgress(path.basename(localPath), totalBytesWritten / fileSize);
        }
      }

      // Optional: Verify that the remote file size matches the local file size.
      final remoteFile = await sftp.open(remotePath, mode: SftpFileOpenMode.read);
      try {
        final stats = await remoteFile.stat();
        final uploadedSize = stats.size ?? 0;
        if (uploadedSize != fileSize) {
          print("Expected: $fileSize bytes, Uploaded: $uploadedSize bytes");
          throw Exception('File upload incomplete: expected $fileSize bytes but uploaded $uploadedSize bytes');
        }
      } finally {
        await remoteFile.close();
      }
    } finally {
      await fileHandle.close();
    }
  }




  Future<void> _downloadFile(String remotePath, String localPath, SftpClient sftp, [void Function(String, double)? onProgress]) async {
    final remoteFile = await sftp.open(remotePath);
    final file = File(localPath);
    
    final stats = await remoteFile.stat();
    final totalSize = stats.size ?? 0;
    int downloadedSize = 0;

    final sink = file.openWrite();
    
    try {
      await for (final chunk in remoteFile.read()) {
        sink.add(chunk);
        downloadedSize += chunk.length;
        
        if (onProgress != null && totalSize > 0) {
          onProgress(path.basename(remotePath), downloadedSize / totalSize);
        }
      }
    } finally {
      await sink.flush();
      await sink.close();
      await remoteFile.close();
    }
  }

  Future<void> uploadFolder(String localPath, String remotePath, String host, int port, String username, String password, [void Function(String, double)? onProgress]) async {
    final client = SSHClient(
      await SSHSocket.connect(host, port),
      username: username,
      onPasswordRequest: () => password,
    );

    try {
      final sftp = await client.sftp();
      final directory = Directory(localPath);
      if (!directory.existsSync()) {
        throw Exception("Directory does not exist: $localPath");
      }

      // Create base remote directory
      final baseRemotePath = remotePath.replaceAll('\\', '/');
      await client.run('mkdir -p "$baseRemotePath"');

      final entities = await _getAllFilesInDirectory(localPath);
      for (final entity in entities) {
        if (entity is Directory) {
          final relativePath = entity.path.substring(localPath.length);
          final remoteFilePath = '$baseRemotePath${relativePath.replaceAll('\\', '/')}';
          await client.run('mkdir -p "$remoteFilePath"');
        }
      }

      // Upload files after creating all directories
      for (final entity in entities) {
        if (entity is File) {
          final relativePath = entity.path.substring(localPath.length);
          final remoteFilePath = '$baseRemotePath${relativePath.replaceAll('\\', '/')}';

          final task = TransferTask(
            id: entity.path,
            filename: path.basename(entity.path),
            sourcePath: entity.path,
            destinationPath: remoteFilePath,
            byteSize: await File(entity.path).length(),
            progress: 0,
            status: TransferStatus.inProgress,
            type: TransferType.upload,
          );
          _activeTasks[task.id] = task;

          await _uploadFile(entity.path, remoteFilePath, sftp, onProgress);
          
          task.status = TransferStatus.completed;
          _taskController.add(task);
        }
      }
    } finally {
      client.close();
    }
  }

  Future<void> downloadFolder(String remotePath, String localPath, String host, int port, String username, String password, [void Function(String, double)? onProgress]) async {
    final client = SSHClient(
      await SSHSocket.connect(host, port),
      username: username,
      onPasswordRequest: () => password,
    );

    try {
      final sftp = await client.sftp();
      final result = utf8.decode(await client.run('ls -laR "$remotePath"'));
      
      // Create local base directory
      final directory = Directory(localPath);
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }

      // Parse ls output and download files
      final sections = result.split('\n\n');
      for (final section in sections) {
        final lines = section.split('\n');
        if (lines.isEmpty) continue;

        final currentDir = lines[0].replaceAll(':', '');
        for (final line in lines.skip(1)) {
          if (line.trim().isEmpty) continue;
          
          final parts = line.split(RegExp(r'\s+'));
          if (parts.length < 9) continue;

          final name = parts.sublist(8).join(' ');
          if (name == '.' || name == '..') continue;

          final permissions = parts[0];
          final remoteFilePath = '$currentDir/$name';
          final localFilePath = '$localPath/${remoteFilePath.substring(remotePath.length)}';

          if (permissions.startsWith('d')) {
            Directory(localFilePath).createSync(recursive: true);
          } else {
            final task = TransferTask(
              id: remoteFilePath,
              filename: name,
              sourcePath: remoteFilePath,
              destinationPath: localFilePath,
              byteSize: int.parse(parts[4]),
              progress: 0,
              status: TransferStatus.inProgress,
              type: TransferType.download,
            );
            _activeTasks[task.id] = task;

            await _downloadFile(remoteFilePath, localFilePath, sftp, onProgress);
            
            task.status = TransferStatus.completed;
            _taskController.add(task);
          }
        }
      }
    } finally {
      client.close();
    }
  }

  void cancelTask(String taskId) {
    final task = _activeTasks[taskId];
    if (task != null) {
      task.status = TransferStatus.cancelled;
      _taskController.add(task);
    }
  }

  Future<String> uploadFile(String localPath, String remotePath, String host, int port, String username, String password, [void Function(String, double)? onProgress]) async {
    final file = File(localPath);
    final fileSize = await file.length();
    final taskId = path.basename(localPath);
    
    final task = TransferTask(
      id: taskId,
      filename: path.basename(localPath),
      sourcePath: localPath,
      destinationPath: remotePath,
      byteSize: fileSize,
      progress: 0,
      status: TransferStatus.inProgress,
      type: TransferType.upload,
    );
    _activeTasks[taskId] = task;

    try {
      final client = SSHClient(
        await SSHSocket.connect(host, port),
        username: username,
        onPasswordRequest: () => password,
      );

      try {
        final sftp = await client.sftp();
        await _uploadFile(localPath, remotePath, sftp, (filename, progress) {
          task.progress = progress;
          _taskController.add(task);
          if (onProgress != null) {
            onProgress(filename, progress);
          }
        });
        
        task.status = TransferStatus.completed;
        task.progress = 1.0;
      } finally {
        client.close();
      }
    } catch (e) {
      task.status = TransferStatus.failed;
      rethrow;
    } finally {
      _taskController.add(task);
    }

    return taskId;
  }

  void dispose() {
    _taskController.close();
  }
}

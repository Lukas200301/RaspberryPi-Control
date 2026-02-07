import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:fixnum/fixnum.dart';
import 'package:path/path.dart' as path;
import '../generated/pi_control.pbgrpc.dart';
import 'grpc_service.dart';

/// File transfer service using gRPC streaming
/// Much simpler than SFTP - no background isolates, no complex state management
class GrpcFileTransferService extends ChangeNotifier {
  final GrpcService _grpcService;
  
  // Transfer tracking
  final Map<String, FileTransferProgress> _activeTransfers = {};
  final List<FileTransferProgress> _completedTransfers = [];
  
  // Configuration
  static const int smallFileThreshold = 1 * 1024 * 1024; // 1MB
  static const int mediumFileThreshold = 10 * 1024 * 1024; // 10MB
  static const int largeFileThreshold = 100 * 1024 * 1024; // 100MB
  static const int smallChunkSize = 256 * 1024; // 256KB for small files
  static const int mediumChunkSize = 512 * 1024; // 512KB for medium files
  static const int largeChunkSize = 2 * 1024 * 1024; // 2MB for large files
  static const int veryLargeChunkSize = 4 * 1024 * 1024; // 4MB for very large files (>100MB)
  static const int maxConcurrentTransfers = 3;
  
  /// Get optimal chunk size based on file size
  static int getOptimalChunkSize(int fileSize) {
    if (fileSize < smallFileThreshold) {
      return smallChunkSize; // 256KB for files < 1MB
    } else if (fileSize < mediumFileThreshold) {
      return mediumChunkSize; // 512KB for files 1-10MB
    } else if (fileSize < largeFileThreshold) {
      return largeChunkSize; // 2MB for files 10-100MB
    } else {
      return veryLargeChunkSize; // 4MB for files > 100MB (multi-GB transfers)
    }
  }
  
  GrpcFileTransferService(this._grpcService);

  /// Get all active transfers
  List<FileTransferProgress> get activeTransfers => _activeTransfers.values.toList();
  
  /// Get completed transfers
  List<FileTransferProgress> get completedTransfers => _completedTransfers;
  
  /// Upload a file to the remote server
  Future<void> uploadFile({
    required String localPath,
    required String remotePath,
    Function(double progress)? onProgress,
  }) async {
    final transferId = '${DateTime.now().millisecondsSinceEpoch}_upload_$remotePath';
    final file = File(localPath);
    
    if (!await file.exists()) {
      throw Exception('Local file does not exist: $localPath');
    }
    
    final fileSize = await file.length();
    final chunkSize = getOptimalChunkSize(fileSize);
    final progress = FileTransferProgress(
      id: transferId,
      localPath: localPath,
      remotePath: remotePath,
      totalBytes: fileSize,
      isUpload: true,
    );
    
    _activeTransfers[transferId] = progress;
    notifyListeners();
    
    try {
      // Create stream controller for sending chunks
      final controller = StreamController<FileChunk>();
      
      // Start the upload call
      final responseCall = _grpcService.uploadFileStream(controller.stream);
      
      // Read and send file chunks with adaptive sizing
      final stream = file.openRead();
      int offset = 0;
      List<int> buffer = [];
      
      await for (final chunk in stream) {
        buffer.addAll(chunk);
        
        // Send chunks when buffer reaches optimal chunk size
        while (buffer.length >= chunkSize) {
          final dataToSend = buffer.sublist(0, chunkSize);
          buffer = buffer.sublist(chunkSize);
          
          final fileChunk = FileChunk()
            ..path = remotePath
            ..data = dataToSend
            ..offset = Int64(offset)
            ..totalSize = Int64(fileSize)
            ..isFinal = false;
          
          controller.add(fileChunk);
          
          offset += dataToSend.length;
          progress.transferredBytes = offset;
          progress.progress = (offset / fileSize * 100);
          
          onProgress?.call(progress.progress);
          notifyListeners();
        }
      }
      
      // Send remaining data in buffer
      if (buffer.isNotEmpty) {
        final fileChunk = FileChunk()
          ..path = remotePath
          ..data = buffer
          ..offset = Int64(offset)
          ..totalSize = Int64(fileSize)
          ..isFinal = true;
        
        controller.add(fileChunk);
        
        offset += buffer.length;
        progress.transferredBytes = offset;
        progress.progress = 100.0;
        
        onProgress?.call(progress.progress);
        notifyListeners();
      }
      
      await controller.close();
      
      // Wait for response
      final response = await responseCall;
      
      if (!response.success) {
        throw Exception(response.error.isEmpty ? 'Upload failed' : response.error);
      }
      
      progress.isComplete = true;
      progress.error = null;
      _completedTransfers.add(progress);
      
      debugPrint('Upload complete: $remotePath (${response.bytesWritten} bytes in ${response.duration.toStringAsFixed(2)}s)');
      
    } catch (e) {
      progress.error = e.toString();
      debugPrint('Upload failed: $e');
      rethrow;
    } finally {
      _activeTransfers.remove(transferId);
      notifyListeners();
    }
  }
  
  /// Download a file from the remote server
  Future<void> downloadFile({
    required String remotePath,
    required String localPath,
    Function(double progress)? onProgress,
    int resumeOffset = 0,
  }) async {
    final transferId = '${DateTime.now().millisecondsSinceEpoch}_download_$remotePath';
    
    final progress = FileTransferProgress(
      id: transferId,
      localPath: localPath,
      remotePath: remotePath,
      totalBytes: 0, // Will be set from first chunk
      isUpload: false,
      transferredBytes: resumeOffset,
    );
    
    _activeTransfers[transferId] = progress;
    notifyListeners();
    
    RandomAccessFile? outputFile;
    
    try {
      final stream = _grpcService.downloadFileStream(remotePath, offset: resumeOffset);
      
      // Open file for writing
      final file = File(localPath);
      if (resumeOffset > 0) {
        // Resume mode: append to existing file
        outputFile = await file.open(mode: FileMode.append);
      } else {
        // New download: create/overwrite file
        outputFile = await file.open(mode: FileMode.write);
      }
      
      await for (final chunk in stream) {
        if (chunk.error.isNotEmpty) {
          throw Exception(chunk.error);
        }
        
        // Set total size from first chunk
        if (progress.totalBytes == 0 && chunk.totalSize > 0) {
          progress.totalBytes = chunk.totalSize.toInt();
        }
        
        // Write chunk data
        if (chunk.data.isNotEmpty) {
          await outputFile.writeFrom(chunk.data);
          progress.transferredBytes += chunk.data.length;
          
          if (progress.totalBytes > 0) {
            progress.progress = (progress.transferredBytes / progress.totalBytes * 100);
            onProgress?.call(progress.progress);
          }
          
          notifyListeners();
        }
        
        // Check if transfer is complete
        if (chunk.isFinal) {
          break;
        }
      }
      
      progress.isComplete = true;
      progress.error = null;
      _completedTransfers.add(progress);
      
      debugPrint('Download complete: $localPath (${progress.transferredBytes} bytes)');
      
    } catch (e) {
      progress.error = e.toString();
      debugPrint('Download failed: $e');
      rethrow;
    } finally {
      await outputFile?.close();
      _activeTransfers.remove(transferId);
      notifyListeners();
    }
  }
  
  /// Upload multiple files
  Future<void> uploadFiles({
    required List<String> localPaths,
    required String remoteDirectory,
    Function(String filename, double progress)? onProgress,
  }) async {
    for (final localPath in localPaths) {
      final filename = path.basename(localPath);
      final remotePath = path.join(remoteDirectory, filename).replaceAll('\\', '/');
      
      await uploadFile(
        localPath: localPath,
        remotePath: remotePath,
        onProgress: (progress) => onProgress?.call(filename, progress),
      );
    }
  }
  
  /// Upload a directory recursively
  Future<void> uploadDirectory({
    required String localPath,
    required String remotePath,
    Function(String filename, double progress)? onProgress,
  }) async {
    final localDir = Directory(localPath);
    
    if (!await localDir.exists()) {
      throw Exception('Local directory does not exist: $localPath');
    }
    
    // Get all files recursively
    final files = await localDir.list(recursive: true).where((entity) => entity is File).toList();
    
    for (final entity in files) {
      if (entity is File) {
        // Calculate relative path
        final relativePath = path.relative(entity.path, from: localPath);
        final remoteFilePath = path.join(remotePath, relativePath).replaceAll('\\', '/');
        
        await uploadFile(
          localPath: entity.path,
          remotePath: remoteFilePath,
          onProgress: (progress) => onProgress?.call(relativePath, progress),
        );
      }
    }
  }
  
  /// Cancel a transfer
  void cancelTransfer(String transferId) {
    final transfer = _activeTransfers[transferId];
    if (transfer != null) {
      transfer.error = 'Cancelled by user';
      _activeTransfers.remove(transferId);
      notifyListeners();
    }
  }
  
  /// Clear completed transfers history
  void clearCompleted() {
    _completedTransfers.clear();
    notifyListeners();
  }
  
  /// Get transfer by ID
  FileTransferProgress? getTransfer(String transferId) {
    return _activeTransfers[transferId] ?? 
           _completedTransfers.firstWhere(
             (t) => t.id == transferId,
             orElse: () => FileTransferProgress(
               id: '',
               localPath: '',
               remotePath: '',
               totalBytes: 0,
               isUpload: true,
             ),
           );
  }
}

/// Transfer progress tracking
class FileTransferProgress {
  final String id;
  final String localPath;
  final String remotePath;
  final bool isUpload;
  
  int totalBytes;
  int transferredBytes;
  double progress;
  bool isComplete;
  String? error;
  DateTime startTime;
  
  FileTransferProgress({
    required this.id,
    required this.localPath,
    required this.remotePath,
    required this.totalBytes,
    required this.isUpload,
    this.transferredBytes = 0,
    this.progress = 0.0,
    this.isComplete = false,
    this.error,
  }) : startTime = DateTime.now();
  
  /// Get filename from path
  String get filename => isUpload ? path.basename(localPath) : path.basename(remotePath);
  
  /// Get transfer speed in bytes per second
  double get speedBytesPerSecond {
    final elapsed = DateTime.now().difference(startTime).inMilliseconds / 1000.0;
    return elapsed > 0 ? transferredBytes / elapsed : 0;
  }
  
  /// Get transfer speed in MB/s
  double get speedMBps => speedBytesPerSecond / (1024 * 1024);
  
  /// Get estimated time remaining in seconds
  int get estimatedSecondsRemaining {
    if (speedBytesPerSecond == 0 || isComplete) return 0;
    final remainingBytes = totalBytes - transferredBytes;
    return (remainingBytes / speedBytesPerSecond).round();
  }
  
  /// Format progress as percentage string
  String get progressString => '${progress.toStringAsFixed(1)}%';
  
  /// Format speed as human-readable string
  String get speedString {
    if (speedBytesPerSecond < 1024) {
      return '${speedBytesPerSecond.toStringAsFixed(0)} B/s';
    } else if (speedBytesPerSecond < 1024 * 1024) {
      return '${(speedBytesPerSecond / 1024).toStringAsFixed(1)} KB/s';
    } else {
      return '${(speedBytesPerSecond / (1024 * 1024)).toStringAsFixed(2)} MB/s';
    }
  }
  
  /// Format bytes as human-readable string
  static String formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }
  
  String get transferredString => '${formatBytes(transferredBytes)} / ${formatBytes(totalBytes)}';
}

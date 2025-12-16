import 'package:flutter/material.dart';

/// Represents a file or directory item
class FileItem {
  final String name;
  final String path;
  final bool isDirectory;
  final int size;
  final int permissions;
  final DateTime modified;
  final String owner;
  final String group;

  FileItem({
    required this.name,
    required this.path,
    required this.isDirectory,
    required this.size,
    required this.permissions,
    required this.modified,
    required this.owner,
    required this.group,
  });

  /// Get file extension
  String get extension {
    if (isDirectory) return '';
    final parts = name.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  /// Get human-readable file size
  String get formattedSize {
    if (isDirectory) return '--';
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Get permissions as string (e.g., "rwxr-xr-x")
  String get permissionsString {
    String result = '';
    
    // Owner permissions
    result += (permissions & 0x100) != 0 ? 'r' : '-';
    result += (permissions & 0x80) != 0 ? 'w' : '-';
    result += (permissions & 0x40) != 0 ? 'x' : '-';
    
    // Group permissions
    result += (permissions & 0x20) != 0 ? 'r' : '-';
    result += (permissions & 0x10) != 0 ? 'w' : '-';
    result += (permissions & 0x8) != 0 ? 'x' : '-';
    
    // Other permissions
    result += (permissions & 0x4) != 0 ? 'r' : '-';
    result += (permissions & 0x2) != 0 ? 'w' : '-';
    result += (permissions & 0x1) != 0 ? 'x' : '-';
    
    return result;
  }

  /// Get octal permissions (e.g., "755")
  String get permissionsOctal {
    final owner = ((permissions & 0x1C0) >> 6);
    final group = ((permissions & 0x38) >> 3);
    final other = (permissions & 0x7);
    return '$owner$group$other';
  }

  /// Get icon based on file type
  IconData get icon {
    if (isDirectory) {
      if (name.startsWith('.')) return Icons.folder_special;
      return Icons.folder;
    }

    // Code files
    if (['dart', 'java', 'py', 'js', 'ts', 'cpp', 'c', 'h', 'go', 'rs']
        .contains(extension)) {
      return Icons.code;
    }

    // Config files
    if (['json', 'yaml', 'yml', 'toml', 'ini', 'conf', 'config', 'xml']
        .contains(extension)) {
      return Icons.settings_suggest;
    }

    // Images
    if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'svg', 'webp'].contains(extension)) {
      return Icons.image;
    }

    // Documents
    if (['txt', 'md', 'pdf', 'doc', 'docx'].contains(extension)) {
      return Icons.description;
    }

    // Archives
    if (['zip', 'tar', 'gz', 'bz2', 'xz', '7z', 'rar'].contains(extension)) {
      return Icons.archive;
    }

    // Scripts
    if (['sh', 'bash', 'zsh', 'fish', 'ps1', 'bat', 'cmd'].contains(extension)) {
      return Icons.terminal;
    }

    // Videos
    if (['mp4', 'avi', 'mkv', 'mov', 'wmv', 'flv', 'webm'].contains(extension)) {
      return Icons.video_file;
    }

    // Audio
    if (['mp3', 'wav', 'flac', 'ogg', 'aac', 'm4a'].contains(extension)) {
      return Icons.audio_file;
    }

    return Icons.insert_drive_file;
  }

  /// Get color based on file type
  Color get color {
    if (isDirectory) return Colors.blue;

    // Code files
    if (['dart', 'java', 'py', 'js', 'ts', 'cpp', 'c', 'h', 'go', 'rs']
        .contains(extension)) {
      return Colors.green;
    }

    // Config files
    if (['json', 'yaml', 'yml', 'toml', 'ini', 'conf', 'config', 'xml']
        .contains(extension)) {
      return Colors.orange;
    }

    // Images
    if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'svg', 'webp'].contains(extension)) {
      return Colors.purple;
    }

    // Archives
    if (['zip', 'tar', 'gz', 'bz2', 'xz', '7z', 'rar'].contains(extension)) {
      return Colors.brown;
    }

    // Scripts
    if (['sh', 'bash', 'zsh', 'fish', 'ps1', 'bat', 'cmd'].contains(extension)) {
      return Colors.teal;
    }

    return Colors.grey;
  }

  /// Check if file is a text file (can be previewed)
  bool get isTextFile {
    final textExtensions = [
      'txt', 'md', 'json', 'yaml', 'yml', 'toml', 'ini', 'conf', 'config',
      'xml', 'html', 'css', 'js', 'ts', 'dart', 'java', 'py', 'cpp', 'c',
      'h', 'go', 'rs', 'sh', 'bash', 'log', 'csv', 'sql',
    ];
    return textExtensions.contains(extension);
  }

  /// Check if file is an image
  bool get isImage {
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension);
  }

  /// Check if file can be edited
  bool get isEditable {
    return isTextFile && !isDirectory;
  }
}

/// Represents a file transfer operation
class FileTransfer {
  final String id;
  final String fileName;
  final String localPath;
  final String remotePath;
  final bool isUpload;
  final int totalSize;
  int transferredSize;
  FileTransferStatus status;
  String? error;
  final bool isFolderTransfer;
  int? totalBytes; // For folder transfers, store actual byte size
  int? transferredBytes; // For folder transfers, store transferred bytes

  FileTransfer({
    required this.id,
    required this.fileName,
    required this.localPath,
    required this.remotePath,
    required this.isUpload,
    required this.totalSize,
    this.transferredSize = 0,
    this.status = FileTransferStatus.pending,
    this.error,
    this.isFolderTransfer = false,
    this.totalBytes,
    this.transferredBytes,
  });

  double get progress => totalSize > 0 ? transferredSize / totalSize : 0.0;
  
  String get formattedProgress {
    return '${(progress * 100).toStringAsFixed(1)}%';
  }
}

enum FileTransferStatus {
  pending,
  transferring,
  completed,
  failed,
  cancelled,
}

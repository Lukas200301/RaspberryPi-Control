/// File Entity Model - Represents a file or directory on the remote system
class FileEntity {
  final String name;
  final bool isDirectory;
  final String size;
  final String permissions;
  final String? fullPath;

  FileEntity({
    required this.name,
    required this.isDirectory,
    required this.size,
    required this.permissions,
    this.fullPath,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileEntity &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          isDirectory == other.isDirectory;

  @override
  int get hashCode => name.hashCode ^ isDirectory.hashCode;

  /// Format size to human readable format
  String get formattedSize {
    final bytes = int.tryParse(size) ?? 0;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Get file extension
  String get extension {
    if (isDirectory) return '';
    final parts = name.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  /// Check if file is hidden (starts with .)
  bool get isHidden => name.startsWith('.');

  /// Get appropriate icon type
  FileIconType get iconType {
    if (isDirectory) return FileIconType.folder;

    switch (extension) {
      case 'txt':
      case 'md':
      case 'log':
        return FileIconType.text;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'svg':
      case 'webp':
        return FileIconType.image;
      case 'mp4':
      case 'avi':
      case 'mkv':
      case 'mov':
      case 'webm':
        return FileIconType.video;
      case 'mp3':
      case 'wav':
      case 'flac':
      case 'ogg':
        return FileIconType.audio;
      case 'zip':
      case 'tar':
      case 'gz':
      case 'rar':
      case '7z':
        return FileIconType.archive;
      case 'pdf':
        return FileIconType.pdf;
      case 'doc':
      case 'docx':
        return FileIconType.document;
      case 'py':
      case 'js':
      case 'dart':
      case 'java':
      case 'cpp':
      case 'c':
      case 'h':
      case 'sh':
      case 'json':
      case 'xml':
      case 'yaml':
      case 'yml':
        return FileIconType.code;
      default:
        return FileIconType.file;
    }
  }
}

/// File icon type enumeration
enum FileIconType {
  folder,
  file,
  text,
  image,
  video,
  audio,
  archive,
  pdf,
  document,
  code,
}

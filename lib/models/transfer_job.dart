/// Represents a file transfer job
class TransferJob {
  final String id;
  final String localPath;
  final String remotePath;
  final TransferType type;
  final int totalBytes;
  final TransferStatus status;
  final int transferredBytes;
  final String? error;
  final DateTime createdAt;

  TransferJob({
    required this.id,
    required this.localPath,
    required this.remotePath,
    required this.type,
    this.totalBytes = 0,
    this.status = TransferStatus.queued,
    this.transferredBytes = 0,
    this.error,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  double get progress {
    if (totalBytes == 0) return 0;
    return (transferredBytes / totalBytes * 100).clamp(0, 100);
  }

  TransferJob copyWith({
    String? id,
    String? localPath,
    String? remotePath,
    TransferType? type,
    int? totalBytes,
    TransferStatus? status,
    int? transferredBytes,
    String? error,
    DateTime? createdAt,
  }) {
    return TransferJob(
      id: id ?? this.id,
      localPath: localPath ?? this.localPath,
      remotePath: remotePath ?? this.remotePath,
      type: type ?? this.type,
      totalBytes: totalBytes ?? this.totalBytes,
      status: status ?? this.status,
      transferredBytes: transferredBytes ?? this.transferredBytes,
      error: error ?? this.error,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'localPath': localPath,
      'remotePath': remotePath,
      'type': type.name,
      'totalBytes': totalBytes,
      'status': status.name,
      'transferredBytes': transferredBytes,
      'error': error,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TransferJob.fromJson(Map<String, dynamic> json) {
    return TransferJob(
      id: json['id'] as String,
      localPath: json['localPath'] as String,
      remotePath: json['remotePath'] as String,
      type: TransferType.values.firstWhere((e) => e.name == json['type']),
      totalBytes: json['totalBytes'] as int? ?? 0,
      status: TransferStatus.values.firstWhere((e) => e.name == json['status']),
      transferredBytes: json['transferredBytes'] as int? ?? 0,
      error: json['error'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransferJob &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

enum TransferType { upload, download }

enum TransferStatus {
  queued,
  connecting,
  transferring,
  completed,
  failed,
  cancelled,
}

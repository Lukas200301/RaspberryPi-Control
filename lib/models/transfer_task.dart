enum TransferType { upload, download }
enum TransferStatus { inProgress, completed, failed, cancelled }

class TransferTask {
  final String id;
  final String filename;
  final String sourcePath;
  final String destinationPath;
  final int byteSize;
  double progress;
  TransferStatus status;
  final TransferType type;

  TransferTask({
    required this.id,
    required this.filename,
    required this.sourcePath,
    required this.destinationPath,
    required this.byteSize,
    required this.progress,
    required this.status,
    required this.type,
  });
}

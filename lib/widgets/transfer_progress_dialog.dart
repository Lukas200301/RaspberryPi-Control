import 'package:flutter/material.dart';
import '../models/transfer_task.dart';

class TransferProgressDialog extends StatelessWidget {
  final String fileName;
  final String sourcePath;
  final String destinationPath;
  final double progress;
  final double speed;
  final int elapsedTime;
  final int remainingTime;
  final TransferType type;
  final VoidCallback onCancel;

  const TransferProgressDialog({
    Key? key,
    required this.fileName,
    required this.sourcePath,
    required this.destinationPath,
    required this.progress,
    required this.speed,
    required this.elapsedTime,
    required this.remainingTime,
    required this.type,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(type == TransferType.upload ? Icons.upload : Icons.download),
                const SizedBox(width: 8),
                Text(
                  type == TransferType.upload ? 'Uploading...' : 'Downloading...',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('File: $fileName'),
            const SizedBox(height: 8),
            Text('From: $sourcePath'),
            Text('To: $destinationPath'),
            const SizedBox(height: 16),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 8),
            Text('Progress: ${(progress * 100).toStringAsFixed(1)}%'),
            Text('Speed: ${speed.toStringAsFixed(2)} MB/s'),
            Text('Elapsed time: ${_formatDuration(elapsedTime)}'),
            Text('Remaining time: ${_formatDuration(remainingTime)}'),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onCancel,
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) {
      return '$seconds seconds';
    } else if (seconds < 3600) {
      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;
      return '$minutes min ${remainingSeconds}s';
    } else {
      final hours = seconds ~/ 3600;
      final minutes = (seconds % 3600) ~/ 60;
      final remainingSeconds = seconds % 60;
      return '$hours h ${minutes}m ${remainingSeconds}s';
    }
  }
}

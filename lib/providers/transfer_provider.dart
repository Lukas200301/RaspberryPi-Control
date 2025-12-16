import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/transfer_job.dart';
import '../models/ssh_connection.dart';
import '../services/sftp_background_service.dart';

const _uuid = Uuid();

/// Notifier for managing file transfer jobs
class TransferQueueNotifier extends Notifier<List<TransferJob>> {
  StreamSubscription? _updateSubscription;

  @override
  List<TransferJob> build() {
    // Listen to background service updates
    _updateSubscription = SftpBackgroundService.updates.listen((event) {
      if (event['job'] != null) {
        final updatedJob = TransferJob.fromJson(event['job'] as Map<String, dynamic>);
        _updateJob(updatedJob);
      }
    });

    // Clean up subscription when provider is disposed
    ref.onDispose(() {
      _updateSubscription?.cancel();
    });

    return [];
  }

  /// Add a download job
  Future<void> addDownload({
    required String localPath,
    required String remotePath,
    required SSHConnection connection,
  }) async {
    final job = TransferJob(
      id: _uuid.v4(),
      localPath: localPath,
      remotePath: remotePath,
      type: TransferType.download,
    );

    state = [...state, job];

    // Send to background service
    SftpBackgroundService.addTransferJob(job, connection);
  }

  /// Add an upload job
  Future<void> addUpload({
    required String localPath,
    required String remotePath,
    required SSHConnection connection,
  }) async {
    final job = TransferJob(
      id: _uuid.v4(),
      localPath: localPath,
      remotePath: remotePath,
      type: TransferType.upload,
    );

    state = [...state, job];

    // Send to background service
    SftpBackgroundService.addTransferJob(job, connection);
  }

  /// Cancel a job
  void cancelJob(String jobId) {
    final job = state.firstWhere((j) => j.id == jobId);
    SftpBackgroundService.cancelJob(jobId);

    final updatedJob = job.copyWith(status: TransferStatus.cancelled);
    _updateJob(updatedJob);
  }

  /// Remove completed/failed/cancelled jobs
  void clearCompleted() {
    state = state.where((job) {
      return job.status != TransferStatus.completed &&
          job.status != TransferStatus.failed &&
          job.status != TransferStatus.cancelled;
    }).toList();
  }

  /// Remove a specific job
  void removeJob(String jobId) {
    state = state.where((job) => job.id != jobId).toList();
  }

  /// Update a job in the state
  void _updateJob(TransferJob updatedJob) {
    final index = state.indexWhere((j) => j.id == updatedJob.id);
    if (index != -1) {
      final newState = [...state];
      newState[index] = updatedJob;
      state = newState;
    }
  }
}

/// Provider for the transfer queue
final transferQueueProvider = NotifierProvider<TransferQueueNotifier, List<TransferJob>>(
  TransferQueueNotifier.new,
);

/// Provider for active transfers (queued, connecting, transferring)
final activeTransfersProvider = Provider<List<TransferJob>>((ref) {
  final queue = ref.watch(transferQueueProvider);
  return queue.where((job) {
    return job.status == TransferStatus.queued ||
        job.status == TransferStatus.connecting ||
        job.status == TransferStatus.transferring;
  }).toList();
});

/// Provider for completed transfers
final completedTransfersProvider = Provider<List<TransferJob>>((ref) {
  final queue = ref.watch(transferQueueProvider);
  return queue.where((job) => job.status == TransferStatus.completed).toList();
});

/// Provider for failed transfers
final failedTransfersProvider = Provider<List<TransferJob>>((ref) {
  final queue = ref.watch(transferQueueProvider);
  return queue.where((job) => job.status == TransferStatus.failed).toList();
});

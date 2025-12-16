import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transfer_job.dart';
import '../providers/transfer_provider.dart';
import '../theme/app_theme.dart';

/// Panel showing background file transfers
class BackgroundTransferPanel extends ConsumerWidget {
  const BackgroundTransferPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transfers = ref.watch(transferQueueProvider);

    if (transfers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border.all(color: AppTheme.glassBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppTheme.glassLight,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Icon(Icons.swap_vert, color: AppTheme.primaryIndigo),
                const SizedBox(width: 12),
                Text(
                  'File Transfers',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    ref.read(transferQueueProvider.notifier).clearCompleted();
                  },
                  icon: const Icon(Icons.clear_all, size: 18),
                  label: const Text('Clear'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // Transfer list
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: transfers.length,
              itemBuilder: (context, index) {
                final transfer = transfers[index];
                return _TransferItem(transfer: transfer);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TransferItem extends ConsumerWidget {
  final TransferJob transfer;

  const _TransferItem({required this.transfer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fileName = transfer.type == TransferType.download
        ? transfer.remotePath.split('/').last
        : transfer.localPath.split('/').last;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                transfer.type == TransferType.download
                    ? Icons.download
                    : Icons.upload,
                size: 20,
                color: _getStatusColor(transfer.status),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  fileName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              if (transfer.status == TransferStatus.queued ||
                  transfer.status == TransferStatus.connecting ||
                  transfer.status == TransferStatus.transferring)
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    ref.read(transferQueueProvider.notifier).cancelJob(transfer.id);
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  color: Colors.white70,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (transfer.status == TransferStatus.transferring) ...[
                      LinearProgressIndicator(
                        value: transfer.progress / 100,
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getStatusColor(transfer.status),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${transfer.progress.toStringAsFixed(1)}% - ${_formatBytes(transfer.transferredBytes)} / ${_formatBytes(transfer.totalBytes)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                      ),
                    ] else ...[
                      Text(
                        _getStatusText(transfer.status),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: _getStatusColor(transfer.status),
                            ),
                      ),
                    ],
                    if (transfer.error != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        transfer.error!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.errorRose,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(TransferStatus status) {
    switch (status) {
      case TransferStatus.queued:
        return Colors.orange;
      case TransferStatus.connecting:
        return Colors.blue;
      case TransferStatus.transferring:
        return AppTheme.primaryIndigo;
      case TransferStatus.completed:
        return AppTheme.successGreen;
      case TransferStatus.failed:
        return AppTheme.errorRose;
      case TransferStatus.cancelled:
        return Colors.grey;
    }
  }

  String _getStatusText(TransferStatus status) {
    switch (status) {
      case TransferStatus.queued:
        return 'Waiting in queue...';
      case TransferStatus.connecting:
        return 'Connecting...';
      case TransferStatus.transferring:
        return 'Transferring...';
      case TransferStatus.completed:
        return 'Completed';
      case TransferStatus.failed:
        return 'Failed';
      case TransferStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

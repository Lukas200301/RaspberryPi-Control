import 'package:flutter/material.dart';
import '../models/file_item.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

class FileTransferPanel extends StatelessWidget {
  final List<FileTransfer> transfers;

  const FileTransferPanel({
    super.key,
    required this.transfers,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.sync, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Transfers (${transfers.length})',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                if (transfers.any((t) => t.status == FileTransferStatus.completed))
                  TextButton(
                    onPressed: () {
                      // Clear completed transfers
                    },
                    child: const Text('Clear'),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: transfers.length,
              itemBuilder: (context, index) {
                final transfer = transfers[index];
                return _buildTransferItem(transfer);
              },
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildTransferItem(FileTransfer transfer) {
    IconData icon;
    Color color;

    switch (transfer.status) {
      case FileTransferStatus.pending:
        icon = Icons.pending;
        color = Colors.grey;
        break;
      case FileTransferStatus.transferring:
        icon = transfer.isUpload ? Icons.upload : Icons.download;
        color = AppTheme.primaryIndigo;
        break;
      case FileTransferStatus.completed:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case FileTransferStatus.failed:
        icon = Icons.error;
        color = Colors.red;
        break;
      case FileTransferStatus.cancelled:
        icon = Icons.cancel;
        color = Colors.orange;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transfer.fileName,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (transfer.status == FileTransferStatus.transferring)
                      Text(
                        transfer.isFolderTransfer
                            ? '${transfer.transferredSize} / ${transfer.totalSize} files'
                            : '${_formatBytes(transfer.transferredSize)} / ${_formatBytes(transfer.totalSize)}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    if (transfer.error != null)
                      Text(
                        transfer.error!,
                        style: const TextStyle(fontSize: 12, color: Colors.red),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              if (transfer.status == FileTransferStatus.transferring)
                Text(
                  transfer.formattedProgress,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          if (transfer.status == FileTransferStatus.transferring) ...[
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: transfer.progress,
              backgroundColor: Colors.grey.withValues(alpha: 0.2),
              color: AppTheme.primaryIndigo,
            ),
          ],
        ],
      ),
    );
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

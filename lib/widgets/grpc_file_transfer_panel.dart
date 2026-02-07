import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/grpc_file_transfer_service.dart';
import '../providers/app_providers.dart';
import 'glass_card.dart';

/// Panel to display active file transfers using gRPC streaming
class GrpcFileTransferPanel extends ConsumerWidget {
  const GrpcFileTransferPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transferService = ref.watch(grpcFileTransferServiceProvider);
    
    // Listen to changes
    final activeTransfers = transferService.activeTransfers;
    final completedTransfers = transferService.completedTransfers.take(5).toList();
    
    if (activeTransfers.isEmpty && completedTransfers.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'File Transfers',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (completedTransfers.isNotEmpty)
                  TextButton(
                    onPressed: () => transferService.clearCompleted(),
                    child: Text(
                      'Clear',
                      style: TextStyle(color: Colors.blue[400]),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Active transfers
            if (activeTransfers.isNotEmpty) ...[
              Text(
                'Active (${activeTransfers.length})',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              ...activeTransfers.map((transfer) => _buildTransferItem(
                context,
                transfer,
                isActive: true,
                onCancel: () => transferService.cancelTransfer(transfer.id),
              )),
              const SizedBox(height: 16),
            ],
            
            // Recently completed transfers
            if (completedTransfers.isNotEmpty) ...[
              Text(
                'Recent',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              ...completedTransfers.map((transfer) => _buildTransferItem(
                context,
                transfer,
                isActive: false,
              )),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildTransferItem(
    BuildContext context,
    FileTransferProgress transfer, {
    required bool isActive,
    VoidCallback? onCancel,
  }) {
    final hasError = transfer.error != null;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasError 
              ? Colors.red.shade700.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filename and status
          Row(
            children: [
              Icon(
                transfer.isUpload ? Icons.upload : Icons.download,
                size: 16,
                color: hasError
                    ? Colors.red[700]
                    : (isActive ? Colors.blue[400] : Colors.green[600]),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  transfer.filename,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isActive && onCancel != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: onCancel,
                  color: Colors.white54,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
              else if (hasError)
                Icon(
                  Icons.error_outline,
                  size: 18,
                  color: Colors.red[700],
                )
              else if (!isActive)
                Icon(
                  Icons.check_circle_outline,
                  size: 18,
                  color: Colors.green[600],
                ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Progress bar (only for active transfers)
          if (isActive) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: transfer.progress / 100,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation(Colors.blue[400]),
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 6),
          ],
          
          // Transfer details
          if (hasError)
            Text(
              transfer.error!,
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  transfer.transferredString,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                if (isActive) ...[
                  Text(
                    '${transfer.speedString} • ${transfer.progressString}',
                    style: TextStyle(
                      color: Colors.blue[400],
                      fontSize: 12,
                    ),
                  ),
                ] else ...[
                  Text(
                    'Complete',
                    style: TextStyle(
                      color: Colors.green[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../providers/app_providers.dart';
import '../services/grpc_file_transfer_service.dart';
import '../ui/ui.dart';

/// Running and recent uploads/downloads, shown under the file list
class GrpcFileTransferPanel extends ConsumerStatefulWidget {
  const GrpcFileTransferPanel({super.key});

  @override
  ConsumerState<GrpcFileTransferPanel> createState() => _GrpcFileTransferPanelState();
}

class _GrpcFileTransferPanelState extends ConsumerState<GrpcFileTransferPanel> {
  bool _expanded = true;
  Timer? _hide;

  @override
  void dispose() {
    _hide?.cancel();
    super.dispose();
  }

  /// Successful transfers disappear a few seconds after the last one ends;
  /// failures stay until cleared, so they are not missed
  void _scheduleHide(GrpcFileTransferService service, bool done, bool failed) {
    if (!done || failed) {
      _hide?.cancel();
      _hide = null;
      return;
    }
    _hide ??= Timer(const Duration(seconds: 5), () {
      _hide = null;
      if (mounted && service.activeTransfers.isEmpty) service.clearCompleted();
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.watch(grpcFileTransferServiceProvider);
    final active = service.activeTransfers;
    final recent = service.completedTransfers.take(5).toList();
    if (active.isEmpty && recent.isEmpty) return const SizedBox.shrink();
    final failed = recent.where((t) => t.error != null).length;
    _scheduleHide(service, active.isEmpty, failed > 0);

    return Material(
      color: context.cs.surfaceContainerHigh,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              dense: true,
              leading: active.isNotEmpty
                  ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Icon(
                      failed > 0 ? Icons.error_outline : Icons.check_circle_outline,
                      color: failed > 0 ? context.cs.error : context.ac.success,
                    ),
              title: Text(
                active.isNotEmpty
                    ? '${active.length} ${active.length == 1 ? 'transfer' : 'transfers'} running'
                    : failed > 0
                    ? '$failed ${failed == 1 ? 'transfer' : 'transfers'} failed'
                    : 'Transfers finished',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (active.isEmpty) TextButton(onPressed: service.clearCompleted, child: const Text('Clear')),
                  IconButton(
                    tooltip: _expanded ? 'Collapse' : 'Expand',
                    icon: Icon(_expanded ? Icons.expand_more : Icons.expand_less),
                    onPressed: () => setState(() => _expanded = !_expanded),
                  ),
                ],
              ),
            ),
            if (_expanded)
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(Insets.md, 0, Insets.md, Insets.sm),
                  children: [
                    for (final t in active)
                      _TransferRow(
                        transfer: t,
                        active: true,
                        stopping: service.isCancelling(t.id),
                        onCancel: () => service.cancelTransfer(t.id),
                      ),
                    for (final t in recent) _TransferRow(transfer: t, active: false),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TransferRow extends StatelessWidget {
  final FileTransferProgress transfer;
  final bool active;

  /// Cancel was pressed; the transfer ends at the next chunk
  final bool stopping;
  final VoidCallback? onCancel;

  const _TransferRow({required this.transfer, required this.active, this.stopping = false, this.onCancel});

  @override
  Widget build(BuildContext context) {
    final t = transfer;
    final error = t.error != null;
    final color = error
        ? context.cs.error
        : active
        ? context.cs.primary
        : context.ac.success;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Insets.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(t.isUpload ? Icons.upload : Icons.download, size: 18, color: color),
              const Gap(Insets.sm),
              Expanded(
                child: Text(t.filename, overflow: TextOverflow.ellipsis, style: context.tt.bodyMedium),
              ),
              Text(
                error
                    ? 'failed'
                    : stopping
                    ? 'stopping…'
                    : active
                    ? '${t.speedString} · ${t.progressString}'
                    : t.transferredString,
                style: context.tt.labelSmall?.copyWith(color: color, fontFeatures: tabularFigures),
              ),
              if (active && onCancel != null && !stopping)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Cancel',
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: onCancel,
                ),
            ],
          ),
          if (active) ...[
            const Gap(Insets.xs),
            UsageBar(value: (t.progress / 100).clamp(0, 1), color: color, height: 4),
          ],
          if (error)
            Padding(
              padding: const EdgeInsets.only(left: 26, top: 2),
              child: Text(
                t.error!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.tt.bodySmall?.copyWith(color: context.cs.error),
              ),
            ),
        ],
      ),
    );
  }
}

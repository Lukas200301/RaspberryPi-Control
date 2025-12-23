import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../theme/app_theme.dart';
import '../models/ssh_connection.dart';
import '../services/agent_version_service.dart';
import '../providers/app_providers.dart';
import '../providers/file_providers.dart';

class AgentUpdateBanner extends ConsumerStatefulWidget {
  final SSHConnection connection;
  final VoidCallback? onDismiss;

  const AgentUpdateBanner({
    super.key,
    required this.connection,
    this.onDismiss,
  });

  @override
  ConsumerState<AgentUpdateBanner> createState() => _AgentUpdateBannerState();
}

class _AgentUpdateBannerState extends ConsumerState<AgentUpdateBanner> {
  bool _isUpdating = false;
  String? _updateStatus;

  Future<void> _updateAgent() async {
    setState(() {
      _isUpdating = true;
      _updateStatus = 'Stopping agent...';
    });

    try {
      final sshService = ref.read(sshServiceProvider);
      
      debugPrint('Stopping all agent processes...');
      
      // Stop all agent processes
      try {
        await sshService.execute('sudo systemctl stop pi-agent 2>/dev/null || true');
        await sshService.execute('sudo systemctl stop pi-control 2>/dev/null || true');
        await sshService.execute('pkill -9 -f "\\.pi_control/agent" 2>/dev/null || true');
        await sshService.execute('pkill -9 -f "pi-agent" 2>/dev/null || true');
        await sshService.execute('pkill -9 agent 2>/dev/null || true');
        await sshService.execute('fuser -k 50051/tcp 2>/dev/null || true');
        await Future.delayed(const Duration(seconds: 1));
      } catch (e) {
        debugPrint('Error stopping agent: $e');
      }

      setState(() {
        _updateStatus = 'Removing old installation...';
      });

      // Delete the old agent installation
      debugPrint('Removing old agent installation...');
      final rmResult = await sshService.execute('rm -rf ~/.pi_control 2>&1 || echo "failed"');
      debugPrint('Remove result: $rmResult');
      
      final rmTmpResult = await sshService.execute('rm -f /tmp/pi-agent* 2>&1 || echo "done"');
      debugPrint('Remove temp result: $rmTmpResult');
      
      // Verify removal
      final checkResult = await sshService.execute('ls ~/.pi_control/agent 2>&1 || echo "NOT_FOUND"');
      debugPrint('Verification check: $checkResult');
      
      if (!checkResult.contains('NOT_FOUND') && !checkResult.contains('No such file')) {
        throw Exception('Failed to remove old agent installation');
      }
      
      debugPrint('Agent removed successfully');

      setState(() {
        _isUpdating = false;
        _updateStatus = null;
      });

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: AlertDialog(
              backgroundColor: AppTheme.glassLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppTheme.glassBorder, width: 1),
              ),
              title: const Row(
                children: [
                  Icon(Icons.check_circle, color: AppTheme.successGreen),
                  Gap(12),
                  Text('Update Prepared'),
                ],
              ),
              content: Text(
                'Old agent removed. The new agent v${AgentVersionService.requiredAgentVersion} will be automatically installed on next connection.',
              ),
              actions: [
                FilledButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await ref.read(connectionManagerProvider).disconnect();
                    if (context.mounted) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/',
                        (route) => false,
                      );
                    }
                  },
                  child: const Text('Disconnect & Reconnect'),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUpdating = false;
          _updateStatus = null;
        });

        showDialog(
          context: context,
          builder: (context) => BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: AlertDialog(
              backgroundColor: AppTheme.glassLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppTheme.glassBorder, width: 1),
              ),
              title: const Row(
                children: [
                  Icon(Icons.error_outline, color: AppTheme.errorRose),
                  Gap(12),
                  Text('Update Failed'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Failed to update agent:'),
                  const Gap(8),
                  Text(
                    e.toString(),
                    style: const TextStyle(
                      color: AppTheme.errorRose,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              actions: [
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = AgentVersionService.checkVersion(widget.connection.agentVersion);
    
    if (status != AgentVersionStatus.outdated) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.warningAmber.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.warningAmber.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: AppTheme.warningAmber,
                  size: 28,
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Agent Update Available',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.warningAmber,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        'Current v${widget.connection.agentVersion} → Update to v${AgentVersionService.requiredAgentVersion}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!_isUpdating && widget.onDismiss != null)
                  IconButton(
                    icon: const Icon(Icons.close),
                    color: AppTheme.textTertiary,
                    onPressed: widget.onDismiss,
                  ),
              ],
            ),
            if (_isUpdating) ...[
              const Gap(16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const LinearProgressIndicator(
                    backgroundColor: AppTheme.glassLight,
                    color: AppTheme.warningAmber,
                  ),
                  const Gap(8),
                  Text(
                    _updateStatus ?? 'Updating...',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ] else ...[
              const Gap(12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FilledButton.icon(
                    onPressed: _updateAgent,
                    icon: const Icon(Icons.system_update, size: 18),
                    label: const Text('Update Now'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.warningAmber,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../models/ssh_connection.dart';
import '../providers/app_providers.dart';
import '../services/connection_manager.dart';
import 'main_screen.dart';

class ConnectionsScreen extends ConsumerWidget {
  const ConnectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connections = ref.watch(connectionListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connections'),
        scrolledUnderElevation: 0,
      ),
      body: connections.isEmpty
          ? _buildEmptyState(context)
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: connections.length,
              separatorBuilder: (context, index) => const Gap(12),
              itemBuilder: (context, index) {
                final connection = connections[index];
                return _buildConnectionCard(context, ref, connection);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddConnectionDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Connection'),
        backgroundColor: AppTheme.primaryIndigo,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: GlassCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.devices,
              size: 64,
              color: AppTheme.textTertiary,
            ),
            const Gap(16),
            Text(
              'No Connections',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Gap(8),
            Text(
              'Add a Raspberry Pi connection to get started',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionCard(
    BuildContext context,
    WidgetRef ref,
    SSHConnection connection,
  ) {
    return GlassCard(
      onTap: () => _connectToDevice(context, ref, connection),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryIndigo.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.computer,
              color: AppTheme.primaryIndigo,
            ),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      connection.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (connection.isFavorite) ...[
                      const Gap(8),
                      const Icon(
                        Icons.star,
                        size: 16,
                        color: AppTheme.warningAmber,
                      ),
                    ],
                  ],
                ),
                const Gap(4),
                Text(
                  '${connection.username}@${connection.host}:${connection.port}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (connection.lastConnected != null) ...[
                  const Gap(4),
                  Text(
                    'Last: ${_formatDate(connection.lastConnected!)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textTertiary,
                        ),
                  ),
                ],
              ],
            ),
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            offset: const Offset(-8, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.transparent,
            elevation: 0,
            itemBuilder: (context) => [
              PopupMenuItem(
                padding: EdgeInsets.zero,
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.glassLight,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                    border: Border(
                      top: BorderSide(color: AppTheme.glassBorder, width: 1),
                      left: BorderSide(color: AppTheme.glassBorder, width: 1),
                      right: BorderSide(color: AppTheme.glassBorder, width: 1),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: const Row(
                    children: [
                      Icon(Icons.star_outline, size: 20),
                      Gap(12),
                      Text('Toggle Favorite'),
                    ],
                  ),
                ),
                onTap: () {
                  ref.read(connectionListProvider.notifier).toggleFavorite(connection.id);
                },
              ),
              PopupMenuItem(
                padding: EdgeInsets.zero,
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.glassLight,
                    border: Border(
                      left: BorderSide(color: AppTheme.glassBorder, width: 1),
                      right: BorderSide(color: AppTheme.glassBorder, width: 1),
                      top: BorderSide(color: AppTheme.glassBorder, width: 0.5),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: const Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      Gap(12),
                      Text('Edit'),
                    ],
                  ),
                ),
                onTap: () {
                  final ctx = context;
                  Future.delayed(Duration.zero, () {
                    _showEditConnectionDialog(ctx, ref, connection);
                  });
                },
              ),
              PopupMenuItem(
                padding: EdgeInsets.zero,
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.glassLight,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                    border: Border(
                      bottom: BorderSide(color: AppTheme.glassBorder, width: 1),
                      left: BorderSide(color: AppTheme.glassBorder, width: 1),
                      right: BorderSide(color: AppTheme.glassBorder, width: 1),
                      top: BorderSide(color: AppTheme.glassBorder, width: 0.5),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: const Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: AppTheme.errorRose),
                      Gap(12),
                      Text('Delete', style: TextStyle(color: AppTheme.errorRose)),
                    ],
                  ),
                ),
                onTap: () {
                  ref.read(connectionListProvider.notifier).deleteConnection(connection.id);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _connectToDevice(
    BuildContext context,
    WidgetRef ref,
    SSHConnection connection,
  ) async {
    final connectionManager = ref.read(connectionManagerProvider);

    // Guard: Check if already connected or connecting
    if (connectionManager.isConnecting) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Already connecting to a device...'),
          backgroundColor: AppTheme.warningAmber,
        ),
      );
      return;
    }

    if (connectionManager.isConnected) {
      final current = connectionManager.currentConnection;
      if (current?.id == connection.id) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Already connected to ${connection.name}'),
            backgroundColor: AppTheme.warningAmber,
          ),
        );
        return;
      }
    }

    // Show connecting dialog
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppTheme.primaryIndigo),
              const Gap(16),
              Text(
                'Connecting to ${connection.name}...',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );

    try {
      // Start connection
      final result = await connectionManager.connect(
        connection,
        installAgentIfNeeded: false,
        enableForwardingIfNeeded: false,
        onProgress: (message) {
          // Progress updates are handled by the state stream
        },
      );

      // Handle different result types
      if (result is SuccessResult) {
        // Update current connection state with agent version from result
        debugPrint('Connection success - agent version in result: ${result.connection.agentVersion}');
        final updatedConnection = result.connection.copyWith(
          lastConnected: DateTime.now(),
          agentVersion: result.connection.agentVersion, // Preserve agent version
        );
        ref.read(currentConnectionProvider.notifier).setConnection(updatedConnection);

        // Save updated connection with agent version
        await ref.read(connectionListProvider.notifier).updateConnection(updatedConnection);

        if (context.mounted) {
          Navigator.pop(context); // Close progress dialog

          // Navigate to main screen (dashboard)
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        }
      } else if (result is AgentSetupRequiredResult) {
        // Close connecting dialog
        if (context.mounted) Navigator.pop(context);

        // Show agent setup dialog
        if (!context.mounted) return;
        final install = await _showAgentSetupDialog(context, result.agentInfo);

        if (install == true && context.mounted) {
          final agentManager = ref.read(agentManagerProvider);
          await _installAgent(context, ref, agentManager);

          // Continue connection after agent installation
          if (context.mounted) {
            await _continueConnection(context, ref, connection);
          }
        } else {
          // User declined agent installation, cleanup
          await connectionManager.disconnect();
        }
      } else if (result is SSHForwardingRequiredResult) {
        // Close connecting dialog
        if (context.mounted) Navigator.pop(context);

        // Show SSH forwarding dialog
        if (!context.mounted) return;
        final enable = await _showEnableForwardingDialog(context);

        if (enable == true && context.mounted) {
          await connectionManager.enableSSHForwarding();

          // Continue connection after enabling forwarding
          if (context.mounted) {
            await _continueConnection(context, ref, connection);
          }
        } else {
          // User declined, cleanup
          await connectionManager.disconnect();

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('SSH forwarding required for real-time monitoring'),
                backgroundColor: AppTheme.warningAmber,
              ),
            );
          }
        }
      } else if (result is ErrorResult) {
        throw Exception(result.error);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close progress dialog
        
        debugPrint('Connection error: $e');
        
        final errorMessage = e.toString();
        
        // Check if error is about sudo requirement
        if (errorMessage.contains('SUDO_REQUIRED') || errorMessage.contains('ROOT_REQUIRED')) {
          _showRootRequiredDialog(context);
        } else if (errorMessage.contains('AUTH_FAILED') && !errorMessage.contains('SUDO_REQUIRED')) {
          // Only show auth failed if it's truly an authentication issue, not a permission issue
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Authentication failed. Please check your username and password.'),
              backgroundColor: AppTheme.errorRose,
              duration: Duration(seconds: 5),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Connection failed: $e'),
              backgroundColor: AppTheme.errorRose,
            ),
          );
        }
      }
    }
  }

  Future<void> _showRootRequiredDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.background,
        title: Row(
          children: [
            Icon(Icons.admin_panel_settings, color: AppTheme.errorRose),
            const Gap(12),
            const Text('Sudo Access Required'),
          ],
        ),
        content: Text(
          'This application requires sudo permissions to manage your Raspberry Pi.\n\nPlease reconnect using a user with sudo access (e.g., root or pi user with sudo privileges).',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _continueConnection(
    BuildContext context,
    WidgetRef ref,
    SSHConnection connection,
  ) async {
    final connectionManager = ref.read(connectionManagerProvider);

    // Show progress dialog
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppTheme.primaryIndigo),
              const Gap(16),
              Text(
                'Completing connection...',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final result = await connectionManager.continueConnection();

      if (result is SuccessResult) {
        // Update current connection state with agent version from result
        final updatedConnection = result.connection.copyWith(
          lastConnected: DateTime.now(),
          agentVersion: result.connection.agentVersion, // Preserve agent version
        );
        ref.read(currentConnectionProvider.notifier).setConnection(updatedConnection);

        // Save updated connection with agent version
        await ref.read(connectionListProvider.notifier).updateConnection(updatedConnection);

        if (context.mounted) {
          Navigator.pop(context); // Close progress dialog

          // Navigate to main screen (dashboard)
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        }
      } else if (result is ErrorResult) {
        throw Exception(result.error);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection failed: $e'),
            backgroundColor: AppTheme.errorRose,
          ),
        );
      }
    }
  }

  Future<bool?> _showEnableForwardingDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.background,
        title: const Text('Enable SSH Forwarding?'),
        content: Text(
          'SSH port forwarding is currently disabled on your Raspberry Pi.\n\n'
          'To enable real-time monitoring, we need to:\n'
          '• Modify /etc/ssh/sshd_config\n'
          '• Set AllowTcpForwarding yes\n'
          '• Restart SSH service\n\n'
          'This is required for secure gRPC communication.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryIndigo,
            ),
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showAgentSetupDialog(BuildContext context, dynamic agentInfo) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.background,
        title: const Text('Enable Real-Time Monitoring?'),
        content: Text(
          'To visualize system stats in real-time, the app needs to copy a small helper tool (Agent) to your Raspberry Pi. This takes about 5 seconds.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Use Basic Mode'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Install & Connect'),
          ),
        ],
      ),
    );
  }

  Future<void> _installAgent(
    BuildContext context,
    WidgetRef ref,
    dynamic agentManager,
  ) async {
    // Show progress dialog
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppTheme.primaryIndigo),
              const Gap(16),
              Text(
                'Installing agent...',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );

    try {
      await agentManager.installAgent(
        onProgress: (message) {
          // Could update dialog with progress
        },
      );

      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Agent installation failed: $e', style: const TextStyle(color: Colors.white)),
            backgroundColor: AppTheme.errorRose,
          ),
        );
      }
    }
  }

  void _showAddConnectionDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final hostController = TextEditingController();
    final portController = TextEditingController(text: '22');
    final usernameController = TextEditingController(text: 'pi');
    final passwordController = TextEditingController();


    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppTheme.background,
          title: const Text('Add Connection'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const Gap(16),
                TextField(
                  controller: hostController,
                  decoration: const InputDecoration(labelText: 'Host/IP'),
                ),
                const Gap(16),
                TextField(
                  controller: portController,
                  decoration: const InputDecoration(labelText: 'Port'),
                  keyboardType: TextInputType.number,
                ),
                const Gap(16),
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                const Gap(16),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final connection = SSHConnection(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  host: hostController.text,
                  port: int.tryParse(portController.text) ?? 22,
                  username: usernameController.text,
                  password: passwordController.text,
                );

                ref.read(connectionListProvider.notifier).addConnection(connection);
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditConnectionDialog(
    BuildContext context,
    WidgetRef ref,
    SSHConnection connection,
  ) {
    final nameController = TextEditingController(text: connection.name);
    final hostController = TextEditingController(text: connection.host);
    final portController = TextEditingController(text: connection.port.toString());
    final usernameController = TextEditingController(text: connection.username);
    final passwordController = TextEditingController(text: connection.password);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppTheme.background,
          title: const Text('Edit Connection'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const Gap(16),
                TextField(
                  controller: hostController,
                  decoration: const InputDecoration(labelText: 'Host/IP'),
                ),
                const Gap(16),
                TextField(
                  controller: portController,
                  decoration: const InputDecoration(labelText: 'Port'),
                  keyboardType: TextInputType.number,
                ),
                const Gap(16),
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                const Gap(16),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final updated = connection.copyWith(
                  name: nameController.text,
                  host: hostController.text,
                  port: int.tryParse(portController.text) ?? 22,
                  username: usernameController.text,
                  password: passwordController.text,

                );

                ref.read(connectionListProvider.notifier).updateConnection(updated);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

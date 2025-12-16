import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../models/ssh_connection.dart';
import '../providers/app_providers.dart';
import '../services/network_discovery_service.dart';
import '../services/transfer_manager_service.dart';
import 'main_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final Map<String, bool> _connectionStatus = {};
  bool _isCheckingStatus = false;
  bool _isDiscovering = false;
  List<DiscoveredDevice> _discoveredDevices = [];

  @override
  void initState() {
    super.initState();
    _checkConnectionStatus();
  }

  Future<void> _checkConnectionStatus() async {
    setState(() => _isCheckingStatus = true);

    final connections = ref.read(connectionListProvider);
    final discoveryService = ref.read(networkDiscoveryServiceProvider);

    final hosts = connections.map((c) => c.host).toList();
    final statuses = await discoveryService.checkHostsStatus(hosts);

    if (mounted) {
      setState(() {
        _connectionStatus.addAll(statuses);
        _isCheckingStatus = false;
      });
    }
  }

  Future<void> _discoverDevices() async {
    setState(() {
      _isDiscovering = true;
      _discoveredDevices.clear();
    });

    // Show scanning dialog
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
                'Scanning local network...',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Gap(8),
              Text(
                'This may take up to 30 seconds',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final discoveryService = ref.read(networkDiscoveryServiceProvider);
    final devices = await discoveryService.discoverSSHDevices();

    if (mounted) {
      Navigator.pop(context); // Close scanning dialog
      
      setState(() {
        _discoveredDevices = devices;
        _isDiscovering = false;
      });

      if (devices.isNotEmpty) {
        _showDiscoveredDevicesSheet(devices);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No devices found on this network. Make sure devices are powered on.', 
              style: TextStyle(color: Colors.white)),
            backgroundColor: AppTheme.warningAmber,
          ),
        );
      }
    }
  }

  void _showDiscoveredDevicesSheet(List<DiscoveredDevice> devices) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            const Gap(8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Gap(16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  const Icon(Icons.devices, color: AppTheme.primaryIndigo, size: 28),
                  const Gap(12),
                  Text(
                    'Network Devices',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  Text(
                    '${devices.length} found',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.secondaryTeal,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(16),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final device = devices[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: GlassCard(
                      onTap: () {
                        Navigator.pop(context);
                        _showAddConnectionSheet(
                          prefilledHost: device.host,
                        prefilledName: device.name != device.host ? device.name : null,
                        );
                      },
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
                              Text(
                                device.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const Gap(4),
                              Text(
                                device.host,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.secondaryTeal,
                                ),
                              ),
                              if (device.type != null) ...[
                                const Gap(2),
                                Text(
                                  device.type!,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textTertiary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.add_circle_outline,
                          size: 20,
                          color: AppTheme.primaryIndigo,
                        ),
                      ],
                    ),
                  ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddConnectionSheet({String? prefilledHost, int? prefilledPort, String? prefilledName}) {
    final nameController = TextEditingController(text: prefilledName ?? '');
    final hostController = TextEditingController(text: prefilledHost ?? '');
    final portController = TextEditingController(text: prefilledPort?.toString() ?? '22');
    final usernameController = TextEditingController(text: 'pi');
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.add_circle, color: AppTheme.primaryIndigo, size: 28),
                      const Gap(12),
                      Text(
                        'New Connection',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const Gap(24),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Connection Name',
                      prefixIcon: Icon(Icons.label),
                      hintText: 'Living Room Pi',
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const Gap(16),
                  TextFormField(
                    controller: hostController,
                    decoration: const InputDecoration(
                      labelText: 'Host/IP Address',
                      prefixIcon: Icon(Icons.dns),
                      hintText: '192.168.1.100',
                    ),
                    keyboardType: TextInputType.text,
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const Gap(16),
                  TextFormField(
                    controller: portController,
                    decoration: const InputDecoration(
                      labelText: 'Port',
                      prefixIcon: Icon(Icons.settings_ethernet),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      final port = int.tryParse(v);
                      if (port == null || port < 1 || port > 65535) return 'Invalid port';
                      return null;
                    },
                  ),
                  const Gap(16),
                  TextFormField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const Gap(16),
                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const Gap(24),
                  ElevatedButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;

                      final connection = SSHConnection(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: nameController.text.trim(),
                        host: hostController.text.trim(),
                        port: int.parse(portController.text.trim()),
                        username: usernameController.text.trim(),
                        password: passwordController.text,
                      );

                      await ref.read(connectionListProvider.notifier).addConnection(connection);

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${connection.name} saved!', 
                              style: const TextStyle(color: Colors.white)),
                            backgroundColor: AppTheme.successGreen,
                          ),
                        );
                        _checkConnectionStatus();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Save Connection'),
                  ),
                  const Gap(8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _connectToDevice(SSHConnection connection) async {
    // Show loading dialog
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
              ),
            ],
          ),
        ),
      ),
    );

    try {
      // Connect SSH
      final sshService = ref.read(sshServiceProvider);
      await sshService.connect(connection);

      // Connect TransferManagerService with same credentials
      TransferManagerService.connect(
        host: connection.host,
        port: connection.port,
        username: connection.username,
        password: connection.password,
      );

      // Check and install agent if needed
      final agentManager = ref.read(agentManagerProvider);
      final agentInfo = await agentManager.checkAgentVersion();

      if (!agentInfo.isInstalled || agentInfo.needsUpdate) {
        if (mounted) {
          Navigator.pop(context); // Close loading
          final install = await _showAgentSetupDialog(connection.name);
          if (install == true) {
            await _installAgent(agentManager, connection.name);
          } else {
            // User cancelled installation
            return;
          }
        }
      }

      // Start the agent and connect gRPC
      if (mounted) {
        // Show loading dialog for agent startup and connection
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
                    'Starting agent...',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
        );
      }

      if (mounted) {
        final sshService = ref.read(sshServiceProvider);
        
        // Check and enable SSH forwarding if needed
        try {
          final forwardCheck = await sshService.execute(
            'grep -i "^\\s*AllowTcpForwarding" /etc/ssh/sshd_config || echo "not_configured"'
          );
          debugPrint('SSH forwarding config: $forwardCheck');
          
          // Check if explicitly disabled
          if (forwardCheck.toLowerCase().contains('allowtcpforwarding no') || 
              forwardCheck.toLowerCase().contains('allowtcpforwarding=no')) {
            if (mounted) {
              final enable = await _showEnableForwardingDialog();
              if (enable == true) {
                await _enableSSHForwarding(sshService, connection);
              } else {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('SSH forwarding required for real-time monitoring',
                          style: TextStyle(color: Colors.white)),
                      backgroundColor: AppTheme.warningAmber,
                    ),
                  );
                }
                return;
              }
            }
          }
        } catch (e) {
          debugPrint('Could not check SSH config: $e');
        }

        // Kill any existing agent first
        try {
          await sshService.execute('pkill -f ".pi_control/agent" || true');
          await Future.delayed(const Duration(milliseconds: 200));
        } catch (e) {
          debugPrint('Error killing existing agent: $e');
        }
        
        // Start the agent on IPv4 specifically (bind to all interfaces for now)
        try {
          await sshService.execute('nohup ~/.pi_control/agent --host 0.0.0.0 --port 50051 > ~/.pi_control/agent.log 2>&1 & echo \$!');
          debugPrint('Agent started on Pi (0.0.0.0:50051)');
          // Give it time to start and bind to port
          await Future.delayed(const Duration(seconds: 2));
          
          // Verify agent is running and port is listening
          final portCheck = await sshService.execute('netstat -tuln | grep 50051 || ss -tuln | grep 50051 || echo "not_listening"');
          debugPrint('Port 50051 status: $portCheck');
          
          if (portCheck.contains('not_listening')) {
            throw Exception('Agent started but not listening on port 50051');
          }
        } catch (e) {
          debugPrint('Error starting agent: $e');
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to start agent: $e',
                    style: const TextStyle(color: Colors.white)),
                backgroundColor: AppTheme.errorRose,
              ),
            );
          }
          return;
        }

        // Set up SSH tunnel for gRPC
        try {
          final localPort = await sshService.forwardLocal(50051, 'localhost', 50051);
          debugPrint('SSH tunnel established: localhost:$localPort -> Pi:localhost:50051');
          
          // Give tunnel time to establish
          await Future.delayed(const Duration(seconds: 1));
        } catch (e) {
          debugPrint('Error setting up SSH tunnel: $e');
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to setup tunnel: $e',
                    style: const TextStyle(color: Colors.white)),
                backgroundColor: AppTheme.errorRose,
              ),
            );
          }
          return;
        }

        // Connect gRPC service
        try {
          final grpcService = ref.read(grpcServiceProvider);
          await grpcService.connect(50051);
          debugPrint('gRPC connected successfully');
        } catch (e) {
          debugPrint('Error connecting gRPC: $e');
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to connect to agent: $e',
                    style: const TextStyle(color: Colors.white)),
                backgroundColor: AppTheme.errorRose,
              ),
            );
          }
          return;
        }
      }

      // Update connection
      await ref.read(connectionListProvider.notifier).updateConnection(
            connection.copyWith(lastConnected: DateTime.now()),
          );
      ref.read(currentConnectionProvider.notifier).setConnection(connection);

      // Navigate
      if (mounted) {
        Navigator.pop(context); // Close loading if still open
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection failed: $e', style: const TextStyle(color: Colors.white)),
            backgroundColor: AppTheme.errorRose,
          ),
        );
      }
    }
  }

  Future<bool?> _showEnableForwardingDialog() async {
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

  Future<void> _enableSSHForwarding(dynamic sshService, SSHConnection connection) async {
    try {
      debugPrint('Enabling SSH forwarding...');
      
      // Backup original config
      await sshService.execute('sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup');
      
      // Enable AllowTcpForwarding
      await sshService.execute(
        'echo "${connection.password}" | sudo -S sed -i "s/^\\s*AllowTcpForwarding.*/AllowTcpForwarding yes/" /etc/ssh/sshd_config'
      );
      
      // Add if not exists
      await sshService.execute(
        'grep -q "^AllowTcpForwarding" /etc/ssh/sshd_config || echo "${connection.password}" | sudo -S sh -c "echo \'AllowTcpForwarding yes\' >> /etc/ssh/sshd_config"'
      );
      
      // Restart SSH service (this will drop our connection)
      await sshService.execute('echo "${connection.password}" | sudo -S systemctl restart sshd || sudo -S service ssh restart');
      
      debugPrint('SSH service restarting (connection will drop)...');
      
      // Wait for SSH service to restart and disconnect
      await Future.delayed(const Duration(seconds: 3));
      
      // Reconnect SSH
      debugPrint('Reconnecting SSH after forwarding enabled...');
      await sshService.disconnect();
      await Future.delayed(const Duration(seconds: 1));
      await sshService.connect(connection);
      debugPrint('SSH reconnected successfully');

      // Reconnect TransferManagerService
      TransferManagerService.connect(
        host: connection.host,
        port: connection.port,
        username: connection.username,
        password: connection.password,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SSH forwarding enabled and reconnected',
                style: TextStyle(color: Colors.white)),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error enabling SSH forwarding: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to enable forwarding: $e',
                style: const TextStyle(color: Colors.white)),
            backgroundColor: AppTheme.errorRose,
          ),
        );
      }
      rethrow;
    }
  }

  Future<bool?> _showAgentSetupDialog(String deviceName) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.background,
        title: const Text('Enable Real-Time Monitoring?'),
        content: Text(
          'To visualize system stats in real-time for $deviceName, install Agent v3.0 (takes ~5 seconds).',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Skip'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Install Agent'),
          ),
        ],
      ),
    );
  }

  Future<void> _installAgent(dynamic agentManager, String deviceName) async {
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
                'Installing agent on $deviceName...',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );

    try {
      await agentManager.installAgent();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Installation failed: $e', style: const TextStyle(color: Colors.white)),
            backgroundColor: AppTheme.errorRose,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final connections = ref.watch(connectionListProvider);
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.background,
              Color(0xFF0A0A1A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.primaryIndigo.withValues(alpha: 0.5),
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/icon/ic_launcher.png',
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (_isCheckingStatus)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.textTertiary,
                            ),
                          )
                        else
                          IconButton(
                            onPressed: _checkConnectionStatus,
                            icon: const Icon(Icons.refresh),
                            color: AppTheme.textSecondary,
                          ),
                      ],
                    ),
                    const Gap(16),
                    Text(
                      'Welcome Back,',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      'Commander',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
              ),

              // Connection Carousel
              if (connections.isNotEmpty) ...[
                const Gap(8),
                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    scrollDirection: Axis.horizontal,
                    itemCount: connections.length,
                    itemBuilder: (context, index) {
                      final conn = connections[index];
                      final isOnline = _connectionStatus[conn.host] ?? false;

                      return Container(
                        width: 280,
                        margin: const EdgeInsets.only(right: 16),
                        child: GlassCard(
                          padding: const EdgeInsets.all(20),
                          onTap: () => _connectToDevice(conn),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: isOnline ? AppTheme.successGreen : AppTheme.errorRose,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: (isOnline ? AppTheme.successGreen : AppTheme.errorRose)
                                              .withValues(alpha: 0.5),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Gap(8),
                                  Text(
                                    isOnline ? 'Online' : 'Offline',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isOnline ? AppTheme.successGreen : AppTheme.errorRose,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: AppTheme.textTertiary,
                                    size: 20,
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Text(
                                conn.name,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Gap(8),
                              Row(
                                children: [
                                  const Icon(Icons.computer, size: 16, color: AppTheme.secondaryTeal),
                                  const Gap(6),
                                  Expanded(
                                    child: Text(
                                      conn.host,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppTheme.secondaryTeal,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(4),
                              Row(
                                children: [
                                  const Icon(Icons.person, size: 16, color: AppTheme.textSecondary),
                                  const Gap(6),
                                  Text(
                                    '${conn.username}@${conn.host}:${conn.port}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ] else ...[
                // Empty state
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.devices_other,
                            size: 64,
                            color: AppTheme.textTertiary.withValues(alpha: 0.5),
                          ),
                          const Gap(20),
                          Text(
                            'No Connections Yet',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const Gap(8),
                          Text(
                            'Add your first Raspberry Pi to get started',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textTertiary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],

              // Quick Actions Bar
              Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.glassLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.glassBorder),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppTheme.textTertiary,
                      ),
                    ),
                    const Gap(12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showAddConnectionSheet(),
                            icon: const Icon(Icons.add),
                            label: const Text('New Connection'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const Gap(12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isDiscovering ? null : _discoverDevices,
                            icon: const Icon(Icons.radar),
                            label: const Text('Find Devices'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (connections.isNotEmpty) ...[
                      const Gap(8),
                      TextButton.icon(
                        onPressed: () => Navigator.pushNamed(context, '/connections'),
                        icon: const Icon(Icons.list, size: 18),
                        label: const Text('Manage All Connections'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

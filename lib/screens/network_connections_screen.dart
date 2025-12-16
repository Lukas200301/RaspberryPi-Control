import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../providers/app_providers.dart';
import '../generated/pi_control.pb.dart';

class NetworkConnectionsScreen extends ConsumerStatefulWidget {
  const NetworkConnectionsScreen({super.key});

  @override
  ConsumerState<NetworkConnectionsScreen> createState() => _NetworkConnectionsScreenState();
}

class _NetworkConnectionsScreenState extends ConsumerState<NetworkConnectionsScreen> {
  String _searchQuery = '';
  String _filterProtocol = 'all'; // all, tcp, udp
  String _filterStatus = 'all'; // all, established, listen

  // Well-known port mappings
  static const Map<int, String> _wellKnownPorts = {
    20: 'FTP Data',
    21: 'FTP Control',
    22: 'SSH',
    23: 'Telnet',
    25: 'SMTP',
    53: 'DNS',
    67: 'DHCP Server',
    68: 'DHCP Client',
    80: 'HTTP',
    110: 'POP3',
    123: 'NTP',
    143: 'IMAP',
    161: 'SNMP',
    162: 'SNMP Trap',
    179: 'BGP',
    194: 'IRC',
    389: 'LDAP',
    443: 'HTTPS',
    445: 'SMB',
    465: 'SMTPS',
    514: 'Syslog',
    587: 'SMTP',
    631: 'IPP',
    636: 'LDAPS',
    993: 'IMAPS',
    995: 'POP3S',
    1433: 'MS SQL',
    1521: 'Oracle DB',
    1723: 'PPTP',
    3306: 'MySQL',
    3389: 'RDP',
    5432: 'PostgreSQL',
    5900: 'VNC',
    6379: 'Redis',
    8080: 'HTTP Alt',
    8443: 'HTTPS Alt',
    9090: 'Prometheus',
    27017: 'MongoDB',
    50051: 'gRPC',
  };

  String _getPortDescription(int port) {
    return _wellKnownPorts[port] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Connections'),
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Field
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by address, port, or process...',
                    prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                    filled: true,
                    fillColor: AppTheme.glassLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.glassBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.glassBorder),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
                const Gap(12),
                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All Protocols', 'all', Icons.public),
                      const Gap(8),
                      _buildFilterChip('TCP', 'tcp', Icons.swap_horiz, AppTheme.primaryIndigo),
                      const Gap(8),
                      _buildFilterChip('UDP', 'udp', Icons.swap_vert, AppTheme.secondaryTeal),
                      const Gap(16),
                      _buildStatusChip('All States', 'all', Icons.circle),
                      const Gap(8),
                      _buildStatusChip('Established', 'established', Icons.link, AppTheme.successGreen),
                      const Gap(8),
                      _buildStatusChip('Listen', 'listen', Icons.hearing, AppTheme.warningAmber),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Connections List
          Expanded(
            child: _buildConnectionsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {});
        },
        backgroundColor: AppTheme.primaryIndigo,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, IconData icon, [Color? color]) {
    final isSelected = _filterProtocol == value;
    final chipColor = color ?? AppTheme.textSecondary;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? chipColor : AppTheme.textSecondary),
          const Gap(6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterProtocol = value;
        });
      },
      backgroundColor: AppTheme.glassLight,
      selectedColor: chipColor.withValues(alpha: 0.3),
      checkmarkColor: chipColor,
      labelStyle: TextStyle(
        color: isSelected ? chipColor : AppTheme.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? chipColor : AppTheme.glassBorder,
      ),
    );
  }

  Widget _buildStatusChip(String label, String value, IconData icon, [Color? color]) {
    final isSelected = _filterStatus == value;
    final chipColor = color ?? AppTheme.textSecondary;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? chipColor : AppTheme.textSecondary),
          const Gap(6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterStatus = value;
        });
      },
      backgroundColor: AppTheme.glassLight,
      selectedColor: chipColor.withValues(alpha: 0.3),
      checkmarkColor: chipColor,
      labelStyle: TextStyle(
        color: isSelected ? chipColor : AppTheme.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? chipColor : AppTheme.glassBorder,
      ),
    );
  }

  Widget _buildConnectionsList() {
    final grpcService = ref.read(grpcServiceProvider);

    return FutureBuilder<NetworkConnectionList>(
      future: grpcService.getNetworkConnections(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryIndigo),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.errorRose,
                  ),
                  const Gap(16),
                  Text(
                    'Error loading connections',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Gap(8),
                  Text(
                    snapshot.error.toString(),
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final connections = snapshot.data?.connections.toList() ?? <NetworkConnection>[];
        final filteredConnections = _filterConnections(connections);

        if (filteredConnections.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_off,
                  size: 64,
                  color: AppTheme.textTertiary.withValues(alpha: 0.5),
                ),
                const Gap(16),
                Text(
                  'No connections found',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: filteredConnections.length,
          itemBuilder: (context, index) {
            return _buildConnectionCard(filteredConnections[index]);
          },
        );
      },
    );
  }

  List<NetworkConnection> _filterConnections(List<NetworkConnection> connections) {
    return connections.where((conn) {
      // Filter by protocol
      if (_filterProtocol != 'all') {
        if (!conn.protocol.toLowerCase().contains(_filterProtocol)) {
          return false;
        }
      }

      // Filter by status
      if (_filterStatus != 'all') {
        if (!conn.status.toLowerCase().contains(_filterStatus)) {
          return false;
        }
      }

      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        final searchLower = _searchQuery.toLowerCase();
        return conn.localAddress.toLowerCase().contains(searchLower) ||
            conn.remoteAddress.toLowerCase().contains(searchLower) ||
            conn.localPort.toString().contains(searchLower) ||
            conn.remotePort.toString().contains(searchLower) ||
            conn.processName.toLowerCase().contains(searchLower);
      }

      return true;
    }).toList();
  }

  Widget _buildConnectionCard(NetworkConnection conn) {
    Color statusColor;
    IconData statusIcon;

    final status = conn.status.toLowerCase();
    if (status.contains('established')) {
      statusColor = AppTheme.successGreen;
      statusIcon = Icons.check_circle;
    } else if (status.contains('listen')) {
      statusColor = AppTheme.warningAmber;
      statusIcon = Icons.hearing;
    } else if (status.contains('close') || status.contains('time_wait')) {
      statusColor = AppTheme.errorRose;
      statusIcon = Icons.close;
    } else {
      statusColor = AppTheme.textSecondary;
      statusIcon = Icons.circle;
    }

    final protocolColor = conn.protocol.contains('TCP')
        ? AppTheme.primaryIndigo
        : AppTheme.secondaryTeal;

    // Get port descriptions for display in top right
    final localPortDesc = _getPortDescription(conn.localPort);
    final remotePortDesc = conn.remoteAddress.isNotEmpty ? _getPortDescription(conn.remotePort) : '';
    final hasPortDesc = localPortDesc.isNotEmpty || remotePortDesc.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Protocol and Status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: protocolColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    conn.protocol,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: protocolColor,
                    ),
                  ),
                ),
                const Gap(8),
                Icon(statusIcon, size: 16, color: statusColor),
                const Gap(4),
                Text(
                  conn.status,
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // Known Ports Display - Top Right
                if (hasPortDesc) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (localPortDesc.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryIndigo.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: AppTheme.primaryIndigo.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            localPortDesc,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.primaryIndigo,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (localPortDesc.isNotEmpty && remotePortDesc.isNotEmpty)
                        const Gap(4),
                      if (remotePortDesc.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryTeal.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: AppTheme.secondaryTeal.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            remotePortDesc,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.secondaryTeal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const Gap(8),
                ],
                if (conn.processName.isNotEmpty) ...[
                  const Icon(Icons.apps, size: 14, color: AppTheme.textTertiary),
                  const Gap(4),
                  Text(
                    conn.processName,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
            const Gap(12),
            const Divider(color: AppTheme.glassBorder, height: 1),
            const Gap(12),
            // Local Address
            Row(
              children: [
                const Icon(Icons.computer, size: 16, color: AppTheme.primaryIndigo),
                const Gap(8),
                const Text(
                  'Local:',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: Text(
                    '${conn.localAddress}:${conn.localPort}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: 'monospace',
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const Gap(8),
            // Remote Address
            Row(
              children: [
                const Icon(Icons.public, size: 16, color: AppTheme.secondaryTeal),
                const Gap(8),
                const Text(
                  'Remote:',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: Text(
                    conn.remoteAddress.isEmpty
                        ? '*:*'
                        : '${conn.remoteAddress}:${conn.remotePort}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: 'monospace',
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            if (conn.pid != 0) ...[
              const Gap(8),
              Row(
                children: [
                  const Icon(Icons.tag, size: 16, color: AppTheme.textTertiary),
                  const Gap(8),
                  Text(
                    'PID: ${conn.pid}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textTertiary,
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/services/ssh_service_controller.dart';

class NetworkConnectionsPage extends StatefulWidget {
  const NetworkConnectionsPage({Key? key}) : super(key: key);

  @override
  State<NetworkConnectionsPage> createState() => _NetworkConnectionsPageState();
}

class _NetworkConnectionsPageState extends State<NetworkConnectionsPage> {
  String _searchQuery = '';
  String _filterProtocol = 'All';
  String _filterState = 'All';
  String _sortBy = 'State';
  List<dynamic> _connections = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConnections();
  }

  Future<void> _loadConnections() async {
    setState(() => _isLoading = true);
    try {
      final sshController = Get.find<SSHServiceController>();
      final stats = await sshController.service?.getDetailedStats();
      if (stats != null && mounted) {
        setState(() {
          _connections = stats['active_connections'] as List? ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<Map<String, dynamic>> get _filteredConnections {
    var connections = List<Map<String, dynamic>>.from(_connections);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      connections = connections.where((conn) {
        final protocol = conn['protocol']?.toString().toLowerCase() ?? '';
        final localIp = conn['local_ip']?.toString().toLowerCase() ?? '';
        final remoteIp = conn['remote_ip']?.toString().toLowerCase() ?? '';
        final state = conn['state']?.toString().toLowerCase() ?? '';
        final query = _searchQuery.toLowerCase();

        return protocol.contains(query) ||
            localIp.contains(query) ||
            remoteIp.contains(query) ||
            state.contains(query);
      }).toList();
    }

    // Apply protocol filter
    if (_filterProtocol != 'All') {
      connections = connections.where((conn) {
        return conn['protocol']?.toString().toUpperCase() == _filterProtocol;
      }).toList();
    }

    // Apply state filter
    if (_filterState != 'All') {
      connections = connections.where((conn) {
        return conn['state']?.toString().toUpperCase() == _filterState;
      }).toList();
    }

    // Apply sorting
    connections.sort((a, b) {
      switch (_sortBy) {
        case 'Protocol':
          return (a['protocol'] ?? '').toString().compareTo(
            (b['protocol'] ?? '').toString(),
          );
        case 'Local IP':
          return (a['local_ip'] ?? '').toString().compareTo(
            (b['local_ip'] ?? '').toString(),
          );
        case 'Remote IP':
          return (a['remote_ip'] ?? '').toString().compareTo(
            (b['remote_ip'] ?? '').toString(),
          );
        case 'State':
        default:
          return (a['state'] ?? '').toString().compareTo(
            (b['state'] ?? '').toString(),
          );
      }
    });

    return connections;
  }

  Color _getConnectionStateColor(String? state) {
    if (state == null) return Colors.grey;
    switch (state.toUpperCase()) {
      case 'ESTABLISHED':
        return Colors.green;
      case 'TIME_WAIT':
        return Colors.orange;
      case 'CLOSE_WAIT':
        return Colors.amber;
      case 'SYN_SENT':
      case 'SYN_RECV':
        return Colors.blue;
      case 'FIN_WAIT1':
      case 'FIN_WAIT2':
        return Colors.purple;
      case 'CLOSED':
        return Colors.red;
      case 'LISTEN':
        return AppColors.accentCyan;
      default:
        return Colors.grey;
    }
  }

  Map<String, int> get _connectionStats {
    final stats = <String, int>{
      'total': _connections.length,
      'tcp': 0,
      'udp': 0,
      'established': 0,
      'time_wait': 0,
      'listen': 0,
    };

    for (var conn in _connections) {
      final protocol = conn['protocol']?.toString().toUpperCase() ?? '';
      final state = conn['state']?.toString().toUpperCase() ?? '';

      if (protocol == 'TCP') stats['tcp'] = (stats['tcp'] ?? 0) + 1;
      if (protocol == 'UDP') stats['udp'] = (stats['udp'] ?? 0) + 1;
      if (state == 'ESTABLISHED') stats['established'] = (stats['established'] ?? 0) + 1;
      if (state == 'TIME_WAIT') stats['time_wait'] = (stats['time_wait'] ?? 0) + 1;
      if (state == 'LISTEN') stats['listen'] = (stats['listen'] ?? 0) + 1;
    }

    return stats;
  }

  void _showConnectionDetails(Map<String, dynamic> connection) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A0A),
            borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
            border: Border.all(color: AppColors.accentCyan, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accentCyan.withOpacity(0.2),
                      Colors.transparent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppDimensions.radiusCard),
                    topRight: Radius.circular(AppDimensions.radiusCard),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.accentCyan.withOpacity(0.3),
                            AppColors.accentCyan.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.lan_outlined,
                        color: AppColors.accentCyan,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Connection Details',
                            style: TextStyle(
                              color: AppColors.accentCyan,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            connection['protocol']?.toString().toUpperCase() ?? 'N/A',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(
                      'Protocol',
                      connection['protocol']?.toString().toUpperCase() ?? 'N/A',
                      Icons.category_outlined,
                    ),
                    const Divider(color: Colors.white10, height: 24),
                    _buildDetailRow(
                      'Local Address',
                      '${connection['local_ip']}:${connection['local_port']}',
                      Icons.computer_outlined,
                      selectable: true,
                    ),
                    const Divider(color: Colors.white10, height: 24),
                    _buildDetailRow(
                      'Remote Address',
                      '${connection['remote_ip']}:${connection['remote_port']}',
                      Icons.public_outlined,
                      selectable: true,
                    ),
                    const Divider(color: Colors.white10, height: 24),
                    _buildDetailRow(
                      'State',
                      connection['state']?.toString().toUpperCase() ?? 'N/A',
                      Icons.info_outline,
                      color: _getConnectionStateColor(connection['state']),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon, {
    Color? color,
    bool selectable = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color ?? AppColors.accentCyan, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              selectable
                  ? SelectableText(
                      value,
                      style: TextStyle(
                        color: color ?? Colors.white,
                        fontSize: 14,
                        fontFamily: 'monospace',
                      ),
                    )
                  : Text(
                      value,
                      style: TextStyle(
                        color: color ?? Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, int value, Color color) {
    return Expanded(
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.2),
              color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          border: Border.all(color: color.withOpacity(0.5), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value.toString(),
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, Color color, bool isProtocol) {
    final isSelected = isProtocol
        ? _filterProtocol == value
        : _filterState == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isProtocol) {
            _filterProtocol = value;
          } else {
            _filterState = value;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
                )
              : null,
          color: isSelected ? null : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.white.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? color : Colors.white70,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionCard(Map<String, dynamic> connection) {
    final state = connection['state']?.toString().toUpperCase() ?? 'N/A';
    final stateColor = _getConnectionStateColor(state);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showConnectionDetails(connection),
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.accentCyan.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
              borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
              border: Border.all(
                color: stateColor.withOpacity(0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: stateColor.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.accentCyan.withOpacity(0.3),
                              AppColors.accentCyan.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.lan_outlined,
                          color: AppColors.accentCyan,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              connection['protocol']?.toString().toUpperCase() ?? 'N/A',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${connection['local_ip']}:${connection['local_port']} → ${connection['remote_ip']}:${connection['remote_port']}',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: stateColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: stateColor, width: 1),
                        ),
                        child: Text(
                          state,
                          style: TextStyle(
                            color: stateColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.accentCyan.withOpacity(0.2),
                  AppColors.accentCyan.withOpacity(0.05),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lan_outlined,
              size: 64,
              color: AppColors.accentCyan.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Connections Found',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Row(
          children: [
            Icon(Icons.lan_outlined, color: AppColors.accentCyan),
            const SizedBox(width: 12),
            const Text(
              'Network Connections',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.accentCyan.withOpacity(0.3),
                    AppColors.accentCyan.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.accentCyan, width: 1),
              ),
              child: Text(
                '${_connections.length}',
                style: TextStyle(
                  color: AppColors.accentCyan,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: Colors.white),
            color: const Color(0xFF1A1A1A),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (context) => [
              'State',
              'Protocol',
              'Local IP',
              'Remote IP',
            ].map((sort) {
              return PopupMenuItem(
                value: sort,
                child: Row(
                  children: [
                    if (_sortBy == sort)
                      Icon(Icons.check, color: AppColors.accentCyan, size: 20)
                    else
                      const SizedBox(width: 20),
                    const SizedBox(width: 8),
                    Text(
                      sort,
                      style: TextStyle(
                        color: _sortBy == sort ? AppColors.accentCyan : Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppColors.accentCyan),
            )
          : Column(
              children: [
                // Stats Overview
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _buildStatCard('TCP', _connectionStats['tcp']!, AppColors.accentIndigo),
                      const SizedBox(width: 12),
                      _buildStatCard('UDP', _connectionStats['udp']!, AppColors.accentPurple),
                      const SizedBox(width: 12),
                      _buildStatCard('Active', _connectionStats['established']!, Colors.green),
                    ],
                  ),
                ),
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accentCyan.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search connections...',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    prefixIcon: Icon(Icons.search, color: AppColors.accentCyan),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildFilterChip('All', 'All', AppColors.accentIndigo, true),
                  const SizedBox(width: 8),
                  _buildFilterChip('TCP', 'TCP', AppColors.accentIndigo, true),
                  const SizedBox(width: 8),
                  _buildFilterChip('UDP', 'UDP', AppColors.accentPurple, true),
                  const SizedBox(width: 16),
                  _buildFilterChip('All States', 'All', AppColors.accentCyan, false),
                  const SizedBox(width: 8),
                  _buildFilterChip('Established', 'ESTABLISHED', Colors.green, false),
                  const SizedBox(width: 8),
                  _buildFilterChip('Listen', 'LISTEN', AppColors.accentCyan, false),
                ],
              ),
            ),
                const SizedBox(height: 16),
                // Connection List
                Expanded(
                  child: _filteredConnections.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredConnections.length,
                          itemBuilder: (context, index) {
                            final connection = _filteredConnections[index];
                            return _buildConnectionCard(connection);
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

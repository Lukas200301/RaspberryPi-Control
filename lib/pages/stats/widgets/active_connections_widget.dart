import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:isolate';
import 'dart:math' as math;

class ConnectionUtils {
  static bool isSpecialConnection(Map<String, dynamic> connection) {
    if (connection['local_port'] == '22' || connection['remote_port'] == '22') {
      return true;
    }
    
    if (connection['remote_ip'] == '0.0.0.0' || 
        connection['remote_ip'] == '::' || 
        connection['remote_ip'].isEmpty) {
      return true;
    }
    
    if (connection['local_port'] == '80' || 
        connection['local_port'] == '443' || 
        connection['remote_port'] == '80' || 
        connection['remote_port'] == '443') {
      return true;
    }
    
    return false;
  }
  
  static Widget buildStateWithColor(String state) {
    Color stateColor = getStateColor(state);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: stateColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: stateColor.withOpacity(0.5))
      ),
      child: Text(
        state.isEmpty ? 'Unknown' : state,
        style: TextStyle(
          fontSize: 13,
          color: stateColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  static Color getStateColor(String state) {
    switch (state) {
      case 'ESTABLISHED':
        return Colors.green;
      case 'TIME_WAIT':
      case 'CLOSE_WAIT':
        return Colors.orange;
      case 'SYN_SENT':
      case 'SYN_RECV':
        return Colors.blue;
      case 'CLOSED':
      case 'CLOSING':
      case 'LAST_ACK':
      case 'FIN_WAIT1':
      case 'FIN_WAIT2':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class NetworkConnection {
  final String protocol;
  final String localIp;
  final String localPort;
  final String remoteIp;
  final String remotePort;
  final String state;

  NetworkConnection({
    required this.protocol,
    required this.localIp,
    required this.localPort,
    required this.remoteIp,
    required this.remotePort,
    required this.state,
  });

  factory NetworkConnection.fromMap(Map<String, dynamic> map) {
    return NetworkConnection(
      protocol: map['protocol'] ?? '',
      localIp: map['local_ip'] ?? '',
      localPort: map['local_port'] ?? '',
      remoteIp: map['remote_ip'] ?? '',
      remotePort: map['remote_port'] ?? '',
      state: map['state'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'protocol': protocol,
      'local_ip': localIp,
      'local_port': localPort,
      'remote_ip': remoteIp,
      'remote_port': remotePort,
      'state': state,
    };
  }

  bool isSpecial() {
    return ConnectionUtils.isSpecialConnection(toMap());
  }
}

class ActiveConnectionsWidget extends StatelessWidget {
  final List<dynamic> connections;

  const ActiveConnectionsWidget({
    Key? key,
    required this.connections,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<NetworkConnection> safeConnections = _convertToSafeConnections(connections);
    
    final visibleConnections = safeConnections.take(5).toList();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.device_hub),
                const SizedBox(width: 8),
                const Text(
                  'Active Network Connections',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${safeConnections.length} connections',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (safeConnections.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'No active connections',
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              )
            else
              Column(
                children: List.generate(
                  visibleConnections.length,
                  (index) {
                    final connection = visibleConnections[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 4),
                      child: InkWell(
                        onTap: () => _showConnectionDetails(context, connection.toMap()),
                        child: ListTile(
                          dense: true,
                          title: Row(
                            children: [
                              Expanded(
                                flex: 5,
                                child: Text(
                                  '${connection.localIp}:${connection.localPort}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(Icons.arrow_forward, size: 16),
                              Expanded(
                                flex: 5,
                                child: Text(
                                  '${connection.remoteIp}:${connection.remotePort}',
                                  style: const TextStyle(fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                connection.protocol,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              _buildConnectionState(context, connection.state),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.info_outline, size: 18),
                            onPressed: () => _showConnectionDetails(context, connection.toMap()),
                            tooltip: 'Connection details',
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
            if (safeConnections.length > 5)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: OutlinedButton(
                  onPressed: () => _navigateToAllConnections(context, safeConnections),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(40),
                  ),
                  child: const Text('Show All Connections'),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  List<NetworkConnection> _convertToSafeConnections(List<dynamic> rawConnections) {
    final List<NetworkConnection> result = [];
    
    try {
      for (final conn in rawConnections) {
        if (conn == null || conn is! Map<String, dynamic>) continue;
        
        result.add(NetworkConnection.fromMap(conn));
      }
    } catch (e) {
      print('Error converting connections: $e');
    }
    
    return result;
  }

  void _navigateToAllConnections(BuildContext context, List<NetworkConnection> connections) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllConnectionsPage(
          connections: connections,
        ),
      ),
    );
  }
  
  Widget _buildConnectionState(BuildContext context, String state) {
    Color stateColor = ConnectionUtils.getStateColor(state);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: stateColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: stateColor.withOpacity(0.5))
      ),
      child: Text(
        state,
        style: TextStyle(
          fontSize: 10,
          color: stateColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  void _showConnectionDetails(BuildContext context, Map<String, dynamic> connection) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Connection Details',
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              _buildDetailRow(
                'Protocol', 
                connection['protocol'], 
                Icons.settings_ethernet
              ),
              const Divider(),
              _buildDetailRow(
                'Local Address',
                '${connection['local_ip']}:${connection['local_port']}',
                Icons.computer
              ),
              const Divider(),
              _buildDetailRow(
                'Remote Address',
                '${connection['remote_ip']}:${connection['remote_port']}',
                Icons.public
              ),
              const Divider(),
              _buildDetailRow(
                'Connection State',
                connection['state'] ?? 'Unknown',
                Icons.info,
                isState: true,
                state: connection['state']
              ),
              
              if (ConnectionUtils.isSpecialConnection(connection)) ...[
                const Divider(),
                _buildConnectionNotes(connection),
              ],
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildDetailRow(String label, String value, IconData icon, {bool isState = false, String? state}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                isState 
                  ? ConnectionUtils.buildStateWithColor(state ?? 'Unknown')
                  : Text(
                      value,
                      style: const TextStyle(fontSize: 14),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildConnectionNotes(Map<String, dynamic> connection) {
    String message = '';
    String title = 'Notes';
    IconData noteIcon = Icons.note;
    
    if (connection['local_port'] == '22' || connection['remote_port'] == '22') {
      message = 'This appears to be an SSH connection. This is likely your current SSH session to this Raspberry Pi.';
      title = 'SSH Connection';
      noteIcon = Icons.vpn_key;
    }
    else if (connection['remote_ip'] == '0.0.0.0' || 
             connection['remote_ip'] == '::' || 
             connection['remote_ip'].isEmpty) {
      message = 'This connection is in a listening state waiting for incoming connections.';
      title = 'Listening Socket';
      noteIcon = Icons.hearing;
    }
    else if (connection['local_port'] == '80' || 
             connection['local_port'] == '443' || 
             connection['remote_port'] == '80' || 
             connection['remote_port'] == '443') {
      final isHttps = connection['local_port'] == '443' || connection['remote_port'] == '443';
      message = 'This appears to be ${isHttps ? 'a secure HTTPS' : 'an HTTP'} web connection.';
      title = isHttps ? 'HTTPS Connection' : 'HTTP Connection';
      noteIcon = Icons.language;
    }
    
    return _buildDetailRow(title, message, noteIcon);
  }
}

class AllConnectionsPage extends StatefulWidget {
  final List<NetworkConnection> connections;

  const AllConnectionsPage({
    Key? key,
    required this.connections,
  }) : super(key: key);

  @override
  State<AllConnectionsPage> createState() => _AllConnectionsPageState();
}

class _AllConnectionsPageState extends State<AllConnectionsPage> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  List<NetworkConnection> _filteredConnections = [];
  String _sortOption = 'state';
  
  static const int _pageSize = 50;
  int _currentPage = 0;
  bool _hasMoreItems = true;
  bool _isLoading = true;
  ScrollController _scrollController = ScrollController();
  
  Isolate? _isolate;
  ReceivePort? _receivePort;
  Completer<void>? _processingCompleter;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_scrollListener);
    
    _loadInitialConnections();
  }
  
  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && 
        !_isLoading && 
        _hasMoreItems) {
      _loadMoreConnections();
    }
  }

  Future<void> _loadInitialConnections() async {
    setState(() {
      _isLoading = true;
      _currentPage = 0;
      _filteredConnections = [];
    });
    
    await _filterAndSortConnections();
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        _hasMoreItems = _filteredConnections.length >= _pageSize;
      });
    }
  }
  
  Future<void> _loadMoreConnections() async {
    if (_isLoading || !_hasMoreItems) return;
    
    setState(() {
      _isLoading = true;
      _currentPage++;
    });
    
    await _filterAndSortConnections(appendMode: true);
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _onSearchChanged() {
    if (_searchQuery != _searchController.text) {
      _searchQuery = _searchController.text;
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 300), () {
        _loadInitialConnections();
      });
    }
  }
  
  Timer? _debounceTimer;

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    _debounceTimer?.cancel();
    _cancelBackgroundProcessing();
    super.dispose();
  }
  
  void _cancelBackgroundProcessing() {
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _receivePort?.close();
    _receivePort = null;
    _processingCompleter?.complete();
    _processingCompleter = null;
  }

  Future<void> _filterAndSortConnections({bool appendMode = false}) async {
    _cancelBackgroundProcessing();
    
    final receivePort = ReceivePort();
    _receivePort = receivePort;
    _processingCompleter = Completer<void>();
    
    try {
      if (!appendMode) {
        _filteredConnections = [];
      }
      
      final startIdx = _currentPage * _pageSize;
      final endIdx = math.min(startIdx + _pageSize, widget.connections.length);
      
      if (startIdx >= widget.connections.length) {
        setState(() {
          _hasMoreItems = false;
          _isLoading = false;
        });
        return;
      }
      
      final currentPageConnections = widget.connections.sublist(startIdx, endIdx);
      
      _isolate = await Isolate.spawn(
        _isolateProcessing,
        {
          'sendPort': receivePort.sendPort,
          'connections': currentPageConnections,
          'searchQuery': _searchQuery,
          'sortOption': _sortOption,
        },
      );
      
      receivePort.listen((message) {
        if (message is List<NetworkConnection>) {
          if (mounted) {
            setState(() {
              if (appendMode) {
                _filteredConnections.addAll(message);
              } else {
                _filteredConnections = message;
              }
              
              _hasMoreItems = endIdx < widget.connections.length;
            });
          }
          
          _cancelBackgroundProcessing();
        }
      });
      
      Timer(const Duration(seconds: 10), () {
        if (_processingCompleter?.isCompleted == false) {
          print('Processing timed out, cleaning up resources');
          _cancelBackgroundProcessing();
          
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      });
      
      return _processingCompleter!.future;
    } catch (e) {
      print('Error processing connections: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  static void _isolateProcessing(Map<String, dynamic> params) {
    final SendPort sendPort = params['sendPort'];
    final connections = params['connections'] as List<NetworkConnection>;
    final searchQuery = params['searchQuery'] as String;
    final sortOption = params['sortOption'] as String;
    
    final result = connections.where((connection) {
      if (searchQuery.isEmpty) return true;
      
      final localIp = connection.localIp.toLowerCase();
      final localPort = connection.localPort.toLowerCase();
      final remoteIp = connection.remoteIp.toLowerCase();
      final remotePort = connection.remotePort.toLowerCase();
      final protocol = connection.protocol.toLowerCase();
      final state = connection.state.toLowerCase();
      
      final query = searchQuery.toLowerCase();
      
      return localIp.contains(query) ||
             localPort.contains(query) ||
             remoteIp.contains(query) ||
             remotePort.contains(query) ||
             protocol.contains(query) ||
             state.contains(query) ||
             '$localIp:$localPort'.contains(query) ||
             '$remoteIp:$remotePort'.contains(query);
    }).toList();
    
    switch (sortOption) {
      case 'state':
        result.sort((a, b) {
          if (a.state == 'ESTABLISHED' && b.state != 'ESTABLISHED') return -1;
          if (b.state == 'ESTABLISHED' && a.state != 'ESTABLISHED') return 1;
          return a.state.compareTo(b.state);
        });
        break;
      case 'protocol':
        result.sort((a, b) => a.protocol.compareTo(b.protocol));
        break;
      case 'local_port':
        result.sort((a, b) {
          final portA = int.tryParse(a.localPort) ?? 0;
          final portB = int.tryParse(b.localPort) ?? 0;
          return portA.compareTo(portB);
        });
        break;
      case 'remote_ip':
        result.sort((a, b) => a.remoteIp.compareTo(b.remoteIp));
        break;
    }
    
    sendPort.send(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Connections'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort by',
            onSelected: (value) {
              setState(() {
                _sortOption = value;
                _loadInitialConnections();
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'state',
                child: Text('Sort by Connection State'),
              ),
              const PopupMenuItem(
                value: 'protocol',
                child: Text('Sort by Protocol'),
              ),
              const PopupMenuItem(
                value: 'local_port',
                child: Text('Sort by Local Port'),
              ),
              const PopupMenuItem(
                value: 'remote_ip',
                child: Text('Sort by Remote IP'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search connections',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
              ),
            ),
          ),
          Expanded(
            child: _filteredConnections.isEmpty && !_isLoading
              ? const Center(
                  child: Text(
                    'No connections found',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : Stack(
                  children: [
                    ListView.builder(
                      controller: _scrollController,
                      itemCount: _filteredConnections.length + (_hasMoreItems ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _filteredConnections.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        
                        final connection = _filteredConnections[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: ListTile(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${connection.localIp}:${connection.localPort}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    const Icon(Icons.arrow_forward, size: 14),
                                    Expanded(
                                      child: Text(
                                        '${connection.remoteIp}:${connection.remotePort}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            subtitle: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  connection.protocol,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                _buildConnectionState(context, connection.state),
                              ],
                            ),
                            leading: Icon(
                              _getConnectionIcon(connection),
                              color: ConnectionUtils.getStateColor(connection.state),
                            ),
                            onTap: () => _showConnectionDetails(context, connection),
                          ),
                        );
                      },
                    ),
                    if (_isLoading && _filteredConnections.isEmpty)
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                  ],
                ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Showing ${_filteredConnections.length} of ${widget.connections.length} connections',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildConnectionState(BuildContext context, String state) {
    Color stateColor = ConnectionUtils.getStateColor(state);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: stateColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: stateColor.withOpacity(0.5))
      ),
      child: Text(
        state,
        style: TextStyle(
          fontSize: 10,
          color: stateColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  IconData _getConnectionIcon(NetworkConnection connection) {
    if (connection.localPort == '22' || connection.remotePort == '22') {
      return Icons.vpn_key;
    } else if (connection.localPort == '80' || 
              connection.localPort == '443' ||
              connection.remotePort == '80' || 
              connection.remotePort == '443') {
      return Icons.language;
    } else if (connection.remoteIp == '0.0.0.0' || 
              connection.remoteIp == '::' || 
              connection.remoteIp.isEmpty) {
      return Icons.hearing;
    }
    return Icons.public;
  }
  
  void _showConnectionDetails(BuildContext context, NetworkConnection connection) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Connection Details',
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              _buildDetailRow(
                'Protocol', 
                connection.protocol, 
                Icons.settings_ethernet
              ),
              const Divider(),
              _buildDetailRow(
                'Local Address',
                '${connection.localIp}:${connection.localPort}',
                Icons.computer
              ),
              const Divider(),
              _buildDetailRow(
                'Remote Address',
                '${connection.remoteIp}:${connection.remotePort}',
                Icons.public
              ),
              const Divider(),
              _buildDetailRow(
                'Connection State',
                connection.state,
                Icons.info,
                isState: true,
                state: connection.state
              ),
              
              if (connection.isSpecial()) ...[
                const Divider(),
                _buildConnectionNotes(connection),
              ],
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildDetailRow(String label, String value, IconData icon, {bool isState = false, String? state}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                isState 
                  ? ConnectionUtils.buildStateWithColor(state ?? 'Unknown')
                  : Text(
                      value,
                      style: const TextStyle(fontSize: 14),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildConnectionNotes(NetworkConnection connection) {
    String message = '';
    String title = 'Notes';
    IconData noteIcon = Icons.note;
    
    if (connection.localPort == '22' || connection.remotePort == '22') {
      message = 'This appears to be an SSH connection. This is likely your current SSH session to this Raspberry Pi.';
      title = 'SSH Connection';
      noteIcon = Icons.vpn_key;
    }
    else if (connection.remoteIp == '0.0.0.0' || 
             connection.remoteIp == '::' || 
             connection.remoteIp.isEmpty) {
      message = 'This connection is in a listening state waiting for incoming connections.';
      title = 'Listening Socket';
      noteIcon = Icons.hearing;
    }
    else if (connection.localPort == '80' || 
             connection.localPort == '443' || 
             connection.remotePort == '80' || 
             connection.remotePort == '443') {
      final isHttps = connection.localPort == '443' || connection.remotePort == '443';
      message = 'This appears to be ${isHttps ? 'a secure HTTPS' : 'an HTTP'} web connection.';
      title = isHttps ? 'HTTPS Connection' : 'HTTP Connection';
      noteIcon = Icons.language;
    }
    
    return _buildDetailRow(title, message, noteIcon);
  }
}

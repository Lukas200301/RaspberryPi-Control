import 'package:flutter/material.dart';
import 'dart:ui';
import '../../services/ssh_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Connection extends StatefulWidget {
  final Function(SSHService?) setSSHService;
  final String connectionStatus;

  const Connection({
    super.key,
    required this.setSSHService,
    required this.connectionStatus,
  });

  @override
  ConnectionState createState() => ConnectionState();
}

class ConnectionState extends State<Connection> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _hostController = TextEditingController();
  final TextEditingController _portController = TextEditingController(text: '22');
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  SSHService? sshService;
  bool isConnected = false;
  String connectionStatus = '';
  int? _editingIndex;
  List<Map<String, dynamic>> connections = [];
  String _testConnectionStatus = '';
  String _currentSort = 'name';
  String _activeConnectionId = '';
  Set<String> _favorites = {};
  String _filterCategory = 'all';
  String _defaultPort = '22';
  bool _showPassword = false;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  bool _isSecureStorageAvailable = true;
  
  @override
  void initState() {
    super.initState();
    _checkSecureStorage();
    _loadConnections();
    _loadFavorites();
    _loadDefaultPort();
    connectionStatus = widget.connectionStatus;
    isConnected = widget.connectionStatus.startsWith('Connected');
    
    if (isConnected && connections.isNotEmpty) {
      _updateActiveConnectionFromStatus();
    }
  }
  
  @override
  void didUpdateWidget(Connection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.connectionStatus != oldWidget.connectionStatus) {
      setState(() {
        connectionStatus = widget.connectionStatus;
        isConnected = connectionStatus.startsWith('Connected');
        
        if (isConnected) {
          _updateActiveConnectionFromStatus();
        } else {
          _activeConnectionId = '';
        }
      });
    } else if (isConnected && _activeConnectionId.isEmpty && connections.isNotEmpty) {
      setState(() {
        _updateActiveConnectionFromStatus();
      });
    }
  }

  void _updateActiveConnectionFromStatus() {
    print("Updating active connection from status: '$connectionStatus'");
    
    if (connectionStatus.isNotEmpty && connectionStatus.startsWith('Connected')) {
      String? activeName;
      String? activeHost;
      
      if (connectionStatus.contains('Connected to ') && connectionStatus.contains('(') && connectionStatus.contains(')')) {
        try {
          final nameStart = connectionStatus.indexOf('Connected to ') + 'Connected to '.length;
          final nameEnd = connectionStatus.lastIndexOf(', (');
          
          final hostStart = connectionStatus.indexOf('(') + 1;
          final hostEnd = connectionStatus.indexOf(')');
          
          if (nameStart < nameEnd && hostStart < hostEnd) {
            activeName = connectionStatus.substring(nameStart, nameEnd).trim();
            activeHost = connectionStatus.substring(hostStart, hostEnd).trim();
            print("Extracted name: '$activeName', host: '$activeHost'");
          }
        } catch (e) {
          print("Error parsing connection status: $e");
        }
      }
      
      if (activeName == null && activeHost == null && connectionStatus.contains('(') && connectionStatus.contains(')')) {
        try {
          final hostStart = connectionStatus.indexOf('(') + 1;
          final hostEnd = connectionStatus.indexOf(')');
          
          if (hostStart < hostEnd) {
            activeHost = connectionStatus.substring(hostStart, hostEnd).trim();
            print("Fallback: extracted host only: '$activeHost'");
          }
        } catch (e) {
          print("Error in fallback parsing: $e");
        }
      }
      
      _activeConnectionId = '';
      
      if (activeName != null && activeHost != null) {
        for (var connection in connections) {
          if (connection['name'] == activeName && connection['host'] == activeHost) {
            _activeConnectionId = connection['id'];
            print("Found exact match (name and host): ID ${connection['id']}");
            return;
          }
        }
      }
      
      if (activeHost != null) {
        for (var connection in connections) {
          if (connection['host'] == activeHost) {
            _activeConnectionId = connection['id'];
            print("Found host-only match: ID ${connection['id']}");
            return;
          }
        }
        
        for (var connection in connections) {
          if (connection['host'].toString().toLowerCase().trim() == activeHost.toLowerCase().trim()) {
            _activeConnectionId = connection['id'];
            print("Found case-insensitive host match: ID ${connection['id']}");
            return;
          }
        }
      }
      
      print("No matching connection found for status: '$connectionStatus'");
    } else {
      _activeConnectionId = '';
      print("Connection status doesn't indicate an active connection");
    }
  }

  Future<void> _checkSecureStorage() async {
    try {
      await _secureStorage.write(key: 'test_key', value: 'test_value');
      await _secureStorage.read(key: 'test_key');
      await _secureStorage.delete(key: 'test_key');
      _isSecureStorageAvailable = true;
    } catch (e) {
      print('Secure storage not available: $e');
      _isSecureStorageAvailable = false;
      if (mounted) {
        Future.delayed(const Duration(seconds: 1), () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Secure storage is not available. Passwords will not be encrypted.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 5),
            ),
          );
        });
      }
    }
  }

  void _loadConnections() async {
    final prefs = await SharedPreferences.getInstance();
    final connectionsString = prefs.getString('connections') ?? '[]';
    
    List<Map<String, dynamic>> loadedConnections = List<Map<String, dynamic>>.from(
      (jsonDecode(connectionsString) as List).map(
        (connection) => 
          Map<String, dynamic>.from({
            ...Map<String, String>.from(connection),
            'lastConnected': connection['lastConnected'] ?? '',
            'category': connection['category'] ?? 'Default',
            'id': connection['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
          }),
      ),
    );
    
    if (_isSecureStorageAvailable) {
      for (var connection in loadedConnections) {
        try {
          final String? securePassword = await _secureStorage.read(key: 'password_${connection['id']}');
          if (securePassword != null) {
            connection['password'] = securePassword;
          } else if (connection['password'] == '') {
            final legacyPassword = prefs.getString('password_${connection["id"]}');
            if (legacyPassword != null && legacyPassword.isNotEmpty) {
              connection['password'] = legacyPassword;
              await _secureStorage.write(
                key: 'password_${connection["id"]}',
                value: legacyPassword
              );
              await prefs.remove('password_${connection["id"]}');
            }
          }
        } catch (e) {
          print('Failed to load password from secure storage: $e');
        }
      }
    }
    
    setState(() {
      connections = loadedConnections;
    });
  }

  void _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favorites = Set<String>.from(prefs.getStringList('favorites') ?? []);
    });
  }

  void _loadDefaultPort() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _defaultPort = prefs.getString('defaultPort') ?? '22';
    });
  }

  void _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('favorites', _favorites.toList());
  }

  void _saveConnections() async {
    final prefs = await SharedPreferences.getInstance();
    
    final List<Map<String, dynamic>> connectionsCopy;
    
    if (_isSecureStorageAvailable) {
      connectionsCopy = connections.map((conn) {
        final Map<String, dynamic> copy = Map<String, dynamic>.from(conn);
        copy['password'] = ''; 
        return copy;
      }).toList();
    } else {
      connectionsCopy = List<Map<String, dynamic>>.from(connections);
    }
    
    prefs.setString(
      'connections',
      jsonEncode(connectionsCopy),
    );
    
    if (_isSecureStorageAvailable) {
      for (var connection in connections) {
        if (connection['password'] != null && connection['password'].isNotEmpty) {
          try {
            await _secureStorage.write(
              key: 'password_${connection["id"]}',
              value: connection['password']
            );
          } catch (e) {
            print('Failed to write password to secure storage: $e');
            
            await prefs.setString('password_${connection["id"]}', connection['password']);
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to securely store password. Using less secure storage method.'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          }
        }
      }
    }
  }

  void _addConnection(Map<String, dynamic> connection) {
    if (!connection.containsKey('id')) {
      connection['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    }
    
    setState(() {
      connections.add(connection);
    });
    _saveConnections();
  }

  void _removeConnection(int index) async {
    final connection = connections[index];
    if (_favorites.contains(connection['id'])) {
      _favorites.remove(connection['id']);
      _saveFavorites();
    }
    
    if (_isSecureStorageAvailable) {
      try {
        await _secureStorage.delete(key: 'password_${connection["id"]}');
      } catch (e) {
        print('Failed to delete from secure storage: $e');
      }
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('password_${connection["id"]}');
    
    setState(() {
      connections.removeAt(index);
    });
    _saveConnections();
  }

  void _updateConnection(int index, Map<String, dynamic> connection) {
    setState(() {
      connections[index] = connection;
    });
    _saveConnections();
  }

  void _toggleFavorite(String id) {
    setState(() {
      if (_favorites.contains(id)) {
        _favorites.remove(id);
      } else {
        _favorites.add(id);
      }
    });
    _saveFavorites();
  }

  void _connectToSavedConnection(Map<String, dynamic> connection) async {
    if (isConnected) {
      _showDisconnectDialog(connection);
      return;
    }

    setState(() {
      connectionStatus = 'Connecting...';
    });
    try {
      sshService = SSHService(
        name: connection['name']!,
        host: connection['host']!,
        port: int.parse(connection['port']!),
        username: connection['username']!,
        password: connection['password']!,
      );
      await sshService!.connect();
      widget.setSSHService(sshService!);
      
      final now = DateTime.now();
      final index = connections.indexWhere((c) => c['id'] == connection['id']);
      if (index != -1) {
        connections[index]['lastConnected'] = now.toIso8601String();
        _saveConnections();
      }
      
      final specificConnectionId = connection['id'];
      
      setState(() {
        isConnected = true;
        _activeConnectionId = '';
        _activeConnectionId = specificConnectionId;
        
        connectionStatus = 'Connected to ${connection['name']}, (${connection['host']})';
      });
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            if (_activeConnectionId != specificConnectionId) {
              print("Correcting active connection ID: $_activeConnectionId -> $specificConnectionId");
              _activeConnectionId = specificConnectionId;
            }
          });
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connected to ${connection['name']}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      setState(() {
        connectionStatus = 'Error: $e';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection failed: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
  
  void _disconnect() {
    try {
      if (sshService != null) {
        print("Disconnecting SSH service");
        sshService!.disconnect();
      }
      
      widget.setSSHService(null);
      
      setState(() {
        isConnected = false;
        _activeConnectionId = '';
        connectionStatus = 'Disconnected';
        sshService = null;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Disconnected successfully'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error during disconnect: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error disconnecting: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
  
  void _showDisconnectDialog(Map<String, dynamic> newConnection) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Active Connection'),
        content: Text('You\'re currently connected to a Raspberry Pi. Do you want to disconnect and connect to ${newConnection['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _disconnect();
              _connectToSavedConnection(newConnection);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: const Text('Disconnect & Connect'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(int index) {
    final connection = connections[index];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Connection'),
        content: Text('Are you sure you want to delete "${connection['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _removeConnection(index);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _duplicateConnection(Map<String, dynamic> connection) {
    final duplicate = Map<String, dynamic>.from(connection);
    duplicate['name'] = '${connection['name']} (Copy)';
    duplicate['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    _addConnection(duplicate);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Connection "${connection['name']}" duplicated'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _saveConnection() {
    final connection = {
      'name': _nameController.text,
      'host': _hostController.text,
      'port': _portController.text,
      'username': _usernameController.text,
      'password': _passwordController.text,
      'category': 'Default',
      'lastConnected': '',
    };
    if (_editingIndex != null) {
      final existingConnection = connections[_editingIndex!];
      connection['id'] = existingConnection['id'];
      connection['category'] = existingConnection['category'];
      connection['lastConnected'] = existingConnection['lastConnected'];
      
      _updateConnection(_editingIndex!, connection);
      _editingIndex = null;
    } else {
      _addConnection(connection);
    }
    _clearFields();
  }

  void _clearFields() {
    _nameController.clear();
    _hostController.clear();
    _portController.clear();
    _usernameController.clear();
    _passwordController.clear();
  }

  void _showEditDialog({Map<String, dynamic>? connection, int? index}) {
    if (connection != null) {
      _nameController.text = connection['name']!;
      _hostController.text = connection['host']!;
      _portController.text = connection['port']!;
      _usernameController.text = connection['username']!;
      _passwordController.text = connection['password']!;
      _editingIndex = index;
      _showPassword = false;
    } else {
      _clearFields();
      _portController.text = _defaultPort; 
      _editingIndex = null;
      _showPassword = false;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _editingIndex == null ? Icons.add_circle : Icons.edit,
                          color: Theme.of(context).colorScheme.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _editingIndex == null ? 'Add SSH Connection' : 'Edit SSH Connection',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Connection Details',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'Connection Name',
                                hintText: 'My Raspberry Pi',
                                prefixIcon: const Icon(Icons.bookmark),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            const Text(
                              'SSH Server',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 10),
                            
                            TextField(
                              controller: _hostController,
                              decoration: InputDecoration(
                                labelText: 'Host/IP Address',
                                hintText: '192.168.1.100',
                                prefixIcon: const Icon(Icons.computer),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            TextField(
                              controller: _portController,
                              decoration: InputDecoration(
                                labelText: 'Port',
                                hintText: '22',
                                prefixIcon: const Icon(Icons.numbers),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                            
                            const SizedBox(height: 16),
                            
                            const Text(
                              'Authentication',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 10),
                            
                            TextField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                labelText: 'Username',
                                hintText: 'pi',
                                prefixIcon: const Icon(Icons.person),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            TextField(
                              controller: _passwordController,
                              obscureText: !_showPassword,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                hintText: '********',
                                prefixIcon: const Icon(Icons.lock),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _showPassword ? Icons.visibility_off : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _showPassword = !_showPassword;
                                    });
                                  },
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 20),
                            
                            if (_testConnectionStatus.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: _testConnectionStatus.startsWith('Error')
                                      ? Colors.red.withOpacity(0.1)
                                      : Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _testConnectionStatus.startsWith('Error')
                                          ? Icons.error
                                          : Icons.check_circle,
                                      color: _testConnectionStatus.startsWith('Error')
                                          ? Colors.red
                                          : Colors.green,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _testConnectionStatus,
                                        style: TextStyle(
                                          color: _testConnectionStatus.startsWith('Error')
                                              ? Colors.red
                                              : Colors.green,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        Row(
                          children: [
                            OutlinedButton.icon(
                              onPressed: () async {
                                await _testConnection(setState);
                              },
                              icon: const Icon(Icons.wifi_tethering),
                              label: const Text('Test'),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () {
                                _saveConnection();
                                Navigator.of(context).pop();
                              },
                              icon: const Icon(Icons.save),
                              label: const Text('Save'),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _testConnection(StateSetter setState) async {
    setState(() {
      _testConnectionStatus = 'Testing connection...';
    });
    try {
      final testSSHService = SSHService(
        name: _nameController.text,
        host: _hostController.text,
        port: int.parse(_portController.text),
        username: _usernameController.text,
        password: _passwordController.text,
      );
      await testSSHService.connect();
      setState(() {
        _testConnectionStatus = 'Connection successful!';
      });
      testSSHService.disconnect();
    } catch (e) {
      setState(() {
        _testConnectionStatus = 'Error: $e';
      });
    }
  }

  List<Map<String, dynamic>> _getFilteredConnections() {
    var filtered = List<Map<String, dynamic>>.from(connections);
    
    if (_filterCategory != 'all') {
      if (_filterCategory == 'favorites') {
        filtered = filtered.where((c) => _favorites.contains(c['id'])).toList();
      } else {
        filtered = filtered.where((c) => c['category'] == _filterCategory).toList();
      }
    }
    
    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      filtered = filtered.where((c) => 
        c['name'].toLowerCase().contains(searchTerm) ||
        c['host'].toLowerCase().contains(searchTerm)
      ).toList();
    }
    
    filtered.sort((a, b) {
      switch (_currentSort) {
        case 'name':
          return a['name'].toLowerCase().compareTo(b['name'].toLowerCase());
        case 'recent':
          final aDate = a['lastConnected'] == '' 
              ? DateTime(1970) 
              : DateTime.parse(a['lastConnected']);
          final bDate = b['lastConnected'] == '' 
              ? DateTime(1970) 
              : DateTime.parse(b['lastConnected']);
          return bDate.compareTo(aDate);
        case 'host':
          return a['host'].toLowerCase().compareTo(b['host'].toLowerCase());
        default:
          return 0;
      }
    });
    
    return filtered;
  }

  List<String> _getCategories() {
    final categories = connections.map((c) => c['category'] as String)
                                  .where((category) => category != 'Default')  
                                  .toSet()
                                  .toList();
    categories.sort();
    return categories;
  }

  String _formatLastConnected(String timestamp) {
    if (timestamp.isEmpty) {
      return 'Never';
    }
    
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays > 7) {
        return DateFormat('MMM d, yyyy').format(date);
      } else if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isConnected && connections.isNotEmpty) {
      bool hasMultipleActive = false;
      String foundActiveId = '';
      
      for (var connection in connections) {
        if (_activeConnectionId == connection['id']) {
          if (foundActiveId.isEmpty) {
            foundActiveId = connection['id'];
          } else {
            hasMultipleActive = true;
            break;
          }
        }
      }
      
      if (hasMultipleActive) {
        print("Error: Multiple active connections detected - fixing...");
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _activeConnectionId = foundActiveId.isNotEmpty ? foundActiveId : '';
              _updateActiveConnectionFromStatus();
            });
          }
        });
      } else if (_activeConnectionId.isEmpty) {
        print("Connected but no active connection ID set - attempting to update from status");
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            _updateActiveConnectionFromStatus();
          });
        });
      }
    }
    
    final filteredConnections = _getFilteredConnections();
    final categories = _getCategories();
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search connections...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                              });
                            },
                          )
                        : null,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              FilterChip(
                                label: const Text('All'),
                                selected: _filterCategory == 'all',
                                onSelected: (_) => setState(() => _filterCategory = 'all'),
                                backgroundColor: colorScheme.surfaceVariant,
                                selectedColor: colorScheme.primaryContainer,
                              ),
                              const SizedBox(width: 8),
                              FilterChip(
                                label: const Text('⭐ Favorites'),
                                selected: _filterCategory == 'favorites',
                                onSelected: (_) => setState(() => _filterCategory = 'favorites'),
                                backgroundColor: colorScheme.surfaceVariant,
                                selectedColor: colorScheme.brightness == Brightness.dark
                                    ? Colors.amber.shade900.withOpacity(0.4)
                                    : Colors.amber.shade100,
                              ),
                              for (final category in categories) ...[
                                const SizedBox(width: 8),
                                FilterChip(
                                  label: Text(category),
                                  selected: _filterCategory == category,
                                  onSelected: (_) => setState(() => _filterCategory = category),
                                  backgroundColor: colorScheme.surfaceVariant,
                                  selectedColor: colorScheme.primaryContainer,
                                ),
                              ]
                            ],
                          ),
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.sort),
                        tooltip: 'Sort',
                        onSelected: (value) {
                          setState(() {
                            _currentSort = value;
                          });
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'name',
                            child: Text('Sort by name'),
                          ),
                          const PopupMenuItem(
                            value: 'host',
                            child: Text('Sort by host'),
                          ),
                          const PopupMenuItem(
                            value: 'recent',
                            child: Text('Sort by recent'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: filteredConnections.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredConnections.length,
                      itemBuilder: (context, index) {
                        final connection = filteredConnections[index];
                        final bool isFavorite = _favorites.contains(connection['id']);
                        final bool isActive = _activeConnectionId == connection['id'];
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: AppDimensions.spaceMD),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: Theme.of(context).brightness == Brightness.dark
                                  ? [
                                      Colors.white.withOpacity(0.1),
                                      Colors.white.withOpacity(0.05),
                                    ]
                                  : [
                                      Colors.white.withOpacity(0.9),
                                      Colors.white.withOpacity(0.6),
                                    ],
                            ),
                            border: Border.all(
                              color: isActive
                                  ? AppColors.accentBlue
                                  : Colors.white.withOpacity(0.2),
                              width: isActive ? 2.0 : 1.5,
                            ),
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color: AppColors.accentBlue.withOpacity(0.4),
                                      blurRadius: 20,
                                      spreadRadius: 0,
                                      offset: const Offset(0, 0),
                                    ),
                                  ]
                                : [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                contentPadding: const EdgeInsets.fromLTRB(16, 8, 4, 4),
                                title: Row(
                                  children: [
                                    Text(
                                      connection['name']!,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (isActive)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              AppColors.accentBlue.withOpacity(0.3),
                                              AppColors.accentBlue.withOpacity(0.2),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                                          border: Border.all(
                                            color: AppColors.accentBlue,
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.circle, color: AppColors.accentBlue, size: 8),
                                            const SizedBox(width: 4),
                                            Text(
                                              'ACTIVE',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: AppColors.accentBlue,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.computer, size: 14, color: Colors.grey),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${connection['host']}:${connection['port']}',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                                        const SizedBox(width: 6),
                                        Text(
                                          connection['username']!,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time, size: 14, color: Colors.grey),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Last used: ${_formatLastConnected(connection['lastConnected'] ?? '')}',
                                          style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                leading: IconButton(
                                  icon: Icon(
                                    isFavorite ? Icons.star : Icons.star_border,
                                    color: isFavorite ? AppColors.warning : Colors.grey,
                                  ),
                                  tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
                                  onPressed: () => _toggleFavorite(connection['id']),
                                ),
                                trailing: PopupMenuButton(
                                  icon: const Icon(Icons.more_vert),
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: ListTile(
                                        leading: Icon(Icons.edit),
                                        title: Text('Edit'),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'duplicate',
                                      child: ListTile(
                                        leading: Icon(Icons.copy),
                                        title: Text('Duplicate'),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: ListTile(
                                        leading: Icon(Icons.delete, color: Colors.red),
                                        title: Text('Delete', style: TextStyle(color: Colors.red)),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ],
                                  onSelected: (value) {
                                    final originalIndex = connections.indexWhere((c) => c['id'] == connection['id']);
                                    if (originalIndex == -1) return;
                                    
                                    switch (value) {
                                      case 'edit':
                                        _showEditDialog(connection: connection, index: originalIndex);
                                        break;
                                      case 'duplicate':
                                        _duplicateConnection(connection);
                                        break;
                                      case 'delete':
                                        _confirmDelete(originalIndex);
                                        break;
                                    }
                                  },
                                ),
                              ),
                              
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (isActive)
                                      OutlinedButton.icon(
                                        onPressed: _disconnect,
                                        icon: const Icon(Icons.power_settings_new, size: 16),
                                        label: const Text('Disconnect'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppColors.error,
                                          side: BorderSide(color: AppColors.error),
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                                          ),
                                        ),
                                      )
                                    else if (isConnected)
                                      OutlinedButton.icon(
                                        onPressed: () => _showDisconnectDialog(connection),
                                        icon: const Icon(Icons.swap_horiz, size: 16),
                                        label: const Text('Switch to this'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Theme.of(context).colorScheme.primary,
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                        ),
                                      )
                                    else
                                      ElevatedButton.icon(
                                        onPressed: () => _connectToSavedConnection(connection),
                                        icon: const Icon(Icons.login, size: 16),
                                        label: const Text('Connect'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Theme.of(context).colorScheme.primary,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: AppDimensions.bottomNavHeight + AppDimensions.bottomNavMargin),
        child: FloatingActionButton(
          onPressed: () => _showEditDialog(),
          tooltip: 'Add Connection',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.computer,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isNotEmpty
                ? 'No matching connections found'
                : 'No connections yet',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isNotEmpty
                ? 'Try a different search term'
                : 'Add a connection to get started',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              if (_searchController.text.isNotEmpty) {
                setState(() {
                  _searchController.clear();
                });
              } else {
                _showEditDialog();
              }
            },
            icon: Icon(
              _searchController.text.isNotEmpty ? Icons.clear : Icons.add,
            ),
            label: Text(
              _searchController.text.isNotEmpty
                  ? 'Clear Search'
                  : 'Add Connection',
            ),
          ),
        ],
      ),
    );
  }
}
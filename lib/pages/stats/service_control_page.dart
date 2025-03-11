import 'package:flutter/material.dart';

class ServiceControlPage extends StatefulWidget {
  final List<Map<String, dynamic>>? initialServices;
  final Function(String)? onStartService;
  final Function(String)? onStopService;
  final Function(String)? onRestartService;
  final Future<String> Function(String)? getServiceLogs;

  const ServiceControlPage({
    Key? key,
    this.initialServices,
    this.onStartService,
    this.onStopService,
    this.onRestartService,
    this.getServiceLogs,
  }) : super(key: key);

  @override
  _ServiceControlPageState createState() => _ServiceControlPageState();
}

class _ServiceControlPageState extends State<ServiceControlPage> {
  List<Map<String, dynamic>> services = [];
  List<Map<String, dynamic>> filteredServices = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;
  String _filterStatus = 'all';
  String _sortOption = 'name';

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  void _initializeServices() {
    if (widget.initialServices != null) {
      services = widget.initialServices!.map((item) {
        if (item is Map<String, String>) {
          return Map<String, dynamic>.from(item);
        }
        return item;
      }).toList();
      
      _applyFilter();
      setState(() {
        isLoading = false;
      });
    }
  }

  void _applyFilter() {
    final searchQuery = searchController.text.toLowerCase();
    
    try {
      filteredServices = List.from(services);
      
      if (_filterStatus != 'all') {
        filteredServices = filteredServices.where((service) {
          final status = (service['status'] ?? '').toLowerCase();
          return status == _filterStatus;
        }).toList();
      }
      
      if (searchQuery.isNotEmpty) {
        filteredServices = filteredServices.where((service) {
          final name = (service['name'] ?? '').toLowerCase();
          final description = (service['description'] ?? '').toLowerCase();
          return name.contains(searchQuery) || description.contains(searchQuery);
        }).toList();
      }
      
      _sortServices();
    } catch (e) {
      debugPrint('Error during filtering: $e');
      filteredServices = List.from(services);
    }
  }

  void _sortServices() {
    switch (_sortOption) {
      case 'name':
        filteredServices.sort((a, b) => 
          (a['name']?.toString() ?? '').toLowerCase().compareTo((b['name']?.toString() ?? '').toLowerCase()));
        break;
      case 'status':
        filteredServices.sort((a, b) {
          final statusOrder = {'running': 0, 'active': 0, 'stopped': 1, 'inactive': 1, 'dead': 2};
          final statusA = statusOrder[(a['status']?.toString() ?? '').toLowerCase()] ?? 3;
          final statusB = statusOrder[(b['status']?.toString() ?? '').toLowerCase()] ?? 3;
          return statusA.compareTo(statusB);
        });
        break;
    }
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    
    switch (status.toLowerCase()) {
      case 'running':
      case 'active':
        return Colors.green;
      case 'stopped':
      case 'inactive':
        return Colors.orange;
      case 'dead':
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showServiceLogs(String serviceName) async {
    if (widget.getServiceLogs == null) return;
    
    final logs = await widget.getServiceLogs!(serviceName);
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) {
        final brightness = MediaQuery.platformBrightnessOf(context);
        final isDarkMode = brightness == Brightness.dark || Theme.of(context).brightness == Brightness.dark;
        
        return AlertDialog(
          title: Text('Logs: $serviceName'),
          content: Container(
            width: double.maxFinite,
            height: 400,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: SelectableText(
                  logs,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontFamily: 'Courier',
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildServiceControls(Map<String, dynamic> service) {
    final status = (service['status'] ?? '').toLowerCase();
    final isRunning = status == 'running' || status == 'active';
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isRunning && widget.onStartService != null)
          OutlinedButton.icon(
            onPressed: () {
              widget.onStartService!(service['name']);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Starting ${service['name']}...'))
              );
            },
            icon: const Icon(Icons.play_arrow, size: 16),
            label: const Text('Start'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              visualDensity: VisualDensity.compact,
            ),
          ),

        if (isRunning && widget.onStopService != null)
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: OutlinedButton.icon(
              onPressed: () {
                widget.onStopService!(service['name']);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Stopping ${service['name']}...'))
                );
              },
              icon: const Icon(Icons.stop, size: 16),
              label: const Text('Stop'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),

        if (widget.onRestartService != null)
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: OutlinedButton.icon(
              onPressed: isRunning ? () {
                widget.onRestartService!(service['name']);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Restarting ${service['name']}...'))
                );
              } : null,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Restart'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final bool isSearching = searchController.text.isNotEmpty;
    
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.miscellaneous_services,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            isSearching ? 'No matching services found' : 'No services available',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSearching ? 'Try different search terms or filters' : 'Try refreshing the services list',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                if (isSearching) {
                  searchController.clear();
                  _filterStatus = 'all';
                }
                _applyFilter();
              });
            },
            icon: Icon(
              isSearching ? Icons.clear : Icons.refresh,
            ),
            label: Text(
              isSearching ? 'Clear Filters' : 'Refresh',
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Control'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: const Text('Sort by Name'),
                      leading: Radio<String>(
                        value: 'name',
                        groupValue: _sortOption,
                        onChanged: (value) {
                          Navigator.pop(context);
                          setState(() {
                            _sortOption = value!;
                            _sortServices();
                          });
                        },
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          _sortOption = 'name';
                          _sortServices();
                        });
                      },
                    ),
                    ListTile(
                      title: const Text('Sort by Status'),
                      leading: Radio<String>(
                        value: 'status',
                        groupValue: _sortOption,
                        onChanged: (value) {
                          Navigator.pop(context);
                          setState(() {
                            _sortOption = value!;
                            _sortServices();
                          });
                        },
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          _sortOption = 'status';
                          _sortServices();
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              Future.delayed(const Duration(milliseconds: 500), () {
                setState(() {
                  _applyFilter();
                  isLoading = false;
                });
              });
            },
          ),
        ],
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search services...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              searchController.clear();
                              _applyFilter();
                            });
                          },
                        )
                      : null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _applyFilter();
                    });
                  },
                ),
              ),
              
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: _filterStatus == 'all',
                      onSelected: (_) => setState(() {
                        _filterStatus = 'all';
                        _applyFilter();
                      }),
                      backgroundColor: colorScheme.surfaceVariant,
                      selectedColor: colorScheme.primaryContainer,
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Running'),
                      selected: _filterStatus == 'running',
                      onSelected: (_) => setState(() {
                        _filterStatus = 'running';
                        _applyFilter();
                      }),
                      backgroundColor: colorScheme.surfaceVariant,
                      selectedColor: Colors.green.withOpacity(0.2),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Exited'),
                      selected: _filterStatus == 'exited',
                      onSelected: (_) => setState(() {
                        _filterStatus = 'exited';
                        _applyFilter();
                      }),
                      backgroundColor: colorScheme.surfaceVariant,
                      selectedColor: Colors.orange.withOpacity(0.2),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Dead'),
                      selected: _filterStatus == 'dead',
                      onSelected: (_) => setState(() {
                        _filterStatus = 'dead';
                        _applyFilter();
                      }),
                      backgroundColor: colorScheme.surfaceVariant,
                      selectedColor: Colors.red.withOpacity(0.2),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 8),
              
              Expanded(
                child: filteredServices.isEmpty 
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredServices.length,
                      itemBuilder: (context, index) {
                        final service = filteredServices[index];
                        final status = (service['status'] ?? '').toLowerCase();
                        final statusColor = _getStatusColor(status);
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () => _showServiceLogs(service['name']),
                            child: Column(
                              children: [
                                ListTile(
                                  contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          service['name'] ?? '',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.circle, color: statusColor, size: 8),
                                            const SizedBox(width: 4),
                                            Text(
                                              status.toUpperCase(), 
                                              style: TextStyle(fontSize: 10, color: statusColor)
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
                                      if (service['description'] != null && service['description'].toString().isNotEmpty)
                                        Text(
                                          service['description'] ?? '',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      if (service['load'] != null)
                                        Row(
                                          children: [
                                            const Icon(Icons.timer_outlined, size: 14, color: Colors.grey),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Load: ${service['load']}',
                                              style: const TextStyle(fontSize: 14),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
                                ),
                                
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      _buildServiceControls(service),
                                    ],
                                  ),
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
    );
  }
}

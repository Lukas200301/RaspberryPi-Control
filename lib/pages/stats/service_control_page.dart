import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';

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
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator(color: AppColors.accentIndigo)),
    );

    final logs = await widget.getServiceLogs!(serviceName);
    
    if (!mounted) return;
    Navigator.pop(context);
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(maxHeight: 600, maxWidth: 500),
          decoration: BoxDecoration(
            gradient: AppColors.glassGradientDark,
            borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
            border: Border.all(color: AppColors.accentIndigo.withOpacity(0.3), width: 1.5),
            boxShadow: [AppColors.indigoGlow()],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(AppDimensions.spaceLG),
                child: Row(
                  children: [
                    Icon(Icons.article, color: AppColors.accentIndigo),
                    SizedBox(width: AppDimensions.spaceSM),
                    Expanded(
                      child: Text(
                        'Logs: $serviceName',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Divider(color: Colors.white12, height: 1),
              Flexible(
                child: Container(
                  margin: EdgeInsets.all(AppDimensions.spaceMD),
                  padding: EdgeInsets.all(AppDimensions.spaceMD),
                  decoration: BoxDecoration(
                    color: Color(0xFF0A0A0A),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                    border: Border.all(color: AppColors.accentIndigo.withOpacity(0.3), width: 1.5),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      logs,
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Courier',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
                SnackBar(
                  content: Text('Starting ${service['name']}...'),
                  backgroundColor: AppColors.success,
                )
              );
            },
            icon: const Icon(Icons.play_arrow, size: 16),
            label: const Text('Start'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.success,
              side: BorderSide(color: AppColors.success.withOpacity(0.5), width: 1.5),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),

        if (isRunning && widget.onStopService != null)
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: OutlinedButton.icon(
              onPressed: () {
                widget.onStopService!(service['name']);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Stopping ${service['name']}...'),
                    backgroundColor: AppColors.error,
                  )
                );
              },
              icon: const Icon(Icons.stop, size: 16),
              label: const Text('Stop'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(color: AppColors.error.withOpacity(0.5), width: 1.5),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                  SnackBar(
                    content: Text('Restarting ${service['name']}...'),
                    backgroundColor: AppColors.accentTeal,
                  )
                );
              } : null,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Restart'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accentTeal,
                side: BorderSide(color: AppColors.accentTeal.withOpacity(0.5), width: 1.5),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.accentIndigo.withOpacity(0.2),
                  AppColors.accentTeal.withOpacity(0.2),
                ],
              ),
              boxShadow: [AppColors.indigoGlow(opacity: 0.3)],
            ),
            child: Icon(
              Icons.miscellaneous_services,
              size: 64,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isSearching ? 'No matching services found' : 'No services available',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSearching ? 'Try different search terms or filters' : 'Try refreshing the services list',
            style: TextStyle(
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
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
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accentIndigo,
              side: BorderSide(color: AppColors.accentIndigo.withOpacity(0.5), width: 1.5),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkGradientStart,
      appBar: AppBar(
        title: Row(
          children: [
            Text('Service Control', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            SizedBox(width: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accentIndigo.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accentIndigo.withOpacity(0.5)),
              ),
              child: Text(
                '${filteredServices.length}',
                style: TextStyle(color: AppColors.accentIndigo, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
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
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.glassGradientDark,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                    border: Border.all(color: AppColors.glassBorderDark(), width: 1.5),
                  ),
                  child: TextField(
                    controller: searchController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search services...',
                      hintStyle: TextStyle(color: Colors.white54),
                      prefixIcon: const Icon(Icons.search, color: Colors.white70),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white70),
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
              ),
              
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildFilterChip('All', 'all', AppColors.accentIndigo),
                    const SizedBox(width: 8),
                    _buildFilterChip('Running', 'running', AppColors.success),
                    const SizedBox(width: 8),
                    _buildFilterChip('Exited', 'exited', AppColors.warning),
                    const SizedBox(width: 8),
                    _buildFilterChip('Dead', 'dead', AppColors.error),
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
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            gradient: AppColors.glassGradientDark,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                            border: Border.all(color: statusColor.withOpacity(0.3), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: statusColor.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _showServiceLogs(service['name']),
                              borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                              splashColor: statusColor.withOpacity(0.1),
                              highlightColor: statusColor.withOpacity(0.05),
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
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: statusColor.withOpacity(0.5)),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: statusColor,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: statusColor.withOpacity(0.5),
                                                    blurRadius: 8,
                                                    spreadRadius: 2,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              status.toUpperCase(), 
                                              style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.bold)
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
                                          style: const TextStyle(fontSize: 14, color: Colors.white70),
                                        ),
                                      if (service['load'] != null)
                                        Row(
                                          children: [
                                            const Icon(Icons.timer_outlined, size: 14, color: Colors.white54),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Load: ${service['load']}',
                                              style: const TextStyle(fontSize: 14, color: Colors.white54),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                  trailing: const Icon(Icons.chevron_right, color: Colors.white54),
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
                        ),
                        );
                      },
                    ),
              ),
            ],
          ),
    );
  }

  Widget _buildFilterChip(String label, String value, Color color) {
    final isSelected = _filterStatus == value;
    return InkWell(
      onTap: () => setState(() {
        _filterStatus = value;
        _applyFilter();
      }),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.glassGradientDark : null,
          color: isSelected ? null : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color.withOpacity(0.5) : Colors.white.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? color : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

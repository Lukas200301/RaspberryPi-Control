import 'package:flutter/material.dart';

class ServiceControlWidget extends StatefulWidget {
  final List<Map<String, String>> services;
  final List<Map<String, String>> filteredServices;
  final bool showSearchBar;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final VoidCallback onSearchToggle;
  final VoidCallback onRefresh;
  final VoidCallback onFilterChange;
  final Future<void> Function(String) onStartService;
  final Future<void> Function(String) onStopService;
  final Future<void> Function(String) onRestartService;
  final Future<String> Function(String)? getServiceLogs;

  const ServiceControlWidget({
    Key? key,
    required this.services,
    required this.filteredServices,
    required this.showSearchBar,
    required this.searchController,
    required this.searchFocusNode,
    required this.onSearchToggle,
    required this.onRefresh,
    required this.onFilterChange,
    required this.onStartService,
    required this.onStopService,
    required this.onRestartService,
    this.getServiceLogs,
  }) : super(key: key);

  @override
  State<ServiceControlWidget> createState() => _ServiceControlWidgetState();
}

class _ServiceControlWidgetState extends State<ServiceControlWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Service Control',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.search),
                      tooltip: 'Search Services',
                      onPressed: widget.onSearchToggle,
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Refresh Services',
                      onPressed: widget.onRefresh,
                    ),
                  ],
                ),
              ],
            ),
            if (widget.showSearchBar) ...[
              const SizedBox(height: 16),
              TextField(
                controller: widget.searchController,
                focusNode: widget.searchFocusNode,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Search services...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) => widget.onFilterChange(),
              ),
            ],
            const SizedBox(height: 16),
            Container(
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.filteredServices.length,
                itemBuilder: (context, index) {
                  final service = widget.filteredServices[index];
                  final serviceName = service['name'] ?? '';
                  final status = service['status'] ?? '';
                  final description = service['description'] ?? '';
                  
                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade300,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: ListTile(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => _buildServiceDetailsDialog(
                            context, serviceName, status, description
                          ),
                        );
                      },
                      title: Text(
                        serviceName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(
                              description,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          Text(
                            status,
                            style: TextStyle(
                              fontSize: 12,
                              color: _getStatusColor(status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.play_arrow,
                              size: 16,
                            ),
                            tooltip: 'Start Service',
                            onPressed: () {
                              _handleServiceAction(context, serviceName, 'Started', () {
                                return widget.onStartService(serviceName);
                              });
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 24,
                              minHeight: 24,
                            ),
                            color: Colors.green,
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.stop,
                              size: 16,
                            ),
                            tooltip: 'Stop Service',
                            onPressed: () {
                              _handleServiceAction(context, serviceName, 'Stopped', () {
                                return widget.onStopService(serviceName);
                              });
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 24,
                              minHeight: 24,
                            ),
                            color: Colors.red,
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.refresh,
                              size: 16,
                            ),
                            tooltip: 'Restart Service',
                            onPressed: () {
                              _handleServiceAction(context, serviceName, 'Restarted', () {
                                return widget.onRestartService(serviceName);
                              });
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 24,
                              minHeight: 24,
                            ),
                            color: Colors.blue,
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

  void _handleServiceAction(
    BuildContext context, 
    String serviceName, 
    String actionText,
    Future<void> Function() action
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$actionText $serviceName'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
    action();
  }
  
  Widget _buildServiceDetailsDialog(
    BuildContext context, 
    String serviceName, 
    String status, 
    String description
  ) {
    return StatefulBuilder(
      builder: (context, setState) {
        String currentStatus = status;
        
        void handleAction(String action, Future<void> Function() serviceAction) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$action $serviceName'),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
          
          serviceAction();
          

          setState(() {
            if (action == 'Started') {
              currentStatus = 'running';
            } else if (action == 'Stopped') {
              currentStatus = 'dead';
            } else if (action == 'Restarted') {
              currentStatus = 'running';
            }
          });
        }
        
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.7,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        serviceName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Description:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text(
                      'Status: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      currentStatus,
                      style: TextStyle(
                        fontSize: 14,
                        color: _getStatusColor(currentStatus),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Service Logs:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: FutureBuilder<String>(
                    future: widget.getServiceLogs != null 
                        ? widget.getServiceLogs!(serviceName) 
                        : Future.value('Log fetching not available'),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error loading logs: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No logs available'));
                      }
                      
                      final String formattedLog = _formatLogText(snapshot.data!);
                      
                      final isDarkMode = Theme.of(context).brightness == Brightness.dark;
                      
                      return Container(
                        decoration: BoxDecoration(
                          color: isDarkMode 
                              ? const Color(0xFF1E1E1E) 
                              : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDarkMode 
                                ? Colors.grey.shade800
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: SelectableText(
                              formattedLog,
                              style: TextStyle(
                                color: isDarkMode
                                    ? const Color(0xFFE0E0E0)
                                    : const Color(0xFF212121),
                                fontFamily: 'monospace',
                                fontSize: 11,  
                                height: 1.4, 
                                letterSpacing: -0.1, 
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final buttonWidth = (constraints.maxWidth - 16) / 3;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: buttonWidth,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: () => handleAction('Started', () => widget.onStartService(serviceName)),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.play_arrow, size: 16),
                                  SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      'Start',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: buttonWidth,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: () => handleAction('Stopped', () => widget.onStopService(serviceName)),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.stop, size: 16),
                                  SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      'Stop',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: buttonWidth,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: () => handleAction('Restarted', () => widget.onRestartService(serviceName)),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.refresh, size: 16),
                                  SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      'Restart',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
  
  Color _getStatusColor(String status) {
    if (status == 'running') {
      return Colors.green;
    } else if (status == 'dead') {
      return Colors.red;
    } else if (status == 'exited') {
      return Colors.orange;
    }
    return Colors.grey;
  } 
  
  String _formatLogText(String rawLog) {
    List<String> lines = rawLog.split('\n');
    
    List<String> processedLines = [];
    bool inErrorBlock = false;
    
    for (String line in lines) {
      String trimmedLine = line.trimRight();
      
      if (trimmedLine.isNotEmpty) {
        if (trimmedLine.contains('ERROR') || trimmedLine.contains('FATAL')) {
          inErrorBlock = true;
          processedLines.add('! ' + trimmedLine);
        } else if (trimmedLine.contains('WARNING')) {
          processedLines.add('> ' + trimmedLine);
          inErrorBlock = false;
        } else if (trimmedLine.contains('INFO')) {
          processedLines.add('• ' + trimmedLine);
          inErrorBlock = false;
        } else if (inErrorBlock) {
          processedLines.add('  ' + trimmedLine);
        } else {
          processedLines.add(trimmedLine);
        }
      }
    }
    
    return processedLines.join('\n');
  }
}

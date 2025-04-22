import 'package:flutter/material.dart';
import '../service_control_page.dart';
import '../../../controllers/stats_controller.dart';

class ServiceControlWidget extends StatelessWidget {
  final List<Map<String, dynamic>> services;
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
  final Future<String> Function(String) getServiceLogs;

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
    required this.getServiceLogs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> convertedServices = 
      StatsController.instance.services;
      
    final List<Map<String, dynamic>> runningServices = convertedServices
      .where((service) {
        final status = (service['status'] ?? '').toString().toLowerCase();
        return status == 'running' || status == 'active';
      }).toList();
    
    runningServices.sort((a, b) {
      return (a['name'] ?? '').toString().toLowerCase()
          .compareTo((b['name'] ?? '').toString().toLowerCase());
    });
    
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'System Services',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${runningServices.length} Running', 
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(height: 1),
          ),
          
          if (runningServices.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey.shade400, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'No running services found',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: onRefresh,
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Refresh Services'),
                    )
                  ],
                ),
              ),
            )
          else
            SizedBox(
              height: 220, 
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: runningServices.length, 
                itemBuilder: (context, index) {
                  final service = runningServices[index];
                  final status = (service['status'] ?? '').toLowerCase();
                  final Color statusColor = Colors.green;
                  
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    elevation: 0,
                    color: Theme.of(context).colorScheme.surface,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => _showServiceDetailSheet(context, service),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: ListTile(
                          dense: true,
                          visualDensity: const VisualDensity(vertical: -1),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  service['name'] ?? '',
                                  style: const TextStyle(fontWeight: FontWeight.w500),
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
                          subtitle: service['description'] != null && service['description'].toString().isNotEmpty
                            ? Text(
                                service['description']!, 
                                maxLines: 1, 
                                overflow: TextOverflow.ellipsis
                              )
                            : null,
                          trailing: const Icon(Icons.chevron_right),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          
          Container(
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: ${convertedServices.length} Services',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ServiceControlPage(
                          initialServices: convertedServices,
                          onStartService: onStartService,
                          onStopService: onStopService,
                          onRestartService: onRestartService,
                          getServiceLogs: getServiceLogs,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.view_list, size: 18),
                  label: const Text('View All Services'),
                  style: ElevatedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _showServiceDetailSheet(BuildContext context, Map<String, dynamic> service) {
    final status = (service['status'] ?? '').toLowerCase();
    final isRunning = status == 'running' || status == 'active';
    final Color statusColor = _getStatusColor(status);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      service['name'] ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, color: statusColor, size: 10),
                        const SizedBox(width: 4),
                        Text(
                          status.toUpperCase(), 
                          style: TextStyle(fontSize: 12, color: statusColor, fontWeight: FontWeight.bold)
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const Divider(),
            
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  if (service['description'] != null && service['description'].toString().isNotEmpty) ...[
                    const Text(
                      'Description',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(service['description'] ?? ''),
                    const SizedBox(height: 16),
                  ],
                  
                  if (service['load'] != null) ...[
                    const Text(
                      'Load',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(service['load'] ?? ''),
                    const SizedBox(height: 16),
                  ],

                  ElevatedButton.icon(
                    onPressed: () async {
                      final logs = await getServiceLogs(service['name']);
                      if (context.mounted) {
                        Navigator.pop(context); 
                        
                        showDialog(
                          context: context,
                          builder: (context) {
                            final brightness = MediaQuery.platformBrightnessOf(context);
                            final isDarkMode = brightness == Brightness.dark || 
                                              Theme.of(context).brightness == Brightness.dark;
                            

                            return AlertDialog(
                              title: Text('Logs: ${service['name']}'),
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
                    },
                    icon: const Icon(Icons.info),
                    label: const Text('Service Logs'),
                    style: ElevatedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  const Text(
                    'Service Controls',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (!isRunning)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              onStartService(service['name']);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Starting ${service['name']}...'))
                              );
                            },
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Start'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        
                      if (isRunning) ...[
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              onStopService(service['name']);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Stopping ${service['name']}...'))
                              );
                            },
                            icon: const Icon(Icons.stop),
                            label: const Text('Stop'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              onRestartService(service['name']);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Restarting ${service['name']}...'))
                              );
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Restart'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
}

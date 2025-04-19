import 'package:flutter/material.dart';

class SystemProcessesWidget extends StatefulWidget {
  final List<dynamic> processes;

  const SystemProcessesWidget({
    Key? key,
    required this.processes,
  }) : super(key: key);

  @override
  State<SystemProcessesWidget> createState() => _SystemProcessesWidgetState();
}

class _SystemProcessesWidgetState extends State<SystemProcessesWidget> {
  String _sortOption = 'cpu';
  List<dynamic> _sortedProcesses = [];
  
  @override
  void initState() {
    super.initState();
    _sortProcesses();
  }
  
  @override
  void didUpdateWidget(SystemProcessesWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.processes != oldWidget.processes) {
      _sortProcesses();
    }
  }
  
  void _sortProcesses() {
    _sortedProcesses = List.from(widget.processes)
      .where((process) => !process['command'].toString().contains('ps aux --sort'))
      .toList();
    
    switch (_sortOption) {
      case 'cpu':
        _sortedProcesses.sort((a, b) => (b['cpu'] as double).compareTo(a['cpu'] as double));
        break;
      case 'memory':
        _sortedProcesses.sort((a, b) => (b['memory'] as double).compareTo(a['memory'] as double));
        break;
      case 'name':
        _sortedProcesses.sort((a, b) => a['command'].toString().split(' ')[0]
            .compareTo(b['command'].toString().split(' ')[0]));
        break;
    }
  }
  
  void _navigateToAllProcesses() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllProcessesPage(
          processes: _sortedProcesses,
          initialSortOption: _sortOption,
        ),
      ),
    );
  }
  
  void _showProcessDetails(Map<String, dynamic> process) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      process['command'].toString(),
                      style: const TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
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
              _buildDetailRow('Process ID', process['pid'].toString()),
              _buildDetailRow('User', process['user'].toString()),
              _buildDetailRow('CPU Usage', '${process['cpu'].toStringAsFixed(1)}%'),
              _buildDetailRow('Memory Usage', '${process['memory'].toStringAsFixed(1)}%'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Command',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      process['command'].toString(),
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Functionality to terminate process ${process['pid']} not implemented')),
                  );
                },
                icon: const Icon(Icons.stop_circle_outlined),
                label: const Text('Terminate Process'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final visibleProcesses = _sortedProcesses.take(5).toList(); 
    
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'System Processes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.sort, size: 20),
                      tooltip: 'Sort by',
                      onSelected: (value) {
                        setState(() {
                          _sortOption = value;
                          _sortProcesses();
                        });
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'cpu',
                          child: Text('Sort by CPU Usage'),
                        ),
                        const PopupMenuItem(
                          value: 'memory',
                          child: Text('Sort by Memory Usage'),
                        ),
                        const PopupMenuItem(
                          value: 'name',
                          child: Text('Sort by Name'),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_sortedProcesses.length} Processes',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(height: 1),
          ),
          
          _sortedProcesses.isEmpty 
            ? const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'No process information available',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(top: 4.0), 
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: visibleProcesses.length,
                  itemBuilder: (context, index) {
                    final process = visibleProcesses[index];
                    final cpuUsage = process['cpu'] as double;
                    final memoryUsage = process['memory'] as double;
                    final command = process['command'] as String;
                    final pid = process['pid'] as String;
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      elevation: 0,
                      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: InkWell(
                        onTap: () => _showProcessDetails(process),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0), 
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6), 
                                decoration: BoxDecoration(
                                  color: _getProcessColor(cpuUsage).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.memory,
                                  color: _getProcessColor(cpuUsage),
                                  size: 18, 
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min, 
                                  children: [
                                    Text(
                                      command.split(' ')[0],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'PID: $pid',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  _buildUsageChip('CPU', cpuUsage, Colors.blue),
                                  const SizedBox(height: 4),
                                  _buildUsageChip('MEM', memoryUsage, Colors.orange),
                                ],
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.chevron_right, size: 18),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
        
          if (_sortedProcesses.length > 5)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: OutlinedButton(
                onPressed: _navigateToAllProcesses,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(40),
                ),
                child: const Text('Show All Processes'),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildUsageChip(String label, double value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '${value.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getProcessColor(double usage) {
    if (usage >= 80) {
      return Colors.red;
    } else if (usage >= 50) {
      return Colors.orange;
    } else if (usage >= 20) {
      return Colors.blue;
    } else {
      return Colors.green;
    }
  }
}

class AllProcessesPage extends StatefulWidget {
  final List<dynamic> processes;
  final String initialSortOption;

  const AllProcessesPage({
    Key? key,
    required this.processes,
    required this.initialSortOption,
  }) : super(key: key);

  @override
  State<AllProcessesPage> createState() => _AllProcessesPageState();
}

class _AllProcessesPageState extends State<AllProcessesPage> {
  late String _sortOption;
  late List<dynamic> _sortedProcesses;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _sortOption = widget.initialSortOption;
    _sortedProcesses = List.from(widget.processes);
    _sortProcesses();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _filterAndSortProcesses();
    });
  }

  void _sortProcesses() {
    switch (_sortOption) {
      case 'cpu':
        _sortedProcesses.sort((a, b) => (b['cpu'] as double).compareTo(a['cpu'] as double));
        break;
      case 'memory':
        _sortedProcesses.sort((a, b) => (b['memory'] as double).compareTo(a['memory'] as double));
        break;
      case 'name':
        _sortedProcesses.sort((a, b) => a['command'].toString().split(' ')[0]
            .compareTo(b['command'].toString().split(' ')[0]));
        break;
    }
  }

  void _filterAndSortProcesses() {
    if (_searchQuery.isEmpty) {
      _sortedProcesses = List.from(widget.processes);
    } else {
      _sortedProcesses = widget.processes.where((process) {
        final command = process['command'].toString().toLowerCase();
        final user = process['user'].toString().toLowerCase();
        final pid = process['pid'].toString();
        
        return command.contains(_searchQuery.toLowerCase()) ||
               user.contains(_searchQuery.toLowerCase()) ||
               pid.contains(_searchQuery);
      }).toList();
    }
    _sortProcesses();
  }

  void _showProcessDetails(Map<String, dynamic> process) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      process['command'].toString(),
                      style: const TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
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
              _buildDetailRow('Process ID', process['pid'].toString()),
              _buildDetailRow('User', process['user'].toString()),
              _buildDetailRow('CPU Usage', '${process['cpu'].toStringAsFixed(1)}%'),
              _buildDetailRow('Memory Usage', '${process['memory'].toStringAsFixed(1)}%'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Command',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      process['command'].toString(),
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Functionality to terminate process ${process['pid']} not implemented')),
                  );
                },
                icon: const Icon(Icons.stop_circle_outlined),
                label: const Text('Terminate Process'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Processes'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort by',
            onSelected: (value) {
              setState(() {
                _sortOption = value;
                _sortProcesses();
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'cpu',
                child: Text('Sort by CPU Usage'),
              ),
              const PopupMenuItem(
                value: 'memory',
                child: Text('Sort by Memory Usage'),
              ),
              const PopupMenuItem(
                value: 'name',
                child: Text('Sort by Name'),
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
                hintText: 'Search processes',
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
            child: _sortedProcesses.isEmpty
              ? const Center(
                  child: Text(
                    'No processes found',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: _sortedProcesses.length,
                  itemBuilder: (context, index) {
                    final process = _sortedProcesses[index];
                    final cpuUsage = process['cpu'] as double;
                    final memoryUsage = process['memory'] as double;
                    final command = process['command'] as String;
                    final pid = process['pid'] as String;
                    final user = process['user'] as String;
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getProcessColor(cpuUsage).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.memory,
                            color: _getProcessColor(cpuUsage),
                            size: 20,
                          ),
                        ),
                        title: Text(
                          command.split(' ')[0],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          'PID: $pid | User: $user',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildUsageChip('CPU', cpuUsage, Colors.blue),
                            const SizedBox(width: 8),
                            _buildUsageChip('MEM', memoryUsage, Colors.orange),
                          ],
                        ),
                        onTap: () => _showProcessDetails(process),
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildUsageChip(String label, double value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '${value.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getProcessColor(double usage) {
    if (usage >= 80) {
      return Colors.red;
    } else if (usage >= 50) {
      return Colors.orange;
    } else if (usage >= 20) {
      return Colors.blue;
    } else {
      return Colors.green;
    }
  }
}

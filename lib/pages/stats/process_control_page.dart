import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/services/ssh_service_controller.dart';

class ProcessControlPage extends StatefulWidget {
  const ProcessControlPage({Key? key}) : super(key: key);

  @override
  State<ProcessControlPage> createState() => _ProcessControlPageState();
}

class _ProcessControlPageState extends State<ProcessControlPage> {
  String _sortOption = 'cpu';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _processes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProcesses();
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
    });
  }

  Future<void> _loadProcesses() async {
    setState(() => _isLoading = true);
    try {
      final sshController = Get.find<SSHServiceController>();
      final stats = await sshController.service?.getDetailedStats();
      if (stats != null && mounted) {
        setState(() {
          _processes = stats['processes'] as List? ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<dynamic> get _filteredAndSortedProcesses {
    var filtered = _processes.where((process) {
      if (_searchQuery.isEmpty) return true;
      
      final command = process['command'].toString().toLowerCase();
      final user = process['user'].toString().toLowerCase();
      final pid = process['pid'].toString();
      
      return command.contains(_searchQuery.toLowerCase()) ||
             user.contains(_searchQuery.toLowerCase()) ||
             pid.contains(_searchQuery);
    }).toList();

    switch (_sortOption) {
      case 'cpu':
        filtered.sort((a, b) => (b['cpu'] as double).compareTo(a['cpu'] as double));
        break;
      case 'memory':
        filtered.sort((a, b) => (b['memory'] as double).compareTo(a['memory'] as double));
        break;
      case 'name':
        filtered.sort((a, b) => a['command'].toString().split(' ')[0]
            .compareTo(b['command'].toString().split(' ')[0]));
        break;
      case 'user':
        filtered.sort((a, b) => a['user'].toString().compareTo(b['user'].toString()));
        break;
    }
    
    return filtered;
  }

  Color _getProcessColor(double usage) {
    if (usage >= 80) return Colors.red;
    if (usage >= 50) return Colors.orange;
    if (usage >= 20) return AppColors.accentCyan;
    return Colors.green;
  }

  Future<void> _killProcess(String pid, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkGradientStart,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange),
            SizedBox(width: AppDimensions.spaceSM),
            Text('Kill Process?', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(
          'Are you sure you want to kill process "$name" (PID: $pid)?\n\nThis action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Kill Process'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final sshController = Get.find<SSHServiceController>();
      await sshController.service?.executeCommand('kill -9 $pid');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Process $pid killed successfully'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
        await _loadProcesses();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Text('Failed to kill process: $e'),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showProcessDetails(Map<String, dynamic> process) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Color(0xFF0A0A0A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        ),
        child: Container(
          padding: EdgeInsets.all(AppDimensions.spaceLG),
          constraints: BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Process Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
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
              Divider(color: Colors.white24),
              SizedBox(height: AppDimensions.spaceMD),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Process ID', process['pid'].toString()),
                      _buildDetailRow('User', process['user'].toString()),
                      _buildDetailRow('CPU Usage', '${process['cpu'].toStringAsFixed(1)}%'),
                      _buildDetailRow('Memory Usage', '${process['memory'].toStringAsFixed(1)}%'),
                      SizedBox(height: AppDimensions.spaceMD),
                      Text(
                        'Command',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: AppDimensions.spaceSM),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(AppDimensions.spaceMD),
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.accentCyan.withOpacity(0.3)),
                        ),
                        child: SelectableText(
                          process['command'].toString(),
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                            color: AppColors.accentCyan,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: AppDimensions.spaceLG),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _killProcess(process['pid'].toString(), process['command'].toString().split(' ')[0]);
                },
                icon: Icon(Icons.clear),
                label: Text('Kill Process'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.red.shade700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimensions.spaceSM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredProcesses = _filteredAndSortedProcesses;

    return Scaffold(
      backgroundColor: AppColors.darkGradientStart,
      appBar: AppBar(
        backgroundColor: AppColors.darkGradientStart,
        elevation: 0,
        title: Row(
          children: [
            Text('System Processes', style: TextStyle(color: Colors.white)),
            SizedBox(width: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: AppColors.glassGradientDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accentCyan.withOpacity(0.3)),
              ),
              child: Text(
                '${filteredProcesses.length}',
                style: TextStyle(
                  color: AppColors.accentCyan,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.sort, color: Colors.white),
            tooltip: 'Sort by',
            onSelected: (value) {
              setState(() => _sortOption = value);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'cpu',
                child: Row(
                  children: [
                    Icon(Icons.speed, size: 18),
                    SizedBox(width: 8),
                    Text('CPU Usage'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'memory',
                child: Row(
                  children: [
                    Icon(Icons.memory, size: 18),
                    SizedBox(width: 8),
                    Text('Memory Usage'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'name',
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha, size: 18),
                    SizedBox(width: 8),
                    Text('Name'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'user',
                child: Row(
                  children: [
                    Icon(Icons.person, size: 18),
                    SizedBox(width: 8),
                    Text('User'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadProcesses,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(AppDimensions.spaceMD),
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColors.glassGradientDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.glassBorderDark()),
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search processes...',
                  hintStyle: TextStyle(color: Colors.white54),
                  prefixIcon: Icon(Icons.search, color: AppColors.accentCyan),
                  suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.white54),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(AppDimensions.spaceMD),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(color: AppColors.accentCyan),
                )
              : filteredProcesses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(AppDimensions.spaceLG),
                          decoration: BoxDecoration(
                            gradient: AppColors.glassGradientDark,
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: AppColors.glassBorderDark()),
                          ),
                          child: Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.white24,
                          ),
                        ),
                        SizedBox(height: AppDimensions.spaceLG),
                        Text(
                          'No processes found',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: AppDimensions.spaceMD),
                    itemCount: filteredProcesses.length,
                    itemBuilder: (context, index) {
                      final process = filteredProcesses[index];
                      final cpuUsage = process['cpu'] as double;
                      final memoryUsage = process['memory'] as double;
                      final command = process['command'] as String;
                      final pid = process['pid'] as String;
                      final user = process['user'] as String;

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _showProcessDetails(process),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                          child: Container(
                            margin: EdgeInsets.only(bottom: AppDimensions.spaceSM),
                            padding: EdgeInsets.all(AppDimensions.spaceMD),
                            decoration: BoxDecoration(
                              gradient: AppColors.glassGradientDark,
                              borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                              border: Border.all(
                                color: _getProcessColor(cpuUsage).withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: _getProcessColor(cpuUsage).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.memory,
                                    color: _getProcessColor(cpuUsage),
                                    size: 20,
                                  ),
                                ),
                                SizedBox(width: AppDimensions.spaceMD),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        command.split(' ')[0],
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'PID: $pid • User: $user',
                                        style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    _buildUsageChip('CPU', cpuUsage, AppColors.accentCyan),
                                    SizedBox(height: 4),
                                    _buildUsageChip('MEM', memoryUsage, Colors.orange),
                                  ],
                                ),
                                SizedBox(width: AppDimensions.spaceSM),
                                IconButton(
                                  icon: Icon(Icons.clear, color: Colors.red, size: 20),
                                  onPressed: () => _killProcess(pid, command.split(' ')[0]),
                                  tooltip: 'Kill process',
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

  Widget _buildUsageChip(String label, double value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
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
          SizedBox(width: 4),
          Text(
            '${value.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

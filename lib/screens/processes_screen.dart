import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../providers/app_providers.dart';
import '../generated/pi_control.pb.dart';

class ProcessesScreen extends ConsumerStatefulWidget {
  const ProcessesScreen({super.key});

  @override
  ConsumerState<ProcessesScreen> createState() => _ProcessesScreenState();
}

class _ProcessesScreenState extends ConsumerState<ProcessesScreen> {
  String _searchQuery = '';
  String _sortBy = 'cpu'; // cpu, memory, name, pid
  bool _sortAscending = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Processes'),
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Sort Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Field
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by name, PID, user...',
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
                // Sort Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildSortChip('CPU', 'cpu', Icons.memory, AppTheme.primaryIndigo),
                      const Gap(8),
                      _buildSortChip('Memory', 'memory', Icons.storage, AppTheme.secondaryTeal),
                      const Gap(8),
                      _buildSortChip('Name', 'name', Icons.abc, AppTheme.successGreen),
                      const Gap(8),
                      _buildSortChip('PID', 'pid', Icons.tag, AppTheme.warningAmber),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Processes List
          Expanded(
            child: _buildProcessesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, String value, IconData icon, Color color) {
    final isSelected = _sortBy == value;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? color : AppTheme.textSecondary),
          const Gap(6),
          Text(label),
          if (isSelected) ...[
            const Gap(4),
            Icon(
              _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
              size: 14,
              color: color,
            ),
          ],
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (_sortBy == value) {
            _sortAscending = !_sortAscending;
          } else {
            _sortBy = value;
            _sortAscending = false;
          }
        });
      },
      backgroundColor: AppTheme.glassLight,
      selectedColor: color.withValues(alpha: 0.3),
      checkmarkColor: Colors.transparent,
      labelStyle: TextStyle(
        color: isSelected ? color : AppTheme.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? color : AppTheme.glassBorder,
      ),
    );
  }

  Widget _buildProcessesList() {
    final grpcService = ref.read(grpcServiceProvider);

    return FutureBuilder<ProcessList>(
      future: grpcService.getProcessList(),
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
                    'Error loading processes',
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

        final processes = snapshot.data?.processes.toList() ?? <ProcessInfo>[];
        final filteredProcesses = _filterAndSortProcesses(processes);

        if (filteredProcesses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.apps,
                  size: 64,
                  color: AppTheme.textTertiary.withValues(alpha: 0.5),
                ),
                const Gap(16),
                Text(
                  'No processes found',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredProcesses.length,
          itemBuilder: (context, index) {
            return _buildProcessCard(filteredProcesses[index]);
          },
        );
      },
    );
  }

  List<ProcessInfo> _filterAndSortProcesses(List<ProcessInfo> processes) {
    // Filter
    var filtered = processes.where((proc) {
      if (_searchQuery.isEmpty) return true;

      return proc.name.toLowerCase().contains(_searchQuery) ||
          proc.pid.toString().contains(_searchQuery) ||
          proc.username.toLowerCase().contains(_searchQuery) ||
          proc.cmdline.toLowerCase().contains(_searchQuery);
    }).toList();

    // Sort
    filtered.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'cpu':
          comparison = a.cpuPercent.compareTo(b.cpuPercent);
          break;
        case 'memory':
          comparison = a.memoryBytes.compareTo(b.memoryBytes);
          break;
        case 'name':
          comparison = a.name.toLowerCase().compareTo(b.name.toLowerCase());
          break;
        case 'pid':
          comparison = a.pid.compareTo(b.pid);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });

    return filtered;
  }

  Widget _buildProcessCard(ProcessInfo process) {
    Color getCpuColor(double cpu) {
      if (cpu > 80) return AppTheme.errorRose;
      if (cpu > 50) return AppTheme.warningAmber;
      return AppTheme.primaryIndigo;
    }

    Color getMemoryColor(double mem) {
      if (mem > 80) return AppTheme.errorRose;
      if (mem > 50) return AppTheme.warningAmber;
      return AppTheme.secondaryTeal;
    }

    final memoryMB = (process.memoryBytes.toDouble() / 1024 / 1024);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: InkWell(
          onTap: () => _showProcessDetails(process),
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Name and Kill Button
              Row(
                children: [
                  Expanded(
                    child: Text(
                      process.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Gap(8),
                  // Status Badge
                  if (process.status.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.textTertiary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        process.status,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.textTertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  const Gap(8),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => _killProcess(process),
                    color: AppTheme.errorRose,
                    tooltip: 'Kill process',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const Gap(12),
              // Info Row
              Row(
                children: [
                  // PID
                  const Icon(Icons.tag, size: 14, color: AppTheme.textTertiary),
                  const Gap(4),
                  Text(
                    'PID: ${process.pid}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const Gap(16),
                  // User
                  const Icon(Icons.person, size: 14, color: AppTheme.textTertiary),
                  const Gap(4),
                  Expanded(
                    child: Text(
                      process.username,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Gap(12),
              // Stats Row
              Row(
                children: [
                  // CPU
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.memory, size: 14, color: AppTheme.primaryIndigo),
                            const Gap(4),
                            const Text(
                              'CPU',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const Gap(4),
                        Text(
                          '${process.cpuPercent.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: getCpuColor(process.cpuPercent),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Memory
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.storage, size: 14, color: AppTheme.secondaryTeal),
                            const Gap(4),
                            const Text(
                              'Memory',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const Gap(4),
                        Text(
                          '${memoryMB.toStringAsFixed(0)} MB',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: getMemoryColor(process.memoryPercent),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProcessDetails(ProcessInfo process) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.background,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.apps, color: AppTheme.primaryIndigo),
                const Gap(12),
                Expanded(
                  child: Text(
                    process.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Gap(20),
            _buildDetailRow('PID', '${process.pid}', Icons.tag),
            const Gap(12),
            _buildDetailRow('User', process.username, Icons.person),
            const Gap(12),
            _buildDetailRow('Status', process.status, Icons.info),
            const Gap(12),
            _buildDetailRow('CPU Usage', '${process.cpuPercent.toStringAsFixed(2)}%', Icons.memory),
            const Gap(12),
            _buildDetailRow('Memory', '${process.memoryPercent.toStringAsFixed(2)}% (${(process.memoryBytes.toDouble() / 1024 / 1024).toStringAsFixed(1)} MB)', Icons.storage),
            if (process.cmdline.isNotEmpty) ...[
              const Gap(20),
              const Text(
                'Command Line:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textSecondary,
                ),
              ),
              const Gap(8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.glassLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.glassBorder),
                ),
                child: SelectableText(
                  process.cmdline,
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
            const Gap(24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _killProcess(process);
                    },
                    icon: const Icon(Icons.close),
                    label: const Text('Kill Process'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.errorRose,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textTertiary),
        const Gap(12),
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _killProcess(ProcessInfo process) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.background,
        title: const Text('Kill Process?'),
        content: Text(
          'Are you sure you want to kill "${process.name}" (PID: ${process.pid})?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRose,
              foregroundColor: Colors.white,
            ),
            child: const Text('Kill'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final grpcService = ref.read(grpcServiceProvider);
        await grpcService.killProcess(process.pid);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Process "${process.name}" (PID: ${process.pid}) killed successfully',
                  style: const TextStyle(color: Colors.white)),
              backgroundColor: AppTheme.successGreen,
            ),
          );
          // Refresh the list
          setState(() {});
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to kill process: $e',
                  style: const TextStyle(color: Colors.white)),
              backgroundColor: AppTheme.errorRose,
            ),
          );
        }
      }
    }
  }
}

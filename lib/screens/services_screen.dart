import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../providers/app_providers.dart';
import '../generated/pi_control.pb.dart';
import 'service_logs_screen.dart';

class ServicesScreen extends ConsumerStatefulWidget {
  const ServicesScreen({super.key});

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen> {
  String _searchQuery = '';
  String _filterStatus = 'all'; // all, active, inactive

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(serviceListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Services'),
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(serviceListProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Field
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search services...',
                    prefixIcon: const Icon(Icons.search, color: AppTheme.textTertiary),
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
                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', 'all'),
                      const Gap(8),
                      _buildFilterChip('Active', 'active'),
                      const Gap(8),
                      _buildFilterChip('Inactive', 'inactive'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Services List
          Expanded(
            child: servicesAsync.when(
              data: (serviceList) {
                final services = _filterServices(serviceList.services);

                if (services.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppTheme.textTertiary.withValues(alpha: 0.5),
                        ),
                        const Gap(16),
                        Text(
                          'No services found',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    return _buildServiceItem(services[index]);
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryIndigo),
              ),
              error: (error, stack) => Center(
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
                        'Error loading services',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Gap(8),
                      Text(
                        error.toString(),
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const Gap(16),
                      ElevatedButton.icon(
                        onPressed: () => ref.invalidate(serviceListProvider),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterStatus == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterStatus = value;
        });
      },
      backgroundColor: AppTheme.glassLight,
      selectedColor: AppTheme.primaryIndigo.withValues(alpha: 0.3),
      checkmarkColor: AppTheme.primaryIndigo,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryIndigo : AppTheme.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? AppTheme.primaryIndigo : AppTheme.glassBorder,
      ),
    );
  }

  List<ServiceInfo> _filterServices(List<ServiceInfo> services) {
    return services.where((service) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final nameMatch = service.name.toLowerCase().contains(_searchQuery);
        final descMatch = service.description.toLowerCase().contains(_searchQuery);
        if (!nameMatch && !descMatch) return false;
      }

      // Status filter
      if (_filterStatus == 'active') {
        return service.subState == 'running';
      } else if (_filterStatus == 'inactive') {
        return service.subState != 'running';
      }

      return true;
    }).toList();
  }

  Widget _buildServiceItem(ServiceInfo service) {
    final isRunning = service.subState == 'running';
    final statusColor = isRunning ? AppTheme.successGreen : AppTheme.textTertiary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        onTap: () => _showServiceOptions(service),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Status Indicator
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                    boxShadow: isRunning ? [
                      BoxShadow(
                        color: statusColor.withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ] : null,
                  ),
                ),
                const Gap(12),
                // Service Name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (service.description.isNotEmpty) ...[
                        const Gap(2),
                        Text(
                          service.description,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textTertiary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const Gap(12),
            // Status Row
            Row(
              children: [
                _buildStatusChip('Status', service.subState, statusColor),
                const Gap(8),
                _buildStatusChip(
                  'Enabled',
                  service.enabled ? 'yes' : 'no',
                  service.enabled ? AppTheme.primaryIndigo : AppTheme.textTertiary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
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

  void _showServiceOptions(ServiceInfo service) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.settings_applications, color: AppTheme.primaryIndigo, size: 28),
                const Gap(12),
                Expanded(
                  child: Text(
                    service.name,
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Gap(24),

            // Control Actions
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.play_arrow,
                    label: 'Start',
                    color: AppTheme.successGreen,
                    onPressed: () {
                      Navigator.pop(context);
                      _manageService(service, ServiceAction.START);
                    },
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.stop,
                    label: 'Stop',
                    color: AppTheme.errorRose,
                    onPressed: () {
                      Navigator.pop(context);
                      _manageService(service, ServiceAction.STOP);
                    },
                  ),
                ),
              ],
            ),
            const Gap(8),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.refresh,
                    label: 'Restart',
                    color: AppTheme.warningAmber,
                    onPressed: () {
                      Navigator.pop(context);
                      _manageService(service, ServiceAction.RESTART);
                    },
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.replay,
                    label: 'Reload',
                    color: AppTheme.secondaryTeal,
                    onPressed: () {
                      Navigator.pop(context);
                      _manageService(service, ServiceAction.RELOAD);
                    },
                  ),
                ),
              ],
            ),
            const Gap(16),
            const Divider(color: AppTheme.glassBorder),
            const Gap(16),

            // View Logs Button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ServiceLogsScreen(serviceName: service.name),
                  ),
                );
              },
              icon: const Icon(Icons.article, size: 20),
              label: const Text('View Logs'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryTeal.withValues(alpha: 0.2),
                foregroundColor: AppTheme.secondaryTeal,
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: AppTheme.secondaryTeal.withValues(alpha: 0.5)),
              ),
            ),
            const Gap(16),
            const Divider(color: AppTheme.glassBorder),
            const Gap(16),

            // Enable/Disable
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _manageService(service, ServiceAction.ENABLE);
                    },
                    icon: const Icon(Icons.check_circle_outline, size: 20),
                    label: const Text('Enable on Boot'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryIndigo,
                      side: const BorderSide(color: AppTheme.primaryIndigo),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _manageService(service, ServiceAction.DISABLE);
                    },
                    icon: const Icon(Icons.cancel_outlined, size: 20),
                    label: const Text('Disable on Boot'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary,
                      side: const BorderSide(color: AppTheme.glassBorder),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const Gap(8),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.2),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: BorderSide(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const Gap(6),
          Text(label),
        ],
      ),
    );
  }

  Future<void> _manageService(ServiceInfo service, ServiceAction action) async {
    try {
      final grpcService = ref.read(grpcServiceProvider);
      final result = await grpcService.manageService(service.name, action);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.success ? result.message : 'Failed: ${result.message}',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: result.success ? AppTheme.successGreen : AppTheme.errorRose,
          ),
        );

        if (result.success) {
          // Refresh the service list after a short delay
          await Future.delayed(const Duration(milliseconds: 500));
          ref.invalidate(serviceListProvider);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e', style: const TextStyle(color: Colors.white)),
            backgroundColor: AppTheme.errorRose,
          ),
        );
      }
    }
  }
}

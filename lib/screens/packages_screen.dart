import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../providers/app_providers.dart';
import '../generated/pi_control.pb.dart';
import 'package_details_screen.dart';

class PackagesScreen extends ConsumerStatefulWidget {
  const PackagesScreen({super.key});

  @override
  ConsumerState<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends ConsumerState<PackagesScreen> {
  bool _installedOnly = true;
  String _searchQuery = '';
  bool _isLoading = false;
  List<PackageInfo> _packages = [];
  String? _error;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadPackages();
    // Check agent elevation status - delay to ensure connection is fully established
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        ref.read(agentElevationProvider.notifier).refresh();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadPackages() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final grpcService = ref.read(grpcServiceProvider);
      final packageList = await grpcService.listPackages(
        searchTerm: _searchQuery.isEmpty ? null : _searchQuery,
        installedOnly: _installedOnly,
      );

      setState(() {
        _packages = packageList.packages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updatePackageList() async {
    try {
      final grpcService = ref.read(grpcServiceProvider);
      final result = await grpcService.updatePackageList();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: result.success ? AppTheme.successGreen : AppTheme.errorRose,
          ),
        );
      }

      if (result.success) {
        _loadPackages();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.errorRose,
          ),
        );
      }
    }
  }

  Future<void> _upgradePackages() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upgrade All Packages'),
        content: const Text('This will upgrade all installed packages to their latest versions. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: const AlertDialog(
            backgroundColor: AppTheme.background,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                Gap(16),
                Text('Upgrading packages...'),
              ],
            ),
          ),
        ),
      );
    }

    try {
      final grpcService = ref.read(grpcServiceProvider);
      final result = await grpcService.upgradePackages();

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.message,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: result.success ? AppTheme.successGreen : AppTheme.errorRose,
          ),
        );
      }

      if (result.success) {
        _loadPackages();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: $e',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppTheme.errorRose,
          ),
        );
      }
    }
  }

  Future<void> _installPackage(String packageName) async{
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: AppTheme.background,
          title: const Text('Install Package'),
          content: Text('Install $packageName?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Install'),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) return;

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: const AlertDialog(
            backgroundColor: AppTheme.background,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                Gap(16),
                Text('Installing package...'),
              ],
            ),
          ),
        ),
      );
    }

    try {
      final grpcService = ref.read(grpcServiceProvider);
      final result = await grpcService.installPackage(packageName);

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.message,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: result.success ? AppTheme.successGreen : AppTheme.errorRose,
          ),
        );
      }

      if (result.success) {
        _loadPackages();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: $e',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppTheme.errorRose,
          ),
        );
      }
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Future<void> _removePackage(String packageName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: AppTheme.background,
          title: const Text('Remove Package'),
          content: Text('Remove $packageName?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.errorRose,
              ),
              child: const Text('Remove'),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) return;

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: const AlertDialog(
            backgroundColor: AppTheme.background,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                Gap(16),
                Text('Removing package...'),
              ],
            ),
          ),
        ),
      );
    }

    try {
      final grpcService = ref.read(grpcServiceProvider);
      final result = await grpcService.removePackage(packageName);

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.message,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: result.success ? AppTheme.successGreen : AppTheme.errorRose,
          ),
        );
      }

      if (result.success) {
        _loadPackages();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: $e',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppTheme.errorRose,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final elevationStatus = ref.watch(agentElevationProvider);
    final currentConnection = ref.watch(currentConnectionProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Package Manager'),
        scrolledUnderElevation: 0,
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: _updatePackageList,
                child: const Row(
                  children: [
                    Icon(Icons.sync),
                    Gap(12),
                    Text('Update Package List'),
                  ],
                ),
              ),
              PopupMenuItem(
                onTap: _upgradePackages,
                child: const Row(
                  children: [
                    Icon(Icons.system_update),
                    Gap(12),
                    Text('Upgrade All'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Warning banner if agent is not running as root
          elevationStatus.when(
            data: (isRoot) {
              debugPrint('PackagesScreen: Elevation status - isRoot: $isRoot');
              if (!isRoot) {
                const warningMessage = '⚠️ Limited Functionality: The agent is not running with elevated privileges. You can browse packages, but installing or removing them may fail.';
                
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.errorRose.withValues(alpha: 0.15),
                    border: Border(
                      bottom: BorderSide(
                        color: AppTheme.errorRose.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: AppTheme.errorRose,
                        size: 20,
                      ),
                      const Gap(12),
                      Expanded(
                        child: Text(
                          warningMessage,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.errorRose,
                                fontSize: 12,
                              ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
            loading: () {
              debugPrint('PackagesScreen: Elevation status loading...');
              return const SizedBox.shrink();
            },
            error: (error, stack) {
              debugPrint('PackagesScreen: Elevation check error: $error');
              // Show warning if we can't check (assume not root to be safe)
              const warningMessage = '⚠️ Limited Functionality: Could not verify agent privileges. Package operations may fail.';
              
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.errorRose.withValues(alpha: 0.15),
                  border: Border(
                    bottom: BorderSide(
                      color: AppTheme.errorRose.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: AppTheme.errorRose,
                      size: 20,
                    ),
                    const Gap(12),
                    Expanded(
                      child: Text(
                        warningMessage,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.errorRose,
                              fontSize: 12,
                            ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          // Search and filter
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search packages...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() => _searchQuery = '');
                              _debounce?.cancel();
                              _loadPackages();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    // Cancel previous timer
                    _debounce?.cancel();

                    setState(() => _searchQuery = value);

                    // Only search after user stops typing for 500ms
                    _debounce = Timer(const Duration(milliseconds: 500), () {
                      _loadPackages();
                    });
                  },
                  onSubmitted: (value) {
                    _debounce?.cancel();
                    setState(() => _searchQuery = value);
                    _loadPackages();
                  },
                ),
                const Gap(12),
                Row(
                  children: [
                    Expanded(
                      child: SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(
                            value: true,
                            label: Text('Installed'),
                            icon: Icon(Icons.check_circle_outline),
                          ),
                          ButtonSegment(
                            value: false,
                            label: Text('All'),
                            icon: Icon(Icons.apps),
                          ),
                        ],
                        selected: {_installedOnly},
                        onSelectionChanged: (Set<bool> newSelection) {
                          setState(() => _installedOnly = newSelection.first);
                          _loadPackages();
                        },
                      ),
                    ),
                    const Gap(12),
                    IconButton.filled(
                      icon: const Icon(Icons.refresh),
                      onPressed: _loadPackages,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Package list
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        Gap(16),
                        Text('Loading packages...'),
                      ],
                    ),
                  )
                : _error != null
                    ? Center(
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
                                'Error loading packages',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const Gap(8),
                              Text(
                                _error!,
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                              const Gap(16),
                              FilledButton.icon(
                                onPressed: _loadPackages,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _packages.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inbox_outlined,
                                  size: 64,
                                  color: Colors.grey[600],
                                ),
                                const Gap(16),
                                Text(
                                  'No packages found',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _packages.length,
                            itemBuilder: (context, index) {
                              final package = _packages[index];
                              return _buildPackageItem(package);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageItem(PackageInfo package) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PackageDetailsScreen(
                packageName: package.name,
                isInstalled: package.installed,
              ),
            ),
          ).then((_) {
            // Reload packages when returning from details screen
            _loadPackages();
          });
        },
        child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: package.installed ? AppTheme.successGreen.withValues(alpha: 0.2) : AppTheme.glassLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              package.installed ? Icons.check_circle : Icons.apps,
              color: package.installed ? AppTheme.successGreen : Colors.grey,
              size: 24,
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        package.name,
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (package.version.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.glassLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          package.version,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                  ],
                ),
                if (package.description.isNotEmpty) ...[
                  const Gap(4),
                  Text(
                    package.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[400],
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (package.installed && package.installedSize > 0) ...[
                  const Gap(4),
                  Row(
                    children: [
                      Icon(Icons.sd_storage, size: 12, color: Colors.grey[500]),
                      const Gap(4),
                      Text(
                        _formatBytes(package.installedSize.toInt()),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[500],
                              fontSize: 11,
                            ),
                      ),
                      if (package.section.isNotEmpty) ...[
                        const Gap(8),
                        Icon(Icons.folder_outlined, size: 12, color: Colors.grey[500]),
                        const Gap(4),
                        Expanded(
                          child: Text(
                            package.section,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[500],
                                  fontSize: 11,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
          const Gap(8),
          if (package.installed)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: AppTheme.errorRose,
              onPressed: () => _removePackage(package.name),
            )
          else
            FilledButton.icon(
              onPressed: () => _installPackage(package.name),
              icon: const Icon(Icons.download, size: 18),
              label: const Text('Install'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
        ],
      ),
      ),
    );
  }
}

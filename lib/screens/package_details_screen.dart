import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../providers/app_providers.dart';
import '../generated/pi_control.pb.dart';

class PackageDetailsScreen extends ConsumerStatefulWidget {
  final String packageName;
  final bool isInstalled;

  const PackageDetailsScreen({
    super.key,
    required this.packageName,
    required this.isInstalled,
  });

  @override
  ConsumerState<PackageDetailsScreen> createState() => _PackageDetailsScreenState();
}

class _PackageDetailsScreenState extends ConsumerState<PackageDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  PackageDetails? _details;
  PackageDependencies? _dependencies;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPackageDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPackageDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final grpcService = ref.read(grpcServiceProvider);
      final details = await grpcService.getPackageDetails(widget.packageName);
      final dependencies = await grpcService.getPackageDependencies(widget.packageName);

      if (mounted) {
        setState(() {
          _details = details;
          _dependencies = dependencies;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _installPackage() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.background,
        title: const Text('Install Package'),
        content: Text('Install ${widget.packageName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.successGreen,
            ),
            child: const Text('Install'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final grpcService = ref.read(grpcServiceProvider);
      final result = await grpcService.installPackage(widget.packageName);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.message,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: result.success ? AppTheme.successGreen : AppTheme.errorRose,
          ),
        );

        if (result.success) {
          _loadPackageDetails(); // Reload to update status
        }
      }
    } catch (e) {
      if (mounted) {
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

  Future<void> _removePackage() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.background,
        title: const Text('Remove Package'),
        content: Text('Remove ${widget.packageName}?'),
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
    );

    if (confirmed != true || !mounted) return;

    try {
      final grpcService = ref.read(grpcServiceProvider);
      final result = await grpcService.removePackage(widget.packageName);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.message,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: result.success ? AppTheme.successGreen : AppTheme.errorRose,
          ),
        );

        if (result.success) {
          Navigator.pop(context); // Go back to package list
        }
      }
    } catch (e) {
      if (mounted) {
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

  String _formatDate(int timestamp) {
    if (timestamp == 0) return 'Unknown';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _updatePackage() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.background,
        title: const Text('Update Package'),
        content: Text('Update ${widget.packageName} to the latest version?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primaryIndigo,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final grpcService = ref.read(grpcServiceProvider);
      final result = await grpcService.updatePackage(widget.packageName);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.message,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: result.success ? AppTheme.successGreen : AppTheme.errorRose,
          ),
        );

        if (result.success) {
          _loadPackageDetails(); // Reload to update status
        }
      }
    } catch (e) {
      if (mounted) {
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.packageName),
        actions: [
          if (_details != null)
            _details!.installed
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.system_update),
                        onPressed: _updatePackage,
                        tooltip: 'Update Package',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: _removePackage,
                        tooltip: 'Remove Package',
                      ),
                    ],
                  )
                : IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: _installPackage,
                    tooltip: 'Install Package',
                  ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Dependencies'),
            Tab(text: 'Details'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryIndigo))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: AppTheme.errorRose),
                      const Gap(16),
                      Text('Error loading package details', style: Theme.of(context).textTheme.titleMedium),
                      const Gap(8),
                      Text(_error!, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildDependenciesTab(),
                    _buildDetailsTab(),
                  ],
                ),
    );
  }

  Widget _buildOverviewTab() {
    if (_details == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _details!.installed ? AppTheme.successGreen : AppTheme.textTertiary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _details!.installed ? 'INSTALLED' : 'NOT INSTALLED',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const Gap(24),

          // Short Description
          Text(
            _details!.description,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Gap(24),

          // Key Information
          GlassCard(
            child: Column(
              children: [
                _buildInfoRow(Icons.info_outline, 'Version', _details!.version),
                const Divider(color: AppTheme.glassBorder),
                _buildInfoRow(Icons.computer, 'Architecture', _details!.architecture),
                const Divider(color: AppTheme.glassBorder),
                _buildInfoRow(Icons.folder, 'Section', _details!.section.isEmpty ? 'Unknown' : _details!.section),
                if (_details!.installed) ...[
                  const Divider(color: AppTheme.glassBorder),
                  _buildInfoRow(Icons.storage, 'Installed Size', _formatBytes(_details!.installedSize.toInt())),
                  const Divider(color: AppTheme.glassBorder),
                  _buildInfoRow(Icons.calendar_today, 'Install Date', _formatDate(_details!.installDate.toInt())),
                ],
              ],
            ),
          ),
          const Gap(24),

          // Long Description
          if (_details!.longDescription.isNotEmpty) ...[
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Gap(12),
            GlassCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _details!.longDescription,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            const Gap(24),
          ],

          // Maintainer & Homepage
          if (_details!.maintainer.isNotEmpty || _details!.homepage.isNotEmpty) ...[
            Text(
              'Project Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Gap(12),
            GlassCard(
              child: Column(
                children: [
                  if (_details!.maintainer.isNotEmpty) ...[
                    _buildInfoRow(Icons.person, 'Maintainer', _details!.maintainer),
                    if (_details!.homepage.isNotEmpty) const Divider(color: AppTheme.glassBorder),
                  ],
                  if (_details!.homepage.isNotEmpty)
                    ListTile(
                      leading: const Icon(Icons.link, color: AppTheme.primaryIndigo),
                      title: const Text('Homepage'),
                      subtitle: Text(_details!.homepage),
                      trailing: const Icon(Icons.open_in_new, size: 20),
                      onTap: () async {
                        final uri = Uri.parse(_details!.homepage);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                    ),
                ],
              ),
            ),
            const Gap(24),
          ],

          // Tags
          if (_details!.tags.isNotEmpty) ...[
            Text(
              'Tags',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Gap(12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _details!.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryIndigo.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryIndigo.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      color: AppTheme.primaryIndigo,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDependenciesTab() {
    if (_dependencies == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Depends
          if (_dependencies!.depends.isNotEmpty) ...[
            _buildDependencySection(
              'Required Packages',
              'These packages must be installed for ${widget.packageName} to work',
              _dependencies!.depends,
              Icons.arrow_downward,
              AppTheme.errorRose,
            ),
            const Gap(24),
          ],

          // Required By
          if (_dependencies!.requiredBy.isNotEmpty) ...[
            _buildDependencySection(
              'Required By',
              'These packages depend on ${widget.packageName}',
              _dependencies!.requiredBy,
              Icons.arrow_upward,
              AppTheme.warningAmber,
            ),
            const Gap(24),
          ],

          // Recommends
          if (_dependencies!.recommends.isNotEmpty) ...[
            _buildDependencySection(
              'Recommended',
              'These packages are recommended for full functionality',
              _dependencies!.recommends,
              Icons.thumb_up_outlined,
              AppTheme.secondaryTeal,
            ),
            const Gap(24),
          ],

          // Suggests
          if (_dependencies!.suggests.isNotEmpty) ...[
            _buildDependencySection(
              'Suggested',
              'These packages enhance ${widget.packageName}',
              _dependencies!.suggests,
              Icons.lightbulb_outline,
              AppTheme.primaryIndigo,
            ),
            const Gap(24),
          ],

          // Conflicts
          if (_dependencies!.conflicts.isNotEmpty) ...[
            _buildDependencySection(
              'Conflicts',
              'These packages conflict with ${widget.packageName}',
              _dependencies!.conflicts,
              Icons.warning_outlined,
              AppTheme.errorRose,
            ),
          ],

          // Empty state
          if (_dependencies!.depends.isEmpty &&
              _dependencies!.requiredBy.isEmpty &&
              _dependencies!.recommends.isEmpty &&
              _dependencies!.suggests.isEmpty &&
              _dependencies!.conflicts.isEmpty)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_outline, size: 48, color: AppTheme.successGreen),
                  const Gap(16),
                  Text(
                    'No dependencies',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Gap(8),
                  Text(
                    'This package has no dependency information',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDependencySection(
    String title,
    String description,
    List<String> packages,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 24),
            const Gap(8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
        const Gap(8),
        Text(
          description,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        const Gap(12),
        GlassCard(
          child: Column(
            children: packages.asMap().entries.map((entry) {
              final index = entry.key;
              final pkg = entry.value;
              return Column(
                children: [
                  if (index > 0) const Divider(color: AppTheme.glassBorder),
                  ListTile(
                    leading: Icon(Icons.inventory_2_outlined, color: color, size: 20),
                    title: Text(pkg),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () {
                      // Navigate to package details
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PackageDetailsScreen(
                            packageName: pkg,
                            isInstalled: false, // We don't know, will be checked
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsTab() {
    if (_details == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Technical Details',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Gap(12),
          GlassCard(
            child: Column(
              children: [
                _buildDetailRow('Package Name', _details!.name),
                const Divider(color: AppTheme.glassBorder),
                _buildDetailRow('Version', _details!.version),
                const Divider(color: AppTheme.glassBorder),
                _buildDetailRow('Architecture', _details!.architecture),
                const Divider(color: AppTheme.glassBorder),
                _buildDetailRow('Status', _details!.status),
                if (_details!.source.isNotEmpty) ...[
                  const Divider(color: AppTheme.glassBorder),
                  _buildDetailRow('Source Package', _details!.source),
                ],
                const Divider(color: AppTheme.glassBorder),
                _buildDetailRow('Section', _details!.section.isEmpty ? 'Unknown' : _details!.section),
                if (_details!.license.isNotEmpty) ...[
                  const Divider(color: AppTheme.glassBorder),
                  _buildDetailRow('License', _details!.license),
                ],
                if (_details!.installed) ...[
                  const Divider(color: AppTheme.glassBorder),
                  _buildDetailRow('Installed Size', _formatBytes(_details!.installedSize.toInt())),
                  const Divider(color: AppTheme.glassBorder),
                  _buildDetailRow('Install Date', _formatDate(_details!.installDate.toInt())),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryIndigo),
      title: Text(label),
      subtitle: Text(value),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          const Gap(16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../providers/app_providers.dart';
import '../generated/pi_control.pb.dart';

class SystemUpdateScreen extends ConsumerStatefulWidget {
  const SystemUpdateScreen({super.key});

  @override
  ConsumerState<SystemUpdateScreen> createState() => _SystemUpdateScreenState();
}

class _SystemUpdateScreenState extends ConsumerState<SystemUpdateScreen> {
  SystemUpdateStatus? _status;
  bool _isLoading = true;
  bool _isUpgrading = false;
  final List<String> _upgradeLog = [];
  String _upgradePhase = '';
  String? _error;
  StreamSubscription? _upgradeSubscription;
  final Set<String> _upgradingSingle = {};

  @override
  void initState() {
    super.initState();
    _checkForUpdates();
  }

  @override
  void dispose() {
    _upgradeSubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkForUpdates() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final grpcService = ref.read(grpcServiceProvider);
      final status = await grpcService.getSystemUpdateStatus();
      if (mounted) {
        setState(() {
          _status = status;
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

  void _startUpgrade() {
    setState(() {
      _isUpgrading = true;
      _upgradeLog.clear();
      _upgradePhase = 'update';
    });

    final grpcService = ref.read(grpcServiceProvider);
    _upgradeSubscription = grpcService.streamSystemUpgrade().listen(
      (progress) {
        if (mounted) {
          setState(() {
            if (progress.line.isNotEmpty) {
              _upgradeLog.add(progress.line);
            }
            _upgradePhase = progress.phase;
            if (progress.isComplete) {
              _isUpgrading = false;
              if (progress.success) {
                _checkForUpdates(); // Refresh status
              }
            }
          });
        }
      },
      onError: (e) {
        if (mounted) {
          setState(() {
            _isUpgrading = false;
            _upgradeLog.add('Error: $e');
          });
        }
      },
    );
  }

  Future<void> _upgradeSinglePackage(String packageName) async {
    setState(() => _upgradingSingle.add(packageName));
    try {
      final grpcService = ref.read(grpcServiceProvider);
      final result = await grpcService.updatePackage(packageName);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.success ? 'Updated $packageName' : 'Failed: ${result.message}',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: result.success ? AppTheme.successGreen : AppTheme.errorRose,
          ),
        );
        if (result.success) _checkForUpdates();
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
    } finally {
      if (mounted) setState(() => _upgradingSingle.remove(packageName));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Updates'),
        scrolledUnderElevation: 0,
        actions: [
          if (!_isUpgrading)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _checkForUpdates,
              tooltip: 'Check for updates',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : _buildContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppTheme.errorRose),
          const Gap(16),
          Text('Failed to load update status',
              style: Theme.of(context).textTheme.titleMedium),
          const Gap(8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(_error!, style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center),
          ),
          const Gap(16),
          FilledButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            onPressed: _checkForUpdates,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSystemInfoCard(),
        const Gap(16),
        _buildUpdateSummaryCard(),
        const Gap(16),
        if (_status != null && _status!.upgradablePackages.isNotEmpty)
          _buildPackageList(),
        if (_upgradeLog.isNotEmpty) ...[
          const Gap(16),
          _buildUpgradeLogCard(),
        ],
      ],
    );
  }

  Widget _buildSystemInfoCard() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryIndigo.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.computer, color: AppTheme.primaryIndigo, size: 24),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('System Information',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold)),
                      if (_status?.osName.isNotEmpty == true)
                        Text(_status!.osName,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24, color: AppTheme.glassBorder),
            _buildInfoRow(Icons.memory, 'Kernel', _status?.kernelVersion ?? 'N/A'),
            const Gap(8),
            _buildInfoRow(Icons.architecture, 'Architecture', _status?.architecture ?? 'N/A'),
            const Gap(8),
            _buildInfoRow(Icons.timer_outlined, 'Uptime', _status?.uptime ?? 'N/A'),
            const Gap(8),
            _buildInfoRow(Icons.update, 'Last Checked',
                _status?.lastUpdate.isNotEmpty == true ? _status!.lastUpdate : 'Never'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textSecondary),
        const Gap(8),
        Text('$label: ', style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary)),
        Expanded(
          child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }

  Widget _buildUpdateSummaryCard() {
    final count = _status?.upgradableCount ?? 0;
    final hasUpdates = count > 0;
    final color = hasUpdates ? AppTheme.warningAmber : AppTheme.successGreen;
    final icon = hasUpdates ? Icons.system_update : Icons.check_circle;

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasUpdates ? '$count update${count == 1 ? '' : 's'} available' : 'System is up to date',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold),
                      ),
                      Text(
                        hasUpdates ? 'Tap upgrade to install all updates' : 'No packages need updating',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (hasUpdates) ...[
              const Gap(16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: _isUpgrading
                      ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.system_update_alt),
                  label: Text(_isUpgrading ? _getPhaseLabel() : 'Upgrade All'),
                  onPressed: _isUpgrading ? null : _startUpgrade,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primaryIndigo,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getPhaseLabel() {
    switch (_upgradePhase) {
      case 'update':
        return 'Updating package list...';
      case 'upgrade':
        return 'Upgrading packages...';
      case 'done':
        return 'Complete!';
      case 'error':
        return 'Error occurred';
      default:
        return 'Working...';
    }
  }

  Widget _buildPackageList() {
    final packages = _status!.upgradablePackages;

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Upgradable Packages',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold)),
            const Gap(12),
            ...packages.map((pkg) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_upward, size: 14, color: AppTheme.warningAmber),
                      const Gap(8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(pkg.name,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600)),
                            Text(
                              '${pkg.currentVersion.isNotEmpty ? pkg.currentVersion : "?"} → ${pkg.newVersion}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textSecondary,
                                    fontFamily: 'Courier',
                                    fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      if (_upgradingSingle.contains(pkg.name))
                        const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        IconButton(
                          icon: const Icon(Icons.upgrade, size: 20, color: AppTheme.successGreen),
                          onPressed: _isUpgrading ? null : () => _upgradeSinglePackage(pkg.name),
                          tooltip: 'Upgrade ${pkg.name}',
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(4),
                        ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeLogCard() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Upgrade Log',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  onPressed: () => setState(() => _upgradeLog.clear()),
                  tooltip: 'Clear log',
                ),
              ],
            ),
            const Gap(8),
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 300),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                reverse: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _upgradeLog
                      .map((line) => Text(
                            line,
                            style: TextStyle(
                              color: line.startsWith('Error') ? AppTheme.errorRose : Colors.white70,
                              fontFamily: 'Courier',
                              fontSize: 11,
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

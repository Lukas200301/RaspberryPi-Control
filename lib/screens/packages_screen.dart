import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../generated/pi_control.pb.dart';
import '../providers/app_providers.dart';
import '../ui/ui.dart';
import 'package_details_screen.dart';
import 'system_update_screen.dart';

/// Tabs of the Packages screen
enum PackagesTab { updates, installed, find }

/// Runs a package command with a blocking progress dialog and reports the result
Future<bool> runPackageCommand(
  BuildContext context, {
  required String working,
  required Future<ActionStatus> Function() call,
  required String done,
}) async {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialog) => PopScope(
      canPop: false,
      child: AlertDialog(
        content: Row(
          children: [
            const SizedBox.square(dimension: 24, child: CircularProgressIndicator(strokeWidth: 3)),
            const Gap(Insets.lg),
            Expanded(child: Text(working)),
          ],
        ),
      ),
    ),
  );
  var ok = false;
  String message;
  try {
    final r = await call();
    ok = r.success;
    message = ok ? done : r.message;
  } catch (e) {
    message = describeError(e);
  }
  if (context.mounted) {
    Navigator.of(context, rootNavigator: true).pop();
    showToast(context, message, tone: ok ? Tone.success : Tone.danger);
  }
  return ok;
}

/// apt software: updates, installed packages and search in one place
class PackagesScreen extends ConsumerStatefulWidget {
  final PackagesTab initialTab;

  const PackagesScreen({super.key, this.initialTab = PackagesTab.updates});

  @override
  ConsumerState<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends ConsumerState<PackagesScreen> with SingleTickerProviderStateMixin {
  late final _tabs = TabController(length: 3, vsync: this, initialIndex: widget.initialTab.index);
  String _query = '';
  Timer? _debounce;
  bool _loading = false;
  bool _refreshing = false;
  Object? _error;
  List<PackageInfo> _packages = [];
  int _request = 0;

  PackagesTab get _tab => PackagesTab.values[_tabs.index];

  @override
  void initState() {
    super.initState();
    _tabs.addListener(() {
      if (_tabs.indexIsChanging) return;
      setState(() {});
      if (_tab != PackagesTab.updates) _load();
    });
    if (_tab != PackagesTab.updates) _load();
    Future.microtask(() => ref.read(agentElevationProvider.notifier).refresh());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _tabs.dispose();
    super.dispose();
  }

  bool get _needsQuery => _tab == PackagesTab.find && _query.trim().length < 2;

  Future<void> _load() async {
    if (_tab == PackagesTab.updates) return;
    if (_needsQuery) {
      setState(() {
        _packages = [];
        _loading = false;
        _error = null;
      });
      return;
    }
    final request = ++_request;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await ref
          .read(grpcServiceProvider)
          .listPackages(
            searchTerm: _query.trim().isEmpty ? null : _query.trim(),
            installedOnly: _tab == PackagesTab.installed,
          );
      // Ignore answers to older searches
      if (!mounted || request != _request) return;
      setState(() {
        _packages = list.packages;
        _loading = false;
      });
    } catch (e) {
      if (!mounted || request != _request) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  void _search(String v) {
    _query = v;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _load);
    setState(() {});
  }

  /// apt-get update: fresh package lists for all tabs
  Future<void> _refreshLists() async {
    setState(() => _refreshing = true);
    try {
      final r = await ref.read(grpcServiceProvider).updatePackageList();
      if (!mounted) return;
      showToast(
        context,
        r.success ? 'Package lists are up to date' : r.message,
        tone: r.success ? Tone.success : Tone.danger,
      );
    } catch (e) {
      if (mounted) showToast(context, describeError(e), tone: Tone.danger);
    } finally {
      ref.invalidate(updateStatusProvider);
      if (mounted) setState(() => _refreshing = false);
      _load();
    }
  }

  Future<void> _open(PackageInfo p) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => PackageDetailsScreen(packageName: p.name)),
    );
    if (changed == true) {
      ref.invalidate(updateStatusProvider);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final root = ref.watch(agentElevationProvider).valueOrNull;
    final status = ref.watch(updateStatusProvider).valueOrNull;
    final upgradable = {for (final u in status?.upgradablePackages ?? const <UpgradablePackage>[]) u.name};
    final updates = status?.upgradablePackages.length;

    return PageScaffold(
      title: 'Packages',
      subtitle: switch (_tab) {
        PackagesTab.updates =>
          updates == null
              ? null
              : updates == 0
              ? 'Up to date'
              : '$updates ${updates == 1 ? 'update' : 'updates'} available',
        PackagesTab.installed => _loading ? 'Loading…' : '${_packages.length} installed',
        PackagesTab.find =>
          _loading ? 'Searching…' : (_needsQuery ? 'Search all available software' : '${_packages.length} found'),
      },
      actions: [
        IconButton(
          tooltip: 'Check for updates (apt update)',
          onPressed: _refreshing ? null : _refreshLists,
          icon: _refreshing
              ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.sync),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(_tab == PackagesTab.updates ? 48 : 112),
        child: Column(
          children: [
            TabBar(
              controller: _tabs,
              tabs: [
                Tab(
                  child: Badge(
                    isLabelVisible: (updates ?? 0) > 0,
                    label: Text('${updates ?? 0}'),
                    offset: const Offset(14, -6),
                    child: const Text('Updates'),
                  ),
                ),
                const Tab(text: 'Installed'),
                const Tab(text: 'Find'),
              ],
            ),
            if (_tab != PackagesTab.updates)
              Padding(
                padding: const EdgeInsets.fromLTRB(Insets.page, Insets.sm, Insets.page, Insets.sm),
                child: SearchField(
                  key: ValueKey(_tab),
                  hint: _tab == PackagesTab.find ? 'Search all software (e.g. nginx)' : 'Search installed packages',
                  initial: _query,
                  onChanged: _search,
                ),
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (root == false)
            MaterialBanner(
              leading: const Icon(Icons.admin_panel_settings_outlined),
              content: const Text(
                'The agent is not running as root, so installing and removing packages will fail. '
                'Reinstall it under Settings > Agent.',
              ),
              actions: [
                TextButton(
                  onPressed: () => ref.read(agentElevationProvider.notifier).refresh(),
                  child: const Text('Check again'),
                ),
              ],
            ),
          Expanded(
            // IndexedStack keeps a running upgrade alive while you look at other tabs
            child: IndexedStack(
              index: _tabs.index,
              children: [
                const UpdatesView(),
                _tab == PackagesTab.installed ? _listTab(upgradable) : const SizedBox.shrink(),
                _tab == PackagesTab.find ? _listTab(upgradable) : const SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _listTab(Set<String> upgradable) {
    return Column(
      children: [
        if (_loading) const LinearProgressIndicator(),
        Expanded(child: _list(_packages, upgradable)),
      ],
    );
  }

  Widget _list(List<PackageInfo> shown, Set<String> upgradable) {
    if (_error != null && shown.isEmpty) {
      return ErrorState(title: 'Packages could not be listed', error: _error!, onRetry: _load);
    }
    if (_needsQuery) {
      return const EmptyState(
        icon: Icons.travel_explore,
        title: 'Find software',
        message: 'Type at least two letters to search everything apt can install.',
      );
    }
    if (shown.isEmpty && !_loading) {
      final installedTab = _tab == PackagesTab.installed;
      return EmptyState(
        icon: Icons.search_off,
        title: 'No packages found',
        message: installedTab && _query.isNotEmpty ? 'Search "Find" to install it.' : null,
        action: installedTab && _query.isNotEmpty
            ? OutlinedButton(
                onPressed: () => _tabs.animateTo(PackagesTab.find.index),
                child: const Text('Search all software'),
              )
            : null,
      );
    }
    // Packages with an update first
    final sorted = [...shown]
      ..sort((a, b) {
        final ua = upgradable.contains(a.name), ub = upgradable.contains(b.name);
        if (ua != ub) return ua ? -1 : 1;
        return a.name.compareTo(b.name);
      });
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(Insets.page, Insets.xs, Insets.page, 96),
        itemCount: sorted.length,
        itemBuilder: (context, i) {
          final p = sorted[i];
          final update = p.installed && upgradable.contains(p.name);
          return Padding(
            padding: const EdgeInsets.only(bottom: Insets.xs),
            child: Material(
              color: context.cs.surfaceContainer,
              borderRadius: Radii.mdAll,
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                onTap: () => _open(p),
                leading: IconBadge(
                  p.installed ? Icons.inventory_2 : Icons.inventory_2_outlined,
                  tone: update
                      ? Tone.warning
                      : p.installed
                      ? Tone.primary
                      : Tone.neutral,
                  size: 36,
                ),
                title: Row(
                  children: [
                    Flexible(child: Text(p.name, overflow: TextOverflow.ellipsis)),
                    if (update) ...[const Gap(Insets.xs), const StatusPill('update', tone: Tone.warning)],
                    if (_tab == PackagesTab.find && p.installed) ...[
                      const Gap(Insets.xs),
                      const StatusPill('installed', tone: Tone.success),
                    ],
                  ],
                ),
                subtitle: Text(
                  [if (p.version.isNotEmpty) p.version, if (p.description.isNotEmpty) p.description].join(' · '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: p.installed && p.installedSize > 0
                    ? Text(
                        formatBytes(p.installedSize.toInt()),
                        style: context.tt.labelMedium?.copyWith(color: context.cs.onSurfaceVariant),
                      )
                    : const Icon(Icons.chevron_right),
              ),
            ),
          );
        },
      ),
    );
  }
}

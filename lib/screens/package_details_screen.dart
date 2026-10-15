import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../generated/pi_control.pb.dart';
import '../providers/app_providers.dart';
import '../ui/ui.dart';
import 'packages_screen.dart';

final _detailsProvider = FutureProvider.autoDispose.family<(PackageDetails, PackageDependencies?), String>((
  ref,
  name,
) async {
  ref.watch(grpcSessionProvider);
  final grpc = ref.read(grpcServiceProvider);
  final details = await grpc.getPackageDetails(name);
  PackageDependencies? deps;
  try {
    deps = await grpc.getPackageDependencies(name);
  } catch (_) {
    // Dependencies are extra information
  }
  return (details, deps);
});

/// One apt package: description, metadata, dependencies and actions.
/// Pops with true when something was installed, removed or updated.
class PackageDetailsScreen extends ConsumerStatefulWidget {
  final String packageName;

  const PackageDetailsScreen({super.key, required this.packageName});

  @override
  ConsumerState<PackageDetailsScreen> createState() => _PackageDetailsScreenState();
}

class _PackageDetailsScreenState extends ConsumerState<PackageDetailsScreen> {
  bool _changed = false;

  String get _name => widget.packageName;

  Future<void> _install() async {
    final ok = await runPackageCommand(
      context,
      working: 'Installing $_name…',
      call: () => ref.read(grpcServiceProvider).installPackage(_name),
      done: 'Installed $_name',
    );
    _after(ok);
  }

  Future<void> _update() async {
    final ok = await runPackageCommand(
      context,
      working: 'Updating $_name…',
      call: () => ref.read(grpcServiceProvider).updatePackage(_name),
      done: 'Updated $_name',
    );
    _after(ok);
  }

  Future<void> _remove(PackageDependencies? deps) async {
    final users = deps?.requiredBy ?? const <String>[];
    if (!await showConfirmDialog(
      context,
      title: 'Remove $_name?',
      message: users.isEmpty
          ? 'Its configuration files are kept, so reinstalling restores the setup.'
          : '${users.length} installed ${users.length == 1 ? 'package depends' : 'packages depend'} on it '
                '(${users.take(5).join(', ')}${users.length > 5 ? ', …' : ''}). apt may remove them too.',
      confirmLabel: 'Remove',
      destructive: true,
      icon: users.isEmpty ? Icons.delete_outline : Icons.warning_amber_rounded,
    )) {
      return;
    }
    if (!mounted) return;
    final ok = await runPackageCommand(
      context,
      working: 'Removing $_name…',
      call: () => ref.read(grpcServiceProvider).removePackage(_name),
      done: 'Removed $_name',
    );
    _after(ok);
  }

  void _after(bool ok) {
    if (!ok) return;
    _changed = true;
    ref.invalidate(_detailsProvider(_name));
  }

  void _openPackage(String spec) {
    // Dependency strings look like "libc6 (>= 2.34)" or "a | b"
    final name = spec.split('|').first.trim().split(RegExp(r'[\s(:]')).first;
    if (name.isEmpty) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => PackageDetailsScreen(packageName: name)));
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_detailsProvider(_name));
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.pop(context, _changed);
      },
      child: PageScaffold(
        title: _name,
        subtitle: async.valueOrNull?.$1.version,
        body: AsyncView(
          value: async,
          onRetry: () => ref.invalidate(_detailsProvider(_name)),
          loadingMessage: 'Reading package information…',
          data: (data) => _content(data.$1, data.$2),
        ),
      ),
    );
  }

  Widget _content(PackageDetails d, PackageDependencies? deps) {
    final upgradable = d.status == 'upgradable';
    return PageList(
      onRefresh: () async => ref.invalidate(_detailsProvider(_name)),
      children: [
        AppCard(
          variant: CardVariant.raised,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconBadge(
                    Icons.inventory_2_outlined,
                    tone: upgradable
                        ? Tone.warning
                        : d.installed
                        ? Tone.success
                        : Tone.neutral,
                    size: 48,
                  ),
                  const Gap(Insets.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(d.name, style: context.tt.titleLarge),
                        if (d.description.isNotEmpty)
                          Text(
                            d.description,
                            style: context.tt.bodyMedium?.copyWith(color: context.cs.onSurfaceVariant),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(Insets.md),
              Wrap(
                spacing: Insets.xs,
                runSpacing: Insets.xs,
                children: [
                  StatusPill(
                    upgradable
                        ? 'update available'
                        : d.installed
                        ? 'installed'
                        : 'not installed',
                    tone: upgradable
                        ? Tone.warning
                        : d.installed
                        ? Tone.success
                        : Tone.neutral,
                    dot: true,
                  ),
                  if (d.section.isNotEmpty) StatusPill(d.section, icon: Icons.category_outlined),
                  if (d.installedSize > 0) StatusPill(formatBytes(d.installedSize.toInt()), icon: Icons.storage),
                ],
              ),
              const Gap(Insets.lg),
              Row(
                children: [
                  if (!d.installed)
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _install,
                        icon: const Icon(Icons.download),
                        label: const Text('Install'),
                      ),
                    ),
                  if (upgradable) ...[
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _update,
                        icon: const Icon(Icons.system_update_alt),
                        label: const Text('Update'),
                      ),
                    ),
                    const Gap(Insets.sm),
                  ],
                  if (d.installed)
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(foregroundColor: context.cs.error),
                        onPressed: () => _remove(deps),
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Remove'),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        if (d.longDescription.isNotEmpty) ...[
          const SectionHeader(title: 'About'),
          AppCard(child: Text(d.longDescription.trim(), style: context.tt.bodyMedium)),
        ],
        const SectionHeader(title: 'Details'),
        AppCard(
          child: Column(
            children: [
              InfoRow('Version', d.version, mono: true),
              InfoRow('Architecture', d.architecture),
              if (d.source.isNotEmpty && d.source != d.name) InfoRow('Source package', d.source),
              if (d.maintainer.isNotEmpty) InfoRow('Maintainer', d.maintainer),
              if (d.license.isNotEmpty) InfoRow('License', d.license),
              if (d.installDate > 0)
                InfoRow(
                  'Installed',
                  DateFormat.yMMMd().format(DateTime.fromMillisecondsSinceEpoch(d.installDate.toInt() * 1000)),
                ),
            ],
          ),
        ),
        if (d.homepage.isNotEmpty) ...[
          const Gap(Insets.sm),
          TileGroup(
            children: [
              ActionTile(
                icon: Icons.open_in_new,
                title: 'Homepage',
                subtitle: d.homepage,
                onTap: () => launchUrl(Uri.parse(d.homepage), mode: LaunchMode.externalApplication),
              ),
            ],
          ),
        ],
        if (deps != null) ...[
          _deps('Depends on', Icons.call_split, deps.depends),
          _deps('Required by (installed)', Icons.merge_type, deps.requiredBy),
          _deps('Recommends', Icons.thumb_up_alt_outlined, deps.recommends),
          _deps('Suggests', Icons.lightbulb_outline, deps.suggests),
          _deps('Conflicts with', Icons.block, deps.conflicts),
        ],
      ],
    );
  }

  Widget _deps(String title, IconData icon, List<String> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title, subtitle: '${items.length}'),
        Wrap(
          spacing: Insets.xs,
          runSpacing: Insets.xs,
          children: [
            for (final dep in items.take(60))
              ActionChip(avatar: Icon(icon, size: 16), label: Text(dep), onPressed: () => _openPackage(dep)),
            if (items.length > 60) Chip(label: Text('+${items.length - 60} more')),
          ],
        ),
      ],
    );
  }
}

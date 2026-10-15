import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../generated/pi_control.pb.dart';
import '../services/docker_service.dart';
import '../ui/ui.dart';
import 'docker/container_screen.dart';

String containerName(ContainerInfo c) =>
    c.names.isNotEmpty ? c.names.first : (c.id.length > 12 ? c.id.substring(0, 12) : c.id);

Tone containerTone(String state, {String health = ''}) => switch (state) {
  _ when health == 'unhealthy' => Tone.danger,
  'running' => Tone.success,
  'paused' => Tone.warning,
  'restarting' => Tone.info,
  'dead' => Tone.danger,
  _ => Tone.neutral,
};

enum _Filter { all, running, stopped }

/// Docker: containers (grouped by compose project), images and cleanup
class DockerScreen extends ConsumerStatefulWidget {
  const DockerScreen({super.key});

  @override
  ConsumerState<DockerScreen> createState() => _DockerScreenState();
}

class _DockerScreenState extends ConsumerState<DockerScreen> with SingleTickerProviderStateMixin {
  late final _tabs = TabController(length: 2, vsync: this);
  String _query = '';
  _Filter _filter = _Filter.all;
  final _busy = <String>{};

  @override
  void initState() {
    super.initState();
    _tabs.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _run(String id, String label, Future<void> Function() action) async {
    setState(() => _busy.add(id));
    try {
      await action();
      if (mounted) showToast(context, label, tone: Tone.success);
      ref.invalidate(containerListProvider);
      ref.invalidate(dockerInfoProvider);
    } catch (e) {
      if (mounted) showToast(context, describeError(e), tone: Tone.danger);
    } finally {
      if (mounted) setState(() => _busy.remove(id));
    }
  }

  Future<void> _cleanup() async {
    final target = await showChoiceSheet<PruneTarget>(
      context,
      title: 'Clean up',
      value: PruneTarget.PRUNE_CONTAINERS,
      choices: const [
        (PruneTarget.PRUNE_CONTAINERS, 'Stopped containers'),
        (PruneTarget.PRUNE_IMAGES, 'Dangling images (untagged layers)'),
        (PruneTarget.PRUNE_ALL_IMAGES, 'All images no container uses'),
        (PruneTarget.PRUNE_VOLUMES, 'Unused anonymous volumes'),
        (PruneTarget.PRUNE_NETWORKS, 'Unused networks'),
        (PruneTarget.PRUNE_BUILD_CACHE, 'Build cache'),
      ],
    );
    if (target == null || !mounted) return;
    final what = switch (target) {
      PruneTarget.PRUNE_CONTAINERS => 'all stopped containers',
      PruneTarget.PRUNE_IMAGES => 'all dangling images',
      PruneTarget.PRUNE_ALL_IMAGES => 'every image that no container uses',
      PruneTarget.PRUNE_VOLUMES => 'unused anonymous volumes and their data',
      PruneTarget.PRUNE_NETWORKS => 'unused networks',
      _ => 'the build cache',
    };
    if (!await showConfirmDialog(
      context,
      title: 'Delete $what?',
      message: 'This cannot be undone.',
      confirmLabel: 'Delete',
      destructive: true,
    )) {
      return;
    }
    try {
      final r = await ref.read(dockerServiceProvider).prune(target);
      if (!mounted) return;
      showToast(
        context,
        '${r.message}${r.spaceReclaimed > 0 ? ' · ${formatBytes(r.spaceReclaimed.toInt())} freed' : ''}',
        tone: Tone.success,
      );
      ref
        ..invalidate(containerListProvider)
        ..invalidate(dockerImagesProvider)
        ..invalidate(dockerInfoProvider);
    } catch (e) {
      if (mounted) showToast(context, describeError(e), tone: Tone.danger);
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = ref.watch(dockerInfoProvider);
    final i = info.valueOrNull;
    final containers = ref.watch(containerListProvider);
    final all = containers.valueOrNull ?? const <ContainerInfo>[];
    final running = all.where((c) => c.state == 'running').length;

    return PageScaffold(
      title: 'Docker',
      subtitle: i == null
          ? null
          : 'Engine ${i.serverVersion} · $running of ${all.length} running · ${i.images} images',
      actions: [
        IconButton(
          tooltip: 'Refresh',
          icon: const Icon(Icons.refresh),
          onPressed: () => ref
            ..invalidate(containerListProvider)
            ..invalidate(dockerImagesProvider)
            ..invalidate(dockerInfoProvider),
        ),
        IconButton(tooltip: 'Clean up', icon: const Icon(Icons.cleaning_services_outlined), onPressed: _cleanup),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(_tabs.index == 0 ? 160 : 48),
        child: Column(
          children: [
            TabBar(
              controller: _tabs,
              tabs: [
                Tab(text: 'Containers${all.isEmpty ? '' : ' · ${all.length}'}'),
                Tab(text: 'Images${i == null ? '' : ' · ${i.images}'}'),
              ],
            ),
            if (_tabs.index == 0)
              SearchFilterBar<_Filter>(
                hint: 'Search name, image or project',
                onSearch: (v) => setState(() => _query = v),
                selected: _filter,
                onFilter: (f) => setState(() => _filter = f),
                filters: [
                  FilterOption(_Filter.all, 'All', count: all.length),
                  FilterOption(_Filter.running, 'Running', count: running),
                  FilterOption(_Filter.stopped, 'Stopped', count: all.length - running),
                ],
              ),
          ],
        ),
      ),
      body: info.hasError && all.isEmpty
          ? ErrorState(
              title: 'Docker is not available',
              error: info.error!,
              onRetry: () => ref.invalidate(dockerInfoProvider),
            )
          : TabBarView(
              controller: _tabs,
              children: [_containers(containers), const _ImagesTab()],
            ),
    );
  }

  Widget _containers(AsyncValue<List<ContainerInfo>> async) {
    return AsyncView(
      value: async,
      onRetry: () => ref.invalidate(containerListProvider),
      loadingMessage: 'Loading containers…',
      data: (all) {
        final q = _query.toLowerCase();
        final shown = all.where((c) {
          if (_filter == _Filter.running && c.state != 'running') return false;
          if (_filter == _Filter.stopped && c.state == 'running') return false;
          if (q.isEmpty) return true;
          return containerName(c).toLowerCase().contains(q) ||
              c.image.toLowerCase().contains(q) ||
              c.composeProject.toLowerCase().contains(q);
        }).toList();
        if (all.isEmpty) {
          return const EmptyState(
            icon: Icons.view_in_ar_outlined,
            title: 'No containers',
            message: 'Containers you create with docker run or docker compose show up here.',
          );
        }
        if (shown.isEmpty) return const EmptyState(icon: Icons.search_off, title: 'No containers match');

        // Compose projects first, then the rest
        final groups = <String, List<ContainerInfo>>{};
        for (final c in shown) {
          groups.putIfAbsent(c.composeProject, () => []).add(c);
        }
        final keys = groups.keys.toList()..sort((a, b) => a.isEmpty ? 1 : (b.isEmpty ? -1 : a.compareTo(b)));

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(containerListProvider),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(Insets.page, 0, Insets.page, 96),
            children: [
              for (final k in keys) ...[
                if (keys.length > 1 || k.isNotEmpty)
                  SectionHeader(
                    title: k.isEmpty ? 'Other containers' : k,
                    subtitle: k.isEmpty
                        ? null
                        : 'Compose · ${groups[k]!.where((c) => c.state == 'running').length} of ${groups[k]!.length} running',
                  ),
                for (final c in groups[k]!)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Insets.sm),
                    child: _ContainerTile(
                      container: c,
                      busy: _busy.contains(c.id),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ContainerScreen(container: c)),
                      ),
                      onToggle: () {
                        final service = ref.read(dockerServiceProvider);
                        c.state == 'running'
                            ? _run(c.id, 'Stopped ${containerName(c)}', () => service.stopContainer(c.id))
                            : c.state == 'paused'
                            ? _run(
                                c.id,
                                'Resumed ${containerName(c)}',
                                () => service.containerAction(c.id, ContainerOp.CONTAINER_UNPAUSE),
                              )
                            : _run(c.id, 'Started ${containerName(c)}', () => service.startContainer(c.id));
                      },
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ContainerTile extends StatelessWidget {
  final ContainerInfo container;
  final bool busy;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  const _ContainerTile({required this.container, required this.busy, required this.onTap, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final c = container;
    final unhealthy = c.status.contains('(unhealthy)');
    final tone = containerTone(c.state, health: unhealthy ? 'unhealthy' : '');
    final running = c.state == 'running';
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(Insets.lg, Insets.md, Insets.xs, Insets.md),
      accent: unhealthy || c.state == 'dead' ? context.cs.error : null,
      child: Row(
        children: [
          IconBadge(Icons.view_in_ar_outlined, tone: tone, size: 40),
          const Gap(Insets.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(containerName(c), style: context.tt.titleSmall, overflow: TextOverflow.ellipsis),
                Text(
                  c.image,
                  style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant),
                  overflow: TextOverflow.ellipsis,
                ),
                const Gap(Insets.xs),
                Wrap(
                  spacing: Insets.xs,
                  runSpacing: Insets.xs,
                  children: [
                    StatusPill(c.status.isEmpty ? c.state : c.status, tone: tone, dot: true),
                    for (final p in c.ports.where((p) => p.contains(':')).toSet().take(3)) StatusPill(p, icon: Icons.lan_outlined),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            width: 48,
            child: busy
                ? const Center(child: SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                : IconButton(
                    tooltip: running ? 'Stop' : (c.state == 'paused' ? 'Resume' : 'Start'),
                    icon: Icon(running ? Icons.stop : Icons.play_arrow),
                    color: running ? context.cs.error : context.ac.success,
                    onPressed: onToggle,
                  ),
          ),
        ],
      ),
    );
  }
}

class _ImagesTab extends ConsumerWidget {
  const _ImagesTab();

  Future<void> _remove(BuildContext context, WidgetRef ref, DockerImage img) async {
    final name = img.tags.isEmpty ? img.id.replaceFirst('sha256:', '').substring(0, 12) : img.tags.first;
    final inUse = img.containers > 0;
    if (!await showConfirmDialog(
      context,
      title: 'Delete $name?',
      message: inUse
          ? '${img.containers} ${img.containers == 1 ? 'container uses' : 'containers use'} this image. '
                'Deleting it forcibly untags it; the containers keep running but cannot be recreated without pulling again.'
          : 'Frees ${formatBytes(img.size.toInt())}. You can pull it again later.',
      confirmLabel: inUse ? 'Force delete' : 'Delete',
      destructive: true,
    )) {
      return;
    }
    try {
      await ref.read(dockerServiceProvider).removeImage(img.id, force: inUse);
      if (context.mounted) showToast(context, 'Deleted $name', tone: Tone.success);
      ref
        ..invalidate(dockerImagesProvider)
        ..invalidate(dockerInfoProvider);
    } catch (e) {
      if (context.mounted) showToast(context, describeError(e), tone: Tone.danger);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(dockerImagesProvider);
    return AsyncView(
      value: async,
      onRetry: () => ref.invalidate(dockerImagesProvider),
      loadingMessage: 'Loading images…',
      data: (images) {
        if (images.isEmpty) return const EmptyState(icon: Icons.layers_outlined, title: 'No images');
        final sorted = [...images]..sort((a, b) => b.size.compareTo(a.size));
        final total = images.fold<int>(0, (s, i) => s + i.size.toInt());
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(dockerImagesProvider),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(Insets.page, Insets.md, Insets.page, 96),
            children: [
              Text(
                '${images.length} images · ${formatBytes(total)} on disk',
                style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant),
              ),
              const Gap(Insets.sm),
              TileGroup(
                children: [
                  for (final img in sorted)
                    ListTile(
                      leading: IconBadge(
                        Icons.layers_outlined,
                        tone: img.containers > 0 ? Tone.primary : Tone.neutral,
                        size: 36,
                      ),
                      title: Text(
                        img.tags.isEmpty ? '<untagged>' : img.tags.join(', '),
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        [
                          formatBytes(img.size.toInt()),
                          DateFormat.yMMMd().format(DateTime.fromMillisecondsSinceEpoch(img.created.toInt() * 1000)),
                          img.containers > 0
                              ? 'used by ${img.containers}'
                              : 'unused',
                        ].join(' · '),
                      ),
                      trailing: IconButton(
                        tooltip: 'Delete image',
                        icon: Icon(Icons.delete_outline, color: context.cs.error),
                        onPressed: () => _remove(context, ref, img),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

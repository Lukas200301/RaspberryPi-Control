import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../models/file_item.dart';
import '../providers/app_providers.dart';
import '../providers/file_providers.dart';
import '../providers/settings_provider.dart';
import '../services/app_lock.dart';
import '../ui/ui.dart';
import '../widgets/file_editor_dialog.dart';
import '../widgets/file_preview_dialog.dart';
import '../services/grpc_file_transfer_service.dart';
import '../widgets/grpc_file_transfer_panel.dart';
import 'files/permissions_dialog.dart';

String _join(String dir, String name) => dir.endsWith('/') ? '$dir$name' : '$dir/$name';

String _parent(String path) {
  if (path == '/' || !path.contains('/')) return '/';
  final p = path.substring(0, path.lastIndexOf('/'));
  return p.isEmpty ? '/' : p;
}

String _modified(DateTime t) {
  final now = DateTime.now();
  if (now.difference(t).inHours < 24 && now.day == t.day) return DateFormat.Hm().format(t);
  if (t.year == now.year) return DateFormat.MMMd().format(t);
  return DateFormat.yMMMd().format(t);
}

/// Remote file browser (SFTP for listing, the agent for transfers)
class FilesScreen extends ConsumerStatefulWidget {
  const FilesScreen({super.key});

  @override
  ConsumerState<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends ConsumerState<FilesScreen> {
  final _crumbs = ScrollController();
  String _home = '/';
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(grpcFileTransferServiceProvider).addListener(_onTransfer);
    });
    // Start in the home folder once it is known (also after a reconnect)
    ref.listenManual<AsyncValue<String>>(homeDirectoryProvider, (_, next) {
      final home = next.valueOrNull;
      if (home == null || !mounted) return;
      setState(() => _home = home);
      if (ref.read(navigationHistoryProvider).isEmpty) ref.read(currentDirectoryProvider.notifier).state = home;
    }, fireImmediately: true);
    ref.listenManual(currentDirectoryProvider, (prev, next) {
      if (prev == next) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_crumbs.hasClients) {
          _crumbs.animateTo(_crumbs.position.maxScrollExtent, duration: Durations.medium2, curve: Curves.easeOut);
        }
      });
    });
  }

  void _onTransfer() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _crumbs.dispose();
    super.dispose();
  }

  // ---------------- Navigation ----------------

  void _go(String path) {
    final current = ref.read(currentDirectoryProvider);
    if (path == current) return;
    ref.read(navigationHistoryProvider.notifier).state = [...ref.read(navigationHistoryProvider), current];
    ref.read(currentDirectoryProvider.notifier).state = path;
    ref.read(selectedFilesProvider.notifier).state = {};
    ref.read(fileSearchQueryProvider.notifier).state = '';
    setState(() => _searching = false);
  }

  Future<void> _goToPath() async {
    final current = ref.read(currentDirectoryProvider);
    final path = await showTextPrompt(
      context,
      title: 'Go to folder',
      label: 'Path',
      initial: current,
      confirmLabel: 'Open',
      suggestions: {_home, '/', '/etc', '/var/log', '/opt', '/srv', '/tmp', '/media', '/mnt'}.toList(),
      validator: (v) => v.trim().startsWith('/') || v.trim().startsWith('~') ? null : 'Use an absolute path like /etc',
    );
    if (path == null) return;
    var p = path.trim();
    if (p.startsWith('~')) p = _home + p.substring(1);
    if (p.length > 1 && p.endsWith('/')) p = p.substring(0, p.length - 1);
    final sftp = ref.read(sftpServiceProvider);
    if (sftp != null && !await sftp.exists(p)) {
      if (mounted) showToast(context, '$p does not exist', tone: Tone.danger);
      return;
    }
    _go(p);
  }

  void _refresh() => ref.invalidate(fileListProvider);

  // ---------------- Selection ----------------

  Set<String> get _selected => ref.read(selectedFilesProvider);

  void _toggle(String path) {
    final s = {..._selected};
    s.contains(path) ? s.remove(path) : s.add(path);
    ref.read(selectedFilesProvider.notifier).state = s;
  }

  void _clearSelection() => ref.read(selectedFilesProvider.notifier).state = {};

  // ---------------- Operations ----------------

  Future<void> _delete(List<FileItem> items) async {
    if (items.isEmpty) return;
    final folders = items.where((f) => f.isDirectory).length;
    if (ref.read(settingsProvider).filesConfirmDelete &&
        !await showConfirmDialog(
          context,
          title: items.length == 1 ? 'Delete ${items.first.name}?' : 'Delete ${items.length} items?',
          message: folders > 0
              ? '${folders == 1 ? 'The folder is' : '$folders folders are'} deleted with everything inside. This cannot be undone.'
              : 'This cannot be undone.',
          confirmLabel: 'Delete',
          destructive: true,
        )) {
      return;
    }
    final grpc = ref.read(grpcServiceProvider);
    var failed = 0;
    String? error;
    for (final f in items) {
      try {
        final r = await grpc.deleteFile(f.path, isDirectory: f.isDirectory);
        if (!r.success) {
          failed++;
          error = r.error;
        }
      } catch (e) {
        failed++;
        error = describeError(e);
      }
    }
    _clearSelection();
    _refresh();
    if (!mounted) return;
    showToast(
      context,
      failed == 0
          ? 'Deleted ${items.length == 1 ? items.first.name : '${items.length} items'}'
          : 'Could not delete $failed of ${items.length}: $error',
      tone: failed == 0 ? Tone.success : Tone.danger,
    );
  }

  Future<void> _rename(FileItem f) async {
    final name = await showTextPrompt(
      context,
      title: 'Rename',
      label: 'New name',
      initial: f.name,
      confirmLabel: 'Rename',
      validator: (v) => v.trim().isEmpty
          ? 'Enter a name'
          : v.contains('/')
          ? 'A name cannot contain /'
          : null,
    );
    if (name == null || name.trim() == f.name) return;
    try {
      await ref.read(sftpServiceProvider)!.rename(f.path, _join(_parent(f.path), name.trim()));
      _refresh();
    } catch (e) {
      if (mounted) showToast(context, 'Rename failed: ${describeError(e)}', tone: Tone.danger);
    }
  }

  Future<void> _chmod(FileItem f) async {
    final mode = await showPermissionsDialog(context, f);
    if (mode == null) return;
    try {
      await ref.read(sftpServiceProvider)!.chmod(f.path, mode);
      _refresh();
      if (mounted) showToast(context, 'Permissions set to ${mode.toRadixString(8)}', tone: Tone.success);
    } catch (e) {
      if (mounted) showToast(context, 'Could not change permissions: ${describeError(e)}', tone: Tone.danger);
    }
  }

  Future<void> _create({required bool folder}) async {
    final name = await showTextPrompt(
      context,
      title: folder ? 'New folder' : 'New file',
      label: 'Name',
      confirmLabel: 'Create',
      validator: (v) => v.trim().isEmpty
          ? 'Enter a name'
          : v.contains('/')
          ? 'A name cannot contain /'
          : null,
    );
    if (name == null) return;
    final sftp = ref.read(sftpServiceProvider);
    if (sftp == null) return;
    final path = _join(ref.read(currentDirectoryProvider), name.trim());
    try {
      if (await sftp.exists(path)) {
        if (mounted) showToast(context, '${name.trim()} already exists', tone: Tone.warning);
        return;
      }
      folder ? await sftp.createDirectory(path) : await sftp.writeFile(path, Uint8List(0));
      _refresh();
    } catch (e) {
      if (mounted) showToast(context, 'Could not create ${name.trim()}: ${describeError(e)}', tone: Tone.danger);
    }
  }

  Future<void> _upload({required bool folder}) async {
    final lock = ref.read(appLockProvider.notifier);
    final dir = ref.read(currentDirectoryProvider);
    final transfers = ref.read(grpcFileTransferServiceProvider);
    try {
      if (folder) {
        final local = await lock.withoutLocking(() => FilePicker.getDirectoryPath(dialogTitle: 'Folder to upload'));
        if (local == null) return;
        final name = local.split(Platform.pathSeparator).last;
        await transfers.uploadDirectory(localPath: local, remotePath: _join(dir, name), onProgress: (_, _) {});
        if (mounted) showToast(context, 'Uploaded folder $name', tone: Tone.success);
      } else {
        final files = await lock.withoutLocking(() => FilePicker.pickFiles());
        if (files.isEmpty) return;
        var done = 0;
        for (final f in files) {
          if (f.path == null) continue;
          try {
            await transfers.uploadFile(localPath: f.path!, remotePath: _join(dir, f.name), onProgress: (_) {});
            done++;
          } on TransferCancelled {
            // The user stopped it
          } catch (e) {
            if (mounted) showToast(context, 'Upload of ${f.name} failed: ${describeError(e)}', tone: Tone.danger);
          }
        }
        if (mounted && done > 0) {
          showToast(context, 'Uploaded ${done == 1 ? files.first.name : '$done files'}', tone: Tone.success);
        }
      }
    } catch (e) {
      if (mounted) showToast(context, 'Upload failed: ${describeError(e)}', tone: Tone.danger);
    }
    _refresh();
  }

  Future<void> _download(List<FileItem> items) async {
    if (items.isEmpty) return;
    final target = await ref
        .read(appLockProvider.notifier)
        .withoutLocking(() => FilePicker.getDirectoryPath(dialogTitle: 'Save to'));
    if (target == null || !mounted) return;
    final transfers = ref.read(grpcFileTransferServiceProvider);
    final sftp = ref.read(sftpServiceProvider);
    var failed = 0;
    var cancelled = 0;
    Future<void> folder(String remote, String local) async {
      await Directory(local).create(recursive: true);
      for (final item in await sftp!.listDirectory(remote)) {
        final dest = '$local${Platform.pathSeparator}${item.name}';
        if (item.isDirectory) {
          await folder(item.path, dest);
        } else {
          try {
            await transfers.downloadFile(remotePath: item.path, localPath: dest, onProgress: (_) {});
          } on TransferCancelled {
            cancelled++;
          } catch (_) {
            failed++;
          }
        }
      }
    }

    for (final f in items) {
      final dest = '$target${Platform.pathSeparator}${f.name}';
      try {
        if (f.isDirectory) {
          await folder(f.path, dest);
        } else {
          await transfers.downloadFile(remotePath: f.path, localPath: dest, onProgress: (_) {});
        }
      } on TransferCancelled {
        cancelled++;
      } catch (e) {
        failed++;
      }
    }
    _clearSelection();
    if (!mounted) return;
    showToast(
      context,
      failed > 0
          ? '$failed ${failed == 1 ? 'file' : 'files'} could not be downloaded'
          : cancelled > 0
          ? 'Download cancelled'
          : 'Downloaded ${items.length == 1 ? items.first.name : '${items.length} items'}',
      tone: failed > 0 ? Tone.warning : (cancelled > 0 ? Tone.neutral : Tone.success),
    );
  }

  void _open(FileItem f) {
    if (f.isDirectory) {
      _go(f.path);
    } else {
      showDialog(context: context, builder: (_) => FilePreviewDialog(file: f));
    }
  }

  void _actions(FileItem f) {
    showActionSheet(
      context,
      title: f.name,
      subtitle: [
        if (!f.isDirectory) f.formattedSize,
        f.permissionsString,
        if (f.owner.isNotEmpty && f.owner != 'unknown') '${f.owner}:${f.group}',
        _modified(f.modified),
      ].join(' · '),
      actions: [
        SheetAction(
          icon: f.isDirectory ? Icons.folder_open : Icons.visibility_outlined,
          label: f.isDirectory ? 'Open' : 'Preview',
          onTap: () => _open(f),
        ),
        if (!f.isDirectory && f.isEditable)
          SheetAction(
            icon: Icons.edit_note,
            label: 'Edit',
            onTap: () async {
              await showDialog(context: context, builder: (_) => FileEditorDialog(file: f));
              _refresh();
            },
          ),
        SheetAction(icon: Icons.download_outlined, label: 'Download', tone: Tone.info, onTap: () => _download([f])),
        SheetAction(icon: Icons.drive_file_rename_outline, label: 'Rename', onTap: () => _rename(f)),
        SheetAction(icon: Icons.lock_outline, label: 'Permissions (${f.permissionsOctal})', onTap: () => _chmod(f)),
        SheetAction(
          icon: Icons.copy,
          label: 'Copy path',
          tone: Tone.neutral,
          onTap: () {
            Clipboard.setData(ClipboardData(text: f.path));
            showToast(context, 'Path copied');
          },
        ),
        SheetAction(icon: Icons.delete_outline, label: 'Delete', destructive: true, onTap: () => _delete([f])),
      ],
    );
  }

  void _newSheet() {
    showActionSheet(
      context,
      title: 'Add to this folder',
      subtitle: ref.read(currentDirectoryProvider),
      actions: [
        SheetAction(icon: Icons.upload_file, label: 'Upload files', onTap: () => _upload(folder: false)),
        SheetAction(icon: Icons.drive_folder_upload, label: 'Upload a folder', onTap: () => _upload(folder: true)),
        SheetAction(
          icon: Icons.create_new_folder_outlined,
          label: 'New folder',
          tone: Tone.success,
          onTap: () => _create(folder: true),
        ),
        SheetAction(icon: Icons.note_add_outlined, label: 'New empty file', tone: Tone.success, onTap: () => _create(folder: false)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final path = ref.watch(currentDirectoryProvider);
    final selected = ref.watch(selectedFilesProvider);
    final showHidden = ref.watch(settingsProvider.select((s) => s.filesShowHidden));
    final sort = ref.watch(fileSortProvider);
    final async = ref.watch(filteredFileListProvider);
    final all = async.valueOrNull ?? const <FileItem>[];
    final files = showHidden ? all : all.where((f) => !f.name.startsWith('.')).toList();
    final hidden = all.length - files.length;
    final selecting = selected.isNotEmpty;
    final selectedItems = files.where((f) => selected.contains(f.path)).toList();

    return PageScaffold(
      title: selecting ? '${selected.length} selected' : 'Files',
      subtitle: selecting ? null : path,
      automaticallyImplyLeading: false,
      leading: selecting
          ? IconButton(tooltip: 'Cancel selection', icon: const Icon(Icons.close), onPressed: _clearSelection)
          : null,
      actions: selecting
          ? [
              IconButton(
                tooltip: 'Select all',
                icon: const Icon(Icons.select_all),
                onPressed: () => ref.read(selectedFilesProvider.notifier).state = files.map((f) => f.path).toSet(),
              ),
              IconButton(
                tooltip: 'Download',
                icon: const Icon(Icons.download_outlined),
                onPressed: () => _download(selectedItems),
              ),
              IconButton(
                tooltip: 'Delete',
                icon: Icon(Icons.delete_outline, color: context.cs.error),
                onPressed: () => _delete(selectedItems),
              ),
            ]
          : [
              IconButton(
                tooltip: 'Search this folder',
                isSelected: _searching,
                icon: const Icon(Icons.search),
                onPressed: () {
                  setState(() => _searching = !_searching);
                  if (!_searching) ref.read(fileSearchQueryProvider.notifier).state = '';
                },
              ),
              PopupMenuButton<Object>(
                tooltip: 'View',
                icon: const Icon(Icons.sort),
                onSelected: (v) {
                  if (v is FileSortOption) ref.read(fileSortProvider.notifier).state = v;
                  if (v == 'hidden') {
                    ref.read(settingsProvider.notifier).update((s) => s.copyWith(filesShowHidden: !showHidden));
                  }
                  if (v == 'goto') _goToPath();
                },
                itemBuilder: (_) => [
                  for (final o in const [
                    (FileSortOption.nameAsc, 'Name A–Z'),
                    (FileSortOption.nameDesc, 'Name Z–A'),
                    (FileSortOption.dateDesc, 'Newest first'),
                    (FileSortOption.dateAsc, 'Oldest first'),
                    (FileSortOption.sizeDesc, 'Largest first'),
                    (FileSortOption.sizeAsc, 'Smallest first'),
                    (FileSortOption.typeAsc, 'Type'),
                  ])
                    CheckedPopupMenuItem(value: o.$1, checked: sort == o.$1, child: Text(o.$2)),
                  const PopupMenuDivider(),
                  CheckedPopupMenuItem(value: 'hidden', checked: showHidden, child: const Text('Show hidden files')),
                  const PopupMenuItem(
                    value: 'goto',
                    child: ListTile(leading: Icon(Icons.drive_folder_upload_outlined), title: Text('Go to path…')),
                  ),
                ],
              ),
            ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(_searching ? 112 : 52),
        child: Column(
          children: [
            _PathBar(
              path: path,
              home: _home,
              controller: _crumbs,
              onGo: _go,
              onUp: path == '/' ? null : () => _go(_parent(path)),
              onEdit: _goToPath,
            ),
            if (_searching)
              Padding(
                padding: const EdgeInsets.fromLTRB(Insets.page, Insets.xs, Insets.page, Insets.sm),
                child: SearchField(
                  hint: 'Filter this folder',
                  autofocus: true,
                  onChanged: (v) => ref.read(fileSearchQueryProvider.notifier).state = v,
                ),
              ),
          ],
        ),
      ),
      bottomBar: const GrpcFileTransferPanel(),
      floatingActionButton: selecting
          ? null
          : FloatingActionButton.extended(onPressed: _newSheet, icon: const Icon(Icons.add), label: const Text('New')),
      body: Column(
        children: [
          Expanded(
            child: async.when(
              loading: () => const LoadingState(message: 'Reading folder…'),
              error: (e, _) => ErrorState(
                title: 'This folder cannot be opened',
                error: e,
                onRetry: _refresh,
              ),
              data: (_) => files.isEmpty
                  ? EmptyState(
                      icon: Icons.folder_open,
                      title: ref.read(fileSearchQueryProvider).isNotEmpty ? 'Nothing matches' : 'This folder is empty',
                      message: hidden > 0 ? '$hidden hidden ${hidden == 1 ? 'item' : 'items'}. Show them from the sort menu.' : null,
                    )
                  : RefreshIndicator(
                      onRefresh: () async => _refresh(),
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(Insets.page, Insets.xs, Insets.page, 96),
                        itemCount: files.length + (hidden > 0 ? 1 : 0),
                        itemBuilder: (context, i) {
                          if (i == files.length) {
                            return Padding(
                              padding: const EdgeInsets.all(Insets.md),
                              child: Text(
                                '$hidden hidden ${hidden == 1 ? 'item' : 'items'}',
                                textAlign: TextAlign.center,
                                style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant),
                              ),
                            );
                          }
                          final f = files[i];
                          final isSelected = selected.contains(f.path);
                          return _FileTile(
                            file: f,
                            selected: isSelected,
                            selecting: selecting,
                            onTap: () => selecting ? _toggle(f.path) : _open(f),
                            onLongPress: () => _toggle(f.path),
                            onMore: () => _actions(f),
                          );
                        },
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PathBar extends StatelessWidget {
  final String path;
  final String home;
  final ScrollController controller;
  final ValueChanged<String> onGo;
  final VoidCallback? onUp;
  final VoidCallback onEdit;

  const _PathBar({
    required this.path,
    required this.home,
    required this.controller,
    required this.onGo,
    required this.onUp,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final parts = path.split('/').where((p) => p.isNotEmpty).toList();
    return SizedBox(
      height: 52,
      child: Row(
        children: [
          const Gap(Insets.sm),
          IconButton(tooltip: 'Up one folder', icon: const Icon(Icons.arrow_upward), onPressed: onUp),
          IconButton(
            tooltip: 'Home folder',
            icon: const Icon(Icons.home_outlined),
            isSelected: path == home,
            selectedIcon: const Icon(Icons.home),
            onPressed: () => onGo(home),
          ),
          Expanded(
            child: ListView(
              controller: controller,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(vertical: Insets.sm),
              children: [
                ActionChip(label: const Text('/'), onPressed: () => onGo('/')),
                for (var i = 0; i < parts.length; i++) ...[
                  Icon(Icons.chevron_right, size: 18, color: context.cs.onSurfaceVariant),
                  i == parts.length - 1
                      ? Chip(
                          label: Text(parts[i]),
                          backgroundColor: context.cs.secondaryContainer,
                          side: BorderSide.none,
                        )
                      : ActionChip(
                          label: Text(parts[i]),
                          onPressed: () => onGo('/${parts.sublist(0, i + 1).join('/')}'),
                        ),
                ],
                const Gap(Insets.md),
              ],
            ),
          ),
          IconButton(tooltip: 'Type a path', icon: const Icon(Icons.edit_location_alt_outlined), onPressed: onEdit),
          const Gap(Insets.xs),
        ],
      ),
    );
  }
}

class _FileTile extends StatelessWidget {
  final FileItem file;
  final bool selected;
  final bool selecting;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onMore;

  const _FileTile({
    required this.file,
    required this.selected,
    required this.selecting,
    required this.onTap,
    required this.onLongPress,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    final f = file;
    final hidden = f.name.startsWith('.');
    return Padding(
      padding: const EdgeInsets.only(bottom: Insets.xs),
      child: Material(
        color: selected ? context.cs.secondaryContainer : context.cs.surfaceContainer,
        borderRadius: Radii.mdAll,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Insets.md, Insets.sm, Insets.xs, Insets.sm),
            child: Row(
              children: [
                if (selecting)
                  Padding(
                    padding: const EdgeInsets.only(right: Insets.sm),
                    child: Icon(
                      selected ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: selected ? context.cs.primary : context.cs.onSurfaceVariant,
                    ),
                  ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (f.isDirectory ? context.cs.primary : f.color).withValues(alpha: 0.14),
                    borderRadius: Radii.smAll,
                  ),
                  child: Icon(f.icon, color: f.isDirectory ? context.cs.primary : f.color, size: 22),
                ),
                const Gap(Insets.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        f.name,
                        style: context.tt.titleSmall?.copyWith(
                          color: hidden ? context.cs.onSurfaceVariant : null,
                          fontWeight: selected ? FontWeight.w700 : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        [
                          if (!f.isDirectory) f.formattedSize,
                          _modified(f.modified),
                          f.permissionsString,
                        ].join(' · '),
                        style: context.tt.bodySmall?.copyWith(
                          color: context.cs.onSurfaceVariant,
                          fontFeatures: tabularFigures,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (!selecting) IconButton(tooltip: 'More', icon: const Icon(Icons.more_vert), onPressed: onMore),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

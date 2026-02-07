import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../models/file_item.dart';
import '../providers/file_providers.dart';
import '../providers/app_providers.dart';
import '../widgets/file_operation_dialog.dart';
import '../widgets/file_preview_dialog.dart';
import '../widgets/grpc_file_transfer_panel.dart';

class FilesScreen extends ConsumerStatefulWidget {
  const FilesScreen({super.key});

  @override
  ConsumerState<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends ConsumerState<FilesScreen> {
  final _searchController = TextEditingController();
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();

    // Listen to gRPC file transfer updates for UI rebuilds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final transferService = ref.read(grpcFileTransferServiceProvider);
      transferService.addListener(() {
        if (mounted) setState(() {});
      });
    });

    // Initialize home directory
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final sftp = ref.read(sftpServiceProvider);
      if (sftp != null) {
        try {
          final homeDir = await sftp.getHomeDirectory();
          ref.read(currentDirectoryProvider.notifier).state = homeDir;
        } catch (e) {
          // Default to /home if can't get home directory
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToDirectory(String path) {
    final currentPath = ref.read(currentDirectoryProvider);
    final history = ref.read(navigationHistoryProvider);
    
    // Add current path to history
    ref.read(navigationHistoryProvider.notifier).state = [...history, currentPath];
    
    // Navigate to new path
    ref.read(currentDirectoryProvider.notifier).state = path;
    
    // Clear selection
    ref.read(selectedFilesProvider.notifier).state = {};
    _isSelectionMode = false;
  }

  void _navigateBack() {
    final history = ref.read(navigationHistoryProvider);
    if (history.isEmpty) return;

    final previousPath = history.last;
    ref.read(navigationHistoryProvider.notifier).state = 
        history.sublist(0, history.length - 1);
    ref.read(currentDirectoryProvider.notifier).state = previousPath;
    
    // Clear selection
    ref.read(selectedFilesProvider.notifier).state = {};
    _isSelectionMode = false;
  }

  void _navigateUp() {
    final currentPath = ref.read(currentDirectoryProvider);
    if (currentPath == '/') return;

    final parts = currentPath.split('/');
    parts.removeLast();
    final parentPath = parts.isEmpty ? '/' : parts.join('/');
    
    _navigateToDirectory(parentPath.isEmpty ? '/' : parentPath);
  }

  Future<void> _uploadFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(allowMultiple: true);
      if (result == null || result.files.isEmpty) return;

      final currentPath = ref.read(currentDirectoryProvider);
      final transferService = ref.read(grpcFileTransferServiceProvider);

      for (final file in result.files) {
        if (file.path == null) continue;

        final remotePath = currentPath.endsWith('/')
            ? '$currentPath${file.name}'
            : '$currentPath/${file.name}';

        try {
          await transferService.uploadFile(
            localPath: file.path!,
            remotePath: remotePath,
            onProgress: (progress) {
              // Progress is automatically tracked in the service
            },
          );
        } catch (e) {
          debugPrint('Upload failed for ${file.name}: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Upload failed for ${file.name}: $e', 
                    style: const TextStyle(color: Colors.white)),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Uploaded ${result.files.length} file(s) successfully', 
                style: const TextStyle(color: Colors.black)),
            backgroundColor: Colors.green.shade700,
          ),
        );
      }

      // Refresh file list
      ref.invalidate(fileListProvider);
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e', 
                style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadFolder() async {
    try {
      final currentPath = ref.read(currentDirectoryProvider);

      // Pick folder
      final folderPath = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Select folder to upload',
      );

      if (folderPath == null) return;

      final folderName = folderPath.split(Platform.pathSeparator).last;
      final remotePath = '$currentPath/$folderName';

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Uploading folder $folderName...', 
                style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.blue.shade700,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      final transferService = ref.read(grpcFileTransferServiceProvider);

      await transferService.uploadDirectory(
        localPath: folderPath,
        remotePath: remotePath,
        onProgress: (filename, progress) {
          debugPrint('$filename: ${progress.toStringAsFixed(1)}%');
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Folder "$folderName" uploaded successfully!', 
                style: const TextStyle(color: Colors.black)),
            backgroundColor: Colors.green.shade700,
          ),
        );
      }

      ref.invalidate(fileListProvider);
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e', 
                style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _downloadFile(FileItem file) async {
    if (file.isDirectory) {
      // For directories, use the folder download function
      await _downloadFolder(file);
      return;
    }

    try {
      // On mobile platforms, we need to handle downloads differently
      final transferService = ref.read(grpcFileTransferServiceProvider);
      
      // For mobile: use getDirectoryPath to let user pick download folder
      final downloadFolder = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Select download location',
      );

      if (downloadFolder == null) {
        // User cancelled
        return;
      }

      // Build the full local path
      final localPath = '$downloadFolder${Platform.pathSeparator}${file.name}';

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Downloading ${file.name}...', 
                style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.blue.shade700,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      await transferService.downloadFile(
        remotePath: file.path,
        localPath: localPath,
        onProgress: (progress) {
          // Progress is automatically tracked in the service
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File saved successfully!', 
                style: const TextStyle(color: Colors.black)),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: $e', 
                style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _downloadFolder(FileItem folder) async {
    try {
      // Let user pick a destination folder
      final destinationPath = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Select destination for "${folder.name}"',
      );

      if (destinationPath == null) {
        // User cancelled
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Downloading folder "${folder.name}"...', 
                style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.blue.shade700,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      final sftp = ref.read(sftpServiceProvider);
      final transferService = ref.read(grpcFileTransferServiceProvider);

      if (sftp == null) {
        throw Exception('SFTP not available');
      }

      // Recursively download all files in the folder
      await _downloadFolderRecursive(
        sftp: sftp,
        transferService: transferService,
        remotePath: folder.path,
        localBasePath: destinationPath,
        folderName: folder.name,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Folder "${folder.name}" downloaded successfully!', 
                style: const TextStyle(color: Colors.black)),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Folder download failed: $e', 
                style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _downloadFolderRecursive({
    required dynamic sftp,
    required dynamic transferService,
    required String remotePath,
    required String localBasePath,
    required String folderName,
  }) async {
    // Create the folder structure locally
    final localFolderPath = '$localBasePath${Platform.pathSeparator}$folderName';
    final localDir = Directory(localFolderPath);
    
    if (!await localDir.exists()) {
      await localDir.create(recursive: true);
    }

    // List all items in the remote directory
    final items = await sftp.listDirectory(remotePath);

    for (final item in items) {
      if (item.isDirectory) {
        // Recursively download subdirectories
        await _downloadFolderRecursive(
          sftp: sftp,
          transferService: transferService,
          remotePath: item.path,
          localBasePath: localFolderPath,
          folderName: item.name,
        );
      } else {
        // Download file via gRPC
        final localFilePath = '$localFolderPath${Platform.pathSeparator}${item.name}';
        
        try {
          await transferService.downloadFile(
            remotePath: item.path,
            localPath: localFilePath,
            onProgress: (progress) {
              // Progress is automatically tracked in the service
            },
          );
          debugPrint('Downloaded: ${item.path} -> $localFilePath');
        } catch (e) {
          debugPrint('Failed to download ${item.path}: $e');
          // Continue with other files even if one fails
        }
      }
    }
  }

  void _toggleSelection(String path) {
    final selected = ref.read(selectedFilesProvider);
    final newSelected = Set<String>.from(selected);
    
    if (newSelected.contains(path)) {
      newSelected.remove(path);
    } else {
      newSelected.add(path);
    }
    
    ref.read(selectedFilesProvider.notifier).state = newSelected;
    setState(() {
      _isSelectionMode = newSelected.isNotEmpty;
    });
  }

  void _selectAll(List<FileItem> files) {
    ref.read(selectedFilesProvider.notifier).state = 
        files.map((f) => f.path).toSet();
    setState(() {
      _isSelectionMode = true;
    });
  }

  void _clearSelection() {
    ref.read(selectedFilesProvider.notifier).state = {};
    setState(() {
      _isSelectionMode = false;
    });
  }

  Future<void> _deleteSelected() async {
    final selected = ref.read(selectedFilesProvider);
    if (selected.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          title: const Text('Delete Files'),
          content: Text('Delete ${selected.length} item(s)?'),
          actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
        ),
      ),
    );

    if (confirmed != true) return;

    final grpcService = ref.read(grpcServiceProvider);
    if (grpcService == null) return;

    final fileList = await ref.read(fileListProvider.future);
    final filesToDelete = fileList.where((f) => selected.contains(f.path)).toList();

    for (final file in filesToDelete) {
      try {
        final response = await grpcService.deleteFile(file.path, isDirectory: file.isDirectory);
        if (!response.success) {
          throw Exception(response.error);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete ${file.name}: $e', style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      }
    }

    _clearSelection();
    ref.invalidate(fileListProvider);
  }

  @override
  Widget build(BuildContext context) {
    final currentPath = ref.watch(currentDirectoryProvider);
    final fileListAsync = ref.watch(filteredFileListProvider);
    final selectedFiles = ref.watch(selectedFilesProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSelectionMode
            ? Text('${selectedFiles.length} selected')
            : const Text('File Explorer'),
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _clearSelection,
              )
            : null,
        actions: _isSelectionMode
            ? [
                IconButton(
                  icon: const Icon(Icons.select_all),
                  onPressed: () {
                    fileListAsync.whenData((files) => _selectAll(files));
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _deleteSelected,
                ),
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => ref.invalidate(fileListProvider),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.sort),
                  onSelected: (value) {
                    final sortOption = FileSortOption.values.firstWhere(
                      (e) => e.toString() == value,
                    );
                    ref.read(fileSortProvider.notifier).state = sortOption;
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'FileSortOption.nameAsc',
                      child: Text('Name (A-Z)'),
                    ),
                    const PopupMenuItem(
                      value: 'FileSortOption.nameDesc',
                      child: Text('Name (Z-A)'),
                    ),
                    const PopupMenuItem(
                      value: 'FileSortOption.sizeAsc',
                      child: Text('Size (Smallest)'),
                    ),
                    const PopupMenuItem(
                      value: 'FileSortOption.sizeDesc',
                      child: Text('Size (Largest)'),
                    ),
                    const PopupMenuItem(
                      value: 'FileSortOption.dateAsc',
                      child: Text('Date (Oldest)'),
                    ),
                    const PopupMenuItem(
                      value: 'FileSortOption.dateDesc',
                      child: Text('Date (Newest)'),
                    ),
                  ],
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'New',
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'upload',
                      child: Row(
                        children: [
                          Icon(Icons.upload_file),
                          SizedBox(width: 8),
                          Text('Upload File'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'uploadFolder',
                      child: Row(
                        children: [
                          Icon(Icons.drive_folder_upload),
                          SizedBox(width: 8),
                          Text('Upload Folder'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'folder',
                      child: Row(
                        children: [
                          Icon(Icons.create_new_folder),
                          SizedBox(width: 8),
                          Text('New Folder'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'upload') {
                      _uploadFile();
                    } else if (value == 'uploadFolder') {
                      _uploadFolder();
                    } else if (value == 'folder') {
                      _showCreateFolderDialog();
                    }
                  },
                ),
              ],
      ),
      body: Column(
        children: [
          // Breadcrumb navigation
          _buildBreadcrumb(currentPath),
          
          // Search bar
          _buildSearchBar(),
          
          // File list
          Expanded(
            child: fileListAsync.when(
              data: (files) => files.isEmpty
                  ? _buildEmptyState()
                  : _buildFileList(files, selectedFiles),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _buildErrorState(error.toString()),
            ),
          ),

          // gRPC Transfer panel (auto-shows when there are active transfers)
          const GrpcFileTransferPanel(),
        ],
      ),
    );
  }

  Widget _buildBreadcrumb(String path) {
    final parts = path.split('/').where((p) => p.isNotEmpty).toList();
    
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GlassCard(
        child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: ref.read(navigationHistoryProvider).isEmpty 
                  ? null 
                  : _navigateBack,
            ),
            IconButton(
              icon: const Icon(Icons.arrow_upward),
              onPressed: path == '/' ? null : _navigateUp,
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              icon: const Icon(Icons.home, size: 18),
              label: const Text('/'),
              onPressed: () => _navigateToDirectory('/'),
            ),
            ...parts.asMap().entries.map((entry) {
              final index = entry.key;
              final part = entry.value;
              final pathUpTo = '/${parts.sublist(0, index + 1).join('/')}';
              
              return Row(
                children: [
                  const Icon(Icons.chevron_right, size: 16),
                  TextButton(
                    onPressed: () => _navigateToDirectory(pathUpTo),
                    child: Text(part),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search files...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(fileSearchQueryProvider.notifier).state = '';
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (value) {
          ref.read(fileSearchQueryProvider.notifier).state = value;
        },
      ),
    );
  }

  Widget _buildFileList(List<FileItem> files, Set<String> selectedFiles) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index];
        final isSelected = selectedFiles.contains(file.path);
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GlassCard(
            child: ListTile(
            leading: _isSelectionMode
                ? Checkbox(
                    value: isSelected,
                    onChanged: (_) => _toggleSelection(file.path),
                  )
                : Icon(file.icon, color: file.color),
            title: Text(
              file.name,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Text(
              '${file.formattedSize} • ${file.permissionsString}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _showFileOptions(file),
            ),
            onTap: () {
              if (_isSelectionMode) {
                _toggleSelection(file.path);
              } else if (file.isDirectory) {
                _navigateToDirectory(file.path);
              } else {
                _showFilePreview(file);
              }
            },
            onLongPress: () {
              if (!_isSelectionMode) {
                _toggleSelection(file.path);
              }
            },
          ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 64,
            color: AppTheme.primaryIndigo.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No files in this directory',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error loading files',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.invalidate(fileListProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showFileOptions(FileItem file) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      isScrollControlled: true,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: FileOperationDialog(
        file: file,
        onDownload: () => _downloadFile(file),
        onDelete: () async {
          final grpcService = ref.read(grpcServiceProvider);
          if (grpcService != null) {
            final response = await grpcService.deleteFile(file.path, isDirectory: file.isDirectory);
            if (response.success) {
              ref.invalidate(fileListProvider);
            } else {
              debugPrint('Delete failed: ${response.error}');
            }
          }
        },
        onRename: (newName) async {
          final sftp = ref.read(sftpServiceProvider);
          if (sftp != null) {
            final newPath = file.path.substring(0, file.path.lastIndexOf('/') + 1) + newName;
            await sftp.rename(file.path, newPath);
            ref.invalidate(fileListProvider);
          }
        },
        onChmod: (permissions) async {
          final sftp = ref.read(sftpServiceProvider);
          if (sftp != null) {
            await sftp.chmod(file.path, permissions);
            ref.invalidate(fileListProvider);
          }
        },
        ),
      ),
    );
  }

  void _showFilePreview(FileItem file) {
    showDialog(
      context: context,
      builder: (context) => FilePreviewDialog(file: file),
    );
  }

  Future<void> _showCreateFolderDialog() async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          title: const Text('Create Folder'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Folder name',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                Navigator.pop(context, value);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  Navigator.pop(context, controller.text);
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );

    if (result != null && result.isNotEmpty) {
      final sftp = ref.read(sftpServiceProvider);
      if (sftp == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Not connected to server', style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final currentPath = ref.read(currentDirectoryProvider);
      final newPath = currentPath.endsWith('/')
          ? '$currentPath$result'
          : '$currentPath/$result';

      try {
        await sftp.createDirectory(newPath);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Folder "$result" created successfully', style: TextStyle(color: Colors.black)),
              backgroundColor: Colors.green.shade700,
            ),
          );
        }

        // Refresh file list
        ref.invalidate(fileListProvider);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create folder: $e', style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.red.shade700,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }
}

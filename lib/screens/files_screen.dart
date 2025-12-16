import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../models/file_item.dart';
import '../providers/file_providers.dart';
import '../providers/app_providers.dart';
import '../widgets/file_operation_dialog.dart';
import '../widgets/file_preview_dialog.dart';
import '../widgets/file_transfer_panel.dart';
import '../services/transfer_service.dart';
import '../services/transfer_manager_service.dart';

class FilesScreen extends ConsumerStatefulWidget {
  const FilesScreen({super.key});

  @override
  ConsumerState<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends ConsumerState<FilesScreen> {
  final _searchController = TextEditingController();
  final _transferService = TransferService();
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();

    // Initialize transfer service
    _transferService.initialize();
    _transferService.addListener(_handleTransferEvent);

    // Start and connect transfer service
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        // First, initialize the background service
        debugPrint('Files Screen: Initializing TransferManagerService...');
        await TransferManagerService.initialize();
        
        // Check if service is running
        final service = FlutterBackgroundService();
        bool isRunning = await service.isRunning();
        debugPrint('Files Screen: Service running before restart: $isRunning');
        
        if (isRunning) {
          // Force stop to ensure clean state
          debugPrint('Files Screen: Force stopping service...');
          await TransferManagerService.stop();
          await Future.delayed(const Duration(seconds: 1));
          
          isRunning = await service.isRunning();
          debugPrint('Files Screen: Service running after stop: $isRunning');
        }
        
        // Start the background service fresh
        debugPrint('Files Screen: Starting TransferManagerService...');
        await service.startService();
        
        // Wait for service to start and initialize
        await Future.delayed(const Duration(seconds: 2));
        
        isRunning = await service.isRunning();
        debugPrint('Files Screen: Service running after start: $isRunning');
        
        // Connect to SSH
        final connection = ref.read(currentConnectionProvider);
        if (connection != null) {
          debugPrint('Files Screen: Connecting transfer service to SSH...');
          _transferService.connect(
            host: connection.host,
            port: connection.port,
            username: connection.username,
            password: connection.password,
          );
          
          // Wait for connection to establish
          await Future.delayed(const Duration(seconds: 2));
          debugPrint('Files Screen: Transfer service setup complete');
        }
      } catch (e) {
        debugPrint('Files Screen: Error setting up transfer service: $e');
      }
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
    _transferService.removeListener(_handleTransferEvent);
    _transferService.dispose();
    super.dispose();
  }

  void _handleTransferEvent(String type, Map<String, dynamic>? data) {
    if (!mounted) return;

    switch (type) {
      case 'uploadFolderComplete':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Folder uploaded successfully!', style: TextStyle(color: Colors.black)),
            backgroundColor: Colors.green.shade700,
          ),
        );
        ref.invalidate(fileListProvider);
        break;

      case 'uploadFolderFailed':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: ${data?['error']}', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
          ),
        );
        break;

      case 'folderComplete':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Folder downloaded successfully!', style: TextStyle(color: Colors.black)),
            backgroundColor: Colors.green.shade700,
          ),
        );
        break;

      case 'folderFailed':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: ${data?['error']}', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
          ),
        );
        break;
    }
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
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null) return;

    final sftp = ref.read(sftpServiceProvider);
    if (sftp == null) return;

    final currentPath = ref.read(currentDirectoryProvider);

    for (final file in result.files) {
      if (file.path == null) continue;

      final transferId = DateTime.now().millisecondsSinceEpoch.toString();
      final remotePath = currentPath.endsWith('/')
          ? '$currentPath${file.name}'
          : '$currentPath/${file.name}';

      // Add transfer to list
      ref.read(fileTransfersProvider.notifier).addTransfer(FileTransfer(
        id: transferId,
        fileName: file.name,
        localPath: file.path!,
        remotePath: remotePath,
        isUpload: true,
        totalSize: file.size,
      ));

      // Start upload
      try {
        ref.read(fileTransfersProvider.notifier).updateTransfer(
          transferId,
          status: FileTransferStatus.transferring,
        );

        final fileBytes = await File(file.path!).readAsBytes();

        await sftp.uploadFile(
          localPath: file.path!,
          remotePath: remotePath,
          data: fileBytes,
          onProgress: (sent, total) {
            ref.read(fileTransfersProvider.notifier).updateTransfer(
              transferId,
              transferredSize: sent,
            );
          },
        );

        ref.read(fileTransfersProvider.notifier).updateTransfer(
          transferId,
          status: FileTransferStatus.completed,
        );

        // Refresh file list
        ref.invalidate(fileListProvider);
      } catch (e) {
        ref.read(fileTransfersProvider.notifier).updateTransfer(
          transferId,
          status: FileTransferStatus.failed,
          error: e.toString(),
        );
      }
    }
  }

  Future<void> _uploadFolder() async {
    final sftp = ref.read(sftpServiceProvider);
    if (sftp == null) return;

    final currentPath = ref.read(currentDirectoryProvider);

    // Pick folder
    final folderPath = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select folder to upload',
    );

    if (folderPath == null) return;

    final folderName = folderPath.split(Platform.pathSeparator).last;
    final remotePath = '$currentPath/$folderName';
    final transferId = DateTime.now().millisecondsSinceEpoch.toString();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Counting files in $folderName...', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blue.shade700,
          duration: const Duration(seconds: 1),
        ),
      );
    }

    try {
      // Count total files
      final totalFiles = await _countLocalFiles(folderPath);
      debugPrint('Total files to upload: $totalFiles');
      
      // Add transfer to list
      ref.read(fileTransfersProvider.notifier).addTransfer(FileTransfer(
        id: transferId,
        fileName: folderName,
        localPath: folderPath,
        remotePath: remotePath,
        isUpload: true,
        totalSize: totalFiles,
        transferredSize: 0,
        isFolderTransfer: true,
      ));

      ref.read(fileTransfersProvider.notifier).updateTransfer(
        transferId,
        status: FileTransferStatus.transferring,
      );
      
      // Upload with progress tracking
      int processedFiles = 0;
      await _uploadFolderRecursive(
        folderPath, 
        remotePath, 
        sftp,
        onFileUploaded: () {
          processedFiles++;
          ref.read(fileTransfersProvider.notifier).updateTransfer(
            transferId,
            transferredSize: processedFiles,
          );
        },
      );
      
      ref.read(fileTransfersProvider.notifier).updateTransfer(
        transferId,
        status: FileTransferStatus.completed,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Folder uploaded successfully!', style: TextStyle(color: Colors.black)),
            backgroundColor: Colors.green.shade700,
          ),
        );
      }
      
      ref.invalidate(fileListProvider);
    } catch (e) {
      ref.read(fileTransfersProvider.notifier).updateTransfer(
        transferId,
        status: FileTransferStatus.failed,
        error: e.toString(),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<int> _countLocalFiles(String localPath) async {
    int count = 0;
    final localDir = Directory(localPath);
    final items = await localDir.list().toList();
    
    for (final item in items) {
      if (item is Directory) {
        count += await _countLocalFiles(item.path);
      } else if (item is File) {
        count++;
      }
    }
    
    return count;
  }

  Future<void> _uploadFolderRecursive(
    String localPath, 
    String remotePath, 
    dynamic sftp,
    {Function()? onFileUploaded}
  ) async {
    // Create remote directory
    try {
      await sftp.createDirectory(remotePath);
    } catch (e) {
      // Directory might already exist
      debugPrint('Directory exists or error: $e');
    }

    // List local directory
    final localDir = Directory(localPath);
    final items = await localDir.list().toList();

    for (final item in items) {
      final itemName = item.path.split(Platform.pathSeparator).last;
      final itemRemotePath = '$remotePath/$itemName';

      if (item is Directory) {
        // Recursively upload subdirectory
        await _uploadFolderRecursive(item.path, itemRemotePath, sftp, onFileUploaded: onFileUploaded);
      } else if (item is File) {
        // Upload file
        final fileBytes = await item.readAsBytes();
        await sftp.uploadFile(
          localPath: item.path,
          remotePath: itemRemotePath,
          data: fileBytes,
        );
        
        // Call progress callback
        onFileUploaded?.call();
      }
    }
  }

  Future<void> _downloadFile(FileItem file) async {
    final sftp = ref.read(sftpServiceProvider);
    if (sftp == null) return;

    if (file.isDirectory) {
      // For directories, use the folder download function
      await _downloadFolder(file);
      return;
    }

    // First, download the file data from the remote server
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Downloading ${file.name}...', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blue.shade700,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    try {
      // Download file data from remote server
      final data = await sftp.downloadFile(
        remotePath: file.path,
        onProgress: (received, total) {
          // Could update a progress indicator here
        },
      );

      // Let user choose where to save the file using the system file picker
      String? outputPath;

      if (Platform.isAndroid || Platform.isIOS) {
        // For mobile, use FilePicker to save the file
        outputPath = await FilePicker.platform.saveFile(
          dialogTitle: 'Save ${file.name}',
          fileName: file.name,
          bytes: data,
        );
      } else {
        // For desktop, let user choose location
        outputPath = await FilePicker.platform.saveFile(
          dialogTitle: 'Save ${file.name}',
          fileName: file.name,
        );

        if (outputPath != null) {
          await File(outputPath).writeAsBytes(data);
        }
      }

      if (outputPath != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File saved successfully!', style: TextStyle(color: Colors.black)),
              backgroundColor: Colors.green.shade700,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        // User cancelled the save dialog
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Download cancelled', style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.orange.shade700,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: $e', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _downloadFolder(FileItem folder) async {
    final sftp = ref.read(sftpServiceProvider);
    if (sftp == null) return;

    // Let user pick save location
    final outputPath = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select download location',
    );

    if (outputPath == null) {
      debugPrint('User cancelled folder download');
      return;
    }

    final localPath = '$outputPath${Platform.pathSeparator}${folder.name}';
    final transferId = DateTime.now().millisecondsSinceEpoch.toString();

    debugPrint('=== FOLDER DOWNLOAD INITIATED ===');
    debugPrint('Remote folder: ${folder.path}');
    debugPrint('Output path: $outputPath');
    debugPrint('Local path: $localPath');
    debugPrint('Platform separator: ${Platform.pathSeparator}');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Counting files in ${folder.name}...', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blue.shade700,
          duration: const Duration(seconds: 1),
        ),
      );
    }

    try {
      // First, count total files
      final totalFiles = await _countFilesInFolder(folder.path, sftp);
      debugPrint('Total files to download: $totalFiles');
      
      // Add transfer to list with total count
      ref.read(fileTransfersProvider.notifier).addTransfer(FileTransfer(
        id: transferId,
        fileName: folder.name,
        localPath: localPath,
        remotePath: folder.path,
        isUpload: false,
        totalSize: totalFiles,
        transferredSize: 0,
        isFolderTransfer: true,
      ));

      ref.read(fileTransfersProvider.notifier).updateTransfer(
        transferId,
        status: FileTransferStatus.transferring,
      );
      
      // Download with progress tracking
      int processedFiles = 0;
      await _downloadFolderRecursive(
        folder.path, 
        localPath, 
        sftp,
        onFileDownloaded: () {
          processedFiles++;
          ref.read(fileTransfersProvider.notifier).updateTransfer(
            transferId,
            transferredSize: processedFiles,
          );
        },
      );
      
      ref.read(fileTransfersProvider.notifier).updateTransfer(
        transferId,
        status: FileTransferStatus.completed,
      );

      debugPrint('=== FOLDER DOWNLOAD COMPLETED ===');
      debugPrint('Processed $processedFiles files');
      debugPrint('Local path: $localPath');

      // Verify the download by listing the local directory
      final localDir = Directory(localPath);
      if (await localDir.exists()) {
        final items = await localDir.list(recursive: true).toList();
        debugPrint('Verification: Found ${items.length} items in local directory');
        for (final item in items.take(20)) {
          if (item is File) {
            final size = await item.length();
            debugPrint('  FILE: ${item.path} ($size bytes)');
          } else if (item is Directory) {
            debugPrint('  DIR: ${item.path}');
          }
        }
        if (items.length > 20) {
          debugPrint('  ... and ${items.length - 20} more items');
        }
      } else {
        debugPrint('ERROR: Local directory $localPath does not exist after download!');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Downloaded $processedFiles files to: $localPath', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      ref.read(fileTransfersProvider.notifier).updateTransfer(
        transferId,
        status: FileTransferStatus.failed,
        error: e.toString(),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: $e', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<int> _countFilesInFolder(String remotePath, dynamic sftp) async {
    int count = 0;
    final items = await sftp.listDirectory(remotePath);
    
    for (final item in items) {
      if (item.isDirectory) {
        count += await _countFilesInFolder(item.path, sftp);
      } else {
        count++;
      }
    }
    
    return count;
  }

  Future<void> _downloadFolderRecursive(
    String remotePath, 
    String localPath, 
    dynamic sftp,
    {Function()? onFileDownloaded}
  ) async {
    // Create local directory
    final localDir = Directory(localPath);
    if (!await localDir.exists()) {
      await localDir.create(recursive: true);
      debugPrint('Created directory: $localPath');
    }
    
    debugPrint('Downloading folder: $remotePath -> $localPath');

    // List remote directory
    final items = await sftp.listDirectory(remotePath);
    debugPrint('Found ${items.length} items in $remotePath');

    for (final item in items) {
      final itemLocalPath = '$localPath${Platform.pathSeparator}${item.name}';
      
      debugPrint('Processing: ${item.name} (isDirectory: ${item.isDirectory})');

      if (item.isDirectory) {
        // Recursively download subdirectory
        debugPrint('Recursing into subdirectory: ${item.path} -> $itemLocalPath');
        await _downloadFolderRecursive(item.path, itemLocalPath, sftp, onFileDownloaded: onFileDownloaded);
      } else {
        // Download file using readFile
        try {
          debugPrint('Downloading file: ${item.path} -> $itemLocalPath');
          final data = await sftp.readFile(item.path);

          // Ensure parent directory exists
          final file = File(itemLocalPath);
          final parentDir = file.parent;
          if (!await parentDir.exists()) {
            await parentDir.create(recursive: true);
            debugPrint('Created parent directory: ${parentDir.path}');
          }

          // Write file and ensure it's written
          await file.writeAsBytes(data, flush: true);

          // Verify file was written
          final exists = await file.exists();
          final size = exists ? await file.length() : 0;
          debugPrint('Downloaded: ${item.name} to $itemLocalPath (${data.length} bytes, exists: $exists, size on disk: $size)');

          if (!exists || size != data.length) {
            debugPrint('WARNING: File write verification failed for ${item.name} at $itemLocalPath');
          }

          // Call progress callback
          onFileDownloaded?.call();
        } catch (e) {
          debugPrint('Error downloading ${item.name} to $itemLocalPath: $e');
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

    final sftp = ref.read(sftpServiceProvider);
    if (sftp == null) return;

    final fileList = await ref.read(fileListProvider.future);
    final filesToDelete = fileList.where((f) => selected.contains(f.path)).toList();

    for (final file in filesToDelete) {
      try {
        await sftp.delete(file.path, isDirectory: file.isDirectory);
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
    final transfers = ref.watch(fileTransfersProvider);
    final activeTransfers = transfers.where((t) => 
        t.status == FileTransferStatus.transferring || 
        t.status == FileTransferStatus.pending
    ).toList();

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

          // Transfer panel
          if (activeTransfers.isNotEmpty)
            FileTransferPanel(transfers: activeTransfers),
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
          final sftp = ref.read(sftpServiceProvider);
          if (sftp != null) {
            await sftp.delete(file.path, isDirectory: file.isDirectory);
            ref.invalidate(fileListProvider);
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

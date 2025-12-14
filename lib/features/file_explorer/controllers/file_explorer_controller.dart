import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:async';
import 'package:path/path.dart' as path;

import '../../../services/ssh_service.dart';
import '../../../services/transfer_service.dart';
import '../../../models/transfer_task.dart';
import '../models/file_entity.dart';
import '../models/sort_option.dart';

/// File Explorer Controller - Manages remote file browsing via SSH
class FileExplorerController extends GetxController {
  final SSHService? sshService;

  FileExplorerController({this.sshService});

  // Reactive state
  final currentPath = '/'.obs;
  final contents = <FileEntity>[].obs;
  final filteredContents = <FileEntity>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final selectedItems = <FileEntity>{}.obs;
  final isSelectionMode = false.obs;
  final sortOption = SortOption.foldersFirst.obs;
  final showSearchBar = false.obs;
  final searchQuery = ''.obs;
  final isSearching = false.obs;

  // Transfer progress
  final isUploading = false.obs;
  final isDownloading = false.obs;
  final transferProgress = 0.0.obs;
  final transferSpeed = 0.0.obs;
  final transferElapsedTime = 0.obs;
  final transferRemainingTime = 0.obs;
  final currentFileName = ''.obs;
  final sourcePath = ''.obs;
  final destinationPath = ''.obs;

  final transferService = TransferService();
  final activeTasks = <TransferTask>[].obs;

  Timer? _timer;
  bool _isCancelled = false;
  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchChanged);
    transferService.taskStream.listen(_handleTransferUpdate);
    // Don't load directory immediately - let the view trigger it when needed
    // This prevents blocking the app startup
  }

  @override
  void onClose() {
    _timer?.cancel();
    searchController.dispose();
    transferService.dispose();
    super.onClose();
  }

  /// Load directory contents
  Future<void> loadCurrentDirectory() async {
    if (sshService == null) {
      errorMessage.value = 'Not connected';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final prefs = await SharedPreferences.getInstance();
      final showHidden = prefs.getBool('showHiddenFiles') ?? false;

      final lsCommand = showHidden
          ? 'ls -la "${currentPath.value}"'
          : 'ls -l "${currentPath.value}"';

      final result = await sshService!.executeCommand(lsCommand);
      final List<FileEntity> fileList = [];

      final lines = result.split('\n');
      for (var line in lines.skip(1)) {
        if (line.trim().isEmpty) continue;

        final parts = line.split(RegExp(r'\s+'));
        if (parts.length >= 9) {
          final permissions = parts[0];
          final size = parts[4];
          final name = parts.sublist(8).join(' ');

          if (name == '.' || name == '..') continue;
          if (!showHidden && name.startsWith('.')) continue;

          fileList.add(FileEntity(
            name: name,
            isDirectory: permissions.startsWith('d'),
            size: size,
            permissions: permissions,
          ));
        }
      }

      contents.value = fileList;
      filteredContents.value = List.from(fileList);
      _sortContents();
      isLoading.value = false;
    } catch (e) {
      errorMessage.value = 'Error: $e';
      isLoading.value = false;
    }
  }

  /// Sort contents based on current sort option
  void _sortContents() {
    switch (sortOption.value) {
      case SortOption.foldersFirst:
        filteredContents.sort((a, b) {
          if (a.isDirectory && !b.isDirectory) return -1;
          if (!a.isDirectory && b.isDirectory) return 1;
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case SortOption.filesFirst:
        filteredContents.sort((a, b) {
          if (a.isDirectory && !b.isDirectory) return 1;
          if (!a.isDirectory && b.isDirectory) return -1;
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case SortOption.nameAZ:
        filteredContents.sort((a, b) =>
          a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case SortOption.nameZA:
        filteredContents.sort((a, b) =>
          b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
      case SortOption.sizeSmallLarge:
        filteredContents.sort((a, b) =>
          int.parse(a.size).compareTo(int.parse(b.size)));
        break;
      case SortOption.sizeLargeSmall:
        filteredContents.sort((a, b) =>
          int.parse(b.size).compareTo(int.parse(a.size)));
        break;
    }
  }

  /// Navigate to directory
  Future<void> navigateToDirectory(String dirName) async {
    isSelectionMode.value = false;
    selectedItems.clear();

    final newPath = dirName == '..'
        ? currentPath.value.substring(0, currentPath.value.lastIndexOf('/'))
        : '${currentPath.value}${currentPath.value.endsWith('/') ? '' : '/'}$dirName';

    currentPath.value = newPath.isEmpty ? '/' : newPath;
    await loadCurrentDirectory();
  }

  /// Change sort option
  void changeSortOption(SortOption option) {
    sortOption.value = option;
    _sortContents();
  }

  /// Toggle selection mode
  void toggleSelectionMode(FileEntity item) {
    if (!isSelectionMode.value) {
      isSelectionMode.value = true;
      selectedItems.add(item);
    } else {
      if (selectedItems.contains(item)) {
        selectedItems.remove(item);
      } else {
        selectedItems.add(item);
      }
    }
  }

  /// Exit selection mode
  void exitSelectionMode() {
    isSelectionMode.value = false;
    selectedItems.clear();
  }

  /// Select all files
  void selectAllFiles() {
    if (selectedItems.length == contents.length) {
      selectedItems.clear();
    } else {
      selectedItems.clear();
      selectedItems.addAll(contents);
    }
    isSelectionMode.value = true;
  }

  /// Toggle search bar
  void toggleSearchBar() {
    showSearchBar.value = !showSearchBar.value;
    if (!showSearchBar.value) {
      searchController.clear();
      filteredContents.value = List.from(contents);
    }
  }

  /// Search changed listener
  void _onSearchChanged() {
    searchQuery.value = searchController.text;
    if (searchQuery.value.isEmpty) {
      filteredContents.value = List.from(contents);
      isSearching.value = false;
    } else {
      _performSearch();
    }
  }

  /// Perform search
  Future<void> _performSearch() async {
    if (sshService == null) return;

    isSearching.value = true;

    try {
      final query = searchQuery.value;
      final searchCommand = 'cd "${currentPath.value}" && find . -iname "*$query*"';
      final result = await sshService!.executeCommand(searchCommand);

      if (result.contains('No such file or directory') || result.trim().isEmpty) {
        filteredContents.value = [];
        isSearching.value = false;
        return;
      }

      final List<FileEntity> results = [];
      final files = result.split('\n');

      for (var file in files) {
        if (file.trim().isEmpty || file == '.') continue;

        final cleanPath = file.startsWith('./') ? file.substring(2) : file;
        if (cleanPath.isEmpty) continue;

        final fullPath = '${currentPath.value}/$cleanPath';
        try {
          final statResult = await sshService!.executeCommand('ls -la "$fullPath"');
          final parts = statResult.trim().split(RegExp(r'\s+'));
          if (parts.length >= 9) {
            final permissions = parts[0];
            final size = parts[4];
            final name = cleanPath.split('/').last;

            results.add(FileEntity(
              name: name,
              isDirectory: permissions.startsWith('d'),
              size: size,
              permissions: permissions,
              fullPath: fullPath,
            ));
          }
        } catch (e) {
          continue;
        }
      }

      filteredContents.value = results;
      isSearching.value = false;
    } catch (e) {
      errorMessage.value = 'Search error: $e';
      isSearching.value = false;
    }
  }

  /// Reset to root directory
  void resetToRoot() {
    currentPath.value = '/';
    contents.clear();
    filteredContents.clear();
    selectedItems.clear();
    isSelectionMode.value = false;
    errorMessage.value = '';
    showSearchBar.value = false;
    searchController.clear();
  }

  /// Upload file
  Future<void> uploadFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null) return;

    final prefs = await SharedPreferences.getInstance();
    final confirmOverwrite = prefs.getBool('confirmBeforeOverwrite') ?? true;

    for (final file in result.files) {
      if (file.path == null) continue;

      final remoteFilePath = '${currentPath.value}${currentPath.value.endsWith('/') ? '' : '/'}${file.name}';

      // Check if file exists
      if (confirmOverwrite) {
        try {
          final checkResult = await sshService!.executeCommand(
            '[ -f "$remoteFilePath" ] && echo "exists" || echo "not exists"'
          );

          if (checkResult.trim() == "exists") {
            final shouldOverwrite = await Get.dialog<bool>(
              AlertDialog(
                title: const Text('File already exists'),
                content: Text('The file "${file.name}" already exists. Replace it?'),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(result: false),
                    child: const Text('Skip'),
                  ),
                  TextButton(
                    onPressed: () => Get.back(result: true),
                    child: const Text('Replace'),
                  ),
                ],
              ),
              barrierDismissible: false,
            );

            if (shouldOverwrite != true) continue;
          }
        } catch (e) {
          debugPrint('Error checking file: $e');
        }
      }

      await _performUpload(file.path!, file.name, remoteFilePath);
    }

    await loadCurrentDirectory();
  }

  /// Perform upload with progress tracking
  Future<void> _performUpload(String localPath, String fileName, String remotePath) async {
    if (sshService == null) return;

    isUploading.value = true;
    currentFileName.value = fileName;
    sourcePath.value = localPath;
    destinationPath.value = remotePath;
    transferProgress.value = 0.0;

    try {
      final fileSize = await File(localPath).length();
      final startTime = DateTime.now();

      await transferService.uploadFile(
        localPath,
        remotePath,
        sshService!.host,
        sshService!.port,
        sshService!.username,
        sshService!.password,
        (filename, progress) {
          transferProgress.value = progress;
          final elapsed = DateTime.now().difference(startTime).inSeconds;
          transferElapsedTime.value = elapsed;

          if (elapsed > 0) {
            final bytesTransferred = (progress * fileSize).toInt();
            transferSpeed.value = bytesTransferred / elapsed / (1024 * 1024);
          }
        },
      );

      Get.snackbar(
        'Success',
        '$fileName uploaded successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to upload $fileName: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isUploading.value = false;
      transferProgress.value = 0.0;
    }
  }

  /// Download selected files
  Future<void> downloadSelected() async {
    if (sshService == null || selectedItems.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final defaultDir = prefs.getString('defaultDownloadDirectory') ?? '';

    String? selectedDirectory;
    if (defaultDir.isNotEmpty && await Directory(defaultDir).exists()) {
      selectedDirectory = defaultDir;
    } else {
      selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory == null) return;
    }

    isDownloading.value = true;

    for (final item in selectedItems) {
      if (item.isDirectory) continue;

      final localPath = '$selectedDirectory${Platform.pathSeparator}${item.name}';
      final remotePath = '${currentPath.value}${currentPath.value.endsWith('/') ? '' : '/'}${item.name}';

      await _performDownload(item.name, remotePath, localPath);
    }

    isDownloading.value = false;
    isSelectionMode.value = false;
    selectedItems.clear();

    Get.snackbar(
      'Success',
      'Files downloaded successfully',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Perform download with progress tracking
  Future<void> _performDownload(String fileName, String remotePath, String localPath) async {
    if (sshService == null) return;

    currentFileName.value = fileName;
    sourcePath.value = remotePath;
    destinationPath.value = localPath;
    transferProgress.value = 0.0;

    try {
      final startTime = DateTime.now();

      await transferService.downloadFile(
        remotePath,
        localPath,
        sshService!.host,
        sshService!.port,
        sshService!.username,
        sshService!.password,
        (filename, progress) {
          transferProgress.value = progress;
          final elapsed = DateTime.now().difference(startTime).inSeconds;
          transferElapsedTime.value = elapsed;
        },
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to download $fileName: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Delete selected files
  Future<void> deleteSelected() async {
    if (sshService == null || selectedItems.isEmpty) return;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Delete ${selectedItems.length} item(s)?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    isLoading.value = true;

    try {
      for (final item in selectedItems) {
        final remotePath = '${currentPath.value}${currentPath.value.endsWith('/') ? '' : '/'}${item.name}';
        await sshService!.executeCommand('rm -rf "$remotePath"');
      }

      await loadCurrentDirectory();

      Get.snackbar(
        'Success',
        'Deleted ${selectedItems.length} item(s)',
        snackPosition: SnackPosition.BOTTOM,
      );

      isSelectionMode.value = false;
      selectedItems.clear();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Handle transfer updates
  void _handleTransferUpdate(TransferTask task) {
    final index = activeTasks.indexWhere((t) => t.id == task.id);
    if (index >= 0) {
      activeTasks[index] = task;
    }
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/file_item.dart';
import '../services/sftp_service.dart';
import 'app_providers.dart';

/// Provider for current directory path
final currentDirectoryProvider = StateProvider<String>((ref) => '/home');

/// Provider for navigation history (for back button)
final navigationHistoryProvider = StateProvider<List<String>>((ref) => []);

/// Provider for selected files (for multi-select operations)
final selectedFilesProvider = StateProvider<Set<String>>((ref) => {});

/// Provider for file sort order
final fileSortProvider = StateProvider<FileSortOption>((ref) => FileSortOption.nameAsc);

enum FileSortOption {
  nameAsc,
  nameDesc,
  sizeAsc,
  sizeDesc,
  dateAsc,
  dateDesc,
  typeAsc,
}

/// Provider for SFTP service
final sftpServiceProvider = Provider<SftpService?>((ref) {
  final sshService = ref.watch(sshServiceProvider);
  final sshClient = sshService.client;
  if (sshClient == null) return null;
  return SftpService(sshClient);
});

/// Provider for file list in current directory
final fileListProvider = FutureProvider.autoDispose<List<FileItem>>((ref) async {
  // Keep provider alive when app goes to background
  ref.keepAlive();
  
  final sftpService = ref.watch(sftpServiceProvider);
  final currentDir = ref.watch(currentDirectoryProvider);
  final sortOption = ref.watch(fileSortProvider);

  if (sftpService == null) {
    throw Exception('SFTP service not available');
  }

  try {
    var files = await sftpService.listDirectory(currentDir);
    
    // Apply sorting
    switch (sortOption) {
      case FileSortOption.nameAsc:
        files.sort((a, b) {
          if (a.isDirectory && !b.isDirectory) return -1;
          if (!a.isDirectory && b.isDirectory) return 1;
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case FileSortOption.nameDesc:
        files.sort((a, b) {
          if (a.isDirectory && !b.isDirectory) return -1;
          if (!a.isDirectory && b.isDirectory) return 1;
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;
      case FileSortOption.sizeAsc:
        files.sort((a, b) {
          if (a.isDirectory && !b.isDirectory) return -1;
          if (!a.isDirectory && b.isDirectory) return 1;
          return a.size.compareTo(b.size);
        });
        break;
      case FileSortOption.sizeDesc:
        files.sort((a, b) {
          if (a.isDirectory && !b.isDirectory) return -1;
          if (!a.isDirectory && b.isDirectory) return 1;
          return b.size.compareTo(a.size);
        });
        break;
      case FileSortOption.dateAsc:
        files.sort((a, b) {
          if (a.isDirectory && !b.isDirectory) return -1;
          if (!a.isDirectory && b.isDirectory) return 1;
          return a.modified.compareTo(b.modified);
        });
        break;
      case FileSortOption.dateDesc:
        files.sort((a, b) {
          if (a.isDirectory && !b.isDirectory) return -1;
          if (!a.isDirectory && b.isDirectory) return 1;
          return b.modified.compareTo(a.modified);
        });
        break;
      case FileSortOption.typeAsc:
        files.sort((a, b) {
          if (a.isDirectory && !b.isDirectory) return -1;
          if (!a.isDirectory && b.isDirectory) return 1;
          return a.extension.compareTo(b.extension);
        });
        break;
    }
    
    return files;
  } catch (e) {
    throw Exception('Failed to list files: $e');
  }
});

/// Provider for file transfers
class FileTransferNotifier extends Notifier<List<FileTransfer>> {
  @override
  List<FileTransfer> build() => [];

  void addTransfer(FileTransfer transfer) {
    state = [...state, transfer];
  }

  void updateTransfer(String id, {
    int? transferredSize,
    FileTransferStatus? status,
    String? error,
  }) {
    state = [
      for (final transfer in state)
        if (transfer.id == id)
          FileTransfer(
            id: transfer.id,
            fileName: transfer.fileName,
            localPath: transfer.localPath,
            remotePath: transfer.remotePath,
            isUpload: transfer.isUpload,
            totalSize: transfer.totalSize,
            transferredSize: transferredSize ?? transfer.transferredSize,
            status: status ?? transfer.status,
            error: error ?? transfer.error,
            isFolderTransfer: transfer.isFolderTransfer,
            totalBytes: transfer.totalBytes,
            transferredBytes: transfer.transferredBytes,
          )
        else
          transfer,
    ];
  }

  void removeTransfer(String id) {
    state = state.where((t) => t.id != id).toList();
  }

  void clearCompleted() {
    state = state.where((t) => t.status != FileTransferStatus.completed).toList();
  }

  void clearAll() {
    state = [];
  }
}

final fileTransfersProvider = NotifierProvider<FileTransferNotifier, List<FileTransfer>>(() {
  return FileTransferNotifier();
});

/// Provider for search query
final fileSearchQueryProvider = StateProvider<String>((ref) => '');

/// Provider for filtered file list (with search)
final filteredFileListProvider = Provider<AsyncValue<List<FileItem>>>((ref) {
  final fileListAsync = ref.watch(fileListProvider);
  final searchQuery = ref.watch(fileSearchQueryProvider).toLowerCase();

  return fileListAsync.whenData((files) {
    if (searchQuery.isEmpty) return files;
    return files.where((file) => file.name.toLowerCase().contains(searchQuery)).toList();
  });
});

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'dart:async';
import '../../services/ssh_service.dart';
import '../../services/transfer_service.dart';
import '../../models/transfer_task.dart';
import '../../widgets/transfer_progress_dialog.dart';

class FileExplorer extends StatefulWidget {
  final SSHService? sshService;

  const FileExplorer({
    super.key,
    required this.sshService,
  });

  @override
  FileExplorerState createState() => FileExplorerState();
}

enum SortOption {
  foldersFirst,
  filesFirst,
  nameAZ,
  nameZA,
  sizeSmallLarge,
  sizeLargeSmall,
}

class FileExplorerState extends State<FileExplorer> with AutomaticKeepAliveClientMixin<FileExplorer> {
  String _currentPath = '/';
  List<FileEntity> _contents = [];
  bool _isLoading = false;
  String _errorMessage = '';
  Set<FileEntity> _selectedItems = {};
  bool _isSelectionMode = false;
  SortOption _sortOption = SortOption.foldersFirst;
  double _progress = 0.0;
  bool _isUploading = false;
  bool _isDownloading = false;
  bool _isCancelled = false;
  String _currentFileName = '';
  String _sourcePath = '';
  String _destinationPath = '';
  bool _showSearchBar = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<FileEntity> _filteredContents = [];
  bool _isSearching = false;
  String _lastSearchQuery = '';
  final TransferService _transferService = TransferService();
  final List<TransferTask> _activeTasks = [];
  double _speed = 0.0;
  int _elapsedTime = 0;
  int _remainingTime = 0;
  Timer? _timer;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterContents);
    _transferService.taskStream.listen(_handleTransferUpdate);
    if (widget.sshService != null && mounted) {
      _loadCurrentDirectory();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _transferService.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentDirectory() async {
    final sshService = widget.sshService;
    if (sshService == null) {
      setState(() => _errorMessage = 'Not connected');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await sshService.executeCommand('ls -la "$_currentPath"');
      final List<FileEntity> contents = [];
      
      final lines = result.split('\n');
      for (var line in lines.skip(1)) {
        if (line.trim().isEmpty) continue;
        
        final parts = line.split(RegExp(r'\s+'));
        if (parts.length >= 9) {
          final permissions = parts[0];
          final size = parts[4];
          final name = parts.sublist(8).join(' ');
          
          if (name == '.' || name == '..') continue;
          
          contents.add(FileEntity(
            name: name,
            isDirectory: permissions.startsWith('d'),
            size: size,
            permissions: permissions,
          ));
        }
      }

      setState(() {
        _contents = contents;
        _filteredContents = List.from(contents);
        _sortContents();
        _isLoading = false;
        _errorMessage = '';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  void _sortContents() {
    final listToSort = _filteredContents;
    switch (_sortOption) {
      case SortOption.foldersFirst:
        listToSort.sort((a, b) {
          if (a.isDirectory && !b.isDirectory) return -1;
          if (!a.isDirectory && b.isDirectory) return 1;
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case SortOption.filesFirst:
        listToSort.sort((a, b) {
          if (a.isDirectory && !b.isDirectory) return 1;
          if (!a.isDirectory && b.isDirectory) return -1;
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case SortOption.nameAZ:
        listToSort.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case SortOption.nameZA:
        listToSort.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
      case SortOption.sizeSmallLarge:
        listToSort.sort((a, b) => int.parse(a.size).compareTo(int.parse(b.size)));
        break;
      case SortOption.sizeLargeSmall:
        listToSort.sort((a, b) => int.parse(b.size).compareTo(int.parse(a.size)));
        break;
    }
  }
  
  void resetToRoot() {
    setState(() {
      _currentPath = '/';
      _contents = [];
      _filteredContents = [];
      _selectedItems.clear();
      _isSelectionMode = false;
      _errorMessage = '';
    });
  }

  Future<void> _navigateToDirectory(String dirName) async {
    setState(() {
      _isSelectionMode = false;
      _selectedItems.clear();
    });
    
    final newPath = dirName == '..' 
        ? _currentPath.substring(0, _currentPath.lastIndexOf('/'))
        : '$_currentPath${_currentPath.endsWith('/') ? '' : '/'}$dirName';
    
    setState(() => _currentPath = newPath.isEmpty ? '/' : newPath);
    await _loadCurrentDirectory();
  }

  Future<void> _uploadFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null) return;

    for (final file in result.files) {
      if (file.path != null) {
        StreamController<Map<String, dynamic>>? dialogController;
        Timer? progressTimer;
        final startTime = DateTime.now();
        int lastUpdate = 0;
        
        try {
          final fileSize = await File(file.path!).length();
          
          setState(() {
            _currentFileName = file.name;
            _sourcePath = file.path!;
            _destinationPath = '$_currentPath/${file.name}';
            _progress = 0.0;
            _speed = 0.0;
            _elapsedTime = 0;
            _remainingTime = 0;
            _isUploading = true;
          });

          dialogController = StreamController<Map<String, dynamic>>();
          
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) => StreamBuilder<Map<String, dynamic>>(
              stream: dialogController!.stream,
              initialData: {
                'fileName': file.name,
                'sourcePath': file.path,
                'destinationPath': '$_currentPath/${file.name}',
                'progress': 0.0,
                'speed': 0.0,
                'elapsedTime': 0,
                'remainingTime': 0
              },
              builder: (context, snapshot) {
                final data = snapshot.data!;
                return TransferProgressDialog(
                  fileName: _currentFileName,
                  sourcePath: _sourcePath,
                  destinationPath: _destinationPath,
                  progress: data['progress'],
                  speed: data['speed'],
                  elapsedTime: data['elapsedTime'],
                  remainingTime: data['remainingTime'],
                  type: TransferType.upload,
                  onCancel: () {
                    _cancelOperation();
                    Navigator.of(dialogContext).pop();
                    if (dialogController != null && !dialogController.isClosed) {
                      dialogController.close();
                    }
                    progressTimer?.cancel();
                  },
                );
              },
            ),
          );
          
          progressTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
            if (!mounted) return;
            
            final elapsedSeconds = DateTime.now().difference(startTime).inSeconds;
            
            int remainingSeconds = 0;
            if (_progress > 0.01) { 
              remainingSeconds = (elapsedSeconds / _progress * (1 - _progress)).round();
            }
            
            if (dialogController != null && !dialogController.isClosed) {
              dialogController.add({
                'fileName': file.name,
                'sourcePath': file.path,
                'destinationPath': '$_currentPath/${file.name}',
                'progress': _progress,
                'speed': _speed,
                'elapsedTime': elapsedSeconds,
                'remainingTime': remainingSeconds
              });
            }
            
            if (elapsedSeconds != lastUpdate) {
              setState(() {
                _elapsedTime = elapsedSeconds;
                _remainingTime = remainingSeconds;
              });
              lastUpdate = elapsedSeconds;
            }
          });

          await _transferService.uploadFile(
            file.path!,
            '$_currentPath/${file.name}',
            widget.sshService!.host,
            widget.sshService!.port,
            widget.sshService!.username,
            widget.sshService!.password,
            (filename, progress) {
              if (mounted) {
                final bytesTransferred = (progress * fileSize).toInt();
                final elapsedSeconds = DateTime.now().difference(startTime).inSeconds;
                final speedMBps = elapsedSeconds > 0
                    ? bytesTransferred / elapsedSeconds / (1024 * 1024)
                    : 0.0;
                
                setState(() {
                  _progress = progress;
                  _speed = speedMBps;
                });
              }
            },
          );

          await _loadCurrentDirectory();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${file.name} uploaded successfully')),
          );
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to upload ${file.name}: $e')),
            );
          }
        } finally {
          progressTimer?.cancel();
          
          if (dialogController != null && !dialogController.isClosed) {
            dialogController.close();
          }
          
          if (mounted) {
            Navigator.of(context).pop();
            setState(() {
              _isUploading = false;
              _progress = 0.0;
              _speed = 0.0;
              _elapsedTime = 0;
              _remainingTime = 0;
            });
          }
        }
      }
    }
  }

  Future<void> requestStoragePermission() async {
    if (await Permission.manageExternalStorage.request().isGranted) {
      print("✅ Full storage permission granted!");
    } else {
      print("❌ Storage permission denied! Requesting again...");
      openAppSettings();
    }
  }

  Future<void> _uploadFolder() async {
    if (widget.sshService == null) return;

    await requestStoragePermission();

    final String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory == null) {
      print("❌ No folder selected.");
      return;
    }

    setState(() {
      _isLoading = true;
      _isUploading = true;
      _progress = 0.0;
      _speed = 0.0;
      _elapsedTime = 0;
      _remainingTime = 0;
    });

    final dialogController = StreamController<Map<String, dynamic>>();
    final folderName = path.basename(selectedDirectory);
    
    final overallStartTime = DateTime.now();
    int lastBytesTransferred = 0;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StreamBuilder<Map<String, dynamic>>(
        stream: dialogController.stream,
        initialData: {
          'fileName': folderName,
          'sourcePath': selectedDirectory,
          'destinationPath': '$_currentPath/$folderName',
          'progress': 0.0,
          'speed': 0.0,
          'elapsedTime': 0,
          'remainingTime': 0
        },
        builder: (context, snapshot) {
          final data = snapshot.data!;
          return TransferProgressDialog(
            fileName: data['fileName'],
            sourcePath: data['sourcePath'],
            destinationPath: data['destinationPath'],
            progress: data['progress'],
            speed: data['speed'],
            elapsedTime: data['elapsedTime'],
            remainingTime: data['remainingTime'],
            type: TransferType.upload,
            onCancel: () {
              _cancelOperation();
              Navigator.of(dialogContext).pop();
              dialogController.close();
            },
          );
        },
      ),
    );
    
    _stopTimer();
    
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        final elapsedSeconds = DateTime.now().difference(overallStartTime).inSeconds;
        
        int remainingSeconds = 0;
        if (_progress > 0.01) { 
          remainingSeconds = (elapsedSeconds / _progress * (1 - _progress)).round();
        }
        
        setState(() {
          _elapsedTime = elapsedSeconds;
          _remainingTime = remainingSeconds;
        });
        
        if (!dialogController.isClosed) {
          dialogController.add({
            'fileName': _currentFileName.isEmpty 
                ? folderName 
                : _currentFileName,
            'sourcePath': _sourcePath.isEmpty 
                ? selectedDirectory 
                : _sourcePath,
            'destinationPath': _destinationPath.isEmpty 
                ? '$_currentPath/$folderName' 
                : _destinationPath,
            'progress': _progress,
            'speed': _speed,
            'elapsedTime': elapsedSeconds,
            'remainingTime': remainingSeconds
          });
        }
      }
    });

    try {
      final directory = Directory(selectedDirectory);
      if (!directory.existsSync()) {
        throw Exception("Directory does not exist: $selectedDirectory");
      }

      final baseRemotePath = '$_currentPath${_currentPath.endsWith('/') ? '' : '/'}$folderName';

      print("📂 Creating base folder: $baseRemotePath");
      await widget.sshService!.executeCommand('mkdir -p "$baseRemotePath"');

      final entities = await _getAllFilesInDirectory(selectedDirectory);
      print("✅ Found ${entities.length} items to upload");

      final totalSize = await _calculateTotalSize(entities);
      int uploadedSize = 0;

      for (final entity in entities) {
        if (_isCancelled) break;

        final relativePath = entity.path.substring(selectedDirectory.length);
        final remotePath = '$baseRemotePath${relativePath.replaceAll('\\', '/')}';
        final fileName = path.basename(entity.path);

        setState(() {
          _currentFileName = fileName;
          _sourcePath = entity.path;
          _destinationPath = remotePath;
        });
        
        if (!dialogController.isClosed) {
          dialogController.add({
            'fileName': fileName,
            'sourcePath': entity.path,
            'destinationPath': remotePath,
            'progress': _progress,
            'speed': _speed,
            'elapsedTime': _elapsedTime,
            'remainingTime': _remainingTime
          });
        }

        if (entity is Directory) {
          print("📁 Creating remote directory: $remotePath");
          await widget.sshService!.executeCommand('mkdir -p "$remotePath"');
        } else if (entity is File) {
          print("📄 Uploading file: ${entity.path} -> $remotePath");
          
          final parentDir = remotePath.substring(0, remotePath.lastIndexOf('/'));
          await widget.sshService!.executeCommand('mkdir -p "$parentDir"');

          final fileSize = await entity.length();
          
          await _transferService.uploadFile(
            entity.path,
            remotePath,
            widget.sshService!.host,
            widget.sshService!.port,
            widget.sshService!.username,
            widget.sshService!.password,
            (filename, fileProgress) {
              if (mounted) {
                final currentFileBytes = (fileProgress * fileSize).round();
                final newTotalUploaded = uploadedSize + currentFileBytes;
                final currentProgress = totalSize > 0 ? newTotalUploaded / totalSize : 0;
                
                final bytesTransferredSinceLastCheck = newTotalUploaded - lastBytesTransferred;
                final elapsedSeconds = DateTime.now().difference(overallStartTime).inSeconds;
                final speedMBps = elapsedSeconds > 0 
                    ? (bytesTransferredSinceLastCheck / 500 * 1000 / (1024 * 1024)).toDouble() 
                    : 0.0;
                
                setState(() {
                  _progress = currentProgress.toDouble(); 
                  _speed = speedMBps;
                });
                
                lastBytesTransferred = newTotalUploaded;
                
                if (!dialogController.isClosed) {
                  final elapsedSeconds = DateTime.now().difference(overallStartTime).inSeconds;
                  int remainingSeconds = 0;
                  if (currentProgress > 0.01) {
                    remainingSeconds = (elapsedSeconds / currentProgress * (1 - currentProgress)).round();
                  }
                  
                  dialogController.add({
                    'fileName': fileName,
                    'sourcePath': entity.path,
                    'destinationPath': remotePath,
                    'progress': currentProgress,
                    'speed': speedMBps,
                    'elapsedTime': elapsedSeconds,
                    'remainingTime': remainingSeconds
                  });
                }
              }
            },
          );
          
          uploadedSize += fileSize;
        }
      }

      await _loadCurrentDirectory();

      _stopTimer();
      if (!dialogController.isClosed) {
        dialogController.close();
      }
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Folder uploaded successfully!')),
        );
      }
    } catch (e) {
      print("❌ Error during folder upload: $e");
      
      _stopTimer();
      if (!dialogController.isClosed) {
        dialogController.close();
      }
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload folder: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isUploading = false;
          _progress = 0.0;
          _isCancelled = false;
          _currentFileName = '';
          _sourcePath = '';
          _destinationPath = '';
        });
      }
    }
  }

  Future<void> _downloadSelected() async {
    if (widget.sshService == null || _selectedItems.isEmpty) return;

    _showTransferProgress();

    try {
      final String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory == null) return;

      setState(() {
        _isLoading = true;
        _isDownloading = true;
      });

      int totalSize = 0;
      for (final item in _selectedItems) {
        if (!item.isDirectory) {
          totalSize += int.parse(item.size);
        }
      }

      for (int i = 0; i < _selectedItems.length; i++) {
        if (_isCancelled) break;
        final item = _selectedItems.elementAt(i);
        final localPath = '$selectedDirectory${Platform.pathSeparator}${item.name}';
        final remotePath = '$_currentPath${_currentPath.endsWith('/') ? '' : '/'}${item.name}';

        setState(() {
          _currentFileName = item.name;
          _sourcePath = remotePath;
          _destinationPath = localPath;
        });

        if (item.isDirectory) {
          await _downloadDirectory(remotePath, localPath);
        } else {
          _startTimer();
          final startTime = DateTime.now();
          await _transferService.downloadFolder(
            remotePath,
            localPath,
            widget.sshService!.host,
            widget.sshService!.port,
            widget.sshService!.username,
            widget.sshService!.password,
            (filename, progress) {
              if (mounted) {
                setState(() {
                  _progress = progress;
                  final currentTime = DateTime.now();
                  final duration = currentTime.difference(startTime).inSeconds;
                  _speed = (progress * totalSize) / duration / (1024 * 1024); 
                });
              }
            }
          );
          _stopTimer();
        }
        
        setState(() {
          _progress = (i + 1) / _selectedItems.length;
        });
      }

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Downloaded ${_selectedItems.length} item(s)')),
      );

      setState(() {
        _isSelectionMode = false;
        _selectedItems.clear();
      });
    } catch (e) {
      if (e.toString().contains('Not connected')) {
        await widget.sshService!.connect();
        await _downloadSelected();
      } else {
        if (!mounted) return;
        
        setState(() => _errorMessage = 'Download error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to download: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isDownloading = false;
          _progress = 0.0;
          _isCancelled = false;
        });
      }
    }
  }

  Future<void> _downloadDirectory(String remotePath, String localPath) async {
    final sshService = widget.sshService;
    if (sshService == null) return;

    final result = await sshService.executeCommand('ls -la "$remotePath"');
    final List<FileEntity> contents = [];

    final lines = result.split('\n');
    for (var line in lines.skip(1)) {
      if (line.trim().isEmpty) continue;

      final parts = line.split(RegExp(r'\s+'));
      if (parts.length >= 9) {
        final permissions = parts[0];
        final name = parts.sublist(8).join(' ');

        if (name == '.' || name == '..') continue;

        contents.add(FileEntity(
          name: name,
          isDirectory: permissions.startsWith('d'),
          size: '0',  
          permissions: permissions,
        ));
      }
    }

    final directory = Directory(localPath);
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }

    for (final item in contents) {
      if (_isCancelled) break;
      final itemRemotePath = '$remotePath/${item.name}';
      final itemLocalPath = '$localPath/${item.name}';

      if (item.isDirectory) {
        await _downloadDirectory(itemRemotePath, itemLocalPath);
      } else {
        await _transferService.downloadFolder(
          itemRemotePath,
          itemLocalPath,
          widget.sshService!.host,
          widget.sshService!.port,
          widget.sshService!.username,
          widget.sshService!.password,
          (filename, progress) {
            if (mounted) {
              setState(() {
                _progress = progress;
              });
            }
          }
        );
      }
    }
  }


  Future<void> _confirmDeleteSelected() async {
    if (_selectedItems.isEmpty) return;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete ${_selectedItems.length} item(s)?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deleteSelected();
    }
  }

  Future<void> _deleteSelected() async {
    if (widget.sshService == null || _selectedItems.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      for (final item in _selectedItems) {
        final remotePath = '$_currentPath${_currentPath.endsWith('/') ? '' : '/'}${item.name}';
        await widget.sshService!.executeCommand('rm -rf "$remotePath"');
      }

      await _loadCurrentDirectory();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted ${_selectedItems.length} item(s)')),
      );

      setState(() {
        _isSelectionMode = false;
        _selectedItems.clear();
      });
    } catch (e) {
      if (e.toString().contains('Not connected')) {
        await widget.sshService!.connect();
        await _deleteSelected();
      } else {
        if (!mounted) return;

        setState(() => _errorMessage = 'Delete error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _changeSortOption(SortOption option) {
    setState(() {
      _sortOption = option;
      _sortContents();
    });
  }

  void _selectAllFiles() {
    setState(() {
      if (_selectedItems.length == _contents.length) {
        _selectedItems.clear();
      } else {
        _selectedItems.clear();
        _selectedItems.addAll(_contents);
      }
      _isSelectionMode = true;
    });
  }

  void _cancelOperation() {
    setState(() {
      _isCancelled = true;
      _isLoading = false;
      _isUploading = false;
      _isDownloading = false;
      _progress = 0.0;
    });
  }

  Future<List<FileEntity>> _searchAllDirectories(String path, String query) async {
    List<FileEntity> results = [];
    try {
      final searchCommand = 'cd "$path" && find . -iname "*$query*"';
      final result = await widget.sshService!.executeCommand(searchCommand);
      
      if (result.contains('No such file or directory') || result.trim().isEmpty) {
        return results;
      }

      final files = result.split('\n');
      for (var file in files) {
        if (file.trim().isEmpty || file == '.') continue;
        
        final cleanPath = file.startsWith('./') ? file.substring(2) : file;
        if (cleanPath.isEmpty) continue;

        final fullPath = '$path/${cleanPath}';
        try {
          final statResult = await widget.sshService!.executeCommand('ls -la "$fullPath"');
          final parts = statResult.trim().split(RegExp(r'\s+'));
          if (parts.length >= 9) {
            final permissions = parts[0];
            final size = parts[4];
            final name = path.split('/').last;
            
            results.add(FileEntity(
              name: name,
              isDirectory: permissions.startsWith('d'),
              size: size,
              permissions: permissions,
              fullPath: fullPath,
            ));
          }
        } catch (e) {
          print('Error getting file details: $e');
          continue;
        }
      }
    } catch (e) {
      print('Search error: $e');
    }
    return results;
  }

  void _filterContents() async {
    final query = _searchController.text;
    if (query.isEmpty) {
      setState(() {
        _filteredContents = List.from(_contents);
        _isSearching = false;
        _lastSearchQuery = '';
      });
      return;
    }

    if (query != _lastSearchQuery) {
      setState(() => _isSearching = true);
      _lastSearchQuery = query;
      
      try {
        final searchPath = _currentPath == '/' ? '/' : _currentPath;
        final results = await _searchAllDirectories(searchPath, query);
        
        if (mounted) {
          setState(() {
            _filteredContents = results;
            _isSearching = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Search error: $e';
            _isSearching = false;
          });
        }
      }
    }
    _sortContents();
  }

  Future<List<FileSystemEntity>> _getAllFilesInDirectory(String path) async {
    final List<FileSystemEntity> entities = [];
    try {
      final directory = Directory(path);
      if (!directory.existsSync()) {
        print('❌ Directory does not exist: $path');
        return entities;
      }

      final List<Directory> directories = [];
      final List<File> files = [];

      final List<FileSystemEntity> entries = directory.listSync(followLinks: false);
      
      for (var entity in entries) {
        if (entity is Directory) {
          directories.add(entity);
          entities.addAll(await _getAllFilesInDirectory(entity.path));
        } else if (entity is File) {
          files.add(entity);
        }
      }

      entities.addAll(directories);
      entities.addAll(files);

    } catch (e) {
      print('❌ Error listing directory contents: $e');
    }
    return entities;
  }

  Future<int> _calculateTotalSize(List<FileSystemEntity> entities) async {
    int totalSize = 0;
    try {
      for (final entity in entities) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
    } catch (e) {
      print('❌ Error calculating total size: $e');
    }
    return totalSize;
  }

  void _handleTransferUpdate(TransferTask task) {
    setState(() {
      final index = _activeTasks.indexWhere((t) => t.id == task.id);
      if (index >= 0) {
        _activeTasks[index] = task;
      }
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _elapsedTime = 0;
    final startTime = DateTime.now();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          _elapsedTime = DateTime.now().difference(startTime).inSeconds;
          if (_progress > 0) {
            _remainingTime = (_elapsedTime / _progress * (1 - _progress)).toInt();
          }
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  void _showTransferProgress() {
    if (!mounted || (!_isUploading && !_isDownloading)) return;
    
    if (_isDownloading) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => TransferProgressDialog(
          fileName: _currentFileName,
          sourcePath: _sourcePath,
          destinationPath: _destinationPath,
          progress: _progress,
          speed: _speed,
          elapsedTime: _elapsedTime,
          remainingTime: _remainingTime,
          type: _isUploading ? TransferType.upload : TransferType.download,
          onCancel: () {
            _cancelOperation();
            Navigator.of(context).pop();
          },
        ),
      );
    }
  }

  Widget _buildTransferList() {
    if (_activeTasks.isEmpty) return const SizedBox();

    return Container(
      height: 200,
      child: ListView.builder(
        itemCount: _activeTasks.length,
        itemBuilder: (context, index) {
          final task = _activeTasks[index];
          return ListTile(
            leading: Icon(_getTransferIcon(task)),
            title: Text(task.filename),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(value: task.progress),
                Text('Progress: ${(task.progress * 100).toStringAsFixed(2)}%'),
                Text('Speed: ${_speed.toStringAsFixed(2)} MB/s'),
                Text('Elapsed time: $_elapsedTime s'),
                Text('Remaining time: $_remainingTime s'),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: () => _transferService.cancelTask(task.id),
            ),
          );
        },
      ),
    );
  }

  IconData _getTransferIcon(TransferTask task) {
    switch (task.status) {
      case TransferStatus.completed:
        return Icons.check_circle;
      case TransferStatus.failed:
        return Icons.error;
      case TransferStatus.cancelled:
        return Icons.cancel;
      default:
        return task.type == TransferType.upload 
          ? Icons.upload_file 
          : Icons.download;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_currentPath == '/' && _contents.isEmpty && widget.sshService != null && !_isLoading) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadCurrentDirectory();
      }
    });
  }
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        title: GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Path copied to clipboard')),
            );
            Clipboard.setData(ClipboardData(text: _currentPath));
          },
          child: Text(_currentPath),
        ),
        leading: _isSelectionMode
          ? IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isSelectionMode = false;
                  _selectedItems.clear();
                });
              },
            )
          : null,
        actions: [
          if (_isSelectionMode) ...[
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: _selectedItems.isEmpty ? null : _downloadSelected,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _selectedItems.isEmpty ? null : _confirmDeleteSelected,
            ),
            IconButton(
              icon: const Icon(Icons.select_all),
              onPressed: _selectAllFiles,
            ),
          ] else if (widget.sshService != null) ...[
            if (_currentPath != '/') 
              IconButton(
                icon: const Icon(Icons.search),
                tooltip: 'Search Files',
                onPressed: () {
                  setState(() {
                    _showSearchBar = !_showSearchBar;
                    if (!_showSearchBar) {
                      _searchController.clear();
                      _filterContents();
                    }
                  });
                },
              ),
            IconButton(
              icon: const Icon(Icons.upload_file),
              onPressed: _uploadFile,
            ),
            IconButton(
              icon: const Icon(Icons.folder_open),
              onPressed: _uploadFolder,
            ),
            PopupMenuButton<SortOption>(
              onSelected: _changeSortOption,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: SortOption.foldersFirst,
                  child: Text('Folders First'),
                ),
                const PopupMenuItem(
                  value: SortOption.filesFirst,
                  child: Text('Files First'),
                ),
                const PopupMenuItem(
                  value: SortOption.nameAZ,
                  child: Text('Name A-Z'),
                ),
                const PopupMenuItem(
                  value: SortOption.nameZA,
                  child: Text('Name Z-A'),
                ),
                const PopupMenuItem(
                  value: SortOption.sizeSmallLarge,
                  child: Text('Size Small-Large'),
                ),
                const PopupMenuItem(
                  value: SortOption.sizeLargeSmall,
                  child: Text('Size Large-Small'),
                ),
              ],
              icon: const Icon(Icons.sort),
            ),
          ],
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadCurrentDirectory,
        child: Column(
          children: [
            _buildTransferList(),
            if (_showSearchBar)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Search all files...',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _isSearching 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _filterContents();
                          },
                        ),
                  ),
                  onChanged: (value) => _filterContents(),
                ),
              ),
            Expanded(
              child: _isLoading && (_isUploading || _isDownloading)
                ? const Center(child: CircularProgressIndicator())  
                : _isLoading || _isSearching
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage.isNotEmpty
                        ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)))
                        : Column(
                            children: [
                              if (_currentPath != '/')
                                ListTile(
                                  leading: const Icon(Icons.folder),
                                  title: const Text('..'),
                                  onTap: () => _navigateToDirectory('..'),
                                ),
                              Expanded(
                                child: ListView.builder(
                                  key: PageStorageKey<String>(_currentPath),
                                  itemCount: _filteredContents.length,
                                  itemBuilder: (context, index) {
                                    final item = _filteredContents[index];
                                    final bool isSelected = _selectedItems.contains(item);

                                    return ListTile(
                                      leading: Icon(
                                        item.isDirectory ? Icons.folder : Icons.insert_drive_file,
                                        color: item.isDirectory ? Colors.blue : null,
                                      ),
                                      title: Text(item.name),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('${item.size} ${item.permissions}'),
                                          if (_showSearchBar && item.fullPath != null)
                                            Text(
                                              item.fullPath!,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                        ],
                                      ),
                                      selected: isSelected,
                                      trailing: _isSelectionMode
                                          ? Checkbox(
                                              value: isSelected,
                                              onChanged: (bool? value) {
                                                setState(() {
                                                  if (value == true) {
                                                    _selectedItems.add(item);
                                                  } else {
                                                    _selectedItems.remove(item);
                                                  }
                                                });
                                              },
                                            )
                                          : null,
                                      onTap: () {
                                        if (_isSelectionMode) {
                                          setState(() {
                                            if (isSelected) {
                                              _selectedItems.remove(item);
                                            } else {
                                              _selectedItems.add(item);
                                            }
                                          });
                                        } else {
                                          if (item.isDirectory) {
                                            _navigateToDirectory(item.name);
                                          } else {
                                            _downloadSelected();
                                          }
                                        }
                                      },
                                      onLongPress: () {
                                        if (!_isSelectionMode) {
                                          setState(() {
                                            _isSelectionMode = true;
                                            _selectedItems.add(item);
                                          });
                                        }
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
            ),
          ],
        ),
      ),
    );
  }
}

class FileEntity {
  final String name;
  final bool isDirectory;
  final String size;
  final String permissions;
  final String? fullPath;

  FileEntity({
    required this.name,
    required this.isDirectory,
    required this.size,
    required this.permissions,
    this.fullPath,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileEntity &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          isDirectory == other.isDirectory;

  @override
  int get hashCode => name.hashCode ^ isDirectory.hashCode;
}
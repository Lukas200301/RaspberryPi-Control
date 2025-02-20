import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'ssh_service.dart';
import 'dart:io';

class FileExplorerScreen extends StatefulWidget {
  final SSHService? sshService;

  const FileExplorerScreen({
    super.key,
    required this.sshService,
  });

  @override
  _FileExplorerScreenState createState() => _FileExplorerScreenState();
}

enum SortOption {
  foldersFirst,
  filesFirst,
  nameAZ,
  nameZA,
  sizeSmallLarge,
  sizeLargeSmall,
}

class _FileExplorerScreenState extends State<FileExplorerScreen> with AutomaticKeepAliveClientMixin<FileExplorerScreen> {
  String _currentPath = '/';
  List<FileEntity> _contents = [];
  bool _isLoading = false;
  String _errorMessage = '';
  Set<FileEntity> _selectedItems = {};
  bool _isSelectionMode = false;
  SortOption _sortOption = SortOption.foldersFirst;
  double _progress = 0.0;
  String _progressMessage = '';
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

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterContents);
    _loadCurrentDirectory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentDirectory() async {
    if (widget.sshService == null) {
      setState(() => _errorMessage = 'Not connected');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await widget.sshService!.executeCommand('ls -la "$_currentPath"');
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
    if (widget.sshService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not connected to server')),
      );
      return;
    }

    final result = await FilePicker.platform.pickFiles(allowMultiple: true, type: FileType.any);
    if (result == null || result.files.isEmpty) return;
    if (!widget.sshService!.isConnected()) {
      await widget.sshService!.reconnect();
    }

    setState(() {
      _isLoading = true;
      _isUploading = true;
      _progress = 0.0;  
      _progressMessage = 'Uploading files...';
    });

    try {
      int totalSize = result.files.fold(0, (sum, file) => sum + file.size);
      int uploadedSize = 0;

      for (int i = 0; i < result.files.length; i++) {
        if (_isCancelled) break;
        final file = result.files[i];

        if (file.path != null) {
          final localPath = file.path!;
          final fileName = file.name;
          final remotePath = '$_currentPath${_currentPath.endsWith('/') ? '' : '/'}$fileName';

          setState(() {
            _currentFileName = fileName;
            _sourcePath = localPath;
            _destinationPath = remotePath;
          });

          if (FileSystemEntity.isDirectorySync(localPath)) {
            await _uploadDirectory(localPath, remotePath);
          } else {
            await widget.sshService!.uploadFile(localPath, remotePath, (sent, total) {
              if (mounted) {
                setState(() {
                  uploadedSize = sent;  
                  _progress = uploadedSize / totalSize; 
                });
              }
            });
          }
        }
      }

      await _loadCurrentDirectory();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload Completed Successfully!')),
        );
      }

    } catch (e) {
      if (e.toString().contains('Not connected')) {
        await widget.sshService!.connect();
        await _uploadFile();
      } else {
        if (!mounted) return;
        setState(() {
          _errorMessage = 'Upload error: $e';
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isUploading = false;  
          _progress = 0.0;
          _progressMessage = '';
          _isCancelled = false;
          _currentFileName = '';
          _sourcePath = '';
          _destinationPath = '';
        });
      }
    }
  }

  Future<void> _uploadDirectory(String localPath, String remotePath) async {
  final directory = Directory(localPath);
  if (!directory.existsSync()) {
    return;
  }

  final List<FileSystemEntity> entities = await directory.list(recursive: true).toList();
  int totalSize = 0;
  for (final entity in entities.whereType<File>()) {
    totalSize += await entity.length();
  }
  int uploadedSize = 0;

  for (final entity in entities) {
    if (_isCancelled) break;
    final relativePath = entity.path.substring(localPath.length + 1);
    final remoteFilePath = '$remotePath/$relativePath';

    if (entity is Directory) {
      await widget.sshService!.executeCommand('mkdir -p "$remoteFilePath"');
    } else if (entity is File) {
      setState(() {
        _currentFileName = entity.path.split(Platform.pathSeparator).last;
        _sourcePath = entity.path;
        _destinationPath = remoteFilePath;
      });

      await widget.sshService!.uploadFile(
        entity.path,
        remoteFilePath,
        (sent, total) {
          if (mounted) {
            setState(() {
              uploadedSize += sent;
              _progress = uploadedSize / totalSize;
            });
          }
        },
      );
    }
  }
}

  Future<void> _uploadFolder() async {
    if (widget.sshService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not connected to server')),
      );
      return;
    }

    final String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      setState(() {
        _isLoading = true;
        _isUploading = true;
        _progressMessage = 'Uploading folder...';
      });

      try {
        final directoryName = selectedDirectory.split(Platform.pathSeparator).last;
        final remotePath = '$_currentPath${_currentPath.endsWith('/') ? '' : '/'}$directoryName';
        await widget.sshService!.executeCommand('mkdir -p "$remotePath"');
        await _uploadDirectory(selectedDirectory, remotePath);
        await _loadCurrentDirectory();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Uploaded folder: $directoryName')),
        );
      } catch (e) {
        if (e.toString().contains('Not connected')) {
          await widget.sshService!.connect();
          await _uploadFolder();
        } else {
          if (!mounted) return;
          setState(() {
            _errorMessage = 'Upload error: $e';
            _isLoading = false;
          });
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
            _progressMessage = '';
            _isCancelled = false;
          });
        }
      }
    }
  }

  Future<void> _downloadSelected() async {
    if (widget.sshService == null || _selectedItems.isEmpty) return;

    try {
      final String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory == null) return;

      setState(() {
        _isLoading = true;
        _isDownloading = true;
        _progressMessage = 'Downloading files...';
      });

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
          await widget.sshService!.downloadFile(remotePath, localPath);
        }
        setState(() {
          _progress = (i + 1) / _selectedItems.length;
        });
      }

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Downloaded ${_selectedItems.length} item(s)'),
          action: SnackBarAction(
            label: 'Open Folder',
            onPressed: () async {
              if (Platform.isWindows) {
                await Process.run('explorer.exe', [selectedDirectory]);
              } else if (Platform.isLinux) {
                await Process.run('xdg-open', [selectedDirectory]);
              } else if (Platform.isMacOS) {
                await Process.run('open', [selectedDirectory]);
              }
            },
          ),
        ),
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
          _progressMessage = '';
          _isCancelled = false;
        });
      }
    }
  }

  Future<void> _downloadDirectory(String remotePath, String localPath) async {
  final result = await widget.sshService!.executeCommand('ls -la "$remotePath"');
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
      await widget.sshService!.downloadFile(
        itemRemotePath, 
        itemLocalPath,
        (downloaded, total) {
          if (mounted) {
            setState(() {
              _progress = downloaded / total;
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
      _progressMessage = 'Deleting files...';
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
          _progressMessage = '';
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
      _progressMessage = 'Operation cancelled';
    });
  }

  Future<List<FileEntity>> _searchAllDirectories(String path, String query) async {
    List<FileEntity> results = [];
    try {
      // Search only from current path
      final searchCommand = 'cd "$path" && find . -iname "*$query*"';
      final result = await widget.sshService!.executeCommand(searchCommand);
      
      if (result.contains('No such file or directory') || result.trim().isEmpty) {
        return results;
      }

      final files = result.split('\n');
      for (var file in files) {
        if (file.trim().isEmpty || file == '.') continue;
        
        // Remove './' from the beginning of the path
        final cleanPath = file.startsWith('./') ? file.substring(2) : file;
        if (cleanPath.isEmpty) continue;

        final fullPath = '$path/${cleanPath}';
        try {
          final statResult = await widget.sshService!.executeCommand('ls -la "$fullPath"');
          final parts = statResult.trim().split(RegExp(r'\s+'));
          if (parts.length >= 9) {
            final permissions = parts[0];
            final size = parts[4];
            final name = fullPath.split('/').last;
            
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
        // Search from root if we're at root, otherwise search from current directory
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Center(child: CircularProgressIndicator()),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 200,
                        child: LinearProgressIndicator(value: _progress),
                      ),
                      const SizedBox(height: 10),
                      Text(_progressMessage),
                      const SizedBox(height: 10),
                      Center(child: Text('File: $_currentFileName')),
                      Center(child: Text('Source: $_sourcePath', textAlign: TextAlign.center)),
                      Center(child: Text('Destination: $_destinationPath', textAlign: TextAlign.center)),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _cancelOperation,
                        child: const Text('Cancel'),
                      ),
                    ],
                  )
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
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'ssh_service.dart';
import 'dart:io';

class FileTransferScreen extends StatefulWidget {
  final SSHService? sshService;

  const FileTransferScreen({
    super.key,
    required this.sshService,
  });

  @override
  _FileTransferScreenState createState() => _FileTransferScreenState();
}

enum SortOption {
  foldersFirst,
  filesFirst,
  nameAZ,
  nameZA,
  sizeSmallLarge,
  sizeLargeSmall,
}

class _FileTransferScreenState extends State<FileTransferScreen> with AutomaticKeepAliveClientMixin<FileTransferScreen> {
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

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadCurrentDirectory();
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
    switch (_sortOption) {
      case SortOption.foldersFirst:
        _contents.sort((a, b) {
          if (a.isDirectory && !b.isDirectory) return -1;
          if (!a.isDirectory && b.isDirectory) return 1;
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case SortOption.filesFirst:
        _contents.sort((a, b) {
          if (a.isDirectory && !b.isDirectory) return 1;
          if (!a.isDirectory && b.isDirectory) return -1;
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case SortOption.nameAZ:
        _contents.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case SortOption.nameZA:
        _contents.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
      case SortOption.sizeSmallLarge:
        _contents.sort((a, b) => int.parse(a.size).compareTo(int.parse(b.size)));
        break;
      case SortOption.sizeLargeSmall:
        _contents.sort((a, b) => int.parse(b.size).compareTo(int.parse(a.size)));
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
    if (result != null && result.files.isNotEmpty) {
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
        if (!mounted) return;
        setState(() {
          _errorMessage = 'Upload error: $e';
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload: $e')),
        );
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
  }

  Future<void> _uploadDirectory(String localPath, String remotePath) async {
    final directory = Directory(localPath);
    if (!directory.existsSync()) {
      return;
    }

    final List<FileSystemEntity> entities = directory.listSync(recursive: true);
    int totalSize = entities.whereType<File>().fold(0, (sum, file) => sum + file.lengthSync());
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
                uploadedSize = sent;
                _progress = uploadedSize / totalSize;
              });
            }
          },
        );
      }
    }
    if (mounted) {
      setState(() {
        _isUploading = false; 
        _isLoading = false;
      });
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
        if (!mounted) return;
        setState(() {
          _errorMessage = 'Upload error: $e';
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload folder: $e')),
        );
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
      if (!mounted) return;
      
      setState(() => _errorMessage = 'Download error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download: $e')),
      );
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

    final directory = Directory(localPath);
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }

    for (final item in contents) {
      if (_isCancelled) break;
      final itemRemotePath = '$remotePath/${item.name}';
      final itemLocalPath = '$localPath${Platform.pathSeparator}${item.name}';
      if (item.isDirectory) {
        await _downloadDirectory(itemRemotePath, itemLocalPath);
      } else {
        await widget.sshService!.downloadFile(itemRemotePath, itemLocalPath);
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
      if (!mounted) return;

      setState(() => _errorMessage = 'Delete error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete: $e')),
      );
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        title: Text(_currentPath),
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
                Center(child: Text('Source: $_sourcePath')),
                Center(child: Text('Destination: $_destinationPath')),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _cancelOperation,
                  child: const Text('Cancel'),
                ),
              ],
            )
          : _isLoading
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
                            itemCount: _contents.length,
                            itemBuilder: (context, index) {
                              final item = _contents[index];
                              final bool isSelected = _selectedItems.contains(item);

                              return ListTile(
                                leading: Icon(
                                  item.isDirectory ? Icons.folder : Icons.insert_drive_file,
                                  color: item.isDirectory ? Colors.blue : null,
                                ),
                                title: Text(item.name),
                                subtitle: Text('${item.size} ${item.permissions}'),
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
    );
  }
}

class FileEntity {
  final String name;
  final bool isDirectory;
  final String size;
  final String permissions;

  FileEntity({
    required this.name,
    required this.isDirectory,
    required this.size,
    required this.permissions,
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
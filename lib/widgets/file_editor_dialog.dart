import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/file_item.dart';
import '../providers/file_providers.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

class FileEditorDialog extends ConsumerStatefulWidget {
  final FileItem file;

  const FileEditorDialog({
    super.key,
    required this.file,
  });

  @override
  ConsumerState<FileEditorDialog> createState() => _FileEditorDialogState();
}

class _FileEditorDialogState extends ConsumerState<FileEditorDialog> {
  late TextEditingController _controller;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasUnsavedChanges = false;
  String? _error;
  String _originalContent = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(() {
      if (!_hasUnsavedChanges && _controller.text != _originalContent) {
        setState(() {
          _hasUnsavedChanges = true;
        });
      }
    });
    _loadFile();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadFile() async {
    final sftp = ref.read(sftpServiceProvider);
    if (sftp == null) {
      setState(() {
        _error = 'SFTP service not available';
        _isLoading = false;
      });
      return;
    }

    try {
      final data = await sftp.readFile(widget.file.path);
      final content = utf8.decode(data);
      
      setState(() {
        _originalContent = content;
        _controller.text = content;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load file: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveFile() async {
    final sftp = ref.read(sftpServiceProvider);
    if (sftp == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final data = Uint8List.fromList(utf8.encode(_controller.text));
      await sftp.writeFile(widget.file.path, data);
      
      setState(() {
        _originalContent = _controller.text;
        _hasUnsavedChanges = false;
        _isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool> _confirmDiscard() async {
    if (!_hasUnsavedChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text('You have unsaved changes. Do you want to discard them?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        final canClose = await _confirmDiscard();
        if (canClose && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: GlassCard(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.85,
            child: Column(
              children: [
                // Header
                _buildHeader(),
                const Divider(height: 1),
                
                // Editor
                Expanded(
                  child: _buildEditor(),
                ),
                
                // Footer with stats
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(Icons.edit_note, color: AppTheme.primaryIndigo),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.file.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_hasUnsavedChanges)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: const Text(
                          'Modified',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                Text(
                  widget.file.path,
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Save button
          if (_hasUnsavedChanges && !_isSaving)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveFile,
              tooltip: 'Save (Ctrl+S)',
              color: AppTheme.secondaryTeal,
            ),
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          // Close button
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              final canClose = await _confirmDiscard();
              if (canClose && mounted) {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEditor() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _error = null;
                  _isLoading = true;
                });
                _loadFile();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Container(
      color: Colors.black.withOpacity(0.3),
      child: TextField(
        controller: _controller,
        maxLines: null,
        expands: true,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 14,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    final lines = _controller.text.split('\n').length;
    final chars = _controller.text.length;
    final selection = _controller.selection;
    final cursor = selection.baseOffset;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        border: const Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Lines: $lines | Characters: $chars',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (cursor >= 0)
            Text(
              'Cursor: $cursor',
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
    );
  }
}

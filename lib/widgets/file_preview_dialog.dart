import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/file_item.dart';
import '../providers/file_providers.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

class FilePreviewDialog extends ConsumerStatefulWidget {
  final FileItem file;

  const FilePreviewDialog({
    super.key,
    required this.file,
  });

  @override
  ConsumerState<FilePreviewDialog> createState() => _FilePreviewDialogState();
}

class _FilePreviewDialogState extends ConsumerState<FilePreviewDialog> {
  bool _isLoading = true;
  String? _content;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFile();
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
      
      if (widget.file.isTextFile) {
        setState(() {
          _content = utf8.decode(data);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Cannot preview this file type';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load file: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassCard(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(widget.file.icon, color: widget.file.color),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.file.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            widget.file.formattedSize,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              
              // Content
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
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
          ],
        ),
      );
    }

    if (_content == null) {
      return const Center(
        child: Text('No content to display'),
      );
    }

    // Show different preview based on file type
    if (widget.file.isImage) {
      return _buildImagePreview();
    } else if (widget.file.isTextFile) {
      return _buildTextPreview();
    }

    return const Center(
      child: Text('Preview not available for this file type'),
    );
  }

  Widget _buildTextPreview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SelectableText(
        _content!,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 12,
          color: _getTextColor(),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return const Center(
      child: Text('Image preview not yet implemented'),
    );
  }

  Color _getTextColor() {
    // Basic color coding based on file type
    switch (widget.file.extension) {
      case 'json':
      case 'yaml':
      case 'yml':
        return AppTheme.secondaryTeal;
      case 'log':
        return Colors.grey;
      case 'sh':
      case 'bash':
        return Colors.green;
      default:
        return Colors.white;
    }
  }
}

/// Simple syntax highlighter for code files
class SyntaxHighlighter {
  static TextSpan highlight(String code, String extension) {
    final lines = code.split('\n');
    final spans = <TextSpan>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      
      // Line number
      spans.add(TextSpan(
        text: '${(i + 1).toString().padLeft(4)} │ ',
        style: const TextStyle(
          color: Colors.grey,
          fontFamily: 'monospace',
        ),
      ));

      // Syntax highlighting based on extension
      spans.add(_highlightLine(line, extension));
      
      if (i < lines.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }

    return TextSpan(children: spans);
  }

  static TextSpan _highlightLine(String line, String extension) {
    // Basic keyword highlighting
    final keywords = _getKeywords(extension);
    final comments = _getCommentStyle(extension);
    
    // Check for comments
    if (comments != null && line.trimLeft().startsWith(comments)) {
      return TextSpan(
        text: line,
        style: const TextStyle(
          color: Colors.grey,
          fontStyle: FontStyle.italic,
          fontFamily: 'monospace',
        ),
      );
    }

    // Highlight keywords
    final words = line.split(RegExp(r'\s+'));
    final spans = <InlineSpan>[];
    
    for (var i = 0; i < words.length; i++) {
      final word = words[i];
      
      if (keywords.contains(word)) {
        spans.add(TextSpan(
          text: word,
          style: const TextStyle(
            color: AppTheme.primaryIndigo,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ));
      } else if (word.startsWith('"') || word.startsWith("'")) {
        spans.add(TextSpan(
          text: word,
          style: const TextStyle(
            color: Colors.green,
            fontFamily: 'monospace',
          ),
        ));
      } else if (RegExp(r'^\d+$').hasMatch(word)) {
        spans.add(TextSpan(
          text: word,
          style: const TextStyle(
            color: Colors.orange,
            fontFamily: 'monospace',
          ),
        ));
      } else {
        spans.add(TextSpan(
          text: word,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'monospace',
          ),
        ));
      }
      
      if (i < words.length - 1) {
        spans.add(const TextSpan(text: ' '));
      }
    }

    return TextSpan(children: spans);
  }

  static Set<String> _getKeywords(String extension) {
    switch (extension) {
      case 'dart':
        return {
          'class', 'extends', 'implements', 'with', 'abstract', 'interface',
          'if', 'else', 'for', 'while', 'do', 'switch', 'case', 'default',
          'return', 'break', 'continue', 'try', 'catch', 'finally', 'throw',
          'var', 'final', 'const', 'void', 'int', 'double', 'String', 'bool',
          'List', 'Map', 'Set', 'Future', 'async', 'await', 'import', 'export',
        };
      case 'java':
        return {
          'public', 'private', 'protected', 'class', 'interface', 'extends',
          'implements', 'if', 'else', 'for', 'while', 'do', 'switch', 'case',
          'return', 'break', 'continue', 'try', 'catch', 'finally', 'throw',
          'int', 'long', 'double', 'float', 'boolean', 'void', 'String',
          'import', 'package', 'static', 'final', 'abstract',
        };
      case 'py':
        return {
          'def', 'class', 'if', 'elif', 'else', 'for', 'while', 'return',
          'import', 'from', 'as', 'try', 'except', 'finally', 'raise',
          'with', 'lambda', 'yield', 'pass', 'break', 'continue',
          'True', 'False', 'None', 'and', 'or', 'not', 'in', 'is',
        };
      case 'js':
      case 'ts':
        return {
          'function', 'const', 'let', 'var', 'if', 'else', 'for', 'while',
          'return', 'break', 'continue', 'try', 'catch', 'finally', 'throw',
          'class', 'extends', 'import', 'export', 'default', 'async', 'await',
          'new', 'this', 'super', 'typeof', 'instanceof',
        };
      case 'sh':
      case 'bash':
        return {
          'if', 'then', 'else', 'elif', 'fi', 'for', 'while', 'do', 'done',
          'case', 'esac', 'function', 'return', 'exit', 'echo', 'read',
          'export', 'source', 'cd', 'pwd', 'mkdir', 'rm', 'cp', 'mv',
        };
      default:
        return {};
    }
  }

  static String? _getCommentStyle(String extension) {
    switch (extension) {
      case 'dart':
      case 'java':
      case 'js':
      case 'ts':
      case 'cpp':
      case 'c':
        return '//';
      case 'py':
      case 'sh':
      case 'bash':
      case 'yaml':
      case 'yml':
        return '#';
      default:
        return null;
    }
  }
}

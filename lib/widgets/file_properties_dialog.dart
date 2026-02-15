import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/file_item.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

class FilePropertiesDialog extends StatelessWidget {
  final FileItem file;

  const FilePropertiesDialog({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassCard(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Icon(file.icon, size: 64, color: file.color),
              const SizedBox(height: 16),
              Text(
                file.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                file.formattedSize,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              const SizedBox(height: 24),

              // Properties Grid
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildPropertyGroup(
                        context,
                        'Location',
                        [
                          _PropertyItem(
                            label: 'Path',
                            value: file.path,
                            canCopy: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildPropertyGroup(
                        context,
                        'Details',
                        [
                          _PropertyItem(label: 'Type', value: file.isDirectory ? 'Directory' : 'File (${file.extension})'),
                          if (!file.isDirectory) _PropertyItem(label: 'Size', value: '${file.size} bytes'),
                          _PropertyItem(label: 'Modified', value: _formatDate(file.modified)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildPropertyGroup(
                        context,
                        'Permissions',
                        [
                          _PropertyItem(label: 'String', value: file.permissionsString),
                          _PropertyItem(label: 'Octal', value: file.permissionsOctal),
                          _PropertyItem(label: 'Owner', value: file.owner),
                          _PropertyItem(label: 'Group', value: file.group),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyGroup(BuildContext context, String title, List<_PropertyItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.textTertiary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            children: items.map((item) => _buildPropertyRow(context, item)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyRow(BuildContext context, _PropertyItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.05),
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              item.label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              item.value,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontFamily: 'RobotoMono', // Monospace for values usually looks better
              ),
            ),
          ),
          if (item.canCopy) ...[
            const SizedBox(width: 8),
            InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: item.value));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Copied ${item.label} to clipboard'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.copy, size: 14, color: AppTheme.textTertiary),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
           '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _PropertyItem {
  final String label;
  final String value;
  final bool canCopy;

  _PropertyItem({
    required this.label,
    required this.value,
    this.canCopy = false,
  });
}

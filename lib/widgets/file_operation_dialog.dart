import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/file_item.dart';
import 'file_editor_dialog.dart';

class FileOperationDialog extends StatelessWidget {
  final FileItem file;
  final VoidCallback onDownload;
  final VoidCallback onDelete;
  final Function(String newName) onRename;
  final Function(int permissions) onChmod;

  const FileOperationDialog({
    super.key,
    required this.file,
    required this.onDownload,
    required this.onDelete,
    required this.onRename,
    required this.onChmod,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(file.icon, color: file.color, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        file.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        file.path,
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // File info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow(context, 'Size', file.formattedSize),
                _buildInfoRow(context, 'Permissions', file.permissionsString),
                _buildInfoRow(context, 'Octal', file.permissionsOctal),
                _buildInfoRow(context, 'Modified', _formatDate(file.modified)),
                _buildInfoRow(context, 'Owner', file.owner),
                _buildInfoRow(context, 'Group', file.group),
              ],
            ),
          ),

          const Divider(height: 1),

          // Actions
          ListTile(
            leading: Icon(file.isDirectory ? Icons.folder_zip : Icons.download),
            title: Text(file.isDirectory ? 'Download Folder' : 'Download'),
            onTap: () {
              Navigator.pop(context);
              onDownload();
            },
          ),
          if (!file.isDirectory && file.isTextFile)
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => FileEditorDialog(file: file),
                );
              },
            ),
          ListTile(
            leading: const Icon(Icons.drive_file_rename_outline),
            title: const Text('Rename'),
            onTap: () {
              Navigator.pop(context);
              _showRenameDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Change Permissions'),
            onTap: () {
              Navigator.pop(context);
              _showChmodDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Properties'),
            onTap: () {
              Navigator.pop(context);
              _showPropertiesDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete', style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.pop(context);
              final confirmed = await _showDeleteConfirmation(context);
              if (confirmed) {
                onDelete();
              }
            },
          ),
          const SizedBox(height: 16),
        ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _showRenameDialog(BuildContext context) async {
    final controller = TextEditingController(text: file.name);
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'New name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Rename'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && result != file.name) {
      onRename(result);
    }
  }

  Future<void> _showChmodDialog(BuildContext context) async {
    int ownerRead = (file.permissions & 0x100) != 0 ? 1 : 0;
    int ownerWrite = (file.permissions & 0x80) != 0 ? 1 : 0;
    int ownerExec = (file.permissions & 0x40) != 0 ? 1 : 0;
    int groupRead = (file.permissions & 0x20) != 0 ? 1 : 0;
    int groupWrite = (file.permissions & 0x10) != 0 ? 1 : 0;
    int groupExec = (file.permissions & 0x8) != 0 ? 1 : 0;
    int otherRead = (file.permissions & 0x4) != 0 ? 1 : 0;
    int otherWrite = (file.permissions & 0x2) != 0 ? 1 : 0;
    int otherExec = (file.permissions & 0x1) != 0 ? 1 : 0;

    await showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: StatefulBuilder(
        builder: (context, setState) {
          int calculatePermissions() {
            return (ownerRead << 8) | (ownerWrite << 7) | (ownerExec << 6) |
                   (groupRead << 5) | (groupWrite << 4) | (groupExec << 3) |
                   (otherRead << 2) | (otherWrite << 1) | otherExec;
          }

          String getOctal() {
            final owner = (ownerRead * 4) + (ownerWrite * 2) + ownerExec;
            final group = (groupRead * 4) + (groupWrite * 2) + groupExec;
            final other = (otherRead * 4) + (otherWrite * 2) + otherExec;
            return '$owner$group$other';
          }

          return AlertDialog(
            title: const Text('Change Permissions'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Octal: ${getOctal()}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildPermissionRow('Owner', ownerRead == 1, ownerWrite == 1, ownerExec == 1, 
                  (r) => setState(() => ownerRead = r ? 1 : 0),
                  (w) => setState(() => ownerWrite = w ? 1 : 0),
                  (x) => setState(() => ownerExec = x ? 1 : 0),
                ),
                _buildPermissionRow('Group', groupRead == 1, groupWrite == 1, groupExec == 1, 
                  (r) => setState(() => groupRead = r ? 1 : 0),
                  (w) => setState(() => groupWrite = w ? 1 : 0),
                  (x) => setState(() => groupExec = x ? 1 : 0),
                ),
                _buildPermissionRow('Other', otherRead == 1, otherWrite == 1, otherExec == 1, 
                  (r) => setState(() => otherRead = r ? 1 : 0),
                  (w) => setState(() => otherWrite = w ? 1 : 0),
                  (x) => setState(() => otherExec = x ? 1 : 0),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  onChmod(calculatePermissions());
                },
                child: const Text('Apply'),
              ),
            ],
          );
        },
        ),
      ),
    );
  }

  Widget _buildPermissionRow(
    String label,
    bool read,
    bool write,
    bool execute,
    Function(bool) onReadChanged,
    Function(bool) onWriteChanged,
    Function(bool) onExecuteChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPermissionCheckbox('R', read, onReadChanged),
                _buildPermissionCheckbox('W', write, onWriteChanged),
                _buildPermissionCheckbox('X', execute, onExecuteChanged),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionCheckbox(String label, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label),
        Checkbox(
          value: value,
          onChanged: (val) => onChanged(val ?? false),
        ),
      ],
    );
  }

  Future<void> _showPropertiesDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
        title: const Text('Properties'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPropertyItem('Name', file.name),
            _buildPropertyItem('Path', file.path),
            _buildPropertyItem('Type', file.isDirectory ? 'Directory' : 'File'),
            if (!file.isDirectory) _buildPropertyItem('Extension', file.extension),
            _buildPropertyItem('Size', file.formattedSize),
            _buildPropertyItem('Permissions', '${file.permissionsString} (${file.permissionsOctal})'),
            _buildPropertyItem('Modified', _formatDate(file.modified)),
            _buildPropertyItem('Owner', file.owner),
            _buildPropertyItem('Group', file.group),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildPropertyItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 14),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          title: const Text('Delete File'),
          content: Text('Are you sure you want to delete "${file.name}"?'),
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
    return result ?? false;
  }
}

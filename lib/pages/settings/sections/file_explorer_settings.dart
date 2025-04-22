import 'package:flutter/material.dart';
import '../utils/settings_utils.dart';

class FileExplorerSettings extends StatelessWidget {
  final bool showHiddenFiles;
  final Function(bool) onShowHiddenFilesChanged;
  final bool confirmBeforeOverwrite;
  final Function(bool) onConfirmBeforeOverwriteChanged;
  final String defaultDownloadDirectory;
  final Function() pickDefaultDirectory;
  final Function() clearDefaultDirectory;
  final Function() saveSettings;

  const FileExplorerSettings({
    Key? key,
    required this.showHiddenFiles,
    required this.onShowHiddenFilesChanged,
    required this.confirmBeforeOverwrite,
    required this.onConfirmBeforeOverwriteChanged,
    required this.defaultDownloadDirectory,
    required this.pickDefaultDirectory,
    required this.clearDefaultDirectory,
    required this.saveSettings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsUtils.buildSectionHeader(context, 'File Explorer Settings'),
        
        SwitchListTile(
          secondary: const Icon(Icons.visibility),
          title: const Text('Show Hidden Files'),
          subtitle: const Text('Display files starting with a dot (.)'),
          value: showHiddenFiles,
          onChanged: (value) {
            onShowHiddenFilesChanged(value);
            saveSettings();
          },
        ),
        
        SwitchListTile(
          secondary: const Icon(Icons.warning),
          title: const Text('Confirm File Overwrite'),
          subtitle: const Text('Ask before replacing existing files'),
          value: confirmBeforeOverwrite,
          onChanged: (value) {
            onConfirmBeforeOverwriteChanged(value);
            saveSettings();
          },
        ),
        
        ListTile(
          leading: const Icon(Icons.folder),
          title: const Text('Default Download Directory'),
          subtitle: Text(defaultDownloadDirectory.isEmpty 
              ? 'Not set (will ask each time)' 
              : defaultDownloadDirectory),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (defaultDownloadDirectory.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: clearDefaultDirectory,
                  tooltip: 'Clear default directory',
                ),
              IconButton(
                icon: const Icon(Icons.folder_open),
                onPressed: pickDefaultDirectory,
                tooltip: 'Select default directory',
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

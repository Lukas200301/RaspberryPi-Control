import 'package:flutter/material.dart';
import '../utils/settings_utils.dart';

class DataManagementSettings extends StatelessWidget {
  final Function() clearAppData;

  const DataManagementSettings({
    Key? key, 
    required this.clearAppData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsUtils.buildSectionHeader(context, 'Data Management'),
        ListTile(
          leading: const Icon(Icons.delete_forever, color: Colors.red),
          title: const Text('Clear App Data'),
          subtitle: const Text('Reset all settings and delete saved connections (cannot be undone)'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: clearAppData,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

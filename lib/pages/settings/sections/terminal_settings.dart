import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/settings_utils.dart';

class TerminalSettings extends StatefulWidget {
  final String terminalFontSize;
  final Function(String) onFontSizeChanged;
  final Function() saveSettings;

  const TerminalSettings({
    Key? key,
    required this.terminalFontSize,
    required this.onFontSizeChanged,
    required this.saveSettings,
  }) : super(key: key);

  @override
  State<TerminalSettings> createState() => _TerminalSettingsState();
}

class _TerminalSettingsState extends State<TerminalSettings> {
  late TextEditingController _fontSizeController;
  
  @override
  void initState() {
    super.initState();
    _fontSizeController = TextEditingController(text: widget.terminalFontSize);
    _refreshFontSizeFromPrefs();
  }
  
  @override
  void didUpdateWidget(TerminalSettings oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.terminalFontSize != widget.terminalFontSize) {
      _fontSizeController.text = widget.terminalFontSize;
    }
  }
  
  @override
  void dispose() {
    _fontSizeController.dispose();
    super.dispose();
  }
  
  Future<void> _refreshFontSizeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final storedFontSize = prefs.getString('terminalFontSize') ?? '14';
    
    if (mounted && storedFontSize != _fontSizeController.text) {
      setState(() {
        _fontSizeController.text = storedFontSize;
      });
      widget.onFontSizeChanged(storedFontSize);
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshFontSizeFromPrefs();
    });
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsUtils.buildSectionHeader(context, 'Terminal Settings'),
        ListTile(
          leading: const Icon(Icons.text_fields),
          title: const Text('Terminal Font Size'),
          subtitle: const Text('Adjust text size for better readability in terminal'),
          trailing: SizedBox(
            width: 70,
            child: TextFormField(
              controller: _fontSizeController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              onChanged: (value) async {
                widget.onFontSizeChanged(value);
                
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('terminalFontSize', value);
                
                widget.saveSettings();
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

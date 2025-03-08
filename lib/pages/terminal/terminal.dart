import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/ssh_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Terminal extends StatefulWidget {
  final SSHService? sshService;
  final TextEditingController commandController;
  final String commandOutput;
  final VoidCallback sendCommand;

  const Terminal({
    super.key,
    required this.sshService,
    required this.commandController,
    required this.commandOutput,
    required this.sendCommand,
  });

  @override
  TerminalState createState() => TerminalState();
}

class TerminalState extends State<Terminal> {
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  List<String> _commandHistory = [];
  int _historyIndex = -1;
  double _fontSize = 14.0;
  final int _maxHistorySize = 50; 

  @override
  void initState() {
    super.initState();
    _loadTerminalSettings();
    _setupSettingsListener();
  }

  void _setupSettingsListener() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForSettingsChanges();
    });
  }

  Future<void> _checkForSettingsChanges() async {
    if (!mounted) return;
    
    await _loadTerminalSettings();
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _checkForSettingsChanges();
      }
    });
  }

  Future<void> _loadTerminalSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final newFontSize = double.tryParse(prefs.getString('terminalFontSize') ?? '14') ?? 14.0;
    
    
    if (newFontSize != _fontSize) {
      setState(() {
        _fontSize = newFontSize;
      });
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendCommand() async {
    final command = widget.commandController.text.trim();
    if (command.isNotEmpty) {
      if (_commandHistory.isEmpty || _commandHistory.last != command) {
        _commandHistory.add(command);
        if (_commandHistory.length > _maxHistorySize) {
          _commandHistory = _commandHistory.sublist(_commandHistory.length - _maxHistorySize);
        }
      }
      _historyIndex = _commandHistory.length;
      widget.sendCommand();
    }
    _focusNode.requestFocus();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void _handleKeyPress(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey.keyLabel == 'Arrow Up') {
        _navigateHistory(-1);
      } else if (event.logicalKey.keyLabel == 'Arrow Down') {
        _navigateHistory(1);
      }
    }
  }

  void _navigateHistory(int direction) {
    if (_commandHistory.isEmpty) return;

    setState(() {
      _historyIndex += direction;
      if (_historyIndex >= _commandHistory.length) {
        _historyIndex = _commandHistory.length;
        widget.commandController.text = '';
      } else if (_historyIndex < 0) {
        _historyIndex = 0;
      }

      if (_historyIndex < _commandHistory.length) {
        widget.commandController.text = _commandHistory[_historyIndex];
        widget.commandController.selection = TextSelection.fromPosition(
          TextPosition(offset: widget.commandController.text.length),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              child: SelectableText(
                widget.commandOutput,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: _fontSize, 
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border(
                top: BorderSide(
                  color: Colors.grey[850]!,
                  width: 1,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              children: [
                const Text(
                  '\$',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RawKeyboardListener(
                    focusNode: FocusNode(),
                    onKey: _handleKeyPress,
                    child: TextField(
                      controller: widget.commandController,
                      focusNode: _focusNode,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter command',
                        hintStyle: TextStyle(
                          color: isDarkMode ? Colors.grey : Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                      onSubmitted: (value) => _sendCommand(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
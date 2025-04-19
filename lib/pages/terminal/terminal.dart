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

  List<String> _autocompleteSuggestions = [];
  final List<String> _allCommands = [
    'ls', 'cd', 'pwd', 'mkdir', 'rm', 'touch', 'echo', 'cat', 'grep',
    'tail', 'head', 'exit', 'clear', 'chmod', 'chown', 'cp', 'mv', 'nano',
    'vim', 'top', 'ps', 'kill', 'ssh', 'scp', 'find', 'du', 'df', 'tar',
  ];

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
    setState(() {
      _autocompleteSuggestions.clear();
    });
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
      } else if (event.logicalKey == LogicalKeyboardKey.tab) {
        _sendTabCompletion();
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

  void _updateAutocompleteSuggestions(String input) {
    setState(() {
      if (input.trim().isEmpty) {
        _autocompleteSuggestions.clear();
      } else {
        _autocompleteSuggestions = _allCommands
            .where((cmd) => cmd.startsWith(input))
            .toList();
      }
    });
  }

  void _sendTabCompletion() {
    final text = widget.commandController.text;
    final words = text.split(' ');

    if (_autocompleteSuggestions.isNotEmpty) {
      final replacement = _autocompleteSuggestions.first;

      words[words.length - 1] = replacement;
      final newText = words.join(' ');

      setState(() {
        widget.commandController.text = newText;
        widget.commandController.selection = TextSelection.fromPosition(
          TextPosition(offset: newText.length),
        );
        _autocompleteSuggestions.clear();
      });
    }

    _focusNode.requestFocus();
  }

  void _sendControlSequence(String key) {
    if (widget.sshService != null) {
      if (key == 'C') {
        widget.sshService!.executeCommand('\x03');
      } else if (key == 'D') {
        widget.sshService!.executeCommand('\x04');
      } else if (key == 'Z') {
        widget.sshService!.executeCommand('\x1A');
      }
      _focusNode.requestFocus();
    }
  }

  void _insertText(String text) {
    final currentText = widget.commandController.text;
    final selection = widget.commandController.selection;
    final newText = currentText.replaceRange(selection.start, selection.end, text);

    widget.commandController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: selection.start + text.length),
    );
    _focusNode.requestFocus();
  }

  void _moveCursor(int direction) {
    final selection = widget.commandController.selection;
    int newPosition = selection.baseOffset + direction;
    newPosition = newPosition.clamp(0, widget.commandController.text.length);
    widget.commandController.selection = TextSelection.collapsed(offset: newPosition);
    _focusNode.requestFocus();
  }

  Widget _buildSpecialKeyButton(String label, VoidCallback onPressed) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDarkMode ? Colors.grey[850] : Colors.grey[300],
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
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
            height: 48,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[900] : Colors.grey[200],
              border: Border(
                top: BorderSide(
                  color: isDarkMode ? Colors.grey[800]! : Colors.grey[400]!,
                  width: 1,
                ),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  children: [
                    _buildSpecialKeyButton('Tab', _sendTabCompletion),
                    _buildSpecialKeyButton('Ctrl+C', () => _sendControlSequence('C')),
                    _buildSpecialKeyButton('Ctrl+D', () => _sendControlSequence('D')),
                    _buildSpecialKeyButton('Ctrl+Z', () => _sendControlSequence('Z')),
                    _buildSpecialKeyButton('←', () => _moveCursor(-1)),
                    _buildSpecialKeyButton('→', () => _moveCursor(1)),
                    _buildSpecialKeyButton('|', () => _insertText('|')),
                    _buildSpecialKeyButton('&', () => _insertText('&')),
                    _buildSpecialKeyButton(';', () => _insertText(';')),
                    _buildSpecialKeyButton('>', () => _insertText('>')),
                    _buildSpecialKeyButton('<', () => _insertText('<')),
                    _buildSpecialKeyButton('*', () => _insertText('*')),
                    _buildSpecialKeyButton('~', () => _insertText('~')),
                    _buildSpecialKeyButton('Send', _sendCommand),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border(
                top: BorderSide(color: Colors.grey[850]!, width: 1),
              ),
            ),
            child: Column(
              children: [
                Row(
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
                          onChanged: (value) {
                            final words = value.trim().split(' ');
                            if (words.isNotEmpty) {
                              _updateAutocompleteSuggestions(words.last);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                if (_autocompleteSuggestions.isNotEmpty)
                  Container(
                    alignment: Alignment.centerLeft,
                    color: isDarkMode ? Colors.black : Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _autocompleteSuggestions
                          .map(
                            (s) => GestureDetector(
                              onTap: () {
                                final words = widget.commandController.text.split(' ');
                                words[words.length - 1] = s;
                                final newText = words.join(' ');
                                setState(() {
                                  widget.commandController.text = newText;
                                  widget.commandController.selection = TextSelection.fromPosition(
                                    TextPosition(offset: newText.length),
                                  );
                                  _autocompleteSuggestions.clear();
                                });
                                _focusNode.requestFocus();
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Text(
                                  s,
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 14,
                                    color: isDarkMode ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
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

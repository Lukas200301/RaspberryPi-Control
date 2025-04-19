import 'package:flutter/material.dart';
import '../../services/ssh_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:xterm/xterm.dart' as xterm;

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
  late xterm.Terminal _terminal;
  final FocusNode _focusNode = FocusNode();
  double _fontSize = 14.0;
  
  StreamSubscription? _shellSubscription;
  bool _isInteractiveMode = false;
  bool _ctrlPressed = false;

  int _terminalColumns = 80;
  int _terminalRows = 25;

  @override
  void initState() {
    super.initState();
    _terminal = xterm.Terminal();
    
    _terminal.onOutput = (data) {
      if (_isInteractiveMode && widget.sshService != null) {
        widget.sshService!.sendToShell(data);
      }
    };
    
    _setupTerminalResize();
    
    _loadTerminalSettings();
    _setupSettingsListener();
    _initInteractiveShell();
  }
  
  @override
  void dispose() {
    _shellSubscription?.cancel();
    if (widget.sshService != null) {
      widget.sshService!.closeShell();
    }
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadTerminalSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final newFontSize = double.tryParse(prefs.getString('terminalFontSize') ?? '14') ?? 14.0;

    if (mounted) {
      setState(() {
        _fontSize = newFontSize;
      });
    }
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

  void _handleShellOutput(String data) {
    _terminal.write(data);
  }

  void _setupTerminalResize() {
    _terminal.onResize = (w, h, pw, ph) {
      if (widget.sshService != null && _isInteractiveMode) {
        setState(() {
          _terminalColumns = w;
          _terminalRows = h;
        });
        widget.sshService!.resizeShell(w, h);
      }
    };
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateAndApplyTerminalSize();
    });
  }
  
  void _calculateAndApplyTerminalSize() {
    final size = MediaQuery.of(context).size;
    final availableHeight = size.height - 56 - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom - 16;
    final availableWidth = size.width - 16;  
    final columns = (availableWidth / 8).floor();
    final rows = (availableHeight / 16).floor();
    
    final effectiveColumns = columns > 20 ? columns : 20;
    final effectiveRows = rows > 10 ? rows : 10;
    
    setState(() {
      _terminalColumns = effectiveColumns;
      _terminalRows = effectiveRows;
    });
    
    _terminal.resize(effectiveColumns, effectiveRows);
    
    if (widget.sshService != null && _isInteractiveMode) {
      widget.sshService!.resizeShell(effectiveColumns, effectiveRows);
    }
  }

  Future<void> _initInteractiveShell() async {
    if (widget.sshService != null && widget.sshService!.isConnected()) {
      try {
        _terminal.write('Connecting to SSH...\r\n');
        
        await widget.sshService!.startShell(
          width: _terminalColumns, 
          height: _terminalRows
        );
        
        _shellSubscription = widget.sshService!.shellOutput.listen(_handleShellOutput);
        
        setState(() {
          _isInteractiveMode = true;
        });
        
        _calculateAndApplyTerminalSize();
        
      } catch (e) {
        print('Failed to initialize interactive shell: $e');
        setState(() {
          _isInteractiveMode = false;
          _terminal.write('Failed to start interactive shell: $e\r\n');
          _terminal.write('Falling back to basic command mode.\r\n');
        });
      }
    } else {
      _terminal.write('No SSH connection available. Please connect first.\r\n');
    }
  }

  @override
  void didUpdateWidget(Terminal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sshService != widget.sshService) {
      _shellSubscription?.cancel();
      _initInteractiveShell();
    }
  }

  void _sendControlSequence(String key) {
    if (widget.sshService != null && _isInteractiveMode) {
      final int charCode = key.codeUnitAt(0) - 64; 
      if (charCode > 0 && charCode < 27) {
        final String ctrlChar = String.fromCharCode(charCode);
        widget.sshService!.sendToShell(ctrlChar);
      }
    }
    
    setState(() {
      _ctrlPressed = false;
    });
    _focusNode.requestFocus();
  }

  void _toggleCtrl() {
    setState(() {
      _ctrlPressed = !_ctrlPressed;
    });
    _focusNode.requestFocus();
  }

  void _sendSpecialKey(String sequence) {
    if (widget.sshService != null && _isInteractiveMode) {
      widget.sshService!.sendToShell(sequence);
    }
  }

  Widget _buildSpecialKeyButton(String label, VoidCallback onPressed, {bool isActive = false}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isActionButton = label == 'Send';
    final isCtrlButton = label == 'Ctrl';
    
    final Color buttonColor = isCtrlButton && isActive
        ? Colors.green.shade700 
        : isActionButton 
            ? Theme.of(context).colorScheme.primary 
            : (isDarkMode ? Colors.grey[800]! : Colors.grey[200]!);
    
    final Color textColor = isCtrlButton && isActive
        ? Colors.white
        : isActionButton 
            ? Colors.white
            : (isDarkMode ? Colors.grey[200]! : Colors.grey[800]!);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Material(
        color: buttonColor,
        borderRadius: BorderRadius.circular(8),
        elevation: 2,
        shadowColor: isDarkMode ? Colors.black54 : Colors.black26,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          splashColor: isActionButton 
              ? Theme.of(context).colorScheme.primary.withOpacity(0.3) 
              : (isDarkMode ? Colors.grey[700] : Colors.grey[300]),
          highlightColor: isActionButton 
              ? Theme.of(context).colorScheme.primary.withOpacity(0.2) 
              : (isDarkMode ? Colors.grey[700] : Colors.grey[300]),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isActionButton ? 16 : 12, 
              vertical: isActionButton ? 10 : 8
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: isActionButton ? 14 : 13,
                fontWeight: isActionButton ? FontWeight.w600 : FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    final primaryColor = isDarkMode ? Colors.lightGreenAccent : Colors.black;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              color: backgroundColor,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final newWidth = constraints.maxWidth;
                    final newHeight = constraints.maxHeight;
                    
                    if (newWidth > 0 && newHeight > 0 && 
                        (newWidth / 8).floor() != _terminalColumns || 
                        (newHeight / 16).floor() != _terminalRows) {
                      _calculateAndApplyTerminalSize();
                    }
                  });
                  
                  return xterm.TerminalView(
                    _terminal,
                    padding: const EdgeInsets.all(8.0),
                    autofocus: true,
                    focusNode: _focusNode,
                    textStyle: xterm.TerminalStyle.fromTextStyle(
                      TextStyle(
                        fontFamily: 'monospace',
                        fontSize: _fontSize,
                      ),
                    ),
                    theme: xterm.TerminalTheme(
                      cursor: Colors.white,
                      selection: Colors.blue.withOpacity(0.5),
                      foreground: primaryColor,
                      background: backgroundColor,
                      black: Colors.black,
                      red: Colors.red,
                      green: Colors.green,
                      yellow: Colors.yellow,
                      blue: Colors.blue,
                      magenta: Colors.purple,
                      cyan: Colors.cyan,
                      white: Colors.white,
                      brightBlack: Colors.grey.shade700,
                      brightRed: Colors.red.shade400,
                      brightGreen: Colors.green.shade400,
                      brightYellow: Colors.yellow.shade400,
                      brightBlue: Colors.blue.shade400,
                      brightMagenta: Colors.purple.shade400,
                      brightCyan: Colors.cyan.shade400,
                      brightWhite: Colors.white,
                      searchHitBackground: Colors.yellow,
                      searchHitBackgroundCurrent: Colors.orange,
                      searchHitForeground: Colors.black,
                    ),
                  );
                },
              ),
            ),
          ),
          
          SizedBox(
            height: 56, 
            child: Stack(
              clipBehavior: Clip.none, 
              children: [
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[850] : Colors.grey[200],
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      child: Row(
                        children: [
                          _buildSpecialKeyButton('Tab', () => _sendSpecialKey('\t')),
                          _buildSpecialKeyButton('Ctrl', _toggleCtrl, isActive: _ctrlPressed),
                          _buildSpecialKeyButton('←', () => _sendSpecialKey('\x1b[D')),
                          _buildSpecialKeyButton('→', () => _sendSpecialKey('\x1b[C')),
                          _buildSpecialKeyButton('↑', () => _sendSpecialKey('\x1b[A')), 
                          _buildSpecialKeyButton('↓', () => _sendSpecialKey('\x1b[B')),
                          _buildSpecialKeyButton('PgUp', () => _sendSpecialKey('\x1b[5~')),
                          _buildSpecialKeyButton('PgDn', () => _sendSpecialKey('\x1b[6~')),
                          _buildSpecialKeyButton('Home', () => _sendSpecialKey('\x1b[H')),
                          _buildSpecialKeyButton('End', () => _sendSpecialKey('\x1b[F')),
                          _buildSpecialKeyButton('Esc', () => _sendSpecialKey('\x1b')),
                          _buildSpecialKeyButton('|', () => _sendSpecialKey('|')),
                          _buildSpecialKeyButton('&', () => _sendSpecialKey('&')),
                          _buildSpecialKeyButton(';', () => _sendSpecialKey(';')),
                          _buildSpecialKeyButton('>', () => _sendSpecialKey('>')),
                          _buildSpecialKeyButton('<', () => _sendSpecialKey('<')),
                          _buildSpecialKeyButton('*', () => _sendSpecialKey('*')),
                          _buildSpecialKeyButton('~', () => _sendSpecialKey('~')),
                        ],
                      ),
                    ),
                  ),
                ),
                
                if (_ctrlPressed)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[900] : Colors.grey[300],
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 5,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildCtrlKeyButton('A', 'Select All'),
                                    _buildCtrlKeyButton('C', 'Copy/Cancel'),
                                    _buildCtrlKeyButton('D', 'EOF'),
                                    _buildCtrlKeyButton('E', 'End of Line'),
                                    _buildCtrlKeyButton('G', 'Get Help'),
                                    _buildCtrlKeyButton('K', 'Kill Line'),
                                    _buildCtrlKeyButton('L', 'Clear'),
                                    _buildCtrlKeyButton('N', 'Next'),
                                    _buildCtrlKeyButton('O', 'Save'),
                                    _buildCtrlKeyButton('P', 'Previous'),
                                    _buildCtrlKeyButton('Q', 'Resume'),
                                    _buildCtrlKeyButton('R', 'Search'),
                                    _buildCtrlKeyButton('S', 'Stop Output'),
                                    _buildCtrlKeyButton('T', 'Spell Check'),
                                    _buildCtrlKeyButton('U', 'Clear Line'),
                                    _buildCtrlKeyButton('W', 'Delete Word'),
                                    _buildCtrlKeyButton('X', 'Cut'),
                                    _buildCtrlKeyButton('Z', 'Suspend'),
                                    _buildCtrlKeyButton('_', 'Go To Line'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          
                          SizedBox(
                            width: 70, 
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                    color: isDarkMode ? Colors.grey[700]! : Colors.grey[400]!,
                                    width: 1,
                                  ),
                                ),
                                color: isDarkMode ? Colors.grey[850] : Colors.grey[250],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _ctrlPressed = false;
                                    });
                                  },
                                  child: Container(
                                    height: 56, 
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(
                                        color: isDarkMode ? Colors.grey[200] : Colors.grey[800],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildCtrlKeyButton(String key, String tooltip) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Tooltip(
      message: tooltip,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3.0),
        child: Material(
          color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
          borderRadius: BorderRadius.circular(6),
          elevation: 1,
          child: InkWell(
            onTap: () => _sendControlSequence(key),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                key,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.lightGreenAccent : Colors.green[800],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

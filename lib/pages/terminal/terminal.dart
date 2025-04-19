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

class TerminalState extends State<Terminal> with AutomaticKeepAliveClientMixin {

  late xterm.Terminal _terminal;
  final FocusNode _focusNode = FocusNode();
  double _fontSize = 14.0;
  
  StreamSubscription? _shellSubscription;
  bool _isInteractiveMode = false;
  bool _ctrlPressed = false;
  bool _isTerminalInitialized = false;
  bool _isActive = true;
  bool _shouldRequestFocus = false; 
  final List<String> _inputBuffer = [];
  Timer? _inputProcessingTimer;

  int _terminalColumns = 80;
  int _terminalRows = 25;
  
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _terminal = xterm.Terminal();
    
    _focusNode.addListener(_handleFocusChange);
    
    _terminal.onOutput = (data) {
      if (_isInteractiveMode && widget.sshService != null) {
        _bufferInput(data);
      }
    };
    
    _loadTerminalSettings();
    _setupSettingsListener();
    _startInputProcessingTimer();
    
    Future.microtask(() {
      if (mounted) {
        _initInteractiveShell();
        _setupTerminalResize();
        _isTerminalInitialized = true;
      }
    });
  }
  
  void _startInputProcessingTimer() {
    _inputProcessingTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      _processInputBuffer();
    });
  }
  
  void _bufferInput(String data) {
    _inputBuffer.add(data);
  }
  
  void _processInputBuffer() {
    if (_inputBuffer.isEmpty || !_isActive || !_isInteractiveMode || widget.sshService == null) {
      return;
    }
    
    try {
      final input = _inputBuffer.removeAt(0);
      widget.sshService!.sendToShell(input);
    } catch (e) {
      print('Error processing input buffer: $e');
      _inputBuffer.clear();
      
      if (_isInteractiveMode && widget.sshService != null && widget.sshService!.isConnected()) {
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            _terminal.write('\r\nRecovering shell connection...\r\n');
            _cleanupTerminal();
            _initInteractiveShell();
          }
        });
      }
    }
  }
  
  void _handleFocusChange() {
    if (_focusNode.hasFocus && !_shouldRequestFocus) {
      if (!_isActive) {
        print("Terminal: Unexpected focus detected while inactive, releasing focus");
        Future.microtask(() => _focusNode.unfocus());
      } else {
        print("Terminal received focus");
      }
    }
  }
  
  @override
  void deactivate() {
    _isActive = false;
    _shouldRequestFocus = false; 
    _focusNode.unfocus();
    super.deactivate();
  }
  
  @override
  void activate() {
    _isActive = true;
    _shouldRequestFocus = false; 
    super.activate();
  }
  
  @override
  void dispose() {
    _inputProcessingTimer?.cancel();
    _inputBuffer.clear();
    _isActive = false;
    _shouldRequestFocus = false;
    
    _focusNode.removeListener(_handleFocusChange);
    
    _focusNode.unfocus();
    
    Future.microtask(() {
      _cleanupTerminal();
    });
    _focusNode.dispose();
    super.dispose();
  }
  
  void _cleanupTerminal() {
    if (_shellSubscription != null) {
      _shellSubscription!.cancel();
      _shellSubscription = null;
    }
    
    Future.delayed(const Duration(milliseconds: 50), () {
      if (widget.sshService != null) {
        widget.sshService!.closeShell();
      }
    });
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
    
    if (_isActive && _isInteractiveMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _terminal.buffer.setCursor(_terminal.buffer.cursorX, _terminal.buffer.cursorY);
      });
    }
  }

  void _setupTerminalResize() {
    _terminal.onResize = (w, h, pw, ph) {
      if (widget.sshService != null && _isInteractiveMode) {
        _terminalColumns = w;
        _terminalRows = h;
        
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && widget.sshService != null && _isInteractiveMode) {
            widget.sshService!.resizeShell(w, h);
          }
        });
      }
    };
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateAndApplyTerminalSize();
    });
  }
  
  void _calculateAndApplyTerminalSize() {
    if (!mounted) return;

    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final topPadding = mediaQuery.padding.top + kToolbarHeight; 
    final fontSizeFactor = _fontSize / 14.0;
    final devicePixelRatio = mediaQuery.devicePixelRatio;
    
    final charWidth = 8.0 * fontSizeFactor; 
    final charHeight = 17.0 * fontSizeFactor;
    
    const horizontalPadding = 16.0; 
    final availableHeight = size.height - 56 - topPadding - mediaQuery.padding.bottom - 16;
    final availableWidth = size.width - horizontalPadding * 2; 
    
    final safetyBuffer = 8.0 * fontSizeFactor;
    final adjustedWidth = availableWidth - safetyBuffer;
    
    final columns = (adjustedWidth / charWidth).floor();
    final rows = (availableHeight / charHeight).floor();
    
    final effectiveColumns = columns > 20 ? columns : 20;
    final effectiveRows = rows > 10 ? rows : 10;
    
    final safeColumns = (effectiveColumns * 0.95).floor();
    
    if (_terminalColumns != safeColumns || _terminalRows != effectiveRows) {
      if (_isActive) {
        print('Screen: ${size.width.toStringAsFixed(1)}x${size.height.toStringAsFixed(1)}px, '
              'density: ${devicePixelRatio.toStringAsFixed(1)}');
        print('Font size: $_fontSize, char: ${charWidth.toStringAsFixed(1)}x${charHeight.toStringAsFixed(1)}');
        print('Available space: ${availableWidth.toStringAsFixed(1)}x${availableHeight.toStringAsFixed(1)}px');
        print('Terminal dimensions: $safeColumns x $effectiveRows characters');
      }
      
      _terminalColumns = safeColumns;
      _terminalRows = effectiveRows;
      
      _terminal.resize(safeColumns, effectiveRows);
      
      _configureTerminalOptions();
      
      if (widget.sshService != null && _isInteractiveMode) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && widget.sshService != null && _isInteractiveMode) {
            widget.sshService!.resizeShell(effectiveColumns, effectiveRows);
          }
        });
      }
    }
  }
  
  void _configureTerminalOptions() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _terminal.buffer.setCursor(_terminal.buffer.cursorX, _terminal.buffer.cursorY);
      }
    });
  }
  
  Future<void> _initInteractiveShell() async {
    if (widget.sshService != null && widget.sshService!.isConnected()) {
      try {
        _terminal.write('Connecting to SSH...\r\n');
        print('Terminal: Starting shell with dimensions: $_terminalColumns x $_terminalRows');
        
        await Future.delayed(const Duration(milliseconds: 100));
        
        await widget.sshService!.startShell(
          width: _terminalColumns, 
          height: _terminalRows
        );
        
        print('Terminal: Shell started successfully');
        
        await Future.delayed(const Duration(milliseconds: 100));
        
        _shellSubscription = widget.sshService!.shellOutput.listen(
          _handleShellOutput,
          onError: (error) {
            print('Terminal: Shell output stream error: $error');
            _terminal.write('\r\nError in shell communication: $error\r\n');
          },
          onDone: () {
            print('Terminal: Shell output stream closed');
            if (mounted && _isInteractiveMode) {
              _terminal.write('\r\nShell connection closed.\r\n');
            }
          }
        );
        
        setState(() {
          _isInteractiveMode = true;
        });
        
        _terminal.write('Connected! Terminal ready.\r\n');
        
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted && _isInteractiveMode && widget.sshService != null) {
            _bufferInput('\r\n');  
            
            _terminal.buffer.setCursor(_terminal.buffer.cursorX, _terminal.buffer.cursorY);
          }
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
      _focusNode.unfocus();
      
      Future.microtask(() {
        _cleanupTerminal();
        if (mounted) {
          _initInteractiveShell();
        }
      });
    }
  }

  void _sendControlSequence(String key) {
    if (_isActive && widget.sshService != null && _isInteractiveMode) {
      final int charCode = key.codeUnitAt(0) - 64; 
      if (charCode > 0 && charCode < 27) {
        final String ctrlChar = String.fromCharCode(charCode);
        _bufferInput(ctrlChar);
      }
    }
    
    setState(() {
      _ctrlPressed = false;
    });
    
    if (_isActive) {
      _focusNode.requestFocus();
    }
  }

  void _sendSpecialKey(String sequence) {
    if (_isActive && widget.sshService != null && _isInteractiveMode) {
      _bufferInput(sequence);
    }
  }

  void resetShell() {
    if (mounted) {
      _terminal.write('\r\nResetting shell connection...\r\n');
      Future.microtask(() {
        _cleanupTerminal();
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _initInteractiveShell();
          }
        });
      });
    }
  }

  void forceReleaseTerminalFocus() {
    print("Terminal: Force releasing focus");
    
    _inputBuffer.clear();
    
    _isActive = false;
    
    _shouldRequestFocus = false;
    
    _ctrlPressed = false;
    
    _focusNode.unfocus();
    
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _isActive = true;
        });
      }
    });
  }
  
  void requestTerminalFocus() {
    if (!_isActive) return;
    
    print("Terminal: Explicitly requesting focus");
    
    setState(() {
      _shouldRequestFocus = true;
    });
    
    _focusNode.requestFocus();
    
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _shouldRequestFocus = false;
        });
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode ? Colors.lightGreenAccent : Colors.black;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;

    const double controlPanelHeight = 56.0;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: controlPanelHeight, 
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (_isActive) {
                  print("Terminal tapped, requesting focus");
                  requestTerminalFocus();
                }
              },
              child: Container(
                color: backgroundColor,
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (_isTerminalInitialized && _isActive) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _calculateAndApplyTerminalSize();
                      });
                    }
                    
                    return xterm.TerminalView(
                      _terminal,
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      autofocus: false,
                      focusNode: _focusNode,
                      keyboardType: TextInputType.text,
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
          ),
          
          Positioned(
            left: 0,
            right: 0,
            bottom: 0, 
            height: controlPanelHeight,
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[850] : Colors.grey[200],
                border: Border(
                  top: BorderSide(
                    color: isDarkMode ? Colors.grey[800]! : Colors.grey[400]!,
                    width: 1,
                  ),
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  SingleChildScrollView(
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
                  
                  if (_ctrlPressed)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        height: controlPanelHeight,
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

  void _toggleCtrl() {
    setState(() {
      _ctrlPressed = !_ctrlPressed;
    });
    
    if (_isActive) {
      _focusNode.requestFocus();
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_shouldRequestFocus) {
      _focusNode.requestFocus();
    }
  }
}

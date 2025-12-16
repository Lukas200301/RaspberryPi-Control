import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xterm/xterm.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:gap/gap.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';

class TerminalScreen extends ConsumerStatefulWidget {
  const TerminalScreen({super.key});

  @override
  ConsumerState<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends ConsumerState<TerminalScreen> {
  late Terminal terminal;
  late TerminalController terminalController;
  bool _isConnected = false;
  bool _showKeyboard = false;
  bool _ctrlPressed = false;
  StreamSubscription? _shellSubscription;

  @override
  void initState() {
    super.initState();
    
    terminal = Terminal(
      maxLines: 10000,
    );
    
    terminalController = TerminalController();
    
    _connectTerminal();
  }

  Future<void> _connectTerminal() async {
    try {
      final sshService = ref.read(sshServiceProvider);
      
      if (!sshService.isConnected) {
        throw Exception('SSH not connected');
      }

      // Create SSH shell session
      final session = await sshService.client!.shell(
        pty: SSHPtyConfig(
          width: 80,
          height: 24,
        ),
      );

      // Connect terminal output to SSH
      terminal.onOutput = (data) {
        session.stdin.add(utf8.encode(data));
      };

      // Connect SSH output to terminal
      _shellSubscription = session.stdout.listen((data) {
        terminal.write(utf8.decode(data));
      });

      // Handle errors
      session.stderr.listen((data) {
        terminal.write(utf8.decode(data));
      });

      setState(() {
        _isConnected = true;
      });
      
    } catch (e) {
      debugPrint('Terminal connection error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to connect terminal: $e',
                style: const TextStyle(color: Colors.white)),
            backgroundColor: AppTheme.errorRose,
          ),
        );
      }
    }
  }

  void _sendSpecialKey(String key) {
    switch (key) {
      case 'ESC':
        terminal.keyInput(TerminalKey.escape);
        _ctrlPressed = false;
        break;
      case 'TAB':
        terminal.keyInput(TerminalKey.tab);
        _ctrlPressed = false;
        break;
      case 'CTRL':
        setState(() {
          _ctrlPressed = !_ctrlPressed;
        });
        break;
      case 'UP':
        terminal.keyInput(TerminalKey.arrowUp);
        _ctrlPressed = false;
        break;
      case 'DOWN':
        terminal.keyInput(TerminalKey.arrowDown);
        _ctrlPressed = false;
        break;
      case 'LEFT':
        terminal.keyInput(TerminalKey.arrowLeft);
        _ctrlPressed = false;
        break;
      case 'RIGHT':
        terminal.keyInput(TerminalKey.arrowRight);
        _ctrlPressed = false;
        break;
      case 'HOME':
        terminal.keyInput(TerminalKey.home);
        _ctrlPressed = false;
        break;
      case 'END':
        terminal.keyInput(TerminalKey.end);
        _ctrlPressed = false;
        break;
    }
  }
  
  void _handleInput(String char) {
    if (_ctrlPressed) {
      // Send CTRL+char combination
      final upperChar = char.toUpperCase();
      if (upperChar.length == 1) {
        final charCode = upperChar.codeUnitAt(0);
        if (charCode >= 64 && charCode <= 95) {
          // Convert A-Z to CTRL+A through CTRL+Z (ASCII 1-26)
          final ctrlCode = charCode - 64;
          terminal.textInput(String.fromCharCode(ctrlCode));
        }
      }
      setState(() {
        _ctrlPressed = false;
      });
    } else {
      terminal.textInput(char);
    }
  }

  @override
  void dispose() {
    _shellSubscription?.cancel();
    terminal.onOutput = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terminal'),
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(_showKeyboard ? Icons.keyboard_hide : Icons.keyboard),
            onPressed: () {
              setState(() {
                _showKeyboard = !_showKeyboard;
              });
            },
            tooltip: _showKeyboard ? 'Hide keyboard bar' : 'Show keyboard bar',
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              terminal.write('\x1b[2J\x1b[H'); // Clear screen
            },
            tooltip: 'Clear screen',
          ),
        ],
      ),
      body: Column(
        children: [
          if (!_isConnected)
            Container(
              padding: const EdgeInsets.all(16),
              color: AppTheme.warningAmber.withValues(alpha: 0.2),
              child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.warningAmber,
                    ),
                  ),
                  const Gap(12),
                  const Text(
                    'Connecting to terminal...',
                    style: TextStyle(color: AppTheme.warningAmber),
                  ),
                ],
              ),
            ),
          
          // Terminal view
          Expanded(
            child: Container(
              color: Colors.black,
              child: Consumer(
                builder: (context, ref, _) {
                  final settings = ref.watch(appSettingsProvider);
                  return TerminalView(
                    terminal,
                    controller: terminalController,
                    autofocus: true,
                    backgroundOpacity: 1.0,
                    padding: const EdgeInsets.all(8),
                    textStyle: TerminalStyle(
                      fontSize: settings.terminalFontSize,
                      fontFamily: 'Courier',
                    ),
                  );
                },
              ),
            ),
          ),

          // Custom keyboard bar
          if (_showKeyboard)
            Container(
              color: AppTheme.glassLight,
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      _buildKeyButton('ESC'),
                      _buildKeyButton('TAB'),
                      _buildKeyButton('CTRL'),
                      const VerticalDivider(width: 16),
                      _buildKeyButton('UP', icon: Icons.arrow_upward),
                      _buildKeyButton('DOWN', icon: Icons.arrow_downward),
                      _buildKeyButton('LEFT', icon: Icons.arrow_back),
                      _buildKeyButton('RIGHT', icon: Icons.arrow_forward),
                      const VerticalDivider(width: 16),
                      _buildKeyButton('HOME'),
                      _buildKeyButton('END'),
                      const VerticalDivider(width: 16),
                      _buildKeyButton('/', char: '/'),
                      _buildKeyButton('|', char: '|'),
                      _buildKeyButton('-', char: '-'),
                      _buildKeyButton('~', char: '~'),
                      const VerticalDivider(width: 16),
                      // Common CTRL combinations for nano
                      _buildKeyButton('X', char: 'x'),
                      _buildKeyButton('O', char: 'o'),
                      _buildKeyButton('S', char: 's'),
                      _buildKeyButton('W', char: 'w'),
                      _buildKeyButton('K', char: 'k'),
                      _buildKeyButton('U', char: 'u'),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildKeyButton(String label, {IconData? icon, String? char}) {
    final isCtrl = label == 'CTRL';
    final isActive = isCtrl && _ctrlPressed;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: isActive ? AppTheme.primaryIndigo : AppTheme.glassLight,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () {
            if (char != null) {
              _handleInput(char);
            } else {
              _sendSpecialKey(label);
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: icon != null
                ? Icon(
                    icon, 
                    size: 16, 
                    color: isActive ? Colors.white : AppTheme.primaryIndigo,
                  )
                : Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white : AppTheme.primaryIndigo,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

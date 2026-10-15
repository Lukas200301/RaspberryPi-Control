import 'dart:async';
import 'dart:convert';

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xterm/xterm.dart';
import '../models/app_settings.dart';
import '../providers/app_providers.dart';
import '../providers/settings_provider.dart';
import '../providers/terminal_snippets_provider.dart';
import '../theme/app_theme.dart';
import '../theme/terminal_themes.dart';
import '../ui/ui.dart';

enum _State { connecting, connected, closed, failed }

/// Interactive SSH shell
class TerminalScreen extends ConsumerStatefulWidget {
  const TerminalScreen({super.key});

  @override
  ConsumerState<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends ConsumerState<TerminalScreen> {
  late Terminal _terminal = _newTerminal();
  final _controller = TerminalController();
  final _focus = FocusNode();
  SSHSession? _session;
  StreamSubscription<String>? _out;
  StreamSubscription<String>? _err;
  _State _state = _State.connecting;
  String? _error;
  bool _ctrl = false;
  bool _alt = false;

  @override
  void initState() {
    super.initState();
    _connect();
  }

  Terminal _newTerminal() => Terminal(maxLines: ref.read(settingsProvider).terminalScrollback);

  @override
  void dispose() {
    _close();
    _focus.dispose();
    super.dispose();
  }

  void _close() {
    _out?.cancel();
    _err?.cancel();
    _session?.close();
    _session = null;
  }

  Future<void> _connect() async {
    _close();
    setState(() {
      _state = _State.connecting;
      _error = null;
    });
    try {
      final ssh = ref.read(sshServiceProvider);
      if (!ssh.isConnected || ssh.client == null) throw Exception('Not connected to the device');
      final session = await ssh.client!.shell(
        pty: SSHPtyConfig(width: _terminal.viewWidth, height: _terminal.viewHeight, type: 'xterm-256color'),
      );
      _session = session;

      _terminal.onOutput = (data) => session.write(utf8.encode(_modified(data)));
      // Tell the shell about every size change, so full-screen programs fit
      _terminal.onResize = (w, h, pw, ph) => session.resizeTerminal(w, h, pw, ph);
      session.resizeTerminal(_terminal.viewWidth, _terminal.viewHeight);

      // A streaming decoder keeps characters intact that span two packets
      _out = session.stdout
          .cast<List<int>>()
          .transform(const Utf8Decoder(allowMalformed: true))
          .listen(_terminal.write);
      _err = session.stderr
          .cast<List<int>>()
          .transform(const Utf8Decoder(allowMalformed: true))
          .listen(_terminal.write);
      session.done.then((_) {
        if (!mounted || _session != session) return;
        setState(() => _state = _State.closed);
        _terminal.write('\r\n\x1b[2m[session ended]\x1b[0m\r\n');
      });
      setState(() => _state = _State.connected);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _state = _State.failed;
        _error = describeError(e);
      });
    }
  }

  /// Applies sticky Ctrl/Alt to keyboard input
  String _modified(String data) {
    if (!_ctrl && !_alt) return data;
    var out = data;
    if (_ctrl && data.length == 1) {
      final c = data.toUpperCase().codeUnitAt(0);
      if (c >= 64 && c <= 95) out = String.fromCharCode(c - 64);
      if (data == ' ') out = '\x00';
    }
    if (_alt) out = '\x1b$out';
    setState(() {
      _ctrl = false;
      _alt = false;
    });
    return out;
  }

  void _key(TerminalKey key) {
    _terminal.keyInput(key, ctrl: _ctrl, alt: _alt);
    setState(() {
      _ctrl = false;
      _alt = false;
    });
  }

  void _text(String text) => _terminal.textInput(text);

  void _toggleCtrl() => setState(() => _ctrl = !_ctrl);

  void _toggleAlt() => setState(() => _alt = !_alt);

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text == null || text.isEmpty) return;
    if (text.contains('\n') &&
        mounted &&
        !await showConfirmDialog(
          context,
          title: 'Paste ${'\n'.allMatches(text).length + 1} lines?',
          message: 'Each line runs as a command as soon as it is pasted.',
          confirmLabel: 'Paste',
        )) {
      return;
    }
    _terminal.paste(text);
  }

  void _copy() {
    final selection = _controller.selection;
    if (selection == null) {
      showToast(context, 'Select text first: long-press and drag');
      return;
    }
    Clipboard.setData(ClipboardData(text: _terminal.buffer.getText(selection)));
    _controller.clearSelection();
    showToast(context, 'Copied');
  }

  void _fontSize(double delta) {
    final s = ref.read(settingsProvider);
    ref
        .read(settingsProvider.notifier)
        .update((x) => x.copyWith(terminalFontSize: (s.terminalFontSize + delta).clamp(8.0, 28.0)));
  }

  void _snippets() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheet) => Consumer(
        builder: (context, ref, _) {
          final snippets = ref.watch(terminalSnippetsProvider);
          return SafeArea(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.7),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(Insets.xl, 0, Insets.md, Insets.sm),
                    child: Row(
                      children: [
                        Expanded(child: Text('Snippets', style: context.tt.titleLarge)),
                        TextButton.icon(
                          onPressed: () async {
                            final cmd = await showTextPrompt(
                              context,
                              title: 'New snippet',
                              label: 'Command',
                              confirmLabel: 'Save',
                              validator: (v) => v.trim().isEmpty ? 'Enter a command' : null,
                            );
                            if (cmd != null) ref.read(terminalSnippetsProvider.notifier).addSnippet(cmd);
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add'),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(Insets.xl, 0, Insets.xl, Insets.sm),
                    child: Text(
                      'Tap to type a command, or run it right away.',
                      style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant),
                    ),
                  ),
                  Flexible(
                    child: snippets.isEmpty
                        ? const Padding(padding: EdgeInsets.all(Insets.xl), child: Text('No snippets yet.'))
                        : ListView(
                            shrinkWrap: true,
                            children: [
                              for (final s in snippets)
                                ListTile(
                                  title: Text(s, style: AppTheme.mono(size: 13)),
                                  onTap: () {
                                    Navigator.pop(sheet);
                                    _text(s);
                                    _focus.requestFocus();
                                  },
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        tooltip: 'Run',
                                        icon: const Icon(Icons.play_arrow),
                                        onPressed: () {
                                          Navigator.pop(sheet);
                                          _text('$s\r');
                                        },
                                      ),
                                      IconButton(
                                        tooltip: 'Delete',
                                        icon: Icon(Icons.delete_outline, color: context.cs.error),
                                        onPressed: () => ref.read(terminalSnippetsProvider.notifier).removeSnippet(s),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(settingsProvider);
    // The scrollback length is fixed per terminal; a change starts a fresh one
    ref.listen(settingsProvider.select((x) => x.terminalScrollback), (prev, next) {
      if (prev == next) return;
      setState(() => _terminal = _newTerminal());
      _connect();
    });
    final scheme = terminalSchemeById(s.terminalTheme);
    final device = ref.watch(currentConnectionProvider);

    return PageScaffold(
      title: 'Terminal',
      subtitle: switch (_state) {
        _State.connecting => 'Connecting…',
        _State.connected => device?.address,
        _State.closed => 'Session ended',
        _State.failed => 'Not connected',
      },
      automaticallyImplyLeading: false,
      maxWidth: double.infinity,
      actions: [
        IconButton(tooltip: 'Snippets', icon: const Icon(Icons.bolt_outlined), onPressed: _snippets),
        IconButton(tooltip: 'Paste', icon: const Icon(Icons.content_paste), onPressed: _paste),
        PopupMenuButton<String>(
          onSelected: (v) {
            switch (v) {
              case 'copy':
                _copy();
              case 'bigger':
                _fontSize(1);
              case 'smaller':
                _fontSize(-1);
              case 'clear':
                _terminal.buffer.clear();
                _terminal.buffer.setCursor(0, 0);
                _text('\x0c');
              case 'keys':
                ref.read(settingsProvider.notifier).update((x) => x.copyWith(terminalExtraKeys: !x.terminalExtraKeys));
              case 'restart':
                _terminal.write('\r\n');
                _connect();
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'copy',
              child: ListTile(leading: Icon(Icons.copy), title: Text('Copy selection')),
            ),
            const PopupMenuItem(
              value: 'bigger',
              child: ListTile(leading: Icon(Icons.zoom_in), title: Text('Larger text')),
            ),
            const PopupMenuItem(
              value: 'smaller',
              child: ListTile(leading: Icon(Icons.zoom_out), title: Text('Smaller text')),
            ),
            const PopupMenuItem(
              value: 'clear',
              child: ListTile(leading: Icon(Icons.clear_all), title: Text('Clear screen')),
            ),
            CheckedPopupMenuItem(value: 'keys', checked: s.terminalExtraKeys, child: const Text('Extra keys row')),
            const PopupMenuItem(
              value: 'restart',
              child: ListTile(leading: Icon(Icons.restart_alt), title: Text('New session')),
            ),
          ],
        ),
      ],
      body: Column(
        children: [
          if (_state == _State.failed || _state == _State.closed)
            MaterialBanner(
              leading: Icon(_state == _State.failed ? Icons.error_outline : Icons.logout),
              content: Text(_state == _State.failed ? 'Could not open a shell: $_error' : 'The shell has exited.'),
              actions: [
                TextButton(onPressed: _connect, child: Text(_state == _State.failed ? 'Retry' : 'New session')),
              ],
            ),
          if (_state == _State.connecting) const LinearProgressIndicator(),
          Expanded(
            child: ColoredBox(
              color: scheme.theme.background,
              child: TerminalView(
                _terminal,
                controller: _controller,
                focusNode: _focus,
                autofocus: true,
                theme: scheme.theme,
                padding: const EdgeInsets.all(Insets.sm),
                cursorType: switch (s.terminalCursor) {
                  TerminalCursor.block => TerminalCursorType.block,
                  TerminalCursor.underline => TerminalCursorType.underline,
                  TerminalCursor.bar => TerminalCursorType.verticalBar,
                },
                alwaysShowCursor: s.terminalCursorBlink,
                keyboardAppearance: Theme.of(context).brightness,
                textStyle: TerminalStyle(
                  fontSize: s.terminalFontSize,
                  fontFamily: GoogleFonts.getFont(s.terminalFont).fontFamily!,
                ),
              ),
            ),
          ),
          if (s.terminalExtraKeys) _ExtraKeys(state: this),
        ],
      ),
    );
  }
}

class _ExtraKeys extends StatelessWidget {
  final _TerminalScreenState state;

  const _ExtraKeys({required this.state});

  @override
  Widget build(BuildContext context) {
    Widget key(String label, VoidCallback onTap, {IconData? icon, bool active = false, String? tooltip}) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: active ? context.cs.primary : context.cs.surfaceContainerHighest,
        borderRadius: Radii.smAll,
        child: InkWell(
          borderRadius: Radii.smAll,
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: Tooltip(
            message: tooltip ?? label,
            child: Container(
              constraints: const BoxConstraints(minWidth: 44, minHeight: 40),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: Insets.sm),
              child: icon != null
                  ? Icon(icon, size: 18, color: active ? context.cs.onPrimary : context.cs.onSurface)
                  : Text(
                      label,
                      style: context.tt.labelLarge?.copyWith(
                        color: active ? context.cs.onPrimary : context.cs.onSurface,
                        fontFeatures: tabularFigures,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );

    return Material(
      color: context.cs.surfaceContainer,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: Insets.xs, vertical: 6),
            children: [
              key('Esc', () => state._key(TerminalKey.escape)),
              key('Tab', () => state._key(TerminalKey.tab)),
              key('Ctrl', state._toggleCtrl, active: state._ctrl, tooltip: 'Ctrl: applies to the next key you type'),
              key('Alt', state._toggleAlt, active: state._alt),
              const Gap(Insets.xs),
              key('', () => state._key(TerminalKey.arrowLeft), icon: Icons.keyboard_arrow_left, tooltip: 'Left'),
              key('', () => state._key(TerminalKey.arrowUp), icon: Icons.keyboard_arrow_up, tooltip: 'Up'),
              key('', () => state._key(TerminalKey.arrowDown), icon: Icons.keyboard_arrow_down, tooltip: 'Down'),
              key('', () => state._key(TerminalKey.arrowRight), icon: Icons.keyboard_arrow_right, tooltip: 'Right'),
              const Gap(Insets.xs),
              for (final c in const ['/', '-', '|', '~', '*', '>', '&', r'$']) key(c, () => state._text(c)),
              const Gap(Insets.xs),
              key('Home', () => state._key(TerminalKey.home)),
              key('End', () => state._key(TerminalKey.end)),
              key('PgUp', () => state._key(TerminalKey.pageUp)),
              key('PgDn', () => state._key(TerminalKey.pageDown)),
              key('^C', () => state._text('\x03'), tooltip: 'Ctrl+C: stop the running program'),
              key('^D', () => state._text('\x04'), tooltip: 'Ctrl+D: end input or log out'),
              key('^Z', () => state._text('\x1a'), tooltip: 'Ctrl+Z: pause the running program'),
            ],
          ),
        ),
      ),
    );
  }
}

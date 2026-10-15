import 'package:flutter/material.dart';
import 'package:xterm/xterm.dart';

/// A terminal color scheme the user can pick in Settings → Terminal
class TerminalScheme {
  final String id;
  final String name;
  final TerminalTheme theme;

  const TerminalScheme(this.id, this.name, this.theme);
}

/// Builds a theme from the 16 ANSI colors plus foreground, background and
/// cursor (selection and search highlights derive from the cursor color)
TerminalTheme _scheme({
  required int fg,
  required int bg,
  required int cursor,
  required List<int> ansi,
}) {
  final c = Color(cursor);
  return TerminalTheme(
    cursor: c,
    selection: c.withValues(alpha: 0.27),
    foreground: Color(fg),
    background: Color(bg),
    black: Color(ansi[0]),
    red: Color(ansi[1]),
    green: Color(ansi[2]),
    yellow: Color(ansi[3]),
    blue: Color(ansi[4]),
    magenta: Color(ansi[5]),
    cyan: Color(ansi[6]),
    white: Color(ansi[7]),
    brightBlack: Color(ansi[8]),
    brightRed: Color(ansi[9]),
    brightGreen: Color(ansi[10]),
    brightYellow: Color(ansi[11]),
    brightBlue: Color(ansi[12]),
    brightMagenta: Color(ansi[13]),
    brightCyan: Color(ansi[14]),
    brightWhite: Color(ansi[15]),
    searchHitBackground: c.withValues(alpha: 0.27),
    searchHitBackgroundCurrent: c.withValues(alpha: 0.53),
    searchHitForeground: const Color(0xFFFFFFFF),
  );
}

final List<TerminalScheme> terminalSchemes = [
  TerminalScheme(
    'default',
    'Midnight',
    _scheme(fg: 0xFFE0E0E0, bg: 0xFF000000, cursor: 0xFF6366F1, ansi: const [
      0xFF000000, 0xFFF43F5E, 0xFF10B981, 0xFFFBBF24, 0xFF6366F1, 0xFFD946EF, 0xFF14B8A6, 0xFFE5E7EB, //
      0xFF374151, 0xFFFB7185, 0xFF34D399, 0xFFFCD34D, 0xFF818CF8, 0xFFE879F9, 0xFF2DD4BF, 0xFFFFFFFF,
    ]),
  ),
  TerminalScheme(
    'nord',
    'Nord',
    _scheme(fg: 0xFFD8DEE9, bg: 0xFF2E3440, cursor: 0xFF88C0D0, ansi: const [
      0xFF3B4252, 0xFFBF616A, 0xFFA3BE8C, 0xFFEBCB8B, 0xFF81A1C1, 0xFFB48EAD, 0xFF88C0D0, 0xFFE5E9F0, //
      0xFF4C566A, 0xFFBF616A, 0xFFA3BE8C, 0xFFEBCB8B, 0xFF81A1C1, 0xFFB48EAD, 0xFF8FBCBB, 0xFFECEFF4,
    ]),
  ),
  TerminalScheme(
    'dracula',
    'Dracula',
    _scheme(fg: 0xFFF8F8F2, bg: 0xFF282A36, cursor: 0xFFFF79C6, ansi: const [
      0xFF21222C, 0xFFFF5555, 0xFF50FA7B, 0xFFF1FA8C, 0xFFBD93F9, 0xFFFF79C6, 0xFF8BE9FD, 0xFFF8F8F2, //
      0xFF6272A4, 0xFFFF6E6E, 0xFF69FF94, 0xFFFFFFA5, 0xFFD6ACFF, 0xFFFF92DF, 0xFFA4FFFF, 0xFFFFFFFF,
    ]),
  ),
  TerminalScheme(
    'synthwave',
    'Synthwave',
    _scheme(fg: 0xFFE2E2FF, bg: 0xFF0D0D1A, cursor: 0xFFFF2D78, ansi: const [
      0xFF1A1A2E, 0xFFFF2D78, 0xFF00F5D4, 0xFFFF9E00, 0xFF7B2FBE, 0xFFDA00FF, 0xFF00B4D8, 0xFFE2E2FF, //
      0xFF2D2B55, 0xFFFF6B9D, 0xFF5EFCE8, 0xFFFFD166, 0xFFA855F7, 0xFFE879F9, 0xFF48CAE4, 0xFFFFFFFF,
    ]),
  ),
  TerminalScheme(
    'one-dark',
    'One Dark',
    _scheme(fg: 0xFFABB2BF, bg: 0xFF282C34, cursor: 0xFF528BFF, ansi: const [
      0xFF282C34, 0xFFE06C75, 0xFF98C379, 0xFFE5C07B, 0xFF61AFEF, 0xFFC678DD, 0xFF56B6C2, 0xFFABB2BF, //
      0xFF5C6370, 0xFFE06C75, 0xFF98C379, 0xFFE5C07B, 0xFF61AFEF, 0xFFC678DD, 0xFF56B6C2, 0xFFFFFFFF,
    ]),
  ),
  TerminalScheme(
    'tokyo-night',
    'Tokyo Night',
    _scheme(fg: 0xFFC0CAF5, bg: 0xFF1A1B26, cursor: 0xFF7AA2F7, ansi: const [
      0xFF15161E, 0xFFF7768E, 0xFF9ECE6A, 0xFFE0AF68, 0xFF7AA2F7, 0xFFBB9AF7, 0xFF7DCFFF, 0xFFA9B1D6, //
      0xFF414868, 0xFFF7768E, 0xFF9ECE6A, 0xFFE0AF68, 0xFF7AA2F7, 0xFFBB9AF7, 0xFF7DCFFF, 0xFFC0CAF5,
    ]),
  ),
  TerminalScheme(
    'gruvbox',
    'Gruvbox Dark',
    _scheme(fg: 0xFFEBDBB2, bg: 0xFF282828, cursor: 0xFFFE8019, ansi: const [
      0xFF282828, 0xFFCC241D, 0xFF98971A, 0xFFD79921, 0xFF458588, 0xFFB16286, 0xFF689D6A, 0xFFA89984, //
      0xFF928374, 0xFFFB4934, 0xFFB8BB26, 0xFFFABD2F, 0xFF83A598, 0xFFD3869B, 0xFF8EC07C, 0xFFEBDBB2,
    ]),
  ),
  TerminalScheme(
    'solarized-dark',
    'Solarized Dark',
    _scheme(fg: 0xFF839496, bg: 0xFF002B36, cursor: 0xFF93A1A1, ansi: const [
      0xFF073642, 0xFFDC322F, 0xFF859900, 0xFFB58900, 0xFF268BD2, 0xFFD33682, 0xFF2AA198, 0xFFEEE8D5, //
      0xFF586E75, 0xFFCB4B16, 0xFF859900, 0xFFB58900, 0xFF268BD2, 0xFF6C71C4, 0xFF2AA198, 0xFFFDF6E3,
    ]),
  ),
  TerminalScheme(
    'light',
    'Paper (light)',
    _scheme(fg: 0xFF24292F, bg: 0xFFFFFFFF, cursor: 0xFF0969DA, ansi: const [
      0xFF24292F, 0xFFCF222E, 0xFF116329, 0xFF4D2D00, 0xFF0969DA, 0xFF8250DF, 0xFF1B7C83, 0xFF6E7781, //
      0xFF57606A, 0xFFA40E26, 0xFF1A7F37, 0xFF633C01, 0xFF218BFF, 0xFFA475F9, 0xFF3192AA, 0xFF8C959F,
    ]),
  ),
];

TerminalScheme terminalSchemeById(String id) =>
    terminalSchemes.firstWhere((s) => s.id == id, orElse: () => terminalSchemes.first);

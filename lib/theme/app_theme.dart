import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xterm/xterm.dart';

// ─── Theme Presets ────────────────────────────────────────────────────────────
enum AppThemePreset { amoled, nord, dracula, synthwave }

extension AppThemePresetExtension on AppThemePreset {
  String get displayName {
    switch (this) {
      case AppThemePreset.amoled:
        return 'AMOLED Black';
      case AppThemePreset.nord:
        return 'Nord';
      case AppThemePreset.dracula:
        return 'Dracula';
      case AppThemePreset.synthwave:
        return 'Synthwave';
    }
  }

  Color get background {
    switch (this) {
      case AppThemePreset.amoled:
        return const Color(0xFF000000);
      case AppThemePreset.nord:
        return const Color(0xFF2E3440);
      case AppThemePreset.dracula:
        return const Color(0xFF282A36);
      case AppThemePreset.synthwave:
        return const Color(0xFF0D0D1A);
    }
  }

  Color get surface {
    switch (this) {
      case AppThemePreset.amoled:
        return const Color(0xFF111111);
      case AppThemePreset.nord:
        return const Color(0xFF3B4252);
      case AppThemePreset.dracula:
        return const Color(0xFF44475A);
      case AppThemePreset.synthwave:
        return const Color(0xFF1A1A2E);
    }
  }

  Color get primary {
    switch (this) {
      case AppThemePreset.amoled:
        return const Color(0xFF6366F1); // Electric Indigo
      case AppThemePreset.nord:
        return const Color(0xFF88C0D0); // Nord Frost Blue
      case AppThemePreset.dracula:
        return const Color(0xFFBD93F9); // Dracula Purple
      case AppThemePreset.synthwave:
        return const Color(0xFFFF2D78); // Hot Pink
    }
  }

  Color get secondary {
    switch (this) {
      case AppThemePreset.amoled:
        return const Color(0xFF14B8A6); // Teal
      case AppThemePreset.nord:
        return const Color(0xFFA3BE8C); // Nord Green
      case AppThemePreset.dracula:
        return const Color(0xFF50FA7B); // Dracula Green
      case AppThemePreset.synthwave:
        return const Color(0xFF00F5D4); // Cyan
    }
  }

  Color get accent {
    switch (this) {
      case AppThemePreset.amoled:
        return const Color(0xFFF43F5E);
      case AppThemePreset.nord:
        return const Color(0xFFBF616A); // Nord Red
      case AppThemePreset.dracula:
        return const Color(0xFFFF79C6); // Dracula Pink
      case AppThemePreset.synthwave:
        return const Color(0xFFFF9E00); // Orange
    }
  }

  // Swatch colors for the theme picker card
  List<Color> get swatchColors => [
    background,
    surface,
    primary,
    secondary,
    accent,
  ];

  // Terminal theme matching the UI preset
  TerminalTheme get terminalTheme {
    switch (this) {
      case AppThemePreset.amoled:
        return TerminalTheme(
          cursor: const Color(0xFF6366F1),
          selection: const Color(0x446366F1),
          foreground: const Color(0xFFE0E0E0),
          background: const Color(0xFF000000),
          black: const Color(0xFF000000),
          red: const Color(0xFFF43F5E),
          green: const Color(0xFF10B981),
          yellow: const Color(0xFFFBBF24),
          blue: const Color(0xFF6366F1),
          magenta: const Color(0xFFD946EF),
          cyan: const Color(0xFF14B8A6),
          white: const Color(0xFFE5E7EB),
          brightBlack: const Color(0xFF374151),
          brightRed: const Color(0xFFFB7185),
          brightGreen: const Color(0xFF34D399),
          brightYellow: const Color(0xFFFCD34D),
          brightBlue: const Color(0xFF818CF8),
          brightMagenta: const Color(0xFFE879F9),
          brightCyan: const Color(0xFF2DD4BF),
          brightWhite: const Color(0xFFFFFFFF),
          searchHitBackground: const Color(0x446366F1),
          searchHitBackgroundCurrent: const Color(0x886366F1),
          searchHitForeground: const Color(0xFFFFFFFF),
        );
      case AppThemePreset.nord:
        return TerminalTheme(
          cursor: const Color(0xFF88C0D0),
          selection: const Color(0x4488C0D0),
          foreground: const Color(0xFFD8DEE9),
          background: const Color(0xFF2E3440),
          black: const Color(0xFF3B4252),
          red: const Color(0xFFBF616A),
          green: const Color(0xFFA3BE8C),
          yellow: const Color(0xFFEBCB8B),
          blue: const Color(0xFF81A1C1),
          magenta: const Color(0xFFB48EAD),
          cyan: const Color(0xFF88C0D0),
          white: const Color(0xFFE5E9F0),
          brightBlack: const Color(0xFF4C566A),
          brightRed: const Color(0xFFBF616A),
          brightGreen: const Color(0xFFA3BE8C),
          brightYellow: const Color(0xFFEBCB8B),
          brightBlue: const Color(0xFF81A1C1),
          brightMagenta: const Color(0xFFB48EAD),
          brightCyan: const Color(0xFF8FBCBB),
          brightWhite: const Color(0xFFECEFF4),
          searchHitBackground: const Color(0x4488C0D0),
          searchHitBackgroundCurrent: const Color(0x8888C0D0),
          searchHitForeground: const Color(0xFFFFFFFF),
        );
      case AppThemePreset.dracula:
        return TerminalTheme(
          cursor: const Color(0xFFFF79C6),
          selection: const Color(0x44FF79C6),
          foreground: const Color(0xFFF8F8F2),
          background: const Color(0xFF282A36),
          black: const Color(0xFF21222C),
          red: const Color(0xFFFF5555),
          green: const Color(0xFF50FA7B),
          yellow: const Color(0xFFF1FA8C),
          blue: const Color(0xFFBD93F9),
          magenta: const Color(0xFFFF79C6),
          cyan: const Color(0xFF8BE9FD),
          white: const Color(0xFFF8F8F2),
          brightBlack: const Color(0xFF6272A4),
          brightRed: const Color(0xFFFF6E6E),
          brightGreen: const Color(0xFF69FF94),
          brightYellow: const Color(0xFFFFFFA5),
          brightBlue: const Color(0xFFD6ACFF),
          brightMagenta: const Color(0xFFFF92DF),
          brightCyan: const Color(0xFFA4FFFF),
          brightWhite: const Color(0xFFFFFFFF),
          searchHitBackground: const Color(0x44BD93F9),
          searchHitBackgroundCurrent: const Color(0x88BD93F9),
          searchHitForeground: const Color(0xFFFFFFFF),
        );
      case AppThemePreset.synthwave:
        return TerminalTheme(
          cursor: const Color(0xFFFF2D78),
          selection: const Color(0x44FF2D78),
          foreground: const Color(0xFFE2E2FF),
          background: const Color(0xFF0D0D1A),
          black: const Color(0xFF1A1A2E),
          red: const Color(0xFFFF2D78),
          green: const Color(0xFF00F5D4),
          yellow: const Color(0xFFFF9E00),
          blue: const Color(0xFF7B2FBE),
          magenta: const Color(0xFFDA00FF),
          cyan: const Color(0xFF00B4D8),
          white: const Color(0xFFE2E2FF),
          brightBlack: const Color(0xFF2D2B55),
          brightRed: const Color(0xFFFF6B9D),
          brightGreen: const Color(0xFF5EFCE8),
          brightYellow: const Color(0xFFFFD166),
          brightBlue: const Color(0xFFA855F7),
          brightMagenta: const Color(0xFFE879F9),
          brightCyan: const Color(0xFF48CAE4),
          brightWhite: const Color(0xFFFFFFFF),
          searchHitBackground: const Color(0x44FF2D78),
          searchHitBackgroundCurrent: const Color(0x88FF2D78),
          searchHitForeground: const Color(0xFFFFFFFF),
        );
    }
  }
}

// ─── AppTheme ─────────────────────────────────────────────────────────────────
class AppTheme {
  // Default/fallback static colors based on AMOLED preset
  static const Color background = Color(0xFF000000);
  static const Color primaryIndigo = Color(0xFF6366F1);
  static const Color secondaryTeal = Color(0xFF14B8A6);
  static const Color errorRose = Color(0xFFF43F5E);
  static const Color warningAmber = Color(0xFFFBBF24);
  static const Color successGreen = Color(0xFF10B981);

  static const Color glassLight = Color(0x14FFFFFF);
  static const Color glassBorder = Color(0x1AFFFFFF);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xB3FFFFFF);
  static const Color textTertiary = Color(0x80FFFFFF);

  static ThemeData getTheme({
    Color primary = primaryIndigo,
    Color secondary = secondaryTeal,
    Color bg = background,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        error: errorRose,
        surface: bg,
        onSurface: textPrimary,
        surfaceContainer: bg,
        surfaceContainerHigh: bg,
        surfaceContainerHighest: bg,
      ),

      textTheme: TextTheme(
        displayLarge: GoogleFonts.inter(
          fontSize: 57,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 45,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        displaySmall: GoogleFonts.inter(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.robotoMono(fontSize: 16, color: textSecondary),
        bodyMedium: GoogleFonts.robotoMono(fontSize: 14, color: textSecondary),
        bodySmall: GoogleFonts.robotoMono(fontSize: 12, color: textTertiary),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textSecondary,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textTertiary,
        ),
      ),

      cardTheme: CardThemeData(
        color: glassLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: glassBorder, width: 1),
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        surfaceTintColor: Colors.transparent,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: glassLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorRose),
        ),
        labelStyle: GoogleFonts.inter(color: textSecondary),
        hintStyle: GoogleFonts.inter(color: textTertiary),
      ),

      iconTheme: const IconThemeData(color: textPrimary, size: 24),

      popupMenuTheme: PopupMenuThemeData(
        color: glassLight,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: glassBorder, width: 1),
        ),
        textStyle: GoogleFonts.inter(fontSize: 14, color: textPrimary),
      ),
    );
  }

  static ThemeData getThemeFromPreset(AppThemePreset preset) {
    return getTheme(
      primary: preset.primary,
      secondary: preset.secondary,
      bg: preset.background,
    );
  }

  static ThemeData get darkTheme => getTheme();

  static BoxDecoration glassDecoration({
    double borderRadius = 16,
    Color? color,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: color ?? glassLight,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: borderColor ?? glassBorder, width: 1),
    );
  }

  static Color getTempColor(double temp) {
    if (temp < 50) return successGreen;
    if (temp < 70) return warningAmber;
    return errorRose;
  }

  static Color getCPUColor(double usage) {
    if (usage < 50) return successGreen;
    if (usage < 80) return warningAmber;
    return errorRose;
  }

  static Color getMemoryColor(double usage) {
    if (usage < 70) return successGreen;
    if (usage < 90) return warningAmber;
    return errorRose;
  }
}

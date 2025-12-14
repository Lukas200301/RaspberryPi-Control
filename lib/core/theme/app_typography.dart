import 'package:flutter/material.dart';

/// v3.0 Typography System
class AppTypography {
  // ===== FONT FAMILIES =====

  static const String primaryFont = 'Roboto';
  static const String monoFont = 'Courier';

  // ===== TEXT STYLES =====

  // Display styles (Large headers)
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.25,
    height: 1.3,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  // Headline styles (Section headers)
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    height: 1.4,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // Title styles (Card titles, dialog titles)
  static const TextStyle titleLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  // Body text styles
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.6,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  // Label styles (Buttons, chips, labels)
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  // ===== SPECIAL PURPOSE STYLES =====

  // Monospace (terminal, code)
  static const TextStyle monoLarge = TextStyle(
    fontFamily: monoFont,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const TextStyle monoMedium = TextStyle(
    fontFamily: monoFont,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const TextStyle monoSmall = TextStyle(
    fontFamily: monoFont,
    fontSize: 11,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  // Numbers/Stats (Tabular numbers)
  static const TextStyle statsLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle statsMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle statsSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  // ===== TEXT THEME =====

  /// Generate Material TextTheme
  static TextTheme textTheme = const TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );

  // ===== ADAPTIVE HELPERS =====

  /// Get adaptive font size based on platform
  static double adaptiveFontSize(double baseFontSize, BuildContext context) {
    // Slightly larger on desktop
    final isDesktop = Theme.of(context).platform == TargetPlatform.windows ||
        Theme.of(context).platform == TargetPlatform.linux ||
        Theme.of(context).platform == TargetPlatform.macOS;

    return isDesktop ? baseFontSize * 1.1 : baseFontSize;
  }
}

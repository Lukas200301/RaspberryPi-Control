import 'package:flutter/material.dart';

/// Spacing scale. Use these instead of ad-hoc numbers so screens share one
/// rhythm.
class Insets {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  /// Horizontal page padding
  static const double page = 16;
}

class Radii {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double card = 20;

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius cardAll = BorderRadius.all(Radius.circular(card));
}

/// Window size classes from the Material 3 guidelines
class Breakpoints {
  /// From here on navigation moves into a side rail
  static const double medium = 600;

  /// From here on the rail shows labels and pages may use two columns
  static const double expanded = 840;

  /// Content never gets wider than this
  static const double maxContent = 1200;
}

/// Tones for status colors (pills, icons, metrics)
enum Tone { neutral, primary, success, warning, danger, info }

/// Semantic colors the Material color scheme does not have. They adapt to
/// light and dark mode.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color warning;
  final Color onWarning;
  final Color warningContainer;
  final Color info;
  final Color infoContainer;

  /// Log/terminal panels
  final Color codeBackground;
  final Color codeForeground;
  final Color logStdout;
  final Color logStderr;
  final Color logDaemon;

  /// Categorical colors for charts and series (CPU, memory, network...)
  final List<Color> series;

  const AppColors({
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.info,
    required this.infoContainer,
    required this.codeBackground,
    required this.codeForeground,
    required this.logStdout,
    required this.logStderr,
    required this.logDaemon,
    required this.series,
  });

  factory AppColors.dark({required bool pureBlack}) => AppColors(
    success: const Color(0xFF4ADE80),
    onSuccess: const Color(0xFF052E16),
    successContainer: const Color(0xFF14532D),
    warning: const Color(0xFFFBBF24),
    onWarning: const Color(0xFF3B2700),
    warningContainer: const Color(0xFF5C4100),
    info: const Color(0xFF60A5FA),
    infoContainer: const Color(0xFF1E3A5F),
    codeBackground: pureBlack ? Colors.black : const Color(0xFF0B0D12),
    codeForeground: const Color(0xFFE6E8EE),
    logStdout: const Color(0xFFE6E8EE),
    logStderr: const Color(0xFFFCA5A5),
    logDaemon: const Color(0xFFC4B5FD),
    series: const [
      Color(0xFF818CF8),
      Color(0xFF2DD4BF),
      Color(0xFFFBBF24),
      Color(0xFFF472B6),
      Color(0xFF60A5FA),
      Color(0xFFA3E635),
      Color(0xFFFB923C),
      Color(0xFFC084FC),
    ],
  );

  factory AppColors.light() => const AppColors(
    success: Color(0xFF15803D),
    onSuccess: Colors.white,
    successContainer: Color(0xFFDCFCE7),
    warning: Color(0xFFB45309),
    onWarning: Colors.white,
    warningContainer: Color(0xFFFEF3C7),
    info: Color(0xFF1D4ED8),
    infoContainer: Color(0xFFDBEAFE),
    codeBackground: Color(0xFF111318),
    codeForeground: Color(0xFFE6E8EE),
    logStdout: Color(0xFFE6E8EE),
    logStderr: Color(0xFFFCA5A5),
    logDaemon: Color(0xFFC4B5FD),
    series: [
      Color(0xFF4F46E5),
      Color(0xFF0D9488),
      Color(0xFFD97706),
      Color(0xFFDB2777),
      Color(0xFF2563EB),
      Color(0xFF65A30D),
      Color(0xFFEA580C),
      Color(0xFF9333EA),
    ],
  );

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      success: l(success, other.success),
      onSuccess: l(onSuccess, other.onSuccess),
      successContainer: l(successContainer, other.successContainer),
      warning: l(warning, other.warning),
      onWarning: l(onWarning, other.onWarning),
      warningContainer: l(warningContainer, other.warningContainer),
      info: l(info, other.info),
      infoContainer: l(infoContainer, other.infoContainer),
      codeBackground: l(codeBackground, other.codeBackground),
      codeForeground: l(codeForeground, other.codeForeground),
      logStdout: l(logStdout, other.logStdout),
      logStderr: l(logStderr, other.logStderr),
      logDaemon: l(logDaemon, other.logDaemon),
      series: [
        for (var i = 0; i < series.length; i++)
          l(series[i], other.series[i % other.series.length]),
      ],
    );
  }
}

extension ThemeContext on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get cs => Theme.of(this).colorScheme;
  TextTheme get tt => Theme.of(this).textTheme;
  AppColors get ac => Theme.of(this).extension<AppColors>()!;

  double get width => MediaQuery.sizeOf(this).width;
  bool get isMediumUp => width >= Breakpoints.medium;
  bool get isExpanded => width >= Breakpoints.expanded;

  /// Foreground color of a tone
  Color tone(Tone tone) {
    switch (tone) {
      case Tone.primary:
        return cs.primary;
      case Tone.success:
        return ac.success;
      case Tone.warning:
        return ac.warning;
      case Tone.danger:
        return cs.error;
      case Tone.info:
        return ac.info;
      case Tone.neutral:
        return cs.onSurfaceVariant;
    }
  }

  /// Soft background color of a tone
  Color toneContainer(Tone tone) {
    switch (tone) {
      case Tone.primary:
        return cs.primaryContainer;
      case Tone.success:
        return ac.successContainer;
      case Tone.warning:
        return ac.warningContainer;
      case Tone.danger:
        return cs.errorContainer;
      case Tone.info:
        return ac.infoContainer;
      case Tone.neutral:
        return cs.surfaceContainerHighest;
    }
  }
}

/// Tabular figures keep changing numbers from jumping around
const List<FontFeature> tabularFigures = [FontFeature.tabularFigures()];

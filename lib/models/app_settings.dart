import 'package:flutter/material.dart';

/// Where the app colors come from
enum ColorSource { preset, custom, dynamic }

enum TemperatureUnit { celsius, fahrenheit }

enum TerminalCursor { block, underline, bar }

/// All user settings. Immutable; change them through the settings provider.
@immutable
class AppSettings {
  // Appearance
  final ThemeMode themeMode;
  final ColorSource colorSource;
  final int presetSeed;
  final int customSeed;
  final bool pureBlack;
  final double contrast;
  final double textScale;
  final bool animations;
  final bool compact;

  // Dashboard & monitoring
  final TemperatureUnit temperatureUnit;
  final int statsHistory;
  final int refreshSeconds;
  final double tempWarning;
  final double tempCritical;

  // Terminal
  final double terminalFontSize;
  final String terminalFont;
  final String terminalTheme;
  final TerminalCursor terminalCursor;
  final bool terminalCursorBlink;
  final int terminalScrollback;
  final bool terminalExtraKeys;

  // Connection
  final bool autoReconnect;
  final int keepAliveSeconds;
  final int connectTimeoutSeconds;

  // Files
  final bool filesShowHidden;
  final bool filesConfirmDelete;

  // Security
  final bool appLock;
  final bool appLockBiometrics;
  final int appLockTimeoutSeconds;

  const AppSettings({
    this.themeMode = ThemeMode.dark,
    this.colorSource = ColorSource.preset,
    this.presetSeed = 0xFF6366F1,
    this.customSeed = 0xFF6366F1,
    this.pureBlack = false,
    this.contrast = 0,
    this.textScale = 1.0,
    this.animations = true,
    this.compact = false,
    this.temperatureUnit = TemperatureUnit.celsius,
    this.statsHistory = 60,
    this.refreshSeconds = 4,
    this.tempWarning = 65,
    this.tempCritical = 80,
    this.terminalFontSize = 14,
    this.terminalFont = 'JetBrains Mono',
    this.terminalTheme = 'default',
    this.terminalCursor = TerminalCursor.block,
    this.terminalCursorBlink = true,
    this.terminalScrollback = 10000,
    this.terminalExtraKeys = true,
    this.autoReconnect = true,
    this.keepAliveSeconds = 15,
    this.connectTimeoutSeconds = 10,
    this.filesShowHidden = false,
    this.filesConfirmDelete = true,
    this.appLock = false,
    this.appLockBiometrics = true,
    this.appLockTimeoutSeconds = 60,
  });

  /// The seed color of the current color source (dynamic falls back to it)
  Color get seed => Color(colorSource == ColorSource.custom ? customSeed : presetSeed);

  String formatTemperature(double celsius, {int digits = 1}) {
    if (temperatureUnit == TemperatureUnit.fahrenheit) {
      return '${(celsius * 9 / 5 + 32).toStringAsFixed(digits)}°F';
    }
    return '${celsius.toStringAsFixed(digits)}°C';
  }

  static const terminalFonts = [
    'JetBrains Mono',
    'Fira Code',
    'Roboto Mono',
    'Source Code Pro',
    'Ubuntu Mono',
  ];

  static const availableFontSizes = [10.0, 12.0, 13.0, 14.0, 16.0, 18.0, 20.0];

  AppSettings copyWith({
    ThemeMode? themeMode,
    ColorSource? colorSource,
    int? presetSeed,
    int? customSeed,
    bool? pureBlack,
    double? contrast,
    double? textScale,
    bool? animations,
    bool? compact,
    TemperatureUnit? temperatureUnit,
    int? statsHistory,
    int? refreshSeconds,
    double? tempWarning,
    double? tempCritical,
    double? terminalFontSize,
    String? terminalFont,
    String? terminalTheme,
    TerminalCursor? terminalCursor,
    bool? terminalCursorBlink,
    int? terminalScrollback,
    bool? terminalExtraKeys,
    bool? autoReconnect,
    int? keepAliveSeconds,
    int? connectTimeoutSeconds,
    bool? filesShowHidden,
    bool? filesConfirmDelete,
    bool? appLock,
    bool? appLockBiometrics,
    int? appLockTimeoutSeconds,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      colorSource: colorSource ?? this.colorSource,
      presetSeed: presetSeed ?? this.presetSeed,
      customSeed: customSeed ?? this.customSeed,
      pureBlack: pureBlack ?? this.pureBlack,
      contrast: contrast ?? this.contrast,
      textScale: textScale ?? this.textScale,
      animations: animations ?? this.animations,
      compact: compact ?? this.compact,
      temperatureUnit: temperatureUnit ?? this.temperatureUnit,
      statsHistory: statsHistory ?? this.statsHistory,
      refreshSeconds: refreshSeconds ?? this.refreshSeconds,
      tempWarning: tempWarning ?? this.tempWarning,
      tempCritical: tempCritical ?? this.tempCritical,
      terminalFontSize: terminalFontSize ?? this.terminalFontSize,
      terminalFont: terminalFont ?? this.terminalFont,
      terminalTheme: terminalTheme ?? this.terminalTheme,
      terminalCursor: terminalCursor ?? this.terminalCursor,
      terminalCursorBlink: terminalCursorBlink ?? this.terminalCursorBlink,
      terminalScrollback: terminalScrollback ?? this.terminalScrollback,
      terminalExtraKeys: terminalExtraKeys ?? this.terminalExtraKeys,
      autoReconnect: autoReconnect ?? this.autoReconnect,
      keepAliveSeconds: keepAliveSeconds ?? this.keepAliveSeconds,
      connectTimeoutSeconds: connectTimeoutSeconds ?? this.connectTimeoutSeconds,
      filesShowHidden: filesShowHidden ?? this.filesShowHidden,
      filesConfirmDelete: filesConfirmDelete ?? this.filesConfirmDelete,
      appLock: appLock ?? this.appLock,
      appLockBiometrics: appLockBiometrics ?? this.appLockBiometrics,
      appLockTimeoutSeconds: appLockTimeoutSeconds ?? this.appLockTimeoutSeconds,
    );
  }

  Map<String, dynamic> toJson() => {
    'themeMode': themeMode.name,
    'colorSource': colorSource.name,
    'presetSeed': presetSeed,
    'customSeed': customSeed,
    'pureBlack': pureBlack,
    'contrast': contrast,
    'textScale': textScale,
    'animations': animations,
    'compact': compact,
    'temperatureUnit': temperatureUnit.name,
    'statsHistory': statsHistory,
    'refreshSeconds': refreshSeconds,
    'tempWarning': tempWarning,
    'tempCritical': tempCritical,
    'terminalFontSize': terminalFontSize,
    'terminalFont': terminalFont,
    'terminalTheme': terminalTheme,
    'terminalCursor': terminalCursor.name,
    'terminalCursorBlink': terminalCursorBlink,
    'terminalScrollback': terminalScrollback,
    'terminalExtraKeys': terminalExtraKeys,
    'autoReconnect': autoReconnect,
    'keepAliveSeconds': keepAliveSeconds,
    'connectTimeoutSeconds': connectTimeoutSeconds,
    'filesShowHidden': filesShowHidden,
    'filesConfirmDelete': filesConfirmDelete,
    'appLock': appLock,
    'appLockBiometrics': appLockBiometrics,
    'appLockTimeoutSeconds': appLockTimeoutSeconds,
  };

  /// Unknown or invalid values fall back to the defaults
  factory AppSettings.fromJson(Map<String, dynamic> j) {
    const d = AppSettings();
    T pick<T>(String key, T fallback) {
      final v = j[key];
      if (v is T) return v;
      if (fallback is double && v is num) return v.toDouble() as T;
      if (fallback is int && v is num) return v.toInt() as T;
      return fallback;
    }

    E pickEnum<E extends Enum>(List<E> values, String key, E fallback) {
      final name = j[key];
      for (final v in values) {
        if (v.name == name) return v;
      }
      return fallback;
    }

    return AppSettings(
      themeMode: pickEnum(ThemeMode.values, 'themeMode', d.themeMode),
      colorSource: pickEnum(ColorSource.values, 'colorSource', d.colorSource),
      presetSeed: pick('presetSeed', d.presetSeed),
      customSeed: pick('customSeed', d.customSeed),
      pureBlack: pick('pureBlack', d.pureBlack),
      contrast: pick('contrast', d.contrast).clamp(0.0, 1.0),
      textScale: pick('textScale', d.textScale).clamp(0.8, 1.4),
      animations: pick('animations', d.animations),
      compact: pick('compact', d.compact),
      temperatureUnit: pickEnum(TemperatureUnit.values, 'temperatureUnit', d.temperatureUnit),
      statsHistory: pick('statsHistory', d.statsHistory).clamp(10, 600),
      refreshSeconds: pick('refreshSeconds', d.refreshSeconds).clamp(1, 60),
      tempWarning: pick('tempWarning', d.tempWarning),
      tempCritical: pick('tempCritical', d.tempCritical),
      terminalFontSize: pick('terminalFontSize', d.terminalFontSize).clamp(8.0, 32.0),
      terminalFont: pick('terminalFont', d.terminalFont),
      terminalTheme: pick('terminalTheme', d.terminalTheme),
      terminalCursor: pickEnum(TerminalCursor.values, 'terminalCursor', d.terminalCursor),
      terminalCursorBlink: pick('terminalCursorBlink', d.terminalCursorBlink),
      terminalScrollback: pick('terminalScrollback', d.terminalScrollback).clamp(500, 100000),
      terminalExtraKeys: pick('terminalExtraKeys', d.terminalExtraKeys),
      autoReconnect: pick('autoReconnect', d.autoReconnect),
      keepAliveSeconds: pick('keepAliveSeconds', d.keepAliveSeconds).clamp(5, 120),
      connectTimeoutSeconds: pick('connectTimeoutSeconds', d.connectTimeoutSeconds).clamp(3, 60),
      filesShowHidden: pick('filesShowHidden', d.filesShowHidden),
      filesConfirmDelete: pick('filesConfirmDelete', d.filesConfirmDelete),
      appLock: pick('appLock', d.appLock),
      appLockBiometrics: pick('appLockBiometrics', d.appLockBiometrics),
      appLockTimeoutSeconds: pick('appLockTimeoutSeconds', d.appLockTimeoutSeconds).clamp(0, 3600),
    );
  }
}

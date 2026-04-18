import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import '../theme/app_theme.dart';

// ─── Theme State ──────────────────────────────────────────────────────────────
class ThemeState {
  final ThemeData themeData;
  final AppThemePreset preset;

  ThemeState({required this.themeData, required this.preset});

  ThemeState copyWith({ThemeData? themeData, AppThemePreset? preset}) {
    return ThemeState(
      themeData: themeData ?? this.themeData,
      preset: preset ?? this.preset,
    );
  }

  // Convenience getters
  Color get primaryColor => preset.primary;
  Color get secondaryColor => preset.secondary;
}

// ─── Theme Notifier ───────────────────────────────────────────────────────────
class ThemeNotifier extends Notifier<ThemeState> {
  static const _presetKey = 'app_theme_preset';
  final _storage = GetStorage();

  @override
  ThemeState build() {
    // Load saved preset or default to AMOLED
    final savedIndex = _storage.read<int>(_presetKey) ?? 0;
    final preset = AppThemePreset
        .values[savedIndex.clamp(0, AppThemePreset.values.length - 1)];

    return ThemeState(
      themeData: AppTheme.getThemeFromPreset(preset),
      preset: preset,
    );
  }

  void setPreset(AppThemePreset preset) {
    _storage.write(_presetKey, preset.index);
    state = ThemeState(
      themeData: AppTheme.getThemeFromPreset(preset),
      preset: preset,
    );
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeState>(
  ThemeNotifier.new,
);

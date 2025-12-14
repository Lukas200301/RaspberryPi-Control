import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'app_dimensions.dart';

/// GetX Theme Controller for v3.0
/// Manages theme mode, blur intensity, and visual preferences
class ThemeController extends GetxController {
  static ThemeController get to => Get.find();

  // GetStorage instance
  final _storage = GetStorage();

  // Storage keys
  static const String _keyThemeMode = 'themeMode';
  static const String _keyBlurLevel = 'blurLevel';
  static const String _keyReduceTransparency = 'reduceTransparency';
  static const String _keyReduceAnimations = 'reduceAnimations';

  // Reactive state
  final Rx<ThemeMode> _themeMode = ThemeMode.dark.obs;
  final Rx<GlassBlurLevel> _blurLevel = GlassBlurLevel.medium.obs;
  final RxBool _reduceTransparency = false.obs;
  final RxBool _reduceAnimations = false.obs;

  // Getters
  ThemeMode get themeMode => _themeMode.value;
  GlassBlurLevel get blurLevel => _blurLevel.value;
  bool get reduceTransparency => _reduceTransparency.value;
  bool get reduceAnimations => _reduceAnimations.value;
  bool get isDarkMode => _themeMode.value == ThemeMode.dark;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  /// Load theme settings from storage
  void _loadSettings() {
    // Load theme mode
    final themeModeString = _storage.read(_keyThemeMode) ?? 'dark';
    _themeMode.value = _parseThemeMode(themeModeString);

    // Load blur level
    final blurLevelString = _storage.read(_keyBlurLevel) ?? 'medium';
    _blurLevel.value = _parseBlurLevel(blurLevelString);

    // Load transparency setting
    _reduceTransparency.value = _storage.read(_keyReduceTransparency) ?? false;

    // Load animations setting
    _reduceAnimations.value = _storage.read(_keyReduceAnimations) ?? false;

    // Update GetX theme
    Get.changeThemeMode(_themeMode.value);
  }

  /// Toggle between dark and light theme
  void toggleTheme() {
    if (_themeMode.value == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
    } else {
      setThemeMode(ThemeMode.dark);
    }
  }

  /// Set specific theme mode
  void setThemeMode(ThemeMode mode) {
    _themeMode.value = mode;
    _storage.write(_keyThemeMode, mode.toString().split('.').last);
    Get.changeThemeMode(mode);
  }

  /// Set theme mode from string (for settings UI)
  void setThemeModeFromString(String mode) {
    final themeMode = _parseThemeMode(mode);
    setThemeMode(themeMode);
  }

  /// Set blur level
  void setBlurLevel(GlassBlurLevel level) {
    _blurLevel.value = level;
    _storage.write(_keyBlurLevel, level.name);
    update(); // Update all GetBuilder widgets
  }

  /// Set blur level from string
  void setBlurLevelFromString(String level) {
    final blurLevel = _parseBlurLevel(level);
    setBlurLevel(blurLevel);
  }

  /// Toggle reduce transparency
  void toggleReduceTransparency() {
    _reduceTransparency.value = !_reduceTransparency.value;
    _storage.write(_keyReduceTransparency, _reduceTransparency.value);
    update();
  }

  /// Set reduce transparency
  void setReduceTransparency(bool value) {
    _reduceTransparency.value = value;
    _storage.write(_keyReduceTransparency, value);
    update();
  }

  /// Toggle reduce animations
  void toggleReduceAnimations() {
    _reduceAnimations.value = !_reduceAnimations.value;
    _storage.write(_keyReduceAnimations, _reduceAnimations.value);
    update();
  }

  /// Set reduce animations
  void setReduceAnimations(bool value) {
    _reduceAnimations.value = value;
    _storage.write(_keyReduceAnimations, value);
    update();
  }

  /// Get effective blur sigma value (respects reduce transparency setting)
  double getEffectiveBlur() {
    if (_reduceTransparency.value) {
      return AppDimensions.blurNone;
    }
    return _blurLevel.value.sigma;
  }

  /// Get effective opacity (respects reduce transparency setting)
  double getEffectiveOpacity(double baseOpacity) {
    if (_reduceTransparency.value) {
      return baseOpacity * 2; // More opaque when transparency is reduced
    }
    return baseOpacity;
  }

  /// Parse ThemeMode from string
  ThemeMode _parseThemeMode(String mode) {
    switch (mode.toLowerCase()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.dark;
    }
  }

  /// Parse GlassBlurLevel from string
  GlassBlurLevel _parseBlurLevel(String level) {
    switch (level.toLowerCase()) {
      case 'none':
        return GlassBlurLevel.none;
      case 'low':
        return GlassBlurLevel.low;
      case 'medium':
        return GlassBlurLevel.medium;
      case 'high':
        return GlassBlurLevel.high;
      default:
        return GlassBlurLevel.medium;
    }
  }

  /// Get theme mode display name
  String getThemeModeDisplayName() {
    switch (_themeMode.value) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  /// Get blur level display name
  String getBlurLevelDisplayName() {
    return _blurLevel.value.name.capitalize ?? 'Medium';
  }
}

/// Glass blur intensity levels
enum GlassBlurLevel {
  none(AppDimensions.blurNone),
  low(AppDimensions.blurLow),
  medium(AppDimensions.blurMedium),
  high(AppDimensions.blurHigh);

  final double sigma;
  const GlassBlurLevel(this.sigma);
}

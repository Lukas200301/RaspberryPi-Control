import 'package:get_storage/get_storage.dart';

class AppSettings {
  static const String _keyAnimations = 'animations_enabled';
  static const String _keyStatsHistory = 'stats_history';
  static const String _keyTerminalFontSize = 'terminal_font_size';
  static const String _keyAutoReconnect = 'auto_reconnect';
  
  final GetStorage _storage = GetStorage();

  // Animations
  bool get animationsEnabled => _storage.read(_keyAnimations) ?? true;
  set animationsEnabled(bool value) => _storage.write(_keyAnimations, value);

  // Monitoring
  int get statsHistory => _storage.read(_keyStatsHistory) ?? 60;
  set statsHistory(int value) => _storage.write(_keyStatsHistory, value);

  // Terminal
  double get terminalFontSize => _storage.read(_keyTerminalFontSize) ?? 14.0;
  set terminalFontSize(double value) => _storage.write(_keyTerminalFontSize, value);
  
  static const List<double> availableFontSizes = [10.0, 12.0, 14.0, 16.0, 18.0, 20.0];

  // Connection
  bool get autoReconnect => _storage.read(_keyAutoReconnect) ?? true;
  set autoReconnect(bool value) => _storage.write(_keyAutoReconnect, value);

  // Theme
  static const String _keyPrimaryColor = 'theme_primary_color';
  static const String _keySecondaryColor = 'theme_secondary_color';

  int? get primaryColor => _storage.read(_keyPrimaryColor);
  set primaryColor(int? value) => _storage.write(_keyPrimaryColor, value);

  int? get secondaryColor => _storage.read(_keySecondaryColor);
  set secondaryColor(int? value) => _storage.write(_keySecondaryColor, value);

  // Reset all settings
  Future<void> resetAll() async {
    await _storage.erase();
  }
}

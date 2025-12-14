import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized Storage Service using GetStorage
/// Replaces scattered SharedPreferences usage throughout the app
class StorageService extends GetxService {
  late final GetStorage _box;
  bool _initialized = false;

  // ===== STORAGE KEYS =====

  // Theme & Appearance
  static const String keyThemeMode = 'themeMode';
  static const String keyBlurLevel = 'blurLevel';
  static const String keyReduceTransparency = 'reduceTransparency';
  static const String keyReduceAnimations = 'reduceAnimations';
  static const String keyIsDarkMode = 'isDarkMode'; // Legacy compatibility

  // Connection Settings
  static const String keyDefaultPort = 'defaultPort';
  static const String keyConnectionTimeout = 'connectionTimeout';
  static const String keySshKeepAliveInterval = 'sshKeepAliveInterval';
  static const String keySshCompression = 'sshCompression';
  static const String keyAutoReconnect = 'autoReconnect';
  static const String keyConnectionRetryDelay = 'connectionRetryDelay';
  static const String keySecurityTimeout = 'securityTimeout';

  // Terminal Settings
  static const String keyTerminalFontSize = 'terminalFontSize';
  static const String keyTerminalTheme = 'terminalTheme';

  // File Explorer Settings
  static const String keyShowHiddenFiles = 'showHiddenFiles';
  static const String keyConfirmBeforeOverwrite = 'confirmBeforeOverwrite';
  static const String keyDefaultDownloadDirectory = 'defaultDownloadDirectory';

  // Dashboard Settings
  static const String keyDashboardWidgets = 'dashboardWidgets';
  static const String keyDashboardRefreshInterval = 'dashboardRefreshInterval';
  static const String keyTemperatureUnit = 'temperatureUnit';

  // Connections (JSON)
  static const String keyConnections = 'connections';
  static const String keyFavorites = 'favorites';

  // Window State (Desktop)
  static const String keyWindowLeft = 'window_left';
  static const String keyWindowTop = 'window_top';
  static const String keyWindowWidth = 'window_width';
  static const String keyWindowHeight = 'window_height';

  // First Launch & Updates
  static const String keyFirstLaunch = 'firstLaunch';
  static const String keyLastVersion = 'lastVersion';

  // ===== INITIALIZATION =====

  Future<StorageService> init() async {
    if (_initialized) return this;

    await GetStorage.init();
    _box = GetStorage();

    // Migrate from SharedPreferences (v2.x -> v3.0)
    await _migrateFromSharedPreferences();

    _initialized = true;
    return this;
  }

  /// Migrate existing data from SharedPreferences to GetStorage
  Future<void> _migrateFromSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      int migratedCount = 0;

      for (var key in keys) {
        // Skip if already exists in GetStorage
        if (_box.hasData(key)) continue;

        // Migrate the value
        final value = prefs.get(key);
        if (value != null) {
          await _box.write(key, value);
          migratedCount++;
        }
      }

      if (migratedCount > 0) {
        print('✅ Migrated $migratedCount settings from SharedPreferences to GetStorage');
      }
    } catch (e) {
      print('⚠️ Failed to migrate from SharedPreferences: $e');
    }
  }

  // ===== GENERIC READ/WRITE =====

  T? read<T>(String key) => _box.read<T>(key);

  T get<T>(String key, T defaultValue) => _box.read<T>(key) ?? defaultValue;

  Future<void> write(String key, dynamic value) => _box.write(key, value);

  Future<void> remove(String key) => _box.remove(key);

  bool hasData(String key) => _box.hasData(key);

  Future<void> clearAll() => _box.erase();

  // ===== TYPE-SAFE GETTERS =====

  // Theme
  bool get isDarkMode => get(keyIsDarkMode, true);
  String get themeMode => get(keyThemeMode, 'dark');
  String get blurLevel => get(keyBlurLevel, 'medium');
  bool get reduceTransparency => get(keyReduceTransparency, false);
  bool get reduceAnimations => get(keyReduceAnimations, false);

  // Connection
  String get defaultPort => get(keyDefaultPort, '22');
  int get connectionTimeout => get(keyConnectionTimeout, 30);
  String get sshKeepAliveInterval => get(keySshKeepAliveInterval, '60');
  bool get sshCompression => get(keySshCompression, false);
  bool get autoReconnect => get(keyAutoReconnect, true);
  int get connectionRetryDelay => get(keyConnectionRetryDelay, 5);
  int get securityTimeout => get(keySecurityTimeout, 0);

  // Terminal
  String get terminalFontSize => get(keyTerminalFontSize, '14');
  String get terminalTheme => get(keyTerminalTheme, 'dark');

  // File Explorer
  bool get showHiddenFiles => get(keyShowHiddenFiles, false);
  bool get confirmBeforeOverwrite => get(keyConfirmBeforeOverwrite, true);
  String? get defaultDownloadDirectory => read<String>(keyDefaultDownloadDirectory);

  // Dashboard
  String? get dashboardWidgets => read<String>(keyDashboardWidgets);
  int get dashboardRefreshInterval => get(keyDashboardRefreshInterval, 3);
  String get temperatureUnit => get(keyTemperatureUnit, 'C');

  // Connections
  String? get connections => read<String>(keyConnections);
  List<String> get favorites => get<List>(keyFavorites, <String>[]).cast<String>();

  // Window State
  double? get windowLeft => read<double>(keyWindowLeft);
  double? get windowTop => read<double>(keyWindowTop);
  double? get windowWidth => read<double>(keyWindowWidth);
  double? get windowHeight => read<double>(keyWindowHeight);

  // First Launch
  bool get isFirstLaunch => get(keyFirstLaunch, true);
  String get lastVersion => get(keyLastVersion, '0.0.0');

  // ===== TYPE-SAFE SETTERS =====

  // Theme
  Future<void> setDarkMode(bool value) => write(keyIsDarkMode, value);
  Future<void> setThemeMode(String value) => write(keyThemeMode, value);
  Future<void> setBlurLevel(String value) => write(keyBlurLevel, value);
  Future<void> setReduceTransparency(bool value) => write(keyReduceTransparency, value);
  Future<void> setReduceAnimations(bool value) => write(keyReduceAnimations, value);

  // Connection
  Future<void> setDefaultPort(String value) => write(keyDefaultPort, value);
  Future<void> setConnectionTimeout(int value) => write(keyConnectionTimeout, value);
  Future<void> setSshKeepAliveInterval(String value) => write(keySshKeepAliveInterval, value);
  Future<void> setSshCompression(bool value) => write(keySshCompression, value);
  Future<void> setAutoReconnect(bool value) => write(keyAutoReconnect, value);
  Future<void> setConnectionRetryDelay(int value) => write(keyConnectionRetryDelay, value);
  Future<void> setSecurityTimeout(int value) => write(keySecurityTimeout, value);

  // Terminal
  Future<void> setTerminalFontSize(String value) => write(keyTerminalFontSize, value);
  Future<void> setTerminalTheme(String value) => write(keyTerminalTheme, value);

  // File Explorer
  Future<void> setShowHiddenFiles(bool value) => write(keyShowHiddenFiles, value);
  Future<void> setConfirmBeforeOverwrite(bool value) => write(keyConfirmBeforeOverwrite, value);
  Future<void> setDefaultDownloadDirectory(String? value) {
    if (value == null) {
      return remove(keyDefaultDownloadDirectory);
    }
    return write(keyDefaultDownloadDirectory, value);
  }

  // Dashboard
  Future<void> setDashboardWidgets(String value) => write(keyDashboardWidgets, value);
  Future<void> setDashboardRefreshInterval(int value) => write(keyDashboardRefreshInterval, value);
  Future<void> setTemperatureUnit(String value) => write(keyTemperatureUnit, value);

  // Connections
  Future<void> setConnections(String value) => write(keyConnections, value);
  Future<void> setFavorites(List<String> value) => write(keyFavorites, value);

  // Window State
  Future<void> setWindowBounds(double left, double top, double width, double height) async {
    await write(keyWindowLeft, left);
    await write(keyWindowTop, top);
    await write(keyWindowWidth, width);
    await write(keyWindowHeight, height);
  }

  // First Launch
  Future<void> setFirstLaunchComplete() => write(keyFirstLaunch, false);
  Future<void> setLastVersion(String version) => write(keyLastVersion, version);

  // ===== EXPORT/IMPORT SETTINGS =====

  /// Export all settings as JSON
  Map<String, dynamic> exportSettings() {
    final Map<String, dynamic> settings = {};
    final keys = _box.getKeys();

    for (var key in keys) {
      settings[key.toString()] = _box.read(key.toString());
    }

    return settings;
  }

  /// Import settings from JSON
  Future<void> importSettings(Map<String, dynamic> settings) async {
    for (var entry in settings.entries) {
      await write(entry.key, entry.value);
    }
  }

  /// Clear specific category of settings
  Future<void> clearCategory(String prefix) async {
    final keys = _box.getKeys().where((key) => key.toString().startsWith(prefix));
    for (var key in keys) {
      await remove(key.toString());
    }
  }
}

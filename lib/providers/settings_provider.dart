import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import '../models/app_settings.dart';

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);

class SettingsNotifier extends Notifier<AppSettings> {
  static const _key = 'app_settings_v2';
  final _storage = GetStorage();

  @override
  AppSettings build() {
    final saved = _storage.read(_key);
    if (saved is Map) {
      return AppSettings.fromJson(Map<String, dynamic>.from(saved));
    }
    return _migrateLegacy();
  }

  /// Takes over the values of the settings before v2
  AppSettings _migrateLegacy() {
    const presetSeeds = [0xFF6366F1, 0xFF88C0D0, 0xFFBD93F9, 0xFFFF2D78];
    const terminalThemes = ['default', 'nord', 'dracula', 'synthwave'];
    final preset = (_storage.read<int>('app_theme_preset') ?? 0).clamp(0, 3);

    final settings = const AppSettings().copyWith(
      animations: _storage.read<bool>('animations_enabled'),
      statsHistory: _storage.read<int>('stats_history'),
      terminalFontSize: (_storage.read('terminal_font_size') as num?)?.toDouble(),
      autoReconnect: _storage.read<bool>('auto_reconnect'),
      presetSeed: presetSeeds[preset],
      terminalTheme: terminalThemes[preset],
      // The app used to be pure black by default (AMOLED preset)
      pureBlack: preset == 0,
    );
    _storage.write(_key, settings.toJson());
    return settings;
  }

  void update(AppSettings Function(AppSettings s) change) {
    state = change(state);
    _storage.write(_key, state.toJson());
  }

  void replace(AppSettings settings) {
    state = settings;
    _storage.write(_key, state.toJson());
  }

  void reset() => replace(const AppSettings());
}

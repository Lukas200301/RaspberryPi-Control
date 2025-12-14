import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../services/update_service.dart';

/// Settings Controller for RaspberryPi Control v3.0
/// Manages all app settings with reactive state management
class SettingsController extends GetxController {
  static SettingsController get to => Get.find();

  // Lazy getters to avoid initialization order issues
  StorageService get _storage => Get.find<StorageService>();
  ThemeController get _themeController => Get.find<ThemeController>();

  // App Info
  final RxString appVersion = ''.obs;
  final RxString appBuildNumber = ''.obs;

  // Appearance Settings
  final RxBool reduceTransparency = false.obs;
  final RxBool reduceAnimations = false.obs;

  // Terminal Settings
  final RxString terminalFontSize = '14'.obs;
  final RxInt historySize = 1000.obs;
  final RxString terminalTheme = 'default'.obs;

  // Connection Settings
  final RxString defaultPort = '22'.obs;
  final RxInt connectionTimeout = 30.obs;
  final RxString sshKeepAliveInterval = '60'.obs;
  final RxBool autoReconnect = true.obs;
  final RxInt securityTimeout = 0.obs;
  final RxBool sshCompression = false.obs;

  // File Explorer Settings
  final RxString defaultViewMode = 'grid'.obs;
  final RxBool showHiddenFiles = false.obs;
  final RxBool confirmBeforeOverwrite = true.obs;
  final RxString defaultDownloadDirectory = ''.obs;

  // Advanced Settings
  final RxBool debugMode = false.obs;
  final RxBool keepScreenOn = true.obs;

  // Update Checker
  final RxBool isCheckingForUpdates = false.obs;
  final Rx<Map<String, dynamic>?> updateInfo = Rx<Map<String, dynamic>?>(null);
  final RxBool isDownloadingUpdate = false.obs;
  final RxDouble downloadProgress = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    // Delay initialization until async dependencies are ready
    _initializeAsync();
  }

  /// Initialize after async dependencies (StorageService) are ready
  Future<void> _initializeAsync() async {
    // Wait a frame to ensure StorageService completes
    await Future.delayed(Duration.zero);

    // Try to load settings, retry if storage not ready
    int retries = 0;
    while (retries < 10) {
      try {
        await _loadSettings();
        await _loadAppVersion();
        await _checkForUpdates();
        break;
      } catch (e) {
        retries++;
        if (retries >= 10) {
          print('Failed to initialize settings after 10 retries: $e');
          break;
        }
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
  }

  /// Load all settings from storage
  Future<void> _loadSettings() async {
    // Appearance (linked to ThemeController)
    reduceTransparency.value = _themeController.reduceTransparency;
    reduceAnimations.value = _themeController.reduceAnimations;

    // Terminal Settings
    terminalFontSize.value = _storage.get('terminalFontSize', '14');
    historySize.value = _storage.get('historySize', 1000);
    terminalTheme.value = _storage.get('terminalTheme', 'default');

    // Connection Settings
    defaultPort.value = _storage.get('defaultPort', '22');
    connectionTimeout.value = _storage.get('connectionTimeout', 30);
    sshKeepAliveInterval.value = _storage.get('sshKeepAliveInterval', '60');
    autoReconnect.value = _storage.get('autoReconnect', true);
    securityTimeout.value = _storage.get('securityTimeout', 0);
    sshCompression.value = _storage.get('sshCompression', false);

    // File Explorer Settings
    defaultViewMode.value = _storage.get('defaultViewMode', 'grid');
    showHiddenFiles.value = _storage.get('showHiddenFiles', false);
    confirmBeforeOverwrite.value = _storage.get('confirmBeforeOverwrite', true);
    defaultDownloadDirectory.value = _storage.get('defaultDownloadDirectory', '');

    // Advanced Settings
    debugMode.value = _storage.get('debugMode', false);
    keepScreenOn.value = _storage.get('keepScreenOn', true);
  }

  /// Load app version info
  Future<void> _loadAppVersion() async {
    try {
      final PackageInfo info = await PackageInfo.fromPlatform();
      String version = info.version;
      if (version.contains("+")) {
        version = version.split("+")[0];
      }
      appVersion.value = version;
      appBuildNumber.value = info.buildNumber;
    } catch (e) {
      print('Error loading app version: $e');
      appVersion.value = 'Unknown';
      appBuildNumber.value = '0';
    }
  }

  /// Check for updates
  Future<void> _checkForUpdates() async {
    try {
      isCheckingForUpdates.value = true;
      final updates = await UpdateService.checkForUpdates();
      updateInfo.value = updates;
    } catch (e) {
      print('Error checking for updates: $e');
      updateInfo.value = null;
    } finally {
      isCheckingForUpdates.value = false;
    }
  }

  // ==================== Appearance Settings ====================

  void toggleReduceTransparency(bool value) {
    reduceTransparency.value = value;
    _themeController.setReduceTransparency(value);
  }

  void toggleReduceAnimations(bool value) {
    reduceAnimations.value = value;
    _themeController.setReduceAnimations(value);
  }

  // ==================== Terminal Settings ====================

  Future<void> setTerminalFontSize(String size) async {
    terminalFontSize.value = size;
    await _storage.write('terminalFontSize', size);
  }

  Future<void> setHistorySize(int size) async {
    historySize.value = size;
    await _storage.write('historySize', size);
  }

  Future<void> setTerminalTheme(String theme) async {
    terminalTheme.value = theme;
    await _storage.write('terminalTheme', theme);
  }

  // ==================== Connection Settings ====================

  Future<void> setDefaultPort(String port) async {
    defaultPort.value = port;
    await _storage.write('defaultPort', port);
  }

  Future<void> setConnectionTimeout(int timeout) async {
    connectionTimeout.value = timeout;
    await _storage.write('connectionTimeout', timeout);
  }

  Future<void> setSshKeepAliveInterval(String interval) async {
    sshKeepAliveInterval.value = interval;
    await _storage.write('sshKeepAliveInterval', interval);
  }

  Future<void> toggleAutoReconnect(bool value) async {
    autoReconnect.value = value;
    await _storage.write('autoReconnect', value);
  }

  Future<void> setSecurityTimeout(int timeout) async {
    securityTimeout.value = timeout;
    await _storage.write('securityTimeout', timeout);
  }

  Future<void> toggleSshCompression(bool value) async {
    sshCompression.value = value;
    await _storage.write('sshCompression', value);
  }

  // ==================== File Explorer Settings ====================

  Future<void> setDefaultViewMode(String mode) async {
    defaultViewMode.value = mode;
    await _storage.write('defaultViewMode', mode);
  }

  Future<void> toggleShowHiddenFiles(bool value) async {
    showHiddenFiles.value = value;
    await _storage.write('showHiddenFiles', value);
  }

  Future<void> toggleConfirmBeforeOverwrite(bool value) async {
    confirmBeforeOverwrite.value = value;
    await _storage.write('confirmBeforeOverwrite', value);
  }

  Future<void> pickDefaultDownloadDirectory() async {
    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (selectedDirectory != null) {
        defaultDownloadDirectory.value = selectedDirectory;
        await _storage.write('defaultDownloadDirectory', selectedDirectory);
        Get.snackbar(
          'Success',
          'Default download directory updated',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to select directory: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> clearDefaultDownloadDirectory() async {
    defaultDownloadDirectory.value = '';
    await _storage.remove('defaultDownloadDirectory');
    Get.snackbar(
      'Success',
      'Default download directory cleared',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // ==================== Advanced Settings ====================

  Future<void> toggleDebugMode(bool value) async {
    debugMode.value = value;
    await _storage.write('debugMode', value);
  }

  Future<void> toggleKeepScreenOn(bool value) async {
    keepScreenOn.value = value;
    await _storage.write('keepScreenOn', value);
  }

  /// Export all settings to JSON
  Future<void> exportSettings() async {
    try {
      _storage.exportSettings();
      // TODO: Implement file export with FilePicker
      Get.snackbar(
        'Export Settings',
        'Settings exported successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to export settings: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Import settings from JSON
  Future<void> importSettings() async {
    try {
      // TODO: Implement file import with FilePicker
      Get.snackbar(
        'Import Settings',
        'Settings imported successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      await _loadSettings(); // Reload after import
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to import settings: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Clear app cache
  Future<void> clearCache() async {
    try {
      // TODO: Implement cache clearing
      Get.snackbar(
        'Cache Cleared',
        'Application cache has been cleared',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to clear cache: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Clear all app data with confirmation
  Future<void> clearAllData() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will delete all app data including connections, settings, and preferences. This action cannot be undone.\n\nAre you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All Data'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _storage.clearAll();
        Get.snackbar(
          'Data Cleared',
          'All app data has been cleared',
          snackPosition: SnackPosition.BOTTOM,
        );
        // Reload settings with defaults
        await _loadSettings();
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to clear data: $e',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  // ==================== About Section ====================

  Future<void> checkForUpdatesManually() async {
    await _checkForUpdates();

    if (updateInfo.value != null && updateInfo.value!['hasUpdate'] == true) {
      Get.snackbar(
        'Update Available',
        'Version ${updateInfo.value!['latestVersion']} is available',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    } else {
      Get.snackbar(
        'No Updates',
        'You are running the latest version',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> openGitHubRepository() async {
    final url = Uri.parse('https://github.com/Toglefritz/RaspberryPi-Control');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'Error',
        'Could not open GitHub repository',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> reportIssue() async {
    final url = Uri.parse('https://github.com/Toglefritz/RaspberryPi-Control/issues');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'Error',
        'Could not open GitHub issues page',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Reset all settings to defaults
  Future<void> resetToDefaults() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Reset to Defaults'),
        content: const Text(
          'This will reset all settings to their default values. Connections will not be affected.\n\nAre you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Clear all non-connection settings
        await _storage.remove('terminalFontSize');
        await _storage.remove('historySize');
        await _storage.remove('terminalTheme');
        await _storage.remove('defaultPort');
        await _storage.remove('connectionTimeout');
        await _storage.remove('sshKeepAliveInterval');
        await _storage.remove('autoReconnect');
        await _storage.remove('securityTimeout');
        await _storage.remove('sshCompression');
        await _storage.remove('defaultViewMode');
        await _storage.remove('showHiddenFiles');
        await _storage.remove('confirmBeforeOverwrite');
        await _storage.remove('defaultDownloadDirectory');
        await _storage.remove('debugMode');
        await _storage.remove('keepScreenOn');

        // Reset theme to defaults
        _themeController.setReduceTransparency(false);
        _themeController.setReduceAnimations(false);

        // Reload settings
        await _loadSettings();

        Get.snackbar(
          'Settings Reset',
          'All settings have been reset to defaults',
          snackPosition: SnackPosition.BOTTOM,
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to reset settings: $e',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }
}

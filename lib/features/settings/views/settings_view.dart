import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/theme_controller.dart';

/// Settings View - Modern glassmorphism design for v3.0
class SettingsView extends GetView<SettingsController> {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Obx(() {
        return ListView(
          padding: const EdgeInsets.all(AppDimensions.spaceLG),
          children: [
            // Quick Actions Card
            _buildQuickActionsCard(isDark),
            const SizedBox(height: AppDimensions.spaceLG),

            // Appearance Section
            _buildSectionHeader('Appearance', Icons.palette_outlined),
            const SizedBox(height: AppDimensions.spaceMD),
            _buildAppearanceSection(isDark),
            const SizedBox(height: AppDimensions.spaceLG),

            // Terminal Settings
            _buildSectionHeader('Terminal', Icons.terminal),
            const SizedBox(height: AppDimensions.spaceMD),
            _buildTerminalSection(isDark),
            const SizedBox(height: AppDimensions.spaceLG),

            // Connection Settings
            _buildSectionHeader('Connection', Icons.wifi),
            const SizedBox(height: AppDimensions.spaceMD),
            _buildConnectionSection(isDark),
            const SizedBox(height: AppDimensions.spaceLG),

            // File Explorer Settings
            _buildSectionHeader('File Explorer', Icons.folder_outlined),
            const SizedBox(height: AppDimensions.spaceMD),
            _buildFileExplorerSection(isDark),
            const SizedBox(height: AppDimensions.spaceLG),

            // Advanced Settings
            _buildSectionHeader('Advanced', Icons.settings_suggest),
            const SizedBox(height: AppDimensions.spaceMD),
            _buildAdvancedSection(isDark),
            const SizedBox(height: AppDimensions.spaceLG),

            // About Section
            _buildSectionHeader('About', Icons.info_outline),
            const SizedBox(height: AppDimensions.spaceMD),
            _buildAboutSection(isDark),
            const SizedBox(height: AppDimensions.spaceXXL),
          ],
        );
      }),
    );
  }

  // ==================== Quick Actions Card ====================
  Widget _buildQuickActionsCard(bool isDark) {
    final themeController = Get.find<ThemeController>();

    return GlassCard(
      padding: const EdgeInsets.all(AppDimensions.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bolt,
                color: AppColors.accentCyan,
                size: 24,
              ),
              const SizedBox(width: AppDimensions.spaceMD),
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor(isDark ? Brightness.dark : Brightness.light),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceLG),

          // Theme Toggle
          Obx(() => _buildGlassToggle(
            icon: themeController.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            title: 'Dark Mode',
            subtitle: 'Toggle between dark and light theme',
            value: themeController.isDarkMode,
            onChanged: (value) => themeController.toggleTheme(),
            accentColor: AppColors.accentPurple,
            isDark: isDark,
          )),

          const SizedBox(height: AppDimensions.spaceMD),

          // Blur Level Selector
          Obx(() => _buildBlurLevelSelector(themeController, isDark)),
        ],
      ),
    );
  }

  Widget _buildBlurLevelSelector(ThemeController themeController, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.blur_on, color: AppColors.accentBlue, size: 20),
            const SizedBox(width: AppDimensions.spaceSM),
            Text(
              'Glass Effect',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textColor(isDark ? Brightness.dark : Brightness.light),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spaceMD),
        Row(
          children: [
            Expanded(
              child: _buildBlurButton('None', 0, themeController, isDark),
            ),
            const SizedBox(width: AppDimensions.spaceSM),
            Expanded(
              child: _buildBlurButton('Low', 1, themeController, isDark),
            ),
            const SizedBox(width: AppDimensions.spaceSM),
            Expanded(
              child: _buildBlurButton('Medium', 2, themeController, isDark),
            ),
            const SizedBox(width: AppDimensions.spaceSM),
            Expanded(
              child: _buildBlurButton('High', 3, themeController, isDark),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBlurButton(String label, int level, ThemeController themeController, bool isDark) {
    final blurLevels = [
      AppDimensions.blurNone,
      AppDimensions.blurLow,
      AppDimensions.blurMedium,
      AppDimensions.blurHigh,
    ];
    final isSelected = themeController.blurLevel.sigma == blurLevels[level];

    return GestureDetector(
      onTap: () {
        final newLevel = [
          GlassBlurLevel.none,
          GlassBlurLevel.low,
          GlassBlurLevel.medium,
          GlassBlurLevel.high,
        ][level];
        themeController.setBlurLevel(newLevel);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accentBlue.withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.accentBlue
                : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? AppColors.accentBlue
                  : AppColors.textColor(isDark ? Brightness.dark : Brightness.light, secondary: true),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== Appearance Section ====================
  Widget _buildAppearanceSection(bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(AppDimensions.spaceLG),
      child: Column(
        children: [
          _buildGlassToggle(
            icon: Icons.opacity,
            title: 'Reduce Transparency',
            subtitle: 'Improve readability on low-end devices',
            value: controller.reduceTransparency.value,
            onChanged: controller.toggleReduceTransparency,
            accentColor: AppColors.accentCyan,
            isDark: isDark,
          ),
          const SizedBox(height: AppDimensions.spaceMD),
          _buildGlassToggle(
            icon: Icons.animation,
            title: 'Reduce Animations',
            subtitle: 'Disable UI animations for better performance',
            value: controller.reduceAnimations.value,
            onChanged: controller.toggleReduceAnimations,
            accentColor: AppColors.accentPurple,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  // ==================== Terminal Section ====================
  Widget _buildTerminalSection(bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(AppDimensions.spaceLG),
      child: Column(
        children: [
          // Font Size Dropdown
          _buildDropdownSetting(
            icon: Icons.text_fields,
            title: 'Font Size',
            subtitle: 'Terminal text size',
            value: controller.terminalFontSize.value,
            items: ['12', '14', '16', '18', '20'],
            onChanged: (value) => controller.setTerminalFontSize(value!),
            accentColor: AppColors.accentBlue,
            isDark: isDark,
          ),
          const SizedBox(height: AppDimensions.spaceMD),

          // History Size
          _buildNumberSetting(
            icon: Icons.history,
            title: 'Command History Size',
            subtitle: 'Number of commands to remember',
            value: controller.historySize.value,
            onChanged: (value) => controller.setHistorySize(value),
            min: 100,
            max: 5000,
            step: 100,
            accentColor: AppColors.accentCyan,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  // ==================== Connection Section ====================
  Widget _buildConnectionSection(bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(AppDimensions.spaceLG),
      child: Column(
        children: [
          // Default Port
          _buildTextFieldSetting(
            icon: Icons.power,
            title: 'Default SSH Port',
            subtitle: 'Standard port is 22',
            value: controller.defaultPort.value,
            onChanged: (value) => controller.setDefaultPort(value),
            keyboardType: TextInputType.number,
            accentColor: AppColors.accentBlue,
            isDark: isDark,
          ),
          const SizedBox(height: AppDimensions.spaceMD),

          // Connection Timeout
          _buildNumberSetting(
            icon: Icons.timer,
            title: 'Connection Timeout',
            subtitle: 'Timeout in seconds (10-120)',
            value: controller.connectionTimeout.value,
            onChanged: (value) => controller.setConnectionTimeout(value),
            min: 10,
            max: 120,
            step: 10,
            accentColor: AppColors.accentCyan,
            isDark: isDark,
          ),
          const SizedBox(height: AppDimensions.spaceMD),

          // Keep Alive Interval
          _buildTextFieldSetting(
            icon: Icons.favorite,
            title: 'Keep-Alive Interval',
            subtitle: 'Seconds between keep-alive packets',
            value: controller.sshKeepAliveInterval.value,
            onChanged: (value) => controller.setSshKeepAliveInterval(value),
            keyboardType: TextInputType.number,
            accentColor: AppColors.accentPurple,
            isDark: isDark,
          ),
          const SizedBox(height: AppDimensions.spaceMD),

          // Auto Reconnect
          _buildGlassToggle(
            icon: Icons.sync,
            title: 'Auto Reconnect',
            subtitle: 'Automatically reconnect on connection loss',
            value: controller.autoReconnect.value,
            onChanged: controller.toggleAutoReconnect,
            accentColor: AppColors.success,
            isDark: isDark,
          ),
          const SizedBox(height: AppDimensions.spaceMD),

          // SSH Compression
          _buildGlassToggle(
            icon: Icons.compress,
            title: 'SSH Compression',
            subtitle: 'Enable data compression (slower on fast networks)',
            value: controller.sshCompression.value,
            onChanged: controller.toggleSshCompression,
            accentColor: AppColors.accentBlue,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  // ==================== File Explorer Section ====================
  Widget _buildFileExplorerSection(bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(AppDimensions.spaceLG),
      child: Column(
        children: [
          // Default View Mode
          _buildDropdownSetting(
            icon: Icons.view_module,
            title: 'Default View Mode',
            subtitle: 'Grid or list view for files',
            value: controller.defaultViewMode.value,
            items: ['grid', 'list'],
            onChanged: (value) => controller.setDefaultViewMode(value!),
            accentColor: AppColors.accentBlue,
            isDark: isDark,
          ),
          const SizedBox(height: AppDimensions.spaceMD),

          // Show Hidden Files
          _buildGlassToggle(
            icon: Icons.visibility_off,
            title: 'Show Hidden Files',
            subtitle: 'Display files starting with .',
            value: controller.showHiddenFiles.value,
            onChanged: controller.toggleShowHiddenFiles,
            accentColor: AppColors.accentCyan,
            isDark: isDark,
          ),
          const SizedBox(height: AppDimensions.spaceMD),

          // Confirm Before Overwrite
          _buildGlassToggle(
            icon: Icons.warning_amber,
            title: 'Confirm Before Overwrite',
            subtitle: 'Ask before replacing existing files',
            value: controller.confirmBeforeOverwrite.value,
            onChanged: controller.toggleConfirmBeforeOverwrite,
            accentColor: AppColors.warning,
            isDark: isDark,
          ),
          const SizedBox(height: AppDimensions.spaceMD),

          // Download Directory
          _buildActionSetting(
            icon: Icons.folder_open,
            title: 'Default Download Directory',
            subtitle: controller.defaultDownloadDirectory.value.isEmpty
                ? 'Not set - will use system default'
                : controller.defaultDownloadDirectory.value,
            buttonText: controller.defaultDownloadDirectory.value.isEmpty ? 'Set' : 'Change',
            onPressed: controller.pickDefaultDownloadDirectory,
            accentColor: AppColors.accentPurple,
            isDark: isDark,
            showClearButton: controller.defaultDownloadDirectory.value.isNotEmpty,
            onClear: controller.clearDefaultDownloadDirectory,
          ),
        ],
      ),
    );
  }

  // ==================== Advanced Section ====================
  Widget _buildAdvancedSection(bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(AppDimensions.spaceLG),
      child: Column(
        children: [
          _buildGlassToggle(
            icon: Icons.bug_report,
            title: 'Debug Mode',
            subtitle: 'Enable verbose logging',
            value: controller.debugMode.value,
            onChanged: controller.toggleDebugMode,
            accentColor: AppColors.warning,
            isDark: isDark,
          ),
          const SizedBox(height: AppDimensions.spaceMD),

          _buildGlassToggle(
            icon: Icons.screen_lock_portrait,
            title: 'Keep Screen On',
            subtitle: 'Prevent screen from sleeping',
            value: controller.keepScreenOn.value,
            onChanged: controller.toggleKeepScreenOn,
            accentColor: AppColors.accentCyan,
            isDark: isDark,
          ),
          const SizedBox(height: AppDimensions.spaceLG),

          Divider(color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: AppDimensions.spaceLG),

          // Data Management
          _buildActionButton(
            icon: Icons.upload_file,
            title: 'Export Settings',
            subtitle: 'Save settings to file',
            onPressed: controller.exportSettings,
            accentColor: AppColors.accentBlue,
            isDark: isDark,
          ),
          const SizedBox(height: AppDimensions.spaceMD),

          _buildActionButton(
            icon: Icons.download,
            title: 'Import Settings',
            subtitle: 'Restore settings from file',
            onPressed: controller.importSettings,
            accentColor: AppColors.accentCyan,
            isDark: isDark,
          ),
          const SizedBox(height: AppDimensions.spaceMD),

          _buildActionButton(
            icon: Icons.cleaning_services,
            title: 'Clear Cache',
            subtitle: 'Free up storage space',
            onPressed: controller.clearCache,
            accentColor: AppColors.warning,
            isDark: isDark,
          ),
          const SizedBox(height: AppDimensions.spaceMD),

          _buildActionButton(
            icon: Icons.delete_forever,
            title: 'Clear All Data',
            subtitle: 'Reset app to defaults (keeps connections)',
            onPressed: controller.clearAllData,
            accentColor: AppColors.error,
            isDark: isDark,
          ),
          const SizedBox(height: AppDimensions.spaceMD),

          _buildActionButton(
            icon: Icons.restore,
            title: 'Reset to Defaults',
            subtitle: 'Restore all settings to default values',
            onPressed: controller.resetToDefaults,
            accentColor: AppColors.accentPurple,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  // ==================== About Section ====================
  Widget _buildAboutSection(bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(AppDimensions.spaceLG),
      child: Column(
        children: [
          // App Version
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.code,
                  color: AppColors.accentBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppDimensions.spaceMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RaspberryPi Control',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor(isDark ? Brightness.dark : Brightness.light),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Version ${controller.appVersion.value}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textColor(
                          isDark ? Brightness.dark : Brightness.light,
                          secondary: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceLG),

          // Update Checker
          Obx(() {
            if (controller.isCheckingForUpdates.value) {
              return Container(
                padding: const EdgeInsets.all(AppDimensions.spaceMD),
                decoration: BoxDecoration(
                  color: AppColors.accentCyan.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.accentCyan.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(AppColors.accentCyan),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spaceMD),
                    Text(
                      'Checking for updates...',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.accentCyan,
                      ),
                    ),
                  ],
                ),
              );
            }

            final updateInfo = controller.updateInfo.value;
            if (updateInfo != null && updateInfo['hasUpdate'] == true) {
              return Container(
                padding: const EdgeInsets.all(AppDimensions.spaceMD),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.success.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.new_releases, color: AppColors.success, size: 20),
                        const SizedBox(width: AppDimensions.spaceSM),
                        Text(
                          'Update Available!',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spaceSM),
                    Text(
                      'Version ${updateInfo['latestVersion']} is available',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textColor(isDark ? Brightness.dark : Brightness.light),
                      ),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          }),

          const SizedBox(height: AppDimensions.spaceLG),

          _buildActionButton(
            icon: Icons.system_update,
            title: 'Check for Updates',
            subtitle: 'Manually check for new versions',
            onPressed: controller.checkForUpdatesManually,
            accentColor: AppColors.accentCyan,
            isDark: isDark,
          ),
          const SizedBox(height: AppDimensions.spaceMD),

          _buildActionButton(
            icon: Icons.open_in_new,
            title: 'GitHub Repository',
            subtitle: 'View source code and contribute',
            onPressed: controller.openGitHubRepository,
            accentColor: AppColors.accentPurple,
            isDark: isDark,
          ),
          const SizedBox(height: AppDimensions.spaceMD),

          _buildActionButton(
            icon: Icons.bug_report,
            title: 'Report an Issue',
            subtitle: 'Submit bugs or feature requests',
            onPressed: controller.reportIssue,
            accentColor: AppColors.warning,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  // ==================== Helper Widgets ====================

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.accentBlue, size: 22),
        const SizedBox(width: AppDimensions.spaceSM),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.accentBlue,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildGlassToggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required Color accentColor,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? accentColor.withOpacity(0.3) : Colors.white.withOpacity(0.05),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onChanged(!value),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spaceMD),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: accentColor, size: 20),
                ),
                const SizedBox(width: AppDimensions.spaceMD),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor(isDark ? Brightness.dark : Brightness.light),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textColor(
                            isDark ? Brightness.dark : Brightness.light,
                            secondary: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: value,
                  onChanged: onChanged,
                  activeColor: accentColor,
                  activeTrackColor: accentColor.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownSetting({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required Color accentColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceMD),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(width: AppDimensions.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor(isDark ? Brightness.dark : Brightness.light),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textColor(
                      isDark ? Brightness.dark : Brightness.light,
                      secondary: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          DropdownButton<String>(
            value: value,
            onChanged: onChanged,
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item),
              );
            }).toList(),
            dropdownColor: isDark ? const Color(0xFF1e2749) : Colors.white,
            style: TextStyle(
              color: AppColors.textColor(isDark ? Brightness.dark : Brightness.light),
              fontSize: 14,
            ),
            underline: const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldSetting({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required Function(String) onChanged,
    TextInputType? keyboardType,
    required Color accentColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceMD),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(width: AppDimensions.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor(isDark ? Brightness.dark : Brightness.light),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textColor(
                      isDark ? Brightness.dark : Brightness.light,
                      secondary: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 80,
            child: TextField(
              controller: TextEditingController(text: value),
              onSubmitted: onChanged,
              keyboardType: keyboardType,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textColor(isDark ? Brightness.dark : Brightness.light),
                fontSize: 14,
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: accentColor.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: accentColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberSetting({
    required IconData icon,
    required String title,
    required String subtitle,
    required int value,
    required Function(int) onChanged,
    required int min,
    required int max,
    required int step,
    required Color accentColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceMD),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              const SizedBox(width: AppDimensions.spaceMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor(isDark ? Brightness.dark : Brightness.light),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textColor(
                          isDark ? Brightness.dark : Brightness.light,
                          secondary: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceMD),
          Row(
            children: [
              IconButton(
                onPressed: value > min ? () => onChanged(value - step) : null,
                icon: Icon(Icons.remove_circle_outline),
                color: value > min ? accentColor : Colors.grey,
              ),
              Expanded(
                child: Slider(
                  value: value.toDouble(),
                  min: min.toDouble(),
                  max: max.toDouble(),
                  divisions: ((max - min) / step).round(),
                  activeColor: accentColor,
                  inactiveColor: accentColor.withOpacity(0.2),
                  onChanged: (val) => onChanged(val.toInt()),
                ),
              ),
              IconButton(
                onPressed: value < max ? () => onChanged(value + step) : null,
                icon: Icon(Icons.add_circle_outline),
                color: value < max ? accentColor : Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionSetting({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onPressed,
    required Color accentColor,
    required bool isDark,
    bool showClearButton = false,
    VoidCallback? onClear,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceMD),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(width: AppDimensions.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor(isDark ? Brightness.dark : Brightness.light),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textColor(
                      isDark ? Brightness.dark : Brightness.light,
                      secondary: true,
                    ),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (showClearButton && onClear != null) ...[
            IconButton(
              onPressed: onClear,
              icon: const Icon(Icons.clear),
              color: AppColors.error,
              tooltip: 'Clear',
            ),
          ],
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor.withOpacity(0.2),
              foregroundColor: accentColor,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: accentColor.withOpacity(0.3)),
              ),
            ),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onPressed,
    required Color accentColor,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spaceMD),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: accentColor, size: 20),
                ),
                const SizedBox(width: AppDimensions.spaceMD),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor(isDark ? Brightness.dark : Brightness.light),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textColor(
                            isDark ? Brightness.dark : Brightness.light,
                            secondary: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: accentColor.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

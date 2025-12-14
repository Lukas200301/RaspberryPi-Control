import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/dashboard_widget_type.dart';

/// Widget Customization Service - Manages dashboard widget visibility and order
class WidgetCustomizationService extends GetxService {
  static const String _storageKey = 'dashboard_widget_config';

  final widgetConfigs = <DashboardWidgetConfig>[].obs;

  /// Initialize service (for GetX putAsync)
  Future<WidgetCustomizationService> init() async {
    await loadConfiguration();
    return this;
  }

  @override
  void onInit() {
    super.onInit();
    // Load configuration synchronously to ensure it's ready when service is used
    loadConfiguration();
  }

  /// Load widget configuration from storage
  Future<void> loadConfiguration() async {
    print('📦 Loading widget configuration...');
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString != null) {
        print('📦 Found saved config');
        final List<dynamic> jsonList = json.decode(jsonString);
        widgetConfigs.value = jsonList
            .map((json) => DashboardWidgetConfig.fromJson(json))
            .toList();
        print('📦 Loaded ${widgetConfigs.length} widget configs');
      } else {
        // Initialize with defaults
        print('📦 No saved config, using defaults');
        resetToDefaults();
      }
    } catch (e) {
      print('❌ Error loading widget configuration: $e');
      resetToDefaults();
    }
  }

  /// Save widget configuration to storage
  Future<void> saveConfiguration() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = widgetConfigs.map((config) => config.toJson()).toList();
      await prefs.setString(_storageKey, json.encode(jsonList));
    } catch (e) {
      print('Error saving widget configuration: $e');
    }
  }

  /// Reset to default configuration
  void resetToDefaults() {
    print('🔄 Resetting to defaults');
    widgetConfigs.value = DashboardWidgetType.values
        .map((type) => DashboardWidgetConfig.defaultConfig(type))
        .toList();
    print('🔄 Created ${widgetConfigs.length} default configs');
    saveConfiguration();
  }

  /// Get visible widgets in order
  List<DashboardWidgetConfig> getVisibleWidgets() {
    final visible = widgetConfigs.where((config) => config.isVisible).toList();
    visible.sort((a, b) => a.order.compareTo(b.order));
    return visible;
  }

  /// Toggle widget visibility
  void toggleWidgetVisibility(DashboardWidgetType type) {
    print('🔧 Toggling widget: $type');
    print('🔧 Current configs count: ${widgetConfigs.length}');
    final index = widgetConfigs.indexWhere((config) => config.type == type);
    print('🔧 Found index: $index');
    if (index >= 0) {
      // Create a new list to trigger reactivity
      final configs = List<DashboardWidgetConfig>.from(widgetConfigs);
      configs[index] = configs[index].copyWith(
        isVisible: !configs[index].isVisible,
      );
      print('🔧 New visibility: ${configs[index].isVisible}');
      widgetConfigs.value = configs;
      saveConfiguration();
    }
  }

  /// Set widget visibility
  void setWidgetVisibility(DashboardWidgetType type, bool visible) {
    final index = widgetConfigs.indexWhere((config) => config.type == type);
    if (index >= 0) {
      final configs = List<DashboardWidgetConfig>.from(widgetConfigs);
      configs[index] = configs[index].copyWith(
        isVisible: visible,
      );
      widgetConfigs.value = configs;
      saveConfiguration();
    }
  }

  /// Reorder widgets
  void reorderWidgets(int oldIndex, int newIndex) {
    print('🔄 Reordering: $oldIndex -> $newIndex');
    print('🔄 Configs count: ${widgetConfigs.length}');

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    // Create a new list to maintain reactivity
    final configs = List<DashboardWidgetConfig>.from(widgetConfigs);
    final item = configs.removeAt(oldIndex);
    configs.insert(newIndex, item);

    // Update orders for ALL widgets
    for (int i = 0; i < configs.length; i++) {
      configs[i] = configs[i].copyWith(order: i);
    }

    // Update the observable list
    widgetConfigs.value = configs;
    print('🔄 Reorder complete');
    saveConfiguration();
  }

  /// Check if widget is visible
  bool isWidgetVisible(DashboardWidgetType type) {
    final config = widgetConfigs.firstWhereOrNull((c) => c.type == type);
    return config?.isVisible ?? type.defaultVisible;
  }

  /// Get widget count
  int get visibleWidgetCount =>
      widgetConfigs.where((c) => c.isVisible).length;

  int get totalWidgetCount => widgetConfigs.length;

  /// Show all widgets
  void showAllWidgets() {
    final configs = List<DashboardWidgetConfig>.from(widgetConfigs);
    for (int i = 0; i < configs.length; i++) {
      configs[i] = configs[i].copyWith(isVisible: true);
    }
    widgetConfigs.value = configs;
    saveConfiguration();
  }

  /// Hide all widgets except essentials
  void showEssentialsOnly() {
    final configs = List<DashboardWidgetConfig>.from(widgetConfigs);
    for (int i = 0; i < configs.length; i++) {
      final type = configs[i].type;
      final isEssential = type == DashboardWidgetType.heroStats ||
          type == DashboardWidgetType.cpuChart ||
          type == DashboardWidgetType.memoryChart;

      configs[i] = configs[i].copyWith(isVisible: isEssential);
    }
    widgetConfigs.value = configs;
    saveConfiguration();
  }
}

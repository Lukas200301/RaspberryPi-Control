import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import '../../../core/services/ssh_service_controller.dart';
import '../../../core/services/storage_service.dart';
import '../../../pages/settings/models/dashboard_widget_info.dart';
import '../../../controllers/stats_controller.dart';

/// Dashboard Controller for RaspberryPi Control v3.0
/// Manages system monitoring, stats collection, and widget customization
class DashboardController extends GetxController {
  static DashboardController get to => Get.find();

  // Services
  SSHServiceController get _sshController => Get.find<SSHServiceController>();
  StorageService get _storage => Get.find<StorageService>();

  // Monitoring State
  final RxBool isLoading = true.obs;
  final RxBool isConnected = false.obs;
  final RxBool isMonitoring = false.obs;

  // Current Stats (reactive)
  final RxDouble cpuUsage = 0.0.obs;
  final RxDouble memoryUsage = 0.0.obs;
  final RxDouble memoryTotal = 0.0.obs;
  final RxDouble memoryUsed = 0.0.obs;
  final RxDouble cpuTemperature = 0.0.obs;
  final RxDouble gpuTemperature = 0.0.obs;
  final RxDouble networkIn = 0.0.obs;
  final RxDouble networkOut = 0.0.obs;
  final RxDouble pingLatency = 0.0.obs;
  final RxString uptime = ''.obs;
  final RxList<Map<String, dynamic>> disks = <Map<String, dynamic>>[].obs;

  // Chart History (for time-series graphs)
  final RxList<FlSpot> cpuHistory = <FlSpot>[].obs;
  final RxList<FlSpot> memoryHistory = <FlSpot>[].obs;
  final RxList<FlSpot> cpuTempHistory = <FlSpot>[].obs;
  final RxList<FlSpot> gpuTempHistory = <FlSpot>[].obs;
  final RxList<FlSpot> networkInHistory = <FlSpot>[].obs;
  final RxList<FlSpot> networkOutHistory = <FlSpot>[].obs;

  // Advanced CPU stats
  final RxList<FlSpot> cpuUserHistory = <FlSpot>[].obs;
  final RxList<FlSpot> cpuSystemHistory = <FlSpot>[].obs;
  final RxList<FlSpot> cpuNiceHistory = <FlSpot>[].obs;
  final RxList<FlSpot> cpuIoWaitHistory = <FlSpot>[].obs;
  final RxList<FlSpot> cpuIrqHistory = <FlSpot>[].obs;

  // Network stats
  final RxList<FlSpot> pingLatencyHistory = <FlSpot>[].obs;

  // System logs
  final RxList<dynamic> systemLogs = <dynamic>[].obs;

  // Widget Customization
  final RxList<DashboardWidgetInfo> dashboardWidgets = <DashboardWidgetInfo>[].obs;

  // Services
  final RxList<Map<String, dynamic>> services = <Map<String, dynamic>>[].obs;

  // Internal
  StreamSubscription? _connectionSubscription;

  @override
  void onInit() {
    super.onInit();
    _initializeAsync();
  }

  /// Initialize dashboard after dependencies are ready
  Future<void> _initializeAsync() async {
    await Future.delayed(Duration.zero);

    int retries = 0;
    while (retries < 10) {
      try {
        await _loadDashboardSettings();
        _setupConnectionListener();

        // Start monitoring if already connected
        if (_sshController.isConnected) {
          isConnected.value = true;
          await startMonitoring();
        }

        isLoading.value = false;
        break;
      } catch (e) {
        retries++;
        if (retries >= 10) {
          print('Failed to initialize dashboard after 10 retries: $e');
          isLoading.value = false;
          break;
        }
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
  }

  /// Setup connection status listener
  void _setupConnectionListener() {
    // Poll connection status periodically
    Timer.periodic(const Duration(seconds: 1), (_) {
      final connected = _sshController.isConnected;

      if (isConnected.value != connected) {
        isConnected.value = connected;

        if (connected) {
          startMonitoring();
        } else {
          stopMonitoring();
          _clearStats();
        }
      }
    });
  }

  /// Load dashboard widget settings from storage
  Future<void> _loadDashboardSettings() async {
    try {
      // Use the existing static method from DashboardWidgetInfo
      dashboardWidgets.value = DashboardWidgetInfo.getDefaultWidgets();
    } catch (e) {
      print('Error loading dashboard settings: $e');
      dashboardWidgets.value = DashboardWidgetInfo.getDefaultWidgets();
    }
  }

  /// Save dashboard widget settings
  Future<void> saveDashboardSettings() async {
    try {
      // Store visibility state
      final visibilityMap = {
        for (var widget in dashboardWidgets) widget.id: widget.visible
      };
      await _storage.write('dashboardWidgetVisibility', visibilityMap);
    } catch (e) {
      print('Error saving dashboard settings: $e');
    }
  }

  /// Start system monitoring
  Future<void> startMonitoring() async {
    if (isMonitoring.value || _sshController.service == null) return;

    isMonitoring.value = true;
    isLoading.value = true;

    try {
      // Use existing StatsController
      StatsController.instance.startMonitoring(_sshController.service!);

      // Subscribe to stats stream
      _connectionSubscription = StatsController.instance.statsStream.listen((stats) {
        // Update current stats
        cpuUsage.value = stats['cpu']?.toDouble() ?? 0.0;
        memoryUsage.value = stats['memory']?.toDouble() ?? 0.0;
        memoryTotal.value = stats['memory_total']?.toDouble() ?? 0.0;
        memoryUsed.value = stats['memory_used']?.toDouble() ?? 0.0;
        cpuTemperature.value = stats['cpu_temperature']?.toDouble() ?? 0.0;
        gpuTemperature.value = stats['gpu_temperature']?.toDouble() ?? 0.0;
        networkIn.value = stats['network_in']?.toDouble() ?? 0.0;
        networkOut.value = stats['network_out']?.toDouble() ?? 0.0;
        pingLatency.value = stats['ping_latency']?.toDouble() ?? 0.0;
        uptime.value = stats['uptime'] ?? '';
        disks.value = List<Map<String, dynamic>>.from(stats['disks'] ?? []);

        // Sync history from StatsController
        cpuHistory.value = List.from(StatsController.instance.cpuHistory);
        memoryHistory.value = List.from(StatsController.instance.memoryHistory);
        cpuTempHistory.value = List.from(StatsController.instance.cpuTempHistory);
        gpuTempHistory.value = List.from(StatsController.instance.gpuTempHistory);
        networkInHistory.value = List.from(StatsController.instance.networkInHistory);
        networkOutHistory.value = List.from(StatsController.instance.networkOutHistory);
        cpuUserHistory.value = List.from(StatsController.instance.cpuUserHistory);
        cpuSystemHistory.value = List.from(StatsController.instance.cpuSystemHistory);
        cpuNiceHistory.value = List.from(StatsController.instance.cpuNiceHistory);
        cpuIoWaitHistory.value = List.from(StatsController.instance.cpuIoWaitHistory);
        cpuIrqHistory.value = List.from(StatsController.instance.cpuIrqHistory);
        pingLatencyHistory.value = List.from(StatsController.instance.pingLatencyHistory);

        // Update services
        if (stats['services'] != null) {
          services.value = List<Map<String, dynamic>>.from(stats['services']);
        }

        // Update system logs
        if (stats['logs'] != null) {
          systemLogs.value = List.from(stats['logs']);
        }

        isLoading.value = false;
      }, onError: (error) {
        print('Stats stream error: $error');
        isLoading.value = false;
      });
    } catch (e) {
      print('Failed to start monitoring: $e');
      isLoading.value = false;
    }
  }

  /// Stop system monitoring
  void stopMonitoring() {
    isMonitoring.value = false;
    StatsController.instance.stopStatsMonitoring();
    _connectionSubscription?.cancel();
  }

  /// Clear all stats
  void _clearStats() {
    cpuUsage.value = 0.0;
    memoryUsage.value = 0.0;
    memoryTotal.value = 0.0;
    memoryUsed.value = 0.0;
    cpuTemperature.value = 0.0;
    gpuTemperature.value = 0.0;
    networkIn.value = 0.0;
    networkOut.value = 0.0;
    pingLatency.value = 0.0;
    uptime.value = '';
    disks.clear();

    cpuHistory.clear();
    memoryHistory.clear();
    cpuTempHistory.clear();
    gpuTempHistory.clear();
    networkInHistory.clear();
    networkOutHistory.clear();
    cpuUserHistory.clear();
    cpuSystemHistory.clear();
    cpuNiceHistory.clear();
    cpuIoWaitHistory.clear();
    cpuIrqHistory.clear();
    pingLatencyHistory.clear();
    systemLogs.clear();
    services.clear();
  }

  /// Toggle widget visibility
  void toggleWidgetVisibility(String widgetId) {
    final index = dashboardWidgets.indexWhere((w) => w.id == widgetId);
    if (index != -1) {
      // Modify the visible property directly
      dashboardWidgets[index].visible = !dashboardWidgets[index].visible;
      dashboardWidgets.refresh(); // Trigger reactive update
      saveDashboardSettings();
    }
  }

  /// Reorder widgets
  void reorderWidgets(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final widget = dashboardWidgets.removeAt(oldIndex);
    dashboardWidgets.insert(newIndex, widget);
    saveDashboardSettings();
  }

  /// Reset dashboard to default layout
  Future<void> resetToDefaults() async {
    dashboardWidgets.value = DashboardWidgetInfo.getDefaultWidgets();
    await saveDashboardSettings();
  }

  @override
  void onClose() {
    stopMonitoring();
    _connectionSubscription?.cancel();
    super.onClose();
  }
}

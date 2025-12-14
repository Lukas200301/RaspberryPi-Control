/// Dashboard Widget Types - All available widgets
enum DashboardWidgetType {
  heroStats,
  cpuChart,
  memoryChart,
  temperatureChart,
  networkChart,
  diskUsage,
  networkPing,
  systemProcesses,
  activeConnections,
  systemLogs,
  serviceControl,
}

extension DashboardWidgetTypeExtension on DashboardWidgetType {
  String get displayName {
    switch (this) {
      case DashboardWidgetType.heroStats:
        return 'System Overview';
      case DashboardWidgetType.cpuChart:
        return 'CPU Usage Chart';
      case DashboardWidgetType.memoryChart:
        return 'Memory Usage Chart';
      case DashboardWidgetType.temperatureChart:
        return 'Temperature Chart';
      case DashboardWidgetType.networkChart:
        return 'Network Traffic Chart';
      case DashboardWidgetType.diskUsage:
        return 'Disk Usage';
      case DashboardWidgetType.networkPing:
        return 'Network Ping';
      case DashboardWidgetType.systemProcesses:
        return 'System Processes';
      case DashboardWidgetType.activeConnections:
        return 'Active Connections';
      case DashboardWidgetType.systemLogs:
        return 'System Logs';
      case DashboardWidgetType.serviceControl:
        return 'Service Control';
    }
  }

  String get description {
    switch (this) {
      case DashboardWidgetType.heroStats:
        return 'Key system metrics at a glance';
      case DashboardWidgetType.cpuChart:
        return 'Real-time CPU usage graph';
      case DashboardWidgetType.memoryChart:
        return 'Memory consumption over time';
      case DashboardWidgetType.temperatureChart:
        return 'CPU & GPU temperature monitoring';
      case DashboardWidgetType.networkChart:
        return 'Network in/out traffic';
      case DashboardWidgetType.diskUsage:
        return 'Storage space per partition';
      case DashboardWidgetType.networkPing:
        return 'Network latency monitoring';
      case DashboardWidgetType.systemProcesses:
        return 'Top processes by CPU/Memory';
      case DashboardWidgetType.activeConnections:
        return 'Active network connections';
      case DashboardWidgetType.systemLogs:
        return 'Recent system log entries';
      case DashboardWidgetType.serviceControl:
        return 'Manage system services';
    }
  }

  String get iconName {
    switch (this) {
      case DashboardWidgetType.heroStats:
        return 'dashboard';
      case DashboardWidgetType.cpuChart:
        return 'speed';
      case DashboardWidgetType.memoryChart:
        return 'memory';
      case DashboardWidgetType.temperatureChart:
        return 'thermostat';
      case DashboardWidgetType.networkChart:
        return 'network_check';
      case DashboardWidgetType.diskUsage:
        return 'storage';
      case DashboardWidgetType.networkPing:
        return 'wifi_tethering';
      case DashboardWidgetType.systemProcesses:
        return 'widgets';
      case DashboardWidgetType.activeConnections:
        return 'cable';
      case DashboardWidgetType.systemLogs:
        return 'article';
      case DashboardWidgetType.serviceControl:
        return 'settings_applications';
    }
  }

  /// Default visibility
  bool get defaultVisible {
    switch (this) {
      case DashboardWidgetType.heroStats:
      case DashboardWidgetType.cpuChart:
      case DashboardWidgetType.memoryChart:
      case DashboardWidgetType.temperatureChart:
      case DashboardWidgetType.diskUsage:
      case DashboardWidgetType.systemProcesses:
        return true;
      default:
        return false;
    }
  }

  /// Default order
  int get defaultOrder {
    switch (this) {
      case DashboardWidgetType.heroStats:
        return 0;
      case DashboardWidgetType.cpuChart:
        return 1;
      case DashboardWidgetType.memoryChart:
        return 2;
      case DashboardWidgetType.temperatureChart:
        return 3;
      case DashboardWidgetType.networkChart:
        return 4;
      case DashboardWidgetType.diskUsage:
        return 5;
      case DashboardWidgetType.networkPing:
        return 6;
      case DashboardWidgetType.systemProcesses:
        return 7;
      case DashboardWidgetType.activeConnections:
        return 8;
      case DashboardWidgetType.systemLogs:
        return 9;
      case DashboardWidgetType.serviceControl:
        return 10;
    }
  }
}

/// Dashboard Widget Configuration
class DashboardWidgetConfig {
  final DashboardWidgetType type;
  final bool isVisible;
  final int order;

  DashboardWidgetConfig({
    required this.type,
    required this.isVisible,
    required this.order,
  });

  DashboardWidgetConfig copyWith({
    DashboardWidgetType? type,
    bool? isVisible,
    int? order,
  }) {
    return DashboardWidgetConfig(
      type: type ?? this.type,
      isVisible: isVisible ?? this.isVisible,
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'isVisible': isVisible,
      'order': order,
    };
  }

  factory DashboardWidgetConfig.fromJson(Map<String, dynamic> json) {
    return DashboardWidgetConfig(
      type: DashboardWidgetType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => DashboardWidgetType.heroStats,
      ),
      isVisible: json['isVisible'] ?? true,
      order: json['order'] ?? 0,
    );
  }

  factory DashboardWidgetConfig.defaultConfig(DashboardWidgetType type) {
    return DashboardWidgetConfig(
      type: type,
      isVisible: type.defaultVisible,
      order: type.defaultOrder,
    );
  }
}

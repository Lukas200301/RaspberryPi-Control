import 'package:flutter/material.dart';

class DashboardWidgetInfo {
  final String id;
  final String name;
  final IconData icon;
  bool visible;
  
  DashboardWidgetInfo({
    required this.id,
    required this.name,
    required this.icon,
    this.visible = true,
  });

  static List<DashboardWidgetInfo> getDefaultWidgets() {
    return [
      DashboardWidgetInfo(id: 'system_info', name: 'System Info', icon: Icons.info_outline),
      DashboardWidgetInfo(id: 'service_control', name: 'Service Control', icon: Icons.miscellaneous_services),
      DashboardWidgetInfo(id: 'hardware_monitor', name: 'Hardware Monitor', icon: Icons.memory),
      DashboardWidgetInfo(id: 'system_processes', name: 'Processes', icon: Icons.view_list),
      DashboardWidgetInfo(id: 'disk_usage', name: 'Disk Usage', icon: Icons.storage),
      DashboardWidgetInfo(id: 'active_connections', name: 'Network Connections', icon: Icons.device_hub),
      DashboardWidgetInfo(id: 'cpu_chart', name: 'CPU Chart', icon: Icons.speed),
      DashboardWidgetInfo(id: 'memory_chart', name: 'Memory Chart', icon: Icons.sd_card),
      DashboardWidgetInfo(id: 'network_ping', name: 'Network Ping', icon: Icons.network_ping),
      DashboardWidgetInfo(id: 'temperature_chart', name: 'Temperature Chart', icon: Icons.thermostat),
      DashboardWidgetInfo(id: 'network_chart', name: 'Network Chart', icon: Icons.network_check),
      DashboardWidgetInfo(id: 'system_logs', name: 'System Logs', icon: Icons.article),
    ];
  }
}

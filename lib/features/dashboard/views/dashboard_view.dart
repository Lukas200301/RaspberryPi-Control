import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/dashboard_controller.dart';
import '../../../controllers/stats_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/services/ssh_service_controller.dart';
import '../../../pages/stats/service_control_page.dart';
import '../../../pages/stats/process_control_page.dart';
import '../../../pages/stats/network_connections_page.dart';
import 'widgets/widget_customization_sheet.dart';

/// Dashboard View - Main stats and monitoring page for v3.0
/// Complete redesign with glassmorphism based on SSH data
class DashboardView extends GetView<DashboardController> {
  const DashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildContent(context),

        // Floating customize button
        Positioned(
          right: AppDimensions.spaceLG,
          bottom: AppDimensions.spaceLG + 80, // Above bottom nav
          child: FloatingActionButton.extended(
            onPressed: () {
              Get.bottomSheet(
                const WidgetCustomizationSheet(),
                isScrollControlled: true,
                enableDrag: true,
              );
            },
            heroTag: 'customize_dashboard',
            backgroundColor: AppColors.accentIndigo,
            icon: const Icon(Icons.tune),
            label: const Text('Customize'),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Obx(() {
      // Loading state
      if (controller.isLoading.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.accentIndigo),
              const SizedBox(height: AppDimensions.spaceMD),
              Text('Connecting to Raspberry Pi...', 
                style: TextStyle(color: Colors.white70)),
            ],
          ),
        );
      }

      // Not connected state
      if (!controller.isConnected.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(AppDimensions.spaceLG),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accentIndigo.withOpacity(0.3),
                      AppColors.accentTeal.withOpacity(0.3),
                    ],
                  ),
                  boxShadow: [AppColors.indigoGlow()],
                ),
                child: Icon(Icons.cloud_off, size: 64, color: Colors.white70),
              ),
              const SizedBox(height: AppDimensions.spaceLG),
              Text('Not Connected',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                )),
              const SizedBox(height: AppDimensions.spaceSM),
              Text('Connect to a Raspberry Pi to view dashboard',
                style: TextStyle(color: Colors.white60)),
            ],
          ),
        );
      }

      // Main Dashboard
      return RefreshIndicator(
        onRefresh: () async {
          controller.stopMonitoring();
          await Future.delayed(const Duration(milliseconds: 500));
          await controller.startMonitoring();
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.spaceMD,
            AppDimensions.spaceMD,
            AppDimensions.spaceMD,
            100,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // System Info Hero Card
              _buildSystemInfoCard(context),
              SizedBox(height: AppDimensions.spaceMD),

              // Quick Stats Grid (CPU, Memory, Temps)
              _buildQuickStatsGrid(context),
              SizedBox(height: AppDimensions.spaceMD),

              // CPU Chart
              _buildCpuChart(context),
              SizedBox(height: AppDimensions.spaceMD),

              // Memory Chart
              _buildMemoryChart(context),
              SizedBox(height: AppDimensions.spaceMD),

              // Temperature Chart
              _buildTemperatureChart(context),
              SizedBox(height: AppDimensions.spaceMD),

              // Network Chart
              _buildNetworkChart(context),
              SizedBox(height: AppDimensions.spaceMD),

              // Disk Usage
              _buildDiskUsage(context),
              SizedBox(height: AppDimensions.spaceMD),

              // System Processes
              _buildProcesses(context),
              SizedBox(height: AppDimensions.spaceMD),

              // Active Network Connections
              _buildActiveConnections(context),
              SizedBox(height: AppDimensions.spaceMD),

              // Service Control
              _buildServiceControl(context),
              SizedBox(height: 100),
            ],
          ),
        ),
      );
    });
  }

  /// System Info Hero Card with hostname, OS, uptime
  Widget _buildSystemInfoCard(BuildContext context) {
    final stats = Get.find<StatsController>();
    final currentStats = stats.currentStats;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDimensions.spaceLG),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        gradient: AppColors.glassGradientDark,
        border: Border.all(color: AppColors.glassBorderDark(), width: 1.5),
        boxShadow: [AppColors.indigoGlow()],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppDimensions.spaceSM),
                decoration: BoxDecoration(
                  color: AppColors.accentIndigo.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                ),
                child: Icon(Icons.devices, color: AppColors.accentIndigo, size: 28),
              ),
              SizedBox(width: AppDimensions.spaceMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentStats['hostname'] ?? 'Raspberry Pi',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      currentStats['os'] ?? 'Linux',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.spaceSM,
                  vertical: AppDimensions.spaceXS,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                  border: Border.all(color: AppColors.success.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.success,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.success.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 6),
                    Text('ONLINE', style: TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    )),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spaceMD),
          Divider(color: Colors.white12),
          SizedBox(height: AppDimensions.spaceSM),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem(Icons.wifi, 'IP', currentStats['ip_address'] ?? 'N/A'),
              _buildInfoItem(Icons.timer, 'Uptime', currentStats['uptime'] ?? '0m'),
              _buildInfoItem(Icons.memory, 'CPU', currentStats['cpu_model']?.split(' ').take(2).join(' ') ?? 'N/A'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.accentTeal),
          SizedBox(width: 6),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.white54, fontSize: 11)),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Quick Stats Grid - CPU, Memory, Temperature gauges
  Widget _buildQuickStatsGrid(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildQuickStatCard(
          'CPU',
          '${controller.cpuUsage.value.toStringAsFixed(1)}%',
          controller.cpuUsage.value,
          AppColors.accentIndigo,
          Icons.speed,
        )),
        SizedBox(width: AppDimensions.spaceSM),
        Expanded(child: _buildQuickStatCard(
          'Memory',
          '${controller.memoryUsage.value.toStringAsFixed(1)}%',
          controller.memoryUsage.value,
          AppColors.accentTeal,
          Icons.memory,
        )),
        SizedBox(width: AppDimensions.spaceSM),
        Expanded(child: _buildQuickStatCard(
          'CPU Temp',
          '${controller.cpuTemperature.value.toStringAsFixed(1)}°C',
          (controller.cpuTemperature.value / 85.0) * 100,
          _getTempColor(controller.cpuTemperature.value),
          Icons.thermostat,
        )),
      ],
    );
  }

  Widget _buildQuickStatCard(String title, String value, double percentage, Color accentColor, IconData icon) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.spaceMD),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        gradient: AppColors.glassGradientDark,
        border: Border.all(color: accentColor.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.2),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: accentColor, size: 24),
          SizedBox(height: AppDimensions.spaceXS),
          Text(title, style: TextStyle(color: Colors.white60, fontSize: 11)),
          SizedBox(height: 4),
          Text(value, style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          )),
          SizedBox(height: AppDimensions.spaceXS),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation(accentColor),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTempColor(double temp) {
    if (temp > 75) return AppColors.error;
    if (temp > 60) return AppColors.warning;
    return AppColors.accentCyan;
  }

  /// CPU Chart with time-series graph
  Widget _buildCpuChart(BuildContext context) {
    return _buildChartCard(
      context,
      title: 'CPU Usage',
      icon: Icons.speed,
      accentColor: AppColors.accentIndigo,
      data: controller.cpuHistory,
      maxY: 100,
      unit: '%',
    );
  }

  /// Memory Chart
  Widget _buildMemoryChart(BuildContext context) {
    return _buildChartCard(
      context,
      title: 'Memory Usage',
      icon: Icons.memory,
      accentColor: AppColors.accentTeal,
      data: controller.memoryHistory,
      maxY: 100,
      unit: '%',
    );
  }

  /// Temperature Chart
  Widget _buildTemperatureChart(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.spaceLG),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        gradient: AppColors.glassGradientDark,
        border: Border.all(color: AppColors.accentCyan.withOpacity(0.3), width: 1.5),
        boxShadow: [AppColors.cyanGlow()],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.thermostat, color: AppColors.accentCyan),
              SizedBox(width: AppDimensions.spaceSM),
              Text('Temperature', style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              )),
            ],
          ),
          SizedBox(height: AppDimensions.spaceMD),
          SizedBox(
            height: 200,
            child: controller.cpuTempHistory.isEmpty
                ? Center(child: Text('Collecting data...', style: TextStyle(color: Colors.white54)))
                : LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: 85,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: Colors.white10,
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, _) => Text(
                              '${value.toInt()}°C',
                              style: TextStyle(color: Colors.white54, fontSize: 10),
                            ),
                          ),
                        ),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        // CPU Temp
                        LineChartBarData(
                          spots: controller.cpuTempHistory,
                          isCurved: true,
                          color: AppColors.accentCyan,
                          barWidth: 3,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.accentCyan.withOpacity(0.3),
                                AppColors.accentCyan.withOpacity(0.0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                        // GPU Temp
                        if (controller.gpuTempHistory.isNotEmpty)
                          LineChartBarData(
                            spots: controller.gpuTempHistory,
                            isCurved: true,
                            color: AppColors.accentPurple,
                            barWidth: 3,
                            dotData: FlDotData(show: false),
                          ),
                      ],
                    ),
                  ),
          ),
          SizedBox(height: AppDimensions.spaceSM),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem(AppColors.accentCyan, 'CPU', '${controller.cpuTemperature.value.toStringAsFixed(1)}°C'),
              _buildLegendItem(AppColors.accentPurple, 'GPU', '${controller.gpuTemperature.value.toStringAsFixed(1)}°C'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 6),
        Text('$label: ', style: TextStyle(color: Colors.white60, fontSize: 12)),
        Text(value, style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  /// Network Chart
  Widget _buildNetworkChart(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.spaceLG),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        gradient: AppColors.glassGradientDark,
        border: Border.all(color: AppColors.accentTeal.withOpacity(0.3), width: 1.5),
        boxShadow: [AppColors.tealGlow()],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.network_check, color: AppColors.accentTeal),
              SizedBox(width: AppDimensions.spaceSM),
              Text('Network', style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              )),
            ],
          ),
          SizedBox(height: AppDimensions.spaceMD),
          SizedBox(
            height: 200,
            child: controller.networkInHistory.isEmpty
                ? Center(child: Text('Collecting data...', style: TextStyle(color: Colors.white54)))
                : LineChart(
                    LineChartData(
                      minY: 0,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: Colors.white10,
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 50,
                            getTitlesWidget: (value, _) => Text(
                              '${value.toInt()} KB/s',
                              style: TextStyle(color: Colors.white54, fontSize: 10),
                            ),
                          ),
                        ),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        // Download
                        LineChartBarData(
                          spots: controller.networkInHistory,
                          isCurved: true,
                          color: AppColors.accentTeal,
                          barWidth: 3,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.accentTeal.withOpacity(0.3),
                                AppColors.accentTeal.withOpacity(0.0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                        // Upload
                        LineChartBarData(
                          spots: controller.networkOutHistory,
                          isCurved: true,
                          color: AppColors.accentPurple,
                          barWidth: 3,
                          dotData: FlDotData(show: false),
                        ),
                      ],
                    ),
                  ),
          ),
          SizedBox(height: AppDimensions.spaceSM),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem(AppColors.accentTeal, 'Download', '${controller.networkIn.value.toStringAsFixed(1)} KB/s'),
              _buildLegendItem(AppColors.accentPurple, 'Upload', '${controller.networkOut.value.toStringAsFixed(1)} KB/s'),
            ],
          ),
        ],
      ),
    );
  }

  /// Generic chart card builder
  Widget _buildChartCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color accentColor,
    required RxList<FlSpot> data,
    required double maxY,
    required String unit,
  }) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.spaceLG),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        gradient: AppColors.glassGradientDark,
        border: Border.all(color: accentColor.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.2),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor),
              SizedBox(width: AppDimensions.spaceSM),
              Text(title, style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              )),
            ],
          ),
          SizedBox(height: AppDimensions.spaceMD),
          SizedBox(
            height: 200,
            child: data.isEmpty
                ? Center(child: Text('Collecting data...', style: TextStyle(color: Colors.white54)))
                : LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: maxY,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: Colors.white10,
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, _) => Text(
                              '${value.toInt()}$unit',
                              style: TextStyle(color: Colors.white54, fontSize: 10),
                            ),
                          ),
                        ),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: data,
                          isCurved: true,
                          color: accentColor,
                          barWidth: 3,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                accentColor.withOpacity(0.3),
                                accentColor.withOpacity(0.0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  /// Disk Usage
  Widget _buildDiskUsage(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.spaceLG),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        gradient: AppColors.glassGradientDark,
        border: Border.all(color: AppColors.accentPurple.withOpacity(0.3), width: 1.5),
        boxShadow: [AppColors.purpleGlow()],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.storage, color: AppColors.accentPurple),
              SizedBox(width: AppDimensions.spaceSM),
              Text('Disk Usage', style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              )),
            ],
          ),
          SizedBox(height: AppDimensions.spaceMD),
          if (controller.disks.isEmpty)
            Center(child: Text('No disk data available', style: TextStyle(color: Colors.white54)))
          else
            ...controller.disks.map((disk) {
              final percentage = _parseDiskPercentage(disk['used_percentage']);
              return Padding(
                padding: EdgeInsets.only(bottom: AppDimensions.spaceSM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(disk['mount_point'] ?? '/', style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        )),
                        Text('${disk['used']} / ${disk['size']}', style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        )),
                      ],
                    ),
                    SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: Colors.white12,
                        valueColor: AlwaysStoppedAnimation(
                          percentage > 90 ? AppColors.error :
                          percentage > 75 ? AppColors.warning :
                          AppColors.accentPurple
                        ),
                        minHeight: 8,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text('${percentage.toStringAsFixed(1)}% used', style: TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                    )),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  double _parseDiskPercentage(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      final cleaned = value.replaceAll('%', '');
      return double.tryParse(cleaned) ?? 0.0;
    }
    return 0.0;
  }

  /// System Processes
  Widget _buildProcesses(BuildContext context) {
    final stats = Get.find<StatsController>();
    final processes = stats.currentStats['processes'] as List? ?? [];

    return Container(
      padding: EdgeInsets.all(AppDimensions.spaceLG),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        gradient: AppColors.glassGradientDark,
        border: Border.all(color: AppColors.accentIndigo.withOpacity(0.3), width: 1.5),
        boxShadow: [AppColors.indigoGlow()],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.widgets, color: AppColors.accentIndigo),
              SizedBox(width: AppDimensions.spaceSM),
              Text('Top Processes', style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              )),
              Spacer(),
              Text(
                '${processes.length}',
                style: TextStyle(
                  color: AppColors.accentIndigo,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spaceMD),
          if (processes.isEmpty)
            Center(child: Text('No process data available', style: TextStyle(color: Colors.white54)))
          else
            Container(
              constraints: BoxConstraints(maxHeight: 420),
              child: ListView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: processes.length,
                itemBuilder: (context, index) {
                  final process = processes[index];
                  final cpuUsage = (process['cpu'] ?? 0.0) as double;
                  return InkWell(
                    onTap: () => Get.to(() => const ProcessControlPage()),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      margin: EdgeInsets.only(bottom: AppDimensions.spaceSM),
                      padding: EdgeInsets.all(AppDimensions.spaceSM),
                      decoration: BoxDecoration(
                        color: AppColors.accentIndigo.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.accentIndigo.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accentIndigo.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${cpuUsage.toStringAsFixed(1)}%',
                              style: TextStyle(
                                color: AppColors.accentIndigo,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: AppDimensions.spaceSM),
                          Expanded(
                            child: Text(
                              process['command'] ?? 'Unknown',
                              style: TextStyle(color: Colors.white70, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(Icons.chevron_right, color: Colors.white38, size: 16),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          if (processes.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: AppDimensions.spaceMD),
              child: OutlinedButton(
                onPressed: () => Get.to(() => const ProcessControlPage()),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accentIndigo,
                  side: BorderSide(color: AppColors.accentIndigo.withOpacity(0.5)),
                  minimumSize: Size.fromHeight(40),
                ),
                child: Text('View All'),
              ),
            ),
        ],
      ),
    );
  }

  /// Show service logs in a dialog
  void _showServiceLogs(BuildContext context, String serviceName) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      final logs = await Get.find<SSHServiceController>().service?.getServiceStatus(serviceName) ?? 'No logs available';
      Navigator.pop(context);

      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(maxHeight: 600, maxWidth: 500),
            decoration: BoxDecoration(
              gradient: AppColors.glassGradientDark,
              borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
              border: Border.all(color: AppColors.accentIndigo.withOpacity(0.3), width: 1.5),
              boxShadow: [AppColors.indigoGlow()],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.all(AppDimensions.spaceLG),
                  child: Row(
                    children: [
                      Icon(Icons.article, color: AppColors.accentIndigo),
                      SizedBox(width: AppDimensions.spaceSM),
                      Expanded(
                        child: Text(
                          'Logs: $serviceName',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Divider(color: Colors.white12, height: 1),
                Flexible(
                  child: Container(
                    margin: EdgeInsets.all(AppDimensions.spaceMD),
                    padding: EdgeInsets.all(AppDimensions.spaceMD),
                    decoration: BoxDecoration(
                      color: Color(0xFF0A0A0A),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                      border: Border.all(color: AppColors.accentIndigo.withOpacity(0.3), width: 1.5),
                    ),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        logs,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Courier',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to fetch logs: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  /// Build Active Network Connections widget
  Widget _buildActiveConnections(BuildContext context) {
    final stats = Get.find<StatsController>();
    final connections = stats.currentStats['active_connections'] as List? ?? [];

    return Container(
      padding: EdgeInsets.all(AppDimensions.spaceLG),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        gradient: AppColors.glassGradientDark,
        border: Border.all(color: AppColors.accentCyan.withOpacity(0.3), width: 1.5),
        boxShadow: [AppColors.cyanGlow()],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.device_hub, color: AppColors.accentCyan),
                    SizedBox(width: AppDimensions.spaceSM),
                    Flexible(
                      child: Text(
                        'Active Network Connections',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NetworkConnectionsPage(),
                    ),
                  );
                },
                icon: Icon(Icons.arrow_forward, size: 16, color: AppColors.accentCyan),
                label: Text('View All', style: TextStyle(color: AppColors.accentCyan)),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spaceSM),
          if (connections.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(AppDimensions.spaceMD),
                child: Text(
                  'No active connections',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            )
          else
            Container(
              constraints: BoxConstraints(maxHeight: 420),
              child: ListView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: connections.length,
                itemBuilder: (context, index) {
                  final connection = connections[index];
                  final state = connection['state'] ?? '';
                  Color stateColor = _getConnectionStateColor(state);
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NetworkConnectionsPage(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      margin: EdgeInsets.only(bottom: AppDimensions.spaceSM),
                      padding: EdgeInsets.all(AppDimensions.spaceSM),
                      decoration: BoxDecoration(
                        color: AppColors.accentCyan.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: stateColor.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${connection['local_ip']}:${connection['local_port']}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(Icons.arrow_forward, size: 14, color: Colors.white54),
                              Expanded(
                                child: Text(
                                  '${connection['remote_ip']}:${connection['remote_port']}',
                                  style: TextStyle(color: Colors.white70, fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                connection['protocol'] ?? '',
                                style: TextStyle(
                                  color: AppColors.accentCyan,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: stateColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: stateColor.withOpacity(0.5)),
                                ),
                                child: Text(
                                  state,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: stateColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Color _getConnectionStateColor(String state) {
    switch (state) {
      case 'ESTABLISHED':
        return Colors.green;
      case 'TIME_WAIT':
      case 'CLOSE_WAIT':
        return Colors.orange;
      case 'SYN_SENT':
      case 'SYN_RECV':
        return Colors.blue;
      case 'CLOSED':
      case 'CLOSING':
      case 'LAST_ACK':
      case 'FIN_WAIT1':
      case 'FIN_WAIT2':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Service Control Widget - Shows all running services
  Widget _buildServiceControl(BuildContext context) {
    final stats = Get.find<StatsController>();
    final allServices = controller.services;
    final runningServices = allServices
        .where((service) {
          final status = (service['status'] ?? '').toString().toLowerCase();
          return status == 'running' || status == 'active';
        })
        .toList();

    return Container(
      padding: EdgeInsets.all(AppDimensions.spaceLG),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        gradient: AppColors.glassGradientDark,
        border: Border.all(color: AppColors.accentTeal.withOpacity(0.3), width: 1.5),
        boxShadow: [AppColors.tealGlow()],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.settings, color: AppColors.accentTeal),
                  SizedBox(width: AppDimensions.spaceSM),
                  Text('Running Services', style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  )),
                ],
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ServiceControlPage(
                        initialServices: allServices,
                        onStartService: (name) async {
                          try {
                            await Get.find<SSHServiceController>().service?.startService(name);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Started \$name')),
                            );
                            await Future.delayed(Duration(seconds: 1));
                            await stats.refreshServices(Get.find<SSHServiceController>().service!);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to start: \$e')),
                            );
                          }
                        },
                        onStopService: (name) async {
                          try {
                            await Get.find<SSHServiceController>().service?.stopService(name);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Stopped \$name')),
                            );
                            await Future.delayed(Duration(seconds: 1));
                            await stats.refreshServices(Get.find<SSHServiceController>().service!);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to stop: \$e')),
                            );
                          }
                        },
                        onRestartService: (name) async {
                          try {
                            await Get.find<SSHServiceController>().service?.restartService(name);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Restarted \$name')),
                            );
                            await Future.delayed(Duration(seconds: 1));
                            await stats.refreshServices(Get.find<SSHServiceController>().service!);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to restart: \$e')),
                            );
                          }
                        },
                        getServiceLogs: (name) async {
                          try {
                            return await Get.find<SSHServiceController>().service?.getServiceStatus(name) ?? 'No logs available';
                          } catch (e) {
                            return 'Failed to fetch logs: \$e';
                          }
                        },
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.arrow_forward, size: 16, color: AppColors.accentTeal),
                label: Text('View All', style: TextStyle(color: AppColors.accentTeal)),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spaceMD),
          if (runningServices.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(AppDimensions.spaceMD),
                child: Text(
                  'No running services',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            )
          else
            Container(
              constraints: BoxConstraints(maxHeight: 420),
              child: ListView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: runningServices.length,
                itemBuilder: (context, index) {
                  final service = runningServices[index];
                  return InkWell(
                onTap: () => _showServiceLogs(context, service['name'] ?? 'Unknown'),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                child: Container(
                  margin: EdgeInsets.only(bottom: AppDimensions.spaceSM),
                  padding: EdgeInsets.all(AppDimensions.spaceMD),
                  decoration: BoxDecoration(
                    color: AppColors.accentTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                    border: Border.all(
                      color: AppColors.accentTeal.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.success,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.success.withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              service['name'] ?? 'Unknown',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Icon(Icons.chevron_right, color: Colors.white54, size: 20),
                        ],
                      ),
                      if (service['description'] != null && service['description'].toString().isNotEmpty) ...[
                        SizedBox(height: 6),
                        Text(
                          service['description'] ?? '',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      SizedBox(height: AppDimensions.spaceSM),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                try {
                                  await Get.find<SSHServiceController>().service?.stopService(service['name']);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Stopping ${service['name']}...'),
                                      backgroundColor: AppColors.warning,
                                    ),
                                  );
                                  await Future.delayed(Duration(seconds: 1));
                                  await Get.find<StatsController>().refreshServices(Get.find<SSHServiceController>().service!);
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed: $e'),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                }
                              },
                              icon: Icon(Icons.stop, size: 16),
                              label: Text('Stop', style: TextStyle(fontSize: 12)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.error,
                                side: BorderSide(color: AppColors.error.withOpacity(0.5)),
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                          ),
                          SizedBox(width: AppDimensions.spaceSM),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                try {
                                  await Get.find<SSHServiceController>().service?.restartService(service['name']);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Restarting ${service['name']}...'),
                                      backgroundColor: AppColors.accentTeal,
                                    ),
                                  );
                                  await Future.delayed(Duration(seconds: 1));
                                  await Get.find<StatsController>().refreshServices(Get.find<SSHServiceController>().service!);
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed: $e'),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                }
                              },
                              icon: Icon(Icons.refresh, size: 16),
                              label: Text('Restart', style: TextStyle(fontSize: 12)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.accentTeal,
                                side: BorderSide(color: AppColors.accentTeal.withOpacity(0.5)),
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
                },
              ),
            ),
        ],
      ),
    );
  }
}

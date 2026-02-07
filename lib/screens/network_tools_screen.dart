import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../providers/app_providers.dart';
import '../generated/pi_control.pb.dart';

class NetworkToolsScreen extends ConsumerStatefulWidget {
  const NetworkToolsScreen({super.key});

  @override
  ConsumerState<NetworkToolsScreen> createState() => _NetworkToolsScreenState();
}

class _NetworkToolsScreenState extends ConsumerState<NetworkToolsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
        ),
        title: const Text('Network Tools'),
        scrolledUnderElevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          indicatorColor: AppTheme.primaryIndigo,
          indicatorWeight: 3,
          labelColor: AppTheme.primaryIndigo,
          unselectedLabelColor: AppTheme.textSecondary,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 12,
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.network_ping, size: 20),
              text: 'Ping',
            ),
            Tab(
              icon: Icon(Icons.settings_input_component, size: 20),
              text: 'Ports',
            ),
            Tab(
              icon: Icon(Icons.dns, size: 20),
              text: 'DNS',
            ),
            Tab(
              icon: Icon(Icons.speed, size: 20),
              text: 'Speed',
            ),
            Tab(
              icon: Icon(Icons.wifi, size: 20),
              text: 'WiFi',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _PingTab(),
          _PortScannerTab(),
          _DNSLookupTab(),
          _SpeedTestTab(),
          _WiFiTab(),
        ],
      ),
    );
  }
}

// ==================== Ping Tab ====================

class _PingTab extends ConsumerStatefulWidget {
  const _PingTab();

  @override
  ConsumerState<_PingTab> createState() => _PingTabState();
}

class _PingTabState extends ConsumerState<_PingTab> {
  final _hostController = TextEditingController();
  final _countController = TextEditingController(text: '4');
  bool _isPinging = false;
  final List<PingResponse> _pingResults = [];
  final List<double> _latencyHistory = [];

  @override
  void dispose() {
    _hostController.dispose();
    _countController.dispose();
    super.dispose();
  }

  Future<void> _startPing() async {
    if (_hostController.text.isEmpty) return;

    setState(() {
      _isPinging = true;
      _pingResults.clear();
      _latencyHistory.clear();
    });

    final grpcService = ref.read(grpcServiceProvider);

    try {
      final request = PingRequest(
        host: _hostController.text.trim(),
        count: int.tryParse(_countController.text) ?? 4,
        timeout: 5,
        packetSize: 56,
      );

      final stream = grpcService.pingHost(request);

      await for (final response in stream) {
        if (!mounted) break;
        setState(() {
          _pingResults.add(response);
          if (response.success && response.latency > 0) {
            _latencyHistory.add(response.latency);
          }
        });

        if (response.finished) {
          setState(() => _isPinging = false);
          break;
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Ping failed: $e',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppTheme.errorRose,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPinging = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final statsResponse = _pingResults.where((r) => r.hasStatistics()).firstOrNull;
    final stats = statsResponse?.statistics;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Input Section
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ping Host',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Gap(12),
                TextField(
                  controller: _hostController,
                  decoration: InputDecoration(
                    hintText: 'Enter hostname or IP (e.g., google.com, 8.8.8.8)',
                    prefixIcon: const Icon(Icons.dns, color: AppTheme.primaryIndigo),
                    filled: true,
                    fillColor: AppTheme.glassLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.glassBorder),
                    ),
                  ),
                  enabled: !_isPinging,
                ),
                const Gap(12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _countController,
                        decoration: InputDecoration(
                          labelText: 'Count',
                          prefixIcon: const Icon(Icons.numbers, color: AppTheme.secondaryTeal),
                          filled: true,
                          fillColor: AppTheme.glassLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppTheme.glassBorder),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        enabled: !_isPinging,
                      ),
                    ),
                    const Gap(12),
                    ElevatedButton.icon(
                      onPressed: _isPinging ? null : _startPing,
                      icon: Icon(_isPinging ? Icons.stop : Icons.play_arrow),
                      label: Text(_isPinging ? 'Stop' : 'Start Ping'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryIndigo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Gap(24),

          // Statistics
          if (stats != null) ...[
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Statistics',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Gap(12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard('Sent', '${stats.packetsSent}', Icons.send, AppTheme.primaryIndigo),
                      _buildStatCard('Received', '${stats.packetsReceived}', Icons.download, AppTheme.successGreen),
                      _buildStatCard('Loss', '${stats.packetLoss.toStringAsFixed(1)}%', Icons.error_outline, AppTheme.errorRose),
                    ],
                  ),
                  const Gap(12),
                  const Divider(color: AppTheme.glassBorder),
                  const Gap(12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildLatencyCard('Min', stats.minLatency),
                      _buildLatencyCard('Avg', stats.avgLatency),
                      _buildLatencyCard('Max', stats.maxLatency),
                    ],
                  ),
                ],
              ),
            ),
            const Gap(24),
          ],

          // Latency Chart
          if (_latencyHistory.isNotEmpty) ...[
            Text(
              'Latency Graph',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Gap(12),
            GlassCard(
              child: SizedBox(
                height: 200,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: AppTheme.glassBorder,
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) => Text(
                              '${value.toInt()}ms',
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppTheme.textTertiary,
                              ),
                            ),
                          ),
                        ),
                        bottomTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      minY: 0,
                      lineBarsData: [
                        LineChartBarData(
                          spots: _latencyHistory
                              .asMap()
                              .entries
                              .map((e) => FlSpot(e.key.toDouble(), e.value))
                              .toList(),
                          isCurved: true,
                          color: AppTheme.primaryIndigo,
                          barWidth: 3,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) =>
                                FlDotCirclePainter(
                              radius: 3,
                              color: AppTheme.primaryIndigo,
                              strokeWidth: 1,
                              strokeColor: Colors.white,
                            ),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppTheme.primaryIndigo.withValues(alpha: 0.2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const Gap(24),
          ],

          // Results
          if (_pingResults.isNotEmpty) ...[
            Text(
              'Results',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Gap(12),
            GlassCard(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final result in _pingResults.where((r) => !r.finished))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(
                            result.success ? Icons.check_circle : Icons.error,
                            color: result.success ? AppTheme.successGreen : AppTheme.errorRose,
                            size: 16,
                          ),
                          const Gap(8),
                          Expanded(
                            child: Text(
                              result.success
                                  ? 'Reply from ${result.ip}: seq=${result.sequence} ttl=${result.ttl} time=${result.latency.toStringAsFixed(2)}ms'
                                  : 'Request timeout: ${result.error}',
                              style: TextStyle(
                                fontSize: 12,
                                color: result.success ? AppTheme.textPrimary : AppTheme.errorRose,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const Gap(8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildLatencyCard(String label, double latency) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
        const Gap(4),
        Text(
          '${latency.toStringAsFixed(2)}ms',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryIndigo,
          ),
        ),
      ],
    );
  }
}

// ==================== Port Scanner Tab ====================

class _PortScannerTab extends ConsumerStatefulWidget {
  const _PortScannerTab();

  @override
  ConsumerState<_PortScannerTab> createState() => _PortScannerTabState();
}

class _PortScannerTabState extends ConsumerState<_PortScannerTab> {
  final _hostController = TextEditingController();
  final _startPortController = TextEditingController(text: '1');
  final _endPortController = TextEditingController(text: '1024');
  bool _isScanning = false;
  final List<PortScanResponse> _scanResults = [];
  int _progress = 0;
  String _scanMode = 'common'; // common, range, custom

  @override
  void dispose() {
    _hostController.dispose();
    _startPortController.dispose();
    _endPortController.dispose();
    super.dispose();
  }

  Future<void> _startScan() async {
    if (_hostController.text.isEmpty) return;

    setState(() {
      _isScanning = true;
      _scanResults.clear();
      _progress = 0;
    });

    final grpcService = ref.read(grpcServiceProvider);

    try {
      final request = PortScanRequest(
        host: _hostController.text.trim(),
        startPort: _scanMode == 'range' ? int.tryParse(_startPortController.text) ?? 1 : 0,
        endPort: _scanMode == 'range' ? int.tryParse(_endPortController.text) ?? 1024 : 0,
        timeout: 1000,
      );

      final stream = grpcService.scanPorts(request);

      await for (final response in stream) {
        if (!mounted) break;
        setState(() {
          if (response.open) {
            _scanResults.add(response);
          }
          _progress = response.progress;
        });

        if (response.finished) {
          setState(() => _isScanning = false);
          break;
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Port scan failed: $e',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppTheme.errorRose,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Input Section
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Port Scanner',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Gap(12),
                TextField(
                  controller: _hostController,
                  decoration: InputDecoration(
                    hintText: 'Target hostname or IP',
                    prefixIcon: const Icon(Icons.dns, color: AppTheme.primaryIndigo),
                    filled: true,
                    fillColor: AppTheme.glassLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.glassBorder),
                    ),
                  ),
                  enabled: !_isScanning,
                ),
                const Gap(12),
                Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Common Ports'),
                      selected: _scanMode == 'common',
                      onSelected: _isScanning ? null : (selected) {
                        if (selected) setState(() => _scanMode = 'common');
                      },
                      selectedColor: AppTheme.primaryIndigo,
                      labelStyle: TextStyle(
                        color: _scanMode == 'common' ? Colors.white : AppTheme.textSecondary,
                      ),
                    ),
                    const Gap(8),
                    ChoiceChip(
                      label: const Text('Port Range'),
                      selected: _scanMode == 'range',
                      onSelected: _isScanning ? null : (selected) {
                        if (selected) setState(() => _scanMode = 'range');
                      },
                      selectedColor: AppTheme.primaryIndigo,
                      labelStyle: TextStyle(
                        color: _scanMode == 'range' ? Colors.white : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (_scanMode == 'range') ...[
                  const Gap(12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _startPortController,
                          decoration: InputDecoration(
                            labelText: 'Start Port',
                            filled: true,
                            fillColor: AppTheme.glassLight,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppTheme.glassBorder),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          enabled: !_isScanning,
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: TextField(
                          controller: _endPortController,
                          decoration: InputDecoration(
                            labelText: 'End Port',
                            filled: true,
                            fillColor: AppTheme.glassLight,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppTheme.glassBorder),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          enabled: !_isScanning,
                        ),
                      ),
                    ],
                  ),
                ],
                const Gap(12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isScanning ? null : _startScan,
                    icon: Icon(_isScanning ? Icons.stop : Icons.search),
                    label: Text(_isScanning ? 'Scanning... $_progress%' : 'Start Scan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryIndigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                if (_isScanning) ...[
                  const Gap(12),
                  LinearProgressIndicator(
                    value: _progress / 100,
                    backgroundColor: AppTheme.glassLight,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryIndigo),
                  ),
                ],
              ],
            ),
          ),
          const Gap(24),

          // Results
          if (_scanResults.isNotEmpty) ...[
            Text(
              'Open Ports (${_scanResults.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Gap(12),
            GlassCard(
              padding: const EdgeInsets.all(0),
              child: Column(
                children: [
                  for (int i = 0; i < _scanResults.length; i++) ...[
                    ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.successGreen.withValues(alpha: 0.2),
                        ),
                        child: const Icon(
                          Icons.lock_open,
                          color: AppTheme.successGreen,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        'Port ${_scanResults[i].port}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        _scanResults[i].service.isNotEmpty
                            ? _scanResults[i].service
                            : 'Unknown service',
                        style: const TextStyle(color: AppTheme.textSecondary),
                      ),
                      trailing: const Icon(
                        Icons.check_circle,
                        color: AppTheme.successGreen,
                      ),
                    ),
                    if (i < _scanResults.length - 1)
                      const Divider(color: AppTheme.glassBorder, height: 1),
                  ],
                ],
              ),
            ),
          ] else if (!_isScanning) ...[
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search,
                    size: 64,
                    color: AppTheme.textSecondary.withValues(alpha: 0.5),
                  ),
                  const Gap(16),
                  Text(
                    'No scan results yet',
                    style: TextStyle(
                      color: AppTheme.textSecondary.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ==================== DNS Lookup Tab ====================

class _DNSLookupTab extends ConsumerStatefulWidget {
  const _DNSLookupTab();

  @override
  ConsumerState<_DNSLookupTab> createState() => _DNSLookupTabState();
}

class _DNSLookupTabState extends ConsumerState<_DNSLookupTab> {
  final _hostnameController = TextEditingController();
  String _recordType = 'A';
  bool _isLookingUp = false;
  DNSResponse? _result;

  @override
  void dispose() {
    _hostnameController.dispose();
    super.dispose();
  }

  Future<void> _performLookup() async {
    if (_hostnameController.text.isEmpty) return;

    setState(() {
      _isLookingUp = true;
      _result = null;
    });

    final grpcService = ref.read(grpcServiceProvider);

    try {
      final request = DNSRequest(
        hostname: _hostnameController.text.trim(),
        recordType: _recordType,
      );

      final response = await grpcService.dnsLookup(request);

      if (mounted) {
        setState(() {
          _result = response;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'DNS lookup failed: $e',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppTheme.errorRose,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLookingUp = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Input Section
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DNS Lookup',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Gap(12),
                TextField(
                  controller: _hostnameController,
                  decoration: InputDecoration(
                    hintText: 'Enter hostname (e.g., google.com)',
                    prefixIcon: const Icon(Icons.language, color: AppTheme.primaryIndigo),
                    filled: true,
                    fillColor: AppTheme.glassLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.glassBorder),
                    ),
                  ),
                  enabled: !_isLookingUp,
                ),
                const Gap(12),
                Wrap(
                  spacing: 8,
                  children: ['A', 'AAAA', 'MX', 'TXT', 'NS', 'CNAME'].map((type) {
                    return ChoiceChip(
                      label: Text(type),
                      selected: _recordType == type,
                      onSelected: _isLookingUp ? null : (selected) {
                        if (selected) setState(() => _recordType = type);
                      },
                      selectedColor: AppTheme.primaryIndigo,
                      labelStyle: TextStyle(
                        color: _recordType == type ? Colors.white : AppTheme.textSecondary,
                      ),
                    );
                  }).toList(),
                ),
                const Gap(12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLookingUp ? null : _performLookup,
                    icon: Icon(_isLookingUp ? Icons.hourglass_empty : Icons.search),
                    label: Text(_isLookingUp ? 'Looking up...' : 'Lookup'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryIndigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Gap(24),

          // Results
          if (_result != null) ...[
            if (_result!.success) ...[
              // Quick summary
              GlassCard(
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppTheme.successGreen, size: 32),
                    const Gap(16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Query successful',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.successGreen,
                            ),
                          ),
                          const Gap(4),
                          Text(
                            'Query time: ${_result!.queryTime.toStringAsFixed(2)}ms',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(16),

              // Records
              if (_result!.records.isNotEmpty) ...[
                Text(
                  'DNS Records',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Gap(12),
                GlassCard(
                  padding: const EdgeInsets.all(0),
                  child: Column(
                    children: [
                      for (int i = 0; i < _result!.records.length; i++) ...[
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryIndigo.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _result!.records[i].type,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryIndigo,
                              ),
                            ),
                          ),
                          title: Text(
                            _result!.records[i].value,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            'TTL: ${_result!.records[i].ttl}s${_result!.records[i].priority > 0 ? ' | Priority: ${_result!.records[i].priority}' : ''}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                        if (i < _result!.records.length - 1)
                          const Divider(color: AppTheme.glassBorder, height: 1),
                      ],
                    ],
                  ),
                ),
              ] else if (_result!.addresses.isNotEmpty) ...[
                Text(
                  'IP Addresses',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Gap(12),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final address in _result!.addresses)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.dns, color: AppTheme.primaryIndigo, size: 16),
                              const Gap(8),
                              Text(
                                address,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ] else ...[
              GlassCard(
                child: Row(
                  children: [
                    const Icon(Icons.error, color: AppTheme.errorRose, size: 32),
                    const Gap(16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Lookup failed',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.errorRose,
                            ),
                          ),
                          const Gap(4),
                          Text(
                            _result!.error,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

// ==================== Speed Test Tab ====================

class _SpeedTestTab extends ConsumerStatefulWidget {
  const _SpeedTestTab();

  @override
  ConsumerState<_SpeedTestTab> createState() => _SpeedTestTabState();
}

class _SpeedTestTabState extends ConsumerState<_SpeedTestTab> {
  bool _testDownload = true;
  bool _testUpload = true;
  int _duration = 10;
  bool _isTesting = false;
  double _progress = 0;
  double _downloadSpeed = 0;
  double _uploadSpeed = 0;
  double _latency = 0;
  String _server = '';
  String _currentPhase = '';
  final List<double> _downloadHistory = [];
  final List<double> _uploadHistory = [];
  String? _error;

  Future<void> _startSpeedTest() async {
    setState(() {
      _isTesting = true;
      _progress = 0;
      _downloadSpeed = 0;
      _uploadSpeed = 0;
      _latency = 0;
      _server = '';
      _currentPhase = '';
      _downloadHistory.clear();
      _uploadHistory.clear();
      _error = null;
    });

    final grpcService = ref.read(grpcServiceProvider);

    try {
      final request = SpeedTestRequest(
        testDownload: _testDownload,
        testUpload: _testUpload,
        duration: _duration,
      );

      final stream = grpcService.testNetworkSpeed(request);

      await for (final response in stream) {
        if (!mounted) break;
        setState(() {
          _currentPhase = response.phase;
          _progress = response.progress;
          _downloadSpeed = response.downloadSpeed;
          _uploadSpeed = response.uploadSpeed;
          _latency = response.latency;
          _server = response.server;

          if (response.downloadSpeed > 0) {
            _downloadHistory.add(response.downloadSpeed);
          }
          if (response.uploadSpeed > 0) {
            _uploadHistory.add(response.uploadSpeed);
          }
        });

        if (response.finished) {
          setState(() => _isTesting = false);
          if (response.error.isNotEmpty) {
            setState(() => _error = response.error);
          }
          break;
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTesting = false;
          _error = e.toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Speed test failed: $e',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppTheme.errorRose,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Input Section
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Network Speed Test',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Gap(12),
                // Test Type Selection
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test Type',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const Gap(8),
                    Row(
                      children: [
                        Expanded(
                          child: CheckboxListTile(
                            title: const Text('Download'),
                            value: _testDownload,
                            onChanged: _isTesting ? null : (value) {
                              setState(() => _testDownload = value ?? true);
                            },
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        Expanded(
                          child: CheckboxListTile(
                            title: const Text('Upload'),
                            value: _testUpload,
                            onChanged: _isTesting ? null : (value) {
                              setState(() => _testUpload = value ?? true);
                            },
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Gap(16),
                // Duration Selection
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Test Duration',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          const Gap(8),
                          Slider(
                            value: _duration.toDouble(),
                            min: 5,
                            max: 30,
                            divisions: 5,
                            label: '${_duration}s',
                            onChanged: _isTesting ? null : (value) {
                              setState(() => _duration = value.toInt());
                            },
                          ),
                        ],
                      ),
                    ),
                    const Gap(16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.glassLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${_duration}s',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryIndigo,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: (_isTesting || (!_testDownload && !_testUpload)) ? null : _startSpeedTest,
                    icon: Icon(_isTesting ? Icons.stop : Icons.play_arrow),
                    label: Text(_isTesting ? 'Testing...' : 'Start Test'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryIndigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Gap(24),

          // Progress Section
          if (_isTesting) ...[
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryIndigo),
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentPhase.isEmpty ? 'Initializing...' : _currentPhase,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const Gap(4),
                            Text(
                              '${_progress.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Gap(12),
                  LinearProgressIndicator(
                    value: _progress / 100,
                    backgroundColor: AppTheme.glassLight,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryIndigo),
                  ),
                ],
              ),
            ),
            const Gap(24),
          ],

          // Results Section
          if (!_isTesting && (_downloadSpeed > 0 || _uploadSpeed > 0)) ...[
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Results',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Gap(16),
                  // Speed Results Grid
                  if (_testDownload && _downloadSpeed > 0) ...[
                    Row(
                      children: [
                        Expanded(
                          child: _buildSpeedCard(
                            'Download',
                            '${_downloadSpeed.toStringAsFixed(2)}',
                            'Mbps',
                            AppTheme.primaryIndigo,
                            Icons.download,
                          ),
                        ),
                        if (_testUpload && _uploadSpeed > 0) ...[
                          const Gap(12),
                          Expanded(
                            child: _buildSpeedCard(
                              'Upload',
                              '${_uploadSpeed.toStringAsFixed(2)}',
                              'Mbps',
                              AppTheme.successGreen,
                              Icons.upload,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const Gap(16),
                  ] else if (_testUpload && _uploadSpeed > 0) ...[
                    _buildSpeedCard(
                      'Upload',
                      '${_uploadSpeed.toStringAsFixed(2)}',
                      'Mbps',
                      AppTheme.successGreen,
                      Icons.upload,
                    ),
                    const Gap(16),
                  ],

                  // Server & Latency Info
                  if (_latency > 0) ...[
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Latency',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const Gap(4),
                              Text(
                                '${_latency.toStringAsFixed(1)}ms',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.secondaryTeal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_server.isNotEmpty)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Server',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                const Gap(4),
                                Text(
                                  _server,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const Gap(24),
          ],

          // Speed History Chart
          if (_downloadHistory.isNotEmpty || _uploadHistory.isNotEmpty) ...[
            Text(
              'Speed History',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Gap(12),
            GlassCard(
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: 280,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              getDrawingHorizontalLine: (value) => FlLine(
                                color: AppTheme.glassBorder,
                                strokeWidth: 1,
                              ),
                            ),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  getTitlesWidget: (value, meta) => Text(
                                    '${value.toInt()}',
                                    style: const TextStyle(
                                      fontSize: 9,
                                      color: AppTheme.textTertiary,
                                    ),
                                  ),
                                ),
                                axisNameWidget: const Text(
                                  'Mbps',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.textSecondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                axisNameSize: 12,
                              ),
                              bottomTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            minY: 0,
                            clipData: FlClipData.all(),
                            lineTouchData: LineTouchData(
                              touchTooltipData: LineTouchTooltipData(
                                maxContentWidth: 120,
                                tooltipPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                getTooltipItems: (List<LineBarSpot> touchedSpots) {
                                  return touchedSpots.map((LineBarSpot touchedSpot) {
                                    return LineTooltipItem(
                                      '${touchedSpot.y.toStringAsFixed(2)} Mbps',
                                      const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    );
                                  }).toList();
                                },
                              ),
                              handleBuiltInTouches: true,
                            ),
                            lineBarsData: [
                              if (_downloadHistory.isNotEmpty)
                                LineChartBarData(
                                  spots: _downloadHistory
                                      .asMap()
                                      .entries
                                      .map((e) => FlSpot(e.key.toDouble(), e.value))
                                      .toList(),
                                  isCurved: true,
                                  color: AppTheme.primaryIndigo,
                                  barWidth: 3,
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter: (spot, percent, barData, index) =>
                                        FlDotCirclePainter(
                                      radius: 3,
                                      color: AppTheme.primaryIndigo,
                                      strokeWidth: 2,
                                      strokeColor: Colors.white,
                                    ),
                                  ),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: AppTheme.primaryIndigo.withValues(alpha: 0.2),
                                  ),
                                ),
                              if (_uploadHistory.isNotEmpty)
                                LineChartBarData(
                                  spots: _uploadHistory
                                      .asMap()
                                      .entries
                                      .map((e) => FlSpot(e.key.toDouble(), e.value))
                                      .toList(),
                                  isCurved: true,
                                  color: AppTheme.successGreen,
                                  barWidth: 3,
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter: (spot, percent, barData, index) =>
                                        FlDotCirclePainter(
                                      radius: 3,
                                      color: AppTheme.successGreen,
                                      strokeWidth: 2,
                                      strokeColor: Colors.white,
                                    ),
                                  ),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: AppTheme.successGreen.withValues(alpha: 0.2),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Divider(color: AppTheme.glassBorder),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        if (_downloadHistory.isNotEmpty) ...[
                          Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryIndigo,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const Gap(8),
                              const Text(
                                'Download',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (_uploadHistory.isNotEmpty) ...[
                          Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: AppTheme.successGreen,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const Gap(8),
                              const Text(
                                'Upload',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Gap(24),
          ],

          // Error Display
          if (_error != null) ...[
            GlassCard(
              child: Row(
                children: [
                  const Icon(Icons.error, color: AppTheme.errorRose, size: 32),
                  const Gap(16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Test Failed',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.errorRose,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          _error!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSpeedCard(String label, String value, String unit, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Gap(8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Gap(8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              fontSize: 12,
              color: color.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== WiFi Tab ====================

class _WiFiTab extends ConsumerStatefulWidget {
  const _WiFiTab();

  @override
  ConsumerState<_WiFiTab> createState() => _WiFiTabState();
}

class _WiFiTabState extends ConsumerState<_WiFiTab> {
  WifiInfo? _wifiInfo;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadWifiInfo();
  }

  Future<void> _loadWifiInfo() async {
    setState(() => _isLoading = true);

    final grpcService = ref.read(grpcServiceProvider);

    try {
      final response = await grpcService.getWifiInfo();
      if (mounted) {
        setState(() {
          _wifiInfo = response;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to load WiFi info: $e',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppTheme.errorRose,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Color _getSignalColor(int strength) {
    if (strength > -50) return AppTheme.successGreen;
    if (strength > -70) return AppTheme.warningAmber;
    return AppTheme.errorRose;
  }

  IconData _getSignalIcon(int quality) {
    if (quality > 75) return Icons.signal_wifi_4_bar;
    if (quality > 50) return Icons.network_wifi_3_bar;
    if (quality > 25) return Icons.network_wifi_2_bar;
    return Icons.network_wifi_1_bar;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryIndigo,
        ),
      );
    }

    if (_wifiInfo == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off,
              size: 64,
              color: AppTheme.textSecondary,
            ),
            const Gap(16),
            const Text(
              'No WiFi information available',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const Gap(24),
            ElevatedButton.icon(
              onPressed: _loadWifiInfo,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryIndigo,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadWifiInfo,
      color: AppTheme.primaryIndigo,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Current Connection
          if (_wifiInfo!.connected) ...[
            Text(
              'Current Connection',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Gap(12),
            GlassCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getSignalColor(_wifiInfo!.signalStrength).withValues(alpha: 0.2),
                        ),
                        child: Icon(
                          _getSignalIcon(_wifiInfo!.signalQuality),
                          color: _getSignalColor(_wifiInfo!.signalStrength),
                        ),
                      ),
                      const Gap(16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _wifiInfo!.ssid,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const Gap(4),
                            Text(
                              _wifiInfo!.security,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${_wifiInfo!.signalQuality}%',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _getSignalColor(_wifiInfo!.signalStrength),
                            ),
                          ),
                          Text(
                            '${_wifiInfo!.signalStrength} dBm',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Gap(16),
                  const Divider(color: AppTheme.glassBorder),
                  const Gap(16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoColumn('IP Address', _wifiInfo!.ipAddress),
                      _buildInfoColumn('Frequency', '${_wifiInfo!.frequency} GHz'),
                      _buildInfoColumn('Link Speed', '${_wifiInfo!.linkSpeed.toStringAsFixed(0)} Mbps'),
                    ],
                  ),
                ],
              ),
            ),
            const Gap(24),
          ] else ...[
            GlassCard(
              child: Row(
                children: [
                  const Icon(Icons.wifi_off, color: AppTheme.warningAmber, size: 32),
                  const Gap(16),
                  const Expanded(
                    child: Text(
                      'Not connected to WiFi',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(24),
          ],

          // Available Networks
          if (_wifiInfo!.availableNetworks.isNotEmpty) ...[
            Text(
              'Available Networks (${_wifiInfo!.availableNetworks.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Gap(12),
            GlassCard(
              padding: const EdgeInsets.all(0),
              child: Column(
                children: [
                  for (int i = 0; i < _wifiInfo!.availableNetworks.length; i++) ...[
                    ListTile(
                      leading: Icon(
                        _getSignalIcon(_wifiInfo!.availableNetworks[i].signalQuality),
                        color: _getSignalColor(_wifiInfo!.availableNetworks[i].signalStrength),
                      ),
                      title: Text(
                        _wifiInfo!.availableNetworks[i].ssid,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        '${_wifiInfo!.availableNetworks[i].security} • ${_wifiInfo!.availableNetworks[i].frequency} GHz',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${_wifiInfo!.availableNetworks[i].signalQuality}%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _getSignalColor(_wifiInfo!.availableNetworks[i].signalStrength),
                            ),
                          ),
                          Text(
                            '${_wifiInfo!.availableNetworks[i].signalStrength} dBm',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (i < _wifiInfo!.availableNetworks.length - 1)
                      const Divider(color: AppTheme.glassBorder, height: 1),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
        const Gap(4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

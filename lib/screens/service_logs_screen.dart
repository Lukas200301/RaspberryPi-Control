import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../providers/app_providers.dart';
import '../generated/pi_control.pb.dart';

class ServiceLogsScreen extends ConsumerStatefulWidget {
  final String serviceName;

  const ServiceLogsScreen({
    super.key,
    required this.serviceName,
  });

  @override
  ConsumerState<ServiceLogsScreen> createState() => _ServiceLogsScreenState();
}

class _ServiceLogsScreenState extends ConsumerState<ServiceLogsScreen> {
  final List<LogEntry> _logs = [];
  final ScrollController _scrollController = ScrollController();
  bool _autoScroll = true;
  String _filterLevel = 'all'; // all, error, warning, info
  StreamSubscription<LogEntry>? _logSubscription;
  bool _isConnected = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startLogStream();
  }

  @override
  void dispose() {
    _logSubscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startLogStream() {
    final grpcService = ref.read(grpcServiceProvider);

    _logSubscription = grpcService
        .streamLogs(
          service: widget.serviceName,
          tailLines: 50,
        )
        .listen(
          (log) {
            if (mounted) {
              setState(() {
                _logs.add(log);
                _isConnected = true;
                _errorMessage = null;
                // Keep last 500 logs
                if (_logs.length > 500) {
                  _logs.removeAt(0);
                }
              });
              if (_autoScroll) {
                _scrollToBottom();
              }
            }
          },
          onError: (error) {
            if (mounted) {
              setState(() {
                _errorMessage = error.toString();
              });
            }
          },
          onDone: () {
            if (mounted) {
              setState(() {
                _isConnected = false;
              });
            }
          },
          cancelOnError: false,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Service Logs'),
            Text(
              widget.serviceName,
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _autoScroll ? Icons.vertical_align_bottom : Icons.vertical_align_top,
              color: _autoScroll ? AppTheme.primaryIndigo : AppTheme.textSecondary,
            ),
            onPressed: () {
              setState(() {
                _autoScroll = !_autoScroll;
              });
              if (_autoScroll) {
                _scrollToBottom();
              }

              // Show feedback to user
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _autoScroll ? 'Auto-scroll enabled - new logs will scroll to bottom' : 'Auto-scroll disabled',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: _autoScroll ? AppTheme.successGreen : AppTheme.textSecondary,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            tooltip: _autoScroll ? 'Auto-scroll ON' : 'Auto-scroll OFF',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'all', Icons.list),
                  const Gap(8),
                  _buildFilterChip('Errors', 'error', Icons.error, AppTheme.errorRose),
                  const Gap(8),
                  _buildFilterChip('Warnings', 'warning', Icons.warning, AppTheme.warningAmber),
                  const Gap(8),
                  _buildFilterChip('Info', 'info', Icons.info, AppTheme.primaryIndigo),
                ],
              ),
            ),
          ),

          // Log Stream
          Expanded(
            child: _buildLogStream(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, IconData icon, [Color? color]) {
    final isSelected = _filterLevel == value;
    final chipColor = color ?? AppTheme.textSecondary;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? chipColor : AppTheme.textSecondary),
          const Gap(6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterLevel = value;
        });
      },
      backgroundColor: AppTheme.glassLight,
      selectedColor: chipColor.withValues(alpha: 0.3),
      checkmarkColor: chipColor,
      labelStyle: TextStyle(
        color: isSelected ? chipColor : AppTheme.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? chipColor : AppTheme.glassBorder,
      ),
    );
  }

  Widget _buildLogStream() {
    // Show error if connection failed
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppTheme.errorRose,
              ),
              const Gap(16),
              Text(
                'Error streaming logs',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Gap(8),
              Text(
                _errorMessage!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const Gap(16),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _errorMessage = null;
                    _logs.clear();
                  });
                  _startLogStream();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Show empty state (whether connected or not)
    if (_logs.isEmpty) {
      // If we're still trying to connect (never received anything)
      if (!_isConnected && _errorMessage == null) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppTheme.primaryIndigo),
              Gap(16),
              Text('Connecting to log stream...'),
            ],
          ),
        );
      }

      // Otherwise, we're connected but no logs yet (or logs were cleared)
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 64,
              color: AppTheme.textTertiary.withValues(alpha: 0.5),
            ),
            const Gap(16),
            Text(
              'No logs yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const Gap(8),
            const Text(
              'Waiting for log entries...',
              style: TextStyle(color: AppTheme.textTertiary),
            ),
          ],
        ),
      );
    }

    final filteredLogs = _filterLogs(_logs);

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredLogs.length,
      itemBuilder: (context, index) {
        return _buildLogEntry(filteredLogs[index]);
      },
    );
  }

  List<LogEntry> _filterLogs(List<LogEntry> logs) {
    if (_filterLevel == 'all') return logs;

    return logs.where((log) {
      final level = log.level.toLowerCase();
      switch (_filterLevel) {
        case 'error':
          return level.contains('err') || level.contains('crit') || level.contains('alert') || level.contains('emerg');
        case 'warning':
          return level.contains('warn');
        case 'info':
          return level.contains('info') || level.contains('notice') || level.contains('debug');
        default:
          return true;
      }
    }).toList();
  }

  Widget _buildLogEntry(LogEntry log) {
    final level = log.level.toLowerCase();
    Color levelColor;
    IconData levelIcon;

    if (level.contains('err') || level.contains('crit') || level.contains('alert') || level.contains('emerg')) {
      levelColor = AppTheme.errorRose;
      levelIcon = Icons.error;
    } else if (level.contains('warn')) {
      levelColor = AppTheme.warningAmber;
      levelIcon = Icons.warning;
    } else {
      levelColor = AppTheme.primaryIndigo;
      levelIcon = Icons.info;
    }

    final timestamp = DateTime.fromMillisecondsSinceEpoch(log.timestamp.toInt() * 1000);
    final timeStr = '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Level Indicator
            Icon(levelIcon, size: 16, color: levelColor),
            const Gap(12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time
                  Text(
                    timeStr,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textTertiary,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const Gap(4),
                  // Message
                  SelectableText(
                    log.message,
                    style: TextStyle(
                      fontSize: 13,
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
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
}

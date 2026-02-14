import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:fixnum/fixnum.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../services/docker_service.dart' as service;
import '../generated/pi_control.pb.dart';

class DockerScreen extends ConsumerWidget {
  const DockerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final containersAsync = ref.watch(service.containerListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Docker Manager'),
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(service.containerListProvider),
          ),
        ],
      ),
      body: containersAsync.when(
        data: (containers) => containers.isEmpty
            ? _buildEmptyState(context)
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: containers.length,
                itemBuilder: (context, index) {
                  return _buildContainerCard(context, ref, containers[index]);
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppTheme.errorRose),
              const Gap(16),
              Text(
                'Failed to load containers',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Gap(8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.view_in_ar,
            size: 64,
            color: AppTheme.textSecondary.withValues(alpha: 0.5),
          ),
          const Gap(16),
          Text(
            'No containers found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildContainerCard(BuildContext context, WidgetRef ref, ContainerInfo container) {
    final isRunning = container.state == 'running';
    final statusColor = isRunning ? AppTheme.successGreen : AppTheme.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          container.names.isNotEmpty ? container.names.first : container.id.substring(0, 12),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          container.image,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(context, container.state),
                ],
              ),
              const Gap(16),
              
              // Key Stats / Info
              Row(
                children: [
                  _buildInfoItem(context, 'ID', container.id.substring(0, 12)),
                  const Gap(16),
                  _buildInfoItem(context, 'Created', _formatDate(container.created)),
                ],
              ),
              if (container.ports.isNotEmpty) ...[
                const Gap(8),
                Text(
                  'Ports: ${container.ports.join(", ")}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'Courier',
                      ),
                ),
              ],
              
              const Divider(height: 24, color: AppTheme.glassBorder),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isRunning) ...[
                    TextButton.icon(
                      icon: const Icon(Icons.restart_alt, size: 18),
                      label: const Text('Restart'),
                      onPressed: () => _restartContainer(context, ref, container),
                      style: TextButton.styleFrom(foregroundColor: AppTheme.warningAmber),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.stop, size: 18),
                      label: const Text('Stop'),
                      onPressed: () => _stopContainer(context, ref, container),
                      style: TextButton.styleFrom(foregroundColor: AppTheme.errorRose),
                    ),
                  ] else ...[
                    TextButton.icon(
                      icon: const Icon(Icons.play_arrow, size: 18),
                      label: const Text('Start'),
                      onPressed: () => _startContainer(context, ref, container),
                      style: TextButton.styleFrom(foregroundColor: AppTheme.successGreen),
                    ),
                  ],
                  const Gap(8),
                  FilledButton.icon(
                    icon: const Icon(Icons.article, size: 18),
                    label: const Text('Logs'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DockerLogsScreen(container: container),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String state) {
    Color color;
    switch (state) {
      case 'running':
        color = AppTheme.successGreen;
        break;
      case 'exited':
        color = AppTheme.textSecondary;
        break;
      case 'paused':
        color = AppTheme.warningAmber;
        break;
      case 'restarting':
        color = Colors.blue;
        break;
      case 'dead':
        color = AppTheme.errorRose;
        break;
      default:
        color = AppTheme.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        state.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
                fontSize: 10,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  String _formatDate(Int64 timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp.toInt() * 1000);
    return DateFormat('MMM d, HH:mm').format(date);
  }

  Future<void> _startContainer(BuildContext context, WidgetRef ref, ContainerInfo container) async {
    try {
      final dockerService = ref.read(service.dockerServiceProvider);
      await dockerService.startContainer(container.id);
      ref.invalidate(service.containerListProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Started ${container.names.isNotEmpty ? container.names.first : "container"}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.errorRose,
          ),
        );
      }
    }
  }

  Future<void> _stopContainer(BuildContext context, WidgetRef ref, ContainerInfo container) async {
    try {
      final dockerService = ref.read(service.dockerServiceProvider);
      await dockerService.stopContainer(container.id);
      ref.invalidate(service.containerListProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Stopped ${container.names.isNotEmpty ? container.names.first : "container"}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.errorRose,
          ),
        );
      }
    }
  }

  Future<void> _restartContainer(BuildContext context, WidgetRef ref, ContainerInfo container) async {
    try {
      final dockerService = ref.read(service.dockerServiceProvider);
      await dockerService.restartContainer(container.id);
      ref.invalidate(service.containerListProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restarted ${container.names.isNotEmpty ? container.names.first : "container"}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.errorRose,
          ),
        );
      }
    }
  }
}

class DockerLogsScreen extends ConsumerStatefulWidget {
  final ContainerInfo container;

  const DockerLogsScreen({super.key, required this.container});

  @override
  ConsumerState<DockerLogsScreen> createState() => _DockerLogsScreenState();
}

class _DockerLogsScreenState extends ConsumerState<DockerLogsScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<LogEntry> _logs = [];
  bool _autoScroll = true;

  @override
  void initState() {
    super.initState();
    _startLogStream();
  }

  void _startLogStream() {
    final dockerService = ref.read(service.dockerServiceProvider);
    dockerService.getContainerLogs(widget.container.id, follow: true, tail: 100).listen(
      (entry) {
        if (mounted) {
          setState(() {
            _logs.add(entry);
            if (_autoScroll) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scrollController.hasClients) {
                  _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                }
              });
            }
          });
        }
      },
      onError: (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error streaming logs: $e'), backgroundColor: AppTheme.errorRose),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.container.names.first} Logs'),
        backgroundColor: Colors.black,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: Icon(_autoScroll ? Icons.vertical_align_bottom : Icons.vertical_align_center),
            onPressed: () {
              setState(() {
                _autoScroll = !_autoScroll;
              });
            },
            tooltip: 'Auto-scroll',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              setState(() {
                _logs.clear();
              });
            },
            tooltip: 'Clear logs',
          ),
        ],
      ),
      body: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(8),
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _logs.length,
          itemBuilder: (context, index) {
            final log = _logs[index];
            final color = log.level == 'error' ? AppTheme.errorRose : Colors.white;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                log.message,
                style: TextStyle(
                  color: color,
                  fontFamily: 'Courier',
                  fontSize: 12,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

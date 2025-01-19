import 'package:flutter/material.dart';
import 'ssh_service.dart';
import 'dart:async';

class StatsScreen extends StatefulWidget {
  final SSHService? sshService;

  const StatsScreen({
    super.key,
    required this.sshService,
  });

  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  String stats = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.sshService != null) {
      _fetchStats();
      _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
        _fetchStats();
      });
    }
  }

  void _fetchStats() async {
    if (widget.sshService != null) {
      final result = await widget.sshService!.getStats();
      setState(() {
        stats = result;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Text(stats),
        ],
      ),
    );
  }
}
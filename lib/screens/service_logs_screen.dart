import 'package:flutter/material.dart';
import 'journal_screen.dart';

/// The journal of one systemd service
class ServiceLogsScreen extends StatelessWidget {
  final String serviceName;

  const ServiceLogsScreen({super.key, required this.serviceName});

  @override
  Widget build(BuildContext context) => JournalScreen(service: serviceName);
}

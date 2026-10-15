import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import '../docker_screen.dart';
import '../logs_screen.dart';
import '../network_connections_screen.dart';
import '../network_tools_screen.dart';
import '../packages_screen.dart';
import '../pm2_screen.dart';
import '../processes_screen.dart';
import '../services_screen.dart';
import '../stats_screen.dart';
import '../system/cron_screen.dart';
import '../system/firewall_screen.dart';
import '../system/hardware_screen.dart';
import '../system/users_screen.dart';

enum ToolCategory {
  monitoring('Monitoring', Icons.monitor_heart_outlined),
  system('System', Icons.settings_suggest_outlined),
  apps('Apps & containers', Icons.apps_outlined),
  network('Network', Icons.lan_outlined);

  final String label;
  final IconData icon;

  const ToolCategory(this.label, this.icon);
}

/// A screen reachable from the Tools tab
class ToolDef {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final ToolCategory category;
  final Color color;
  final WidgetBuilder builder;

  /// Extra words the search matches
  final List<String> keywords;

  const ToolDef({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    required this.color,
    required this.builder,
    this.keywords = const [],
  });

  bool matches(String query) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return true;
    return title.toLowerCase().contains(q) ||
        description.toLowerCase().contains(q) ||
        category.label.toLowerCase().contains(q) ||
        keywords.any((k) => k.contains(q));
  }

  void open(BuildContext context) =>
      Navigator.push(context, MaterialPageRoute(builder: builder));
}

final List<ToolDef> allTools = [
  ToolDef(
    id: 'stats',
    title: 'System stats',
    description: 'Live CPU, memory, temperature, disk and network charts',
    icon: Icons.monitor_heart_outlined,
    category: ToolCategory.monitoring,
    color: const Color(0xFF6366F1),
    keywords: ['cpu', 'ram', 'memory', 'temperature', 'graph', 'chart'],
    builder: (_) => const StatsScreen(),
  ),
  ToolDef(
    id: 'processes',
    title: 'Processes',
    description: 'Running processes as list or tree; kill, pause and resume',
    icon: Icons.account_tree_outlined,
    category: ToolCategory.monitoring,
    color: const Color(0xFFF43F5E),
    keywords: ['top', 'htop', 'kill', 'pid', 'task'],
    builder: (_) => const ProcessesScreen(),
  ),
  ToolDef(
    id: 'logs',
    title: 'System logs',
    description: 'Live journal with level filters and search',
    icon: Icons.receipt_long_outlined,
    category: ToolCategory.monitoring,
    color: const Color(0xFF8B5CF6),
    keywords: ['journal', 'journalctl', 'syslog'],
    builder: (_) => const LogsScreen(),
  ),
  ToolDef(
    id: 'services',
    title: 'Services',
    description: 'Start, stop, restart and enable systemd services',
    icon: Icons.settings_applications_outlined,
    category: ToolCategory.system,
    color: const Color(0xFF14B8A6),
    keywords: ['systemd', 'systemctl', 'daemon', 'unit'],
    builder: (_) => const ServicesScreen(),
  ),
  ToolDef(
    id: 'packages',
    title: 'Packages & updates',
    description: 'System updates, installed software and search',
    icon: Icons.inventory_2_outlined,
    category: ToolCategory.system,
    color: const Color(0xFFEC4899),
    keywords: ['apt', 'install', 'dpkg', 'software', 'update', 'upgrade', 'security'],
    builder: (_) => const PackagesScreen(),
  ),
  ToolDef(
    id: 'cron',
    title: 'Cron jobs',
    description: 'Scheduled tasks: add, edit, pause and run now',
    icon: Icons.schedule,
    category: ToolCategory.system,
    color: const Color(0xFF8B5CF6),
    keywords: ['crontab', 'schedule', 'timer', 'task', 'job', 'reboot'],
    builder: (_) => const CronScreen(),
  ),
  ToolDef(
    id: 'users',
    title: 'Users & groups',
    description: 'Accounts, passwords, sudo rights and groups',
    icon: Icons.manage_accounts_outlined,
    category: ToolCategory.system,
    color: const Color(0xFF0EA5E9),
    keywords: ['user', 'account', 'password', 'sudo', 'group', 'passwd'],
    builder: (_) => const UsersScreen(),
  ),
  ToolDef(
    id: 'hardware',
    title: 'Hardware & GPIO',
    description: 'Model, throttling, voltages, clocks and the 40-pin header',
    icon: Icons.developer_board,
    category: ToolCategory.system,
    color: const Color(0xFFC51A4A),
    keywords: ['gpio', 'pin', 'vcgencmd', 'voltage', 'throttle', 'usb', 'serial', 'model'],
    builder: (_) => const HardwareScreen(),
  ),
  ToolDef(
    id: 'docker',
    title: 'Docker',
    description: 'Containers, compose projects, images, logs and cleanup',
    icon: Icons.view_in_ar_outlined,
    category: ToolCategory.apps,
    color: const Color(0xFF2496ED),
    keywords: ['container', 'compose', 'image', 'prune', 'volume'],
    builder: (_) => const DockerScreen(),
  ),
  ToolDef(
    id: 'pm2',
    title: 'PM2',
    description: 'Node.js process manager: apps, logs, modules, startup',
    icon: Icons.rocket_launch_outlined,
    category: ToolCategory.apps,
    color: const Color(0xFF84CC16),
    keywords: ['node', 'nodejs', 'javascript', 'ecosystem'],
    builder: (_) => const Pm2Screen(),
  ),
  ToolDef(
    id: 'network',
    title: 'Network tools',
    description: 'Ping, port scan, DNS lookup, traceroute, speed test, Wi-Fi',
    icon: Icons.network_check,
    category: ToolCategory.network,
    color: const Color(0xFF06B6D4),
    keywords: ['ping', 'dns', 'port', 'wifi', 'speed', 'traceroute'],
    builder: (_) => const NetworkToolsScreen(),
  ),
  ToolDef(
    id: 'firewall',
    title: 'Firewall',
    description: 'ufw rules, defaults and logging',
    icon: Icons.shield_outlined,
    category: ToolCategory.network,
    color: const Color(0xFFF97316),
    keywords: ['ufw', 'iptables', 'port', 'block', 'allow', 'security'],
    builder: (_) => const FirewallScreen(),
  ),
  ToolDef(
    id: 'connections',
    title: 'Network connections',
    description: 'Open sockets and listening ports',
    icon: Icons.cable,
    category: ToolCategory.network,
    color: const Color(0xFF10B981),
    keywords: ['socket', 'netstat', 'ss', 'listen', 'tcp', 'udp'],
    builder: (_) => const NetworkConnectionsScreen(),
  ),
];

ToolDef? toolById(String id) {
  // "System updates" is now a tab of Packages
  if (id == 'updates') id = 'packages';
  for (final t in allTools) {
    if (t.id == id) return t;
  }
  return null;
}

/// Tools pinned to the top of the Tools tab and the dashboard
final pinnedToolsProvider = NotifierProvider<PinnedToolsNotifier, List<String>>(
  PinnedToolsNotifier.new,
);

class PinnedToolsNotifier extends Notifier<List<String>> {
  static const _key = 'pinned_tools';
  final _storage = GetStorage();

  @override
  List<String> build() {
    final saved = _storage.read(_key);
    // "updates" merged into "packages"; keep each pin once
    if (saved is List) return {for (final id in saved.whereType<String>()) id == 'updates' ? 'packages' : id}.toList();
    return const ['stats', 'services', 'docker', 'pm2'];
  }

  bool isPinned(String id) => state.contains(id);

  void toggle(String id) {
    state = isPinned(id) ? [...state.where((t) => t != id)] : [...state, id];
    _storage.write(_key, state);
  }

  void reorder(int oldIndex, int newIndex) {
    final list = [...state];
    if (newIndex > oldIndex) newIndex--;
    list.insert(newIndex, list.removeAt(oldIndex));
    state = list;
    _storage.write(_key, state);
  }
}

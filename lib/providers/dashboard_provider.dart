import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';

/// The sections of the dashboard, in their default order
enum DashboardSection {
  vitals('Vitals', 'CPU, memory, temperature and disk gauges', Icons.speed),
  activity('Activity', 'Live CPU, memory and network charts', Icons.show_chart),
  apps('Apps', 'Docker and PM2 at a glance', Icons.apps),
  tools('Pinned tools', 'Shortcuts to your favorite tools', Icons.push_pin_outlined),
  processes('Top processes', 'What uses the most CPU right now', Icons.account_tree_outlined),
  storage('Storage', 'Partitions and disk activity', Icons.storage);

  final String label;
  final String description;
  final IconData icon;

  const DashboardSection(this.label, this.description, this.icon);
}

@immutable
class DashboardLayout {
  final List<DashboardSection> order;
  final Set<DashboardSection> hidden;

  const DashboardLayout(this.order, this.hidden);

  List<DashboardSection> get visible => order.where((s) => !hidden.contains(s)).toList();
}

final dashboardLayoutProvider = NotifierProvider<DashboardLayoutNotifier, DashboardLayout>(
  DashboardLayoutNotifier.new,
);

class DashboardLayoutNotifier extends Notifier<DashboardLayout> {
  static const _orderKey = 'dashboard_v2_order';
  static const _hiddenKey = 'dashboard_v2_hidden';
  final _storage = GetStorage();

  DashboardSection? _byName(Object? name) {
    for (final s in DashboardSection.values) {
      if (s.name == name) return s;
    }
    return null;
  }

  @override
  DashboardLayout build() {
    final savedOrder = (_storage.read<List<dynamic>>(_orderKey) ?? const [])
        .map(_byName)
        .whereType<DashboardSection>()
        .toList();
    // Sections added in newer versions go to the end
    final order = [
      ...savedOrder,
      ...DashboardSection.values.where((s) => !savedOrder.contains(s)),
    ];
    final hidden = (_storage.read<List<dynamic>>(_hiddenKey) ?? const [])
        .map(_byName)
        .whereType<DashboardSection>()
        .toSet();
    return DashboardLayout(order, hidden);
  }

  void _save(DashboardLayout layout) {
    state = layout;
    _storage.write(_orderKey, layout.order.map((s) => s.name).toList());
    _storage.write(_hiddenKey, layout.hidden.map((s) => s.name).toList());
  }

  void reorder(int oldIndex, int newIndex) {
    final order = [...state.order];
    if (newIndex > oldIndex) newIndex--;
    order.insert(newIndex, order.removeAt(oldIndex));
    _save(DashboardLayout(order, state.hidden));
  }

  /// For onReorderItem, which already adjusts [newIndex] for the removal
  void reorderItem(int oldIndex, int newIndex) {
    final order = [...state.order];
    order.insert(newIndex, order.removeAt(oldIndex));
    _save(DashboardLayout(order, state.hidden));
  }

  void setVisible(DashboardSection section, bool visible) {
    final hidden = {...state.hidden};
    visible ? hidden.remove(section) : hidden.add(section);
    _save(DashboardLayout(state.order, hidden));
  }

  void reset() => _save(const DashboardLayout(DashboardSection.values, {}));
}

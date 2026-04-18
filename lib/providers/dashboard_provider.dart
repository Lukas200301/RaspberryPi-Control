import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';

enum DashboardWidgetType {
  connectionInfo,
  systemVitals,
  diskUsage,
  quickActions,
}

extension DashboardWidgetTypeExtension on DashboardWidgetType {
  String get displayName {
    switch (this) {
      case DashboardWidgetType.connectionInfo:
        return 'Connection Info';
      case DashboardWidgetType.systemVitals:
        return 'System Vitals';
      case DashboardWidgetType.diskUsage:
        return 'Disk Usage';
      case DashboardWidgetType.quickActions:
        return 'Quick Actions';
    }
  }
}

class DashboardLayoutNotifier extends Notifier<List<DashboardWidgetType>> {
  /// Stores the FULL canonical order including hidden widgets.
  static const _fullOrderKey = 'dashboard_full_order';
  static const _hiddenKey = 'dashboard_hidden';
  final _storage = GetStorage();

  // ─── Internal helpers ────────────────────────────────────────────────────

  /// Returns the full ordered list **including hidden** widgets.
  List<DashboardWidgetType> _loadFullOrder() {
    final saved = _storage.read<List<dynamic>>(_fullOrderKey);
    if (saved != null) {
      final maxIndex = DashboardWidgetType.values.length - 1;
      final full = saved
          .whereType<int>()
          .where((i) => i >= 0 && i <= maxIndex) // skip removed enum values
          .map((i) => DashboardWidgetType.values[i])
          .toList();
      // Append any new enum values added after the user's last save
      for (final t in DashboardWidgetType.values) {
        if (!full.contains(t)) full.add(t);
      }
      return full;
    }
    return DashboardWidgetType.values.toList();
  }

  Set<DashboardWidgetType> _loadHidden() {
    final maxIndex = DashboardWidgetType.values.length - 1;
    final hidden = _storage.read<List<dynamic>>(_hiddenKey) ?? [];
    return hidden
        .whereType<int>()
        .where((i) => i >= 0 && i <= maxIndex)
        .map((i) => DashboardWidgetType.values[i])
        .toSet();
  }

  void _saveFullOrder(List<DashboardWidgetType> full) {
    _storage.write(_fullOrderKey, full.map((t) => t.index).toList());
  }

  void _saveHidden(Set<DashboardWidgetType> hidden) {
    _storage.write(_hiddenKey, hidden.map((t) => t.index).toList());
  }

  // ─── Visible state = full order filtered by hidden ───────────────────────

  @override
  List<DashboardWidgetType> build() {
    final full = _loadFullOrder();
    final hidden = _loadHidden();
    _saveFullOrder(full); // persist any newly added enum values
    return full.where((t) => !hidden.contains(t)).toList();
  }

  // ─── Reorder ─────────────────────────────────────────────────────────────

  /// The user dragged a visible widget. We must update both the visible state
  /// AND the underlying full order, keeping hidden widgets in their relative
  /// canonical positions between the visible neighbours they were next to.
  void reorder(int oldIndex, int newIndex) {
    final hidden = _loadHidden();
    final full = _loadFullOrder();

    // Update visible list
    final visible = state.toList();
    if (newIndex > oldIndex) newIndex--;
    final moved = visible.removeAt(oldIndex);
    visible.insert(newIndex, moved);

    // Reconstruct full order: walk through old full order, replacing each
    // visible slot with the next item from the new visible order.
    int vi = 0;
    final newFull = full.map((t) {
      if (hidden.contains(t)) return t; // keep hidden in place
      return visible[vi++]; // replace visible slot in new order
    }).toList();

    state = visible;
    _saveFullOrder(newFull);
  }

  // ─── Toggle visibility ────────────────────────────────────────────────────

  void toggleWidget(DashboardWidgetType type) {
    final hidden = _loadHidden();
    final full = _loadFullOrder();

    if (state.contains(type)) {
      // Hide it — remove from visible but preserve full order
      hidden.add(type);
      state = full.where((t) => !hidden.contains(t)).toList();
    } else {
      // Show it again — canonical position restored from full order
      hidden.remove(type);
      state = full.where((t) => !hidden.contains(t)).toList();
    }

    _saveHidden(hidden);
    // full order unchanged by toggling — no need to resave
  }

  bool isVisible(DashboardWidgetType type) => state.contains(type);
}

final dashboardLayoutProvider =
    NotifierProvider<DashboardLayoutNotifier, List<DashboardWidgetType>>(
      DashboardLayoutNotifier.new,
    );

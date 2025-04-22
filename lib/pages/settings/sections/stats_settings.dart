import 'package:flutter/material.dart';
import '../models/dashboard_widget_info.dart';
import '../utils/settings_utils.dart';

class StatsSettings extends StatelessWidget {
  final List<DashboardWidgetInfo> dashboardWidgets;
  final Function(int, int) onReorder;
  final Function(DashboardWidgetInfo, bool) onVisibilityChanged;
  final Function() resetDashboardWidgets;

  const StatsSettings({
    Key? key,
    required this.dashboardWidgets,
    required this.onReorder,
    required this.onVisibilityChanged,
    required this.resetDashboardWidgets,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsUtils.buildSectionHeader(context, 'Stats Settings'),
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Stats Dashboard',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Drag to reorder. Toggle switches to show/hide widgets.',
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                SizedBox(
                  height: 300, 
                  child: ReorderableListView.builder(
                    shrinkWrap: true,
                    itemCount: dashboardWidgets.length,
                    itemBuilder: (context, index) {
                      final widget = dashboardWidgets[index];
                      return Card(
                        key: Key(widget.id),
                        elevation: 1, 
                        margin: const EdgeInsets.only(bottom: 4), 
                        child: ListTile(
                          dense: true, 
                          leading: Icon(widget.icon, size: 20), 
                          title: Text(widget.name),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: widget.visible,
                                onChanged: (value) {
                                  onVisibilityChanged(widget, value);
                                },
                              ),
                              const Icon(Icons.drag_handle, size: 18),
                            ],
                          ),
                        ),
                      );
                    },
                    onReorder: onReorder,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                OutlinedButton.icon(
                  onPressed: resetDashboardWidgets,
                  icon: const Icon(Icons.restore, size: 16), 
                  label: const Text('Reset to Default'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(36), 
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

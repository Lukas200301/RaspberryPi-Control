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
                    Row(
                      children: [
                        const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Use the drag handles to reorder widgets. Toggle switches to show/hide.',
                            style: TextStyle(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  height: 320,
                  child: ReorderableListView.builder(
                    buildDefaultDragHandles: false, 
                    padding: const EdgeInsets.all(8),
                    itemCount: dashboardWidgets.length,
                    onReorder: onReorder,
                    proxyDecorator: (child, index, animation) {
                      return Material(
                        elevation: 4,
                        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(10),
                        child: child,
                      );
                    },
                    itemBuilder: (context, index) {
                      final widget = dashboardWidgets[index];
                      return Card(
                        key: Key(widget.id),
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 8),
                        color: Theme.of(context).colorScheme.surface,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          child: Row(
                            children: [
                              ReorderableDragStartListener(
                                index: index,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.drag_handle,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                ),
                              ),
                              
                              Icon(widget.icon, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  widget.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              
                              Container(
                                height: 40,
                                alignment: Alignment.centerRight,
                                child: Switch(
                                  value: widget.visible,
                                  onChanged: (value) => onVisibilityChanged(widget, value),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 16),
                
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: resetDashboardWidgets,
                    icon: const Icon(Icons.restore, size: 16), 
                    label: const Text(
                      'Reset to Default',
                      overflow: TextOverflow.visible,
                      softWrap: false,
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(36),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../core/widgets/glass_app_bar.dart';
import '../../../core/widgets/glass_bottom_nav.dart';
import '../../../core/services/ssh_service_controller.dart';

// Feature pages
import '../../dashboard/views/dashboard_view.dart';
import '../../../pages/terminal/terminal.dart';
import '../../../pages/connection/connection.dart';
import '../../file_explorer/views/file_explorer_view.dart';
import '../../settings/views/settings_view.dart';

/// Home View - Main app screen with bottom navigation
class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sshController = Get.find<SSHServiceController>();

    return Obx(() {
      final theme = Theme.of(context);

      return Scaffold(
        extendBody: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: GlassAppBar(
          title: controller.currentPageTitle,
          showConnectionStatus: true,
          isConnected: sshController.isConnected,
          onConnectionTap: () {
            // Navigate to connections page
            controller.goToConnections();
          },
        ),
        body: Container(
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark
                ? const Color(0xFF000000) // AMOLED Black
                : const Color(0xFFF8f9fa), // Light mode unchanged
          ),
          child: SafeArea(
            bottom: false,
            child: IndexedStack(
              index: controller.currentIndex.value,
              children: [
                // Dashboard (Stats)
                _buildPage(
                  0,
                  const DashboardView(),
                ),

                // Terminal
                _buildPage(
                  1,
                  sshController.service != null
                      ? Terminal(
                          sshService: sshController.service,
                          commandController: TextEditingController(),
                          commandOutput: '',
                          sendCommand: () {},
                        )
                      : const Center(
                          child: Text('Please connect to a Raspberry Pi'),
                        ),
                ),

                // Connections
                _buildPage(
                  2,
                  Connection(
                    setSSHService: (service) {
                      if (service != null) {
                        sshController.connect(
                          name: service.name,
                          host: service.host,
                          port: service.port,
                          username: service.username,
                          password: service.password,
                        );
                      } else {
                        sshController.disconnect();
                      }
                    },
                    connectionStatus: sshController.connectionStatus,
                  ),
                ),

                // Files
                _buildPage(
                  3,
                  sshController.service != null
                      ? const FileExplorerView()
                      : const Center(
                          child: Text('Please connect to a Raspberry Pi'),
                        ),
                ),

                // Settings - New Glass Design (v3.0)
                _buildPage(
                  4,
                  const SettingsView(),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: GlassBottomNav(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changePage,
          isConnected: sshController.isConnected,
        ),
      );
    });
  }

  Widget _buildPage(int index, Widget child) {
    // Keep page state with PageStorage
    return KeyedSubtree(
      key: PageStorageKey('page_$index'),
      child: child,
    );
  }
}

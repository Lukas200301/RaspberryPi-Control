import 'package:get/get.dart';
import '../services/storage_service.dart';
import '../services/background_service.dart';
import '../services/ssh_service_controller.dart';
import '../theme/theme_controller.dart';
import '../../features/settings/controllers/settings_controller.dart';
import '../../features/dashboard/controllers/dashboard_controller.dart';
import '../../features/dashboard/services/widget_customization_service.dart';
import '../../controllers/stats_controller.dart';

/// Initial Binding - Global dependencies
/// These services persist throughout the app lifecycle
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // StorageService is already initialized in main.dart before the app starts
    // Just verify it exists
    if (!Get.isRegistered<StorageService>()) {
      throw Exception('StorageService must be initialized in main() before InitialBinding');
    }

    // Initialize BackgroundService (Android only)
    Get.putAsync(() => BackgroundService().init(), permanent: true);

    // SSH Service Controller (manages connections)
    Get.put(SSHServiceController(), permanent: true);

    // Theme Controller (manages app theme)
    Get.put(ThemeController(), permanent: true);

    // Settings Controller (manages all app settings)
    Get.put(SettingsController(), permanent: true);

    // Stats Controller (singleton for monitoring - compatible with old implementation)
    Get.put(StatsController.instance, permanent: true);

    // Dashboard Controller (manages dashboard stats and widgets)
    Get.put(DashboardController(), permanent: true);

    // Widget Customization Service - will be initialized on first use
    // DO NOT call loadConfiguration() here - it will be called in onInit()
    Get.lazyPut(() => WidgetCustomizationService(), fenix: true);
  }
}

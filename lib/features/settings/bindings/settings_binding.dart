import 'package:get/get.dart';
import '../controllers/settings_controller.dart';

/// Settings Binding - Dependency injection for Settings feature
class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    // Lazy load SettingsController
    Get.lazyPut<SettingsController>(
      () => SettingsController(),
    );
  }
}

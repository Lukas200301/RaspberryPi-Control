import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../file_explorer/controllers/file_explorer_controller.dart';
import '../../../core/services/ssh_service_controller.dart';

/// Home Binding - Dependencies for home screen
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Home controller (manages navigation)
    Get.lazyPut(() => HomeController());

    // File Explorer controller - will be created when Files tab is accessed
    Get.lazyPut(() {
      try {
        final sshController = Get.find<SSHServiceController>();
        return FileExplorerController(sshService: sshController.service);
      } catch (e) {
        print('Error creating FileExplorerController: $e');
        return FileExplorerController(sshService: null);
      }
    }, fenix: true);

    // Other feature controllers will be lazy-loaded when needed
  }
}

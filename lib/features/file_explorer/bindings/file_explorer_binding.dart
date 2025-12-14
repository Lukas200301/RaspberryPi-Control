import 'package:get/get.dart';
import '../controllers/file_explorer_controller.dart';
import '../../../services/ssh_service.dart';

/// File Explorer Binding
class FileExplorerBinding extends Bindings {
  @override
  void dependencies() {
    // Get SSH service if available
    final sshService = Get.isRegistered<SSHService>()
        ? Get.find<SSHService>()
        : null;

    Get.lazyPut<FileExplorerController>(
      () => FileExplorerController(sshService: sshService),
    );
  }
}

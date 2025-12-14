import 'package:get/get.dart';
import '../../../core/services/ssh_service_controller.dart';

/// Home Controller - Manages navigation and main app state
class HomeController extends GetxController {
  final SSHServiceController _sshController = Get.find();

  // Current page index (0=Dashboard, 1=Terminal, 2=Connections, 3=Files, 4=Settings)
  final RxInt currentIndex = 2.obs; // Start at Connections

  // Page titles
  final List<String> pageTitles = [
    'Dashboard',
    'Terminal',
    'Connections',
    'File Explorer',
    'Settings',
  ];

  // Getters
  String get currentPageTitle => pageTitles[currentIndex.value];
  bool get isConnected => _sshController.isConnected;

  @override
  void onInit() {
    super.onInit();

    // Listen to connection changes to enforce navigation restrictions
    // Use interval to check connection status periodically
    ever(currentIndex, (index) {
      if (!isConnected && !_canNavigateTo(index)) {
        // Force to connections page if disconnected and on restricted page
        currentIndex.value = 2;
      }
    });
  }

  /// Change current page
  void changePage(int index) {
    if (!_canNavigateTo(index)) {
      Get.snackbar(
        'Connection Required',
        'Please connect to a Raspberry Pi first',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      currentIndex.value = 2; // Force to connections
      return;
    }

    currentIndex.value = index;
  }

  /// Check if can navigate to specific page
  bool _canNavigateTo(int index) {
    // Dashboard (0), Terminal (1), Files (3) require connection
    // Connections (2) and Settings (4) are always available
    if (index == 2 || index == 4) return true;
    return _sshController.isConnected;
  }

  /// Navigate to specific page by name
  void navigateToPage(String pageName) {
    final index = pageTitles.indexWhere(
      (title) => title.toLowerCase() == pageName.toLowerCase(),
    );
    if (index != -1) {
      changePage(index);
    }
  }

  /// Quick navigation helpers
  void goToDashboard() => changePage(0);
  void goToTerminal() => changePage(1);
  void goToConnections() => changePage(2);
  void goToFiles() => changePage(3);
  void goToSettings() => changePage(4);
}

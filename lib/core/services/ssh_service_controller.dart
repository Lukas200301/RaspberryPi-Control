import 'package:get/get.dart';
import '../../services/ssh_service.dart';
import 'background_service.dart';

/// GetX Controller wrapper for existing SSHService
/// Provides reactive state management without rewriting SSH logic
class SSHServiceController extends GetxController {
  static SSHServiceController get to => Get.find();

  // Reactive SSH service instance
  final Rx<SSHService?> _service = Rx<SSHService?>(null);

  // Reactive connection state
  final RxBool _isConnected = false.obs;
  final RxString _connectionStatus = 'Disconnected'.obs;
  final RxBool _isReconnecting = false.obs;

  // Getters
  SSHService? get service => _service.value;
  bool get isConnected => _isConnected.value;
  String get connectionStatus => _connectionStatus.value;
  bool get isReconnecting => _isReconnecting.value;

  // Connection info
  String get connectionName => _service.value?.name ?? '';
  String get connectionHost => _service.value?.host ?? '';

  @override
  void onInit() {
    super.onInit();

    // Listen to service changes
    ever(_service, _onServiceChanged);
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }

  /// Called when SSH service changes
  void _onServiceChanged(SSHService? service) {
    if (service != null) {
      _isConnected.value = service.isConnected();
      _updateConnectionStatus();

      // Subscribe to service connection status
      service.connectionStatus.listen((connected) {
        _isConnected.value = connected;
        _updateConnectionStatus();

        if (!connected) {
          // Connection lost - force navigation to connections page
          _handleConnectionLost();
        }
      });
    } else {
      _isConnected.value = false;
      _connectionStatus.value = 'Disconnected';
    }
  }

  /// Update connection status string
  void _updateConnectionStatus() {
    if (_service.value != null && _isConnected.value) {
      _connectionStatus.value = 'Connected to ${_service.value!.name} (${_service.value!.host})';
    } else {
      _connectionStatus.value = 'Disconnected';
    }
  }

  /// Handle connection lost
  void _handleConnectionLost() {
    print('🔌 Connection lost - cleaning up');

    // Disable background service
    Get.find<BackgroundService>().disableBackground();

    // Update will notify all listeners
    update();
  }

  /// Connect with a new SSH service instance
  Future<void> connect({
    required String name,
    required String host,
    required int port,
    required String username,
    required String password,
  }) async {
    try {
      _isReconnecting.value = true;

      // Create new SSH service instance
      final newService = SSHService(
        name: name,
        host: host,
        port: port,
        username: username,
        password: password,
      );

      // Attempt connection
      await newService.connect();

      // Enable background service
      await Get.find<BackgroundService>().enableBackground();

      // Set the service (will trigger _onServiceChanged)
      _service.value = newService;
      _isConnected.value = true;
      _updateConnectionStatus();

      _isReconnecting.value = false;

      print('✅ Connected to $name ($host)');

      // Notify all listeners
      update();

    } catch (e) {
      _isReconnecting.value = false;
      _isConnected.value = false;
      _connectionStatus.value = 'Connection failed: $e';

      // Disable background service on failure
      await Get.find<BackgroundService>().disableBackground();

      print('❌ Connection failed: $e');
      rethrow;
    }
  }

  /// Reconnect with existing service
  Future<void> reconnect() async {
    if (_service.value != null) {
      try {
        _isReconnecting.value = true;
        await _service.value!.reconnect();
        _isConnected.value = true;
        _updateConnectionStatus();
        _isReconnecting.value = false;

        update();
      } catch (e) {
        _isReconnecting.value = false;
        print('❌ Reconnection failed: $e');
        rethrow;
      }
    }
  }

  /// Disconnect and cleanup
  Future<void> disconnect() async {
    if (_service.value != null) {
      print('🔌 Disconnecting from ${_service.value!.name}');

      _service.value!.disconnect();
      await Get.find<BackgroundService>().disableBackground();

      _service.value = null;
      _isConnected.value = false;
      _connectionStatus.value = 'Disconnected';

      update();
    }
  }

  /// Execute command on current connection
  Future<String> executeCommand(String command) async {
    if (_service.value == null) {
      throw Exception('Not connected to any server');
    }
    return await _service.value!.executeCommand(command);
  }

  /// Get detailed stats from server
  Future<Map<String, dynamic>> getDetailedStats() async {
    if (_service.value == null) {
      throw Exception('Not connected to any server');
    }
    return await _service.value!.getDetailedStats();
  }

  /// Start interactive shell
  Future<void> startShell() async {
    if (_service.value == null) {
      throw Exception('Not connected to any server');
    }
    await _service.value!.startShell();
  }

  /// Send to shell
  void sendToShell(String input) {
    if (_service.value != null) {
      _service.value!.sendToShell(input);
    }
  }

  /// Close shell
  void closeShell() {
    if (_service.value != null) {
      _service.value!.closeShell();
    }
  }

  /// Resize shell
  void resizeShell(int width, int height) {
    if (_service.value != null) {
      _service.value!.resizeShell(width, height);
    }
  }

  /// Get shell output stream
  Stream<String>? get shellOutput => _service.value?.shellOutput;

  /// Check if shell is active
  bool get hasActiveShell => _service.value?.shellOutput != null;
}

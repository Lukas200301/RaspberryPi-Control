class AppConstants {
  // Agent Configuration
  static const String agentVersion = '3.2.0';
  static const int agentPort = 50051;
  static const String agentInstallPath = '/opt/pi-control/agent';

  // SSH Configuration
  static const int defaultSSHPort = 22;
  static const Duration sshTimeout = Duration(seconds: 10);
  static const Duration reconnectDelay = Duration(seconds: 5);
  static const int maxReconnectAttempts = 3;

  // gRPC Configuration
  static const Duration grpcTimeout = Duration(seconds: 5);
  static const int statsStreamInterval = 500; // milliseconds

  // Storage Keys
  static const String storageKeyConnections = 'ssh_connections';
  static const String storageKeySettings = 'app_settings';

  // Asset Paths
  static const String agentBinaryArm6 = 'assets/bin/pi-agent-arm6';
  static const String agentBinaryArm7 = 'assets/bin/pi-agent-arm7';
  static const String agentBinaryArm64 = 'assets/bin/pi-agent-arm64';
  static const String appIcon = 'assets/icon/ic_launcher.png';
}

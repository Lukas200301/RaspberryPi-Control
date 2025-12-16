class AgentInfo {
  final String version;
  final bool isInstalled;
  final bool isRunning;
  final bool needsUpdate;

  AgentInfo({
    required this.version,
    required this.isInstalled,
    required this.isRunning,
    required this.needsUpdate,
  });

  factory AgentInfo.notInstalled() => AgentInfo(
        version: '',
        isInstalled: false,
        isRunning: false,
        needsUpdate: false,
      );

  factory AgentInfo.installed(String version, {bool isRunning = false}) =>
      AgentInfo(
        version: version,
        isInstalled: true,
        isRunning: isRunning,
        needsUpdate: false,
      );

  AgentInfo copyWith({
    String? version,
    bool? isInstalled,
    bool? isRunning,
    bool? needsUpdate,
  }) {
    return AgentInfo(
      version: version ?? this.version,
      isInstalled: isInstalled ?? this.isInstalled,
      isRunning: isRunning ?? this.isRunning,
      needsUpdate: needsUpdate ?? this.needsUpdate,
    );
  }
}

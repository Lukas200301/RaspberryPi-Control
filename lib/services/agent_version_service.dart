import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../models/ssh_connection.dart';

/// Service for checking and comparing agent versions
class AgentVersionService {
  // Current app version that expects this agent version
  // Temporarily set to 3.2.0 to test the update banner
  static const String requiredAgentVersion = '3.2.0';

  /// Get the app version from package info
  static Future<String> getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  /// Parse version string into comparable integers
  static List<int> _parseVersion(String version) {
    try {
      return version.split('.').map((e) => int.parse(e)).toList();
    } catch (e) {
      debugPrint('Error parsing version $version: $e');
      return [0, 0, 0];
    }
  }

  /// Compare two version strings
  /// Returns: -1 if v1 < v2, 0 if v1 == v2, 1 if v1 > v2
  static int compareVersions(String v1, String v2) {
    final parts1 = _parseVersion(v1);
    final parts2 = _parseVersion(v2);

    for (int i = 0; i < 3; i++) {
      final p1 = i < parts1.length ? parts1[i] : 0;
      final p2 = i < parts2.length ? parts2[i] : 0;

      if (p1 < p2) return -1;
      if (p1 > p2) return 1;
    }

    return 0;
  }

  /// Check if the agent version is compatible with the app
  static AgentVersionStatus checkVersion(String? agentVersion) {
    if (agentVersion == null || agentVersion.isEmpty) {
      return AgentVersionStatus.unknown;
    }

    final comparison = compareVersions(agentVersion, requiredAgentVersion);

    if (comparison == 0) {
      return AgentVersionStatus.compatible;
    } else if (comparison < 0) {
      return AgentVersionStatus.outdated;
    } else {
      return AgentVersionStatus.newer;
    }
  }

  /// Get a user-friendly message for the version status
  static String getVersionMessage(AgentVersionStatus status, String? agentVersion) {
    switch (status) {
      case AgentVersionStatus.compatible:
        return 'Agent version $agentVersion is compatible';
      case AgentVersionStatus.outdated:
        return 'Agent version $agentVersion is outdated. Please update to $requiredAgentVersion';
      case AgentVersionStatus.newer:
        return 'Agent version $agentVersion is newer than expected ($requiredAgentVersion)';
      case AgentVersionStatus.unknown:
        return 'Agent version unknown';
    }
  }

  /// Get the bundled agent asset path based on architecture
  static String getAgentAssetPath(String architecture) {
    switch (architecture.toLowerCase()) {
      case 'armv6':
      case 'armv6l':
        return 'assets/bin/pi-agent-arm6';
      case 'armv7':
      case 'armv7l':
        return 'assets/bin/pi-agent-arm7';
      case 'arm64':
      case 'aarch64':
        return 'assets/bin/pi-agent-arm64';
      default:
        return 'assets/bin/pi-agent-arm7'; // Default to armv7
    }
  }

  /// Get the agent filename for the target system
  static String getAgentFilename(String architecture) {
    switch (architecture.toLowerCase()) {
      case 'armv6':
      case 'armv6l':
        return 'pi-agent-arm6';
      case 'armv7':
      case 'armv7l':
        return 'pi-agent-arm7';
      case 'arm64':
      case 'aarch64':
        return 'pi-agent-arm64';
      default:
        return 'pi-agent-arm7';
    }
  }

  /// Generate installation command for SSH (after file is uploaded)
  /// Note: This is legacy code - AgentManager.installAgent() should be used instead
  static String getInstallCommand() {
    return '''
# Stop the agent if running
sudo pkill -f "/opt/pi-control/agent" || true

# Create directory if needed
sudo mkdir -p /opt/pi-control

# Move to /opt/pi-control
sudo mv /tmp/pi-control-agent /opt/pi-control/agent

# Make executable
sudo chmod +x /opt/pi-control/agent

# Start agent
sudo nohup /opt/pi-control/agent --host 0.0.0.0 --port 50051 > /opt/pi-control/agent.log 2>&1 &

echo "Agent updated to version $requiredAgentVersion"
''';
  }

  /// Check if we should show update notification
  static bool shouldShowUpdateNotification(SSHConnection connection) {
    if (connection.agentVersion == null) return false;
    
    final status = checkVersion(connection.agentVersion);
    return status == AgentVersionStatus.outdated;
  }
}

enum AgentVersionStatus {
  compatible,
  outdated,
  newer,
  unknown,
}

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:dartssh2/dartssh2.dart';
import '../models/agent_info.dart';
import '../constants/app_constants.dart';
import 'agent_version_service.dart';
import 'ssh_service.dart';

class AgentManager {
  final SSHService sshService;

  AgentManager(this.sshService);

  /// Check the agent version on the remote Pi
  Future<AgentInfo> checkAgentVersion() async {
    try {
      // Try to get version
      final result = await sshService.execute(
        '${AppConstants.agentInstallPath} --version 2>/dev/null || echo "NOT_INSTALLED"',
      );

      if (result.trim() == 'NOT_INSTALLED' || result.isEmpty) {
        return AgentInfo.notInstalled();
      }

      // Parse version from output like "Pi Control Agent v3.0.0"
      final versionMatch = RegExp(r'v(\d+\.\d+\.\d+)').firstMatch(result);
      if (versionMatch != null) {
        final version = versionMatch.group(1)!;
        final versionStatus = AgentVersionService.checkVersion(version);
        final needsUpdate = versionStatus == AgentVersionStatus.outdated;

        // Check if agent is running
        final isRunning = await _isAgentRunning();

        return AgentInfo(
          version: version,
          isInstalled: true,
          isRunning: isRunning,
          needsUpdate: needsUpdate,
        );
      }

      return AgentInfo.notInstalled();
    } catch (e) {
      debugPrint('Error checking agent version: $e');
      return AgentInfo.notInstalled();
    }
  }

  /// Check if the agent process is running
  Future<bool> _isAgentRunning() async {
    try {
      final result = await sshService.execute(
        // Anchored, so the shell running this command does not match itself
        'pgrep -f "^${AppConstants.agentInstallPath} " >/dev/null && echo RUNNING || echo NOT_RUNNING',
      );
      return !result.contains('NOT_RUNNING');
    } catch (e) {
      return false;
    }
  }

  /// Get the appropriate agent binary based on Pi architecture
  Future<String> _getAgentBinaryPath() async {
    try {
      final arch = await sshService.execute('uname -m');
      final archTrimmed = arch.trim();

      if (archTrimmed.contains('aarch64') || archTrimmed.contains('arm64')) {
        return AppConstants.agentBinaryArm64;
      } else if (archTrimmed.contains('armv7')) {
        return AppConstants.agentBinaryArm7;
      } else if (archTrimmed.contains('armv6')) {
        return AppConstants.agentBinaryArm6;
      }

      // Default to ARM64 for Pi 3/4/5
      return AppConstants.agentBinaryArm64;
    } catch (e) {
      debugPrint('Error detecting architecture: $e, defaulting to ARM64');
      return AppConstants.agentBinaryArm64;
    }
  }

  /// Install or update the agent on the Pi
  Future<void> installAgent({Function(String)? onProgress}) async {
    try {
      onProgress?.call('Detecting architecture...');
      final binaryPath = await _getAgentBinaryPath();

      onProgress?.call('Loading agent binary...');
      final binaryData = await rootBundle.load(binaryPath);
      final bytes = binaryData.buffer.asUint8List();

      onProgress?.call('Creating installation directory...');
      await sshService.execute('sudo mkdir -p /opt/pi-control');

      onProgress?.call('Stopping old agent if running...');
      await _stopAgent();

      onProgress?.call('Uploading agent binary...');
      final sftp = await sshService.getSftp();

      // Upload to temp location first (SFTP might not have permission for /opt)
      final tempPath = '/tmp/pi-control-agent';
      final remoteFile = await sftp.open(
        tempPath,
        mode:
            SftpFileOpenMode.create |
            SftpFileOpenMode.truncate |
            SftpFileOpenMode.write,
      );

      await remoteFile.write(_chunked(bytes, (percent) => onProgress?.call('Uploading agent binary… $percent%')));
      await remoteFile.close();

      onProgress?.call('Installing agent to system directory...');
      // Move to /opt with sudo and set permissions
      await sshService.execute(
        'sudo mv $tempPath ${AppConstants.agentInstallPath}',
      );
      await sshService.execute(
        'sudo chmod +x ${AppConstants.agentInstallPath}',
      );

      onProgress?.call('Verifying installation...');
      final version = await sshService.execute(
        '${AppConstants.agentInstallPath} --version',
      );
      debugPrint('Agent installed: $version');

      onProgress?.call('Starting agent...');
      await startAgent();

      onProgress?.call('Installation complete!');
    } catch (e) {
      debugPrint('Error installing agent: $e');
      onProgress?.call('Installation failed: $e');
      rethrow;
    }
  }

  /// Feeds [bytes] to SFTP in small pieces. SSH encryption runs on the UI
  /// isolate, so one 14 MB write froze the app; pausing between chunks lets
  /// frames render.
  static Stream<Uint8List> _chunked(Uint8List bytes, void Function(int percent) onPercent) async* {
    const chunk = 64 * 1024;
    var lastPercent = -1;
    for (var offset = 0; offset < bytes.length; offset += chunk) {
      final end = offset + chunk < bytes.length ? offset + chunk : bytes.length;
      yield Uint8List.sublistView(bytes, offset, end);
      final percent = end * 100 ~/ bytes.length;
      if (percent != lastPercent) {
        lastPercent = percent;
        onPercent(percent);
      }
      await Future<void>.delayed(Duration.zero);
    }
  }

  /// Starts the agent only when it is not running (e.g. after a reconnect)
  Future<void> ensureAgentRunning() async {
    if (await _isAgentRunning()) return;
    await startAgent();
  }

  Future<void> startAgent() async {
    try {
      // Kill existing agent if running
      await _stopAgent();

      // Ensure log directory exists and has proper permissions
      await sshService.execute('sudo touch /opt/pi-control/agent.log');
      await sshService.execute('sudo chmod 666 /opt/pi-control/agent.log');

      // Start agent with sudo (required for /opt/pi-control/)
      // Loopback only: the app reaches the agent through the SSH tunnel, and
      // the agent has no authentication of its own
      final command =
          'sudo nohup ${AppConstants.agentInstallPath} --host 127.0.0.1 --port ${AppConstants.agentPort} > /opt/pi-control/agent.log 2>&1 &';

      // Start agent in background
      await sshService.execute(command);

      // Wait for agent to start and bind to port
      await Future.delayed(const Duration(seconds: 3));

      // Verify it's running
      final isRunning = await _isAgentRunning();
      if (!isRunning) {
        throw Exception('Agent process not running');
      }

      // Verify it's listening on port
      final portCheck = await sshService.execute(
        'sudo netstat -tuln 2>/dev/null | grep ":50051 " || sudo ss -tuln 2>/dev/null | grep ":50051 " || echo "not_listening"',
      );

      if (portCheck.contains('not_listening')) {
        throw Exception('Agent not listening on port 50051');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Stop the agent on the Pi
  Future<void> _stopAgent() async {
    try {
      await sshService.execute(
        // Anchored: an unanchored pattern also matches (and kills) this command's own shell
        'sudo pkill -f "^${AppConstants.agentInstallPath} " || true',
      );
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      debugPrint('Error stopping agent: $e');
    }
  }

  /// Check if the current user is root or has sudo access
  Future<bool> checkSudoAccess() async {
    // Check if user is root
    final whoami = await sshService.execute('whoami');
    debugPrint('Checking sudo access for user: ${whoami.trim()}');

    if (whoami.trim() == 'root') {
      debugPrint('User is root - has sudo access');
      return true;
    }

    // Check if user can run sudo (try with groups command)
    final sudoTest = await sshService.execute(
      'groups | grep -E "sudo|wheel|admin" || echo "NO_SUDO"',
    );
    debugPrint('Sudo groups check result: $sudoTest');

    final hasSudo = !sudoTest.contains('NO_SUDO');
    debugPrint('User has sudo access: $hasSudo');
    return hasSudo;
  }

  /// Setup SSH tunnel for gRPC communication
  Future<int> setupTunnel() async {
    try {
      debugPrint('Setting up SSH tunnel...');
      final localPort = await sshService.forwardLocal(
        AppConstants.agentPort,
        '127.0.0.1',
        AppConstants.agentPort,
      );
      debugPrint('SSH tunnel established on port $localPort');
      return localPort;
    } catch (e) {
      debugPrint('Error setting up tunnel: $e');
      rethrow;
    }
  }
}

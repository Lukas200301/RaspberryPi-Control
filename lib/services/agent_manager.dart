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
        'pgrep -f "${AppConstants.agentInstallPath}" || echo "NOT_RUNNING"',
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
      await sshService.execute('mkdir -p /opt/pi-control');

      onProgress?.call('Stopping old agent if running...');
      await _stopAgent();

      onProgress?.call('Uploading agent binary...');
      final sftp = await sshService.getSftp();

      final remoteFile = await sftp.open(
        AppConstants.agentInstallPath,
        mode: SftpFileOpenMode.create |
            SftpFileOpenMode.truncate |
            SftpFileOpenMode.write,
      );

      await remoteFile.write(Stream.value(bytes));
      await remoteFile.close();

      onProgress?.call('Setting executable permissions...');
      await sshService.execute('chmod +x ${AppConstants.agentInstallPath}');

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

  /// Start the agent on the Pi
  Future<void> startAgent() async {
    try {
      // Kill existing agent if running
      await _stopAgent();

      // Start agent
      final command = 'nohup ${AppConstants.agentInstallPath} --port ${AppConstants.agentPort} > /opt/pi-control/agent.log 2>&1 &';

      // Start agent in background
      await sshService.execute(command);

      // Wait a bit for the agent to start
      await Future.delayed(const Duration(seconds: 2));

      // Verify it's running
      final isRunning = await _isAgentRunning();
      if (!isRunning) {
        throw Exception('Agent failed to start');
      }

      debugPrint('Agent started successfully');
    } catch (e) {
      debugPrint('Error starting agent: $e');
      rethrow;
    }
  }

  /// Stop the agent on the Pi
  Future<void> _stopAgent() async {
    try {
      await sshService.execute(
        'pkill -f "${AppConstants.agentInstallPath}" || true',
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

  /// Get the appropriate install path based on sudo availability
  Future<String> _getInstallPath(bool hasSudo) async {
    if (hasSudo) {
      return AppConstants.agentInstallPath;
    } else {
      // Use home directory for non-sudo users
      final home = await sshService.execute('echo \$HOME');
      return '${home.trim()}/pi-control/agent';
    }
  }

  /// Setup SSH tunnel for gRPC communication
  Future<int> setupTunnel() async {
    try {
      debugPrint('Setting up SSH tunnel...');
      final localPort = await sshService.forwardLocal(
        AppConstants.agentPort,
        'localhost',
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

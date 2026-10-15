import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import '../models/ssh_connection.dart';
import '../providers/app_providers.dart';

enum ConnectStep {
  ssh('Connecting over SSH'),
  permissions('Checking permissions'),
  agent('Checking the agent'),
  forwarding('Checking port forwarding'),
  start('Starting the agent'),
  tunnel('Opening a secure tunnel'),
  ready('Loading your Pi');

  final String label;

  const ConnectStep(this.label);
}

enum StepStatus { pending, running, done, skipped, failed }

/// A question the flow needs answered by the user before it can go on
class ConnectDecision {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;

  /// The user is asked for their password (sudo setup)
  final bool needsPassword;

  const ConnectDecision({
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.cancelLabel = 'Cancel',
    this.needsPassword = false,
  });
}

@immutable
class ConnectState {
  final Map<ConnectStep, StepStatus> steps;
  final Map<ConnectStep, String> details;
  final ConnectStep? current;
  final String? error;
  final bool finished;

  const ConnectState({
    required this.steps,
    this.details = const {},
    this.current,
    this.error,
    this.finished = false,
  });

  factory ConnectState.initial() => ConnectState(
    steps: {for (final s in ConnectStep.values) s: StepStatus.pending},
  );

  ConnectState copyWith({
    Map<ConnectStep, StepStatus>? steps,
    Map<ConnectStep, String>? details,
    ConnectStep? current,
    String? error,
    bool clearError = false,
    bool? finished,
  }) {
    return ConnectState(
      steps: steps ?? this.steps,
      details: details ?? this.details,
      current: current ?? this.current,
      error: clearError ? null : (error ?? this.error),
      finished: finished ?? this.finished,
    );
  }
}

class ConnectCancelled implements Exception {
  const ConnectCancelled();
}

/// Connects to a Pi end to end: SSH, sudo, agent install/update, port
/// forwarding, agent start, tunnel and gRPC. Decisions are delegated to
/// [decide], so any UI can drive it.
class ConnectFlow {
  final WidgetRef ref;
  final ValueNotifier<ConnectState> state = ValueNotifier(ConnectState.initial());

  /// Answers a decision. Returns null when declined, otherwise the entered
  /// text ('' when no input was requested).
  final Future<String?> Function(ConnectDecision decision) decide;

  ConnectFlow(this.ref, {required this.decide});

  void _set(ConnectStep step, StepStatus status, [String? detail]) {
    final s = state.value;
    state.value = s.copyWith(
      steps: {...s.steps, step: status},
      details: detail == null ? s.details : {...s.details, step: detail},
      current: step,
    );
  }

  void _detail(ConnectStep step, String detail) {
    final s = state.value;
    state.value = s.copyWith(details: {...s.details, step: detail});
  }

  /// Runs the flow. Resolves to the updated connection on success.
  Future<SSHConnection?> run(SSHConnection connection) async {
    state.value = ConnectState.initial();
    final ssh = ref.read(sshServiceProvider);
    final agent = ref.read(agentManagerProvider);
    final grpc = ref.read(grpcServiceProvider);
    var step = ConnectStep.ssh;

    try {
      // Drop a previous session first
      await ref.read(connectionManagerProvider).disconnect();
      await ssh.disconnect();

      // 1. SSH
      _set(step, StepStatus.running, connection.address);
      await ssh.connect(connection);
      _set(step, StepStatus.done);

      // 2. Passwordless sudo, which the agent needs
      step = ConnectStep.permissions;
      _set(step, StepStatus.running);
      final whoami = (await ssh.execute('whoami')).trim();
      if (whoami == 'root') {
        _set(step, StepStatus.done, 'Logged in as root');
      } else if (await _sudoWorks()) {
        _set(step, StepStatus.done, 'Passwordless sudo available');
      } else {
        await _setUpSudo(connection, whoami);
        _set(step, StepStatus.done, 'Passwordless sudo set up');
      }

      // 3. Agent
      step = ConnectStep.agent;
      _set(step, StepStatus.running);
      final info = await agent.checkAgentVersion();
      if (!info.isInstalled) {
        final ok = await decide(
          const ConnectDecision(
            title: 'Install the agent?',
            message:
                'The agent is a small program that provides live stats and system '
                'control. It is installed to /opt/pi-control and takes a few seconds.',
            confirmLabel: 'Install',
          ),
        );
        if (ok == null) throw const ConnectCancelled();
        await agent.installAgent(onProgress: (m) => _detail(step, m));
        _set(step, StepStatus.done, 'Agent installed');
      } else if (info.needsUpdate) {
        final ok = await decide(
          ConnectDecision(
            title: 'Update the agent?',
            message:
                'Version ${info.version} is installed, this app needs '
                '${AppConstants.agentVersion}. Some features stay unavailable until you update.',
            confirmLabel: 'Update now',
            cancelLabel: 'Later',
          ),
        );
        if (ok != null) {
          await agent.installAgent(onProgress: (m) => _detail(step, m));
          _set(step, StepStatus.done, 'Updated to ${AppConstants.agentVersion}');
        } else {
          _set(step, StepStatus.done, 'Version ${info.version} (update available)');
        }
      } else {
        _set(step, StepStatus.done, 'Version ${info.version}');
      }

      // 4. Port forwarding (the tunnel needs it)
      step = ConnectStep.forwarding;
      _set(step, StepStatus.running);
      final config = (await ssh.execute(
        r'sudo -n sshd -T 2>/dev/null | grep -i "^allowtcpforwarding" || grep -i "^\s*AllowTcpForwarding" /etc/ssh/sshd_config || echo default',
      )).toLowerCase();
      if (config.contains('allowtcpforwarding no')) {
        final ok = await decide(
          const ConnectDecision(
            title: 'Enable port forwarding?',
            message:
                'SSH port forwarding is disabled on this Pi, but the app needs it for a '
                'secure connection to the agent. This sets "AllowTcpForwarding yes" in '
                '/etc/ssh/sshd_config (a backup is kept) and restarts SSH.',
            confirmLabel: 'Enable',
          ),
        );
        if (ok == null) throw const ConnectCancelled();
        await _enableForwarding(connection);
        _set(step, StepStatus.done, 'Enabled');
      } else {
        _set(step, StepStatus.done, 'Allowed');
      }

      // 5. Start the agent (installAgent already started a fresh one)
      step = ConnectStep.start;
      _set(step, StepStatus.running);
      await agent.startAgent();
      _set(step, StepStatus.done);

      // 6. Tunnel on a free local port
      step = ConnectStep.tunnel;
      _set(step, StepStatus.running);
      final port = await ssh.forwardLocal(0, '127.0.0.1', AppConstants.agentPort);
      await grpc.connect(port);
      _set(step, StepStatus.done, 'localhost:$port → Pi:${AppConstants.agentPort}');

      // 7. Talk to the agent once
      step = ConnectStep.ready;
      _set(step, StepStatus.running);
      String? version;
      try {
        version = (await grpc.getVersion()).version;
      } catch (e) {
        debugPrint('Could not read the agent version: $e');
      }
      final updated = connection.copyWith(lastConnected: DateTime.now(), agentVersion: version);
      await ref.read(connectionListProvider.notifier).updateConnection(updated);
      ref.read(currentConnectionProvider.notifier).setConnection(updated);
      _set(step, StepStatus.done);
      state.value = state.value.copyWith(finished: true);
      return updated;
    } on ConnectCancelled {
      _set(step, StepStatus.skipped, 'Cancelled');
      state.value = state.value.copyWith(error: 'Cancelled', finished: true);
      await ssh.disconnect();
      return null;
    } catch (e) {
      debugPrint('Connect failed at ${step.name}: $e');
      _set(step, StepStatus.failed);
      state.value = state.value.copyWith(error: describeConnectError(step, e), finished: true);
      await grpc.disconnect().catchError((_) {});
      await ssh.disconnect();
      return null;
    }
  }

  Future<bool> _sudoWorks() async {
    final out = await ref.read(sshServiceProvider).execute('sudo -n true 2>/dev/null && echo SUDO_OK || echo SUDO_NO');
    return out.contains('SUDO_OK');
  }

  /// Adds a sudoers drop-in for the user; the password goes over stdin
  Future<void> _setUpSudo(SSHConnection connection, String user) async {
    final ssh = ref.read(sshServiceProvider);
    final groups = await ssh.execute('id -nG');
    if (!RegExp(r'\b(sudo|wheel|admin)\b').hasMatch(groups)) {
      throw Exception(
        'User "$user" is not allowed to use sudo. Connect with a user in the sudo group '
        '(e.g. the default "pi" user) or with root.',
      );
    }

    var password = connection.password;
    final answer = await decide(
      ConnectDecision(
        title: 'Allow passwordless sudo?',
        message:
            'The agent needs sudo without a password prompt. This adds the file '
            '/etc/sudoers.d/010_pi-control-$user once. Your password is only used for this step.',
        confirmLabel: 'Set up',
        needsPassword: password.isEmpty,
      ),
    );
    if (answer == null) throw const ConnectCancelled();
    if (answer.isNotEmpty) password = answer;

    final file = '/etc/sudoers.d/010_pi-control-$user';
    final result = await ssh.executeWithStdin(
      "sudo -S -p '' sh -c 'echo \"$user ALL=(ALL) NOPASSWD:ALL\" > $file.tmp && "
      "chmod 440 $file.tmp && visudo -cf $file.tmp >/dev/null && mv $file.tmp $file'",
      '$password\n',
    );
    if (result.exitCode != 0 || !await _sudoWorks()) {
      final reason = result.stderr.toLowerCase().contains('incorrect') ||
              result.stderr.toLowerCase().contains('try again')
          ? 'The password was not accepted.'
          : result.stderr.trim();
      throw Exception('Could not set up sudo. $reason');
    }
  }

  Future<void> _enableForwarding(SSHConnection connection) async {
    final ssh = ref.read(sshServiceProvider);
    await ssh.execute('sudo cp -n /etc/ssh/sshd_config /etc/ssh/sshd_config.pi-control-backup');
    await ssh.execute(
      r"sudo sed -i 's/^\s*AllowTcpForwarding.*/AllowTcpForwarding yes/' /etc/ssh/sshd_config",
    );
    await ssh.execute(
      'grep -q "^AllowTcpForwarding" /etc/ssh/sshd_config || echo "AllowTcpForwarding yes" | sudo tee -a /etc/ssh/sshd_config >/dev/null',
    );
    // Restarting SSH drops this session; reconnect afterwards
    await ssh.execute('(sleep 1; sudo systemctl restart ssh 2>/dev/null || sudo systemctl restart sshd 2>/dev/null || sudo service ssh restart) >/dev/null 2>&1 &');
    await Future.delayed(const Duration(seconds: 4));
    await ssh.disconnect();
    await ssh.connect(connection);
  }
}

/// Explains a failure in words a user can act on
String describeConnectError(ConnectStep step, Object error) {
  final text = error.toString().replaceFirst('Exception: ', '');
  final lower = text.toLowerCase();
  if (step == ConnectStep.ssh) {
    if (lower.contains('auth') || lower.contains('permission denied')) {
      return 'Login failed. Check the username, password or key.';
    }
    if (lower.contains('timed out') || lower.contains('timeout')) {
      return 'The Pi did not answer in time. Is it switched on and on the same network?';
    }
    if (lower.contains('refused')) {
      return 'The connection was refused. Is SSH enabled on the Pi and the port correct?';
    }
    if (lower.contains('no route') || lower.contains('unreachable') || lower.contains('host lookup')) {
      return 'The address could not be reached. Check the host name or IP.';
    }
  }
  if (step == ConnectStep.start && lower.contains('not listening')) {
    return 'The agent started but does not accept connections. Check the agent log under Settings → Agent.';
  }
  return text;
}

/// Re-opens the session to the device that is already selected: SSH, agent,
/// tunnel and gRPC. Unlike [ConnectFlow] it asks nothing and installs nothing.
Future<void> resumeSession(WidgetRef ref) async {
  final connection = ref.read(currentConnectionProvider);
  if (connection == null) throw Exception('No device selected');
  final ssh = ref.read(sshServiceProvider);
  final grpc = ref.read(grpcServiceProvider);
  await grpc.disconnect().catchError((_) {});
  await ssh.disconnect();
  await ssh.connect(connection);
  await ref.read(agentManagerProvider).ensureAgentRunning();
  final port = await ssh.forwardLocal(0, '127.0.0.1', AppConstants.agentPort);
  // A new session makes every screen load fresh data
  await grpc.connect(port);
}

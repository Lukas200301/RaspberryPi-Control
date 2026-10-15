import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grpc/grpc.dart';
import '../generated/pi_control.pbgrpc.dart';
import '../providers/app_providers.dart';
import 'grpc_service.dart';

final adminServiceProvider = Provider<AdminService>(
  (ref) {
    ref.watch(grpcSessionProvider);
    return AdminService(ref.watch(grpcServiceProvider));
  },
);

/// Cron, firewall, users, hardware, GPIO and power (SystemAdmin service)
class AdminService {
  final GrpcService _grpc;

  AdminService(this._grpc);

  SystemAdminClient get _client {
    final channel = _grpc.channel;
    if (channel == null) throw Exception('Not connected to the agent');
    return SystemAdminClient(channel);
  }

  static final _short = CallOptions(timeout: const Duration(seconds: 60));
  static final _long = CallOptions(timeout: const Duration(minutes: 11));

  Future<T> _call<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on GrpcError catch (e) {
      if (e.code == StatusCode.unimplemented) {
        throw Exception('The agent on your Pi is too old for this tool. Update the agent.');
      }
      throw Exception(e.message ?? e.toString());
    }
  }

  // Cron
  Future<Crontab> getCrontab(String user) =>
      _call(() => _client.getCrontab(CrontabRequest()..user = user, options: _short));

  Future<CommandOutput> setCrontab(String user, String content) => _call(
    () => _client.setCrontab(Crontab()
      ..user = user
      ..content = content, options: _short),
  );

  Future<CommandOutput> runAsUser(String user, String command, {int timeoutSeconds = 60}) => _call(
    () => _client.runAsUser(
      RunAsUserRequest()
        ..user = user
        ..command = command
        ..timeoutSeconds = timeoutSeconds,
      options: CallOptions(timeout: Duration(seconds: timeoutSeconds + 10)),
    ),
  );

  // Firewall
  Future<FirewallStatus> getFirewall() => _call(() => _client.getFirewall(Empty(), options: _short));

  Future<CommandOutput> firewall(FirewallRequest request) => _call(
    () => _client.firewallAction(
      request,
      options: request.op == FirewallOp.FW_INSTALL ? _long : _short,
    ),
  );

  // Users
  Future<UserList> listUsers() => _call(() => _client.listUsers(Empty(), options: _short));

  Future<CommandOutput> user(UserRequest request) => _call(() => _client.userAction(request, options: _short));

  // Hardware
  Future<HardwareInfo> hardware() => _call(() => _client.getHardwareInfo(Empty(), options: _short));

  Future<GpioState> gpio() => _call(() => _client.getGpio(Empty(), options: _short));

  Future<CommandOutput> setGpio(GpioRequest request) => _call(() => _client.setGpio(request, options: _short));

  // Power
  Future<CommandOutput> power(PowerOp op) => _call(() => _client.power(PowerRequest()..op = op, options: _short));
}

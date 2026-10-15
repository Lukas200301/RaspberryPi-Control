import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../generated/pi_control.pb.dart';
import '../../services/admin_service.dart';
import '../../ui/ui.dart';
import '../../widgets/command_result.dart';

final _firewallProvider = FutureProvider.autoDispose<FirewallStatus>(
  (ref) => ref.watch(adminServiceProvider).getFirewall(),
);

/// ufw: status, defaults, rules
class FirewallScreen extends ConsumerWidget {
  const FirewallScreen({super.key});

  Future<void> _run(BuildContext context, WidgetRef ref, FirewallRequest request, String success) async {
    try {
      final result = await ref.read(adminServiceProvider).firewall(request);
      if (context.mounted) reportCommand(context, result, success: success);
    } catch (e) {
      if (context.mounted) showToast(context, describeError(e), tone: Tone.danger);
    }
    ref.invalidate(_firewallProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(_firewallProvider);

    return PageScaffold(
      title: 'Firewall',
      subtitle: 'ufw',
      actions: [
        IconButton(
          tooltip: 'Refresh',
          icon: const Icon(Icons.refresh),
          onPressed: () => ref.invalidate(_firewallProvider),
        ),
        if (status.valueOrNull?.installed ?? false)
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'reload') {
                await _run(context, ref, FirewallRequest()..op = FirewallOp.FW_RELOAD, 'Firewall reloaded');
              } else if (v == 'raw') {
                await showOutputDialog(context, title: 'ufw status verbose', output: status.value!.raw);
              } else if (v == 'reset' &&
                  await showConfirmDialog(
                    context,
                    title: 'Reset the firewall?',
                    message:
                        'All rules are deleted and the firewall is turned off. ufw keeps a backup of the old rules.',
                    confirmLabel: 'Reset',
                    destructive: true,
                  ) &&
                  context.mounted) {
                await _run(context, ref, FirewallRequest()..op = FirewallOp.FW_RESET, 'Firewall reset');
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'reload', child: Text('Reload rules')),
              PopupMenuItem(value: 'raw', child: Text('Show ufw status')),
              PopupMenuItem(value: 'reset', child: Text('Reset firewall')),
            ],
          ),
      ],
      floatingActionButton: (status.valueOrNull?.installed ?? false)
          ? FloatingActionButton.extended(
              onPressed: () => _addRule(context, ref, status.value!),
              icon: const Icon(Icons.add),
              label: const Text('Add rule'),
            )
          : null,
      body: AsyncView<FirewallStatus>(
        value: status,
        onRetry: () => ref.invalidate(_firewallProvider),
        data: (s) {
          if (!s.installed) {
            return EmptyState(
              icon: Icons.shield_outlined,
              title: 'ufw is not installed',
              message: 'ufw ("uncomplicated firewall") blocks unwanted network access to your Pi.',
              action: FilledButton.icon(
                onPressed: () async {
                  showToast(context, 'Installing ufw…', duration: const Duration(minutes: 5));
                  await _run(context, ref, FirewallRequest()..op = FirewallOp.FW_INSTALL, 'ufw installed');
                },
                icon: const Icon(Icons.download),
                label: const Text('Install ufw'),
              ),
            );
          }
          return PageList(
            onRefresh: () async => ref.invalidate(_firewallProvider),
            children: [
              _StatusCard(status: s, onRun: (r, msg) => _run(context, ref, r, msg)),
              SectionHeader(
                title: 'Rules',
                subtitle: s.rules.isEmpty
                    ? null
                    : s.active
                    ? '${s.rules.length} ${s.rules.length == 1 ? 'rule' : 'rules'}, evaluated top to bottom'
                    : '${s.rules.length} ${s.rules.length == 1 ? 'rule' : 'rules'}, applied when the firewall is turned on',
              ),
              if (s.rules.isEmpty)
                AppCard(
                  child: Text(
                    s.active
                        ? 'No rules: only the defaults apply.'
                        : 'No rules yet. Enabling the firewall adds a rule for SSH (port ${s.sshPort}) so the app keeps access.',
                    style: context.tt.bodyMedium?.copyWith(color: context.cs.onSurfaceVariant),
                  ),
                )
              else
                AppCard(
                  padding: const EdgeInsets.symmetric(vertical: Insets.xs),
                  child: Column(
                    children: [
                      for (var i = 0; i < s.rules.length; i++) ...[
                        if (i > 0) const Divider(indent: Insets.lg, endIndent: Insets.lg),
                        _RuleTile(
                          rule: s.rules[i],
                          sshPort: s.sshPort,
                          onDelete: () async {
                            final r = s.rules[i];
                            if (await showConfirmDialog(
                              context,
                              title: r.number > 0 ? 'Delete rule ${r.number}?' : 'Delete rule?',
                              message: '${r.action} ${r.to} from ${r.from}',
                              confirmLabel: 'Delete',
                              destructive: true,
                            )) {
                              if (!context.mounted) return;
                              await _run(
                                context,
                                ref,
                                FirewallRequest()
                                  ..op = FirewallOp.FW_DELETE_RULE
                                  ..number = r.number
                                  ..ruleSpec = r.spec,
                                'Rule deleted',
                              );
                            }
                          },
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _addRule(BuildContext context, WidgetRef ref, FirewallStatus status) async {
    final request = await showModalBottomSheet<FirewallRequest>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddRuleSheet(profiles: status.appProfiles, sshPort: status.sshPort),
    );
    if (request != null && context.mounted) await _run(context, ref, request, 'Rule added');
  }
}

class _StatusCard extends StatelessWidget {
  final FirewallStatus status;
  final Future<void> Function(FirewallRequest, String) onRun;

  const _StatusCard({required this.status, required this.onRun});

  @override
  Widget build(BuildContext context) {
    final s = status;
    Future<void> setDefault(String chain, String current) async {
      final picked = await showChoiceSheet<String>(
        context,
        title: 'Default for $chain traffic',
        value: current,
        choices: const [
          ('allow', 'Allow'),
          ('deny', 'Deny (drop silently)'),
          ('reject', 'Reject (answer with an error)'),
        ],
      );
      if (picked != null && picked != current) {
        await onRun(
          FirewallRequest()
            ..op = FirewallOp.FW_SET_DEFAULT
            ..chain = chain
            ..policy = picked,
          'Default for $chain set to $picked',
        );
      }
    }

    return AppCard(
      variant: CardVariant.raised,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(
                s.active ? Icons.shield : Icons.shield_outlined,
                tone: s.active ? Tone.success : Tone.warning,
                size: 52,
              ),
              const Gap(Insets.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.active ? 'Firewall is on' : 'Firewall is off', style: context.tt.titleLarge),
                    Text(
                      s.active ? 'Incoming traffic is filtered' : 'All traffic is allowed',
                      style: context.tt.bodyMedium?.copyWith(color: context.cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Switch(
                value: s.active,
                onChanged: (on) async {
                  if (on) {
                    if (!await showConfirmDialog(
                      context,
                      title: 'Turn the firewall on?',
                      message:
                          'SSH (port ${s.sshPort}) is allowed automatically so you keep access. '
                          'Other services stay reachable only if you add rules for them.',
                      confirmLabel: 'Turn on',
                      icon: Icons.shield,
                    )) {
                      return;
                    }
                  }
                  await onRun(
                    FirewallRequest()..op = on ? FirewallOp.FW_ENABLE : FirewallOp.FW_DISABLE,
                    on ? 'Firewall turned on' : 'Firewall turned off',
                  );
                },
              ),
            ],
          ),
          if (s.active) ...[
            const Gap(Insets.md),
            const Divider(),
            ActionTile(
              icon: Icons.call_received,
              title: 'Incoming',
              subtitle: 'Default for traffic to the Pi',
              trailing: StatusPill(s.defaultIncoming, tone: s.defaultIncoming == 'allow' ? Tone.warning : Tone.success),
              onTap: () => setDefault('incoming', s.defaultIncoming),
            ),
            ActionTile(
              icon: Icons.call_made,
              title: 'Outgoing',
              subtitle: 'Default for traffic from the Pi',
              trailing: StatusPill(s.defaultOutgoing, tone: Tone.neutral),
              onTap: () => setDefault('outgoing', s.defaultOutgoing),
            ),
            ActionTile(
              icon: Icons.receipt_long_outlined,
              title: 'Logging',
              subtitle: s.logging.isEmpty ? 'off' : s.logging,
              onTap: () async {
                final picked = await showChoiceSheet<String>(
                  context,
                  title: 'Logging level',
                  value: s.logging.contains('(')
                      ? s.logging.split('(').last.replaceAll(')', '')
                      : (s.logging.isEmpty ? 'off' : s.logging),
                  choices: const [
                    ('off', 'Off'),
                    ('low', 'Low'),
                    ('medium', 'Medium'),
                    ('high', 'High'),
                    ('full', 'Full'),
                  ],
                );
                if (picked != null) {
                  await onRun(
                    FirewallRequest()
                      ..op = FirewallOp.FW_SET_LOGGING
                      ..logging = picked,
                    'Logging set to $picked',
                  );
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _RuleTile extends StatelessWidget {
  final FirewallRule rule;
  final int sshPort;
  final VoidCallback onDelete;

  const _RuleTile({required this.rule, required this.sshPort, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final r = rule;
    final tone = r.action.startsWith('ALLOW')
        ? Tone.success
        : r.action.startsWith('LIMIT')
        ? Tone.warning
        : Tone.danger;
    final isSsh = r.to.startsWith('$sshPort/') || r.to == '$sshPort' || r.to.startsWith('OpenSSH');
    return ListTile(
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: context.cs.surfaceContainerHighest,
        child: r.number > 0
            ? Text('${r.number}', style: context.tt.labelMedium)
            : Icon(Icons.schedule, size: 16, color: context.cs.onSurfaceVariant),
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(r.to.replaceAll(' (v6)', ''), style: context.tt.titleSmall, overflow: TextOverflow.ellipsis),
          ),
          const Gap(Insets.sm),
          StatusPill(r.action, tone: tone),
          if (r.v6) ...[const Gap(Insets.xs), const StatusPill('IPv6')],
        ],
      ),
      subtitle: Text(
        [
          'From ${r.from.replaceAll(' (v6)', '')}',
          if (r.comment.isNotEmpty) r.comment,
          if (isSsh) 'keeps SSH reachable',
          if (r.number == 0) 'pending',
        ].join(' · '),
        style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant),
      ),
      trailing: IconButton(
        tooltip: 'Delete rule',
        icon: Icon(Icons.delete_outline, color: context.cs.error),
        onPressed: onDelete,
      ),
    );
  }
}

class _AddRuleSheet extends StatefulWidget {
  final List<String> profiles;
  final int sshPort;

  const _AddRuleSheet({required this.profiles, required this.sshPort});

  @override
  State<_AddRuleSheet> createState() => _AddRuleSheetState();
}

class _AddRuleSheetState extends State<_AddRuleSheet> {
  String _action = 'allow';
  String _direction = 'in';
  String _protocol = 'tcp';
  final _port = TextEditingController();
  final _from = TextEditingController();
  final _comment = TextEditingController();

  late final _presets = [
    ('SSH', '${widget.sshPort}', 'tcp'),
    ('HTTP', '80', 'tcp'),
    ('HTTPS', '443', 'tcp'),
    ('VNC', '5900', 'tcp'),
    ('Samba', '445', 'tcp'),
    ('Node app', '3000', 'tcp'),
    ('Home Assistant', '8123', 'tcp'),
    ('DNS', '53', 'any'),
  ];

  @override
  void dispose() {
    _port.dispose();
    _from.dispose();
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(Insets.xl, 0, Insets.xl, Insets.lg + MediaQuery.viewInsetsOf(context).bottom),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('New rule', style: context.tt.titleLarge),
              const Gap(Insets.md),
              Wrap(
                spacing: Insets.xs,
                runSpacing: Insets.xs,
                children: [
                  for (final p in _presets)
                    ActionChip(
                      label: Text(p.$1),
                      onPressed: () => setState(() {
                        _port.text = p.$2;
                        _protocol = p.$3;
                        if (_comment.text.isEmpty) _comment.text = p.$1;
                      }),
                    ),
                  for (final p in widget.profiles)
                    ActionChip(
                      avatar: const Icon(Icons.apps, size: 16),
                      label: Text(p),
                      onPressed: () => setState(() => _port.text = p),
                    ),
                ],
              ),
              const Gap(Insets.lg),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'allow', label: Text('Allow')),
                  ButtonSegment(value: 'deny', label: Text('Deny')),
                  ButtonSegment(value: 'reject', label: Text('Reject')),
                  ButtonSegment(value: 'limit', label: Text('Limit')),
                ],
                selected: {_action},
                onSelectionChanged: (v) => setState(() => _action = v.first),
              ),
              if (_action == 'limit')
                Padding(
                  padding: const EdgeInsets.only(top: Insets.xs),
                  child: Text(
                    'Limit blocks an address after 6 connections in 30 seconds (good against SSH brute force).',
                    style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant),
                  ),
                ),
              const Gap(Insets.md),
              Row(
                children: [
                  Expanded(
                    child: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'in', label: Text('Incoming')),
                        ButtonSegment(value: 'out', label: Text('Outgoing')),
                      ],
                      selected: {_direction},
                      onSelectionChanged: (v) => setState(() => _direction = v.first),
                    ),
                  ),
                ],
              ),
              const Gap(Insets.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _port,
                      decoration: const InputDecoration(labelText: 'Port or app', hintText: '22, 8000:8100, OpenSSH'),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const Gap(Insets.md),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      initialValue: _protocol,
                      decoration: const InputDecoration(labelText: 'Protocol'),
                      items: const [
                        DropdownMenuItem(value: 'tcp', child: Text('TCP')),
                        DropdownMenuItem(value: 'udp', child: Text('UDP')),
                        DropdownMenuItem(value: 'any', child: Text('Both')),
                      ],
                      onChanged: (v) => setState(() => _protocol = v ?? 'tcp'),
                    ),
                  ),
                ],
              ),
              const Gap(Insets.md),
              TextField(
                controller: _from,
                decoration: const InputDecoration(
                  labelText: 'From (optional)',
                  hintText: '192.168.1.0/24 — empty means anywhere',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const Gap(Insets.md),
              TextField(
                controller: _comment,
                decoration: const InputDecoration(labelText: 'Comment (optional)'),
              ),
              const Gap(Insets.lg),
              FilledButton.icon(
                onPressed: _port.text.trim().isEmpty && _from.text.trim().isEmpty
                    ? null
                    : () => Navigator.pop(
                        context,
                        FirewallRequest()
                          ..op = FirewallOp.FW_ADD_RULE
                          ..ruleAction = _action
                          ..direction = _direction
                          ..port = _port.text.trim()
                          ..protocol = _protocol
                          ..from = _from.text.trim()
                          ..comment = _comment.text.trim(),
                      ),
                icon: const Icon(Icons.add),
                label: const Text('Add rule'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

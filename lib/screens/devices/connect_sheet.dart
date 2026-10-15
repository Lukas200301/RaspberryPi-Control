import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../models/ssh_connection.dart';
import '../../services/connect_flow.dart';
import '../../ui/ui.dart';
import '../main_screen.dart';

/// Connects to [device] with a step-by-step progress sheet and opens the
/// app shell when done
Future<void> connectToDevice(BuildContext context, SSHConnection device) async {
  final connected = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    builder: (_) => _ConnectSheet(device: device),
  );
  if (connected == true && context.mounted) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainScreen()),
      (_) => false,
    );
  }
}

class _ConnectSheet extends ConsumerStatefulWidget {
  final SSHConnection device;

  const _ConnectSheet({required this.device});

  @override
  ConsumerState<_ConnectSheet> createState() => _ConnectSheetState();
}

class _ConnectSheetState extends ConsumerState<_ConnectSheet> {
  late final ConnectFlow _flow = ConnectFlow(ref, decide: _ask);
  ConnectDecision? _decision;
  Completer<String?>? _answer;
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _password.dispose();
    _flow.state.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    final result = await _flow.run(widget.device);
    if (result != null && mounted) Navigator.pop(context, true);
  }

  Future<String?> _ask(ConnectDecision decision) {
    _answer = Completer<String?>();
    _password.clear();
    setState(() => _decision = decision);
    return _answer!.future;
  }

  void _resolve(String? value) {
    setState(() => _decision = null);
    _answer?.complete(value);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          Insets.xl,
          0,
          Insets.xl,
          Insets.lg + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: ValueListenableBuilder<ConnectState>(
          valueListenable: _flow.state,
          builder: (context, s, _) {
            final failed = s.finished && s.error != null;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconBadge(
                      failed ? Icons.link_off : Icons.developer_board,
                      tone: failed ? Tone.danger : Tone.primary,
                      size: 48,
                    ),
                    const Gap(Insets.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            failed ? 'Could not connect' : 'Connecting to ${widget.device.name}',
                            style: context.tt.titleLarge,
                          ),
                          Text(
                            widget.device.address,
                            style: context.tt.bodyMedium?.copyWith(color: context.cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Gap(Insets.lg),
                for (final step in ConnectStep.values)
                  _StepRow(
                    label: step.label,
                    status: s.steps[step]!,
                    detail: s.details[step],
                  ),
                if (_decision != null) ...[
                  const Gap(Insets.md),
                  _DecisionCard(
                    decision: _decision!,
                    password: _password,
                    obscure: _obscure,
                    onToggleObscure: () => setState(() => _obscure = !_obscure),
                    onAnswer: _resolve,
                  ),
                ],
                if (failed) ...[
                  const Gap(Insets.md),
                  AppCard(
                    accent: context.cs.error,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.error_outline, color: context.cs.error),
                        const Gap(Insets.md),
                        Expanded(child: Text(s.error!, style: context.tt.bodyMedium)),
                      ],
                    ),
                  ),
                  const Gap(Insets.lg),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Close'),
                        ),
                      ),
                      const Gap(Insets.md),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _start,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try again'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final String label;
  final StepStatus status;
  final String? detail;

  const _StepRow({required this.label, required this.status, this.detail});

  @override
  Widget build(BuildContext context) {
    final Widget icon = switch (status) {
      StepStatus.running => const SizedBox.square(
        dimension: 20,
        child: CircularProgressIndicator(strokeWidth: 2.5),
      ),
      StepStatus.done => Icon(Icons.check_circle, size: 22, color: context.ac.success),
      StepStatus.failed => Icon(Icons.cancel, size: 22, color: context.cs.error),
      StepStatus.skipped => Icon(Icons.remove_circle_outline, size: 22, color: context.cs.onSurfaceVariant),
      StepStatus.pending => Icon(Icons.radio_button_unchecked, size: 22, color: context.cs.outlineVariant),
    };
    final active = status != StepStatus.pending;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 24, child: Center(child: icon)),
          const Gap(Insets.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.tt.bodyLarge?.copyWith(
                    color: active ? context.cs.onSurface : context.cs.onSurfaceVariant,
                    fontWeight: status == StepStatus.running ? FontWeight.w600 : null,
                  ),
                ),
                if (detail != null && detail!.isNotEmpty)
                  Text(
                    detail!,
                    style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DecisionCard extends StatelessWidget {
  final ConnectDecision decision;
  final TextEditingController password;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final ValueChanged<String?> onAnswer;

  const _DecisionCard({
    required this.decision,
    required this.password,
    required this.obscure,
    required this.onToggleObscure,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: CardVariant.raised,
      accent: context.cs.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(decision.title, style: context.tt.titleMedium),
          const Gap(Insets.xs),
          Text(
            decision.message,
            style: context.tt.bodyMedium?.copyWith(color: context.cs.onSurfaceVariant),
          ),
          if (decision.needsPassword) ...[
            const Gap(Insets.md),
            TextField(
              controller: password,
              obscureText: obscure,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Password of the user',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
                  onPressed: onToggleObscure,
                ),
              ),
            ),
          ],
          const Gap(Insets.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: () => onAnswer(null), child: Text(decision.cancelLabel)),
              const Gap(Insets.sm),
              FilledButton(
                onPressed: () => onAnswer(decision.needsPassword ? password.text : ''),
                child: Text(decision.confirmLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

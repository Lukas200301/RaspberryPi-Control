import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../generated/pi_control.pb.dart';
import '../../providers/settings_provider.dart';
import '../../services/admin_service.dart';
import '../../ui/ui.dart';
import '../../widgets/command_result.dart';

final _hardwareProvider = FutureProvider.autoDispose<HardwareInfo>(
  (ref) => ref.watch(adminServiceProvider).hardware(),
);

class HardwareScreen extends ConsumerStatefulWidget {
  const HardwareScreen({super.key});

  @override
  ConsumerState<HardwareScreen> createState() => _HardwareScreenState();
}

class _HardwareScreenState extends ConsumerState<HardwareScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Hardware',
      actions: [
        if (_tab == 0)
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(_hardwareProvider),
          ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Insets.page, 0, Insets.page, Insets.sm),
          child: SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, icon: Icon(Icons.developer_board), label: Text('Overview')),
              ButtonSegment(value: 1, icon: Icon(Icons.settings_input_component), label: Text('GPIO')),
            ],
            selected: {_tab},
            onSelectionChanged: (v) => setState(() => _tab = v.first),
          ),
        ),
      ),
      body: _tab == 0 ? const _Overview() : const _GpioView(),
    );
  }
}

class _Overview extends ConsumerWidget {
  const _Overview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return AsyncView<HardwareInfo>(
      value: ref.watch(_hardwareProvider),
      onRetry: () => ref.invalidate(_hardwareProvider),
      data: (h) {
        final healthy = h.throttledNow.isEmpty && h.throttledPast.isEmpty;
        return PageList(
          onRefresh: () async => ref.invalidate(_hardwareProvider),
          children: [
            AppCard(
              variant: CardVariant.raised,
              child: Row(
                children: [
                  IconBadge(h.isRaspberryPi ? Icons.developer_board : Icons.computer, size: 56),
                  const Gap(Insets.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(h.model.isEmpty ? h.hostname : h.model, style: context.tt.titleLarge),
                        Text(
                          [h.os, h.architecture].where((s) => s.isNotEmpty).join(' · '),
                          style: context.tt.bodyMedium?.copyWith(color: context.cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (h.vcgencmdAvailable) ...[
              const SectionHeader(title: 'Health'),
              AppCard(
                accent: healthy ? null : (h.throttledNow.isNotEmpty ? context.cs.error : context.ac.warning),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          healthy ? Icons.verified : Icons.warning_amber_rounded,
                          color: healthy ? context.ac.success : (h.throttledNow.isNotEmpty ? context.cs.error : context.ac.warning),
                        ),
                        const Gap(Insets.md),
                        Expanded(
                          child: Text(
                            healthy
                                ? 'Power and temperature are fine'
                                : h.throttledNow.isNotEmpty
                                ? 'Problem right now: ${h.throttledNow.join(', ')}'
                                : 'Happened since boot: ${h.throttledPast.join(', ')}',
                            style: context.tt.titleSmall,
                          ),
                        ),
                      ],
                    ),
                    if (!healthy) ...[
                      const Gap(Insets.sm),
                      Text(
                        [...h.throttledNow, ...h.throttledPast].contains('Under-voltage')
                            ? 'Under-voltage means the power supply cannot deliver enough current. Use the official '
                                  'power supply and a short, thick cable; unpowered USB devices also draw power.'
                            : 'The Pi slowed down to protect itself from heat. Add a heatsink or fan, or improve airflow.',
                        style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant),
                      ),
                    ],
                    const Gap(Insets.sm),
                    InfoRow('Temperature', h.cpuTemp > 0 ? settings.formatTemperature(h.cpuTemp) : '–'),
                    InfoRow('Throttle flags', h.throttledRaw, mono: true),
                    for (final v in h.voltages.entries) InfoRow('Voltage ${v.key}', v.value, mono: true),
                  ],
                ),
              ),
            ],
            const SectionHeader(title: 'Processor'),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoRow('SoC', h.soc),
                  InfoRow('Cores', '${h.cpuCores}'),
                  if (h.cpuMaxMhz > 0) InfoRow('Clock range', '${h.cpuMinMhz} – ${h.cpuMaxMhz} MHz'),
                  if (h.governor.isNotEmpty) InfoRow('Governor', h.governor),
                  for (final c in h.clocks.entries) InfoRow('Clock ${c.key}', c.value),
                  if (h.cpuFreqMhz.any((f) => f > 0) && h.cpuMaxMhz > 0) ...[
                    const Gap(Insets.md),
                    Text('Current clock per core', style: context.tt.labelLarge),
                    const Gap(Insets.sm),
                    for (var i = 0; i < h.cpuFreqMhz.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: Insets.sm),
                        child: Row(
                          children: [
                            SizedBox(width: 56, child: Text('Core $i', style: context.tt.bodySmall)),
                            Expanded(child: UsageBar(value: h.cpuFreqMhz[i].toInt() / h.cpuMaxMhz.toInt(), height: 6)),
                            SizedBox(
                              width: 80,
                              child: Text(
                                '${h.cpuFreqMhz[i]} MHz',
                                textAlign: TextAlign.end,
                                style: context.tt.bodySmall?.copyWith(fontFeatures: tabularFigures),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ],
              ),
            ),
            const SectionHeader(title: 'System'),
            AppCard(
              child: Column(
                children: [
                  InfoRow('Memory', formatBytes(h.memoryTotal.toInt())),
                  if (h.gpuMemory.isNotEmpty) InfoRow('GPU memory', h.gpuMemory),
                  InfoRow('Kernel', h.kernel, mono: true),
                  if (h.firmware.isNotEmpty) InfoRow('Firmware', h.firmware),
                  if (h.bootloader.isNotEmpty) InfoRow('Bootloader', h.bootloader),
                  if (h.serial.isNotEmpty) InfoRow('Serial', h.serial, mono: true),
                  if (h.revision.isNotEmpty) InfoRow('Revision', h.revision, mono: true),
                  InfoRow('Hostname', h.hostname),
                ],
              ),
            ),
            if (h.usbDevices.isNotEmpty) ...[
              const SectionHeader(title: 'USB devices'),
              TileGroup(
                children: [
                  for (final d in h.usbDevices)
                    ActionTile(icon: Icons.usb, tone: Tone.info, title: d, dense: true, trailing: const SizedBox.shrink()),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Physical layout of the 40-pin header: pin number → (label, BCM GPIO)
const _header = <int, (String, int?)>{
  1: ('3V3', null), 2: ('5V', null), 3: ('GPIO2', 2), 4: ('5V', null),
  5: ('GPIO3', 3), 6: ('GND', null), 7: ('GPIO4', 4), 8: ('GPIO14', 14),
  9: ('GND', null), 10: ('GPIO15', 15), 11: ('GPIO17', 17), 12: ('GPIO18', 18),
  13: ('GPIO27', 27), 14: ('GND', null), 15: ('GPIO22', 22), 16: ('GPIO23', 23),
  17: ('3V3', null), 18: ('GPIO24', 24), 19: ('GPIO10', 10), 20: ('GND', null),
  21: ('GPIO9', 9), 22: ('GPIO25', 25), 23: ('GPIO11', 11), 24: ('GPIO8', 8),
  25: ('GND', null), 26: ('GPIO7', 7), 27: ('GPIO0', 0), 28: ('GPIO1', 1),
  29: ('GPIO5', 5), 30: ('GND', null), 31: ('GPIO6', 6), 32: ('GPIO12', 12),
  33: ('GPIO13', 13), 34: ('GND', null), 35: ('GPIO19', 19), 36: ('GPIO16', 16),
  37: ('GPIO26', 26), 38: ('GPIO20', 20), 39: ('GND', null), 40: ('GPIO21', 21),
};

class _GpioView extends ConsumerStatefulWidget {
  const _GpioView();

  @override
  ConsumerState<_GpioView> createState() => _GpioViewState();
}

class _GpioViewState extends ConsumerState<_GpioView> {
  GpioState? _state;
  Object? _error;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final s = await ref.read(adminServiceProvider).gpio();
      if (mounted) setState(() => _state = s);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _state;
    if (s == null) {
      return _error != null ? ErrorState(error: _error!, onRetry: _load) : const LoadingState();
    }
    if (!s.supported) {
      return EmptyState(icon: Icons.settings_input_component, title: 'No GPIO here', message: s.error);
    }
    final pins = {for (final p in s.pins) p.gpio: p};

    return PageList(
      children: [
        AppCard(
          child: Text(
            'Tap a pin to read or set it. Wrong wiring or driving a pin that is connected to something '
            'can damage your Pi. Pins used by the system (e.g. serial or I²C) show their function.',
            style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant),
          ),
        ),
        const Gap(Insets.lg),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: AppCard(
              padding: const EdgeInsets.all(Insets.md),
              child: Column(
                children: [
                  for (var row = 0; row < 20; row++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Expanded(child: _PinCell(physical: row * 2 + 1, pins: pins, alignEnd: true, onTap: _edit)),
                          const Gap(Insets.sm),
                          Expanded(child: _PinCell(physical: row * 2 + 2, pins: pins, alignEnd: false, onTap: _edit)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const Gap(Insets.md),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: Insets.md,
          runSpacing: Insets.xs,
          children: [
            _legend(context, context.cs.primary, 'Input'),
            _legend(context, context.ac.warning, 'Output'),
            _legend(context, context.ac.info, 'Alternate function'),
            _legend(context, context.cs.error, 'Power'),
            _legend(context, context.cs.outline, 'Ground'),
          ],
        ),
        const Gap(Insets.sm),
        Text(
          'Read with ${s.tool}, refreshed every 2 seconds',
          textAlign: TextAlign.center,
          style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _legend(BuildContext context, Color color, String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const Gap(Insets.xs),
      Text(label, style: context.tt.bodySmall),
    ],
  );

  Future<void> _edit(GpioPin pin) async {
    final request = await showModalBottomSheet<GpioRequest>(
      context: context,
      builder: (_) => _PinSheet(pin: pin),
    );
    if (request == null || !mounted) return;
    try {
      final result = await ref.read(adminServiceProvider).setGpio(request);
      if (mounted) reportCommand(context, result, success: 'GPIO${pin.gpio} updated');
    } catch (e) {
      if (mounted) showToast(context, describeError(e), tone: Tone.danger);
    }
    await _load();
  }
}

class _PinCell extends StatelessWidget {
  final int physical;
  final Map<int, GpioPin> pins;
  final bool alignEnd;
  final ValueChanged<GpioPin> onTap;

  const _PinCell({required this.physical, required this.pins, required this.alignEnd, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final (label, gpio) = _header[physical]!;
    final pin = gpio == null ? null : pins[gpio];
    final Color color;
    String detail = '';
    if (label == 'GND') {
      color = context.cs.outline;
    } else if (gpio == null) {
      color = context.cs.error;
    } else if (pin == null) {
      color = context.cs.outlineVariant;
    } else if (pin.mode == 'output') {
      color = context.ac.warning;
      detail = pin.level ? 'high' : 'low';
    } else if (pin.mode == 'input') {
      color = context.cs.primary;
      detail = '${pin.level ? 'high' : 'low'}${pin.pull.isNotEmpty && pin.pull != 'none' ? ' · ${pin.pull}' : ''}';
    } else {
      color = context.ac.info;
      detail = pin.function;
    }

    final dot = Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      child: pin != null && pin.level && (pin.mode == 'input' || pin.mode == 'output')
          ? Center(child: Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)))
          : null,
    );
    final text = Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: context.tt.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
        if (detail.isNotEmpty)
          Text(detail, style: context.tt.labelSmall?.copyWith(color: context.cs.onSurfaceVariant), overflow: TextOverflow.ellipsis),
      ],
    );
    final number = SizedBox(
      width: 22,
      child: Text(
        '$physical',
        textAlign: TextAlign.center,
        style: context.tt.labelSmall?.copyWith(color: context.cs.onSurfaceVariant),
      ),
    );

    return InkWell(
      borderRadius: Radii.smAll,
      onTap: pin == null ? null : () => onTap(pin),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Row(
          mainAxisAlignment: alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: alignEnd
              ? [Flexible(child: text), const Gap(Insets.sm), dot, const Gap(2), number]
              : [number, const Gap(2), dot, const Gap(Insets.sm), Flexible(child: text)],
        ),
      ),
    );
  }
}

class _PinSheet extends StatefulWidget {
  final GpioPin pin;

  const _PinSheet({required this.pin});

  @override
  State<_PinSheet> createState() => _PinSheetState();
}

class _PinSheetState extends State<_PinSheet> {
  late String _mode = widget.pin.mode == 'output' ? 'output' : 'input';
  late bool _level = widget.pin.level;
  late String _pull = widget.pin.pull.isEmpty ? 'none' : widget.pin.pull;

  @override
  Widget build(BuildContext context) {
    final p = widget.pin;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Insets.xl, 0, Insets.xl, Insets.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('GPIO${p.gpio}', style: context.tt.titleLarge),
            Text(
              'Now: ${p.mode}${p.mode == 'input' || p.mode == 'output' ? ', ${p.level ? 'high' : 'low'}' : ''}'
              '${p.function.isNotEmpty && p.function != 'GPIO${p.gpio}' ? ' · ${p.function}' : ''}',
              style: context.tt.bodyMedium?.copyWith(color: context.cs.onSurfaceVariant),
            ),
            if (p.mode.startsWith('alt'))
              Padding(
                padding: const EdgeInsets.only(top: Insets.sm),
                child: Text(
                  'This pin is used by ${p.function}. Changing it disables that function until reboot.',
                  style: context.tt.bodySmall?.copyWith(color: context.ac.warning),
                ),
              ),
            const Gap(Insets.lg),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'input', icon: Icon(Icons.login), label: Text('Input')),
                ButtonSegment(value: 'output', icon: Icon(Icons.logout), label: Text('Output')),
              ],
              selected: {_mode},
              onSelectionChanged: (v) => setState(() => _mode = v.first),
            ),
            const Gap(Insets.md),
            if (_mode == 'output')
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Level'),
                subtitle: Text(_level ? 'High (3.3 V)' : 'Low (0 V)'),
                value: _level,
                onChanged: (v) => setState(() => _level = v),
              )
            else
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'up', label: Text('Pull-up')),
                  ButtonSegment(value: 'down', label: Text('Pull-down')),
                  ButtonSegment(value: 'none', label: Text('None')),
                ],
                selected: {_pull},
                onSelectionChanged: (v) => setState(() => _pull = v.first),
              ),
            const Gap(Insets.lg),
            FilledButton(
              onPressed: () => Navigator.pop(
                context,
                GpioRequest()
                  ..gpio = p.gpio
                  ..mode = _mode
                  ..level = _level
                  ..pull = _pull,
              ),
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }
}

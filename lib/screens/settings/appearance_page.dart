import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../models/app_settings.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';
import '../../ui/ui.dart';

class AppearancePage extends ConsumerWidget {
  const AppearancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    void set(AppSettings Function(AppSettings) change) => notifier.update(change);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PageScaffold(
      title: 'Appearance',
      maxWidth: 760,
      body: PageList(
        children: [
          const _ThemePreview(),
          const SectionHeader(title: 'Theme'),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.brightness_auto), label: Text('System')),
                    ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode), label: Text('Light')),
                    ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode), label: Text('Dark')),
                  ],
                  selected: {s.themeMode},
                  onSelectionChanged: (v) => set((s) => s.copyWith(themeMode: v.first)),
                ),
                const Gap(Insets.lg),
                SegmentedButton<ColorSource>(
                  segments: [
                    const ButtonSegment(value: ColorSource.preset, icon: Icon(Icons.palette_outlined), label: Text('Preset')),
                    const ButtonSegment(value: ColorSource.custom, icon: Icon(Icons.colorize), label: Text('Custom')),
                    if (Platform.isAndroid)
                      const ButtonSegment(value: ColorSource.dynamic, icon: Icon(Icons.wallpaper), label: Text('Wallpaper')),
                  ],
                  selected: {s.colorSource},
                  onSelectionChanged: (v) => set((s) => s.copyWith(colorSource: v.first)),
                ),
                const Gap(Insets.lg),
                if (s.colorSource == ColorSource.preset)
                  Wrap(
                    spacing: Insets.md,
                    runSpacing: Insets.md,
                    children: [
                      for (final p in AppTheme.presets)
                        _SeedSwatch(
                          color: Color(p.seed),
                          label: p.name,
                          selected: p.seed == s.presetSeed,
                          onTap: () => set((s) => s.copyWith(presetSeed: p.seed)),
                        ),
                    ],
                  )
                else if (s.colorSource == ColorSource.custom)
                  Row(
                    children: [
                      _SeedSwatch(color: Color(s.customSeed), label: _hex(Color(s.customSeed)), selected: true, onTap: () {}),
                      const Gap(Insets.lg),
                      Expanded(
                        child: FilledButton.tonalIcon(
                          icon: const Icon(Icons.colorize),
                          label: const Text('Pick a color'),
                          onPressed: () async {
                            final color = await showColorPicker(context, Color(s.customSeed));
                            if (color != null) set((s) => s.copyWith(customSeed: color.toARGB32()));
                          },
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    'Colors follow your wallpaper (Android 12 and newer). Older versions use the selected preset.',
                    style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant),
                  ),
              ],
            ),
          ),
          SettingsSection(
            title: 'Display',
            children: [
              SwitchSettingTile(
                icon: Icons.contrast,
                title: 'Pure black',
                subtitle: isDark ? 'True black backgrounds, saves power on OLED' : 'Applies in dark mode',
                value: s.pureBlack,
                onChanged: (v) => set((s) => s.copyWith(pureBlack: v)),
              ),
              ChoiceSettingTile<double>(
                icon: Icons.tonality,
                title: 'Contrast',
                value: s.contrast,
                choices: const [(0.0, 'Standard'), (0.5, 'Medium'), (1.0, 'High')],
                onChanged: (v) => set((s) => s.copyWith(contrast: v)),
              ),
              SliderSettingTile(
                icon: Icons.format_size,
                title: 'Text size',
                value: s.textScale,
                min: 0.8,
                max: 1.4,
                divisions: 12,
                format: (v) => '${(v * 100).round()} %',
                onChanged: (v) => set((s) => s.copyWith(textScale: double.parse(v.toStringAsFixed(2)))),
              ),
              SwitchSettingTile(
                icon: Icons.density_medium,
                title: 'Compact layout',
                subtitle: 'Tighter lists and controls',
                value: s.compact,
                onChanged: (v) => set((s) => s.copyWith(compact: v)),
              ),
              SwitchSettingTile(
                icon: Icons.animation,
                title: 'Animations',
                subtitle: 'Page transitions and animated charts',
                value: s.animations,
                onChanged: (v) => set((s) => s.copyWith(animations: v)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _hex(Color c) => '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

class _SeedSwatch extends StatelessWidget {
  final Color color;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SeedSwatch({required this.color, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(seedColor: color, brightness: Theme.of(context).brightness);
    return InkWell(
      onTap: onTap,
      borderRadius: Radii.mdAll,
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56,
              height: 56,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: selected ? context.cs.onSurface : Colors.transparent, width: 2.5),
              ),
              child: ClipOval(
                child: Column(
                  children: [
                    Expanded(child: Container(color: scheme.primary)),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(child: Container(color: scheme.secondaryContainer)),
                          Expanded(child: Container(color: scheme.tertiary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Gap(Insets.xs),
            Text(label, style: context.tt.labelSmall, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

/// A small live sample of the current theme
class _ThemePreview extends StatelessWidget {
  const _ThemePreview();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: CardVariant.raised,
      child: Row(
        children: [
          RingGauge(
            value: 0.42,
            size: 76,
            color: context.cs.primary,
            center: Text('42%', style: context.tt.titleMedium?.copyWith(fontFeatures: tabularFigures)),
          ),
          const Gap(Insets.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('raspberrypi', style: context.tt.titleMedium),
                const Gap(Insets.xs),
                const Wrap(
                  spacing: Insets.xs,
                  runSpacing: Insets.xs,
                  children: [
                    StatusPill('Online', tone: Tone.success, dot: true),
                    StatusPill('52°C', tone: Tone.warning),
                  ],
                ),
                const Gap(Insets.sm),
                FilledButton.tonal(onPressed: () {}, child: const Text('Button')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// HSV color picker with a hex field. Resolves to the picked color.
Future<Color?> showColorPicker(BuildContext context, Color initial) {
  var hsv = HSVColor.fromColor(initial);
  final hex = TextEditingController(text: _hex(initial));

  return showDialog<Color>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) {
        void setHsv(HSVColor v) => setState(() {
          hsv = v;
          hex.text = _hex(v.toColor());
        });

        Widget slider(String label, double value, double max, List<Color> colors, ValueChanged<double> onChanged) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: context.tt.labelMedium),
              const Gap(Insets.xs),
              Container(
                height: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(colors: colors),
                ),
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 0,
                    activeTrackColor: Colors.transparent,
                    inactiveTrackColor: Colors.transparent,
                    thumbColor: Colors.white,
                    overlayShape: SliderComponentShape.noOverlay,
                  ),
                  child: Slider(value: value, max: max, onChanged: onChanged),
                ),
              ),
              const Gap(Insets.md),
            ],
          );
        }

        return AlertDialog(
          title: const Text('Custom color'),
          content: SizedBox(
            width: 340,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 64,
                  decoration: BoxDecoration(color: hsv.toColor(), borderRadius: Radii.lgAll),
                ),
                const Gap(Insets.lg),
                slider('Hue', hsv.hue, 360, [
                  for (var h = 0; h <= 360; h += 60) HSVColor.fromAHSV(1, h.toDouble(), 1, 1).toColor(),
                ], (v) => setHsv(hsv.withHue(v))),
                slider('Saturation', hsv.saturation, 1, [
                  hsv.withSaturation(0).toColor(),
                  hsv.withSaturation(1).toColor(),
                ], (v) => setHsv(hsv.withSaturation(v))),
                slider('Brightness', hsv.value, 1, [
                  hsv.withValue(0).toColor(),
                  hsv.withValue(1).toColor(),
                ], (v) => setHsv(hsv.withValue(v))),
                TextField(
                  controller: hex,
                  decoration: const InputDecoration(labelText: 'Hex', prefixIcon: Icon(Icons.tag)),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[#0-9a-fA-F]'))],
                  onSubmitted: (v) {
                    final value = int.tryParse(v.replaceAll('#', ''), radix: 16);
                    if (value != null && v.replaceAll('#', '').length == 6) {
                      setState(() => hsv = HSVColor.fromColor(Color(0xFF000000 | value)));
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(dialogContext, hsv.toColor()), child: const Text('Use color')),
          ],
        );
      },
    ),
  );
}

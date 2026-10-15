import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/app_settings.dart';
import '../../providers/settings_provider.dart';
import '../../theme/terminal_themes.dart';
import '../../ui/ui.dart';

mixin _SettingsAccess on ConsumerWidget {
  void set(WidgetRef ref, AppSettings Function(AppSettings) change) =>
      ref.read(settingsProvider.notifier).update(change);
}

class MonitoringSettingsPage extends ConsumerWidget with _SettingsAccess {
  const MonitoringSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    return PageScaffold(
      title: 'Dashboard & monitoring',
      maxWidth: 760,
      body: PageList(
        children: [
          SettingsSection(
            title: 'Units',
            children: [
              ChoiceSettingTile<TemperatureUnit>(
                icon: Icons.thermostat,
                title: 'Temperature unit',
                value: s.temperatureUnit,
                choices: const [
                  (TemperatureUnit.celsius, 'Celsius (°C)'),
                  (TemperatureUnit.fahrenheit, 'Fahrenheit (°F)'),
                ],
                onChanged: (v) => set(ref, (s) => s.copyWith(temperatureUnit: v)),
              ),
            ],
          ),
          SettingsSection(
            title: 'Temperature thresholds',
            footer: 'Used for colors on the dashboard. Alerts have their own limit under Alerts & notifications.',
            children: [
              SliderSettingTile(
                icon: Icons.warning_amber_rounded,
                tone: Tone.warning,
                title: 'Warning from',
                value: s.tempWarning,
                min: 40,
                max: 85,
                divisions: 45,
                format: (v) => s.formatTemperature(v, digits: 0),
                onChanged: (v) => set(ref, (s) => s.copyWith(
                  tempWarning: v.roundToDouble(),
                  tempCritical: s.tempCritical < v ? v.roundToDouble() : null,
                )),
              ),
              SliderSettingTile(
                icon: Icons.local_fire_department,
                tone: Tone.danger,
                title: 'Critical from',
                value: s.tempCritical,
                min: 50,
                max: 95,
                divisions: 45,
                format: (v) => s.formatTemperature(v, digits: 0),
                onChanged: (v) => set(ref, (s) => s.copyWith(
                  tempCritical: v.roundToDouble(),
                  tempWarning: s.tempWarning > v ? v.roundToDouble() : null,
                )),
              ),
            ],
          ),
          SettingsSection(
            title: 'Data',
            children: [
              ChoiceSettingTile<int>(
                icon: Icons.timeline,
                title: 'Chart history',
                value: s.statsHistory,
                choices: const [(30, '30 seconds'), (60, '1 minute'), (120, '2 minutes'), (300, '5 minutes'), (600, '10 minutes')],
                onChanged: (v) => set(ref, (s) => s.copyWith(statsHistory: v)),
              ),
              ChoiceSettingTile<int>(
                icon: Icons.refresh,
                title: 'List refresh interval',
                subtitle: 'How often process lists, containers and PM2 apps update',
                value: s.refreshSeconds,
                choices: const [(2, '2 seconds'), (4, '4 seconds'), (8, '8 seconds'), (15, '15 seconds'), (30, '30 seconds')],
                onChanged: (v) => set(ref, (s) => s.copyWith(refreshSeconds: v)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TerminalSettingsPage extends ConsumerWidget with _SettingsAccess {
  const TerminalSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final scheme = terminalSchemeById(s.terminalTheme).theme;

    return PageScaffold(
      title: 'Terminal',
      maxWidth: 760,
      body: PageList(
        children: [
          ClipRRect(
            borderRadius: Radii.cardAll,
            child: Container(
              color: scheme.background,
              padding: const EdgeInsets.all(Insets.lg),
              child: Text.rich(
                TextSpan(
                  style: GoogleFonts.getFont(s.terminalFont, fontSize: s.terminalFontSize, color: scheme.foreground, height: 1.35),
                  children: [
                    TextSpan(text: 'pi@raspberrypi', style: TextStyle(color: scheme.green, fontWeight: FontWeight.bold)),
                    const TextSpan(text: ':'),
                    TextSpan(text: '~/app', style: TextStyle(color: scheme.blue, fontWeight: FontWeight.bold)),
                    const TextSpan(text: r'$ ls -l' '\n'),
                    TextSpan(text: 'drwxr-xr-x ', style: TextStyle(color: scheme.brightBlack)),
                    TextSpan(text: 'node_modules\n', style: TextStyle(color: scheme.blue)),
                    TextSpan(text: '-rwxr-xr-x ', style: TextStyle(color: scheme.brightBlack)),
                    TextSpan(text: 'start.sh\n', style: TextStyle(color: scheme.green)),
                    TextSpan(text: 'error: ', style: TextStyle(color: scheme.red)),
                    TextSpan(text: 'warning ', style: TextStyle(color: scheme.yellow)),
                    TextSpan(text: 'info ', style: TextStyle(color: scheme.cyan)),
                    TextSpan(text: 'magic', style: TextStyle(color: scheme.magenta)),
                    TextSpan(text: ' █', style: TextStyle(color: scheme.cursor)),
                  ],
                ),
              ),
            ),
          ),
          const SectionHeader(title: 'Color scheme'),
          Wrap(
            spacing: Insets.sm,
            runSpacing: Insets.sm,
            children: [
              for (final t in terminalSchemes)
                ChoiceChip(
                  showCheckmark: false,
                  avatar: CircleAvatar(
                    backgroundColor: t.theme.background,
                    child: CircleAvatar(radius: 5, backgroundColor: t.theme.cursor),
                  ),
                  label: Text(t.name),
                  selected: t.id == s.terminalTheme,
                  onSelected: (_) => set(ref, (s) => s.copyWith(terminalTheme: t.id)),
                ),
            ],
          ),
          SettingsSection(
            title: 'Text',
            children: [
              ChoiceSettingTile<String>(
                icon: Icons.font_download_outlined,
                title: 'Font',
                value: s.terminalFont,
                choices: [for (final f in AppSettings.terminalFonts) (f, f)],
                onChanged: (v) => set(ref, (s) => s.copyWith(terminalFont: v)),
              ),
              SliderSettingTile(
                icon: Icons.format_size,
                title: 'Font size',
                value: s.terminalFontSize,
                min: 9,
                max: 24,
                divisions: 15,
                format: (v) => '${v.round()} pt',
                onChanged: (v) => set(ref, (s) => s.copyWith(terminalFontSize: v.roundToDouble())),
              ),
            ],
          ),
          SettingsSection(
            title: 'Behavior',
            children: [
              ChoiceSettingTile<TerminalCursor>(
                icon: Icons.text_fields,
                title: 'Cursor',
                value: s.terminalCursor,
                choices: const [
                  (TerminalCursor.block, 'Block'),
                  (TerminalCursor.underline, 'Underline'),
                  (TerminalCursor.bar, 'Bar'),
                ],
                onChanged: (v) => set(ref, (s) => s.copyWith(terminalCursor: v)),
              ),
              SwitchSettingTile(
                icon: Icons.flare,
                title: 'Keep cursor visible',
                subtitle: 'Also while the keyboard is closed',
                value: s.terminalCursorBlink,
                onChanged: (v) => set(ref, (s) => s.copyWith(terminalCursorBlink: v)),
              ),
              ChoiceSettingTile<int>(
                icon: Icons.history,
                title: 'Scrollback',
                value: s.terminalScrollback,
                choices: const [(1000, '1,000 lines'), (5000, '5,000 lines'), (10000, '10,000 lines'), (50000, '50,000 lines')],
                onChanged: (v) => set(ref, (s) => s.copyWith(terminalScrollback: v)),
              ),
              SwitchSettingTile(
                icon: Icons.keyboard_alt_outlined,
                title: 'Extra keys row',
                subtitle: 'Esc, Tab, Ctrl, arrows and more above the keyboard',
                value: s.terminalExtraKeys,
                onChanged: (v) => set(ref, (s) => s.copyWith(terminalExtraKeys: v)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ConnectionSettingsPage extends ConsumerWidget with _SettingsAccess {
  const ConnectionSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    return PageScaffold(
      title: 'Connection',
      maxWidth: 760,
      body: PageList(
        children: [
          SettingsSection(
            title: 'Session',
            children: [
              SwitchSettingTile(
                icon: Icons.autorenew,
                title: 'Reconnect automatically',
                subtitle: 'When the app returns to the foreground or the network comes back',
                value: s.autoReconnect,
                onChanged: (v) => set(ref, (s) => s.copyWith(autoReconnect: v)),
              ),
              ChoiceSettingTile<int>(
                icon: Icons.favorite_border,
                title: 'Keep-alive',
                subtitle: 'How often the SSH connection is checked',
                value: s.keepAliveSeconds,
                choices: const [(5, 'Every 5 seconds'), (15, 'Every 15 seconds'), (30, 'Every 30 seconds'), (60, 'Every minute')],
                onChanged: (v) => set(ref, (s) => s.copyWith(keepAliveSeconds: v)),
              ),
              ChoiceSettingTile<int>(
                icon: Icons.timer_outlined,
                title: 'Connection timeout',
                value: s.connectTimeoutSeconds,
                choices: const [(5, '5 seconds'), (10, '10 seconds'), (20, '20 seconds'), (30, '30 seconds')],
                onChanged: (v) => set(ref, (s) => s.copyWith(connectTimeoutSeconds: v)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FilesSettingsPage extends ConsumerWidget with _SettingsAccess {
  const FilesSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    return PageScaffold(
      title: 'Files',
      maxWidth: 760,
      body: PageList(
        children: [
          SettingsSection(
            title: 'Browser',
            children: [
              SwitchSettingTile(
                icon: Icons.visibility_outlined,
                title: 'Show hidden files',
                subtitle: 'Files and folders starting with a dot',
                value: s.filesShowHidden,
                onChanged: (v) => set(ref, (s) => s.copyWith(filesShowHidden: v)),
              ),
              SwitchSettingTile(
                icon: Icons.delete_outline,
                tone: Tone.danger,
                title: 'Confirm before deleting',
                value: s.filesConfirmDelete,
                onChanged: (v) => set(ref, (s) => s.copyWith(filesConfirmDelete: v)),
              ),
            ],
          ),
          const Gap(Insets.lg),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../models/alerts.dart';
import '../../providers/app_providers.dart';
import '../../services/alert_center.dart';
import '../../services/alert_notifications.dart';
import '../../services/background_monitor.dart';
import '../../ui/ui.dart';

class AlertSettingsPage extends ConsumerWidget {
  const AlertSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rules = ref.watch(alertCenterProvider).rules;
    final center = ref.read(alertCenterProvider.notifier);
    final devices = ref.watch(connectionListProvider);
    void set(AlertRules Function(AlertRules r) change) => center.update(change);

    Future<void> enableNotifications(bool on) async {
      if (on && !await AlertNotifications.requestPermission()) {
        if (context.mounted) {
          showToast(context, 'Notifications are blocked for this app in the system settings', tone: Tone.warning);
        }
        return;
      }
      set((r) => r.copyWith(systemNotifications: on));
    }

    Future<void> enable(bool on) async {
      if (on && rules.systemNotifications) await AlertNotifications.requestPermission();
      set((r) => r.copyWith(enabled: on));
    }

    Widget threshold({
      required bool enabled,
      required IconData icon,
      required Tone tone,
      required String title,
      required String subtitle,
      required ValueChanged<bool> onToggle,
      required int value,
      required double min,
      required double max,
      required String Function(double) format,
      required ValueChanged<int> onValue,
    }) {
      return Column(
        children: [
          SwitchSettingTile(
            icon: icon,
            tone: tone,
            title: title,
            subtitle: subtitle,
            value: enabled,
            onChanged: onToggle,
          ),
          if (enabled)
            SliderSettingTile(
              icon: Icons.tune,
              tone: Tone.neutral,
              title: 'Alert from',
              value: value.toDouble().clamp(min, max),
              min: min,
              max: max,
              divisions: (max - min).round(),
              format: format,
              onChanged: (v) => onValue(v.round()),
            ),
        ],
      );
    }

    return PageScaffold(
      title: 'Alerts',
      subtitle: 'Rules and notifications',
      maxWidth: 760,
      body: PageList(
        children: [
          AppCard(
            variant: CardVariant.raised,
            child: Row(
              children: [
                IconBadge(
                  rules.enabled ? Icons.notifications_active : Icons.notifications_off_outlined,
                  tone: rules.enabled ? Tone.success : Tone.neutral,
                  size: 48,
                ),
                const Gap(Insets.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Watch my devices', style: context.tt.titleMedium),
                      const Gap(Insets.xxs),
                      Text(
                        rules.enabled
                            ? 'Checking ${_count(devices.where((d) => rules.monitors(d.id)).length, 'device')} '
                                  'every ${_seconds(rules.foregroundSeconds)} while the app is open'
                                  '${rules.background && BackgroundMonitor.supported ? ' and every ${rules.backgroundMinutes} min in the background' : ''}.'
                            : 'Get told when a device goes offline, overheats, runs out of space or a service fails.',
                        style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const Gap(Insets.sm),
                Switch(value: rules.enabled, onChanged: enable),
              ],
            ),
          ),
          if (rules.enabled) ...[
            SettingsSection(
              title: 'Notifications',
              children: [
                SwitchSettingTile(
                  icon: Icons.notifications_outlined,
                  title: 'System notifications',
                  subtitle: 'Otherwise alerts only show in the app',
                  value: rules.systemNotifications,
                  onChanged: enableNotifications,
                ),
                SwitchSettingTile(
                  icon: Icons.check_circle_outline,
                  tone: Tone.success,
                  title: 'Notify when resolved',
                  subtitle: 'For example when a device is back online',
                  value: rules.notifyResolved,
                  onChanged: (v) => set((r) => r.copyWith(notifyResolved: v)),
                ),
                ActionTile(
                  icon: Icons.send_outlined,
                  tone: Tone.info,
                  title: 'Send a test notification',
                  onTap: () async {
                    if (!await AlertNotifications.requestPermission()) {
                      if (context.mounted) showToast(context, 'Notifications are blocked', tone: Tone.warning);
                      return;
                    }
                    await AlertNotifications.show(
                      AlertEvent(
                        id: 'test',
                        deviceId: 'test',
                        deviceName: 'Test',
                        kind: AlertKind.temperature,
                        severity: AlertSeverity.warning,
                        title: 'Test alert',
                        message: 'Notifications work. Real alerts look like this.',
                        time: DateTime.now(),
                      ),
                    );
                  },
                ),
              ],
            ),
            SettingsSection(
              title: 'Checking',
              footer: BackgroundMonitor.supported
                  ? 'Background monitoring keeps a small notification while it runs. '
                        'Checks use a short SSH login; no agent is needed.'
                  : 'Checks run while the app is open. Each check is a short SSH login; no agent is needed.',
              children: [
                ChoiceSettingTile<int>(
                  icon: Icons.timer_outlined,
                  title: 'While the app is open',
                  value: rules.foregroundSeconds,
                  choices: const [(30, 'Every 30 seconds'), (60, 'Every minute'), (120, 'Every 2 minutes'), (300, 'Every 5 minutes')],
                  onChanged: (v) => set((r) => r.copyWith(foregroundSeconds: v)),
                ),
                if (BackgroundMonitor.supported) ...[
                  SwitchSettingTile(
                    icon: Icons.nightlight_outlined,
                    tone: Tone.info,
                    title: 'Keep watching in the background',
                    subtitle: 'Also when the app is closed',
                    value: rules.background,
                    onChanged: (v) async {
                      if (v) await AlertNotifications.requestPermission();
                      set((r) => r.copyWith(background: v));
                    },
                  ),
                  if (rules.background)
                    ChoiceSettingTile<int>(
                      icon: Icons.schedule,
                      tone: Tone.info,
                      title: 'In the background',
                      value: rules.backgroundMinutes,
                      choices: const [(5, 'Every 5 minutes'), (15, 'Every 15 minutes'), (30, 'Every 30 minutes'), (60, 'Every hour')],
                      onChanged: (v) => set((r) => r.copyWith(backgroundMinutes: v)),
                    ),
                ],
              ],
            ),
            SettingsSection(
              title: 'Rules',
              children: [
                SwitchSettingTile(
                  icon: Icons.cloud_off_outlined,
                  tone: Tone.danger,
                  title: 'Device offline',
                  subtitle: 'SSH does not answer',
                  value: rules.offline,
                  onChanged: (v) => set((r) => r.copyWith(offline: v)),
                ),
                if (rules.offline)
                  ChoiceSettingTile<int>(
                    icon: Icons.tune,
                    tone: Tone.neutral,
                    title: 'Alert after',
                    value: rules.offlineChecks,
                    choices: const [(1, '1 failed check'), (2, '2 failed checks'), (3, '3 failed checks'), (5, '5 failed checks')],
                    onChanged: (v) => set((r) => r.copyWith(offlineChecks: v)),
                  ),
                threshold(
                  enabled: rules.temperature,
                  icon: Icons.thermostat,
                  tone: Tone.danger,
                  title: 'Temperature',
                  subtitle: 'CPU running hot',
                  onToggle: (v) => set((r) => r.copyWith(temperature: v)),
                  value: rules.temperatureC,
                  min: 50,
                  max: 95,
                  format: (v) => '${v.round()} °C',
                  onValue: (v) => set((r) => r.copyWith(temperatureC: v)),
                ),
                threshold(
                  enabled: rules.load,
                  icon: Icons.speed,
                  tone: Tone.warning,
                  title: 'CPU load',
                  subtitle: '1-minute load relative to the number of cores',
                  onToggle: (v) => set((r) => r.copyWith(load: v)),
                  value: rules.loadPercent,
                  min: 50,
                  max: 200,
                  format: (v) => '${v.round()} %',
                  onValue: (v) => set((r) => r.copyWith(loadPercent: v)),
                ),
                threshold(
                  enabled: rules.memory,
                  icon: Icons.memory,
                  tone: Tone.warning,
                  title: 'Memory',
                  subtitle: 'RAM in use',
                  onToggle: (v) => set((r) => r.copyWith(memory: v)),
                  value: rules.memoryPercent,
                  min: 50,
                  max: 99,
                  format: (v) => '${v.round()} %',
                  onValue: (v) => set((r) => r.copyWith(memoryPercent: v)),
                ),
                threshold(
                  enabled: rules.disk,
                  icon: Icons.storage,
                  tone: Tone.warning,
                  title: 'Disk space',
                  subtitle: 'Root file system',
                  onToggle: (v) => set((r) => r.copyWith(disk: v)),
                  value: rules.diskPercent,
                  min: 50,
                  max: 99,
                  format: (v) => '${v.round()} % full',
                  onValue: (v) => set((r) => r.copyWith(diskPercent: v)),
                ),
                SwitchSettingTile(
                  icon: Icons.settings_applications_outlined,
                  tone: Tone.danger,
                  title: 'Failed services',
                  subtitle: 'systemd units in the failed state',
                  value: rules.services,
                  onChanged: (v) => set((r) => r.copyWith(services: v)),
                ),
                SwitchSettingTile(
                  icon: Icons.rocket_launch_outlined,
                  tone: Tone.danger,
                  title: 'Crashed PM2 apps',
                  subtitle: 'Apps PM2 gave up restarting',
                  value: rules.pm2,
                  onChanged: (v) => set((r) => r.copyWith(pm2: v)),
                ),
                SwitchSettingTile(
                  icon: Icons.view_in_ar_outlined,
                  tone: Tone.danger,
                  title: 'Docker containers',
                  subtitle: 'Stopped, restarting or unhealthy (needs Docker access for the SSH user)',
                  value: rules.containers,
                  onChanged: (v) => set((r) => r.copyWith(containers: v)),
                ),
                SwitchSettingTile(
                  icon: Icons.restart_alt,
                  tone: Tone.info,
                  title: 'Reboots',
                  subtitle: 'A device restarted since the last check',
                  value: rules.reboot,
                  onChanged: (v) => set((r) => r.copyWith(reboot: v)),
                ),
              ],
            ),
            SettingsSection(
              title: 'Devices',
              footer: devices.isEmpty ? 'Add a device first.' : 'Turn a device off to stop checking it.',
              children: [
                for (final d in devices)
                  SwitchSettingTile(
                    icon: Icons.developer_board,
                    title: d.name,
                    subtitle: d.address,
                    value: !rules.mutedDevices.contains(d.id),
                    onChanged: (v) => center.setMuted(d.id, !v),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

String _count(int n, String noun) => '$n ${n == 1 ? noun : '${noun}s'}';

String _seconds(int s) => s < 60 ? '$s s' : s % 60 == 0 ? (s == 60 ? 'minute' : '${s ~/ 60} min') : '$s s';

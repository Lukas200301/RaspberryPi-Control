import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../theme/app_theme.dart';
import '../providers/theme_provider.dart';

class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final notifier = ref.read(themeProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance'),
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Theme',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(12),
          // Theme Preset Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: AppThemePreset.values.map((preset) {
              final isSelected = themeState.preset == preset;
              return _ThemeCard(
                preset: preset,
                isSelected: isSelected,
                onTap: () => notifier.setPreset(preset),
              );
            }).toList(),
          ),
          const Gap(32),

          Text(
            'Terminal Palette',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(12),
          _TerminalPreview(preset: themeState.preset),
          const Gap(32),

          Text(
            'About',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.glassDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active: ${themeState.preset.displayName}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Gap(4),
                Text(
                  'Terminal theme is applied automatically when you open the terminal.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Theme Card ───────────────────────────────────────────────────────────────
class _ThemeCard extends StatelessWidget {
  final AppThemePreset preset;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.preset,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? preset.primary : AppTheme.glassBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: preset.primary.withValues(alpha: 0.35),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            children: [
              // Background fill
              Container(color: preset.background),
              // Gradient overlay
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: preset.primary.withValues(alpha: 0.3),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Color swatches
                    Row(
                      children: [
                        _Swatch(color: preset.primary),
                        const Gap(4),
                        _Swatch(color: preset.secondary),
                        const Gap(4),
                        _Swatch(color: preset.accent),
                        if (isSelected) ...[
                          const Spacer(),
                          Icon(
                            Icons.check_circle,
                            color: preset.primary,
                            size: 16,
                          ),
                        ],
                      ],
                    ),
                    const Spacer(),
                    Text(
                      preset.displayName,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      _presetDescription(preset),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _presetDescription(AppThemePreset preset) {
    switch (preset) {
      case AppThemePreset.amoled:
        return 'True dark • Electric';
      case AppThemePreset.nord:
        return 'Arctic • Calm';
      case AppThemePreset.dracula:
        return 'Vampiric • Vivid';
      case AppThemePreset.synthwave:
        return 'Retro • Neon';
    }
  }
}

class _Swatch extends StatelessWidget {
  final Color color;
  const _Swatch({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
    );
  }
}

// ─── Terminal Preview ─────────────────────────────────────────────────────────
class _TerminalPreview extends StatelessWidget {
  final AppThemePreset preset;

  const _TerminalPreview({required this.preset});

  @override
  Widget build(BuildContext context) {
    final theme = preset.terminalTheme;
    final lines = [
      ('pi@raspberrypi', '~', '\$ ', 'ls -la'),
      ('', '', '', ''),
      ('', '', '', 'drwxr-xr-x  pi pi  /home/pi'),
      ('', '', '', '-rw-r--r--  pi pi  .bashrc'),
      ('pi@raspberrypi', '~', '\$ ', 'sudo systemctl status nginx'),
      ('', '', '', '● nginx.service - A high performance web server'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title bar
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: theme.red,
                  shape: BoxShape.circle,
                ),
              ),
              const Gap(6),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: theme.yellow,
                  shape: BoxShape.circle,
                ),
              ),
              const Gap(6),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: theme.green,
                  shape: BoxShape.circle,
                ),
              ),
              const Gap(12),
              Text(
                'terminal',
                style: TextStyle(
                  color: theme.foreground.withValues(alpha: 0.5),
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const Gap(10),
          // Simulated terminal lines
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: line.$1.isNotEmpty
                  ? RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                        ),
                        children: [
                          TextSpan(
                            text: line.$1,
                            style: TextStyle(
                              color: theme.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: ':${line.$2}',
                            style: TextStyle(color: theme.blue),
                          ),
                          TextSpan(
                            text: line.$3,
                            style: TextStyle(color: theme.white),
                          ),
                          TextSpan(
                            text: line.$4,
                            style: TextStyle(color: theme.foreground),
                          ),
                        ],
                      ),
                    )
                  : RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: theme.foreground,
                        ),
                        text: line.$4,
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}

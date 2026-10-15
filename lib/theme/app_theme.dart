import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/app_settings.dart';
import 'tokens.dart';

/// A named seed color the theme is generated from
class ColorPreset {
  final String name;
  final int seed;

  const ColorPreset(this.name, this.seed);
}

class AppTheme {
  static const presets = [
    ColorPreset('Indigo', 0xFF6366F1),
    ColorPreset('Raspberry', 0xFFC51A4A),
    ColorPreset('Ocean', 0xFF0EA5E9),
    ColorPreset('Emerald', 0xFF10B981),
    ColorPreset('Sunset', 0xFFF97316),
    ColorPreset('Grape', 0xFFA855F7),
    ColorPreset('Nord', 0xFF88C0D0),
    ColorPreset('Dracula', 0xFFBD93F9),
    ColorPreset('Synthwave', 0xFFFF2D78),
    ColorPreset('Slate', 0xFF64748B),
  ];

  /// Builds the light or dark theme for the current settings. [dynamicScheme]
  /// is the wallpaper based scheme of Android 12+ when that source is chosen.
  static ThemeData build(
    Brightness brightness,
    AppSettings settings, {
    ColorScheme? dynamicScheme,
  }) {
    final dark = brightness == Brightness.dark;

    var scheme =
        dynamicScheme ??
        ColorScheme.fromSeed(
          seedColor: settings.seed,
          brightness: brightness,
          contrastLevel: settings.contrast,
        );
    if (dark && settings.pureBlack) {
      scheme = scheme.copyWith(
        surface: Colors.black,
        surfaceDim: Colors.black,
        surfaceContainerLowest: Colors.black,
        surfaceContainerLow: const Color(0xFF0D0D10),
        surfaceContainer: const Color(0xFF131317),
        surfaceContainerHigh: const Color(0xFF1A1A1F),
        surfaceContainerHighest: const Color(0xFF222228),
      );
    }

    final base = ThemeData(brightness: brightness, useMaterial3: true);
    final text = _textTheme(GoogleFonts.interTextTheme(base.textTheme), scheme);
    final roundedLarge = RoundedRectangleBorder(borderRadius: BorderRadius.circular(28));

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      canvasColor: scheme.surface,
      textTheme: text,
      visualDensity: settings.compact ? VisualDensity.compact : VisualDensity.standard,
      extensions: [dark ? AppColors.dark(pureBlack: settings.pureBlack) : AppColors.light()],
      pageTransitionsTheme: settings.animations
          ? const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
                TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
                TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
              },
            )
          : const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: _NoTransitionsBuilder(),
                TargetPlatform.iOS: _NoTransitionsBuilder(),
                TargetPlatform.macOS: _NoTransitionsBuilder(),
                TargetPlatform.windows: _NoTransitionsBuilder(),
                TargetPlatform.linux: _NoTransitionsBuilder(),
              },
            ),

      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      ),

      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(borderRadius: Radii.cardAll),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.secondaryContainer,
        elevation: 0,
        height: 72,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => text.labelMedium?.copyWith(
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
            color: states.contains(WidgetState.selected) ? scheme.onSurface : scheme.onSurfaceVariant,
          ),
        ),
      ),

      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surfaceContainer,
        indicatorColor: scheme.secondaryContainer,
        selectedLabelTextStyle: text.labelMedium?.copyWith(fontWeight: FontWeight.w700),
        unselectedLabelTextStyle: text.labelMedium,
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          textStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          elevation: 0,
          textStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          side: BorderSide(color: scheme.outlineVariant),
          textStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
        elevation: 2,
        shape: const RoundedRectangleBorder(borderRadius: Radii.lgAll),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: dark ? 0.6 : 0.8),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: Radii.mdAll,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: Radii.mdAll,
          borderSide: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: Radii.mdAll,
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: Radii.mdAll,
          borderSide: BorderSide(color: scheme.error),
        ),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant.withValues(alpha: 0.7)),
      ),

      chipTheme: ChipThemeData(
        shape: const RoundedRectangleBorder(borderRadius: Radii.smAll),
        side: BorderSide(color: scheme.outlineVariant),
        labelStyle: text.labelLarge,
      ),

      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        shape: const RoundedRectangleBorder(borderRadius: Radii.mdAll),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: roundedLarge,
        titleTextStyle: text.headlineSmall,
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        modalBackgroundColor: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        elevation: 3,
        shape: const RoundedRectangleBorder(borderRadius: Radii.mdAll),
        textStyle: text.bodyLarge,
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(scheme.surfaceContainerHigh),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: const WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: Radii.mdAll)),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(scheme.surfaceContainerHigh),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: Radii.mdAll),
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: text.bodyMedium?.copyWith(color: scheme.onInverseSurface),
        actionTextColor: scheme.inversePrimary,
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(color: scheme.inverseSurface, borderRadius: Radii.smAll),
        textStyle: text.bodySmall?.copyWith(color: scheme.onInverseSurface),
      ),

      dividerTheme: DividerThemeData(color: scheme.outlineVariant.withValues(alpha: 0.6), space: 1),

      tabBarTheme: TabBarThemeData(
        dividerColor: Colors.transparent,
        labelStyle: text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: text.titleSmall,
      ),

      expansionTileTheme: const ExpansionTileThemeData(
        shape: Border(),
        collapsedShape: Border(),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        linearTrackColor: scheme.surfaceContainerHighest,
        circularTrackColor: scheme.surfaceContainerHighest,
      ),

      searchBarTheme: SearchBarThemeData(
        elevation: const WidgetStatePropertyAll(0),
        backgroundColor: WidgetStatePropertyAll(scheme.surfaceContainerHigh),
        shape: const WidgetStatePropertyAll(StadiumBorder()),
      ),
    );
  }

  static TextTheme _textTheme(TextTheme t, ColorScheme scheme) {
    TextStyle? s(TextStyle? style, {FontWeight? weight, double? spacing}) =>
        style?.copyWith(fontWeight: weight, letterSpacing: spacing);
    return t
        .copyWith(
          displayLarge: s(t.displayLarge, weight: FontWeight.w700, spacing: -1.5),
          displayMedium: s(t.displayMedium, weight: FontWeight.w700, spacing: -1),
          displaySmall: s(t.displaySmall, weight: FontWeight.w700, spacing: -0.5),
          headlineLarge: s(t.headlineLarge, weight: FontWeight.w700, spacing: -0.5),
          headlineMedium: s(t.headlineMedium, weight: FontWeight.w700, spacing: -0.25),
          headlineSmall: s(t.headlineSmall, weight: FontWeight.w600),
          titleLarge: s(t.titleLarge, weight: FontWeight.w600),
          titleMedium: s(t.titleMedium, weight: FontWeight.w600),
          titleSmall: s(t.titleSmall, weight: FontWeight.w600),
          labelLarge: s(t.labelLarge, weight: FontWeight.w600),
        )
        .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);
  }

  /// Monospace style for code, logs, paths and terminal output
  static TextStyle mono({double size = 13, Color? color, FontWeight? weight}) =>
      GoogleFonts.jetBrainsMono(fontSize: size, color: color, fontWeight: weight, height: 1.4);
}

class _NoTransitionsBuilder extends PageTransitionsBuilder {
  const _NoTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => child;
}

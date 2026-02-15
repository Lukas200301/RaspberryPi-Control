import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_settings.dart';
import '../theme/app_theme.dart';
import 'app_providers.dart';

// Theme State
class ThemeState {
  final ThemeData themeData;
  final Color primaryColor;
  final Color secondaryColor;

  ThemeState({
    required this.themeData,
    required this.primaryColor,
    required this.secondaryColor,
  });

  ThemeState copyWith({
    ThemeData? themeData,
    Color? primaryColor,
    Color? secondaryColor,
  }) {
    return ThemeState(
      themeData: themeData ?? this.themeData,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
    );
  }
}

class ThemeNotifier extends Notifier<ThemeState> {
  @override
  ThemeState build() {
    final settings = ref.watch(appSettingsProvider);
    
    // Load saved colors or use defaults
    final savedPrimary = settings.primaryColor;
    final savedSecondary = settings.secondaryColor;

    final primaryColor = savedPrimary != null ? Color(savedPrimary) : AppTheme.primaryIndigo;
    final secondaryColor = savedSecondary != null ? Color(savedSecondary) : AppTheme.secondaryTeal;

    return ThemeState(
      themeData: AppTheme.getTheme(
        primary: primaryColor,
        secondary: secondaryColor,
      ),
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
    );
  }

  void updatePrimaryColor(Color color) {
    final settings = ref.read(appSettingsProvider);
    settings.primaryColor = color.value;
    
    state = state.copyWith(
      primaryColor: color,
      themeData: AppTheme.getTheme(
        primary: color,
        secondary: state.secondaryColor,
      ),
    );
  }

  void updateSecondaryColor(Color color) {
    final settings = ref.read(appSettingsProvider);
    settings.secondaryColor = color.value;
    
    state = state.copyWith(
      secondaryColor: color,
      themeData: AppTheme.getTheme(
        primary: state.primaryColor,
        secondary: color,
      ),
    );
  }
  
  void resetTheme() {
    final settings = ref.read(appSettingsProvider);
    settings.primaryColor = null;
    settings.secondaryColor = null;
    
    const defaultPrimary = AppTheme.primaryIndigo;
    const defaultSecondary = AppTheme.secondaryTeal;

    state = state.copyWith(
      primaryColor: defaultPrimary,
      secondaryColor: defaultSecondary,
      themeData: AppTheme.getTheme(
        primary: defaultPrimary,
        secondary: defaultSecondary,
      ),
    );
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeState>(ThemeNotifier.new);

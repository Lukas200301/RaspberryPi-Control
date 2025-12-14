import 'package:flutter/material.dart';

/// v3.0 Color Palette - Modern Glassmorphism Design System
/// Deep Slate backgrounds with Electric Indigo/Teal accents
class AppColors {
  // ===== BACKGROUND COLORS - AMOLED Black =====

  // Dark Mode - Primary
  static const darkGradientStart = Color(0xFF000000); // AMOLED Black
  static const darkGradientEnd = Color(0xFF000000);   // AMOLED Black
  static const darkGlass = Color(0xFF0A0A0A);         // Very dark gray for glass

  // Light Mode
  static const lightGradientStart = Color(0xFFF1F5F9); // Slate 100
  static const lightGradientEnd = Color(0xFFE2E8F0);   // Slate 200
  static const lightGlass = Color(0xFFFFFFFF);

  // ===== PRIMARY ACCENTS - Blue for buttons, Indigo/Teal for dashboard =====

  static const accentIndigo = Color(0xFF6366F1);  // Electric Indigo - Dashboard widgets
  static const accentTeal = Color(0xFF14B8A6);    // Teal - Dashboard widgets
  static const accentCyan = Color(0xFF06B6D4);    // Cyan
  static const accentPurple = Color(0xFF8B5CF6);  // Purple
  static const accentBlue = Color(0xFF2196F3);    // Material Blue - Buttons/Navigation

  // ===== STATUS COLORS =====

  static const success = Color(0xFF10B981);    // Emerald
  static const warning = Color(0xFFF59E0B);    // Amber
  static const error = Color(0xFFEF4444);      // Red
  static const info = Color(0xFF06B6D4);       // Cyan

  // ===== TEXT COLORS =====

  // Dark Mode
  static const textPrimary = Color(0xFFFFFFFF);      // Pure White
  static const textSecondary = Color(0xFF94A3B8);    // Cool Grey
  static const textTertiary = Color(0xFF64748B);     // Slate 500

  // Light Mode
  static const lightTextPrimary = Color(0xFF0F172A);
  static const lightTextSecondary = Color(0xFF475569);
  static const lightTextTertiary = Color(0xFF94A3B8);

  // ===== GLASS MORPHISM SPECIFIC =====

  // Dark Mode Glass Effects
  // Using Color.fromRGBO to avoid color banding
  static Color glassDark({double opacity = 0.1}) {
    return Color.fromRGBO(255, 255, 255, opacity);
  }

  static Color glassBorderDark({double opacity = 0.15}) {
    return Color.fromRGBO(255, 255, 255, opacity);
  }

  static Color glassBackdropDark({double opacity = 0.05}) {
    return Color.fromRGBO(10, 10, 10, opacity);
  }

  // Light Mode Glass Effects
  static Color glassLight({double opacity = 0.6}) {
    return Color.fromRGBO(255, 255, 255, opacity);
  }

  static Color glassBorderLight({double opacity = 0.2}) {
    return Color.fromRGBO(0, 0, 0, opacity);
  }

  // ===== ADAPTIVE COLORS =====

  /// Returns appropriate glass background color based on brightness
  static Color glassBackground(Brightness brightness, {double opacity = 0.1}) {
    return brightness == Brightness.dark
        ? glassDark(opacity: opacity)
        : glassLight(opacity: opacity);
  }

  /// Returns appropriate glass border color based on brightness
  static Color glassBorder(Brightness brightness, {double opacity = 0.15}) {
    return brightness == Brightness.dark
        ? glassBorderDark(opacity: opacity)
        : glassBorderLight(opacity: opacity);
  }

  /// Returns appropriate text color based on brightness
  static Color textColor(Brightness brightness, {bool secondary = false}) {
    if (brightness == Brightness.dark) {
      return secondary ? textSecondary : textPrimary;
    } else {
      return secondary ? lightTextSecondary : lightTextPrimary;
    }
  }

  // ===== GRADIENT UTILITIES =====

  /// Dark mode background gradient - Deep Slate
  static const LinearGradient darkBackgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkGradientStart, darkGradientEnd],
  );

  /// Light mode background gradient
  static const LinearGradient lightBackgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lightGradientStart, lightGradientEnd],
  );

  /// Glass overlay gradient (dark mode) - Subtle white overlay
  /// Using Color.fromRGBO to avoid color banding
  static const LinearGradient glassGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color.fromRGBO(255, 255, 255, 0.1),
      Color.fromRGBO(255, 255, 255, 0.05),
    ],
  );

  /// Glass overlay gradient (light mode)
  /// Using Color.fromRGBO to avoid color banding
  static const LinearGradient glassGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color.fromRGBO(255, 255, 255, 0.7),
      Color.fromRGBO(255, 255, 255, 0.4),
    ],
  );

  // ===== CONNECTION STATUS COLORS =====

  static const connectedGreen = Color(0xFF10B981);
  static const disconnectedRed = Color(0xFFEF4444);
  static const connectingOrange = Color(0xFFF59E0B);

  // ===== SYSTEM STATUS COLORS =====

  // CPU/System states
  static const cpuNormal = Color(0xFF14B8A6);     // Teal
  static const cpuWarning = Color(0xFFF59E0B);    // Amber
  static const cpuCritical = Color(0xFFEF4444);   // Red

  // Temperature
  static const tempCool = Color(0xFF14B8A6);      // Teal
  static const tempWarm = Color(0xFFF59E0B);      // Amber
  static const tempHot = Color(0xFFEF4444);       // Red

  // Disk Usage
  static const diskHealthy = Color(0xFF10B981);
  static const diskWarning = Color(0xFFF59E0B);
  static const diskCritical = Color(0xFFEF4444);

  // ===== SERVICE STATUS COLORS =====

  static const serviceRunning = Color(0xFF10B981);
  static const serviceStopped = Color(0xFFEF4444);
  static const serviceStarting = Color(0xFFF59E0B);

  // ===== CHART COLORS - Vibrant palette for data visualization =====

  // CPU Chart
  static const cpuUser = Color(0xFF6366F1);       // Indigo
  static const cpuSystem = Color(0xFFEF4444);     // Red
  static const cpuNice = Color(0xFF14B8A6);       // Teal
  static const cpuIoWait = Color(0xFFF59E0B);     // Amber
  static const cpuIrq = Color(0xFF8B5CF6);        // Purple

  // Memory Chart
  static const memoryUsed = Color(0xFF14B8A6);    // Teal
  static const memoryFree = Color(0xFF64748B);    // Slate

  // Network Chart
  static const networkIn = Color(0xFF10B981);     // Green (Download)
  static const networkOut = Color(0xFF6366F1);    // Indigo (Upload)

  // ===== ACCENT GRADIENTS =====

  /// Indigo gradient for primary actions
  static const LinearGradient indigoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
  );

  /// Teal gradient for secondary actions
  static const LinearGradient tealGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF14B8A6), Color(0xFF06B6D4)],
  );

  // ===== MATERIAL COLOR SCHEME HELPERS =====

  /// Generate dark ColorScheme for Material 3 - AMOLED Black theme with Blue accents
  static ColorScheme darkColorScheme = ColorScheme.dark(
    primary: accentBlue, // Blue for buttons and primary actions
    secondary: accentTeal,
    tertiary: accentPurple,
    surface: darkGlass,
    surfaceContainerHighest: Color(0xFF1E293B),
    error: error,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: textPrimary,
    onError: Colors.white,
    brightness: Brightness.dark,
  );

  /// Generate light ColorScheme for Material 3
  static ColorScheme lightColorScheme = ColorScheme.light(
    primary: accentBlue, // Blue for buttons and primary actions
    secondary: accentTeal,
    tertiary: accentPurple,
    surface: lightGlass,
    surfaceContainerHighest: Color(0xFFF1F5F9),
    error: error,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: lightTextPrimary,
    onError: Colors.white,
    brightness: Brightness.light,
  );

  // ===== SHADOWS & GLOWS =====

  /// Glow effect for active elements
  /// Using Color.fromRGBO to avoid color banding
  static BoxShadow indigoGlow({double blur = 20.0, double opacity = 0.5}) {
    return BoxShadow(
      color: Color.fromRGBO(99, 102, 241, opacity), // accentIndigo with opacity
      blurRadius: blur,
      spreadRadius: 0,
      offset: const Offset(0, 0),
    );
  }

  static BoxShadow tealGlow({double blur = 20.0, double opacity = 0.5}) {
    return BoxShadow(
      color: Color.fromRGBO(20, 184, 166, opacity), // accentTeal with opacity
      blurRadius: blur,
      spreadRadius: 0,
      offset: const Offset(0, 0),
    );
  }

  static BoxShadow cyanGlow({double blur = 20.0, double opacity = 0.5}) {
    return BoxShadow(
      color: Color.fromRGBO(6, 182, 212, opacity), // accentCyan with opacity
      blurRadius: blur,
      spreadRadius: 0,
      offset: const Offset(0, 0),
    );
  }

  static BoxShadow purpleGlow({double blur = 20.0, double opacity = 0.5}) {
    return BoxShadow(
      color: Color.fromRGBO(139, 92, 246, opacity), // accentPurple with opacity
      blurRadius: blur,
      spreadRadius: 0,
      offset: const Offset(0, 0),
    );
  }

  /// Soft shadow for glass cards
  static BoxShadow glassShadow({bool dark = true}) {
    return BoxShadow(
      color: dark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.1),
      blurRadius: 30,
      spreadRadius: 0,
      offset: const Offset(0, 10),
    );
  }
}

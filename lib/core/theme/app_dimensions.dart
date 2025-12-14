/// v3.0 Spacing & Dimension System
class AppDimensions {
  // ===== SPACING SCALE =====

  static const double spaceXS = 4.0;
  static const double spaceSM = 8.0;
  static const double spaceMD = 16.0;
  static const double spaceLG = 24.0;
  static const double spaceXL = 32.0;
  static const double spaceXXL = 48.0;

  // ===== BORDER RADIUS - Generous rounded corners =====

  // Glass components
  static const double radiusXS = 8.0;
  static const double radiusSM = 12.0;
  static const double radiusMD = 16.0;
  static const double radiusLG = 20.0;
  static const double radiusXL = 24.0;
  static const double radiusXXL = 32.0;

  // Specific components
  static const double radiusButton = 16.0;     // Generous
  static const double radiusCard = 20.0;       // Generous
  static const double radiusBottomNav = 24.0;
  static const double radiusDialog = 24.0;     // Generous
  static const double radiusChip = 16.0;
  static const double radiusInput = 16.0;      // New - for inputs

  // ===== GLASS EFFECTS =====

  // Blur intensity (sigma values)
  static const double blurNone = 0.0;
  static const double blurLow = 5.0;
  static const double blurMedium = 10.0;
  static const double blurHigh = 15.0;

  // Glass opacity
  static const double opacityGlassDark = 0.15;
  static const double opacityGlassLight = 0.4;
  static const double opacityGlassBorder = 0.2;

  // ===== ELEVATION/SHADOW =====

  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;
  static const double elevationXHigh = 12.0;

  // ===== ICON SIZES =====

  static const double iconXS = 16.0;
  static const double iconSM = 20.0;
  static const double iconMD = 24.0;
  static const double iconLG = 32.0;
  static const double iconXL = 48.0;
  static const double iconXXL = 64.0;

  // ===== BUTTON DIMENSIONS =====

  static const double buttonHeightSmall = 36.0;
  static const double buttonHeightMedium = 48.0;
  static const double buttonHeightLarge = 56.0;

  static const double buttonPaddingHorizontal = 24.0;
  static const double buttonPaddingVertical = 12.0;

  // ===== CARD DIMENSIONS =====

  static const double cardPadding = 16.0;
  static const double cardMargin = 8.0;

  // Dashboard widgets
  static const double dashboardCardMinHeight = 120.0;
  static const double dashboardCardMaxHeight = 400.0;

  // ===== APP BAR =====

  static const double appBarHeight = 56.0;
  static const double appBarElevation = 0.0; // Flat with glass effect

  // ===== BOTTOM NAVIGATION =====

  static const double bottomNavHeight = 70.0;
  static const double bottomNavMargin = 16.0;
  static const double bottomNavIconSize = 28.0;

  // ===== DIALOG DIMENSIONS =====

  static const double dialogMaxWidth = 400.0;
  static const double dialogPadding = 24.0;

  // ===== CHART DIMENSIONS =====

  static const double chartHeightSmall = 120.0;
  static const double chartHeightMedium = 200.0;
  static const double chartHeightLarge = 300.0;

  // Gauge dimensions
  static const double gaugeRadiusSmall = 60.0;
  static const double gaugeRadiusMedium = 80.0;
  static const double gaugeRadiusLarge = 120.0;

  // ===== BORDER WIDTHS =====

  static const double borderThin = 1.0;
  static const double borderMedium = 1.5;
  static const double borderThick = 2.0;

  // ===== RESPONSIVE BREAKPOINTS =====

  static const double breakpointMobile = 600.0;
  static const double breakpointTablet = 900.0;
  static const double breakpointDesktop = 1200.0;

  // ===== ADAPTIVE HELPERS =====

  /// Check if screen is mobile size
  static bool isMobile(double width) => width < breakpointMobile;

  /// Check if screen is tablet size
  static bool isTablet(double width) =>
      width >= breakpointMobile && width < breakpointDesktop;

  /// Check if screen is desktop size
  static bool isDesktop(double width) => width >= breakpointDesktop;

  /// Get adaptive padding based on screen width
  static double adaptivePadding(double width) {
    if (isDesktop(width)) return spaceXL;
    if (isTablet(width)) return spaceLG;
    return spaceMD;
  }

  /// Get adaptive card width based on screen width
  static double adaptiveCardWidth(double screenWidth) {
    if (isDesktop(screenWidth)) return screenWidth * 0.3;
    if (isTablet(screenWidth)) return screenWidth * 0.45;
    return screenWidth - (spaceMD * 2);
  }
}

import 'package:flutter/material.dart';

/// Semantic, context-aware color tokens adapting dynamically between Light & Dark themes.
class AppThemeColors {
  final Brightness brightness;
  final Color scaffoldBg;
  final Color cardBg;
  final Color surface;
  final Color surfaceHigh;
  final Color surfaceHighest;
  final Color textPrimary;
  final Color textMuted;
  final Color textSecondary;
  final Color textTertiary;
  final Color border;
  final Color borderSubtle;
  final Color borderStrong;
  final Color primaryAccent;
  final Color onPrimary;
  final Color accentGold;
  final Color successJade;
  final Color coralRed;

  const AppThemeColors._({
    required this.brightness,
    required this.scaffoldBg,
    required this.cardBg,
    required this.surface,
    required this.surfaceHigh,
    required this.surfaceHighest,
    required this.textPrimary,
    required this.textMuted,
    required this.textSecondary,
    required this.textTertiary,
    required this.border,
    required this.borderSubtle,
    required this.borderStrong,
    required this.primaryAccent,
    required this.onPrimary,
    required this.accentGold,
    required this.successJade,
    required this.coralRed,
  });

  bool get isDark => brightness == Brightness.dark;

  /// Dark Mode Palette
  static const dark = AppThemeColors._(
    brightness: Brightness.dark,
    scaffoldBg: Color(0xFF0C131F),
    cardBg: Color(0xFF171F2B),
    surface: Color(0xFF232A37),
    surfaceHigh: Color(0xFF232A37),
    surfaceHighest: Color(0xFF2E3542),
    textPrimary: Color(0xFFF1F5FA),
    textMuted: Color(0xFF8B949E),
    textSecondary: Color(0xFF8B949E),
    textTertiary: Color(0xFF5A6E85),
    border: Color(0xFF34465B),
    borderSubtle: Color(0xFF34465B),
    borderStrong: Color(0xFF4B6079),
    primaryAccent: Color(0xFFFFB800),
    onPrimary: Color(0xFF0C131F),
    accentGold: Color(0xFFFFB800),
    successJade: Color(0xFF5CC7A0),
    coralRed: Color(0xFFF87171),
  );

  /// Light Mode Palette
  static const light = AppThemeColors._(
    brightness: Brightness.light,
    scaffoldBg: Color(0xFFF6F8FA),
    cardBg: Color(0xFFFFFFFF),
    surface: Color(0xFFF0F4F8),
    surfaceHigh: Color(0xFFF0F4F8),
    surfaceHighest: Color(0xFFE2E8F0),
    textPrimary: Color(0xFF1F2328),
    textMuted: Color(0xFF656D76),
    textSecondary: Color(0xFF656D76),
    textTertiary: Color(0xFF8C959F),
    border: Color(0xFFD0D7DE),
    borderSubtle: Color(0xFFD0D7DE),
    borderStrong: Color(0xFFAFB8C1),
    primaryAccent: Color(0xFFFFB800),
    onPrimary: Color(0xFF0C131F),
    accentGold: Color(0xFFFFB800),
    successJade: Color(0xFF16A34A),
    coralRed: Color(0xFFDC2626),
  );

  /// Aliases for smooth migration & semantic consistency
  Color get primaryBackground => scaffoldBg;
  Color get cardBackground => cardBg;
  Color get elevatedSurface => surfaceHigh;
  Color get surfaceContainerLowest => scaffoldBg;
  Color get surfaceContainerLow => surface;
  Color get surfaceContainer => cardBg;
  Color get surfaceContainerHigh => surfaceHigh;
  Color get surfaceContainerHighest => surfaceHighest;
  Color get surfaceBright => surfaceHighest;
  Color get primaryText => textPrimary;
  Color get secondaryText => textSecondary;
  Color get tertiaryText => textTertiary;
  Color get mutedBorder => borderSubtle;
  Color get outlineVariant => borderSubtle;
  Color get outline => border;
  Color get premiumBlue => primaryAccent;
  Color get gold => accentGold;
  Color get alpineJade => successJade;
  Color get premiumGreen => successJade;
  Color get successGreen => successJade;
  Color get errorRed => coralRed;

  /// Dynamic resolver looking up active Theme brightness from context
  static AppThemeColors of(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? dark : light;
  }
}

/// Backward-compatible palette with static Dark constants and dynamic lookup
class AppColors {
  AppColors._();

  /// Dynamic Theme resolver
  static AppThemeColors of(BuildContext context) => AppThemeColors.of(context);

  // Core background and surface colors (Tonal Surface Engineering)
  static const Color primaryBackground = Color(0xFF0C131F); // Canvas Base (#0c131f)
  static const Color cardBackground = Color(0xFF19202C);    // Surface Layer 1 / Container (#19202c)
  static const Color elevatedSurface = Color(0xFF232A37);   // Surface Container High (#232a37)

  // Calibrated Stitch Tonal Surfaces
  static const Color surfaceContainerLowest = Color(0xFF070E1A);
  static const Color surfaceContainerLow = Color(0xFF151C28);
  static const Color surfaceContainer = Color(0xFF19202C);
  static const Color surfaceContainerHigh = Color(0xFF232A37);
  static const Color surfaceContainerHighest = Color(0xFF2E3542);
  static const Color surfaceBright = Color(0xFF323947);

  // Typography and content contrast tokens
  static const Color primaryText = Color(0xFFF1F5FA);       // Optical-grade frosty white
  static const Color secondaryText = Color(0xFFA9B7C9);     // Low-strain mist blue-grey
  static const Color tertiaryText = Color(0xFF5A6E85);      // Inactive / disabled / placeholder
  static const Color onSurface = Color(0xFFDCE2F4);
  static const Color onSurfaceVariant = Color(0xFFC0C7D0);

  // Structural hairline borders
  static const Color mutedBorder = Color(0xFF34465B);       // Cold-steel hairline containment
  static const Color outlineVariant = Color(0xFF40474F);
  static const Color outline = Color(0xFF8A919A);

  // Primary Accent: Vibrant Swiss Taxi Gold
  static const Color premiumBlue = Color(0xFFFFB800);
  static const Color primaryFixed = Color(0xFFFFE082);
  static const Color primaryLight = Color(0xFFFFD54F);
  static const Color onPrimary = Color(0xFF0C131F);

  // Secondary Accent: Swiss Gold (Prestige, Thresholds & Milestones)
  static const Color accentGold = Color(0xFFFFB800);        // Vibrant Swiss Taxi Gold
  static const Color gold = Color(0xFFFFB800);
  static const Color goldLight = Color(0xFFFFCC33);
  static const Color goldDark = Color(0xFFD99B00);
  static const Color onGold = Color(0xFF0C131F);

  // Tertiary Accent: Alpine Jade (Success, Pass Marks & Verification)
  static const Color premiumGreen = Color(0xFF5CC7A0);     // Alpine Jade
  static const Color successGreen = Color(0xFF5CC7A0);
  static const Color alpineJade = Color(0xFF5CC7A0);
  static const Color jadeLight = Color(0xFF78E2BA);
  static const Color onJade = Color(0xFF003828);

  // Critical / Error Alert: Coral Red
  static const Color errorRed = Color(0xFFF87171);          // Controlled coral crimson
  static const Color coralRed = Color(0xFFF87171);
  static const Color errorContainer = Color(0xFF93000A);
}

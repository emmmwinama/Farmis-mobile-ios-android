import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class FarmioColors {
  // Brand — indigo, a bolder/more distinctive anchor than the old sky-blue.
  static const primary      = Color(0xFF4F46E5); // indigo-600
  static const primaryDark  = Color(0xFF1E1B4B); // indigo-950
  static const primaryLight = Color(0xFFC7D2FE); // indigo-200
  static const primaryBg    = Color(0xFFEEF2FF); // indigo-50
  static const cyan         = Color(0xFF06B6D4);

  // Semantic — emerald/amber/blue/violet each now hold a distinct hue instead
  // of overlapping with primary or each other.
  static const success     = Color(0xFF10B981); // emerald-500
  static const successBg   = Color(0xFFECFDF5);
  static const danger      = Color(0xFFDC2626); // red-600
  static const dangerBg    = Color(0xFFFEF2F2);
  static const warning     = Color(0xFFF59E0B); // amber-500
  static const warningBg   = Color(0xFFFFFBEB);
  static const info        = Color(0xFF3B82F6); // blue-500
  static const infoBg      = Color(0xFFEFF6FF);
  static const purple      = Color(0xFF8B5CF6); // violet-500
  static const purpleBg    = Color(0xFFF5F3FF);

  // Neutrals
  static const ink      = Color(0xFF0B1220);
  static const slate900 = Color(0xFF0F172A);
  static const slate800 = Color(0xFF1E293B);
  static const slate700 = Color(0xFF334155);
  static const slate600 = Color(0xFF475569);
  static const slate500 = Color(0xFF64748B);
  static const slate400 = Color(0xFF94A3B8);
  static const slate300 = Color(0xFFCBD5E1);
  static const slate200 = Color(0xFFE2E8F0);
  static const slate100 = Color(0xFFF1F5F9);
  static const slate50  = Color(0xFFF8FAFC);

  // Surfaces (light)
  static const background  = Color(0xFFF8FAFC);
  static const surface     = Colors.white;
  static const border      = slate200;
  static const softBorder  = Color(0xFFE6ECF2);

  // Text (light)
  static const textPrimary = slate900;
  static const textSecond  = slate600;
  static const textMuted   = slate400;

  // Dark mode — indigo-tinted near-black instead of neutral gray, so dark
  // surfaces carry the brand hue (the Linear/Vercel-style dark-mode signature).
  static const darkBg      = Color(0xFF0A0A17);
  static const darkSurface = Color(0xFF13131F);
  static const darkCard    = Color(0xFF1C1C2B);
  static const darkBorder  = Color(0xFF2E2E42);
  static const darkTextPrimary = Colors.white;
  static const darkTextSecond  = Color(0xFFB4B4C9);
  static const darkTextMuted   = Color(0xFF7C7C93);
}

/// Surface/text tokens that legitimately invert between light and dark mode.
/// Brand/semantic colors (primary, success, danger, warning, info) deliberately
/// stay as static [FarmioColors] constants — their hue doesn't flip with
/// brightness in this design. Read via `context.colors` rather than the
/// static [FarmioColors] surface/text fields wherever a widget needs to
/// respond to dark mode.
class FarmioColorsExt extends ThemeExtension<FarmioColorsExt> {
  final Color background;
  final Color surface;
  final Color border;
  final Color softBorder;
  final Color textPrimary;
  final Color textSecond;
  final Color textMuted;

  const FarmioColorsExt({
    required this.background,
    required this.surface,
    required this.border,
    required this.softBorder,
    required this.textPrimary,
    required this.textSecond,
    required this.textMuted,
  });

  static const light = FarmioColorsExt(
    background: FarmioColors.background,
    surface:    FarmioColors.surface,
    border:     FarmioColors.border,
    softBorder: FarmioColors.softBorder,
    textPrimary: FarmioColors.textPrimary,
    textSecond:  FarmioColors.textSecond,
    textMuted:   FarmioColors.textMuted,
  );

  static const dark = FarmioColorsExt(
    background: FarmioColors.darkBg,
    surface:    FarmioColors.darkCard,
    border:     FarmioColors.darkBorder,
    softBorder: FarmioColors.darkBorder,
    textPrimary: FarmioColors.darkTextPrimary,
    textSecond:  FarmioColors.darkTextSecond,
    textMuted:   FarmioColors.darkTextMuted,
  );

  @override
  FarmioColorsExt copyWith({
    Color? background,
    Color? surface,
    Color? border,
    Color? softBorder,
    Color? textPrimary,
    Color? textSecond,
    Color? textMuted,
  }) {
    return FarmioColorsExt(
      background:  background ?? this.background,
      surface:     surface ?? this.surface,
      border:      border ?? this.border,
      softBorder:  softBorder ?? this.softBorder,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecond:  textSecond ?? this.textSecond,
      textMuted:   textMuted ?? this.textMuted,
    );
  }

  @override
  FarmioColorsExt lerp(ThemeExtension<FarmioColorsExt>? other, double t) {
    if (other is! FarmioColorsExt) return this;
    return FarmioColorsExt(
      background:  Color.lerp(background, other.background, t)!,
      surface:     Color.lerp(surface, other.surface, t)!,
      border:      Color.lerp(border, other.border, t)!,
      softBorder:  Color.lerp(softBorder, other.softBorder, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecond:  Color.lerp(textSecond, other.textSecond, t)!,
      textMuted:   Color.lerp(textMuted, other.textMuted, t)!,
    );
  }
}

/// Derives a darker/lighter shade of a brand/semantic color for gradients
/// without hardcoding a second hex value per stat/action tile — the pattern
/// several screens (dashboard's stat cards, quick actions) used to repeat
/// with one-off hex pairs that drifted from the formal palette.
extension FarmioShade on Color {
  Color darken([double amount = 0.18]) => Color.lerp(this, Colors.black, amount)!;
  Color lighten([double amount = 0.18]) => Color.lerp(this, Colors.white, amount)!;
}

extension FarmioThemeContext on BuildContext {
  /// Dark-aware surface/text tokens. Falls back to the light palette if no
  /// extension is registered (e.g. in a widget test with a bare [ThemeData]).
  FarmioColorsExt get colors =>
      Theme.of(this).extension<FarmioColorsExt>() ?? FarmioColorsExt.light;

  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}

/// Fill for a hero/accent surface (dashboard header, weather/credit-score
/// cards, stat badges, ...) — a multi-stop gradient in light mode, this
/// app's original bold-SaaS signature, flattened to a single solid color in
/// dark mode instead. Layered gradients read as muddy against dark
/// surfaces; a single saturated fill reads as a deliberate, professional
/// accent instead. Spread the result into a [BoxDecoration]'s `color` and
/// `gradient` fields — exactly one of the two is ever non-null.
class HeroFill {
  final Gradient? gradient;
  final Color? color;
  const HeroFill._({this.gradient, this.color});

  factory HeroFill(
    BuildContext context, {
    required List<Color> colors,
    required Color flat,
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    if (context.isDark) return HeroFill._(color: flat);
    return HeroFill._(gradient: LinearGradient(colors: colors, begin: begin, end: end));
  }
}

/// Colored "glow" shadows under primary CTAs/hero surfaces — a bold-SaaS
/// signature detail that a plain neutral drop shadow doesn't give you.
class AppShadows {
  static List<BoxShadow> glow(Color color,
      {double alpha = 0.32, double blur = 20, Offset offset = const Offset(0, 10)}) {
    return [
      BoxShadow(color: color.withValues(alpha: alpha), blurRadius: blur, offset: offset),
    ];
  }
}

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3:    true,
      brightness:      Brightness.light,
      colorScheme:     ColorScheme.fromSeed(
        seedColor:  FarmioColors.primary,
        brightness: Brightness.light,
        primary:    FarmioColors.primary,
        surface:    FarmioColors.surface,
      ),
      scaffoldBackgroundColor: const Color(0xFFF6F6FB),
      extensions: const [FarmioColorsExt.light],
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 34, fontWeight: FontWeight.w900,
          color: FarmioColors.textPrimary, letterSpacing: -1.2,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 24, fontWeight: FontWeight.w800,
          color: FarmioColors.textPrimary, letterSpacing: -0.5,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 20, fontWeight: FontWeight.w800,
          color: FarmioColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 17, fontWeight: FontWeight.w700,
          color: FarmioColors.textPrimary,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 15, fontWeight: FontWeight.w700,
          color: FarmioColors.textPrimary,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w600,
          color: FarmioColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 15, fontWeight: FontWeight.w400,
          color: FarmioColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 13, fontWeight: FontWeight.w400,
          color: FarmioColors.textSecond,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w400,
          color: FarmioColors.textMuted,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w700,
          color: FarmioColors.textPrimary,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 10, fontWeight: FontWeight.w600,
          color: FarmioColors.textMuted,
          letterSpacing: 0.6,
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor:  Colors.white.withValues(alpha: 0.76),
        foregroundColor:  FarmioColors.textPrimary,
        elevation:        0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle:      false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.inter(
          fontSize:   20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
          color:      FarmioColors.textPrimary,
        ),
        iconTheme: const IconThemeData(
          color: FarmioColors.textPrimary,
          size:  22,
        ),
        shape: Border(
          bottom: BorderSide(
            color: FarmioColors.softBorder.withValues(alpha: 0.72),
            width: 0.5,
          ),
        ),
      ),

      cardTheme: CardThemeData(
        color:       Colors.white.withValues(alpha: 0.9),
        elevation:   0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
              color: FarmioColors.softBorder.withValues(alpha: 0.7), width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: FarmioColors.primary,
          foregroundColor: Colors.white,
          elevation:       0,
          shadowColor:     Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: 24, vertical: 15),
          textStyle: GoogleFonts.inter(
            fontSize:   14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: FarmioColors.primary,
          side: const BorderSide(
              color: FarmioColors.border, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: 24, vertical: 15),
          textStyle: GoogleFonts.inter(
            fontSize:   14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: FarmioColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.inter(
            fontSize:   13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled:    true,
        fillColor: FarmioColors.slate50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
              color: FarmioColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
              color: FarmioColors.danger, width: 1.4),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
              color: FarmioColors.danger, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 18, vertical: 15),
        // textSecond (not textMuted) — textMuted on slate50 fill computes to
        // ~2.6:1 contrast, below WCAG AA's 4.5:1 minimum for form text.
        hintStyle: GoogleFonts.inter(
          color: FarmioColors.textSecond, fontSize: 14,
        ),
        labelStyle: GoogleFonts.inter(
          color: FarmioColors.textSecond, fontSize: 14,
        ),
        floatingLabelStyle: GoogleFonts.inter(
          color: FarmioColors.primary, fontSize: 13, fontWeight: FontWeight.w600,
        ),
      ),

      dividerTheme: const DividerThemeData(
        color:     FarmioColors.border,
        thickness: 1,
        space:     1,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: FarmioColors.slate50,
        labelStyle:      GoogleFonts.inter(
          fontSize:   12,
          fontWeight: FontWeight.w700,
          color:      FarmioColors.textSecond,
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 6),
        shape: const StadiumBorder(),
        side: BorderSide.none,
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: FarmioColors.primary,
        foregroundColor: Colors.white,
        elevation:       4,
        highlightElevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor:     Colors.transparent,
        indicatorColor:      Colors.white.withValues(alpha: 0.14),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
              fontSize:   11,
              fontWeight: FontWeight.w700,
              color:      FarmioColors.primary,
            );
          }
          return GoogleFonts.inter(
            fontSize:   11,
            fontWeight: FontWeight.w500,
            color:      FarmioColors.textMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
                color: FarmioColors.primary, size: 22);
          }
          return const IconThemeData(
              color: FarmioColors.textMuted, size: 22);
        }),
      ),

      listTileTheme: ListTileThemeData(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: FarmioColors.slate800,
        contentTextStyle: GoogleFonts.inter(
          color: Colors.white, fontSize: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: FarmioColors.surface,
        elevation:       0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: GoogleFonts.inter(
          fontSize:   17,
          fontWeight: FontWeight.w700,
          color:      FarmioColors.textPrimary,
        ),
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          color:    FarmioColors.textSecond,
        ),
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness:   Brightness.dark,
      colorScheme:  ColorScheme.fromSeed(
        seedColor:  FarmioColors.primary,
        brightness: Brightness.dark,
        primary:    FarmioColors.primaryLight,
        surface:    FarmioColors.darkSurface,
      ),
      scaffoldBackgroundColor: FarmioColors.darkBg,
      extensions: const [FarmioColorsExt.dark],
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 34, fontWeight: FontWeight.w900,
          color: FarmioColors.darkTextPrimary, letterSpacing: -1.2,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 24, fontWeight: FontWeight.w800,
          color: FarmioColors.darkTextPrimary, letterSpacing: -0.5,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 20, fontWeight: FontWeight.w800,
          color: FarmioColors.darkTextPrimary,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 17, fontWeight: FontWeight.w700,
          color: FarmioColors.darkTextPrimary,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 15, fontWeight: FontWeight.w700,
          color: FarmioColors.darkTextPrimary,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w600,
          color: FarmioColors.darkTextPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 15, fontWeight: FontWeight.w400,
          color: FarmioColors.darkTextPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 13, fontWeight: FontWeight.w400,
          color: FarmioColors.darkTextSecond,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w400,
          color: FarmioColors.darkTextMuted,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w700,
          color: FarmioColors.darkTextPrimary,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 10, fontWeight: FontWeight.w600,
          color: FarmioColors.darkTextMuted,
          letterSpacing: 0.6,
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor:  FarmioColors.darkSurface.withValues(alpha: 0.9),
        foregroundColor:  FarmioColors.darkTextPrimary,
        elevation:        0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle:      false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.inter(
          fontSize:   20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
          color:      FarmioColors.darkTextPrimary,
        ),
        iconTheme: const IconThemeData(
          color: FarmioColors.darkTextPrimary,
          size:  22,
        ),
        shape: Border(
          bottom: BorderSide(color: FarmioColors.darkBorder, width: 0.5),
        ),
      ),

      cardTheme: CardThemeData(
        color:     FarmioColors.darkCard,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape:     RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: FarmioColors.darkBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: FarmioColors.primaryLight,
          foregroundColor: FarmioColors.primaryDark,
          elevation:       0,
          shadowColor:     Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: FarmioColors.primaryLight,
          side: const BorderSide(color: FarmioColors.darkBorder, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: FarmioColors.primaryLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled:    true,
        fillColor: FarmioColors.darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: FarmioColors.darkBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: FarmioColors.darkBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: FarmioColors.primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: FarmioColors.danger, width: 1.4),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: FarmioColors.danger, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        hintStyle: GoogleFonts.inter(color: FarmioColors.darkTextMuted, fontSize: 14),
        labelStyle: GoogleFonts.inter(color: FarmioColors.darkTextMuted, fontSize: 14),
        floatingLabelStyle: GoogleFonts.inter(
          color: FarmioColors.primaryLight, fontSize: 13, fontWeight: FontWeight.w600,
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: FarmioColors.darkBorder,
        thickness: 1,
        space: 1,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: FarmioColors.darkCard,
        labelStyle: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w700, color: FarmioColors.darkTextSecond,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: const StadiumBorder(),
        side: BorderSide.none,
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: FarmioColors.primaryLight,
        foregroundColor: FarmioColors.primaryDark,
        elevation: 4,
        highlightElevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        indicatorColor:  Colors.white.withValues(alpha: 0.14),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
                fontSize: 11, fontWeight: FontWeight.w700, color: FarmioColors.primaryLight);
          }
          return GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w500, color: FarmioColors.darkTextMuted);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: FarmioColors.primaryLight, size: 22);
          }
          return const IconThemeData(color: FarmioColors.darkTextMuted, size: 22);
        }),
      ),

      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: FarmioColors.darkCard,
        contentTextStyle: GoogleFonts.inter(color: Colors.white, fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: FarmioColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 17, fontWeight: FontWeight.w700, color: FarmioColors.darkTextPrimary,
        ),
        contentTextStyle: GoogleFonts.inter(fontSize: 14, color: FarmioColors.darkTextSecond),
      ),
    );
  }
}

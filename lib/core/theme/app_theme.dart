import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class FarmioColors {
  // Brand
  static const primary      = Color(0xFF0284C7); // blue-600
  static const primaryDark  = Color(0xFF0F172A); // navy
  static const primaryLight = Color(0xFFBAE6FD); // sky-200
  static const primaryBg    = Color(0xFFE0F2FE); // sky-100
  static const cyan         = Color(0xFF06B6D4);

  // Semantic
  static const success     = Color(0xFF0D9488); // teal-600
  static const successBg   = Color(0xFFF0FDFA);
  static const danger      = Color(0xFFDC2626); // red-600
  static const dangerBg    = Color(0xFFFEF2F2);
  static const warning     = Color(0xFF7C3AED); // violet, avoids warm farm UI
  static const warningBg   = Color(0xFFFFFBEB);
  static const info        = Color(0xFF0284C7); // blue-600
  static const infoBg      = Color(0xFFEFF6FF);
  static const purple      = Color(0xFF6366F1);
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

  // Surfaces
  static const background  = Color(0xFFF8FAFC);
  static const surface     = Colors.white;
  static const border      = slate200;
  static const softBorder  = Color(0xFFE6ECF2);

  // Text
  static const textPrimary = slate900;
  static const textSecond  = slate600;
  static const textMuted   = slate400;

  // Dark mode
  static const darkBg      = Color(0xFF0A0F1E);
  static const darkSurface = Color(0xFF111827);
  static const darkCard    = Color(0xFF1F2937);
  static const darkBorder  = Color(0xFF374151);
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
      scaffoldBackgroundColor: const Color(0xFFF5FAFD),
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 32, fontWeight: FontWeight.w800,
          color: FarmioColors.textPrimary, letterSpacing: -1,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 24, fontWeight: FontWeight.w800,
          color: FarmioColors.textPrimary, letterSpacing: -0.5,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 20, fontWeight: FontWeight.w700,
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
          fontSize:   18,
          fontWeight: FontWeight.w800,
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
        color:       Colors.white.withValues(alpha: 0.82),
        elevation:   0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(
              color: Color(0xDDE6ECF2), width: 1),
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
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: 24, vertical: 14),
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
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: 24, vertical: 14),
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
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.inter(
            fontSize:   13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled:    true,
        fillColor: Colors.white.withValues(alpha: 0.86),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
              color: FarmioColors.softBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
              color: FarmioColors.softBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
              color: FarmioColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
              color: FarmioColors.danger, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.inter(
          color: FarmioColors.textMuted, fontSize: 14,
        ),
        labelStyle: GoogleFonts.inter(
          color: FarmioColors.textMuted, fontSize: 14,
        ),
      ),

      dividerTheme: const DividerThemeData(
        color:     FarmioColors.border,
        thickness: 1,
        space:     1,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.76),
        labelStyle:      GoogleFonts.inter(
          fontSize:   12,
          fontWeight: FontWeight.w600,
          color:      FarmioColors.textSecond,
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: 10, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: BorderSide.none,
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: FarmioColors.primary,
        foregroundColor: Colors.white,
        elevation:       2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
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
        primary:    FarmioColors.primary,
        surface:    FarmioColors.darkSurface,
      ),
      scaffoldBackgroundColor: FarmioColors.darkBg,
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(
          ThemeData.dark().textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor:  FarmioColors.darkSurface,
        foregroundColor:  Colors.white,
        elevation:        0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.inter(
          fontSize:   17,
          fontWeight: FontWeight.w700,
          color:      Colors.white,
        ),
        shape: Border(
          bottom: BorderSide(
            color: FarmioColors.darkBorder,
            width: 0.5,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color:     FarmioColors.darkCard,
        elevation: 0,
        shape:     RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
              color: FarmioColors.darkBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: FarmioColors.primary,
          foregroundColor: Colors.white,
          elevation:       0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: 24, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled:    true,
        fillColor: FarmioColors.darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   BorderSide(
              color: FarmioColors.darkBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   BorderSide(
              color: FarmioColors.darkBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
              color: FarmioColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
      ),
    );
  }
}

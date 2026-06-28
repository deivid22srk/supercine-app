import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Paleta de cores inspirada no HBO Max (roxo premium + deep black).
class SupercineColors {
  // Fundos
  static const background = Color(0xFF0B0B14);
  static const surface = Color(0xFF15151F);
  static const surfaceAlt = Color(0xFF1E1E2C);
  static const card = Color(0xFF1A1A28);
  static const divider = Color(0xFF2A2A3C);

  // Brand
  static const brand = Color(0xFF7B2BF9);
  static const brandLight = Color(0xFFA87BFF);
  static const brandDark = Color(0xFF5A1DD4);
  static const brandGradientStart = Color(0xFF7B2BF9);
  static const brandGradientEnd = Color(0xFF4E10C7);

  // Texto
  static const textPrimary = Color(0xFFF7F4FF);
  static const textSecondary = Color(0xFFB6B0CC);
  static const textMuted = Color(0xFF6E6987);

  // Status
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);
  static const info = Color(0xFF38BDF8);

  // Sobre imagem
  static const scrimTop = Color(0x99000000);
  static const scrimBottom = Color(0xE6000000);
}

/// Tema HBO Max-like (dark premium com roxo de destaque).
class SupercineTheme {
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: SupercineColors.brand,
      brightness: Brightness.dark,
      primary: SupercineColors.brand,
      secondary: SupercineColors.brandLight,
      surface: SupercineColors.surface,
      error: SupercineColors.danger,
    );

    return base.copyWith(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: SupercineColors.background,
      canvasColor: SupercineColors.background,
      splashColor: SupercineColors.brand.withValues(alpha: 0.12),
      highlightColor: SupercineColors.brand.withValues(alpha: 0.08),
      dividerColor: SupercineColors.divider,
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.poppins(
          fontWeight: FontWeight.w800,
          color: SupercineColors.textPrimary,
          letterSpacing: -0.5,
        ),
        headlineLarge: GoogleFonts.poppins(
          fontWeight: FontWeight.w700,
          color: SupercineColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontWeight: FontWeight.w700,
          color: SupercineColors.textPrimary,
        ),
        titleLarge: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          color: SupercineColors.textPrimary,
        ),
        titleMedium: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          color: SupercineColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          color: SupercineColors.textPrimary,
          fontSize: 15,
        ),
        bodyMedium: GoogleFonts.inter(
          color: SupercineColors.textSecondary,
          fontSize: 14,
        ),
        bodySmall: GoogleFonts.inter(
          color: SupercineColors.textMuted,
          fontSize: 12,
        ),
        labelLarge: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          color: SupercineColors.textPrimary,
          fontSize: 14,
          letterSpacing: 0.2,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: SupercineColors.background,
        foregroundColor: SupercineColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w700,
          fontSize: 22,
          color: SupercineColors.textPrimary,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: SupercineColors.surface,
        selectedItemColor: SupercineColors.brand,
        unselectedItemColor: SupercineColors.textMuted,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: SupercineColors.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: SupercineColors.surfaceAlt,
        selectedColor: SupercineColors.brand,
        labelStyle: GoogleFonts.inter(
          color: SupercineColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SupercineColors.surfaceAlt,
        hintStyle: GoogleFonts.inter(color: SupercineColors.textMuted),
        labelStyle: GoogleFonts.inter(color: SupercineColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: SupercineColors.brand, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SupercineColors.brand,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: SupercineColors.textPrimary,
          side: const BorderSide(color: SupercineColors.divider, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      iconTheme: const IconThemeData(
        color: SupercineColors.textPrimary,
        size: 24,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: SupercineColors.brand,
        linearTrackColor: SupercineColors.surfaceAlt,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: SupercineColors.surfaceAlt,
        contentTextStyle: GoogleFonts.inter(color: SupercineColors.textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      SupercineColors.brandGradientStart,
      SupercineColors.brandGradientEnd,
    ],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x00000000),
      Color(0x66000000),
      Color(0xE6000000),
    ],
  );
}

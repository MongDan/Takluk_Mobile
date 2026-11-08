import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TaklukColors {
  static const Color primary = Color(0xFF462B92);
  static const Color accent = Color(0xFFF89C05);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF2A1A5E);
  static const Color tint = Color(0xFFEFEAFB);
  static const Color tintWarm = Color(0xFFFFF4DE);
  static const Color bg = Color(0xFFFAF9FD);
  static const Color muted = Color(0xFF6B6B80);
  static const Color line = Color(0xFFE7E4F0);
  static const Color success = Color(0xFF16A34A);
  static const Color error = Color(0xFFDC2626);
  static const Color gradientStart = Color(0xFF462B92);
  static const Color gradientEnd = Color(0xFF6B47C9);
}

class TaklukGradients {
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [TaklukColors.gradientStart, TaklukColors.gradientEnd],
  );
}

class TaklukRadius {
  static const double hero = 24;
  static const double card = 16;
  static const double thumbnail = 12;
  static const double sheet = 28;
  static BorderRadius heroBR = BorderRadius.circular(hero);
  static BorderRadius cardBR = BorderRadius.circular(card);
  static BorderRadius thumbnailBR = BorderRadius.circular(thumbnail);
  static BorderRadius sheetBR = const BorderRadius.vertical(top: Radius.circular(sheet));
}

class TaklukSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double pagePadding = 20;
  static const double sectionGap = 20;
  static const double cardGap = 8;
  static const double bottomSafe = 112;
}

class TaklukTheme {
  static TextTheme get _textTheme {
    return GoogleFonts.poppinsTextTheme().copyWith(
      headlineLarge: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700, color: TaklukColors.ink),
      headlineMedium: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: TaklukColors.ink),
      titleLarge: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: TaklukColors.ink),
      titleMedium: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: TaklukColors.ink),
      titleSmall: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: TaklukColors.ink),
      bodyLarge: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w400, color: TaklukColors.ink),
      bodyMedium: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400, color: TaklukColors.ink),
      bodySmall: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w400, color: TaklukColors.muted),
      labelLarge: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
      labelMedium: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: TaklukColors.muted),
      labelSmall: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w400, color: TaklukColors.muted),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: TaklukColors.bg,
      colorScheme: const ColorScheme.light(
        primary: TaklukColors.primary,
        secondary: TaklukColors.accent,
        surface: TaklukColors.surface,
        error: TaklukColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: TaklukColors.ink,
        onError: Colors.white,
      ),
      textTheme: _textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: TaklukColors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: TaklukColors.ink,
        ),
        iconTheme: const IconThemeData(color: TaklukColors.primary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: TaklukColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: TaklukRadius.cardBR,
          borderSide: const BorderSide(color: TaklukColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: TaklukRadius.cardBR,
          borderSide: const BorderSide(color: TaklukColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: TaklukRadius.cardBR,
          borderSide: const BorderSide(color: TaklukColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: TaklukRadius.cardBR,
          borderSide: const BorderSide(color: TaklukColors.error),
        ),
        labelStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: TaklukColors.muted),
        hintStyle: GoogleFonts.poppins(fontSize: 14, color: TaklukColors.muted),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: TaklukColors.surface,
        selectedItemColor: TaklukColors.primary,
        unselectedItemColor: TaklukColors.muted,
      ),
    );
  }
}

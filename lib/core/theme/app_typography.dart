import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_theme.dart';

class TaklukTypography {
  static TextStyle pageTitle = GoogleFonts.poppins(
    fontSize: 24, fontWeight: FontWeight.w700, color: TaklukColors.ink,
  );
  static TextStyle sectionTitle = GoogleFonts.poppins(
    fontSize: 16, fontWeight: FontWeight.w700, color: TaklukColors.ink,
  );
  static TextStyle cardTitle = GoogleFonts.poppins(
    fontSize: 14, fontWeight: FontWeight.w600, color: TaklukColors.ink,
  );
  static TextStyle body = GoogleFonts.poppins(
    fontSize: 14, fontWeight: FontWeight.w400, color: TaklukColors.ink,
  );
  static TextStyle bodyMedium = GoogleFonts.poppins(
    fontSize: 14, fontWeight: FontWeight.w500, color: TaklukColors.ink,
  );
  static TextStyle button = GoogleFonts.poppins(
    fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white,
  );
  static TextStyle metadata = GoogleFonts.poppins(
    fontSize: 12, fontWeight: FontWeight.w400, color: TaklukColors.muted,
  );
  static TextStyle caption = GoogleFonts.poppins(
    fontSize: 11, fontWeight: FontWeight.w400, color: TaklukColors.muted,
  );
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get headlineXl => GoogleFonts.plusJakartaSans(
    fontSize: 36,
    fontWeight: FontWeight.w800,
    height: 44 / 36,
    letterSpacing: -0.02 * 36,
  );

  static TextStyle get headlineXlMobile => GoogleFonts.plusJakartaSans(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    height: 36 / 28,
    letterSpacing: -0.02 * 28,
  );

  static TextStyle get headlineLg => GoogleFonts.plusJakartaSans(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 32 / 24,
    letterSpacing: -0.015 * 24,
  );

  static TextStyle get headlineMd => GoogleFonts.plusJakartaSans(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 28 / 20,
    letterSpacing: -0.01 * 20,
  );

  static TextStyle get headlineSm => GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 24 / 16,
  );

  static TextStyle get bodyLg => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
  );

  static TextStyle get bodyMd => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
  );

  static TextStyle get bodySm => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
  );

  static TextStyle get labelLg => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
    letterSpacing: 0.01 * 14,
  );

  static TextStyle get labelMd => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 16 / 12,
    letterSpacing: 0.02 * 12,
  );

  static TextStyle get labelSm => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    height: 14 / 11,
    letterSpacing: 0.05 * 11,
  );

  static TextStyle get numericTable => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}

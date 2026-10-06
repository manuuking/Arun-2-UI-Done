import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Surface
  static const Color surface = Color(0xFFF8F9FF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFEFF4FF);
  static const Color surfaceContainer = Color(0xFFE5EEFF);
  static const Color surfaceContainerHigh = Color(0xFFDCE9FF);

  // On-Surface
  static const Color onSurface = Color(0xFF0B1C30);
  static const Color onSurfaceVariant = Color(0xFF45464D);

  // Outline
  static const Color outline = Color(0xFF76777D);
  static const Color outlineVariant = Color(0xFFC6C6CD);

  // Primary
  static const Color primary = Color(0xFF000000);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF131B2E);

  // Secondary (Amber / Operations)
  static const Color secondary = Color(0xFF904D00);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFFE932C);
  static const Color onSecondaryContainer = Color(0xFF663500);
  static const Color secondaryFixed = Color(0xFFFFDCC3); // Pending Badge BG

  // Tertiary / Success (Paid)
  static const Color tertiaryFixed = Color(0xFF85F8C4); // Paid Badge BG
  static const Color onTertiaryFixed = Color(0xFF002114);
  static const Color onTertiaryContainer = Color(
    0xFF069669,
  ); // Paid Status Text / Dot

  // Secondary variants
  static const Color onSecondaryFixedVariant = Color(0xFF6E3900);

  // Error (Overdue / Delete)
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  // Special Semantic Colors mapped from DESIGN.md
  static const Color pendingBg = Color(0xFFFFDCC3);
  static const Color pendingText = Color(0xFF2F1500);
  static const Color pendingDot = Color(0xFFFE932C);

  static const Color paidBg = Color(0xFF85F8C4);
  static const Color paidText = Color(0xFF002114);
  static const Color paidDot = Color(0xFF069669);

  static const Color partialBg = Color(
    0xFFD3E4FE,
  ); // surface-variant from DESIGN.md
  static const Color partialDot = Color(0xFF904D00);
}

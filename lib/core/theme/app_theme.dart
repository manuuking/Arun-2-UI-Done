import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.onErrorContainer,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
      ),
      scaffoldBackgroundColor: AppColors.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.headlineMd.copyWith(
          color: AppColors.onSurface,
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: AppTextStyles.headlineXl,
        headlineMedium: AppTextStyles.headlineLg,
        headlineSmall: AppTextStyles.headlineMd,
        titleLarge: AppTextStyles.headlineSm,
        bodyLarge: AppTextStyles.bodyLg,
        bodyMedium: AppTextStyles.bodyMd,
        bodySmall: AppTextStyles.bodySm,
        labelLarge: AppTextStyles.labelLg,
        labelMedium: AppTextStyles.labelMd,
        labelSmall: AppTextStyles.labelSm,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          textStyle: AppTextStyles.labelLg,
          minimumSize: const Size.fromHeight(AppDimensions.minTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.onSurface,
          side: const BorderSide(color: AppColors.outlineVariant),
          textStyle: AppTextStyles.labelLg,
          minimumSize: const Size.fromHeight(AppDimensions.minTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceMd,
          vertical: AppDimensions.spaceMd,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(
            color: AppColors.secondaryContainer,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        labelStyle: AppTextStyles.labelSm.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
        hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.outline),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerLowest,
        elevation: 1, // Will map to custom shadows when needed
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          side: const BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radius2Xl),
          ),
        ),
        elevation: 3,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceContainerLowest,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.onSurfaceVariant,
        selectedLabelStyle: AppTextStyles.labelSm,
        unselectedLabelStyle: AppTextStyles.labelSm,
        type: BottomNavigationBarType.fixed,
        elevation: 3,
      ),
    );
  }
}

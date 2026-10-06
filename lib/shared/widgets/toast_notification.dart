import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class ToastNotification {
  static void show(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.hideCurrentSnackBar();
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: isError ? AppColors.error : AppColors.paidDot,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.onPrimary,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.onSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

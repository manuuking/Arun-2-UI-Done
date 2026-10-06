import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';

enum InvoiceStatus { draft, pending, paid, rejected }

class StatusBadge extends StatelessWidget {
  final InvoiceStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    Color border;
    Color? dot;
    String label;

    switch (status) {
      case InvoiceStatus.paid:
        bg = AppColors.paidBg;
        text = AppColors.paidText;
        border = AppColors.paidBg;
        dot = AppColors.paidDot;
        label = 'PAID';
        break;
      case InvoiceStatus.pending:
        bg = AppColors.pendingBg;
        text = AppColors.pendingText;
        border = AppColors.pendingBg;
        dot = AppColors.pendingDot;
        label = 'PENDING';
        break;
      case InvoiceStatus.rejected:
        bg = AppColors.errorContainer;
        text = AppColors.onErrorContainer;
        border = AppColors.errorContainer;
        dot = AppColors.error;
        label = 'REJECTED';
        break;
      case InvoiceStatus.draft:
        bg = AppColors.surfaceContainer;
        text = AppColors.onSurfaceVariant;
        border = AppColors.outlineVariant;
        label = 'DRAFT';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot != null) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(
              color: text,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

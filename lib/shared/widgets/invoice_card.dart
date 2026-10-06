import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/status_badge.dart';

class InvoiceCard extends StatelessWidget {
  final String invoiceNo;
  final String buyerName;
  final String amount;
  final String date;
  final String description;
  final String poNumber;
  final InvoiceStatus status;
  final bool hasLr;
  final VoidCallback? onView;
  final VoidCallback? onWhatsApp;
  final VoidCallback? onAction;
  final VoidCallback? onPayment;
  final String actionLabel;
  final IconData actionIcon;
  final bool isPaid;

  const InvoiceCard({
    super.key,
    required this.invoiceNo,
    required this.buyerName,
    required this.amount,
    required this.date,
    required this.description,
    required this.poNumber,
    required this.status,
    this.hasLr = true,
    this.isPaid = false,
    this.onView,
    this.onWhatsApp,
    this.onAction,
    this.onPayment,
    this.actionLabel = 'View',
    this.actionIcon = Icons.visibility,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Inv No, Badge, Amount, Date
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      runSpacing: 2,
                      children: [
                        Text(
                          invoiceNo,
                          style: AppTextStyles.labelLg.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        StatusBadge(status: status),
                        if (!hasLr && status != InvoiceStatus.rejected)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'NO LR',
                              style: TextStyle(
                                color: Colors.deepOrange,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      buyerName,
                      style: AppTextStyles.bodyMd.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amount,
                    style: AppTextStyles.headlineSm.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  Text(
                    date,
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Items & PO details box
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.inventory_2_outlined,
                      size: 15,
                      color: AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        description,
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: 'PO: ',
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 11,
                          ),
                          children: [
                            TextSpan(
                              text: poNumber,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: isPaid,
                      onChanged: (val) {
                        if (onPayment != null) onPayment!();
                      },
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Paid',
                      style: AppTextStyles.labelSm.copyWith(
                        color: isPaid
                            ? Colors.green
                            : AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.chat,
                  label: 'WhatsApp',
                  color: AppColors.tertiaryFixed,
                  textColor: AppColors.onTertiaryFixed,
                  onTap: onWhatsApp ?? () {},
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  icon: actionIcon,
                  label: actionLabel,
                  color: (actionLabel == 'Add LR' || actionLabel == 'ADD LR')
                      ? Colors.orange.shade600
                      : AppColors.surfaceContainer,
                  textColor: (actionLabel == 'Add LR' || actionLabel == 'ADD LR')
                      ? Colors.white
                      : AppColors.onSurface,
                  onTap: onAction ?? () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    Color color = AppColors.surfaceContainer,
    Color textColor = AppColors.onSurface,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: textColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.labelSm.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

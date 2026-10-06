import 'package:flutter/material.dart';

import '../../../../shared/widgets/section_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class Step4Totals extends StatelessWidget {
  const Step4Totals({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionCard(
          title: 'TAX LEDGER & SUMMARY',
          child: Column(
            children: [
              _buildSummaryRow('Taxable Subtotal', '₹75,600.00'),
              const SizedBox(height: 8),
              _buildSummaryRow('Add CGST 2.5%', '₹1,890.00', isMuted: true),
              const SizedBox(height: 8),
              _buildSummaryRow('Add SGST 2.5%', '₹1,890.00', isMuted: true),
              const SizedBox(height: 8),
              _buildSummaryRow('Other Expenses', '₹0.00', isMuted: true),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.onSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'GRAND TOTAL',
                      style: AppTextStyles.labelLg.copyWith(
                        color: AppColors.onPrimary,
                      ),
                    ),
                    Text(
                      '₹79,380.00',
                      style: AppTextStyles.headlineLg.copyWith(
                        color: AppColors.onPrimary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Amount in Words: Rupees Seventy Nine Thousand Three Hundred Eighty Only',
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'COMPLIANCE',
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 18,
                      color: AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'E-Way Bill generation required (Total exceeds ₹50,000)',
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Mark as Duplicate', style: AppTextStyles.bodyMd),
                  Switch(
                    value: false,
                    onChanged: (val) {},
                    activeThumbColor: AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isMuted = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMd.copyWith(
            color: isMuted ? AppColors.onSurfaceVariant : AppColors.onSurface,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.numericTable.copyWith(
            color: isMuted ? AppColors.onSurfaceVariant : AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}

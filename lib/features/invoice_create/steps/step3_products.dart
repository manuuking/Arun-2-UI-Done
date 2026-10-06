import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class Step3Products extends StatelessWidget {
  const Step3Products({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'BILLED LINE ITEMS',
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Dummy Product Item Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            border: Border.all(color: AppColors.outlineVariant),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Cotton Hand Gloves',
                      style: AppTextStyles.labelLg,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.error,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'HSN 6116',
                      style: AppTextStyles.numericTable.copyWith(fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Qty.',
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  // Qty Stepper Mock
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.outlineVariant),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 16),
                          onPressed: () {},
                        ),
                        Text('2160', style: AppTextStyles.numericTable),
                        IconButton(
                          icon: const Icon(Icons.add, size: 16),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      initialValue: '35.00',
                      textAlign: TextAlign.right,
                      style: AppTextStyles.numericTable,
                      decoration: const InputDecoration(prefixText: '₹ '),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Item Total',
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '₹75,600.00',
                    style: AppTextStyles.headlineSm.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: const Text('ADD ANOTHER PRODUCT'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }
}

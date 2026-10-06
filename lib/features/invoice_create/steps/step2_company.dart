import 'package:flutter/material.dart';

import '../../../../shared/widgets/section_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class Step2Company extends StatelessWidget {
  const Step2Company({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionCard(
          title: 'CLIENT DOSSIER',
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Search Company Name or GSTIN...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 16),

              // Dummy Selected Company
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.outlineVariant),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'M/s PGP Glass Private Limited',
                          style: AppTextStyles.labelLg,
                        ),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Change'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'GSTIN: 24AALCP5737F1ZA',
                        style: AppTextStyles.numericTable,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Billing Address',
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Plot No 177, 25 Mtr, 150 Feet Ring Road,\nRajkot, Gujarat - 360005',
                      style: AppTextStyles.bodySm,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

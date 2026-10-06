import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class FilterDrawer extends StatelessWidget {
  const FilterDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 24),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filters', style: AppTextStyles.headlineMd),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Reset',
                  style: AppTextStyles.labelMd.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            'PAYMENT STATUS',
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip('All', true),
              _buildFilterChip('Pending', false),
              _buildFilterChip('Partial', false),
              _buildFilterChip('Paid', false),
            ],
          ),
          const SizedBox(height: 24),

          Text(
            'BILLING CYCLE',
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip('This Month', true),
              _buildFilterChip('Last 30 Days', false),
              _buildFilterChip('Custom', false),
            ],
          ),
          const SizedBox(height: 24),

          Text(
            'COMPANY',
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(hintText: 'Select Company'),
            items: const [
              DropdownMenuItem(value: 'All', child: Text('All Companies')),
            ],
            onChanged: (value) {},
          ),

          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Apply Filters'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return ActionChip(
      label: Text(label),
      labelStyle: AppTextStyles.labelMd.copyWith(
        color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
      ),
      backgroundColor: isSelected
          ? AppColors.primary
          : AppColors.surfaceContainerHigh,
      onPressed: () {},
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
        side: BorderSide.none,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    );
  }
}

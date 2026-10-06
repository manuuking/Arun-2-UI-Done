import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class QuickFilterChips extends StatelessWidget {
  final List<String> filters = const [
    'All',
    'Unpaid (30)',
    'Due This Week',
    'High Value (>₹1L)',
  ];
  final String activeFilter = 'All';

  const QuickFilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isActive = filter == activeFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ActionChip(
              label: Text(filter),
              labelStyle: AppTextStyles.labelMd.copyWith(
                color: isActive
                    ? AppColors.onPrimary
                    : AppColors.onSurfaceVariant,
              ),
              backgroundColor: isActive
                  ? AppColors.primary
                  : AppColors.surfaceContainerHigh,
              onPressed: () {
                // To be implemented
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
                side: BorderSide.none,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
          );
        }).toList(),
      ),
    );
  }
}

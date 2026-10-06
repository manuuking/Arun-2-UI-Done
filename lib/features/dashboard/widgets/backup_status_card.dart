import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class BackupStatusCard extends StatelessWidget {
  const BackupStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cloud_sync,
              size: 18,
              color: AppColors.onSecondaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Auto-backup enabled',
                  style: AppTextStyles.labelSm.copyWith(
                    fontSize: 12,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  'Last synced 4 mins ago • Tally Prime',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.verified,
            color: AppColors.onSurfaceVariant,
            size: 18,
          ),
        ],
      ),
    );
  }
}

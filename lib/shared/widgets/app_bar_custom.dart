import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AppBarCustom extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showLivePulse;

  const AppBarCustom({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.showLivePulse = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title),
          if (showLivePulse) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.paidBg,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.paidDot,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'LIVE',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.paidText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      leading: leading,
      actions: [
        ...?actions,
        const Padding(
          padding: EdgeInsets.only(right: 16.0),
          child: CircleAvatar(
            backgroundColor: AppColors.surfaceContainerHigh,
            child: Icon(Icons.person, color: AppColors.onSurfaceVariant),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

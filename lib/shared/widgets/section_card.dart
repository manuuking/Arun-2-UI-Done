import 'package:flutter/material.dart';

import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';

class SectionCard extends StatelessWidget {
  final String? title;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const SectionCard({super.key, this.title, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppDimensions.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null) ...[
              Text(title!, style: AppTextStyles.labelSm),
              const SizedBox(height: AppDimensions.spaceMd),
            ],
            child,
          ],
        ),
      ),
    );
  }
}

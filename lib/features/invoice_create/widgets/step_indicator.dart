import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepLabels;

  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepLabels,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step $currentStep of $totalSteps',
              style: AppTextStyles.labelMd.copyWith(color: AppColors.secondary),
            ),
            Text(
              '${(currentStep / totalSteps * 100).toInt()}%',
              style: AppTextStyles.labelMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: currentStep / totalSteps,
          backgroundColor: AppColors.surfaceContainerHigh,
          color: AppColors.secondary,
          minHeight: 4,
          borderRadius: BorderRadius.circular(2),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(totalSteps, (index) {
              final stepNumber = index + 1;
              final isCompleted = stepNumber < currentStep;
              final isCurrent = stepNumber == currentStep;

              Color textColor = AppColors.onSurfaceVariant;
              if (isCompleted || isCurrent) {
                textColor = AppColors.onSurface;
              }

              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Row(
                  children: [
                    Text(
                      '$stepNumber. ${stepLabels[index]}',
                      style: AppTextStyles.labelSm.copyWith(
                        color: textColor,
                        fontWeight: isCurrent
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    if (isCompleted) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.check_circle,
                        size: 14,
                        color: AppColors.onTertiaryContainer,
                      ),
                    ] else if (isCurrent) ...[
                      const SizedBox(width: 4),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

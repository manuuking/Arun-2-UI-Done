import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class CurrencyInput extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final void Function(String)? onChanged;

  const CurrencyInput({
    super.key,
    required this.label,
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      style: AppTextStyles.numericTable,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          width: 48,
          decoration: const BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.horizontal(left: Radius.circular(8)),
          ),
          child: Text(
            '₹',
            style: AppTextStyles.bodyLg.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(
          minHeight: 48,
          minWidth: 48,
        ),
      ),
    );
  }
}

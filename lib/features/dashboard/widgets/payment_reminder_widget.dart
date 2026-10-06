import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/theme/app_text_styles.dart';

class PaymentReminderWidget extends StatefulWidget {
  const PaymentReminderWidget({super.key});

  @override
  State<PaymentReminderWidget> createState() => _PaymentReminderWidgetState();
}

class _PaymentReminderWidgetState extends State<PaymentReminderWidget> {
  bool _isChecked = false;
  late String _currentMonthKey;
  bool _shouldShow = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  void _checkStatus() {
    final now = DateTime.now();
    _currentMonthKey = 'payment_check_${now.year}_${now.month}';

    // Only show between 15th and 18th
    if (now.day >= 15 && now.day <= 18) {
      final box = Hive.box('settings');
      _isChecked = box.get(_currentMonthKey, defaultValue: false);
      if (!_isChecked) {
        _shouldShow = true;
      }
    }
  }

  void _onChanged(bool? value) {
    if (value == true) {
      final box = Hive.box('settings');
      box.put(_currentMonthKey, true);
      setState(() {
        _isChecked = true;
        _shouldShow = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldShow) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade300, width: 2),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PAYMENT CHECK REMINDER',
                  style: AppTextStyles.labelLg.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Please review and follow up on pending payments for this month.',
                  style: AppTextStyles.bodySm.copyWith(
                    color: Colors.red.shade900,
                  ),
                ),
              ],
            ),
          ),
          Checkbox(
            value: _isChecked,
            onChanged: _onChanged,
            activeColor: Colors.red,
          ),
        ],
      ),
    );
  }
}

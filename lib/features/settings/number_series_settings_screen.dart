import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class NumberSeriesSettingsScreen extends StatefulWidget {
  const NumberSeriesSettingsScreen({super.key});

  @override
  State<NumberSeriesSettingsScreen> createState() =>
      _NumberSeriesSettingsScreenState();
}

class _NumberSeriesSettingsScreenState
    extends State<NumberSeriesSettingsScreen> {
  late TextEditingController _invCtrl;
  late TextEditingController _challanCtrl;
  late Box _settingsBox;

  @override
  void initState() {
    super.initState();
    _settingsBox = Hive.box('settings');

    final currentInv = _settingsBox.get(
      'last_invoice_sequence',
      defaultValue: 28,
    );
    final currentChallan = _settingsBox.get(
      'last_challan_sequence',
      defaultValue: 120,
    );

    _invCtrl = TextEditingController(text: currentInv.toString());
    _challanCtrl = TextEditingController(text: currentChallan.toString());
  }

  @override
  void dispose() {
    _invCtrl.dispose();
    _challanCtrl.dispose();
    super.dispose();
  }

  void _saveSettings() {
    final invVal = int.tryParse(_invCtrl.text.trim()) ?? 0;
    final challanVal = int.tryParse(_challanCtrl.text.trim()) ?? 0;

    _settingsBox.put('last_invoice_sequence', invVal);
    _settingsBox.put('last_challan_sequence', challanVal);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Number series settings saved successfully'),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Number Series Settings', style: AppTextStyles.headlineSm),
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: const Text(
              'Save',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'Configure the last used number sequence. The next generated invoice/challan will be this number + 1. Existing duplicate protection is preserved.',
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Invoice Number Series', style: AppTextStyles.labelMd),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _invCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Last Invoice Sequence (e.g. 22)',
                      prefixText: 'INV-',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Next will be: INV-${(int.tryParse(_invCtrl.text) ?? 0) + 1}',
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Challan Number Series', style: AppTextStyles.labelMd),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _challanCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Last Challan Sequence (e.g. 120)',
                      prefixText: 'CH-',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Next will be: CH-${(int.tryParse(_challanCtrl.text) ?? 0) + 1}',
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

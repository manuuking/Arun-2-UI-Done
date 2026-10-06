
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'number_series_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings', style: AppTextStyles.headlineSm)),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Seller Profile
          Card(
            margin: const EdgeInsets.only(bottom: 24),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'SELLER PROFILE',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      TextButton(onPressed: () {}, child: const Text('Edit')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Arun Mensware Service',
                    style: AppTextStyles.headlineSm,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'GSTIN: 24AKZPP9424E1ZM',
                    style: AppTextStyles.numericTable,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Laxmi Chhaya Society-1, Plot No 177, 25 Mtr, 150 Feet Ring Road,\nRajkot, Gujarat - 360005',
                    style: AppTextStyles.bodySm,
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text('Bank Details', style: AppTextStyles.labelMd),
                  const SizedBox(height: 4),
                  Text(
                    'HDFC Rajkot\nA/c: 03792000003498\nIFSC: HDFC0000379',
                    style: AppTextStyles.bodySm,
                  ),
                ],
              ),
            ),
          ),

          // Tax Settings
          Text(
            'TAX SETTINGS',
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            margin: const EdgeInsets.only(bottom: 24),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Enable GST Calculations'),
                  value: true,
                  onChanged: (val) {},
                  activeThumbColor: AppColors.primary,
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Default SGST/CGST Rate'),
                  subtitle: const Text('Currently: 2.5% each (5% total)'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Number Series Settings'),
                  subtitle: const Text('Configure Invoice & Challan sequences'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NumberSeriesSettingsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Branding
          Text(
            'BRANDING',
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            margin: const EdgeInsets.only(bottom: 24),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.image,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              title: const Text('Company Logo'),
              subtitle: const Text('Upload high-res PNG/JPG for invoices'),
              trailing: ElevatedButton(
                onPressed: () async {
                  final picker = ImagePicker();
                  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    final bytes = await image.readAsBytes();
                    await Hive.box('settings').put('company_logo_bytes', bytes);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Logo updated successfully!')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  minimumSize: const Size(0, 36),
                ),
                child: const Text('Upload'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/seller_profile.dart';

class SellerProfileEditScreen extends StatefulWidget {
  const SellerProfileEditScreen({super.key});

  @override
  State<SellerProfileEditScreen> createState() => _SellerProfileEditScreenState();
}

class _SellerProfileEditScreenState extends State<SellerProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _gstinCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _bankNameCtrl;
  late TextEditingController _accountNoCtrl;
  late TextEditingController _ifscCtrl;
  late TextEditingController _bankEmailCtrl;
  late TextEditingController _termsCtrl;

  @override
  void initState() {
    super.initState();
    final box = Hive.box('settings');
    final Map<dynamic, dynamic>? sellerMap = box.get('seller_profile');
    
    SellerProfile profile;
    if (sellerMap != null) {
      profile = SellerProfile.fromMap(sellerMap);
    } else {
      profile = SellerProfile.defaultProfile();
    }

    _nameCtrl = TextEditingController(text: profile.name);
    _gstinCtrl = TextEditingController(text: profile.gstin);
    _addressCtrl = TextEditingController(text: profile.address);
    _phoneCtrl = TextEditingController(text: profile.phone);
    _emailCtrl = TextEditingController(text: profile.email);
    _bankNameCtrl = TextEditingController(text: profile.bankName);
    _accountNoCtrl = TextEditingController(text: profile.accountNo);
    _ifscCtrl = TextEditingController(text: profile.ifsc);
    _bankEmailCtrl = TextEditingController(text: profile.bankEmail ?? '');
    _termsCtrl = TextEditingController(text: profile.termsAndConditions.join('\n\n'));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _gstinCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _bankNameCtrl.dispose();
    _accountNoCtrl.dispose();
    _ifscCtrl.dispose();
    _bankEmailCtrl.dispose();
    _termsCtrl.dispose();
    super.dispose();
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final box = Hive.box('settings');
      final terms = _termsCtrl.text.split('\n\n').where((s) => s.trim().isNotEmpty).toList();
      
      final updatedProfile = SellerProfile(
        name: _nameCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        gstin: _gstinCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        bankName: _bankNameCtrl.text.trim(),
        accountNo: _accountNoCtrl.text.trim(),
        ifsc: _ifscCtrl.text.trim(),
        bankEmail: _bankEmailCtrl.text.trim(),
        termsAndConditions: terms,
      );

      await box.put('seller_profile', updatedProfile.toMap());
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seller Profile updated successfully')),
        );
        Navigator.pop(context);
      }
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isMultiLine = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        maxLines: isMultiLine ? null : 1,
        minLines: isMultiLine ? 3 : 1,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Seller Profile', style: AppTextStyles.headlineSm),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text('COMPANY DETAILS', style: AppTextStyles.labelSm.copyWith(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 16),
            _buildTextField('Seller / Company Name', _nameCtrl),
            _buildTextField('GSTIN', _gstinCtrl),
            _buildTextField('Address', _addressCtrl, isMultiLine: true),
            _buildTextField('Phone', _phoneCtrl),
            _buildTextField('Email', _emailCtrl),
            
            const SizedBox(height: 24),
            Text('BANK DETAILS', style: AppTextStyles.labelSm.copyWith(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 16),
            _buildTextField('Bank Name', _bankNameCtrl),
            _buildTextField('Bank Account Number', _accountNoCtrl),
            _buildTextField('IFSC Code', _ifscCtrl),
            _buildTextField('Bank Email', _bankEmailCtrl),

            const SizedBox(height: 24),
            Text('TERMS & CONDITIONS', style: AppTextStyles.labelSm.copyWith(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 16),
            _buildTextField('Terms & Conditions (Separate with double line break)', _termsCtrl, isMultiLine: true),

            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
              ),
              child: const Text('SAVE CHANGES'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

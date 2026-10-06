import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/company_profile.dart';
import '../../providers/providers.dart';

class CompanyEditScreen extends ConsumerStatefulWidget {
  final CompanyProfile? company;

  const CompanyEditScreen({super.key, this.company});

  @override
  ConsumerState<CompanyEditScreen> createState() => _CompanyEditScreenState();
}

class _CompanyEditScreenState extends ConsumerState<CompanyEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _shortNameController;
  late TextEditingController _gstinController;

  // Addresses
  late List<Address> _addresses;
  // Product rates
  late List<CompanyProductRate> _productRates;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final c = widget.company;
    _nameController = TextEditingController(text: c?.name ?? '');
    _shortNameController = TextEditingController(text: c?.shortName ?? '');
    _gstinController = TextEditingController(
      text: c?.gstin.isNotEmpty == true ? c!.gstin.first : '',
    );

    _addresses = c != null && c.addresses.isNotEmpty
        ? List.from(c.addresses)
        : [
            Address(
              id: 'addr_1',
              label: 'Billing Address',
              fullAddress: 'Plot No 177, 25 Mtr, 150 Feet Ring Road',
              pincode: '360005',
              city: 'Rajkot',
              state: 'Gujarat',
            ),
          ];

    _productRates = c != null ? List.from(c.productRates) : [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _shortNameController.dispose();
    _gstinController.dispose();
    super.dispose();
  }

  void _addAddressDialog() {
    final labelCtrl = TextEditingController(text: 'Delivery Warehouse');
    final addressCtrl = TextEditingController();
    final cityCtrl = TextEditingController(text: 'Rajkot');
    final pinCtrl = TextEditingController(text: '360021');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Address'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: labelCtrl,
                decoration: const InputDecoration(
                  labelText: 'Label (e.g. Warehouse 2)',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: addressCtrl,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: cityCtrl,
                decoration: const InputDecoration(labelText: 'City'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: pinCtrl,
                decoration: const InputDecoration(labelText: 'Pincode'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (addressCtrl.text.trim().isNotEmpty) {
                setState(() {
                  _addresses.add(
                    Address(
                      id: 'addr_${DateTime.now().millisecondsSinceEpoch}',
                      label: labelCtrl.text.trim(),
                      fullAddress: addressCtrl.text.trim(),
                      pincode: pinCtrl.text.trim(),
                      city: cityCtrl.text.trim(),
                      state: 'Gujarat',
                    ),
                  );
                });
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addProductRateDialog() async {
    final products = await ref.read(productRepositoryProvider).getProducts();
    if (!mounted) return;
    if (products.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No products available')));
      return;
    }

    String selectedProdId = products.first.id;
    final rateCtrl = TextEditingController(
      text: products.first.defaultRate.toStringAsFixed(2),
    );
    final labelCtrl = TextEditingController(text: 'Contract Rate');

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          title: const Text('Add Company Rate Override'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedProdId,
                isExpanded: true,
                items: products
                    .map(
                      (p) => DropdownMenuItem(value: p.id, child: Text(p.name)),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setDlgState(() {
                      selectedProdId = val;
                      final p = products.firstWhere((prod) => prod.id == val);
                      rateCtrl.text = p.defaultRate.toStringAsFixed(2);
                    });
                  }
                },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: labelCtrl,
                decoration: const InputDecoration(labelText: 'Rate Label'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: rateCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Special Rate (Rs)',
                  prefixText: 'Rs ',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final r = double.tryParse(rateCtrl.text.trim()) ?? 0.0;
                if (r > 0) {
                  setState(() {
                    _productRates.removeWhere(
                      (pr) => pr.productId == selectedProdId,
                    );
                    _productRates.add(
                      CompanyProductRate(
                        productId: selectedProdId,
                        label: labelCtrl.text.trim(),
                        rate: r,
                      ),
                    );
                  });
                }
                Navigator.pop(ctx);
              },
              child: const Text('Save Rate'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveCompany() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final id =
          widget.company?.id ?? 'comp_${DateTime.now().millisecondsSinceEpoch}';
      final gstinText = _gstinController.text.trim().toUpperCase();

      final updated = CompanyProfile(
        id: id,
        name: _nameController.text.trim(),
        shortName: _shortNameController.text.trim().isNotEmpty
            ? _shortNameController.text.trim()
            : _nameController.text.trim(),
        gstin: gstinText.isNotEmpty ? [gstinText] : [],
        addresses: _addresses,
        productRates: _productRates,
        isActive: true,
        createdAt: widget.company?.createdAt ?? DateTime.now(),
      );

      await ref.read(companyRepositoryProvider).saveCompany(updated);
      ref.invalidate(companiesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Company ${updated.name} saved!'),
            backgroundColor: AppColors.secondary,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving company: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.company == null ? 'New Company' : 'Edit Company',
          style: AppTextStyles.headlineSm,
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveCompany,
            child: _isSaving
                ? const CircularProgressIndicator()
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Company Name *'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter company name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _shortNameController,
                decoration: const InputDecoration(
                  labelText: 'Short Name / Alias',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _gstinController,
                decoration: const InputDecoration(
                  labelText: 'GSTIN (15-digit)',
                ),
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 20),

              // Addresses Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ADDRESSES (${_addresses.length})',
                    style: AppTextStyles.labelMd.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _addAddressDialog,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Address'),
                  ),
                ],
              ),
              ..._addresses.asMap().entries.map((e) {
                final idx = e.key;
                final addr = e.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    dense: true,
                    title: Text(
                      addr.label,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${addr.fullAddress}, ${addr.city} (${addr.pincode})',
                    ),
                    trailing: _addresses.length > 1
                        ? IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: AppColors.error,
                            ),
                            onPressed: () =>
                                setState(() => _addresses.removeAt(idx)),
                          )
                        : null,
                  ),
                );
              }),

              const SizedBox(height: 16),

              // Special Product Rates Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'PRODUCT RATE OVERRIDES (${_productRates.length})',
                    style: AppTextStyles.labelMd.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _addProductRateDialog,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Rate'),
                  ),
                ],
              ),
              if (_productRates.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'No company-specific rates set. Standard product rates will apply.',
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ..._productRates.asMap().entries.map((e) {
                final idx = e.key;
                final pr = e.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    dense: true,
                    title: Text(
                      '${pr.productId} • ${pr.label}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Rate: Rs ${pr.rate.toStringAsFixed(2)}'),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: AppColors.error,
                      ),
                      onPressed: () =>
                          setState(() => _productRates.removeAt(idx)),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

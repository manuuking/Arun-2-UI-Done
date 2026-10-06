import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/product.dart';
import '../../providers/providers.dart';

class ProductEditScreen extends ConsumerStatefulWidget {
  final Product? product;

  const ProductEditScreen({super.key, this.product});

  @override
  ConsumerState<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends ConsumerState<ProductEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _hsnController;
  late TextEditingController _rateController;
  late TextEditingController _unitController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _descController = TextEditingController(text: p?.description ?? '');
    _hsnController = TextEditingController(text: p?.hsnCode ?? '');
    _rateController = TextEditingController(
      text: p != null ? p.defaultRate.toStringAsFixed(2) : '',
    );
    _unitController = TextEditingController(text: p?.unit ?? 'Qty');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _hsnController.dispose();
    _rateController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  void _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final rate = double.tryParse(_rateController.text.trim()) ?? 0.0;
    if (rate <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid rate > 0'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final id =
          widget.product?.id ?? 'prod_${DateTime.now().millisecondsSinceEpoch}';
      final updated = Product(
        id: id,
        name: _nameController.text.trim(),
        description: _descController.text.trim().isNotEmpty
            ? _descController.text.trim()
            : null,
        hsnCode: _hsnController.text.trim(),
        unit: _unitController.text.trim().isNotEmpty
            ? _unitController.text.trim()
            : 'Qty',
        defaultRate: rate,
      );

      await ref.read(productRepositoryProvider).saveProduct(updated);
      ref.invalidate(productsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product ${updated.name} saved!'),
            backgroundColor: AppColors.secondary,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving product: $e'),
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
          widget.product == null ? 'New Product' : 'Edit Product',
          style: AppTextStyles.headlineSm,
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveProduct,
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
                decoration: const InputDecoration(labelText: 'Product Name *'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter product name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Description / Specifications',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _hsnController,
                      decoration: const InputDecoration(
                        labelText: 'HSN Code *',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Enter HSN code'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _unitController,
                      decoration: const InputDecoration(
                        labelText: 'Unit *',
                        hintText: 'e.g. Qty',
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Enter unit' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _rateController,
                decoration: const InputDecoration(
                  labelText: 'Default Rate (Rs) *',
                  prefixText: 'Rs ',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter default rate' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'SAVE PRODUCT',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

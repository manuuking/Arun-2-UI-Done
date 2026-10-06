import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/product.dart';
import '../../providers/providers.dart';
import 'product_edit_screen.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openEditScreen([Product? product]) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductEditScreen(product: product)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Products', style: AppTextStyles.headlineSm),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _openEditScreen(),
          ),
        ],
      ),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading products: $e')),
        data: (products) {
          final query = _searchController.text.trim().toLowerCase();
          final filtered = products.where((p) {
            return query.isEmpty ||
                p.name.toLowerCase().contains(query) ||
                p.hsnCode.toLowerCase().contains(query);
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search products or HSN...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    fillColor: AppColors.surfaceContainerLowest,
                  ),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.inventory_2_outlined,
                              size: 48,
                              color: AppColors.onSurfaceVariant,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No products found',
                              style: AppTextStyles.bodyMd,
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () => _openEditScreen(),
                              child: const Text('Add Product'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final p = filtered[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              onTap: () => _openEditScreen(p),
                              title: Text(p.name, style: AppTextStyles.labelLg),
                              subtitle: Row(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(
                                      top: 4,
                                      right: 8,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceContainerHigh,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'HSN ${p.hsnCode}',
                                      style: AppTextStyles.numericTable
                                          .copyWith(fontSize: 12),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceContainerHigh,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      p.unit,
                                      style: AppTextStyles.labelSm,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Rs ${p.defaultRate.toStringAsFixed(2)}',
                                    style: AppTextStyles.headlineSm.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontFeatures: const [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined),
                                    onPressed: () => _openEditScreen(p),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditScreen(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

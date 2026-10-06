import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/company_profile.dart';
import '../../providers/providers.dart';
import 'company_edit_screen.dart';

class CompanyListScreen extends ConsumerStatefulWidget {
  const CompanyListScreen({super.key});

  @override
  ConsumerState<CompanyListScreen> createState() => _CompanyListScreenState();
}

class _CompanyListScreenState extends ConsumerState<CompanyListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openEditScreen([CompanyProfile? company]) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CompanyEditScreen(company: company)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final companiesAsync = ref.watch(companiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Companies', style: AppTextStyles.headlineSm),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _openEditScreen(),
          ),
        ],
      ),
      body: companiesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading companies: $e')),
        data: (companies) {
          final query = _searchController.text.trim().toLowerCase();
          final filtered = companies.where((c) {
            return query.isEmpty ||
                c.name.toLowerCase().contains(query) ||
                c.gstin.any((g) => g.toLowerCase().contains(query));
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search companies or GSTIN...',
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
                              Icons.business_outlined,
                              size: 48,
                              color: AppColors.onSurfaceVariant,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No companies found',
                              style: AppTextStyles.bodyMd,
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () => _openEditScreen(),
                              child: const Text('Add Company'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final c = filtered[index];
                          final addr = c.addresses.isNotEmpty
                              ? '${c.addresses.first.city}, ${c.addresses.first.state}'
                              : 'No address configured';
                          final gstin = c.gstin.isNotEmpty
                              ? c.gstin.first
                              : 'N/A';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              onTap: () => _openEditScreen(c),
                              title: Text(c.name, style: AppTextStyles.labelLg),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    'GSTIN: $gstin',
                                    style: AppTextStyles.numericTable,
                                  ),
                                  Text(
                                    '$addr • ${c.addresses.length} addresses • ${c.productRates.length} custom rates',
                                    style: AppTextStyles.bodySm,
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () => _openEditScreen(c),
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/utils/date_formatter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/invoice.dart';
import '../../shared/widgets/invoice_card.dart';
import '../../shared/widgets/status_badge.dart';
import '../providers/providers.dart';

import 'package:printing/printing.dart';

import '../pdf/invoice_pdf_generator.dart';

class InvoiceListScreen extends ConsumerStatefulWidget {
  const InvoiceListScreen({super.key});

  @override
  ConsumerState<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends ConsumerState<InvoiceListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'All'; // All, Pending, Paid, Rejected
  String? _selectedCompanyId;
  String? _selectedPoNumber;
  String _selectedPeriod = 'All'; // All, Weekly, This Month, This Year
  String _selectedSort = 'Latest'; // Latest, Number Asc, Number Desc
  DateTime? _dateFrom;
  DateTime? _dateTo;
  String _invoiceFrom = '';
  String _invoiceTo = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getSafeFileName(Invoice inv) {
    String name = '${inv.invoiceNo}_${inv.buyerName}';
    name = name.replaceAll(' ', '-').replaceAll(RegExp(r'[^a-zA-Z0-9\-]'), '');
    return '$name.pdf';
  }

  void _sharePdf(Invoice inv) async {
    try {
      final bytes = await InvoicePdfGenerator.generateInvoice(
        invoice: inv,
        isDuplicate: false,
      );
      final fileName = _getSafeFileName(inv);
      await Printing.sharePdf(bytes: bytes, filename: fileName);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  InvoiceStatus _mapStatus(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return InvoiceStatus.paid;
      case 'rejected':
        return InvoiceStatus.rejected;
      case 'draft':
        return InvoiceStatus.draft;
      default:
        return InvoiceStatus.pending;
    }
  }

  void _showAdvancedFilters() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Advanced Filters'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedSort,
                  decoration: const InputDecoration(labelText: 'Sort By'),
                  items: const [
                    DropdownMenuItem(
                      value: 'Latest',
                      child: Text('Latest (Recently Updated)'),
                    ),
                    DropdownMenuItem(
                      value: 'Number Asc',
                      child: Text('Invoice Number Ascending'),
                    ),
                    DropdownMenuItem(
                      value: 'Number Desc',
                      child: Text('Invoice Number Descending'),
                    ),
                  ],
                  onChanged: (v) =>
                      setState(() => _selectedSort = v ?? 'Latest'),
                ),
                const SizedBox(height: 10),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Invoice Number From',
                  ),
                  onChanged: (v) => setState(() => _invoiceFrom = v.trim()),
                ),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Invoice Number To',
                  ),
                  onChanged: (v) => setState(() => _invoiceTo = v.trim()),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        _dateFrom = picked.start;
                        _dateTo = picked.end;
                      });
                    }
                  },
                  child: const Text('Select Date Range'),
                ),
                if (_dateFrom != null && _dateTo != null)
                  Text(
                    'Selected: ${AppDateFormatter.formatDate(_dateFrom!)} to ${AppDateFormatter.formatDate(_dateTo!)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _dateFrom = null;
                      _dateTo = null;
                      _invoiceFrom = '';
                      _invoiceTo = '';
                    });
                  },
                  child: const Text('Clear Advanced Filters'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  void _openEditLRDialog(Invoice inv) {
    final transportCtrl = TextEditingController(text: inv.transportBy ?? '');
    final lrNoCtrl = TextEditingController(text: inv.lrNo ?? '');
    final lrDateCtrl = TextEditingController(
      text: inv.lrDate ?? DateFormat('dd MMM yyyy').format(DateTime.now()),
    );
    final challanCtrl = TextEditingController(text: inv.challanNo ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.local_shipping_outlined, color: AppColors.primary),
            const SizedBox(width: 8),
            Text('Add / Edit LR', style: AppTextStyles.headlineSm),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: TextEditingController(text: inv.invoiceNo),
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Invoice Number'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: transportCtrl,
                decoration: const InputDecoration(labelText: 'Transport Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: lrNoCtrl,
                decoration: const InputDecoration(labelText: 'LR Number *'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: lrDateCtrl,
                decoration: const InputDecoration(labelText: 'LR Date'),
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
            onPressed: () async {
              final updated = inv.copyWith(
                challanNo: challanCtrl.text.trim(),
                transportBy: transportCtrl.text.trim(),
                lrNo: lrNoCtrl.text.trim(),
                lrDate: lrDateCtrl.text.trim(),
                updatedAt: DateTime.now(),
              );
              await ref.read(invoiceRepositoryProvider).saveInvoice(updated);
              ref.invalidate(invoicesProvider);
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('LR details updated successfully!'),
                    backgroundColor: AppColors.secondary,
                  ),
                );
              }
            },
            child: const Text('Save LR'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final invoicesAsync = ref.watch(invoicesProvider);
    final companiesAsync = ref.watch(companiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice History', style: AppTextStyles.headlineSm),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(invoicesProvider),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Advanced Filters',
            onPressed: _showAdvancedFilters,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New Invoice',
            onPressed: () => context.push('/invoice/new'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: invoicesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading invoices: $e')),
        data: (allInvoices) {
          final query = _searchController.text.trim().toLowerCase();
          final now = DateTime.now();

          final filtered = allInvoices.where((inv) {
            // Status filter
            final matchesStatus =
                _selectedStatus == 'All' ||
                inv.status.toLowerCase() == _selectedStatus.toLowerCase();

            // Company filter
            final matchesCompany =
                _selectedCompanyId == null || inv.buyerId == _selectedCompanyId;

            // PO filter
            final matchesPo =
                _selectedPoNumber == null ||
                (inv.orderNo != null &&
                    inv.orderNo!.toLowerCase().contains(
                      _selectedPoNumber!.toLowerCase(),
                    )) ||
                inv.items.any(
                  (it) => it.poAllocations.any(
                    (a) => a.poNo.toLowerCase().contains(
                      _selectedPoNumber!.toLowerCase(),
                    ),
                  ),
                );

            // Period filter
            bool matchesPeriod = true;
            if (_selectedPeriod == 'Weekly') {
              // Current week approx
              final weekAgo = now.subtract(const Duration(days: 7));
              matchesPeriod =
                  inv.invoiceDate.isAfter(weekAgo) ||
                  inv.invoiceDate.isAtSameMomentAs(weekAgo);
            } else if (_selectedPeriod == 'This Month') {
              matchesPeriod =
                  inv.invoiceDate.month == now.month &&
                  inv.invoiceDate.year == now.year;
            } else if (_selectedPeriod == 'This Year') {
              matchesPeriod = inv.invoiceDate.year == now.year;
            }

            // Advanced Filters
            bool matchesDateRange = true;
            if (_dateFrom != null && _dateTo != null) {
              matchesDateRange =
                  inv.invoiceDate.isAfter(
                    _dateFrom!.subtract(const Duration(days: 1)),
                  ) &&
                  inv.invoiceDate.isBefore(
                    _dateTo!.add(const Duration(days: 1)),
                  );
            }

            bool matchesInvRange = true;
            if (_invoiceFrom.isNotEmpty && _invoiceTo.isNotEmpty) {
              final invNum =
                  int.tryParse(
                    inv.invoiceNo.replaceAll(RegExp(r'[^0-9]'), ''),
                  ) ??
                  0;
              final fromNum =
                  int.tryParse(
                    _invoiceFrom.replaceAll(RegExp(r'[^0-9]'), ''),
                  ) ??
                  0;
              final toNum =
                  int.tryParse(_invoiceTo.replaceAll(RegExp(r'[^0-9]'), '')) ??
                  999999999;
              matchesInvRange = invNum >= fromNum && invNum <= toNum;
            }

            // Search query across: Invoice Number, Company, PO Number, Buyer, LR Number
            final matchesQuery =
                query.isEmpty ||
                inv.invoiceNo.toLowerCase().contains(query) ||
                inv.buyerName.toLowerCase().contains(query) ||
                (inv.orderNo != null &&
                    inv.orderNo!.toLowerCase().contains(query)) ||
                (inv.lrNo != null && inv.lrNo!.toLowerCase().contains(query)) ||
                inv.items.any(
                  (it) =>
                      it.productName.toLowerCase().contains(query) ||
                      it.poAllocations.any(
                        (a) => a.poNo.toLowerCase().contains(query),
                      ),
                );

            return matchesStatus &&
                matchesCompany &&
                matchesPo &&
                matchesPeriod &&
                matchesQuery &&
                matchesDateRange &&
                matchesInvRange;
          }).toList();

          if (_selectedSort == 'Number Asc') {
            filtered.sort((a, b) => a.invoiceNo.compareTo(b.invoiceNo));
          } else if (_selectedSort == 'Number Desc') {
            filtered.sort((a, b) => b.invoiceNo.compareTo(a.invoiceNo));
          } else {
            filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          }

          final totalReconciled = allInvoices
              .where((i) => i.status != 'rejected')
              .fold(0.0, (sum, i) => sum + i.grandTotal);
          final paidCount = allInvoices.where((i) => i.status == 'paid').length;
          final pendingCount = allInvoices
              .where((i) => i.status == 'pending')
              .length;
          final rejectedCount = allInvoices
              .where((i) => i.status == 'rejected')
              .length;

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(invoicesProvider),
            child: Column(
              children: [
                // Search Input
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 6.0,
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search invoice, buyer, PO, LR, product...',
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

                // KPI Ribbon with Indian Comma Formatting
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 4.0,
                  ),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reconciled Total',
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '₹${CurrencyFormatter.formatNumber(totalReconciled)}',
                            style: AppTextStyles.headlineSm.copyWith(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${allInvoices.length} Total Invoices',
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Wrap(
                            alignment: WrapAlignment.end,
                            spacing: 6,
                            runSpacing: 2,
                            children: [
                              _buildSummaryDot(
                                AppColors.paidDot,
                                '$paidCount Paid',
                              ),
                              _buildSummaryDot(
                                AppColors.pendingDot,
                                '$pendingCount Pending',
                              ),
                              if (rejectedCount > 0)
                                _buildSummaryDot(
                                  AppColors.error,
                                  '$rejectedCount Rejected',
                                ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Status Chips: ALL, PENDING, PAID, REJECTED (PARTIAL REMOVED)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 6.0,
                  ),
                  child: Row(
                    children: [
                      _buildStatusFilterChip('All'),
                      const SizedBox(width: 8),
                      _buildStatusFilterChip('Pending'),
                      const SizedBox(width: 8),
                      _buildStatusFilterChip('Paid'),
                      const SizedBox(width: 8),
                      _buildStatusFilterChip('Rejected'),
                      const SizedBox(width: 12),
                      DropdownButton<String>(
                        value: _selectedPeriod,
                        underline: const SizedBox(),
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'All',
                            child: Text('All Time'),
                          ),
                          DropdownMenuItem(
                            value: 'Weekly',
                            child: Text('Weekly'),
                          ),
                          DropdownMenuItem(
                            value: 'This Month',
                            child: Text('This Month'),
                          ),
                          DropdownMenuItem(
                            value: 'This Year',
                            child: Text('This Year'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null)
                            setState(() => _selectedPeriod = val);
                        },
                      ),
                      const SizedBox(width: 10),
                      // Company Filter Dropdown
                      companiesAsync.when(
                        data: (comps) => DropdownButton<String?>(
                          value: _selectedCompanyId,
                          hint: const Text(
                            'All Companies',
                            style: TextStyle(fontSize: 12),
                          ),
                          underline: const SizedBox(),
                          style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('All Companies'),
                            ),
                            ...comps.map(
                              (c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(
                                  c.shortName.isNotEmpty ? c.shortName : c.name,
                                ),
                              ),
                            ),
                          ],
                          onChanged: (val) =>
                              setState(() => _selectedCompanyId = val),
                        ),
                        loading: () => const SizedBox(),
                        error: (_, __) => const SizedBox(),
                      ),
                    ],
                  ),
                ),

                // Invoices List
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.receipt_long_outlined,
                                size: 48,
                                color: AppColors.onSurfaceVariant,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No matching invoices found',
                                style: AppTextStyles.bodyMd,
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () => context.push('/invoice/new'),
                                child: const Text('Create New Invoice'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 4.0,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final inv = filtered[index];
                            final quantities = inv.items
                                .map(
                                  (i) =>
                                      'Qty. ${CurrencyFormatter.formatQuantity(i.quantity)}',
                                )
                                .join(', ');
                            final pos = inv.items
                                .map((i) {
                                  if (i.poAllocations.isNotEmpty)
                                    return i.poAllocations.first.poNo;
                                  return i.poId;
                                })
                                .where((id) => id != null && id.isNotEmpty)
                                .toSet()
                                .join(', ');
                            final firstDesc = quantities.isNotEmpty
                                ? quantities
                                : 'Invoice items';
                            final poLabel = pos.isNotEmpty ? pos : 'N/A';

                            final hasLr =
                                inv.lrNo != null && inv.lrNo!.trim().isNotEmpty;
                            final isRejected = inv.status == 'rejected';

                            return InkWell(
                              onTap: () => context.push('/invoice/${inv.id}'),
                              borderRadius: BorderRadius.circular(16),
                              child: InvoiceCard(
                                invoiceNo: inv.invoiceNo,
                                buyerName: inv.buyerName,
                                amount:
                                    '₹${CurrencyFormatter.formatNumber(inv.grandTotal)}',
                                date: AppDateFormatter.formatDate(
                                  inv.invoiceDate,
                                ),
                                description: firstDesc,
                                poNumber: poLabel,
                                status: _mapStatus(inv.status),
                                hasLr: hasLr,
                                isPaid: inv.status == 'paid',
                                actionLabel: hasLr ? 'LR DONE ✓' : 'ADD LR',
                                actionIcon: hasLr
                                    ? Icons.check_circle
                                    : Icons.local_shipping_outlined,
                                onAction: () {
                                  if (!isRejected) _openEditLRDialog(inv);
                                },
                                onView: () =>
                                    context.push('/invoice/${inv.id}'),
                                onWhatsApp: () => _sharePdf(inv),
                                onPayment: () async {
                                  if (inv.status != 'paid') {
                                    await ref
                                        .read(invoiceRepositoryProvider)
                                        .updatePaymentStatus(inv.id, true);
                                    ref.invalidate(invoicesProvider);
                                    ref.invalidate(paymentsProvider);
                                  }
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/invoice/new'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: AppColors.onPrimary),
        label: Text(
          'New Invoice',
          style: AppTextStyles.labelLg.copyWith(color: AppColors.onPrimary),
        ),
      ),
    );
  }

  Widget _buildStatusFilterChip(String label) {
    final isSelected = _selectedStatus.toLowerCase() == label.toLowerCase();
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedStatus = label),
      selectedColor: AppColors.primary,
      labelStyle: AppTextStyles.labelSm.copyWith(
        color: isSelected ? AppColors.onPrimary : AppColors.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: AppColors.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildSummaryDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.labelSm.copyWith(color: AppColors.onSurface),
        ),
      ],
    );
  }
}

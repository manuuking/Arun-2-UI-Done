import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/date_formatter.dart';
import '../../core/utils/currency_formatter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/company_profile.dart';
import '../providers/providers.dart';

class PaymentsListScreen extends ConsumerStatefulWidget {
  const PaymentsListScreen({super.key});

  @override
  ConsumerState<PaymentsListScreen> createState() => _PaymentsListScreenState();
}

class _PaymentsListScreenState extends ConsumerState<PaymentsListScreen> {
  DateTime? _dateFrom;
  DateTime? _dateTo;
  String _selectedStatus = 'All'; // All, Pending, Paid, Rejected
  String _selectedPeriod = 'All'; // All, Weekly, This Month, This Year
  String? _selectedCompanyId;
  String? _selectedPoNumber;
  String? _fromInvoice;
  String? _toInvoice;

  void _showAdvancedFilters(List<CompanyProfile> companies) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Advanced Filters'),
          content: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (dialogCtx, setModalState) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedCompanyId,
                    decoration: const InputDecoration(labelText: 'Company'),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All Companies'),
                      ),
                      ...companies.map(
                        (c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(c.name, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ],
                    onChanged: (v) =>
                        setModalState(() => _selectedCompanyId = v),
                  ),
                  DropdownButtonFormField<String>(
                    value: _selectedPeriod,
                    decoration: const InputDecoration(labelText: 'Period'),
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All Time')),
                      DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
                      DropdownMenuItem(
                        value: 'This Month',
                        child: Text('This Month'),
                      ),
                      DropdownMenuItem(
                        value: 'This Year',
                        child: Text('This Year'),
                      ),
                    ],
                    onChanged: (v) =>
                        setModalState(() => _selectedPeriod = v ?? 'All'),
                  ),
                  DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All')),
                      DropdownMenuItem(value: 'Paid', child: Text('Paid')),
                      DropdownMenuItem(
                        value: 'Pending',
                        child: Text('Pending'),
                      ),
                    ],
                    onChanged: (v) =>
                        setModalState(() => _selectedStatus = v ?? 'All'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    decoration: const InputDecoration(labelText: 'PO Number'),
                    controller: TextEditingController(text: _selectedPoNumber),
                    onChanged: (v) => _selectedPoNumber = v.trim(),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        initialDateRange: _dateFrom != null && _dateTo != null
                            ? DateTimeRange(start: _dateFrom!, end: _dateTo!)
                            : null,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setModalState(() {
                          _dateFrom = picked.start;
                          _dateTo = picked.end;
                        });
                      }
                    },
                    child: const Text('Select Date Range (From - To)'),
                  ),
                  if (_dateFrom != null && _dateTo != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Selected: ${AppDateFormatter.formatDate(_dateFrom!)} to ${AppDateFormatter.formatDate(_dateTo!)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(labelText: 'From Invoice'),
                          controller: TextEditingController(text: _fromInvoice),
                          onChanged: (v) => _fromInvoice = v.trim(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(labelText: 'To Invoice'),
                          controller: TextEditingController(text: _toInvoice),
                          onChanged: (v) => _toInvoice = v.trim(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      setModalState(() {
                        _dateFrom = null;
                        _dateTo = null;
                        _selectedPoNumber = null;
                        _selectedCompanyId = null;
                        _fromInvoice = null;
                        _toInvoice = null;
                        _selectedPeriod = 'All';
                        _selectedStatus = 'All';
                      });
                    },
                    child: const Text('Clear Filters'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {}); // Apply filters to parent
                Navigator.pop(ctx);
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final paymentsAsync = ref.watch(paymentsProvider);
    final invoicesAsync = ref.watch(invoicesProvider);
    final companiesAsync = ref.watch(companiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Collections', style: AppTextStyles.headlineSm),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Advanced Filters',
            onPressed: () => _showAdvancedFilters(companiesAsync.value ?? []),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(paymentsProvider);
              ref.invalidate(invoicesProvider);
            },
          ),
        ],
      ),
      body: invoicesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (allInvoices) {
          final now = DateTime.now();
          
          return paymentsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (allPayments) {
              final invoices = allInvoices.where((inv) {
                // Calculate actual status
                final invPayments = allPayments.where((p) => p.invoiceId == inv.id).toList();
                final actualPaid = invPayments.fold(0.0, (sum, p) => sum + p.amount);
                String calculatedStatus = 'pending';
                if (actualPaid >= inv.grandTotal && inv.grandTotal > 0) {
                  calculatedStatus = 'paid';
                } else if (actualPaid > 0) {
                  calculatedStatus = 'partial';
                }

                final matchesStatus =
                    _selectedStatus == 'All' ||
                    calculatedStatus == _selectedStatus.toLowerCase();
                
                final matchesCompany =
                    _selectedCompanyId == null || inv.buyerId == _selectedCompanyId;
            final matchesPo =
                _selectedPoNumber == null ||
                _selectedPoNumber!.isEmpty ||
                (inv.orderNo != null &&
                    inv.orderNo!.toLowerCase().contains(
                      _selectedPoNumber!.toLowerCase(),
                    ));

            bool matchesPeriod = true;
            if (_selectedPeriod == 'Weekly') {
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

            bool matchesInvoiceRange = true;
            if ((_fromInvoice != null && _fromInvoice!.isNotEmpty) || (_toInvoice != null && _toInvoice!.isNotEmpty)) {
              int? extractNumber(String s) {
                final match = RegExp(r'\d+').allMatches(s).lastOrNull;
                return match != null ? int.tryParse(match.group(0)!) : null;
              }

              String extractPrefix(String s) {
                final match = RegExp(r'\d+').allMatches(s).lastOrNull;
                return match != null ? s.substring(0, match.start) : s;
              }

              final invNum = extractNumber(inv.invoiceNo);
              final invPrefix = extractPrefix(inv.invoiceNo).toUpperCase();

              if (_fromInvoice != null && _fromInvoice!.isNotEmpty) {
                final fromNum = extractNumber(_fromInvoice!);
                final fromPrefix = extractPrefix(_fromInvoice!).toUpperCase();
                if (fromNum != null && invNum != null && fromPrefix == invPrefix) {
                  if (invNum < fromNum) matchesInvoiceRange = false;
                } else {
                  if (inv.invoiceNo.toUpperCase().compareTo(_fromInvoice!.toUpperCase()) < 0) {
                    matchesInvoiceRange = false;
                  }
                }
              }
              if (matchesInvoiceRange && _toInvoice != null && _toInvoice!.isNotEmpty) {
                final toNum = extractNumber(_toInvoice!);
                final toPrefix = extractPrefix(_toInvoice!).toUpperCase();
                if (toNum != null && invNum != null && toPrefix == invPrefix) {
                  if (invNum > toNum) matchesInvoiceRange = false;
                } else {
                  if (inv.invoiceNo.toUpperCase().compareTo(_toInvoice!.toUpperCase()) > 0) {
                    matchesInvoiceRange = false;
                  }
                }
              }
            }

            return matchesStatus &&
                matchesCompany &&
                matchesPo &&
                matchesPeriod &&
                matchesDateRange &&
                matchesInvoiceRange;
          }).toList();

              final paymentsForInvoices = allPayments.where((p) {
                return invoices.any((inv) => inv.id == p.invoiceId);
              }).toList();

              final totalCollected = paymentsForInvoices.fold(
                0.0,
                (sum, p) => sum + p.amount,
              );

              final totalInvoiced = invoices.fold(
                0.0,
                (sum, i) => sum + i.grandTotal,
              );

              final totalPending = (totalInvoiced - totalCollected).clamp(
                0.0,
                double.infinity,
              );


              return Column(
                children: [
                  // KPI Ribbon
                  Container(
                    margin: const EdgeInsets.all(16.0),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TOTAL COLLECTED',
                              style: AppTextStyles.labelSm.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Rs ${CurrencyFormatter.formatNumber(totalCollected)}',
                              style: AppTextStyles.headlineSm.copyWith(
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          height: 36,
                          width: 1,
                          color: AppColors.outlineVariant,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'OUTSTANDING',
                              style: AppTextStyles.labelSm.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Rs ${CurrencyFormatter.formatNumber(totalPending)}',
                              style: AppTextStyles.headlineSm.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 4.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TRANSACTION LOG (${invoices.length})',
                          style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // List
                  Expanded(
                    child: invoices.isEmpty
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
                                  'No transactions found.',
                                  style: AppTextStyles.bodyMd,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            itemCount: invoices.length,
                            itemBuilder: (context, index) {
                              final inv = invoices[index];
                              
                              final invPayments = allPayments.where((p) => p.invoiceId == inv.id).toList();
                              final actualPaid = invPayments.fold(0.0, (sum, p) => sum + p.amount);
                              
                              String displayStatus = 'PENDING';
                              if (actualPaid >= inv.grandTotal && inv.grandTotal > 0) {
                                displayStatus = 'PAID';
                              } else if (actualPaid > 0) {
                                displayStatus = 'PARTIAL';
                              }
                              
                              DateTime? latestPaymentDate;
                              if (invPayments.isNotEmpty) {
                                invPayments.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
                                latestPaymentDate = invPayments.first.paymentDate;
                              }

                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                child: InkWell(
                                  onTap: () => context.push('/invoice/${inv.id}'),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '${inv.invoiceNo} | ${inv.buyerName}',
                                                style: AppTextStyles.labelSm.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.onSurface,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: displayStatus == 'PAID' 
                                                    ? AppColors.paidBg 
                                                    : (displayStatus == 'PARTIAL' ? Colors.orange.shade100 : AppColors.pendingBg),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                displayStatus,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: displayStatus == 'PAID' 
                                                      ? AppColors.paidText 
                                                      : (displayStatus == 'PARTIAL' ? Colors.orange.shade800 : AppColors.pendingText),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Wrap(
                                          spacing: 8,
                                          crossAxisAlignment: WrapCrossAlignment.center,
                                          children: [
                                            Text(
                                              '₹${CurrencyFormatter.formatNumber(inv.grandTotal)}',
                                              style: AppTextStyles.bodySm.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              '| Paid ₹${CurrencyFormatter.formatNumber(actualPaid)}',
                                              style: AppTextStyles.bodySm.copyWith(
                                                color: Colors.green.shade700,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            if (latestPaymentDate != null) ...[
                                              Text(
                                                '| ${AppDateFormatter.formatDate(latestPaymentDate)}',
                                                style: AppTextStyles.bodySm.copyWith(
                                                  color: AppColors.onSurfaceVariant,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

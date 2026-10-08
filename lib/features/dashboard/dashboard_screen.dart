import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/invoice.dart';
import '../../shared/widgets/invoice_card.dart';
import '../../shared/widgets/status_badge.dart';
import '../providers/providers.dart';

import 'package:flutter/services.dart';
import 'package:printing/printing.dart';

import '../pdf/invoice_pdf_generator.dart';
import 'widgets/kpi_grid.dart';
import 'widgets/payment_reminder_widget.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  void _openEditLRDialog(Invoice inv) {
    final transportCtrl = TextEditingController(text: inv.transportBy ?? '');
    final lrNoCtrl = TextEditingController(text: inv.lrNo ?? '');
    final lrDateCtrl = TextEditingController(
      text: inv.lrDate ?? AppDateFormatter.formatDate(DateTime.now()),
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
                    content: Text('LR updated successfully!'),
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

  String _recentInvoicesSort =
      'Recent'; // 'Number Asc', 'Number Desc', 'Recent', 'Missing LR'

  @override
  Widget build(BuildContext context) {
    final invoicesAsync = ref.watch(invoicesProvider);
    final poSummariesAsync = ref.watch(companyPOSummariesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ARUN INVOICE PRO',
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            ValueListenableBuilder(
              valueListenable: Hive.box('settings').listenable(keys: ['seller_profile']),
              builder: (context, Box box, _) {
                final Map<dynamic, dynamic>? sellerMap = box.get('seller_profile');
                final name = sellerMap != null ? (sellerMap['name'] ?? 'Arun Mensware Service') : 'Arun Mensware Service';
                return Text(
                  name,
                  style: AppTextStyles.headlineSm.copyWith(fontSize: 16),
                );
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(invoicesProvider);
              ref.invalidate(companyPOSummariesProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            tooltip: 'PO Dashboard',
            onPressed: () => context.push('/po-dashboard'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(invoicesProvider);
          ref.invalidate(companyPOSummariesProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PaymentReminderWidget(),
              // Create Invoice Hero Card
              InkWell(
                onTap: () => context.push('/invoice/new'),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.secondaryContainer,
                        AppColors.surfaceContainerHigh,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outlineVariant),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CREATE NEW INVOICE',
                                style: AppTextStyles.labelLg.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              Text(
                                'Sequential GST Tax Invoice',
                                style: AppTextStyles.bodySm.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // KPI Grid (Indian Comma Formatted)
              const KpiGrid(),

              const SizedBox(height: 16),

              // Missing LR Warning Banner (Section 3: Highlight invoices with missing LR)
              invoicesAsync.when(
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
                data: (invoices) {
                  final missingLrList = invoices
                      .where(
                        (i) =>
                            i.status != 'rejected' &&
                            (i.lrNo == null || i.lrNo!.trim().isEmpty),
                      )
                      .toList();

                  if (missingLrList.isEmpty) return const SizedBox();

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.deepOrange,
                              size: 24,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${missingLrList.length} Invoices Missing LR Number',
                                    style: AppTextStyles.labelMd.copyWith(
                                      color: Colors.deepOrange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Update transport dispatch details for smooth tracking',
                                    style: AppTextStyles.bodySm.copyWith(
                                      color: Colors.brown[800],
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...missingLrList.map(
                          (inv) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.orange.shade200,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${inv.invoiceNo} • ${AppDateFormatter.formatDate(inv.invoiceDate)}',
                                          style: AppTextStyles.labelSm.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          inv.buyerName,
                                          style: AppTextStyles.bodySm.copyWith(
                                            color: AppColors.onSurfaceVariant,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'LR Number: Missing',
                                          style: AppTextStyles.bodySm.copyWith(
                                            color: Colors.deepOrange,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => _openEditLRDialog(inv),
                                    child: const Text(
                                      'ADD LR',
                                      style: TextStyle(
                                        color: Colors.deepOrange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // PO Dashboard Quick Progress Widget (Section 6 & 31)
              poSummariesAsync.when(
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
                data: (summaries) {
                  if (summaries.isEmpty) return const SizedBox();
                  final totalRemaining = summaries.fold<double>(
                    0.0,
                    (s, c) => s + c.totalRemainingQty,
                  );
                  final totalOrdered = summaries.fold<double>(
                    0.0,
                    (s, c) => s + c.totalOrderedQty,
                  );
                  final ratio = totalOrdered > 0
                      ? (totalRemaining / totalOrdered).clamp(0.0, 1.0)
                      : 0.0;

                  return InkWell(
                    onTap: () => context.push('/po-dashboard'),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.analytics_outlined,
                                    size: 18,
                                    color: Colors.purple,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'PO STATUS SUMMARY',
                                    style: AppTextStyles.labelSm.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'View Dashboard',
                                    style: AppTextStyles.labelSm.copyWith(
                                      color: Colors.purple.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    size: 16,
                                    color: Colors.purple.shade700,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${summaries.length} Companies Active',
                                style: AppTextStyles.bodySm.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                '${CurrencyFormatter.formatQuantity(totalRemaining)} remaining',
                                style: AppTextStyles.labelSm.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 8,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.purple.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: LayoutBuilder(
                              builder: (ctx, constraints) {
                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    width: constraints.maxWidth * ratio,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.purple.shade400,
                                          Colors.purple.shade700,
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Recent Invoices Section
              invoicesAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (e, _) => Text('Error loading recent invoices: $e'),
                data: (invoices) {
                  var activeInvoices = invoices
                      .where((i) => i.status != 'rejected')
                      .toList();

                  // Sort logic
                  if (_recentInvoicesSort == 'Missing LR') {
                    activeInvoices = activeInvoices.where((a) {
                      return a.lrNo == null || a.lrNo!.trim().isEmpty;
                    }).toList();
                    activeInvoices.sort(
                      (a, b) => b.updatedAt.compareTo(a.updatedAt),
                    );
                  } else if (_recentInvoicesSort == 'Number Asc') {
                    activeInvoices.sort((a, b) {
                      final numA =
                          int.tryParse(
                            a.invoiceNo.replaceAll(RegExp(r'[^0-9]'), ''),
                          ) ??
                          0;
                      final numB =
                          int.tryParse(
                            b.invoiceNo.replaceAll(RegExp(r'[^0-9]'), ''),
                          ) ??
                          0;
                      return numA.compareTo(numB);
                    });
                  } else if (_recentInvoicesSort == 'Number Desc') {
                    activeInvoices.sort((a, b) {
                      final numA =
                          int.tryParse(
                            a.invoiceNo.replaceAll(RegExp(r'[^0-9]'), ''),
                          ) ??
                          0;
                      final numB =
                          int.tryParse(
                            b.invoiceNo.replaceAll(RegExp(r'[^0-9]'), ''),
                          ) ??
                          0;
                      return numB.compareTo(numA);
                    });
                  } else {
                    // Default to Recent (Updated At)
                    activeInvoices.sort(
                      (a, b) => b.updatedAt.compareTo(a.updatedAt),
                    );
                  }

                  final recent = activeInvoices
                      .take(10)
                      .toList(); // Show up to 10 based on sort

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Recent Invoices',
                                style: AppTextStyles.headlineSm,
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(
                                  '${activeInvoices.length}',
                                  style: AppTextStyles.labelSm.copyWith(
                                    color: AppColors.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () => context.go('/invoices'),
                            child: Row(
                              children: [
                                Text(
                                  'View All',
                                  style: AppTextStyles.labelMd.copyWith(
                                    color: AppColors.secondary,
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right,
                                  size: 16,
                                  color: AppColors.secondary,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: DropdownButton<String>(
                          value: _recentInvoicesSort,
                          style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(
                              value: 'Recent',
                              child: Text('Recently Updated'),
                            ),
                            DropdownMenuItem(
                              value: 'Number Asc',
                              child: Text('Number Asc'),
                            ),
                            DropdownMenuItem(
                              value: 'Number Desc',
                              child: Text('Number Desc'),
                            ),
                            DropdownMenuItem(
                              value: 'Missing LR',
                              child: Text('Missing LR First'),
                            ),
                          ],
                          onChanged: (v) {
                            if (v != null)
                              setState(() => _recentInvoicesSort = v);
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...recent.map((inv) {
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
                        final desc = quantities.isNotEmpty
                            ? quantities
                            : 'Invoice items';
                        final poLabel = pos.isNotEmpty ? pos : 'N/A';

                        InvoiceStatus st = InvoiceStatus.pending;
                        if (inv.status == 'paid') st = InvoiceStatus.paid;

                        final hasLr =
                            inv.lrNo != null && inv.lrNo!.trim().isNotEmpty;

                        return InkWell(
                          onTap: () => context.push('/invoice/${inv.id}'),
                          child: InvoiceCard(
                            invoiceNo: inv.invoiceNo,
                            buyerName: inv.buyerName,
                            amount:
                                '₹${CurrencyFormatter.formatNumber(inv.grandTotal)}',
                            date: AppDateFormatter.formatDate(inv.invoiceDate),
                            description: desc,
                            poNumber: poLabel,
                            status: st,
                            hasLr: hasLr,
                            isPaid: st == InvoiceStatus.paid,
                            actionLabel: hasLr ? 'LR DONE ✓' : 'ADD LR',
                            actionIcon: hasLr
                                ? Icons.check_circle
                                : Icons.local_shipping_outlined,
                            onAction: () => _openEditLRDialog(inv),
                            onView: () => context.push('/invoice/${inv.id}'),
                            onWhatsApp: () => _sharePdf(inv),
                            onPayment: () async {
                              if (st != InvoiceStatus.paid) {
                                await ref
                                    .read(invoiceRepositoryProvider)
                                    .updatePaymentStatus(inv.id, true);
                                ref.invalidate(invoicesProvider);
                                ref.invalidate(paymentsProvider);
                              }
                            },
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

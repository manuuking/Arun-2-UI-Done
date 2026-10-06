import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

import '../../core/services/pin_security_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/invoice.dart';
import '../pdf/invoice_pdf_generator.dart';
import '../pdf/pdf_preview_page.dart';
import '../providers/providers.dart';

class InvoiceDetailScreen extends ConsumerStatefulWidget {
  final String? id;
  final Invoice? temporaryInvoice;
  final bool isTemporaryPreview;

  const InvoiceDetailScreen({
    super.key,
    this.id,
    this.temporaryInvoice,
    this.isTemporaryPreview = false,
  });

  @override
  ConsumerState<InvoiceDetailScreen> createState() =>
      _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends ConsumerState<InvoiceDetailScreen> {
  bool _isDuplicate = false;
  bool _isSavingFinal = false;
  Invoice? _savedStateInvoice;

  @override
  void initState() {
    super.initState();
    if (widget.temporaryInvoice != null) {
      _isDuplicate = widget.temporaryInvoice!.invoiceType == 'duplicate';
    }
  }

  String _getSafeFileName(Invoice inv) {
    final cleanComp = inv.buyerName
        .replaceAll(RegExp(r'M/s\s*', caseSensitive: false), '')
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), '-');
    return '${inv.invoiceNo}_$cleanComp.pdf';
  }

  // 1. SAVE PDF (Finalize to Database + Drive sync abstraction)
  void _savePdfFinal(Invoice inv) async {
    setState(() => _isSavingFinal = true);

    try {
      final now = DateTime.now();
      // Generate final PDF bytes to verify layout
      final bytes = await InvoicePdfGenerator.generateInvoice(
        invoice: inv,
        isDuplicate: _isDuplicate,
      );

      // Save locally to documents folder (representing Google Drive / local storage)
      final dir = await getApplicationDocumentsDirectory();
      final fileName = _getSafeFileName(inv);
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);

      // Save structured invoice data into Hive / Firebase
      final finalizedInvoice = inv.copyWith(
        driveFileId: 'drive_${inv.invoiceNo}_${now.millisecondsSinceEpoch}',
        driveFilePath: file.path,
        updatedAt: now,
      );

      await ref.read(invoiceRepositoryProvider).saveInvoice(finalizedInvoice);

      // Invalidate all related providers to reconcile POs, Revenue, KPI and lists
      ref.invalidate(invoicesProvider);
      ref.invalidate(purchaseOrdersProvider);
      ref.invalidate(companyPOSummariesProvider);
      ref.invalidate(dashboardRevenueProvider('2026-2027'));
      ref.invalidate(pendingInvoicesCountProvider);
      if (widget.id != null) {
        ref.invalidate(singleInvoiceProvider(widget.id!));
      }

      setState(() {
        _savedStateInvoice = finalizedInvoice;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Invoice ${inv.invoiceNo} successfully finalized & saved!',
            ),
            backgroundColor: AppColors.secondary,
            action: SnackBarAction(
              label: 'VIEW FILE',
              textColor: Colors.white,
              onPressed: () => OpenFilex.open(file.path),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Save error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSavingFinal = false);
    }
  }

  // 2. DOWNLOAD PDF
  void _downloadPdf(Invoice inv) async {
    try {
      final bytes = await InvoicePdfGenerator.generateInvoice(
        invoice: inv,
        isDuplicate: _isDuplicate,
      );
      final dir = await getApplicationDocumentsDirectory();
      final fileName = _getSafeFileName(inv);
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Downloaded: $fileName'),
            backgroundColor: AppColors.secondary,
            action: SnackBarAction(
              label: 'OPEN',
              textColor: Colors.white,
              onPressed: () => OpenFilex.open(file.path),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // 3. SHARE PDF / WhatsApp (Native Android Share mechanism)
  void _sharePdf(Invoice inv) async {
    final bytes = await InvoicePdfGenerator.generateInvoice(
      invoice: inv,
      isDuplicate: _isDuplicate,
    );
    final fileName = _getSafeFileName(inv);
    await Printing.sharePdf(bytes: bytes, filename: fileName);
  }

  // 4. PRINT PDF
  void _printPdf(Invoice inv) async {
    final bytes = await InvoicePdfGenerator.generateInvoice(
      invoice: inv,
      isDuplicate: _isDuplicate,
    );
    await Printing.layoutPdf(onLayout: (_) => bytes);
  }

  // Format WhatsApp LR Copy Text
  void _copyWhatsAppText(Invoice inv) {
    final dateStr = DateFormat('dd/MM/yyyy').format(inv.invoiceDate);
    final text =
        '''
*${inv.buyerName}*
Invoice No: ${inv.invoiceNo}
Dated: $dateStr
Total Amt: Rs ${CurrencyFormatter.formatNumber(inv.grandTotal)}
Transport: ${inv.transportBy ?? "Direct"}
LR No: ${inv.lrNo ?? "-"}
LR Date: ${inv.lrDate ?? dateStr}
Cartons: ${inv.parcelNo ?? "1 Box"}

Thank you,
Arun Mensware Service
Rajkot (Mo: +91 9824417257)
'''
            .trim();

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('WhatsApp message copied to clipboard!'),
        backgroundColor: AppColors.secondary,
      ),
    );
  }

  // Fixed BUG: Edit LR must ONLY open LR editing dialog, NEVER payment!
  void _editTransportAndLR(Invoice inv) {
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
            Text('Edit LR & Transport', style: AppTextStyles.headlineSm),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: challanCtrl,
                decoration: const InputDecoration(labelText: 'Challan Number'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: transportCtrl,
                decoration: const InputDecoration(labelText: 'Transport Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: lrNoCtrl,
                decoration: const InputDecoration(labelText: 'LR Number'),
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
              ref.invalidate(singleInvoiceProvider(inv.id));
              ref.invalidate(invoicesProvider);
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'LR & Transport details updated successfully!',
                    ),
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

  // Simple Payment Checkbox Toggle (Section 28)
  void _togglePaymentStatus(Invoice inv, bool isPaid) async {
    await ref
        .read(invoiceRepositoryProvider)
        .updatePaymentStatus(inv.id, isPaid);
    ref.invalidate(singleInvoiceProvider(inv.id));
    ref.invalidate(invoicesProvider);
    ref.invalidate(pendingInvoicesCountProvider);
    ref.invalidate(paymentsProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isPaid ? 'Invoice marked as PAID' : 'Invoice marked as PENDING',
          ),
          backgroundColor: isPaid ? AppColors.secondary : Colors.grey[700],
        ),
      );
    }
  }

  // Reject Invoice (Section 27) with 4-digit Admin PIN
  void _rejectInvoice(Invoice inv) async {
    final authorized = await PinSecurityService.requestPinAuthorization(
      context,
      title: 'Reject Invoice ${inv.invoiceNo}',
      message: 'Rejecting this invoice will release all allocated PO quantities back to stock. Invoice will remain in history as REJECTED. 4-digit Admin PIN required.',
    );

    if (!authorized) return;

    await ref.read(invoiceRepositoryProvider).rejectInvoice(inv.id);
    ref.invalidate(singleInvoiceProvider(inv.id));
    ref.invalidate(invoicesProvider);
    ref.invalidate(purchaseOrdersProvider);
    ref.invalidate(companyPOSummariesProvider);
    ref.invalidate(pendingInvoicesCountProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Invoice ${inv.invoiceNo} marked as REJECTED. PO balance restored!',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // If working with temporary unsaved invoice or recently saved invoice
    if (widget.temporaryInvoice != null) {
      final currentInv = _savedStateInvoice ?? widget.temporaryInvoice!;
      final isFinalized = _savedStateInvoice != null;
      return _buildScaffoldForInvoice(currentInv, isTemporary: !isFinalized);
    }

    // Otherwise load from repository
    final invoiceAsync = ref.watch(singleInvoiceProvider(widget.id!));
    return invoiceAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(
        appBar: AppBar(title: const Text('Invoice Details')),
        body: Center(child: Text('Error: $err')),
      ),
      data: (inv) {
        if (inv == null) {
          return const Scaffold(body: Center(child: Text('Invoice not found')));
        }
        return _buildScaffoldForInvoice(inv, isTemporary: false);
      },
    );
  }

  Widget _buildScaffoldForInvoice(Invoice inv, {required bool isTemporary}) {
    final isPaid = inv.status == 'paid';
    final isRejected = inv.status == 'rejected';

    return Scaffold(
      appBar: AppBar(
        title: Text(inv.invoiceNo, style: AppTextStyles.headlineSm),
        actions: [
          if (!isTemporary && !isRejected) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Invoice',
              onPressed: () async {
                final auth = await PinSecurityService.requestPinAuthorization(
                  context,
                  title: 'Edit Invoice',
                  message: 'Enter PIN to edit this invoice.',
                );
                if (auth && context.mounted) {
                  context.push('/invoice/edit/${inv.id}');
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.local_shipping_outlined),
              tooltip: 'Edit LR',
              onPressed: () => _editTransportAndLR(inv),
            ),
          ],
          if (widget.temporaryInvoice != null)
            IconButton(
              icon: const Icon(Icons.home),
              tooltip: 'Home',
              onPressed: () => context.go('/'),
            ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share',
            onPressed: () => _sharePdf(inv),
          ),
          if (!isTemporary)
            PopupMenuButton<String>(
              onSelected: (val) async {
                if (val == 'reject') {
                  if (!isRejected) {
                    final auth =
                        await PinSecurityService.requestPinAuthorization(
                          context,
                          title: 'Reject Invoice',
                          message: 'Enter PIN to reject this invoice.',
                        );
                    if (auth && context.mounted) {
                      await ref
                          .read(invoiceRepositoryProvider)
                          .rejectInvoice(inv.id);
                      ref.invalidate(invoicesProvider);
                      if (context.mounted) Navigator.pop(context);
                    }
                  }
                } else if (val == 'delete') {
                  final auth = await PinSecurityService.requestPinAuthorization(
                    context,
                    title: 'Delete Invoice',
                    message: 'Enter PIN to permanently delete this invoice.',
                  );
                  if (auth && context.mounted) {
                    await ref
                        .read(invoiceRepositoryProvider)
                        .deleteInvoice(inv.id);
                    ref.invalidate(invoicesProvider);
                    if (context.mounted) Navigator.pop(context);
                  }
                }
              },
              itemBuilder: (ctx) => [
                if (!isRejected)
                  const PopupMenuItem(
                    value: 'reject',
                    child: Text('Reject Invoice'),
                  ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text(
                    'Delete Invoice',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
              ],
            ),

          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // Banner for Temporary Preview vs Final Status
          if (isTemporary)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.amber[100],
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'TEMPORARY PREVIEW — Verify layout before saving',
                      style: AppTextStyles.labelSm.copyWith(
                        color: Colors.brown[900],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            // Status & Simple Payment Checkbox Bar (Section 28)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              color: AppColors.surfaceContainerLowest,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isPaid
                                ? AppColors.paidBg
                                : (isRejected
                                      ? AppColors.errorContainer
                                      : AppColors.pendingBg),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            inv.status.toUpperCase(),
                            style: AppTextStyles.labelSm.copyWith(
                              color: isPaid
                                  ? AppColors.paidText
                                  : (isRejected
                                        ? AppColors.onErrorContainer
                                        : AppColors.pendingText),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (!isRejected)
                          Row(
                            children: [
                              Checkbox(
                                value: isPaid,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                                activeColor: AppColors.secondary,
                                onChanged: (val) {
                                  if (val != null)
                                    _togglePaymentStatus(inv, val);
                                },
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Payment Received',
                                style: AppTextStyles.labelSm.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    // Duplicate Switch
                    Row(
                      children: [
                        Text(
                          _isDuplicate ? 'Duplicate' : 'Original',
                          style: AppTextStyles.labelSm.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _isDuplicate
                                ? AppColors.primary
                                : AppColors.onSurface,
                          ),
                        ),
                        Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            value: _isDuplicate,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            onChanged: (val) =>
                                setState(() => _isDuplicate = val),
                            activeThumbColor: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Clean Action Ribbon
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.outlineVariant),
                bottom: BorderSide(color: AppColors.outlineVariant),
              ),
              color: AppColors.surfaceContainerLowest,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildRibbonAction(
                  Icons.download,
                  'Download',
                  () => _downloadPdf(inv),
                ),
                _buildRibbonAction(Icons.share, 'Share', () => _sharePdf(inv)),
                _buildRibbonAction(Icons.print, 'Print', () => _printPdf(inv)),
                _buildRibbonAction(
                  Icons.chat,
                  'Copy LR',
                  () => _copyWhatsAppText(inv),
                ),
                if (!isTemporary && !isRejected)
                  _buildRibbonAction(
                    Icons.cancel_outlined,
                    'Reject',
                    () => _rejectInvoice(inv),
                    color: AppColors.error,
                  ),
              ],
            ),
          ),

          // Main A4 PDF Preview widget
          Expanded(
            child: PdfPreviewPage(invoice: inv, isDuplicate: _isDuplicate),
          ),
        ],
      ),
      bottomNavigationBar: isTemporary
          ? SafeArea(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('EDIT FORM'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 5,
                      child: ElevatedButton.icon(
                        onPressed: _isSavingFinal
                            ? null
                            : () => _savePdfFinal(inv),
                        icon: _isSavingFinal
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.check_circle, size: 18),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        label: Text(
                          _isSavingFinal ? 'SAVING...' : 'SAVE PDF',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildRibbonAction(
    IconData icon,
    String label,
    VoidCallback onTap, {
    Color? color,
  }) {
    final c = color ?? AppColors.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          children: [
            Icon(icon, size: 20, color: c),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.labelSm.copyWith(color: c)),
          ],
        ),
      ),
    );
  }
}

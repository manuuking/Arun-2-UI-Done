import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/invoice.dart';
import '../../data/models/payment.dart';
import '../providers/providers.dart';

class PaymentRecordScreen extends ConsumerStatefulWidget {
  final String invoiceId;

  const PaymentRecordScreen({super.key, required this.invoiceId});

  @override
  ConsumerState<PaymentRecordScreen> createState() =>
      _PaymentRecordScreenState();
}

class _PaymentRecordScreenState extends ConsumerState<PaymentRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _paymentDate = DateTime.now();
  String _paymentMode = 'NEFT/RTGS';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  void _initAmount(Invoice inv) {
    if (_amountController.text.isEmpty) {
      final remaining = (inv.grandTotal - inv.paidAmount).clamp(
        0.0,
        double.infinity,
      );
      _amountController.text = remaining.toStringAsFixed(2);
    }
  }

  void _savePayment(Invoice inv) async {
    if (!_formKey.currentState!.validate()) return;

    final enteredAmount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    if (enteredAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final payment = Payment(
        id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
        invoiceId: inv.id,
        amount: enteredAmount,
        paymentDate: _paymentDate,
        method: _paymentMode,
        referenceNo: _referenceController.text.trim().isNotEmpty
            ? _referenceController.text.trim()
            : null,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        createdAt: DateTime.now(),
      );

      await ref.read(paymentRepositoryProvider).recordPayment(payment);
      ref.invalidate(singleInvoiceProvider(inv.id));
      ref.invalidate(invoicesProvider);
      ref.invalidate(paymentsProvider);
      ref.invalidate(pendingInvoicesCountProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Payment of Rs ${enteredAmount.toStringAsFixed(2)} recorded successfully!',
            ),
            backgroundColor: AppColors.secondary,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error recording payment: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final invoiceAsync = ref.watch(singleInvoiceProvider(widget.invoiceId));

    return invoiceAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (inv) {
        if (inv == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Record Payment')),
            body: const Center(child: Text('Invoice not found')),
          );
        }

        _initAmount(inv);
        final remaining = (inv.grandTotal - inv.paidAmount).clamp(
          0.0,
          double.infinity,
        );

        return Scaffold(
          appBar: AppBar(
            title: Text('Record Payment', style: AppTextStyles.headlineSm),
            actions: [
              TextButton(
                onPressed: _isLoading ? null : () => _savePayment(inv),
                child: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
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
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'PENDING AMOUNT',
                          style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rs ${remaining.toStringAsFixed(2)}',
                          style: AppTextStyles.headlineLg.copyWith(
                            color: remaining > 0
                                ? AppColors.error
                                : AppColors.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Invoice: ${inv.invoiceNo} • ${inv.buyerName}',
                          style: AppTextStyles.bodySm.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Total: Rs ${inv.grandTotal.toStringAsFixed(2)} | Already Paid: Rs ${inv.paidAmount.toStringAsFixed(2)}',
                          style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount Received (Rs) *',
                      prefixText: 'Rs ',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: AppTextStyles.headlineMd,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty)
                        return 'Enter amount';
                      final num = double.tryParse(val.trim());
                      if (num == null || num <= 0)
                        return 'Enter a positive number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Payment Date *',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    controller: TextEditingController(
                      text: DateFormat('dd MMM yyyy').format(_paymentDate),
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _paymentDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setState(() => _paymentDate = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _paymentMode,
                    decoration: const InputDecoration(
                      labelText: 'Payment Mode *',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'NEFT/RTGS',
                        child: Text('NEFT/RTGS'),
                      ),
                      DropdownMenuItem(value: 'Cheque', child: Text('Cheque')),
                      DropdownMenuItem(value: 'UPI', child: Text('UPI')),
                      DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _paymentMode = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _referenceController,
                    decoration: const InputDecoration(
                      labelText: 'Reference / UTR / Cheque No.',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (Optional)',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : () => _savePayment(inv),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'SUBMIT PAYMENT',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

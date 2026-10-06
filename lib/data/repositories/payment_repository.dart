import 'package:hive_flutter/hive_flutter.dart';

import '../models/payment.dart';
import '../models/invoice.dart';

abstract class PaymentRepository {
  Future<List<Payment>> getPaymentsForInvoice(String invoiceId);
  Future<List<Payment>> getAllPayments();
  Future<void> recordPayment(Payment payment);
}

class HivePaymentRepository implements PaymentRepository {
  Box get _box => Hive.box('payments');
  Box get _invoiceBox => Hive.box('invoices');

  @override
  Future<List<Payment>> getAllPayments() async {
    final List<Payment> list = [];
    for (final key in _box.keys) {
      final raw = _box.get(key);
      if (raw is Map) {
        list.add(Payment.fromMap(Map<dynamic, dynamic>.from(raw)));
      }
    }
    list.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
    return list;
  }

  @override
  Future<List<Payment>> getPaymentsForInvoice(String invoiceId) async {
    final all = await getAllPayments();
    return all.where((p) => p.invoiceId == invoiceId).toList();
  }

  @override
  Future<void> recordPayment(Payment payment) async {
    await _box.put(payment.id, payment.toMap());

    // Update invoice status & paidAmount in invoices box
    for (final key in _invoiceBox.keys) {
      final raw = _invoiceBox.get(key);
      if (raw is Map) {
        final inv = Invoice.fromMap(Map<dynamic, dynamic>.from(raw));
        if (inv.id == payment.invoiceId || inv.invoiceNo == payment.invoiceId) {
          final newPaid = inv.paidAmount + payment.amount;
          final isPaid =
              newPaid >= (inv.grandTotal - 0.5); // Allow small rounding margin
          final isPartial = newPaid > 0 && !isPaid;
          final updatedStatus = isPaid
              ? 'paid'
              : (isPartial ? 'partial' : 'pending');

          final updatedInvoice = inv.copyWith(
            paidAmount: newPaid,
            status: updatedStatus,
            updatedAt: DateTime.now(),
          );
          await _invoiceBox.put(inv.id, updatedInvoice.toMap());
          break;
        }
      }
    }
  }
}

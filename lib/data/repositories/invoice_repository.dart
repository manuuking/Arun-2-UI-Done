import 'package:hive_flutter/hive_flutter.dart';

import '../models/invoice.dart';
import '../models/payment.dart';
abstract class InvoiceRepository {
  Future<List<Invoice>> getInvoices();
  Future<Invoice?> getInvoiceById(String id);
  Future<void> saveInvoice(Invoice invoice);
  Future<void> deleteInvoice(String id);
  Future<void> rejectInvoice(String id);
  Future<void> updatePaymentStatus(String id, bool isPaid);

  // Dashboard specific queries
  Future<double> getTotalRevenue(String fiscalYear);
  Future<int> getPendingInvoicesCount();
}

class HiveInvoiceRepository implements InvoiceRepository {
  Box get _box => Hive.box('invoices');

  HiveInvoiceRepository() {
    _seedInitialDataIfNeeded();
  }

  void _seedInitialDataIfNeeded() {
    if (_box.isEmpty) {
      final now = DateTime.now();

      final inv28 = Invoice(
        id: 'INV-0028',
        invoiceNo: 'INV-0028',
        challanNo: 'CH-120',
        invoiceDate: now.subtract(const Duration(days: 1)),
        orderNo: 'PO-2026/881',
        transportBy: 'VRL Logistics',
        lrNo: '', // LR missing for testing missing LR prompt requirement!
        lrDate: null,
        parcelNo: '4 Cartons',
        sellerId: 'arun_mensware_default',
        buyerId: 'comp_pgp',
        buyerName: 'PGP Glass Private Limited',
        buyerGstin: '24AALCP5737F1ZA',
        buyerAddress: 'Plot No 177, 25 Mtr, 150 Feet Ring Road,\nRajkot, Gujarat - 360005',
        items: [
          InvoiceItem(
            id: 'item_1',
            productId: 'prod_gloves',
            productName: 'Cotton Hand Gloves',
            description: 'Cotton Hand Gloves Qty. (20*09 = 12)',
            hsnCode: '6116',
            unit: 'Qty.',
            quantity: 2160,
            rate: 35.0,
            amount: 75600.0,
            taxSlab: 'CGST+SGST',
            cgstRate: 2.5,
            sgstRate: 2.5,
            poId: 'PO-2026/881',
            poAllocations: [
              POAllocation(
                poId: 'po_pgp_881',
                poNo: 'PO-2026/881',
                allocatedQty: 2160,
              ),
            ],
          ),
        ],
        subtotal: 75600.0,
        cgst: 1890.0,
        sgstAmount: 1890.0,
        igst: 0.0,
        otherExp: 0.0,
        roundOff: 0.0,
        grandTotal: 79380.0,
        amountInWords: 'Rupees Seventy Nine Thousand Three Hundred Eighty Only',
        status: 'pending',
        paidAmount: 0.0,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      );

      final inv27 = Invoice(
        id: 'INV-0027',
        invoiceNo: 'INV-0027',
        challanNo: 'CH-119',
        invoiceDate: now.subtract(const Duration(days: 3)),
        orderNo: '9002123',
        transportBy: 'DTDC Courier',
        lrNo: 'D-44102',
        lrDate: '01 Oct 2026',
        parcelNo: '6 Cartons',
        sellerId: 'arun_mensware_default',
        buyerId: 'comp_sterling',
        buyerName: 'Sterling Safety Equips Ltd',
        buyerGstin: '24BBXPT8991K1Z2',
        buyerAddress: 'GIDC Phase II, Naroda, Ahmedabad, Gujarat - 382330',
        items: [
          InvoiceItem(
            id: 'item_2',
            productId: 'prod_uniforms',
            productName: 'Industrial Uniforms',
            description: 'Industrial Safety Uniforms',
            hsnCode: '6203',
            unit: 'Set',
            quantity: 140,
            rate: 850.0,
            amount: 119000.0,
            taxSlab: 'CGST+SGST',
            cgstRate: 2.5,
            sgstRate: 2.5,
            poId: '9002123',
            poAllocations: [
              POAllocation(
                poId: 'po_sterling_1',
                poNo: '9002123',
                allocatedQty: 140,
              ),
            ],
          ),
        ],
        subtotal: 119000.0,
        cgst: 2975.0,
        sgstAmount: 2975.0,
        igst: 0.0,
        otherExp: 0.0,
        roundOff: 0.0,
        grandTotal: 124950.0,
        amountInWords:
            'Rupees One Lakh Twenty Four Thousand Nine Hundred Fifty Only',
        status: 'pending',
        paidAmount: 0.0,
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 3)),
      );

      final inv26 = Invoice(
        id: 'INV-0026',
        invoiceNo: 'INV-0026',
        challanNo: 'CH-118',
        invoiceDate: now.subtract(const Duration(days: 6)),
        orderNo: 'SIC-26/10',
        transportBy: 'Self Pickup',
        lrNo: 'SIC-991',
        lrDate: '28 Sep 2026',
        parcelNo: '2 Cartons',
        sellerId: 'arun_mensware_default',
        buyerId: 'comp_saurashtra',
        buyerName: 'Saurashtra Industrial Corp',
        buyerGstin: '24CCHYP4412J1Z9',
        buyerAddress: '8-A National Highway, Morbi, Gujarat - 363642',
        items: [
          InvoiceItem(
            id: 'item_3',
            productId: 'prod_vests',
            productName: 'High-Vis Vests',
            description: 'Reflective Safety Vests',
            hsnCode: '6114',
            unit: 'Qty.',
            quantity: 360,
            rate: 120.0,
            amount: 43200.0,
            taxSlab: 'CGST+SGST',
            cgstRate: 2.5,
            sgstRate: 2.5,
            poId: 'SIC-26/10',
            poAllocations: [
              POAllocation(
                poId: 'po_saurashtra_1',
                poNo: 'SIC-26/10',
                allocatedQty: 360,
              ),
            ],
          ),
        ],
        subtotal: 43200.0,
        cgst: 1080.0,
        sgstAmount: 1080.0,
        igst: 0.0,
        otherExp: 0.0,
        roundOff: 0.0,
        grandTotal: 45360.0,
        amountInWords: 'Rupees Forty Five Thousand Three Hundred Sixty Only',
        status: 'paid',
        paidAmount: 45360.0,
        createdAt: now.subtract(const Duration(days: 6)),
        updatedAt: now.subtract(const Duration(days: 6)),
      );

      _box.put(inv28.id, inv28.toMap());
      _box.put(inv27.id, inv27.toMap());
      _box.put(inv26.id, inv26.toMap());
    }
  }

  @override
  Future<void> deleteInvoice(String id) async {
    await _box.delete(id);
  }

  @override
  Future<void> rejectInvoice(String id) async {
    final inv = await getInvoiceById(id);
    if (inv != null) {
      final updated = inv.copyWith(
        status: 'rejected',
        updatedAt: DateTime.now(),
      );
      await saveInvoice(updated);
    }
  }

  @override
  Future<void> updatePaymentStatus(String id, bool isPaid) async {
    final inv = await getInvoiceById(id);
    if (inv != null) {
      final paymentsBox = Hive.box('payments');
      double paidAmount = 0.0;

      if (isPaid) {
        // Calculate existing payment sum
        for (final key in paymentsBox.keys) {
          final raw = paymentsBox.get(key);
          if (raw is Map) {
            final payment = Payment.fromMap(Map<dynamic, dynamic>.from(raw));
            if (payment.invoiceId == inv.id) {
              paidAmount += payment.amount;
            }
          }
        }
        
        final remaining = inv.grandTotal - paidAmount;
        if (remaining > 0) {
          final paymentId = DateTime.now().millisecondsSinceEpoch.toString();
          final newPayment = Payment(
            id: paymentId,
            invoiceId: inv.id,
            amount: remaining,
            paymentDate: DateTime.now(),
            method: 'System Sync',
            notes: 'Marked as Paid via Checkbox',
            createdAt: DateTime.now(),
          );
          await paymentsBox.put(paymentId, newPayment.toMap());
          paidAmount += remaining;
        }
      } else {
        // Remove all payments for this invoice
        final keysToRemove = <dynamic>[];
        for (final key in paymentsBox.keys) {
          final raw = paymentsBox.get(key);
          if (raw is Map) {
            final payment = Payment.fromMap(Map<dynamic, dynamic>.from(raw));
            if (payment.invoiceId == inv.id) {
              keysToRemove.add(key);
            }
          }
        }
        await paymentsBox.deleteAll(keysToRemove);
        paidAmount = 0.0;
      }

      final updated = inv.copyWith(
        status: isPaid ? 'paid' : 'pending',
        paidAmount: paidAmount,
        updatedAt: DateTime.now(),
      );
      await saveInvoice(updated);
    }
  }

  @override
  Future<Invoice?> getInvoiceById(String id) async {
    final raw = _box.get(id);
    if (raw != null) {
      return Invoice.fromMap(Map<dynamic, dynamic>.from(raw as Map));
    }
    for (final key in _box.keys) {
      final item = _box.get(key);
      if (item is Map) {
        final inv = Invoice.fromMap(Map<dynamic, dynamic>.from(item));
        if (inv.invoiceNo.toLowerCase() == id.toLowerCase() || inv.id == id) {
          return inv;
        }
      }
    }
    return null;
  }

  @override
  Future<List<Invoice>> getInvoices() async {
    final List<Invoice> list = [];
    for (final key in _box.keys) {
      final raw = _box.get(key);
      if (raw is Map) {
        list.add(Invoice.fromMap(Map<dynamic, dynamic>.from(raw)));
      }
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<int> getPendingInvoicesCount() async {
    final list = await getInvoices();
    return list.where((i) => i.status == 'pending').length;
  }

  @override
  Future<double> getTotalRevenue(String fiscalYear) async {
    final list = await getInvoices();
    // Only non-rejected invoices count towards revenue
    return list
        .where((i) => i.status != 'rejected' && i.status != 'draft')
        .fold<double>(0.0, (double sum, i) => sum + i.grandTotal);
  }

  @override
  Future<void> saveInvoice(Invoice invoice) async {
    await _box.put(invoice.id, invoice.toMap());
  }
}

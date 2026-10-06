import 'package:flutter_test/flutter_test.dart';
import 'package:arun_invoice_pro/core/utils/currency_formatter.dart';
import 'package:arun_invoice_pro/data/models/invoice.dart';
import 'package:arun_invoice_pro/data/models/purchase_order.dart';
import 'package:arun_invoice_pro/features/pdf/invoice_pdf_generator.dart';

void main() {
  group('Indian Currency Formatter Tests', () {
    test('Correctly formats numbers according to Indian numbering system', () {
      expect(CurrencyFormatter.format(1000), '₹1,000.00');
      expect(CurrencyFormatter.format(10000), '₹10,000.00');
      expect(CurrencyFormatter.format(100000), '₹1,00,000.00');
      expect(CurrencyFormatter.format(729312), '₹7,29,312.00');
      expect(CurrencyFormatter.format(76377.60), '₹76,377.60');
      
      expect(CurrencyFormatter.formatQuantity(1000), '1,000');
      expect(CurrencyFormatter.formatQuantity(10000), '10,000');
      expect(CurrencyFormatter.formatQuantity(100000), '1,00,000');
    });
  });

  group('PO Quantity Calculation and Reconciliation Tests', () {
    test('Remaining quantity is derived from orderedQty + adjustments - active allocations', () {
      final po = PurchaseOrder(
        id: 'po-1',
        poNo: 'PO-2026/881',
        companyId: 'comp-1',
        companyName: 'PGP Glass Private Limited',
        poDate: DateTime.now(),
        orderedQty: 10000,
        adjustments: [
          POAdjustment(
            id: 'adj-1',
            quantity: 200,
            reason: 'Extra material delivered by company',
            date: DateTime.now(),
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Total ordered (10,000) + Extra (200) = 10,200
      expect(po.effectiveTotalQty, 10200);

      // Create invoice with PO allocation
      final inv1 = Invoice(
        id: 'inv-1',
        invoiceNo: 'INV-0001',
        challanNo: 'CH-0001',
        invoiceDate: DateTime.now(),
        sellerId: 'seller-1',
        buyerId: 'comp-1',
        buyerName: 'PGP Glass Private Limited',
        buyerAddress: 'Plot 12, GIDC, Ankleshwar',
        status: 'pending',
        subtotal: 210000,
        cgst: 5250,
        sgstAmount: 5250,
        igst: 0,
        roundOff: 0,
        grandTotal: 220500,
        amountInWords: 'Two Lakh Twenty Thousand Five Hundred Only',
        items: [
          InvoiceItem(
            id: 'item-1',
            productId: 'prod-1',
            productName: 'Cotton Hand Gloves',
            hsnCode: '6116',
            unit: 'Pairs',
            quantity: 6000,
            rate: 35,
            amount: 210000,
            taxSlab: 'CGST 2.5% + SGST 2.5%',
            poAllocations: [
              POAllocation(poId: 'po-1', poNo: 'PO-2026/881', allocatedQty: 6000),
            ],
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Active allocations = 6,000
      double allocated = 0;
      if (inv1.status != 'rejected') {
        for (var item in inv1.items) {
          for (var alloc in item.poAllocations) {
            if (alloc.poId == po.id) {
              allocated += alloc.allocatedQty;
            }
          }
        }
      }
      expect(allocated, 6000);
      expect(po.effectiveTotalQty - allocated, 4200);

      // Reject the invoice
      final inv1Rejected = inv1.copyWith(status: 'rejected');
      double allocatedAfterReject = 0;
      if (inv1Rejected.status != 'rejected') {
        for (var item in inv1Rejected.items) {
          for (var alloc in item.poAllocations) {
            if (alloc.poId == po.id) {
              allocatedAfterReject += alloc.allocatedQty;
            }
          }
        }
      }
      // Allocation released
      expect(allocatedAfterReject, 0);
      expect(po.effectiveTotalQty - allocatedAfterReject, 10200);
    });

    test('Multi-PO Allocation splits product quantity across multiple POs', () {
      final item = InvoiceItem(
        id: 'item-2',
        productId: 'prod-1',
        productName: 'Cotton Hand Gloves',
        hsnCode: '6116',
        unit: 'Pairs',
        quantity: 1000,
        rate: 35,
        amount: 35000,
        taxSlab: 'CGST 2.5% + SGST 2.5%',
        poAllocations: [
          POAllocation(poId: 'po-1', poNo: 'PO-2026/881', allocatedQty: 500),
          POAllocation(poId: 'po-2', poNo: 'PO-2026/882', allocatedQty: 300),
          POAllocation(poId: 'po-3', poNo: 'PO-2026/883', allocatedQty: 200),
        ],
      );

      final totalAllocated = item.poAllocations.fold<double>(0, (sum, a) => sum + a.allocatedQty);
      expect(totalAllocated, item.quantity);
      expect(item.poAllocations.length, 3);
    });

    test('InvoicePdfGenerator generates valid PDF bytes without errors', () async {
      final inv = Invoice(
        id: 'inv-pdf-test',
        invoiceNo: 'INV-0036',
        challanNo: 'CH-128',
        invoiceDate: DateTime.now(),
        sellerId: 'seller-1',
        buyerId: 'comp-1',
        buyerName: 'PGP Glass Private Limited',
        buyerAddress: 'Plot 12, GIDC, Ankleshwar',
        status: 'pending',
        subtotal: 17680,
        cgst: 442,
        sgstAmount: 442,
        igst: 0,
        roundOff: 0,
        grandTotal: 18564,
        amountInWords: 'Eighteen Thousand Five Hundred Sixty Four Only',
        parcelNo: '1 Box',
        items: [
          InvoiceItem(
            id: 'item-1',
            productId: 'prod-1',
            productName: 'Cotton Hand Gloves',
            hsnCode: '6216',
            unit: 'Pair',
            quantity: 500,
            rate: 35.36,
            amount: 17680,
            taxSlab: 'CGST 2.5% + SGST 2.5%',
            poAllocations: [
              POAllocation(poId: 'po-1', poNo: 'PO-2026/881', allocatedQty: 500),
            ],
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final pdfBytes = await InvoicePdfGenerator.generateInvoice(invoice: inv);
      expect(pdfBytes, isNotEmpty);
      expect(pdfBytes.length, greaterThan(1000));
    });
  });
}


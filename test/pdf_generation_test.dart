import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:arun_invoice_pro/data/models/invoice.dart';
import 'package:arun_invoice_pro/features/pdf/html_invoice_generator.dart';

void main() {
  test('Generate HTML String Preview directly', () async {
    // 1. Manually construct INV-0028 to bypass Hive native test initialization problems
    final now = DateTime.now();
    final invoice = Invoice(
      id: 'INV-0028',
      invoiceNo: 'INV-0028',
      challanNo: 'CH-120',
      invoiceDate: now.subtract(const Duration(days: 1)),
      orderNo: 'PO-2026/881',
      transportBy: 'VRL Logistics',
      lrNo: '', 
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
    
    Future<void> generateWithNProducts(int count) async {
      final items = <InvoiceItem>[];
      double subtotal = 0;
      for (int i = 0; i < count; i++) {
        items.add(InvoiceItem(
          id: 'item_$i',
          productId: 'prod_$i',
          productName: 'Product Number $i',
          description: 'Description for product $i',
          hsnCode: '6116',
          unit: 'Qty.',
          quantity: 100 * (i + 1).toDouble(),
          rate: 35.0,
          amount: 3500.0 * (i + 1),
          taxSlab: 'CGST+SGST',
          cgstRate: 2.5,
          sgstRate: 2.5,
          poId: 'PO-2026/88$i',
          poAllocations: [
            POAllocation(poId: 'po_$i', poNo: 'PO-2026/88$i', allocatedQty: 100 * (i + 1).toDouble())
          ],
        ));
        subtotal += 3500.0 * (i + 1);
      }
      
      final inv = invoice.copyWith(
        items: items,
        subtotal: subtotal,
        cgst: subtotal * 0.025,
        sgstAmount: subtotal * 0.025,
        grandTotal: subtotal * 1.05,
      );
      
      final htmlStr = HtmlInvoiceGenerator.generateHtmlString(inv, false, null);
      final f = File('test_output/html_invoice_test_$count.html');
      await f.writeAsString(htmlStr);
      print('Saved: \${f.absolute.path}');
    }
    
    await generateWithNProducts(1);
    await generateWithNProducts(2);
    await generateWithNProducts(3);
    await generateWithNProducts(5);
  });
}

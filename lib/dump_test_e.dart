import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:arun_invoice_pro/data/models/invoice.dart';
import 'package:arun_invoice_pro/features/pdf/html_invoice_generator.dart';

void main() async {
  final invoice = Invoice(
    id: 'test_123',
    invoiceNo: 'INV-2023-001',
    invoiceDate: DateTime.now(),
    buyerId: 'buyer_123',
    sellerId: 'seller_123',
    buyerName: 'Test Buyer',
    buyerAddress: '123 Test Street, Test City',
    subtotal: 1000.0,
    cgst: 90.0,
    sgstAmount: 90.0,
    igst: 0.0,
    roundOff: 0.0,
    grandTotal: 1180.0,
    amountInWords: 'One Thousand One Hundred Eighty Only',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    items: [
      InvoiceItem(
        id: 'item_123',
        productId: 'prod_123',
        productName: 'Test Product',
        hsnCode: '1234',
        quantity: 10,
        unit: 'PCS',
        rate: 100.0,
        amount: 1000.0,
        taxSlab: '18.0',
        cgstRate: 9.0,
        sgstRate: 9.0,
        igstRate: 0.0,
        poAllocations: [],
      ),
    ],
  );
  
  final Uint8List tinyPng = base64Decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAACklEQVR4nGMAAQAABQABDQottAAAAABJRU5ErkJggg==');
  
  final html = await HtmlInvoiceGenerator.generateHtmlInvoice(invoice, false, tinyPng);
  
  File('C:/Users/INDIA/.gemini/antigravity-ide/brain/607de37a-4976-487f-b26c-c39760cc49cb/scratch/test_e.html').writeAsStringSync(html);
}

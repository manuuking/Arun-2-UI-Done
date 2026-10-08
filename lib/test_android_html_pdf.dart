import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_html_to_pdf_plus/flutter_html_to_pdf_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:arun_invoice_pro/data/models/invoice.dart';
import 'package:arun_invoice_pro/features/pdf/html_invoice_generator.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Diagnostic',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PdfDiagnosticScreen(),
    );
  }
}

class PdfDiagnosticScreen extends StatefulWidget {
  const PdfDiagnosticScreen({super.key});

  @override
  State<PdfDiagnosticScreen> createState() => _PdfDiagnosticScreenState();
}

class _PdfDiagnosticScreenState extends State<PdfDiagnosticScreen> {
  String _status = 'Select a test to run.';
  bool _isConverting = false;

  Future<void> _runTest(String testName, String htmlContent) async {
    if (_isConverting) {
      setState(() => _status = 'A test is already running. Please wait.');
      return;
    }

    setState(() {
      _isConverting = true;
      _status = 'Running $testName...\nHTML Length: ${htmlContent.length} bytes\nStarting conversion...';
    });

    try {
      Directory dir;
      if (Platform.isAndroid) {
        dir = (await getExternalStorageDirectory()) ?? await getApplicationDocumentsDirectory();
      } else {
        dir = await getApplicationDocumentsDirectory();
      }
      final targetPath = dir.path;
      final targetFileName = 'Diagnostic_${testName.replaceAll(" ", "_")}';

      final stopwatch = Stopwatch()..start();

      final generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(
        content: htmlContent,
        configuration: PrintPdfConfiguration(
          targetDirectory: targetPath,
          targetName: targetFileName,
          printSize: PrintSize.A4,
          printOrientation: PrintOrientation.Portrait,
        ),
      ).timeout(const Duration(seconds: 15));

      stopwatch.stop();

      final file = File(generatedPdfFile.path);
      final sizeBytes = await file.length();

      setState(() {
        _status = '✅ $testName PASS\n'
            'Time: ${stopwatch.elapsedMilliseconds} ms\n'
            'File size: ${(sizeBytes / 1024).toStringAsFixed(2)} KB\n'
            'Saved at: ${generatedPdfFile.path}';
      });
      
      OpenFilex.open(generatedPdfFile.path);
      
    } catch (e) {
      setState(() {
        _status = '❌ $testName FAIL\nError: $e';
      });
    } finally {
      setState(() {
        _isConverting = false;
      });
    }
  }

  Invoice _getProdInvoice() {
    return Invoice(
      id: 'prod_123',
      invoiceNo: 'INV-0029',
      invoiceDate: DateTime(2026, 10, 7),
      buyerId: 'buyer_123',
      sellerId: 'seller_123',
      buyerName: 'Manthan Arun Parmar Help solution Pvt Ltd',
      buyerAddress: 'hello my name is Manthan you are muchting, Rajkot, Gujarat - 360021',
      buyerGstin: '123456789012345',
      challanNo: 'CH-121',
      transportBy: 'VRL Logistics',
      lrDate: '07 Oct 2026',
      parcelNo: '1',
      subtotal: 17500.0,
      cgst: 437.5,
      sgstAmount: 437.5,
      igst: 0.0,
      roundOff: 0.0,
      grandTotal: 18375.0,
      amountInWords: 'Eighteen Thousand Three Hundred Seventy Five Only',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      items: [
        InvoiceItem(
          id: 'item_123',
          productId: 'prod_123',
          productName: 'Cotton Hand Gloves',
          poId: 'PO-2026/881',
          hsnCode: '6116',
          quantity: 500,
          unit: 'PCS',
          rate: 35.0,
          amount: 17500.0,
          taxSlab: '5.0',
          cgstRate: 2.5,
          sgstRate: 2.5,
          igstRate: 0.0,
          poAllocations: [],
        ),
      ],
    );
  }

  void _testProdReproduction() async {
    final invoice = _getProdInvoice();
    final html = await HtmlInvoiceGenerator.generateHtmlInvoice(invoice, false, null);
    _runTest('Test F - EXACT PRODUCTION HTML', html);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Production HTML Reproduction')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(onPressed: _isConverting ? null : _testProdReproduction, child: const Text('RUN EXACT PRODUCTION HTML TEST')),
            const SizedBox(height: 24),
            const Text('Status / Result:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Text(_status, style: const TextStyle(fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


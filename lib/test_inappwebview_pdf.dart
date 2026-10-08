import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'data/repositories/invoice_repository.dart';
import 'features/pdf/html_invoice_generator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  await Hive.openBox('settings');
  await Hive.openBox('invoices');
  await Hive.openBox('payments');
  
  runApp(const TestInAppWebViewApp());
}

class TestInAppWebViewApp extends StatelessWidget {
  const TestInAppWebViewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: PdfGeneratorScreen(),
    );
  }
}

class PdfGeneratorScreen extends StatefulWidget {
  const PdfGeneratorScreen({super.key});

  @override
  State<PdfGeneratorScreen> createState() => _PdfGeneratorScreenState();
}

class _PdfGeneratorScreenState extends State<PdfGeneratorScreen> {
  String? _htmlContent;
  String _status = 'Initializing...';
  InAppWebViewController? _webViewController;


  @override
  void initState() {
    super.initState();
    _loadInvoice();
  }

  Future<void> _loadInvoice() async {
    try {
      setState(() => _status = 'Loading Invoice INV-0028...');
      final repo = HiveInvoiceRepository();
      final invoice = await repo.getInvoiceById('INV-0028');
      
      if (invoice == null) {
        setState(() => _status = 'Error: Invoice INV-0028 not found');
        return;
      }
      
      setState(() => _status = 'Generating HTML...');
      final html = await HtmlInvoiceGenerator.generateHtmlInvoice(invoice, false, null);
      
      setState(() {
        _htmlContent = html;
        _status = 'HTML Generated. Rendering in WebView...';
        debugPrint(_status);
      });
    } catch (e) {
      setState(() => _status = 'Error: $e');
    }
  }

  Future<void> _generatePdf() async {
    if (_webViewController == null) return;
    try {
      setState(() => _status = 'Creating PDF from WebView...');
      
      // Delay to ensure any JS or fonts are totally rendered
      await Future.delayed(const Duration(milliseconds: 1500));
      
      final pdfBytes = await _webViewController!.createPdf(
        pdfConfiguration: PDFConfiguration(),
      );
      
      if (pdfBytes != null) {
        // Save to local device storage to avoid read-only errors on Android
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/inappwebview_test.pdf');
        await file.writeAsBytes(pdfBytes);

        setState(() {
          _status = 'SUCCESS: PDF Saved to ${file.path} (${pdfBytes.length} bytes)!';
          debugPrint(_status);
        });
      } else {
        setState(() { 
          _status = 'Error: PDF generation returned null';
          debugPrint(_status);
        });
      }
    } catch (e) {
      setState(() => _status = 'Error generating PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('InAppWebView PDF Test')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _status, 
              style: TextStyle(fontWeight: FontWeight.bold, color: _status.startsWith('Error') ? Colors.red : Colors.green),
            ),
          ),
          if (_htmlContent != null)
            Expanded(
              child: InAppWebView(
                initialData: InAppWebViewInitialData(data: _htmlContent!),
                onWebViewCreated: (controller) {
                  _webViewController = controller;
                },
                onLoadStop: (controller, url) {
                  debugPrint('WebView: onLoadStop triggered for $url');
                  _generatePdf();
                },
                onConsoleMessage: (controller, consoleMessage) {
                  debugPrint('WebView: ${consoleMessage.message}');
                },
              ),
            )
          else
            const Expanded(child: Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }
}

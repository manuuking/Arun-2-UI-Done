import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:arun_invoice_pro/data/repositories/invoice_repository.dart';
import 'package:arun_invoice_pro/features/pdf/html_invoice_generator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Use a separate test directory for Hive to avoid locking the main app DB if it's open
  await Hive.initFlutter();
  
  // Open necessary boxes
  await Hive.openBox('settings');
  await Hive.openBox('invoices');
  await Hive.openBox('payments');
  
  runApp(const TestApp());
}

class TestApp extends StatefulWidget {
  const TestApp({super.key});
  @override
  State<TestApp> createState() => _TestAppState();
}

class _TestAppState extends State<TestApp> {
  
  @override
  void initState() {
    super.initState();
    _generate();
  }
  
  Future<void> _generate() async {
    try {
      final repo = HiveInvoiceRepository();
      final invoice = await repo.getInvoiceById('INV-0028');
      
      if (invoice != null) {
        print('FOUND INVOICE: \${invoice.invoiceNo}');
        print('Number of products: \${invoice.items.length}');
        
        final bytes = await HtmlInvoiceGenerator.generateInvoice(
          invoice, 
          false, 
          null // no logo bytes for test unless loaded from settings
        );
        
        final dir = Directory('test_output');
        if (!dir.existsSync()) {
          dir.createSync(recursive: true);
        }
        
        final file = File('test_output/html_invoice_test.pdf');
        await file.writeAsBytes(bytes);
        
        print('SUCCESS: PDF saved to \${file.absolute.path}');
        
        // Auto-open on Windows
        if (Platform.isWindows) {
          await Process.run('cmd', ['/c', 'start', '', file.absolute.path]);
        }
        
        // Exit the test app automatically
        exit(0);
      } else {
        print('ERROR: Invoice not found!');
        exit(1);
      }
    } catch (e, stack) {
      print('ERROR generating PDF: \$e');
      print(stack);
      exit(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}

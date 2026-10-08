import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'dart:typed_data';
import 'test_html_string.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TestApp());
}

class TestApp extends StatefulWidget {
  const TestApp({super.key});
  @override
  State<TestApp> createState() => _TestAppState();
}

class _TestAppState extends State<TestApp> {
  Uint8List? _pdfBytes;
  String _status = 'Initializing...';
  String? _error;

  @override
  void initState() {
    super.initState();
    _generate();
  }

  Future<void> _generate() async {
    try {
      setState(() {
        _status = 'Converting HTML to PDF...';
      });

      final htmlContent = invoiceHtmlTemplate;

      final pdfBytes = await Printing.convertHtml(
        html: htmlContent,
        format: PdfPageFormat.a4,
      );

      setState(() {
        _pdfBytes = pdfBytes;
      });
    } catch (e, stack) {
      setState(() {
        _error = 'Error: \$e\n\$stack';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('HTML to PDF Android Test')),
        body: _error != null
            ? SingleChildScrollView(child: Text(_error!, style: const TextStyle(color: Colors.red)))
            : _pdfBytes == null
                ? Center(child: Text(_status))
                : PdfPreview(
                    build: (format) => _pdfBytes!,
                    canChangePageFormat: false,
                    canChangeOrientation: false,
                  ),
      ),
    );
  }
}

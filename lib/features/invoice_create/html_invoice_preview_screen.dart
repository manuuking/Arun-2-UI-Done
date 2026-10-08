import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_html_to_pdf_plus/flutter_html_to_pdf_plus.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/invoice.dart';
import '../pdf/html_invoice_generator.dart';

class HtmlInvoicePreviewScreen extends StatefulWidget {
  final Invoice invoice;

  const HtmlInvoicePreviewScreen({super.key, required this.invoice});

  @override
  State<HtmlInvoicePreviewScreen> createState() => _HtmlInvoicePreviewScreenState();
}

class _HtmlInvoicePreviewScreenState extends State<HtmlInvoicePreviewScreen> {
  bool _isLoading = true;
  bool _isGeneratingPdf = false;
  String _htmlContent = '';
  Uint8List? _logoBytes;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final settingsBox = Hive.box('settings');
      final logo = settingsBox.get('company_logo_bytes');
      if (logo != null && logo is Uint8List) {
        _logoBytes = logo;
      }
    } catch (_) {}

    final html = await HtmlInvoiceGenerator.generateHtmlInvoice(
      widget.invoice,
      widget.invoice.invoiceType == 'duplicate',
      _logoBytes,
    );

    debugPrint('--- LOGO DIAGNOSTICS ---');
    debugPrint('Logo Bytes Length: ${_logoBytes?.length ?? 0}');
    debugPrint('Final HTML contains <img: ${html.contains('<img')}');
    if (_logoBytes != null && _logoBytes!.length >= 3) {
      if (_logoBytes![0] == 0xFF && _logoBytes![1] == 0xD8) {
        debugPrint('Logo MIME type: image/jpeg');
      } else if (_logoBytes![0] == 0x89 && _logoBytes![1] == 0x50) {
        debugPrint('Logo MIME type: image/png');
      } else {
        debugPrint('Logo MIME type: Unknown (first byte ${_logoBytes![0]})');
      }
    }
    
    // Print first part of data URI if available
    final match = RegExp(r'src="(data:image/[^;]+;base64,[^"]{0,50})').firstMatch(html);
    if (match != null) {
      debugPrint('First part of logo data URI: ${match.group(1)}...');
    }
    debugPrint('------------------------');

    if (mounted) {
      setState(() {
        _htmlContent = html;
        _isLoading = false;
      });
    }
  }

  Future<void> _generatePdf() async {
    setState(() {
      _isGeneratingPdf = true;
    });
    // Give Flutter time to rebuild and destroy InAppWebView from the tree
    await Future.delayed(const Duration(milliseconds: 300));

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generating PDF...'),
              ],
            ),
          ),
        ),
      ),
    );

    bool dialogClosed = false;
    void closeDialog() {
      if (!dialogClosed && mounted) {
        Navigator.pop(context);
        dialogClosed = true;
        setState(() {
          _isGeneratingPdf = false;
        });
      }
    }

    debugPrint('--- PDF START ---');

    try {
      // 1. Generate HTML
      final html = await HtmlInvoiceGenerator.generateHtmlInvoice(
        widget.invoice,
        widget.invoice.invoiceType == 'duplicate',
        _logoBytes,
      );

      debugPrint('--- HTML CREATED ---');
      debugPrint('--- PDF HTML LENGTH: ${html.length} ---');
      debugPrint('--- PDF HTML HAS INVOICE NUMBER: ${html.contains(widget.invoice.invoiceNo)} ---');
      debugPrint('--- PDF HTML HAS BUYER NAME: ${html.contains(widget.invoice.buyerName)} ---');
      debugPrint('--- PDF HTML HAS PRODUCT NAME: ${widget.invoice.items.isNotEmpty ? html.contains(widget.invoice.items.first.productName) : "NO PRODUCTS"} ---');
      debugPrint('--- PDF HTML HAS GRAND TOTAL: ${html.contains("GRAND TOTAL")} ---');
      debugPrint('--- PDF HTML HAS LOGO: ${html.contains('data:image/png;base64')} ---');

      // 2. Determine directory
      Directory dir;
      if (Platform.isAndroid) {
        dir = (await getExternalStorageDirectory()) ?? await getApplicationDocumentsDirectory();
      } else {
        dir = await getApplicationDocumentsDirectory();
      }
      final targetPath = dir.path;
      final targetFileName = 'Invoice_${widget.invoice.invoiceNo.replaceAll('/', '_')}';

      debugPrint('--- PDF OUTPUT DIRECTORY: $targetPath ---');

      File? generatedPdfFile;
      
      File('$targetPath/production_pdf_input.html').writeAsStringSync(html);
      debugPrint('--- CRITICAL DEBUG CHECK ---');
      debugPrint('HTML length: ${html.length}');
      debugPrint('Product row count: ${widget.invoice.items.length}');
      debugPrint('Image count: ${'<img'.allMatches(html).length}');
      debugPrint('Has "\$index": ${html.contains('\$index')}');
      debugPrint('Has "window.INVOICE_DATA": ${html.contains('window.INVOICE_DATA')}');
      debugPrint('Has "renderInvoice": ${html.contains('renderInvoice')}');
      debugPrint('Has "<script": ${html.contains('<script')}');
      debugPrint('Has "</div>div>": ${html.contains('</div>div>')}');
      debugPrint('----------------------------');

      debugPrint('--- PDF CONVERSION START ---');
      try {
        // 3. Try to generate PDF using flutter_html_to_pdf_plus with a timeout
        generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(
          content: html,
          configuration: PrintPdfConfiguration(
            targetDirectory: targetPath,
            targetName: targetFileName,
            printSize: PrintSize.A4,
            printOrientation: PrintOrientation.Portrait,
          ),
        ).timeout(const Duration(seconds: 15));
        debugPrint('--- CONVERSION SUCCESS ---');
      } catch (e) {
        debugPrint('--- CONVERSION ERROR: $e ---');
        rethrow;
      }

      final pdfSize = await generatedPdfFile.length();
      debugPrint('--- PDF PATH: ${generatedPdfFile.path} ---');
      debugPrint('--- PDF SIZE: $pdfSize bytes ---');

      closeDialog();

      // 4. Open Temporary Invoice Detail Screen
      debugPrint('--- TEMPORARY INVOICE DETAIL NAVIGATION ---');
      if (mounted) {
         final tempInvoiceWithPdf = widget.invoice.copyWith(
           driveFilePath: generatedPdfFile.path,
         );
         context.push('/invoice/temporary/detail', extra: tempInvoiceWithPdf);
      }

    } catch (e) {
      debugPrint('--- OVERALL ERROR: $e ---');
      closeDialog();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate PDF: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 10),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice Preview', style: AppTextStyles.headlineSm),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), // Pops back to edit form
        ),
      ),
      body: (_isLoading || _isGeneratingPdf)
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: InAppWebView(
                    initialData: InAppWebViewInitialData(
                      data: _htmlContent,
                      mimeType: 'text/html',
                      encoding: 'utf-8',
                    ),
                    onWebViewCreated: (controller) {},
                    initialSettings: InAppWebViewSettings(
                      transparentBackground: true,
                      builtInZoomControls: true,
                      displayZoomControls: false,
                      supportZoom: true,
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('EDIT INVOICE'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: ElevatedButton.icon(
                          onPressed: _generatePdf,
                          icon: const Icon(Icons.picture_as_pdf, size: 18),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          label: const Text(
                            'GENERATE PDF',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';

import '../../core/theme/app_text_styles.dart';

class GeneratedPdfViewerScreen extends StatefulWidget {
  final String pdfPath;

  const GeneratedPdfViewerScreen({super.key, required this.pdfPath});

  @override
  State<GeneratedPdfViewerScreen> createState() => _GeneratedPdfViewerScreenState();
}

class _GeneratedPdfViewerScreenState extends State<GeneratedPdfViewerScreen> {
  int? pages = 0;
  int? currentPage = 0;
  bool isReady = false;
  String errorMessage = '';

  Future<void> _sharePdf() async {
    final file = File(widget.pdfPath);
    if (await file.exists()) {
      await Share.shareXFiles([XFile(widget.pdfPath)], text: 'Invoice');
    }
  }

  Future<void> _printPdf() async {
    final file = File(widget.pdfPath);
    if (await file.exists()) {
      final bytes = await file.readAsBytes();
      await Printing.layoutPdf(
        onLayout: (_) => bytes,
        name: widget.pdfPath.split(Platform.pathSeparator).last,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generated PDF', style: AppTextStyles.headlineSm),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _sharePdf,
          ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _printPdf,
          ),
        ],
      ),
      body: Stack(
        children: [
          PDFView(
            filePath: widget.pdfPath,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: false,
            pageFling: false,
            onRender: (_pages) {
              setState(() {
                pages = _pages;
                isReady = true;
              });
            },
            onError: (error) {
              setState(() {
                errorMessage = error.toString();
              });
            },
            onPageError: (page, error) {
              setState(() {
                errorMessage = '$page: ${error.toString()}';
              });
            },
            onViewCreated: (PDFViewController pdfViewController) {
              // controller can be saved if needed
            },
            onPageChanged: (int? page, int? total) {
              setState(() {
                currentPage = page;
              });
            },
          ),
          if (errorMessage.isEmpty && !isReady)
            const Center(child: CircularProgressIndicator()),
          if (errorMessage.isNotEmpty)
            Center(child: Text(errorMessage, style: const TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}

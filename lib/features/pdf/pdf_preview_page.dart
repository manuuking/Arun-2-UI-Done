import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../data/models/invoice.dart';
import 'invoice_pdf_generator.dart';

class PdfPreviewPage extends StatefulWidget {
  final Invoice? invoice;
  final bool isDuplicate;

  const PdfPreviewPage({super.key, this.invoice, this.isDuplicate = false});

  @override
  State<PdfPreviewPage> createState() => _PdfPreviewPageState();
}

class _PdfPreviewPageState extends State<PdfPreviewPage> {
  final TransformationController _transformationController = TransformationController();
  TapDownDetails? _doubleTapDetails;

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    if (_transformationController.value != Matrix4.identity()) {
      _transformationController.value = Matrix4.identity();
    } else {
      final position = _doubleTapDetails?.localPosition ?? Offset.zero;
      _transformationController.value = Matrix4.identity()
        ..translate(-position.dx * 2, -position.dy * 2)
        ..scale(3.0);
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: _handleDoubleTapDown,
      onDoubleTap: _handleDoubleTap,
      child: InteractiveViewer(
        transformationController: _transformationController,
        panEnabled: true,
        minScale: 1.0,
        maxScale: 5.0,
        child: PdfPreview(
          build: (format) => InvoicePdfGenerator.generateInvoice(
            invoice: widget.invoice,
            isDuplicate: widget.isDuplicate,
          ),
          allowPrinting: true,
          allowSharing: true,
          canChangeOrientation: false,
          canChangePageFormat: false,
          canDebug: false,
          dynamicLayout: false,
        ),
      ),
    );
  }
}

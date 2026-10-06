import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/utils/currency_formatter.dart';
import '../../core/utils/number_to_words.dart';
import '../../data/models/invoice.dart';

class InvoicePdfGenerator {
  static Future<Uint8List> generateInvoice({
    Invoice? invoice,
    bool isDuplicate = false,
  }) async {
    final pdf = pw.Document();
    final inv = invoice ?? _getSampleInvoice();
    final dateStr = DateFormat('dd-MM-yyyy').format(inv.invoiceDate);

    pw.MemoryImage? logoImage;
    try {
      final settingsBox = Hive.box('settings');
      final logoBytes = settingsBox.get('company_logo_bytes');
      if (logoBytes != null && logoBytes is Uint8List) {
        logoImage = pw.MemoryImage(logoBytes);
      }
    } catch (e) {
      // Ignore
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 1.2),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                _buildHeader(logoImage),
                pw.Divider(thickness: 1, color: PdfColors.black, height: 1),
                
                _buildTitleBanner(isDuplicate),
                pw.Divider(thickness: 1, color: PdfColors.black, height: 1),
                
                _buildMetaAndBuyer(inv, dateStr),
                pw.Divider(thickness: 1, color: PdfColors.black, height: 1),
                
                pw.Expanded(child: _buildProductTableArea(inv)),
                
                pw.Divider(thickness: 1, color: PdfColors.black, height: 1),
                _buildParcelRow(inv),
                
                pw.Divider(thickness: 1, color: PdfColors.black, height: 1),
                _buildBottomSection(inv, logoImage),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(pw.MemoryImage? logoImage) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Left: Logo
          pw.Container(
            width: 80,
            height: 80,
            child: logoImage != null 
                ? pw.Image(logoImage, fit: pw.BoxFit.contain)
                : pw.SizedBox(),
          ),
          pw.SizedBox(width: 16),
          // Center: Company Details
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  'ARUN MENSWARE SERVICE',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  'Laxmi Chhaya Society-1, Plot No 177, 25 Mtr,\n150 Feet Ring Road, Rajkot, Gujarat - 360005.',
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(fontSize: 11),
                ),
                pw.SizedBox(height: 6),
                pw.Text('Phone: +91 - 9824417257  |  Email: Arunmsws@gmail.com', style: const pw.TextStyle(fontSize: 11)),
              ],
            ),
          ),
          pw.SizedBox(width: 16),
          // Right: Manufacturer & GSTIN
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Container(
                width: 140,
                padding: const pw.EdgeInsets.all(6),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black, width: 1),
                  borderRadius: pw.BorderRadius.circular(4),
                  color: PdfColors.grey200,
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      width: 18,
                      height: 18,
                      decoration: const pw.BoxDecoration(color: PdfColors.black, shape: pw.BoxShape.circle),
                      child: pw.Center(child: pw.Text('M', style: pw.TextStyle(color: PdfColors.white, fontSize: 11, fontWeight: pw.FontWeight.bold))),
                    ),
                    pw.SizedBox(width: 6),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('MANUFACTURER :', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                          pw.Text('Safety Item & Suppliers,\nHand Gloves, Cap, Mask', style: const pw.TextStyle(fontSize: 7)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'GSTIN : 24AKZPP9424E1ZM',
                style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTitleBanner(bool isDuplicate) {
    return pw.Container(
      color: PdfColors.grey300,
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Expanded(child: pw.SizedBox()), // Spacer
          pw.Text(
            'TAX INVOICE',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.black),
          ),
          pw.Expanded(
            child: pw.Align(
              alignment: pw.Alignment.centerRight,
              child: isDuplicate
                  ? pw.Text('DUPLICATE', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold))
                  : pw.SizedBox(),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildMetaAndBuyer(Invoice inv, String dateStr) {
    return pw.Table(
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(1),
      },
      border: pw.TableBorder.symmetric(inside: const pw.BorderSide(width: 1, color: PdfColors.black)),
      children: [
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _metaField2('Invoice No', inv.invoiceNo),
                  _metaField2('Date', dateStr),
                  _metaField2('Challan No', inv.challanNo ?? '-'),
                  _metaField2('Order No', inv.orderNo ?? '-'),
                  _metaField2('Transport By', inv.transportBy ?? '-'),
                  _metaField2('LR No', inv.lrNo ?? '-'),
                  _metaField2('LR Date', inv.lrDate ?? '-'),
                ],
              ),
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Container(
                  color: PdfColors.grey300,
                  padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: pw.Text('BUYER DETAILS', style: pw.TextStyle(color: PdfColors.black, fontWeight: pw.FontWeight.bold, fontSize: 11)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _metaField2('M/s', inv.buyerName, isBoldVal: true),
                      _metaField2('Address', inv.buyerAddress, maxLines: 3),
                      _metaField2('GSTIN', inv.buyerGstin ?? 'UNREGISTERED', isBoldVal: true),
                      _metaField2('S.S.T', 'State Sale'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _metaField2(String label, String value, {bool isBoldVal = false, int maxLines = 1}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 80,
            child: pw.Text(label, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
          ),
          pw.Text(': ', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
          pw.Expanded(
            child: pw.Text(
              value,
              maxLines: maxLines,
              style: pw.TextStyle(fontSize: 11, fontWeight: isBoldVal ? pw.FontWeight.bold : pw.FontWeight.normal),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildProductTableArea(Invoice inv) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        _buildCol(0, 40, 'SR\nNo.', inv, alignCenter: true),
        pw.Container(width: 1, color: PdfColors.black),
        _buildCol(1, null, 'DESCRIPTION OF GOODS', inv, flex: 1),
        pw.Container(width: 1, color: PdfColors.black),
        _buildCol(2, 70, 'HSN\nCode', inv, alignCenter: true),
        pw.Container(width: 1, color: PdfColors.black),
        _buildCol(3, 70, 'QTY.', inv, alignRight: true),
        pw.Container(width: 1, color: PdfColors.black),
        _buildCol(4, 80, 'RATE\n(₹)', inv, alignRight: true),
        pw.Container(width: 1, color: PdfColors.black),
        _buildCol(5, 100, 'AMOUNT\n(₹)', inv, alignRight: true),
      ],
    );
  }

  static pw.Widget _buildCol(int colIndex, double? width, String title, Invoice inv, {int? flex, bool alignRight = false, bool alignCenter = false}) {
    final header = pw.Container(
      color: PdfColors.grey300,
      padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
      ),
      child: pw.Center(
        child: pw.Text(title, textAlign: pw.TextAlign.center, style: pw.TextStyle(color: PdfColors.black, fontSize: 10, fontWeight: pw.FontWeight.bold)),
      ),
    );

    final items = pw.Padding(
      padding: const pw.EdgeInsets.only(top: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: inv.items.asMap().entries.map((e) {
          final idx = e.key;
          final item = e.value;
          pw.Widget content;
          if (colIndex == 0) {
            content = _itemCell((idx + 1).toString(), alignCenter: true);
          } else if (colIndex == 1) {
            content = _itemDescCell(item);
          } else if (colIndex == 2) {
            content = _itemCell(item.hsnCode, alignCenter: true);
          } else if (colIndex == 3) {
            content = _itemCell('${item.quantity.toStringAsFixed(0)} ${item.unit}', alignRight: true);
          } else if (colIndex == 4) {
            content = _itemCell(CurrencyFormatter.formatNumber(item.rate, decimalDigits: 2), alignRight: true);
          } else {
            content = _itemCell(CurrencyFormatter.formatNumber(item.amount, decimalDigits: 2), alignRight: true);
          }
          return content;
        }).toList(),
      ),
    );

    final colWidget = pw.Container(
      width: width,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          header,
          items,
        ],
      ),
    );

    if (flex != null) return pw.Expanded(flex: flex, child: colWidget);
    return colWidget;
  }

  static pw.Widget _itemCell(String text, {bool alignRight = false, bool alignCenter = false}) {
    pw.TextAlign align = pw.TextAlign.left;
    if (alignRight) align = pw.TextAlign.right;
    if (alignCenter) align = pw.TextAlign.center;
    
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      child: pw.Text(text, textAlign: align, style: const pw.TextStyle(fontSize: 11)),
    );
  }

  static pw.Widget _itemDescCell(InvoiceItem item) {
    final descParts = <String>[item.productName];
    if (item.description != null && item.description!.trim().isNotEmpty) {
      descParts.add(item.description!.trim());
    }
    if (item.poAllocations.isNotEmpty) {
      final poTexts = item.poAllocations
          .map((a) => '${a.poNo} (${CurrencyFormatter.formatQuantity(a.allocatedQty)} ${item.unit})')
          .join(', ');
      descParts.add('PO: $poTexts');
    } else if (item.poId != null && item.poId!.trim().isNotEmpty) {
      descParts.add('PO: ${item.poId!.trim()}');
    }

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: descParts.map((t) => pw.Text(t, style: pw.TextStyle(fontSize: 11, color: t == item.productName ? PdfColors.black : PdfColors.grey800, fontWeight: t == item.productName ? pw.FontWeight.bold : pw.FontWeight.normal))).toList(),
      ),
    );
  }

  static pw.Widget _buildParcelRow(Invoice inv) {
    return pw.Table(
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FixedColumnWidth(150),
        2: const pw.FixedColumnWidth(100),
      },
      border: pw.TableBorder.symmetric(inside: const pw.BorderSide(width: 1, color: PdfColors.black)),
      children: [
        pw.TableRow(
          children: [
            pw.Row(
              children: [
                pw.Container(
                  width: 120,
                  padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: pw.Text('PARCEL NO. :', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                ),
                pw.Container(width: 1, height: 32, color: PdfColors.black),
                pw.Expanded(
                  child: pw.Center(
                    child: pw.Text(inv.parcelNo ?? '-', style: const pw.TextStyle(fontSize: 11)),
                  ),
                ),
              ],
            ),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: pw.Text('SUB TOTAL', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              alignment: pw.Alignment.centerRight,
              child: pw.Text('₹ ${CurrencyFormatter.formatNumber(inv.subtotal, decimalDigits: 2)}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildBottomSection(Invoice inv, pw.MemoryImage? logoImage) {
    return pw.Table(
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FixedColumnWidth(250),
      },
      border: pw.TableBorder.symmetric(inside: const pw.BorderSide(width: 1, color: PdfColors.black)),
      children: [
        pw.TableRow(
          children: [
            // Left Column (Bank, Terms, Footer)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // Bank Details
                pw.Container(
                  decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1))),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                    children: [
                      pw.Container(
                        color: PdfColors.grey300,
                        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        child: pw.Row(
                          children: [
                            pw.Icon(const pw.IconData(0xe84f), size: 14),
                            pw.SizedBox(width: 6),
                            pw.Text('BANK DETAILS', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                          ],
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Column(
                          children: [
                            _metaField2('Bank Name', 'HDFC RAJKOT'),
                            _metaField2('Bank Account', '03792000003498', isBoldVal: true),
                            _metaField2('IFSC', 'HDFC0000379', isBoldVal: true),
                            _metaField2('Email', 'Arunmsws@gmail.com'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Terms & Conditions
                pw.Container(
                  decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1))),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                    children: [
                      pw.Container(
                        color: PdfColors.grey300,
                        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1))),
                        child: pw.Text('TERMS & CONDITIONS', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            _termRow('1', 'Interest @ 21% will be charged from date of the invoice if payment is not made within 10 days.'),
                            _termRow('2', 'We will not be responsible for loss of the materials when it leaves our premises.'),
                            _termRow('3', 'Payment by A/c. Payee Cheque/Draft Only.'),
                            _termRow('4', 'Subject To Rajkot Jurisdiction Only. E & O.E.'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Footer note
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 8, bottom: 8, top: 10),
                  child: pw.Text(
                    'This is a Computer Generated Invoice',
                    style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                  ),
                ),
              ],
            ),
            // Right Column (Totals)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                _calcRow2('OTHER EXP.', '₹ 0.00'),
                if (inv.cgst > 0) _calcRow2('ADD. CGST 2.5%', '₹ ${CurrencyFormatter.formatNumber(inv.cgst, decimalDigits: 2)}'),
                if (inv.sgstAmount > 0) _calcRow2('ADD. SGST 2.5%', '₹ ${CurrencyFormatter.formatNumber(inv.sgstAmount, decimalDigits: 2)}'),
                if (inv.igst > 0) _calcRow2('ADD. IGST 5%', '₹ ${CurrencyFormatter.formatNumber(inv.igst, decimalDigits: 2)}'),
                if (inv.roundOff != 0) _calcRow2('ROUND OFF', '₹ ${CurrencyFormatter.formatNumber(inv.roundOff, decimalDigits: 2)}'),
                
                // GRAND TOTAL
                pw.Container(
                  color: PdfColors.black,
                  padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('GRAND TOTAL', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                      pw.Text('₹ ${CurrencyFormatter.formatNumber(inv.grandTotal, decimalDigits: 2)}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                    ],
                  ),
                ),
                
                // In Words Box
                pw.Container(
                  decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(color: PdfColors.black, width: 1), bottom: pw.BorderSide(color: PdfColors.black, width: 1))),
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('In Words: ', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      pw.Expanded(
                        child: pw.Text(
                          inv.amountInWords.isNotEmpty ? inv.amountInWords : NumberToWords.convert(inv.grandTotal),
                          style: const pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Signature Box
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    child: pw.Stack(
                      children: [
                        if (logoImage != null)
                          pw.Positioned(
                            right: 20,
                            bottom: 30,
                            child: pw.Opacity(
                              opacity: 0.15,
                              child: pw.Image(logoImage, height: 70, width: 70),
                            ),
                          ),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('FOR, ARUN MENSWARE SERVICE', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                            pw.Container(
                              decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(color: PdfColors.black, style: pw.BorderStyle.dashed))),
                              padding: const pw.EdgeInsets.only(top: 6),
                              child: pw.Text('Authorised Signature', textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 10)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _calcRow2(String label, String value) {
    return pw.Container(
      decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1))),
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
          pw.Text(value, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  static pw.Widget _termRow(String num, String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 16,
            height: 16,
            decoration: const pw.BoxDecoration(color: PdfColors.black, shape: pw.BoxShape.circle),
            child: pw.Center(child: pw.Text(num, style: pw.TextStyle(color: PdfColors.white, fontSize: 9, fontWeight: pw.FontWeight.bold))),
          ),
          pw.SizedBox(width: 8),
          pw.Expanded(child: pw.Text(text, style: const pw.TextStyle(fontSize: 10))),
        ],
      ),
    );
  }

  static Invoice _getSampleInvoice() {
    final now = DateTime.now();
    return Invoice(
      id: 'INV-0028',
      invoiceNo: '1',
      challanNo: '01',
      invoiceDate: now,
      orderNo: '1100178082',
      transportBy: 'LMT',
      lrNo: '-',
      lrDate: '-',
      parcelNo: '12',
      sellerId: 'arun_mensware_default',
      buyerId: 'comp_pgp',
      buyerName: 'PGP Glass Private Limited',
      buyerGstin: '24AALCP5737F1ZA',
      buyerAddress: 'B - Dabhasa\nVill - Jambusar',
      items: [
        InvoiceItem(
          id: 'item_1',
          productId: 'prod_gloves',
          productName: 'Cotton Hand Gloves',
          description: '20*09= 12',
          hsnCode: '6216',
          unit: 'Qty',
          quantity: 2160,
          rate: 35.0,
          amount: 75600.0,
          taxSlab: 'CGST+SGST',
          cgstRate: 2.5,
          sgstRate: 2.5,
        ),
      ],
      subtotal: 75600.0,
      cgst: 1890.0,
      sgstAmount: 1890.0,
      igst: 0.0,
      otherExp: 0.0,
      roundOff: 0.0,
      grandTotal: 79380.0,
      amountInWords: 'Seventy Nine Thousand Three Hundred Eighty Only',
      status: 'pending',
      paidAmount: 0.0,
      createdAt: now,
      updatedAt: now,
    );
  }
}

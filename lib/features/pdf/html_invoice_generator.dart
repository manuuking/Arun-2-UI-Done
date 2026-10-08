import 'dart:convert';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/invoice.dart';
import '../../data/models/seller_profile.dart';
import 'invoice_template_html.dart';

class HtmlInvoiceGenerator {
  static String _esc(String? s) {
    if (s == null) return "";
    return const HtmlEscape().convert(s);
  }

  static String _dash(String? s) {
    if (s == null || s.trim().isEmpty) return "-";
    return _esc(s);
  }

  static String _fmtAmt(double n) {
    final formatter = NumberFormat("#,##,##0.00", "en_IN");
    return formatter.format(n);
  }

  static String _money(double n) {
    return "₹ " + _fmtAmt(n);
  }

  static String _fmtQty(double n) {
    var s = n.toStringAsFixed(3);
    while (s.contains('.') && (s.endsWith('0') || s.endsWith('.'))) {
      if (s.endsWith('.')) {
        s = s.substring(0, s.length - 1);
        break;
      }
      s = s.substring(0, s.length - 1);
    }
    return s;
  }

  static String _pct(double part, double sub) {
    if (sub > 0) {
      return (part / sub * 100).toStringAsFixed(2) + "%";
    }
    return "";
  }

  static String _fmtDate(DateTime d) {
    return DateFormat('dd/MM/yyyy').format(d);
  }

  /// Generates a completely static HTML string representing the invoice without JavaScript dependencies.
  static Future<String> generateHtmlInvoice(
    Invoice invoice,
    bool isDuplicate,
    Uint8List? logoBytes,
  ) async {
    // 1. Prepare Logo Data URI
    String logoDataUri = '';
    if (logoBytes != null && logoBytes.isNotEmpty) {
      final base64String = base64Encode(logoBytes);
      String mimeType = 'image/png';
      if (logoBytes.length >= 3) {
        if (logoBytes[0] == 0xFF && logoBytes[1] == 0xD8) {
          mimeType = 'image/jpeg';
        } else if (logoBytes[0] == 0x89 && logoBytes[1] == 0x50 && logoBytes[2] == 0x4E) {
          mimeType = 'image/png';
        } else if (logoBytes[0] == 0x47 && logoBytes[1] == 0x49 && logoBytes[2] == 0x46) {
          mimeType = 'image/gif';
        } else if (logoBytes.length >= 12 && logoBytes[8] == 0x57 && logoBytes[9] == 0x45 && logoBytes[10] == 0x42 && logoBytes[11] == 0x50) {
          mimeType = 'image/webp';
        }
      }
      logoDataUri = 'data:$mimeType;base64,$base64String';
    }

    // 2. Generate Item Rows
    String rows = invoice.items.asMap().entries.map((e) {
      int index = e.key;
      var item = e.value;
      List<String> pos = [];
      if (item.poAllocations.isNotEmpty) {
        pos.addAll(item.poAllocations.map((p) => p.poNo));
      } else if (item.poId != null && item.poId!.trim().isNotEmpty) {
        pos.add(item.poId!);
      }
      
      String poHtml = pos.map((p) => '<div class="po">PO: <b>${_esc(p)}</b></div>').join("");
      
      return '''
        <tr class="prod">
          <td class="c">${index + 1}</td>
          <td>
            <div class="pn">${_esc(item.productName)}</div>
            ${item.description != null && item.description!.trim().isNotEmpty ? '<div class="ds">${_esc(item.description)}</div>' : ''}
            $poHtml
          </td>
          <td class="c">${_esc(item.hsnCode)}</td>
          <td class="c">${_fmtQty(item.quantity)}</td>
          <td class="c">${_fmtAmt(item.rate)}</td>
          <td class="c"><b>${_fmtAmt(item.quantity * item.rate)}</b></td>
        </tr>''';
    }).join("");

    // 3. Tax Rows
    List<String> taxRows = [];
    if (invoice.cgst > 0 || invoice.sgstAmount > 0) {
      taxRows.add('<div class="tr"><span>ADD. CGST ${_pct(invoice.cgst, invoice.subtotal)}</span><span>${_money(invoice.cgst)}</span></div>');
      taxRows.add('<div class="tr"><span>ADD. SGST ${_pct(invoice.sgstAmount, invoice.subtotal)}</span><span>${_money(invoice.sgstAmount)}</span></div>');
    } else if (invoice.igst > 0) {
      taxRows.add('<div class="tr"><span>ADD. IGST ${_pct(invoice.igst, invoice.subtotal)}</span><span>${_money(invoice.igst)}</span></div>');
    } else {
      taxRows.add('<div class="tr"><span style="visibility:hidden">TAX</span><span style="visibility:hidden">-</span></div>');
    }
    String taxRowsHtml = taxRows.join("");

    // 5. Read Seller details from Hive
    final settingsBox = Hive.box('settings');
    final Map<dynamic, dynamic>? sellerMap = settingsBox.get('seller_profile');
    final seller = sellerMap != null ? SellerProfile.fromMap(sellerMap) : SellerProfile.defaultProfile();

    String companyName = seller.name;
    List<String> addressLines = seller.address.split('\n');
    String phone = seller.phone;
    String email = seller.email;
    String gstin = seller.gstin;
    String bankName = seller.bankName;
    String bankAccount = seller.accountNo;
    String bankIfsc = seller.ifsc;
    String bankEmail = seller.bankEmail != null && seller.bankEmail!.isNotEmpty ? seller.bankEmail! : seller.email;
    List<String> terms = seller.termsAndConditions;

    String copyText = isDuplicate ? "DUPLICATE" : "ORIGINAL FOR RECIPIENT";
    String roundOffHtml = invoice.roundOff != 0 
      ? '<div class="tr"><span>ROUND OFF</span><span>${invoice.roundOff < 0 ? "- " : "+ "}₹ ${_fmtAmt(invoice.roundOff.abs())}</span></div>' 
      : '';
    String headerLogoHtml = logoDataUri.isNotEmpty ? '<div class="logo"><img src="${_esc(logoDataUri)}" alt=""></div>' : '<div class="logo"></div>';

    // 6. Build the Inner HTML content directly
    String innerHtml = '''
      <div class="hdr">
        $headerLogoHtml
        <div class="co">
          <h1>${_esc(companyName)}</h1>
          <div class="addr">${addressLines.map(_esc).join("<br>")}</div>
          <div class="ct">${_esc(phone)} &nbsp;|&nbsp; ${_esc(email)}</div>
        </div>
        <div class="right-col">
          <div class="copy-box">${isDuplicate ? "DUPLICATE" : "ORIGINAL"}</div>
          <div class="gst">
            <div class="date">${_fmtDate(invoice.invoiceDate)}</div>
            <div class="gstin">GSTIN :<br><b>${_esc(gstin)}</b></div>
          </div>
        </div>
      </div>

      <div class="title"><span></span><div class="t">TAX INVOICE<div class="copy-label">$copyText</div></div><span></span></div>

      <div class="row2">
        <div class="box">
          <div class="kv"><span class="k">Invoice No</span><span>:</span><span class="v">${_dash(invoice.invoiceNo)}</span></div>
          <div class="kv"><span class="k">Invoice Date</span><span>:</span><span class="v">${_fmtDate(invoice.invoiceDate)}</span></div>
          <div class="kv"><span class="k">Challan No</span><span>:</span><span class="v">${_dash(invoice.challanNo)}</span></div>
          <div class="kv"><span class="k">Transport By</span><span>:</span><span class="v">${_dash(invoice.transportBy)}</span></div>
          <div class="kv"><span class="k">LR No</span><span>:</span><span class="v">${_dash(invoice.lrNo)}</span></div>
        </div>
        <div class="box">
          <h3>BUYER DETAILS</h3>
          <div class="kv"><span class="k">M/s</span><span>:</span><span class="v"><b class="bn">${_dash(invoice.buyerName)}</b></span></div>
          <div class="kv"><span class="k">Address</span><span>:</span><span class="v" style="white-space:pre-line">${_dash(invoice.buyerAddress)}</span></div>
          <div class="kv gs"><span class="k">GSTIN</span><span>:</span><span class="v">${_dash(invoice.buyerGstin)}</span></div>
        </div>
      </div>

      <div class="itemwrap">
        <table class="items">
          <colgroup><col style="width:8%"><col style="width:40%"><col style="width:11%"><col style="width:11%"><col style="width:auto"><col style="width:38mm"></colgroup>
          <thead><tr><th>SR<br>No.</th><th>DESCRIPTION OF GOODS</th><th>HSN<br>Code</th><th>QTY.</th><th>RATE<br>(₹)</th><th>AMOUNT<br>(₹)</th></tr></thead>
          <tbody>$rows<tr class="fill"><td></td><td></td><td></td><td></td><td></td><td></td></tr></tbody>
        </table>
      </div>

      <div class="bottom">
        <div class="col">
          <div class="parcel"><div>PARCEL NO. :</div><div style="text-align: center;">${_dash(invoice.parcelNo)}</div></div>
          <div class="box">
            <h3>BANK DETAILS</h3>
            <div class="kv"><span class="k">Bank Name</span><span>:</span><span class="v">${_esc(bankName)}</span></div>
            <div class="kv"><span class="k">Bank Account</span><span>:</span><span class="v">${_esc(bankAccount)}</span></div>
            <div class="kv"><span class="k">IFSC</span><span>:</span><span class="v">${_esc(bankIfsc)}</span></div>
            <div class="kv"><span class="k">Email</span><span>:</span><span class="v">${_esc(bankEmail)}</span></div>
          </div>
          <div class="box terms">
            <h3>TERMS &amp; CONDITIONS</h3>
            <ol>${terms.map((t) => "<li>${_esc(t)}</li>").join("")}</ol>
          </div>
        </div>
        <div class="col">
          <div class="tot">
            <div class="tr"><span>OTHER EXP.</span><span>${_money(invoice.otherExp)}</span></div>
            <div class="tr sb"><span>SUB TOTAL</span><span>${_money(invoice.subtotal)}</span></div>
            <div class="tax-area">
              $taxRowsHtml
            </div>
            $roundOffHtml
            <div class="tr gt"><span>GRAND TOTAL</span><span>${_money(invoice.grandTotal)}</span></div>
          </div>
          <div class="words"><b>In Words :</b><span>${_esc(invoice.amountInWords)}</span></div>
          <div class="sign">
            <div class="cn">${_esc(companyName)}</div>
            ${logoDataUri.isNotEmpty ? '<img src="${_esc(logoDataUri)}" alt="">' : ''}
            <div class="as">Authorised Signature</div>
          </div>
        </div>
      </div>
      <div class="foot">This is a computer generated invoice.</div>
    ''';

    // 7. Inject into Master Template structure and strip Javascript
    // We split by <script> to keep everything before it, which includes the <html><head><style> and <body> structure up to `<div class="sheet"><div class="frame" id="invoice"></div></div>`
    List<String> parts = masterInvoiceTemplate.split('<div class="frame" id="invoice"></div>');
    
    // Safety check just in case
    if (parts.length < 2) {
      return '<html><body>Error: Could not find template injection point</body></html>';
    }

    String topPart = parts[0];
    String bottomPart = parts[1].split('<script>')[1].split('</script>')[1]; // get the </body></html> part after script

    String finalHtml = '$topPart<div class="frame" id="invoice">$innerHtml</div></div>$bottomPart';

    return finalHtml;
  }
}

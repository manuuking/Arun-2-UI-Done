import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsappService {
  static Future<void> sendInvoiceText({
    required String phoneNumber,
    required String invoiceNo,
    required String amount,
    required String companyName,
  }) async {
    final String message =
        'Hello $companyName,\n\nPlease find the details for Invoice $invoiceNo.\nAmount due: $amount\n\nThank you,\nArun Mensware Service';

    // Remove non-numeric characters from phone number and add country code if missing
    String cleanedPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanedPhone.length == 10) {
      cleanedPhone = '91$cleanedPhone';
    }

    final Uri whatsappUrl = Uri.parse(
      'whatsapp://send?phone=$cleanedPhone&text=${Uri.encodeComponent(message)}',
    );

    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl);
      } else {
        // Fallback to web whatsapp if app is not installed
        final Uri webUrl = Uri.parse(
          'https://wa.me/$cleanedPhone?text=${Uri.encodeComponent(message)}',
        );
        if (await canLaunchUrl(webUrl)) {
          await launchUrl(webUrl, mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      debugPrint('Error launching WhatsApp: $e');
    }
  }
}

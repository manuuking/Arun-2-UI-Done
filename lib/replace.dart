import 'dart:io';

void main() {
  final dir = Directory(
    'g:/app anti/stitch_apex_invoice_manager/arun_invoice_pro/lib',
  );
  final files = dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    var content = file.readAsStringSync();
    var changed = false;

    if (content.contains("'Qty.'")) {
      content = content.replaceAll("'Qty.'", "'Qty.'");
      changed = true;
    }
    if (content.contains("Qty. (")) {
      content = content.replaceAll("Qty. (", "Qty. (");
      changed = true;
    }
    if (content.contains("'Qty.'")) {
      content = content.replaceAll("'Qty.'", "'Qty.'");
      changed = true;
    }
    if (content.contains("Qty.")) {
      content = content.replaceAll("Qty.", "Qty.");
      changed = true;
    }
    if (content.contains("Qty.")) {
      content = content.replaceAll("Qty.", "Qty.");
      changed = true;
    }
    if (content.contains("Qty (\${draft.product?.unit ?? \"Pcs\"})")) {
      content = content.replaceAll(
        "Qty (\${draft.product?.unit ?? \"Pcs\"})",
        "Qty.",
      );
      changed = true;
    }
    if (content.contains("unit ?? \"Pcs\"")) {
      content = content.replaceAll("unit ?? \"Pcs\"", "unit ?? \"Qty.\"");
      changed = true;
    }

    if (changed) {
      file.writeAsStringSync(content);
      print('Updated: ${file.path}');
    }
  }
}

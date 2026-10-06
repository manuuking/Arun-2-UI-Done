import 'package:hive_flutter/hive_flutter.dart';

class HiveSetup {
  static Future<void> init() async {
    await Hive.initFlutter();

    // Open boxes
    await Hive.openBox('invoices');
    await Hive.openBox('companies');
    await Hive.openBox('products');
    await Hive.openBox('payments');
    await Hive.openBox('settings');
    await Hive.openBox('purchase_orders');
    await Hive.openBox('transporters');
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/local/hive_setup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveSetup.init();

  // Firebase initialization will go here later

  runApp(const ProviderScope(child: ArunInvoiceApp()));
}

import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

class ArunInvoiceApp extends StatelessWidget {
  const ArunInvoiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Arun Invoice Pro',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}

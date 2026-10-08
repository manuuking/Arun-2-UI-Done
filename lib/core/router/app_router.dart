import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/dashboard/dashboard_screen.dart';
import '../../features/invoice_list/invoice_list_screen.dart';
import '../../features/invoice_create/invoice_create_screen.dart';
import '../../features/invoice_detail/invoice_detail_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/more/more_menu_screen.dart';
import '../../features/master_data/company/company_list_screen.dart';
import '../../features/master_data/product/product_list_screen.dart';
import '../../features/settings/settings_screen.dart';

import '../../features/payment/payment_record_screen.dart';
import '../../features/payments/payments_list_screen.dart';
import '../../features/po/po_dashboard_screen.dart';
import '../../data/models/invoice.dart';
import '../../features/invoice_create/html_invoice_preview_screen.dart';
import '../../features/pdf/generated_pdf_viewer_screen.dart';

// Provide a global key for the navigator
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  routes: [
    // ShellRoute for Bottom Navigation
    ShellRoute(
      navigatorKey: shellNavigatorKey,
      builder: (context, state, child) {
        // We will replace this with AppBottomNav later
        return Scaffold(
          body: child,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _calculateSelectedIndex(state.uri.path),
            onTap: (index) {
              switch (index) {
                case 0:
                  context.go('/');
                  break;
                case 1:
                  context.go('/invoices');
                  break;
                case 2:
                  context.push('/invoice/new');
                  break;
                case 3:
                  context.go('/po-dashboard');
                  break;
                case 4:
                  context.go('/more');
                  break;
              }
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long),
                label: 'Invoices',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_circle),
                label: 'New',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart),
                label: 'Purchase Orders',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.more_horiz),
                label: 'More',
              ),
            ],
          ),
        );
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/invoices',
          builder: (context, state) => const InvoiceListScreen(),
        ),
        GoRoute(
          path: '/po-dashboard',
          builder: (context, state) => const PODashboardScreen(),
        ),
        GoRoute(
          path: '/more',
          builder: (context, state) => const MoreMenuScreen(),
        ),
      ],
    ),

    // Stack Routes
    GoRoute(
      path: '/payment/new/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? 'unknown';
        return PaymentRecordScreen(invoiceId: id);
      },
    ),
    GoRoute(
      path: '/companies',
      builder: (context, state) => const CompanyListScreen(),
    ),
    GoRoute(
      path: '/products',
      builder: (context, state) => const ProductListScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/invoice/new',
      builder: (context, state) => const InvoiceCreateScreen(),
    ),
    GoRoute(
      path: '/invoice/edit/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return InvoiceCreateScreen(editInvoiceId: id);
      },
    ),
    GoRoute(
      path: '/invoice/preview',
      builder: (context, state) {
        final inv = state.extra as Invoice;
        return HtmlInvoicePreviewScreen(
          invoice: inv,
        );
      },
    ),
    GoRoute(
      path: '/invoice/pdf-viewer',
      builder: (context, state) {
        final path = state.extra as String;
        return GeneratedPdfViewerScreen(pdfPath: path);
      },
    ),
    GoRoute(
      path: '/invoice/temporary/detail',
      builder: (context, state) {
        final inv = state.extra as Invoice;
        return InvoiceDetailScreen(
          temporaryInvoice: inv,
          isTemporaryPreview: true,
        );
      },
    ),
    GoRoute(
      path: '/invoice/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? 'unknown';
        return InvoiceDetailScreen(id: id);
      },
    ),
    GoRoute(
      path: '/payments',
      builder: (context, state) => const PaymentsListScreen(),
    ),
  ],
  redirect: (context, state) {
    // Auth redirect guard will be implemented in Phase 2
    return null;
  },
);

int _calculateSelectedIndex(String location) {
  if (location.startsWith('/invoices')) return 1;
  if (location.startsWith('/po-dashboard')) return 3;
  if (location.startsWith('/more')) return 4;
  return 0; // default to Home
}

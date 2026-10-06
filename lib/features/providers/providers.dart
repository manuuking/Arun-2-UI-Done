import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/invoice_repository.dart';
import '../../data/repositories/company_repository.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/payment_repository.dart';
import '../../data/repositories/po_repository.dart';
import '../../data/repositories/transporter_repository.dart';
import '../../data/models/invoice.dart';
import '../../data/models/company_profile.dart';
import '../../data/models/product.dart';
import '../../data/models/payment.dart';
import '../../data/models/purchase_order.dart';
import '../../data/models/transporter.dart';

// Repository Providers
final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) {
  return HiveInvoiceRepository();
});

final companyRepositoryProvider = Provider<CompanyRepository>((ref) {
  return HiveCompanyRepository();
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return HiveProductRepository();
});

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return HivePaymentRepository();
});

final poRepositoryProvider = Provider<PORepository>((ref) {
  return HivePORepository();
});

final transporterRepositoryProvider = Provider<TransporterRepository>((ref) {
  return HiveTransporterRepository();
});

// State Providers (Future/Stream)
final invoicesProvider = FutureProvider<List<Invoice>>((ref) async {
  final repo = ref.watch(invoiceRepositoryProvider);
  return repo.getInvoices();
});

final singleInvoiceProvider = FutureProvider.family<Invoice?, String>((
  ref,
  id,
) async {
  final repo = ref.watch(invoiceRepositoryProvider);
  return repo.getInvoiceById(id);
});

final companiesProvider = FutureProvider<List<CompanyProfile>>((ref) async {
  final repo = ref.watch(companyRepositoryProvider);
  return repo.getCompanies();
});

final productsProvider = FutureProvider<List<Product>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  return repo.getProducts();
});

final purchaseOrdersProvider = FutureProvider<List<PurchaseOrder>>((ref) async {
  final repo = ref.watch(poRepositoryProvider);
  return repo.getPOs();
});

final transportersProvider = FutureProvider<List<Transporter>>((ref) async {
  final repo = ref.watch(transporterRepositoryProvider);
  return repo.getTransporters();
});

final paymentsProvider = FutureProvider<List<Payment>>((ref) async {
  final repo = ref.watch(paymentRepositoryProvider);
  return repo.getAllPayments();
});

final dashboardRevenueProvider = FutureProvider.family<double, String>((
  ref,
  fiscalYear,
) async {
  final repo = ref.watch(invoiceRepositoryProvider);
  return repo.getTotalRevenue(fiscalYear);
});

final pendingInvoicesCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(invoiceRepositoryProvider);
  return repo.getPendingInvoicesCount();
});

final companyPOSummariesProvider = FutureProvider<List<CompanyPOSummary>>((
  ref,
) async {
  final poRepo = ref.watch(poRepositoryProvider);
  final pos = await poRepo.getPOs();
  final invoices = await ref.watch(invoiceRepositoryProvider).getInvoices();
  return poRepo.calculateAllCompanySummaries(pos, invoices);
});

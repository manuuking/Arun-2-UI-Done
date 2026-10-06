import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/date_formatter.dart';
import '../../core/services/pin_security_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/company_profile.dart';
import '../../data/models/product.dart';
import '../../data/models/purchase_order.dart';
import '../../data/repositories/po_repository.dart';
import '../providers/providers.dart';

class PODashboardScreen extends ConsumerStatefulWidget {
  const PODashboardScreen({super.key});

  @override
  ConsumerState<PODashboardScreen> createState() => _PODashboardScreenState();
}

class _PODashboardScreenState extends ConsumerState<PODashboardScreen> {
  String _searchQuery = '';
  String? _selectedCompanyId;
  String? _selectedPoFilter;

  void _showAddPODialog() async {
    final companies = await ref.read(companyRepositoryProvider).getCompanies();
    final products = await ref.read(productRepositoryProvider).getProducts();

    if (companies.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please create a company first in Master Data'),
          ),
        );
      }
      return;
    }

    CompanyProfile selectedComp = companies.first;
    Product? selectedProd = products.isNotEmpty ? products.first : null;
    final poNoCtrl = TextEditingController(
      text:
          'PO-${DateTime.now().year}/${(DateTime.now().millisecondsSinceEpoch % 900) + 100}',
    );
    final qtyCtrl = TextEditingController(text: '5000');
    DateTime poDate = DateTime.now();

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'New Purchase Order (PO)',
            style: AppTextStyles.headlineSm,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<CompanyProfile>(
                  value: selectedComp,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Company *'),
                  items: companies
                      .map(
                        (c) => DropdownMenuItem(
                          value: c,
                          child: Text(c.name, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                  onChanged: (c) {
                    if (c != null) setModalState(() => selectedComp = c);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: poNoCtrl,
                  decoration: const InputDecoration(
                    labelText: 'PO Number *',
                    hintText: 'e.g. PO-2026/885',
                  ),
                ),
                const SizedBox(height: 12),
                if (products.isNotEmpty)
                  DropdownButtonFormField<Product>(
                    value: selectedProd,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Product'),
                    items: products
                        .map(
                          (p) => DropdownMenuItem(
                            value: p,
                            child: Text(
                              p.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (p) => setModalState(() => selectedProd = p),
                  ),
                const SizedBox(height: 12),
                TextField(
                  controller: qtyCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Total Ordered Quantity *',
                    suffixText: selectedProd?.unit ?? 'Pcs',
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('PO Date'),
                  subtitle: Text(AppDateFormatter.formatDate(poDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: poDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2035),
                    );
                    if (picked != null) {
                      setModalState(() => poDate = picked);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () async {
                final poNo = poNoCtrl.text.trim();
                final qty = double.tryParse(qtyCtrl.text.trim()) ?? 0;
                if (poNo.isEmpty || qty <= 0) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please enter valid PO Number and Quantity > 0',
                      ),
                    ),
                  );
                  return;
                }

                final newPo = PurchaseOrder(
                  id: 'po_${DateTime.now().millisecondsSinceEpoch}',
                  poNo: poNo,
                  companyId: selectedComp.id,
                  companyName: selectedComp.name,
                  productId: selectedProd?.id,
                  productName: selectedProd?.name,
                  poDate: poDate,
                  orderedQty: qty,
                  isActive: true,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                await ref.read(poRepositoryProvider).savePO(newPo);
                ref.invalidate(purchaseOrdersProvider);
                ref.invalidate(companyPOSummariesProvider);

                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('PO $poNo created successfully!'),
                      backgroundColor: AppColors.secondary,
                    ),
                  );
                }
              },
              child: const Text('CREATE PO'),
            ),
          ],
        ),
      ),
    );
  }

  void _togglePOStatus(PurchaseOrder po) async {
    final action = po.isActive ? 'Disable' : 'Reactivate';
    final authorized = await PinSecurityService.requestPinAuthorization(
      context,
      title: '$action PO ${po.poNo}',
      message:
          'Are you sure you want to $action this Purchase Order? 4-digit Admin PIN required.',
    );

    if (!authorized) return;

    await ref.read(poRepositoryProvider).togglePOActive(po.id, !po.isActive);
    ref.invalidate(purchaseOrdersProvider);
    ref.invalidate(companyPOSummariesProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'PO ${po.poNo} is now ${!po.isActive ? "Active" : "Disabled"}',
          ),
          backgroundColor: AppColors.secondary,
        ),
      );
    }
  }

  void _adjustPO(PurchaseOrder po) async {
    final summaries = ref.read(companyPOSummariesProvider).value ?? [];
    POBalanceInfo? bal;
    for (var s in summaries) {
      try {
        bal = s.poBalances.firstWhere((b) => b.po.id == po.id);
        break;
      } catch (_) {}
    }
    if (bal == null) return;

    final qtyCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Adjust PO Usage'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'TOTAL ORDER: ${bal!.effectiveTotalQty}\nUSED: ${bal.invoicedQty}\nREMAINING: ${bal.remainingQty}',
              style: AppTextStyles.bodySm,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: qtyCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                signed: true,
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Adjustment Amount (e.g. -100 or 50)',
                hintText: 'Negative decreases USED, positive increases USED',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              decoration: const InputDecoration(labelText: 'Reason'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () async {
              final val = double.tryParse(qtyCtrl.text.trim()) ?? 0.0;
              if (val == 0) return;

              if (bal!.invoicedQty + val < 0) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Cannot reduce USED below 0.')),
                );
                return;
              }
              if (bal.remainingQty - val < 0) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(
                    content: Text('Cannot reduce REMAINING below 0.'),
                  ),
                );
                return;
              }

              final authorized =
                  await PinSecurityService.requestPinAuthorization(
                    ctx,
                    title: 'Confirm Adjustment',
                    message: 'Apply adjustment of $val to PO ${po.poNo}?',
                  );
              if (authorized) {
                final adj = POAdjustment(
                  id: 'adj_${DateTime.now().millisecondsSinceEpoch}',
                  quantity: val,
                  reason: reasonCtrl.text.trim(),
                  date: DateTime.now(),
                );
                await ref.read(poRepositoryProvider).addAdjustment(po.id, adj);
                ref.invalidate(purchaseOrdersProvider);
                ref.invalidate(companyPOSummariesProvider);
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }

  void _editPO(PurchaseOrder po) async {
    final products = await ref.read(productRepositoryProvider).getProducts();

    final poNoCtrl = TextEditingController(text: po.poNo);
    final qtyCtrl = TextEditingController(text: po.orderedQty.toString());
    DateTime poDate = po.poDate;
    Product? selectedProd = products
        .where((p) => p.id == po.productId)
        .firstOrNull;

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setModalState) => AlertDialog(
          title: const Text('Edit PO'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: poNoCtrl,
                  decoration: const InputDecoration(labelText: 'PO Number *'),
                ),
                const SizedBox(height: 12),
                if (products.isNotEmpty)
                  DropdownButtonFormField<Product>(
                    value: selectedProd,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Product'),
                    items: products
                        .map(
                          (p) => DropdownMenuItem(
                            value: p,
                            child: Text(
                              p.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (p) => setModalState(() => selectedProd = p),
                  ),
                const SizedBox(height: 12),
                TextField(
                  controller: qtyCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Total Order Qty *',
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final d = await showDatePicker(
                      context: dialogCtx,
                      initialDate: poDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (d != null) setModalState(() => poDate = d);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'PO Date'),
                    child: Text(AppDateFormatter.formatDate(poDate)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () async {
                final poNo = poNoCtrl.text.trim();
                final qty = double.tryParse(qtyCtrl.text.trim()) ?? 0.0;
                if (poNo.isEmpty || qty <= 0) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                      content: Text('Invalid PO Number or Quantity'),
                    ),
                  );
                  return;
                }

                final authorized =
                    await PinSecurityService.requestPinAuthorization(
                      ctx,
                      title: 'Confirm Edit',
                      message: 'Save changes to PO ${po.poNo}?',
                    );
                if (authorized) {
                  final updatedPo = po.copyWith(
                    poNo: poNo,
                    productId: selectedProd?.id,
                    productName: selectedProd?.name,
                    poDate: poDate,
                    orderedQty: qty,
                    updatedAt: DateTime.now(),
                  );
                  await ref.read(poRepositoryProvider).savePO(updatedPo);
                  ref.invalidate(purchaseOrdersProvider);
                  ref.invalidate(companyPOSummariesProvider);
                  if (ctx.mounted) Navigator.pop(ctx);
                }
              },
              child: const Text('SAVE'),
            ),
          ],
        ),
      ),
    );
  }

  void _deletePO(PurchaseOrder po) async {
    final authorized = await PinSecurityService.requestPinAuthorization(
      context,
      title: 'Delete PO ${po.poNo}',
      message:
          'This is a DESTRUCTIVE action. Deleting PO ${po.poNo} cannot be undone. Enter 4-digit Admin PIN to confirm.',
    );

    if (!authorized) return;

    await ref.read(poRepositoryProvider).deletePO(po.id);
    ref.invalidate(purchaseOrdersProvider);
    ref.invalidate(companyPOSummariesProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PO ${po.poNo} permanently removed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final summariesAsync = ref.watch(companyPOSummariesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('PO Dashboard', style: AppTextStyles.headlineSm),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(companyPOSummariesProvider);
              ref.invalidate(purchaseOrdersProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'New PO',
            onPressed: _showAddPODialog,
          ),
        ],
      ),
      body: summariesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading PO data: $err')),
        data: (summaries) {
          final filtered = summaries.where((s) {
            final q = _searchQuery.toLowerCase();
            return q.isEmpty ||
                s.companyName.toLowerCase().contains(q) ||
                s.poBalances.any((b) => b.po.poNo.toLowerCase().contains(q));
          }).toList();

          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search company or PO Number...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                    fillColor: AppColors.surfaceContainerLowest,
                  ),
                ),
              ),

              // KPI Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 4.0,
                ),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _kpiItem(
                        'Total POs',
                        summaries
                            .fold<int>(0, (sum, s) => sum + s.poBalances.length)
                            .toString(),
                      ),
                      _kpiItem(
                        'Active POs',
                        summaries
                            .fold<int>(0, (sum, s) => sum + s.activePOCount)
                            .toString(),
                      ),
                      _kpiItem(
                        'Remaining Qty',
                        CurrencyFormatter.formatQuantity(
                          summaries.fold<double>(
                            0.0,
                            (sum, s) => sum + s.totalRemainingQty,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Main List
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.inventory_2_outlined,
                              size: 48,
                              color: AppColors.onSurfaceVariant,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No Purchase Orders found',
                              style: AppTextStyles.bodyMd,
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: _showAddPODialog,
                              icon: const Icon(Icons.add),
                              label: const Text('Create First PO'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 6.0,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final summary = filtered[index];
                          final isExpanded =
                              _selectedCompanyId == summary.companyId;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.outlineVariant,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Company Card Header (Clickable for drill-down)
                                InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () {
                                    setState(() {
                                      _selectedCompanyId = isExpanded
                                          ? null
                                          : summary.companyId;
                                      _selectedPoFilter = null;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                summary.companyName,
                                                style: AppTextStyles.headlineSm
                                                    .copyWith(fontSize: 16),
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 3,
                                                  ),
                                              decoration: BoxDecoration(
                                                color:
                                                    AppColors.primaryContainer,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                '${summary.activePOCount} Active POs',
                                                style: AppTextStyles.labelSm
                                                    .copyWith(
                                                      color:
                                                          AppColors.onPrimary,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        // Visual Progress/Level Bar (████████████░░░░)
                                        _buildCompanyVisualProgressBar(
                                          used: summary.totalInvoicedQty,
                                          total: summary.totalOrderedQty,
                                          remaining: summary.totalRemainingQty,
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'View Details Below',
                                              style: AppTextStyles.bodySm
                                                  .copyWith(
                                                    color: AppColors
                                                        .onSurfaceVariant,
                                                  ),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  isExpanded
                                                      ? 'Hide Details'
                                                      : 'View POs',
                                                  style: AppTextStyles.labelSm
                                                      .copyWith(
                                                        color:
                                                            AppColors.secondary,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                ),
                                                Icon(
                                                  isExpanded
                                                      ? Icons.keyboard_arrow_up
                                                      : Icons
                                                            .keyboard_arrow_down,
                                                  size: 18,
                                                  color: AppColors.secondary,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Expanded Drill-Down PO List
                                if (isExpanded) ...[
                                  const Divider(height: 1),
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'PURCHASE ORDERS',
                                          style: AppTextStyles.labelSm.copyWith(
                                            color: AppColors.onSurfaceVariant,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        ...(() {
                                          var activeList = summary.poBalances.where((b) => b.po.isActive).toList();
                                          var disabledList = summary.poBalances.where((b) => !b.po.isActive).toList();
                                          
                                          int sortFunc(a, b) {
                                            bool aComp = a.remainingQty <= 0;
                                            bool bComp = b.remainingQty <= 0;
                                            if (aComp && !bComp) return 1;
                                            if (!aComp && bComp) return -1;
                                            return b.po.poDate.compareTo(a.po.poDate);
                                          }
                                          
                                          activeList.sort(sortFunc);
                                          disabledList.sort(sortFunc);

                                          Widget buildPoCard(POBalanceInfo bal) {
                                            final po = bal.po;
                                            final isPoSelected =
                                                _selectedPoFilter == po.id;

                                            return Container(
                                            margin: const EdgeInsets.only(
                                              bottom: 8,
                                            ),
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: po.isActive
                                                  ? AppColors
                                                        .surfaceContainerLow
                                                  : AppColors
                                                        .surfaceContainerHigh
                                                        .withValues(alpha: 0.5),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: isPoSelected
                                                    ? AppColors.primary
                                                    : AppColors.outlineVariant,
                                                width: isPoSelected ? 1.5 : 0.8,
                                              ),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                          po.poNo,
                                                          style: AppTextStyles
                                                              .labelLg
                                                              .copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        if (!po.isActive)
                                                          Container(
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal: 6,
                                                                  vertical: 1,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color: AppColors
                                                                  .errorContainer,
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    4,
                                                                  ),
                                                            ),
                                                            child: Text(
                                                              'DISABLED',
                                                              style: AppTextStyles
                                                                  .labelSm
                                                                  .copyWith(
                                                                    color: AppColors
                                                                        .onErrorContainer,
                                                                    fontSize:
                                                                        10,
                                                                  ),
                                                            ),
                                                          )
                                                        else if (bal
                                                                .remainingQty <=
                                                            0)
                                                          Container(
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal: 6,
                                                                  vertical: 1,
                                                                ),
                                                            decoration:
                                                                BoxDecoration(
                                                                  color: Colors
                                                                      .green
                                                                      .shade100,
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        4,
                                                                      ),
                                                                ),
                                                            child: Text(
                                                              'COMPLETED',
                                                              style: AppTextStyles
                                                                  .labelSm
                                                                  .copyWith(
                                                                    color: Colors
                                                                        .green
                                                                        .shade800,
                                                                    fontSize:
                                                                        10,
                                                                  ),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                    PopupMenuButton<String>(
                                                      icon: const Icon(
                                                        Icons.more_vert,
                                                        size: 20,
                                                      ),
                                                      onSelected: (val) {
                                                        if (val == 'toggle')
                                                          _togglePOStatus(po);
                                                        if (val == 'delete')
                                                          _deletePO(po);
                                                        if (val == 'adjustment')
                                                          _adjustPO(po);
                                                        if (val == 'edit')
                                                          _editPO(po);
                                                      },
                                                      itemBuilder: (ctx) => [
                                                        const PopupMenuItem(
                                                          value: 'adjustment',
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                Icons.tune,
                                                                size: 18,
                                                                color: AppColors
                                                                    .primary,
                                                              ),
                                                              SizedBox(
                                                                width: 8,
                                                              ),
                                                              Text(
                                                                'Adjustment',
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        const PopupMenuItem(
                                                          value: 'edit',
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                Icons.edit,
                                                                size: 18,
                                                                color: AppColors
                                                                    .primary,
                                                              ),
                                                              SizedBox(
                                                                width: 8,
                                                              ),
                                                              Text('Edit PO'),
                                                            ],
                                                          ),
                                                        ),
                                                        PopupMenuItem(
                                                          value: 'toggle',
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                po.isActive
                                                                    ? Icons
                                                                          .block
                                                                    : Icons
                                                                          .check_circle_outline,
                                                                size: 18,
                                                              ),
                                                              SizedBox(
                                                                width: 8,
                                                              ),
                                                              Text(
                                                                po.isActive
                                                                    ? 'Disable PO'
                                                                    : 'Reactivate PO',
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        const PopupMenuItem(
                                                          value: 'delete',
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .delete_forever,
                                                                size: 18,
                                                                color: AppColors
                                                                    .error,
                                                              ),
                                                              SizedBox(
                                                                width: 8,
                                                              ),
                                                              Text(
                                                                'Remove PO',
                                                                style: TextStyle(
                                                                  color:
                                                                      AppColors
                                                                          .error,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                if (po.productName != null) ...[
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    'Product: ${po.productName}',
                                                    style: AppTextStyles.bodySm
                                                        .copyWith(
                                                          color: AppColors
                                                              .onSurfaceVariant,
                                                        ),
                                                  ),
                                                ],
                                                const SizedBox(height: 2),
                                                Text(
                                                  'PO Date: ${AppDateFormatter.formatDate(po.poDate)}',
                                                  style: AppTextStyles.bodySm
                                                      .copyWith(
                                                        color: AppColors
                                                            .onSurfaceVariant,
                                                      ),
                                                ),
                                                const SizedBox(height: 6),
                                                _buildPOVisualProgressBar(
                                                  used: bal.invoicedQty,
                                                  total: bal.effectiveTotalQty,
                                                  remaining: bal.remainingQty,
                                                ),
                                                const SizedBox(height: 6),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      '${bal.invoiceCount} invoices created',
                                                      style: AppTextStyles
                                                          .bodySm
                                                          .copyWith(
                                                            color: AppColors
                                                                .onSurfaceVariant,
                                                            fontSize: 11,
                                                          ),
                                                    ),
                                                  ],
                                                ),

                                                // Show Invoice-wise usage drill-down
                                                if (bal.usages.isNotEmpty) ...[
                                                  const SizedBox(height: 8),
                                                  InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        _selectedPoFilter =
                                                            isPoSelected
                                                            ? null
                                                            : po.id;
                                                      });
                                                    },
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            isPoSelected
                                                                ? 'Hide Invoice Usage'
                                                                : 'Show Invoice-wise Usage (${bal.usages.length})',
                                                            style: AppTextStyles
                                                                .bodySm
                                                                .copyWith(
                                                                  color: AppColors
                                                                      .primary,
                                                                  fontSize: 11,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                          ),
                                                          Icon(
                                                            isPoSelected
                                                                ? Icons
                                                                      .arrow_drop_up
                                                                : Icons
                                                                      .arrow_drop_down,
                                                            size: 16,
                                                            color:
                                                                AppColors.primary,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  if (isPoSelected) ...[
                                                    const SizedBox(height: 6),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            8,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: AppColors
                                                            .surfaceContainerLowest,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                        border: Border.all(
                                                          color: AppColors
                                                              .outlineVariant,
                                                        ),
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: bal.usages.map<Widget>((
                                                          u,
                                                        ) {
                                                          final qtyStr = CurrencyFormatter.formatQuantity(u.quantity);
                                                          return Padding(
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  vertical: 3,
                                                                ),
                                                            child: Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Text.rich(
                                                                    TextSpan(
                                                                      style: AppTextStyles.bodySm.copyWith(
                                                                        fontWeight: FontWeight.w500,
                                                                        color: AppColors.onSurfaceVariant,
                                                                        fontSize: 11,
                                                                      ),
                                                                      children: [
                                                                        TextSpan(
                                                                          text: '${u.invoiceNo} • ${AppDateFormatter.formatDate(u.date)} • ',
                                                                          style: AppTextStyles.bodySm.copyWith(
                                                                            color: AppColors.onSurfaceVariant,
                                                                          ),
                                                                        ),
                                                                        TextSpan(
                                                                          text: qtyStr,
                                                                          style: TextStyle(
                                                                            color: u.quantity < 0 ? AppColors.error : AppColors.primary,
                                                                            fontWeight: FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    maxLines: 1,
                                                                    overflow: TextOverflow.ellipsis,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        }).toList(),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ],
                                            ),
                                          );
                                          }

                                          final widgets = <Widget>[];
                                          widgets.addAll(activeList.map<Widget>((bal) => buildPoCard(bal)).toList());
                                          
                                          if (disabledList.isNotEmpty) {
                                            widgets.add(Theme(
                                              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                              child: ExpansionTile(
                                                tilePadding: EdgeInsets.zero,
                                                title: Text('Disabled POs (${disabledList.length})', style: AppTextStyles.labelSm),
                                                children: disabledList.map<Widget>((bal) {
                                                  return Opacity(
                                                    opacity: 0.8,
                                                    child: ColorFiltered(
                                                      colorFilter: const ColorFilter.matrix([
                                                        0.33, 0.33, 0.33, 0, 0,
                                                        0.33, 0.33, 0.33, 0, 0,
                                                        0.33, 0.33, 0.33, 0, 0,
                                                        0,    0,    0,    1, 0,
                                                      ]),
                                                      child: buildPoCard(bal),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ));
                                          }
                                          
                                          return widgets;
                                        }()),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPODialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: AppColors.onPrimary),
        label: Text(
          'New PO',
          style: AppTextStyles.labelLg.copyWith(color: AppColors.onPrimary),
        ),
      ),
    );
  }

  Widget _kpiItem(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: AppTextStyles.labelSm.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(value, style: AppTextStyles.headlineSm.copyWith(fontSize: 16)),
      ],
    );
  }

  Widget _buildCompanyVisualProgressBar({
    required double used,
    required double total,
    required double remaining,
  }) {
    final ratio = total > 0 ? (used / total).clamp(0.0, 1.0) : 0.0;

    // Different color combo for company
    Color statusColor = Colors.deepPurple;
    if (remaining > (total * 0.5)) {
      statusColor = Colors.deepPurpleAccent;
    } else if (remaining > (total * 0.1)) {
      statusColor = Colors.orange;
    } else if (remaining > 0) {
      statusColor = Colors.deepOrange;
    } else {
      statusColor = Colors.redAccent;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            Text(
              'TOTAL ORDER: ${CurrencyFormatter.formatQuantity(total)}',
              style: AppTextStyles.labelSm.copyWith(
                color: Colors.blueGrey,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'USED: ${CurrencyFormatter.formatQuantity(used)}',
              style: AppTextStyles.labelSm.copyWith(
                color: Colors.orange.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'REMAINING: ${CurrencyFormatter.formatQuantity(remaining)}',
              style: AppTextStyles.labelSm.copyWith(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: remaining < 0 ? 1.0 : ratio,
            minHeight: 12, // slightly thicker
            backgroundColor: Colors.blueGrey.shade100,
            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
          ),
        ),
      ],
    );
  }

  Widget _buildPOVisualProgressBar({
    required double used,
    required double total,
    required double remaining,
  }) {
    final ratio = total > 0 ? (used / total).clamp(0.0, 1.0) : 0.0;

    String remainingText = '';
    Color statusColor = AppColors.secondary;
    if (remaining > (total * 0.5)) {
      statusColor = AppColors.onTertiaryContainer; // Plenty remaining -> healthy green
    } else if (remaining > (total * 0.1)) {
      statusColor = AppColors.primary; // Medium -> black
    } else if (remaining > 0) {
      statusColor = AppColors.secondary; // Low remaining -> amber
    } else {
      statusColor = AppColors.error; // Exhausted/Over-allocated -> red
    }

    if (remaining < 0) {
      remainingText =
          'OVER-ALLOCATED by ${CurrencyFormatter.formatQuantity(-remaining)}';
    } else {
      remainingText =
          'REMAINING: ${CurrencyFormatter.formatQuantity(remaining)}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TOTAL ORDER: ${CurrencyFormatter.formatQuantity(total)}',
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'USED: ${CurrencyFormatter.formatQuantity(used)}',
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              remainingText,
              style: AppTextStyles.labelSm.copyWith(
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: remaining < 0 ? 1.0 : ratio,
            minHeight: 8,
            backgroundColor: AppColors.surfaceContainerHigh,
            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
          ),
        ),
      ],
    );
  }
}

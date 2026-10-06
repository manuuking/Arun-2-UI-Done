import 'package:hive_flutter/hive_flutter.dart';

import '../models/invoice.dart';
import '../models/purchase_order.dart';

class POBalanceInfo {
  final PurchaseOrder po;
  final double orderedQty;
  final double manualAdjustments;
  final double effectiveTotalQty;
  final double invoicedQty;
  final double remainingQty;
  final int invoiceCount;
  final List<InvoicePOUsage> usages;

  POBalanceInfo({
    required this.po,
    required this.orderedQty,
    required this.manualAdjustments,
    required this.effectiveTotalQty,
    required this.invoicedQty,
    required this.remainingQty,
    required this.invoiceCount,
    this.usages = const [],
  });

  double get usagePercent => effectiveTotalQty > 0
      ? (invoicedQty / effectiveTotalQty).clamp(0.0, 1.0)
      : 0.0;
}

class InvoicePOUsage {
  final String invoiceId;
  final String invoiceNo;
  final DateTime date;
  final String productName;
  final double quantity;

  InvoicePOUsage({
    required this.invoiceId,
    required this.invoiceNo,
    required this.date,
    required this.productName,
    required this.quantity,
  });
}

class CompanyPOSummary {
  final String companyId;
  final String companyName;
  final double totalOrderedQty;
  final double totalInvoicedQty;
  final double totalRemainingQty;
  final int activePOCount;
  final List<POBalanceInfo> poBalances;

  CompanyPOSummary({
    required this.companyId,
    required this.companyName,
    required this.totalOrderedQty,
    required this.totalInvoicedQty,
    required this.totalRemainingQty,
    required this.activePOCount,
    required this.poBalances,
  });

  double get remainingPercent => totalOrderedQty > 0
      ? (totalRemainingQty / totalOrderedQty).clamp(0.0, 1.0)
      : 0.0;
}

abstract class PORepository {
  Future<List<PurchaseOrder>> getPOs({String? companyId, bool? activeOnly});
  Future<PurchaseOrder?> getPOById(String id);
  Future<PurchaseOrder?> getPOByNumber(String poNo);
  Future<void> savePO(PurchaseOrder po);
  Future<void> deletePO(String id);
  Future<void> togglePOActive(String id, bool isActive);
  Future<void> addAdjustment(String poId, POAdjustment adjustment);
  POBalanceInfo calculatePOBalance(PurchaseOrder po, List<Invoice> allInvoices);
  List<CompanyPOSummary> calculateAllCompanySummaries(
    List<PurchaseOrder> pos,
    List<Invoice> invoices,
  );
}

class HivePORepository implements PORepository {
  Box get _box => Hive.box('purchase_orders');

  HivePORepository() {
    _seedInitialDataIfNeeded();
  }

  void _seedInitialDataIfNeeded() {
    if (_box.isEmpty) {
      final now = DateTime.now();

      final po1 = PurchaseOrder(
        id: 'po_pgp_881',
        poNo: 'PO-2026/881',
        companyId: 'comp_pgp',
        companyName: 'PGP Glass Private Limited',
        productId: 'prod_gloves',
        productName: 'Cotton Hand Gloves',
        poDate: now.subtract(const Duration(days: 30)),
        orderedQty: 10000.0,
        isActive: true,
        notes: 'Annual supply contract for cotton safety gloves',
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 30)),
      );

      final po2 = PurchaseOrder(
        id: 'po_pgp_882',
        poNo: 'PO-2026/882',
        companyId: 'comp_pgp',
        companyName: 'PGP Glass Private Limited',
        productId: 'prod_gloves',
        productName: 'Cotton Hand Gloves',
        poDate: now.subtract(const Duration(days: 20)),
        orderedQty: 5000.0,
        isActive: true,
        notes: 'High heat resistant special gloves lot',
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 20)),
      );

      final po3 = PurchaseOrder(
        id: 'po_pgp_883',
        poNo: 'PO-2026/883',
        companyId: 'comp_pgp',
        companyName: 'PGP Glass Private Limited',
        productId: 'prod_gloves',
        productName: 'Cotton Hand Gloves',
        poDate: now.subtract(const Duration(days: 10)),
        orderedQty: 2500.0,
        isActive: true,
        notes: 'Reserve stock PO',
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 10)),
      );

      final poSterling = PurchaseOrder(
        id: 'po_sterling_1',
        poNo: '9002123',
        companyId: 'comp_sterling',
        companyName: 'Sterling Safety Equips Ltd',
        productId: 'prod_uniforms',
        productName: 'Industrial Uniforms',
        poDate: now.subtract(const Duration(days: 45)),
        orderedQty: 1000.0,
        isActive: true,
        notes: 'Boiler suits and safety sets',
        createdAt: now.subtract(const Duration(days: 45)),
        updatedAt: now.subtract(const Duration(days: 45)),
      );

      final poSaurashtra = PurchaseOrder(
        id: 'po_saurashtra_1',
        poNo: 'SIC-26/10',
        companyId: 'comp_saurashtra',
        companyName: 'Saurashtra Industrial Corp',
        productId: 'prod_vests',
        productName: 'High-Vis Vests',
        poDate: now.subtract(const Duration(days: 15)),
        orderedQty: 2000.0,
        isActive: true,
        notes: 'Reflective safety vests high-vis',
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now.subtract(const Duration(days: 15)),
      );

      _box.put(po1.id, po1.toMap());
      _box.put(po2.id, po2.toMap());
      _box.put(po3.id, po3.toMap());
      _box.put(poSterling.id, poSterling.toMap());
      _box.put(poSaurashtra.id, poSaurashtra.toMap());
    }
  }

  @override
  Future<List<PurchaseOrder>> getPOs({
    String? companyId,
    bool? activeOnly,
  }) async {
    final List<PurchaseOrder> list = [];
    for (final key in _box.keys) {
      final raw = _box.get(key);
      if (raw is Map) {
        final po = PurchaseOrder.fromMap(Map<dynamic, dynamic>.from(raw));
        if (companyId != null && po.companyId != companyId) continue;
        if (activeOnly == true && !po.isActive) continue;
        list.add(po);
      }
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<PurchaseOrder?> getPOById(String id) async {
    final raw = _box.get(id);
    if (raw != null) {
      return PurchaseOrder.fromMap(Map<dynamic, dynamic>.from(raw as Map));
    }
    return null;
  }

  @override
  Future<PurchaseOrder?> getPOByNumber(String poNo) async {
    final cleanPo = poNo.trim().toLowerCase();
    for (final key in _box.keys) {
      final raw = _box.get(key);
      if (raw is Map) {
        final po = PurchaseOrder.fromMap(Map<dynamic, dynamic>.from(raw));
        if (po.poNo.trim().toLowerCase() == cleanPo) {
          return po;
        }
      }
    }
    return null;
  }

  @override
  Future<void> savePO(PurchaseOrder po) async {
    await _box.put(po.id, po.toMap());
  }

  @override
  Future<void> deletePO(String id) async {
    await _box.delete(id);
  }

  @override
  Future<void> togglePOActive(String id, bool isActive) async {
    final po = await getPOById(id);
    if (po != null) {
      final updated = po.copyWith(
        isActive: isActive,
        updatedAt: DateTime.now(),
      );
      await savePO(updated);
    }
  }

  @override
  Future<void> addAdjustment(String poId, POAdjustment adjustment) async {
    final po = await getPOById(poId);
    if (po != null) {
      final list = List<POAdjustment>.from(po.adjustments)..add(adjustment);
      final updated = po.copyWith(adjustments: list, updatedAt: DateTime.now());
      await savePO(updated);
    }
  }

  @override
  POBalanceInfo calculatePOBalance(
    PurchaseOrder po,
    List<Invoice> allInvoices,
  ) {
    final cleanPoNo = po.poNo.trim().toLowerCase();
    final cleanPoId = po.id.trim().toLowerCase();

    double invoicedSum = 0.0;
    final List<InvoicePOUsage> usages = [];

    // Filter to active, non-rejected, non-draft invoices
    final activeInvoices = allInvoices.where(
      (inv) => inv.status != 'rejected' && inv.status != 'draft',
    );

    for (final inv in activeInvoices) {
      double invoiceTotalAllocated = 0.0;
      for (final item in inv.items) {
        // 1. Check item-level multi-PO allocations
        if (item.poAllocations.isNotEmpty) {
          for (final alloc in item.poAllocations) {
            final matchId = alloc.poId.trim().toLowerCase();
            final matchNo = alloc.poNo.trim().toLowerCase();
            if (matchId == cleanPoId || matchNo == cleanPoNo) {
              invoiceTotalAllocated += alloc.allocatedQty;
            }
          }
        } else if (item.poId != null && item.poId!.trim().isNotEmpty) {
          // 2. Check item-level single poId
          final itemPo = item.poId!.trim().toLowerCase();
          if (itemPo == cleanPoNo || itemPo == cleanPoId) {
            invoiceTotalAllocated += item.quantity;
          }
        } else if (inv.orderNo != null && inv.orderNo!.trim().isNotEmpty) {
          // 3. Fallback to invoice header orderNo if item poId is not set
          final invOrder = inv.orderNo!.trim().toLowerCase();
          if (invOrder == cleanPoNo || invOrder == cleanPoId) {
            invoiceTotalAllocated += item.quantity;
          }
        }
      }

      if (invoiceTotalAllocated != 0.0) {
        invoicedSum += invoiceTotalAllocated;
        usages.add(
          InvoicePOUsage(
            invoiceId: inv.id,
            invoiceNo: inv.invoiceNo,
            date: inv.invoiceDate,
            productName: 'Multiple Items',
            quantity: invoiceTotalAllocated,
          ),
        );
      }
    }

    final manualAdjustments = po.adjustments.fold<double>(
      0.0,
      (sum, a) => sum + a.quantity,
    );

    // Add adjustments to usages so they appear in the UI
    for (final adj in po.adjustments) {
      usages.add(
        InvoicePOUsage(
          invoiceId: adj.id,
          invoiceNo: adj.reason.isNotEmpty ? 'ADJ: ${adj.reason}' : 'Adjustment',
          date: adj.date,
          productName: 'Manual Adjustment',
          quantity: adj.quantity,
        ),
      );
    }

    final effectiveTotal = po.orderedQty;
    final effectiveUsed = invoicedSum + manualAdjustments;
    final remaining = effectiveTotal - effectiveUsed;

    // Sort usages descending by date
    usages.sort((a, b) => b.date.compareTo(a.date));

    return POBalanceInfo(
      po: po,
      orderedQty: po.orderedQty,
      manualAdjustments: manualAdjustments,
      effectiveTotalQty: effectiveTotal,
      invoicedQty: effectiveUsed,
      remainingQty: remaining,
      invoiceCount: usages.map((u) => u.invoiceId).toSet().length,
      usages: usages,
    );
  }

  @override
  List<CompanyPOSummary> calculateAllCompanySummaries(
    List<PurchaseOrder> pos,
    List<Invoice> invoices,
  ) {
    final Map<String, List<PurchaseOrder>> companyMap = {};
    final Map<String, String> companyNames = {};

    for (final po in pos) {
      companyMap.putIfAbsent(po.companyId, () => []).add(po);
      companyNames[po.companyId] = po.companyName;
    }

    final List<CompanyPOSummary> summaries = [];

    companyMap.forEach((companyId, cPos) {
      double companyOrdered = 0.0;
      double companyInvoiced = 0.0;
      double companyRemaining = 0.0;
      int activeCount = 0;
      final List<POBalanceInfo> balances = [];

      for (final po in cPos) {
        final bal = calculatePOBalance(po, invoices);
        balances.add(bal);
        companyOrdered += bal.effectiveTotalQty;
        companyInvoiced += bal.invoicedQty;
        companyRemaining += bal.remainingQty;
        if (po.isActive) activeCount++;
      }

      summaries.add(
        CompanyPOSummary(
          companyId: companyId,
          companyName: companyNames[companyId] ?? companyId,
          totalOrderedQty: companyOrdered,
          totalInvoicedQty: companyInvoiced,
          totalRemainingQty: companyRemaining,
          activePOCount: activeCount,
          poBalances: balances,
        ),
      );
    });

    summaries.sort(
      (a, b) => b.totalRemainingQty.compareTo(a.totalRemainingQty),
    );
    return summaries;
  }
}

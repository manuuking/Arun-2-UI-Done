class PurchaseOrder {
  final String id;
  final String poNo;
  final String companyId;
  final String companyName;
  final String? productId;
  final String? productName;
  final DateTime poDate;
  final double orderedQty;
  final List<POAdjustment> adjustments;
  final bool isActive;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  PurchaseOrder({
    required this.id,
    required this.poNo,
    required this.companyId,
    required this.companyName,
    this.productId,
    this.productName,
    required this.poDate,
    required this.orderedQty,
    this.adjustments = const [],
    this.isActive = true,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Total quantity
  double get effectiveTotalQty {
    return orderedQty;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'poNo': poNo,
      'companyId': companyId,
      'companyName': companyName,
      'productId': productId,
      'productName': productName,
      'poDate': poDate.toIso8601String(),
      'orderedQty': orderedQty,
      'adjustments': adjustments.map((a) => a.toMap()).toList(),
      'isActive': isActive,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory PurchaseOrder.fromMap(Map<dynamic, dynamic> map) {
    return PurchaseOrder(
      id: map['id']?.toString() ?? '',
      poNo: map['poNo']?.toString() ?? '',
      companyId: map['companyId']?.toString() ?? '',
      companyName: map['companyName']?.toString() ?? '',
      productId: map['productId']?.toString(),
      productName: map['productName']?.toString(),
      poDate: map['poDate'] != null
          ? DateTime.tryParse(map['poDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      orderedQty: (map['orderedQty'] as num?)?.toDouble() ?? 0.0,
      adjustments:
          (map['adjustments'] as List?)
              ?.map(
                (a) =>
                    POAdjustment.fromMap(Map<dynamic, dynamic>.from(a as Map)),
              )
              .toList() ??
          [],
      isActive: map['isActive'] as bool? ?? true,
      notes: map['notes']?.toString(),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  PurchaseOrder copyWith({
    String? id,
    String? poNo,
    String? companyId,
    String? companyName,
    String? productId,
    String? productName,
    DateTime? poDate,
    double? orderedQty,
    List<POAdjustment>? adjustments,
    bool? isActive,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PurchaseOrder(
      id: id ?? this.id,
      poNo: poNo ?? this.poNo,
      companyId: companyId ?? this.companyId,
      companyName: companyName ?? this.companyName,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      poDate: poDate ?? this.poDate,
      orderedQty: orderedQty ?? this.orderedQty,
      adjustments: adjustments ?? this.adjustments,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PurchaseOrder &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Manual adjustment for extra material or manual corrections (+/- qty)
class POAdjustment {
  final String id;
  final double quantity; // Positive for extra material, negative for deduction
  final String reason;
  final DateTime date;
  final String? adminPinVerified;

  POAdjustment({
    required this.id,
    required this.quantity,
    required this.reason,
    required this.date,
    this.adminPinVerified,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quantity': quantity,
      'reason': reason,
      'date': date.toIso8601String(),
      'adminPinVerified': adminPinVerified,
    };
  }

  factory POAdjustment.fromMap(Map<dynamic, dynamic> map) {
    return POAdjustment(
      id: map['id']?.toString() ?? '',
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0.0,
      reason: map['reason']?.toString() ?? '',
      date: map['date'] != null
          ? DateTime.tryParse(map['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      adminPinVerified: map['adminPinVerified']?.toString(),
    );
  }
}

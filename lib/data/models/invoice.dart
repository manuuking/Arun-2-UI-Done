class Invoice {
  final String id;
  final String invoiceNo;
  final String? challanNo;
  final DateTime invoiceDate;
  final String? orderNo;
  final String? transportBy;
  final String? lrNo;
  final String? lrDate;
  final String? parcelNo;
  final String sellerId;
  final String buyerId;
  final String buyerName;
  final String? buyerGstin;
  final String buyerAddress;
  final List<InvoiceItem> items;
  final double subtotal;
  final double cgst;
  final double sgstAmount;
  final double igst;
  final double otherExp;
  final double roundOff;
  final double grandTotal;
  final String amountInWords;
  final String invoiceType; // original / duplicate
  final String status; // pending / paid / rejected / draft
  final double paidAmount;
  final String? driveFileId;
  final String? driveFilePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  Invoice({
    required this.id,
    required this.invoiceNo,
    this.challanNo,
    required this.invoiceDate,
    this.orderNo,
    this.transportBy,
    this.lrNo,
    this.lrDate,
    this.parcelNo,
    required this.sellerId,
    required this.buyerId,
    required this.buyerName,
    this.buyerGstin,
    required this.buyerAddress,
    required this.items,
    required this.subtotal,
    required this.cgst,
    required this.sgstAmount,
    required this.igst,
    this.otherExp = 0.0,
    required this.roundOff,
    required this.grandTotal,
    required this.amountInWords,
    this.invoiceType = 'original',
    this.status = 'pending',
    this.paidAmount = 0.0,
    this.driveFileId,
    this.driveFilePath,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoiceNo': invoiceNo,
      'challanNo': challanNo,
      'invoiceDate': invoiceDate.toIso8601String(),
      'orderNo': orderNo,
      'transportBy': transportBy,
      'lrNo': lrNo,
      'lrDate': lrDate,
      'parcelNo': parcelNo,
      'sellerId': sellerId,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'buyerGstin': buyerGstin,
      'buyerAddress': buyerAddress,
      'items': items.map((i) => i.toMap()).toList(),
      'subtotal': subtotal,
      'cgst': cgst,
      'sgstAmount': sgstAmount,
      'igst': igst,
      'otherExp': otherExp,
      'roundOff': roundOff,
      'grandTotal': grandTotal,
      'amountInWords': amountInWords,
      'invoiceType': invoiceType,
      'status': status,
      'paidAmount': paidAmount,
      'driveFileId': driveFileId,
      'driveFilePath': driveFilePath,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Invoice.fromMap(Map<dynamic, dynamic> map) {
    return Invoice(
      id: map['id']?.toString() ?? '',
      invoiceNo: map['invoiceNo']?.toString() ?? '',
      challanNo: map['challanNo']?.toString(),
      invoiceDate: map['invoiceDate'] != null
          ? DateTime.tryParse(map['invoiceDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      orderNo: map['orderNo']?.toString(),
      transportBy: map['transportBy']?.toString(),
      lrNo: map['lrNo']?.toString(),
      lrDate: map['lrDate']?.toString(),
      parcelNo: map['parcelNo']?.toString(),
      sellerId: map['sellerId']?.toString() ?? 'arun_mensware_default',
      buyerId: map['buyerId']?.toString() ?? '',
      buyerName: map['buyerName']?.toString() ?? '',
      buyerGstin: map['buyerGstin']?.toString(),
      buyerAddress: map['buyerAddress']?.toString() ?? '',
      items:
          (map['items'] as List?)
              ?.map(
                (i) =>
                    InvoiceItem.fromMap(Map<dynamic, dynamic>.from(i as Map)),
              )
              .toList() ??
          [],
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
      cgst: (map['cgst'] as num?)?.toDouble() ?? 0.0,
      sgstAmount: (map['sgstAmount'] as num?)?.toDouble() ?? 0.0,
      igst: (map['igst'] as num?)?.toDouble() ?? 0.0,
      otherExp: (map['otherExp'] as num?)?.toDouble() ?? 0.0,
      roundOff: (map['roundOff'] as num?)?.toDouble() ?? 0.0,
      grandTotal: (map['grandTotal'] as num?)?.toDouble() ?? 0.0,
      amountInWords: map['amountInWords']?.toString() ?? '',
      invoiceType: map['invoiceType']?.toString() ?? 'original',
      status: map['status']?.toString() ?? 'pending',
      paidAmount: (map['paidAmount'] as num?)?.toDouble() ?? 0.0,
      driveFileId: map['driveFileId']?.toString(),
      driveFilePath: map['driveFilePath']?.toString(),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Invoice copyWith({
    String? id,
    String? invoiceNo,
    String? challanNo,
    DateTime? invoiceDate,
    String? orderNo,
    String? transportBy,
    String? lrNo,
    String? lrDate,
    String? parcelNo,
    String? sellerId,
    String? buyerId,
    String? buyerName,
    String? buyerGstin,
    String? buyerAddress,
    List<InvoiceItem>? items,
    double? subtotal,
    double? cgst,
    double? sgstAmount,
    double? igst,
    double? otherExp,
    double? roundOff,
    double? grandTotal,
    String? amountInWords,
    String? invoiceType,
    String? status,
    double? paidAmount,
    String? driveFileId,
    String? driveFilePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Invoice(
      id: id ?? this.id,
      invoiceNo: invoiceNo ?? this.invoiceNo,
      challanNo: challanNo ?? this.challanNo,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      orderNo: orderNo ?? this.orderNo,
      transportBy: transportBy ?? this.transportBy,
      lrNo: lrNo ?? this.lrNo,
      lrDate: lrDate ?? this.lrDate,
      parcelNo: parcelNo ?? this.parcelNo,
      sellerId: sellerId ?? this.sellerId,
      buyerId: buyerId ?? this.buyerId,
      buyerName: buyerName ?? this.buyerName,
      buyerGstin: buyerGstin ?? this.buyerGstin,
      buyerAddress: buyerAddress ?? this.buyerAddress,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      cgst: cgst ?? this.cgst,
      sgstAmount: sgstAmount ?? this.sgstAmount,
      igst: igst ?? this.igst,
      otherExp: otherExp ?? this.otherExp,
      roundOff: roundOff ?? this.roundOff,
      grandTotal: grandTotal ?? this.grandTotal,
      amountInWords: amountInWords ?? this.amountInWords,
      invoiceType: invoiceType ?? this.invoiceType,
      status: status ?? this.status,
      paidAmount: paidAmount ?? this.paidAmount,
      driveFileId: driveFileId ?? this.driveFileId,
      driveFilePath: driveFilePath ?? this.driveFilePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class POAllocation {
  final String poId;
  final String poNo;
  final double allocatedQty;

  POAllocation({
    required this.poId,
    required this.poNo,
    required this.allocatedQty,
  });

  Map<String, dynamic> toMap() {
    return {'poId': poId, 'poNo': poNo, 'allocatedQty': allocatedQty};
  }

  factory POAllocation.fromMap(Map<dynamic, dynamic> map) {
    return POAllocation(
      poId: map['poId']?.toString() ?? '',
      poNo: map['poNo']?.toString() ?? '',
      allocatedQty: (map['allocatedQty'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class InvoiceItem {
  final String id;
  final String productId;
  final String productName;
  final String? description;
  final String hsnCode;
  final String unit;
  final double quantity;
  final double rate;
  final double amount;
  final String taxSlab; // CGST+SGST / IGST
  final double cgstRate;
  final double sgstRate;
  final double igstRate;
  final String? poId; // Primary PO or Manual PO text
  final List<POAllocation> poAllocations;

  InvoiceItem({
    required this.id,
    required this.productId,
    required this.productName,
    this.description,
    required this.hsnCode,
    required this.unit,
    required this.quantity,
    required this.rate,
    required this.amount,
    required this.taxSlab,
    this.cgstRate = 0.0,
    this.sgstRate = 0.0,
    this.igstRate = 0.0,
    this.poId,
    this.poAllocations = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'description': description,
      'hsnCode': hsnCode,
      'unit': unit,
      'quantity': quantity,
      'rate': rate,
      'amount': amount,
      'taxSlab': taxSlab,
      'cgstRate': cgstRate,
      'sgstRate': sgstRate,
      'igstRate': igstRate,
      'poId': poId,
      'poAllocations': poAllocations.map((a) => a.toMap()).toList(),
    };
  }

  factory InvoiceItem.fromMap(Map<dynamic, dynamic> map) {
    return InvoiceItem(
      id: map['id']?.toString() ?? '',
      productId: map['productId']?.toString() ?? '',
      productName: map['productName']?.toString() ?? '',
      description: map['description']?.toString(),
      hsnCode: map['hsnCode']?.toString() ?? '',
      unit: map['unit']?.toString() ?? 'Pcs',
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0.0,
      rate: (map['rate'] as num?)?.toDouble() ?? 0.0,
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      taxSlab: map['taxSlab']?.toString() ?? 'CGST+SGST',
      cgstRate: (map['cgstRate'] as num?)?.toDouble() ?? 0.0,
      sgstRate: (map['sgstRate'] as num?)?.toDouble() ?? 0.0,
      igstRate: (map['igstRate'] as num?)?.toDouble() ?? 0.0,
      poId: map['poId']?.toString(),
      poAllocations:
          (map['poAllocations'] as List?)
              ?.map(
                (a) =>
                    POAllocation.fromMap(Map<dynamic, dynamic>.from(a as Map)),
              )
              .toList() ??
          [],
    );
  }

  InvoiceItem copyWith({
    String? id,
    String? productId,
    String? productName,
    String? description,
    String? hsnCode,
    String? unit,
    double? quantity,
    double? rate,
    double? amount,
    String? taxSlab,
    double? cgstRate,
    double? sgstRate,
    double? igstRate,
    String? poId,
    List<POAllocation>? poAllocations,
  }) {
    return InvoiceItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      description: description ?? this.description,
      hsnCode: hsnCode ?? this.hsnCode,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      rate: rate ?? this.rate,
      amount: amount ?? this.amount,
      taxSlab: taxSlab ?? this.taxSlab,
      cgstRate: cgstRate ?? this.cgstRate,
      sgstRate: sgstRate ?? this.sgstRate,
      igstRate: igstRate ?? this.igstRate,
      poId: poId ?? this.poId,
      poAllocations: poAllocations ?? this.poAllocations,
    );
  }
}

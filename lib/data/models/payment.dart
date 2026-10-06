class Payment {
  final String id;
  final String invoiceId;
  final double amount;
  final DateTime paymentDate;
  final String method; // Cash / Cheque / NEFT / UPI
  final String? referenceNo; // cheque no., UTR, etc.
  final String? notes;
  final DateTime createdAt;

  Payment({
    required this.id,
    required this.invoiceId,
    required this.amount,
    required this.paymentDate,
    required this.method,
    this.referenceNo,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoiceId': invoiceId,
      'amount': amount,
      'paymentDate': paymentDate.toIso8601String(),
      'method': method,
      'referenceNo': referenceNo,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Payment.fromMap(Map<dynamic, dynamic> map) {
    return Payment(
      id: map['id']?.toString() ?? '',
      invoiceId: map['invoiceId']?.toString() ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      paymentDate: map['paymentDate'] != null
          ? DateTime.tryParse(map['paymentDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      method: map['method']?.toString() ?? 'Cash',
      referenceNo: map['referenceNo']?.toString(),
      notes: map['notes']?.toString(),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Payment copyWith({
    String? id,
    String? invoiceId,
    double? amount,
    DateTime? paymentDate,
    String? method,
    String? referenceNo,
    String? notes,
    DateTime? createdAt,
  }) {
    return Payment(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      method: method ?? this.method,
      referenceNo: referenceNo ?? this.referenceNo,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

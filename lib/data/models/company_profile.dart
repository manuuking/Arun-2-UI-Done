class CompanyProfile {
  final String id;
  final String name;
  final String shortName;
  final List<String> gstin; // primary + additional
  final List<Address> addresses;
  final List<CompanyProductRate> productRates;
  final bool isActive;
  final DateTime createdAt;

  CompanyProfile({
    required this.id,
    required this.name,
    required this.shortName,
    this.gstin = const [],
    this.addresses = const [],
    this.productRates = const [],
    this.isActive = true,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'shortName': shortName,
      'gstin': gstin,
      'addresses': addresses.map((a) => a.toMap()).toList(),
      'productRates': productRates.map((r) => r.toMap()).toList(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CompanyProfile.fromMap(Map<dynamic, dynamic> map) {
    return CompanyProfile(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      shortName: map['shortName']?.toString() ?? '',
      gstin: (map['gstin'] as List?)?.map((e) => e.toString()).toList() ?? [],
      addresses:
          (map['addresses'] as List?)
              ?.map(
                (e) => Address.fromMap(Map<dynamic, dynamic>.from(e as Map)),
              )
              .toList() ??
          [],
      productRates:
          (map['productRates'] as List?)
              ?.map(
                (e) => CompanyProductRate.fromMap(
                  Map<dynamic, dynamic>.from(e as Map),
                ),
              )
              .toList() ??
          [],
      isActive: map['isActive'] as bool? ?? true,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  CompanyProfile copyWith({
    String? id,
    String? name,
    String? shortName,
    List<String>? gstin,
    List<Address>? addresses,
    List<CompanyProductRate>? productRates,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return CompanyProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      gstin: gstin ?? this.gstin,
      addresses: addresses ?? this.addresses,
      productRates: productRates ?? this.productRates,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompanyProfile &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class Address {
  final String id;
  final String label; // "Warehouse A", "Head Office"
  final String fullAddress;
  final String pincode;
  final String city;
  final String state;

  Address({
    required this.id,
    required this.label,
    required this.fullAddress,
    required this.pincode,
    required this.city,
    required this.state,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'fullAddress': fullAddress,
      'pincode': pincode,
      'city': city,
      'state': state,
    };
  }

  factory Address.fromMap(Map<dynamic, dynamic> map) {
    return Address(
      id: map['id']?.toString() ?? '',
      label: map['label']?.toString() ?? 'Default',
      fullAddress: map['fullAddress']?.toString() ?? '',
      pincode: map['pincode']?.toString() ?? '',
      city: map['city']?.toString() ?? '',
      state: map['state']?.toString() ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Address && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class CompanyProductRate {
  final String productId;
  final String label; // "Standard", "Bulk", "Urgent"
  final double rate;

  CompanyProductRate({
    required this.productId,
    required this.label,
    required this.rate,
  });

  Map<String, dynamic> toMap() {
    return {'productId': productId, 'label': label, 'rate': rate};
  }

  factory CompanyProductRate.fromMap(Map<dynamic, dynamic> map) {
    return CompanyProductRate(
      productId: map['productId']?.toString() ?? '',
      label: map['label']?.toString() ?? 'Standard',
      rate: (map['rate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompanyProductRate &&
          runtimeType == other.runtimeType &&
          productId == other.productId &&
          label == other.label;

  @override
  int get hashCode => productId.hashCode ^ label.hashCode;
}

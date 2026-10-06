class Product {
  final String id;
  final String name;
  final String? description;
  final String hsnCode;
  final String unit;
  final double defaultRate;
  final bool isActive;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.hsnCode,
    required this.unit,
    required this.defaultRate,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'hsnCode': hsnCode,
      'unit': unit,
      'defaultRate': defaultRate,
      'isActive': isActive,
    };
  }

  factory Product.fromMap(Map<dynamic, dynamic> map) {
    return Product(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString(),
      hsnCode: map['hsnCode']?.toString() ?? '',
      unit: map['unit']?.toString() ?? 'Pcs',
      defaultRate: (map['defaultRate'] as num?)?.toDouble() ?? 0.0,
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    String? hsnCode,
    String? unit,
    double? defaultRate,
    bool? isActive,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      hsnCode: hsnCode ?? this.hsnCode,
      unit: unit ?? this.unit,
      defaultRate: defaultRate ?? this.defaultRate,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

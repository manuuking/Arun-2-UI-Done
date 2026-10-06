class Transporter {
  final String id;
  final String name;
  final String? phone;
  final String? gstin;
  final bool isActive;

  Transporter({
    required this.id,
    required this.name,
    this.phone,
    this.gstin,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'gstin': gstin,
      'isActive': isActive,
    };
  }

  factory Transporter.fromMap(Map<dynamic, dynamic> map) {
    return Transporter(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      phone: map['phone']?.toString(),
      gstin: map['gstin']?.toString(),
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  Transporter copyWith({
    String? id,
    String? name,
    String? phone,
    String? gstin,
    bool? isActive,
  }) {
    return Transporter(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      gstin: gstin ?? this.gstin,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transporter &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

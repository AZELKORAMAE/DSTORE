class SupplierModel {
  static SupplierModel empty() {
    return SupplierModel(
      id: '',
      userId: '',
      name: '',
      isActive: true,
      totalPurchases: 0.0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
  
  final String id;
  final String userId;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final String? city;
  final String? contactPerson;
  final String? notes;
  final bool isActive;
  final int? productCount;
  final double totalPurchases;
  final DateTime? lastOrderDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  SupplierModel({
    required this.id,
    required this.userId,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.city,
    this.contactPerson,
    this.notes,
    required this.isActive,
    this.productCount,
    required this.totalPurchases,
    this.lastOrderDate,
    required this.createdAt,
    required this.updatedAt,
  });

  // Getters calculés
  String get initials {
    final words = name.trim().split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (words.isNotEmpty) {
      return words[0].substring(0, words[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'SP';
  }

  String get fullAddress {
    final parts = <String>[];
    if ((address ?? '').isNotEmpty) parts.add(address!);
    if ((city ?? '').isNotEmpty) parts.add(city!);
    return parts.join(', ');
  }

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      contactPerson: json['contact_person']?.toString(),
      notes: json['notes']?.toString(),
      isActive: json['is_active'] as bool? ?? true,
      productCount: json['product_count'] as int?,
      totalPurchases: (json['total_purchases'] as num?)?.toDouble() ?? 0.0,
      lastOrderDate: json['last_order_date'] != null
          ? DateTime.parse(json['last_order_date'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'contact_person': contactPerson,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'contact_person': contactPerson,
      'is_active': isActive,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'contact_person': contactPerson,
      'is_active': isActive,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  SupplierModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? contactPerson,
    String? notes,
    bool? isActive,
    int? productCount,
    double? totalPurchases,
    DateTime? lastOrderDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SupplierModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      contactPerson: contactPerson ?? this.contactPerson,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      productCount: productCount ?? this.productCount,
      totalPurchases: totalPurchases ?? this.totalPurchases,
      lastOrderDate: lastOrderDate ?? this.lastOrderDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'SupplierModel(id: $id, name: $name, contactPerson: $contactPerson)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SupplierModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

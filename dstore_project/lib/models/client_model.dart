class ClientModel {
  static ClientModel empty() {
    return ClientModel(
      id: '',
      userId: '',
      name: '',
      creditLimit: 0.0,
      currentCredit: 0.0,
      totalPurchases: 0.0,
      isActive: true,
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
  final String? notes;
  final double creditLimit;
  final double currentCredit;
  final double totalPurchases;
  final DateTime? lastPurchaseDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ClientModel({
    required this.id,
    required this.userId,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.city,
    this.notes,
    required this.creditLimit,
    required this.currentCredit,
    required this.totalPurchases,
    this.lastPurchaseDate,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      notes: json['notes']?.toString(),
      creditLimit: (json['credit_limit'] as num?)?.toDouble() ?? 0.0,
      currentCredit: (json['current_credit'] as num?)?.toDouble() ?? 0.0,
      totalPurchases: (json['total_purchases'] as num?)?.toDouble() ?? 0.0,
      lastPurchaseDate: json['last_purchase_date'] != null
          ? DateTime.parse(json['last_purchase_date'].toString())
          : null,
      isActive: json['is_active'] as bool? ?? true,
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
      'city': city,
      'notes': notes,
      'credit_limit': creditLimit,
      'current_credit': currentCredit,
      'total_purchases': totalPurchases,
      'last_purchase_date': lastPurchaseDate?.toIso8601String(),
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
      'city': city,
      'notes': notes,
      'credit_limit': creditLimit,
      'current_credit': currentCredit,
      'total_purchases': totalPurchases,
      'last_purchase_date': lastPurchaseDate?.toIso8601String(),
      'is_active': isActive,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'notes': notes,
      'credit_limit': creditLimit,
      'current_credit': currentCredit,
      'total_purchases': totalPurchases,
      'last_purchase_date': lastPurchaseDate?.toIso8601String(),
      'is_active': isActive,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  ClientModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? notes,
    double? creditLimit,
    double? currentCredit,
    double? totalPurchases,
    DateTime? lastPurchaseDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ClientModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      notes: notes ?? this.notes,
      creditLimit: creditLimit ?? this.creditLimit,
      currentCredit: currentCredit ?? this.currentCredit,
      totalPurchases: totalPurchases ?? this.totalPurchases,
      lastPurchaseDate: lastPurchaseDate ?? this.lastPurchaseDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Getters calculés
  String get initials {
    final words = name.trim().split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (words.isNotEmpty) {
      return words[0].substring(0, words[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'CL';
  }

  // Alias pour compatibilité
  double get creditBalance => currentCredit;

  // Calculer le crédit disponible
  double get availableCredit {
    return creditLimit - currentCredit;
  }

  // Pourcentage d'utilisation du crédit
  double get creditUsagePercentage {
    if (creditLimit <= 0) return 0.0;
    return (currentCredit / creditLimit) * 100;
  }

  // Adresse complète
  String get fullAddress {
    final parts = <String>[];
    if ((address ?? '').isNotEmpty) parts.add(address!);
    if ((city ?? '').isNotEmpty) parts.add(city!);
    return parts.join(', ');
  }

  // Vérifier si le client a atteint sa limite de crédit
  bool get isAtCreditLimit {
    return currentCredit >= creditLimit;
  }

  // Vérifier si le client peut acheter pour un montant donné
  bool canPurchase(double amount) {
    return (currentCredit + amount) <= creditLimit;
  }

  // Statut du crédit
  CreditStatus get creditStatus {
    final percentage = creditUsagePercentage;
    if (percentage >= 100) return CreditStatus.exceeded;
    if (percentage >= 80) return CreditStatus.warning;
    if (percentage >= 50) return CreditStatus.moderate;
    return CreditStatus.good;
  }

  @override
  String toString() {
    return 'ClientModel(id: $id, name: $name, currentCredit: $currentCredit, creditLimit: $creditLimit)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClientModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Énumération pour le statut du crédit
enum CreditStatus {
  good, // 0-49%
  moderate, // 50-79%
  warning, // 80-99%
  exceeded, // 100%+
}

extension CreditStatusExtension on CreditStatus {
  String get label {
    switch (this) {
      case CreditStatus.good:
        return 'Bon';
      case CreditStatus.moderate:
        return 'Modéré';
      case CreditStatus.warning:
        return 'Attention';
      case CreditStatus.exceeded:
        return 'Dépassé';
    }
  }

  String get description {
    switch (this) {
      case CreditStatus.good:
        return 'Crédit disponible';
      case CreditStatus.moderate:
        return 'Crédit à surveiller';
      case CreditStatus.warning:
        return 'Limite proche';
      case CreditStatus.exceeded:
        return 'Limite dépassée';
    }
  }
}

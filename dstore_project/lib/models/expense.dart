class Expense {
  final String? id;
  final String userId;
  final String type;
  final double amount;
  final String description;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Expense({
    this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.description,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      description: json['description']?.toString() ?? '',
      date: DateTime.parse(json['date']?.toString() ?? DateTime.now().toIso8601String()),
      createdAt: DateTime.parse(json['created_at']?.toString() ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at']?.toString() ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'type': type,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Expense copyWith({
    String? id,
    String? userId,
    String? type,
    double? amount,
    String? description,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Expense(id: $id, userId: $userId, type: $type, amount: $amount, description: $description, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Expense &&
        other.id == id &&
        other.userId == userId &&
        other.type == type &&
        other.amount == amount &&
        other.description == description &&
        other.date == date;
  }

  @override
  int get hashCode {
    return Object.hash(id, userId, type, amount, description, date);
  }
}

// Types de dépenses prédéfinis
class ExpenseType {
  static const String rent = 'rent';
  static const String electricity = 'electricity';
  static const String wifi = 'wifi';
  static const String other = 'other';

  static const List<String> all = [rent, electricity, wifi, other];

  static String getDisplayName(String type, String languageCode) {
    switch (type) {
      case rent:
        switch (languageCode) {
          case 'fr': return 'Loyer';
          case 'en': return 'Rent';
          case 'ar': return 'الإيجار';
          default: return 'Loyer';
        }
      case electricity:
        switch (languageCode) {
          case 'fr': return 'Électricité';
          case 'en': return 'Electricity';
          case 'ar': return 'الكهرباء';
          default: return 'Électricité';
        }
      case wifi:
        switch (languageCode) {
          case 'fr': return 'Internet/WiFi';
          case 'en': return 'Internet/WiFi';
          case 'ar': return 'الإنترنت/واي فاي';
          default: return 'Internet/WiFi';
        }
      case other:
        switch (languageCode) {
          case 'fr': return 'Autre';
          case 'en': return 'Other';
          case 'ar': return 'أخرى';
          default: return 'Autre';
        }
      default:
        return type;
    }
  }
}

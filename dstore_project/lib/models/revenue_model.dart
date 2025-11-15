enum RevenueType {
  invoice('invoice', 'Facture'),
  creditPayment('credit_payment', 'Paiement de crédit'),
  adjustment('adjustment', 'Ajustement');

  const RevenueType(this.value, this.label);
  final String value;
  final String label;

  static RevenueType fromString(String value) {
    switch (value) {
      case 'invoice':
        return RevenueType.invoice;
      case 'credit_payment':
        return RevenueType.creditPayment;
      case 'adjustment':
        return RevenueType.adjustment;
      default:
        return RevenueType.invoice;
    }
  }
}

class RevenueModel {
  final String id;
  final double amount;
  final RevenueType type;
  final String sourceId; // ID de la facture ou du crédit
  final String? clientId;
  final String? description;
  final DateTime date;
  final DateTime createdAt;

  RevenueModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.sourceId,
    this.clientId,
    this.description,
    required this.date,
    required this.createdAt,
  });

  factory RevenueModel.fromJson(Map<String, dynamic> json) {
    return RevenueModel(
      id: json['id']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      type: RevenueType.fromString(json['type']?.toString() ?? 'invoice'),
      sourceId: json['source_id']?.toString() ?? '',
      clientId: json['client_id']?.toString(),
      description: json['description']?.toString(),
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'type': type.value,
      'source_id': sourceId,
      'client_id': clientId,
      'description': description,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  RevenueModel copyWith({
    String? id,
    double? amount,
    RevenueType? type,
    String? sourceId,
    String? clientId,
    String? description,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return RevenueModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      sourceId: sourceId ?? this.sourceId,
      clientId: clientId ?? this.clientId,
      description: description ?? this.description,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'RevenueModel(id: $id, amount: $amount, type: ${type.label}, sourceId: $sourceId, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RevenueModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

import 'client_model.dart';
import 'invoice_model.dart';

enum CreditPaymentStatus {
  pending('pending', 'En attente'),
  partiallyPaid('partially_paid', 'Partiellement payé'),
  paid('paid', 'Payé'),
  overdue('overdue', 'En retard');

  const CreditPaymentStatus(this.value, this.label);
  final String value;
  final String label;

  static CreditPaymentStatus fromString(String value) {
    return CreditPaymentStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => CreditPaymentStatus.pending,
    );
  }
}

class CreditModel {
  final String id;
  final String userId;
  final String clientId;
  final String invoiceId;
  final double totalAmount;
  final double paidAmount;
  final double remainingAmount;
  final DateTime dueDate;
  final CreditPaymentStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relations
  final ClientModel? client;
  final InvoiceModel? invoice;

  CreditModel({
    required this.id,
    required this.userId,
    required this.clientId,
    required this.invoiceId,
    required this.totalAmount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.dueDate,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.client,
    this.invoice,
  });

  factory CreditModel.fromJson(Map<String, dynamic> json) {
    return CreditModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      clientId: json['client_id']?.toString() ?? '',
      invoiceId: json['invoice_id']?.toString() ?? '',
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0.0,
      remainingAmount: (json['remaining_amount'] as num?)?.toDouble() ?? 0.0,
      dueDate:
          DateTime.parse(json['due_date'] ?? DateTime.now().toIso8601String()),
      status: CreditPaymentStatus.fromString(
          json['status']?.toString() ?? 'pending'),
      notes: json['notes']?.toString(),
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
      client:
          json['client'] != null ? ClientModel.fromJson(json['client']) : null,
      invoice: json['invoice'] != null
          ? InvoiceModel.fromJson(json['invoice'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'client_id': clientId,
      'invoice_id': invoiceId,
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'remaining_amount': remainingAmount,
      'due_date': dueDate.toIso8601String(),
      'status': status.value,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  CreditModel copyWith({
    String? id,
    String? userId,
    String? clientId,
    String? invoiceId,
    double? totalAmount,
    double? paidAmount,
    double? remainingAmount,
    DateTime? dueDate,
    CreditPaymentStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    ClientModel? client,
    InvoiceModel? invoice,
  }) {
    return CreditModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      clientId: clientId ?? this.clientId,
      invoiceId: invoiceId ?? this.invoiceId,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      client: client ?? this.client,
      invoice: invoice ?? this.invoice,
    );
  }

  @override
  String toString() {
    return 'CreditModel(id: $id, clientId: $clientId, totalAmount: $totalAmount, remainingAmount: $remainingAmount, status: ${status.label})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CreditModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Modèle pour l'historique des paiements de crédit
class CreditPaymentModel {
  final String id;
  final String creditId;
  final double amount;
  final DateTime paymentDate;
  final String? paymentMethod;
  final String? notes;
  final DateTime createdAt;

  CreditPaymentModel({
    required this.id,
    required this.creditId,
    required this.amount,
    required this.paymentDate,
    this.paymentMethod,
    this.notes,
    required this.createdAt,
  });

  factory CreditPaymentModel.fromJson(Map<String, dynamic> json) {
    return CreditPaymentModel(
      id: json['id']?.toString() ?? '',
      creditId: json['credit_id']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      paymentDate: DateTime.parse(
          json['payment_date'] ?? DateTime.now().toIso8601String()),
      paymentMethod: json['payment_method']?.toString(),
      notes: json['notes']?.toString(),
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'credit_id': creditId,
      'amount': amount,
      'payment_date': paymentDate.toIso8601String(),
      'payment_method': paymentMethod,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'CreditPaymentModel(id: $id, creditId: $creditId, amount: $amount, paymentDate: $paymentDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CreditPaymentModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

import 'client_model.dart';
import 'product_model.dart';
import 'supplier_model.dart';

// Énumération pour le type de facture
enum InvoiceType {
  sale('sale', 'Vente'),
  purchase('purchase', 'Achat');

  const InvoiceType(this.value, this.label);
  final String value;
  final String label;

  static InvoiceType fromString(String value) {
    return InvoiceType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => InvoiceType.sale,
    );
  }
}

class InvoiceModel {
  final String id;
  final String userId;
  final String? clientId;
  final String? supplierId;
  final String invoiceNumber;
  final InvoiceType type;
  final DateTime invoiceDate;
  final DateTime? dueDate;
  final double subtotal;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final double paidAmount;
  final InvoiceStatus status;
  final String? notes;
  final String? imagePath; // Chemin vers l'image de la facture
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relations
  final ClientModel? client;
  final SupplierModel? supplier;
  final List<InvoiceItemModel>? items;

  InvoiceModel({
    required this.id,
    required this.userId,
    this.clientId,
    this.supplierId,
    required this.invoiceNumber,
    required this.type,
    required this.invoiceDate,
    this.dueDate,
    required this.subtotal,
    required this.taxAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.paidAmount,
    required this.status,
    this.notes,
    this.imagePath,
    required this.createdAt,
    required this.updatedAt,
    this.client,
    this.supplier,
    this.items,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      clientId: json['client_id'] != null ? json['client_id'].toString() : null,
      supplierId:
          json['supplier_id'] != null ? json['supplier_id'].toString() : null,
      invoiceNumber: json['invoice_number']?.toString() ?? '',
      type: InvoiceType.fromString(json['type']?.toString() ??
          json['invoice_type']?.toString() ??
          'sale'),
      invoiceDate: json['invoice_date'] != null
          ? DateTime.parse(json['invoice_date'].toString())
          : DateTime.now(),
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'].toString())
          : null,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['tax_amount'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0.0,
      status: InvoiceStatus.fromString(json['status']?.toString() ?? 'draft'),
      notes: json['notes']?.toString(),
      imagePath: json['image_path']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
      client: json['clients'] != null && json['clients'] is Map
          ? ClientModel.fromJson(json['clients'] as Map<String, dynamic>)
          : null,
      supplier: json['suppliers'] != null && json['suppliers'] is Map
          ? SupplierModel.fromJson(json['suppliers'] as Map<String, dynamic>)
          : null,
      items: json['invoice_items'] != null && json['invoice_items'] is List
          ? (json['invoice_items'] as List)
              .map((item) => item is Map<String, dynamic>
                  ? InvoiceItemModel.fromJson(item)
                  : null)
              .where((item) => item != null)
              .cast<InvoiceItemModel>()
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'client_id': clientId,
      'supplier_id': supplierId,
      'invoice_number': invoiceNumber,
      'invoice_type': type.value,
      'invoice_date': invoiceDate.toIso8601String().split('T')[0],
      'due_date': dueDate?.toIso8601String().split('T')[0],
      'subtotal': subtotal,
      'tax_amount': taxAmount,
      'discount_amount': discountAmount,
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'status': status.value,
      'notes': notes,
      'image_path': imagePath,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'invoice_items': items?.map((item) => item.toJson()).toList(),
      'clients': client?.toJson(),
      'suppliers': supplier?.toJson(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'client_id': clientId,
      'supplier_id': supplierId,
      'invoice_number': invoiceNumber,
      'invoice_type': type.value,
      'invoice_date': invoiceDate.toIso8601String().split('T')[0],
      'due_date': dueDate?.toIso8601String().split('T')[0],
      'subtotal': subtotal,
      'tax_amount': taxAmount,
      'discount_amount': discountAmount,
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'status': status.value,
      'notes': notes,
      'image_path': imagePath,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'client_id': clientId,
      'invoice_date': invoiceDate.toIso8601String().split('T')[0],
      'due_date': dueDate?.toIso8601String().split('T')[0],
      'subtotal': subtotal,
      'tax_amount': taxAmount,
      'discount_amount': discountAmount,
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'status': status.value,
      'notes': notes,
      'image_path': imagePath,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  InvoiceModel copyWith({
    String? id,
    String? userId,
    String? clientId,
    String? supplierId,
    String? invoiceNumber,
    InvoiceType? type,
    DateTime? invoiceDate,
    DateTime? dueDate,
    double? subtotal,
    double? taxAmount,
    double? discountAmount,
    double? totalAmount,
    double? paidAmount,
    InvoiceStatus? status,
    String? notes,
    String? imagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
    ClientModel? client,
    SupplierModel? supplier,
    List<InvoiceItemModel>? items,
  }) {
    return InvoiceModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      clientId: clientId ?? this.clientId,
      supplierId: supplierId ?? this.supplierId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      type: type ?? this.type,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      dueDate: dueDate ?? this.dueDate,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      client: client ?? this.client,
      supplier: supplier ?? this.supplier,
      items: items ?? this.items,
    );
  }

  // Getters pour compatibilité
  String? get clientName => client?.name;
  String? get supplierName => supplier?.name;
  String get statusDisplayName => status.label;

  // Calculer le montant restant à payer
  double get remainingAmount {
    return totalAmount - paidAmount;
  }

  // Vérifier si la facture est entièrement payée
  bool get isFullyPaid {
    return paidAmount >= totalAmount;
  }

  // Vérifier si la facture est en retard
  bool get isOverdue {
    if (dueDate == null || isFullyPaid) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  @override
  String toString() {
    return 'InvoiceModel(id: $id, invoiceNumber: $invoiceNumber, totalAmount: $totalAmount, status: ${status.value})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InvoiceModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class InvoiceItemModel {
  final String id;
  final String invoiceId;
  final String productId;
  final double quantity;
  final double unitPrice;
  final double totalPrice;
  final DateTime createdAt;

  // Relations
  final ProductModel? product;

  InvoiceItemModel({
    required this.id,
    required this.invoiceId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.createdAt,
    this.product,
  });

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return InvoiceItemModel(
      id: json['id']?.toString() ?? '',
      invoiceId: json['invoice_id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      product: json['products'] != null && json['products'] is Map
          ? ProductModel.fromJson(json['products'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_id': invoiceId,
      'product_id': productId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'invoice_id': invoiceId,
      'product_id': productId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
    };
  }

  InvoiceItemModel copyWith({
    String? id,
    String? invoiceId,
    String? productId,
    double? quantity,
    double? unitPrice,
    double? totalPrice,
    DateTime? createdAt,
    ProductModel? product,
  }) {
    return InvoiceItemModel(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      createdAt: createdAt ?? this.createdAt,
      product: product ?? this.product,
    );
  }

  @override
  String toString() {
    return 'InvoiceItemModel(id: $id, productId: $productId, quantity: $quantity, totalPrice: $totalPrice)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InvoiceItemModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Énumération pour le statut des factures
enum InvoiceStatus {
  draft('draft'),
  validated('validated'),
  paid('paid'),
  cancelled('cancelled');

  const InvoiceStatus(this.value);
  final String value;

  static InvoiceStatus fromString(String value) {
    return InvoiceStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => InvoiceStatus.draft,
    );
  }

  String get label {
    switch (this) {
      case InvoiceStatus.draft:
        return 'Brouillon';
      case InvoiceStatus.validated:
        return 'Validée';
      case InvoiceStatus.paid:
        return 'Payée';
      case InvoiceStatus.cancelled:
        return 'Annulée';
    }
  }
}

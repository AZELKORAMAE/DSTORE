import 'client_model.dart';

class DailySales {
  final DateTime date;
  final double amount;
  final int count;

  DailySales({
    required this.date,
    required this.amount,
    required this.count,
  });

  factory DailySales.fromJson(Map<String, dynamic> json) {
    return DailySales(
      date: DateTime.parse(json['date']),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      count: json['count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'amount': amount,
      'count': count,
    };
  }
}

class CategorySales {
  final String categoryId;
  final String categoryName;
  final double totalSales;
  final int productCount;

  CategorySales({
    required this.categoryId,
    required this.categoryName,
    required this.totalSales,
    required this.productCount,
  });

  factory CategorySales.fromJson(Map<String, dynamic> json) {
    return CategorySales(
      categoryId: json['category_id'] as String? ?? '',
      categoryName: json['category_name'] as String? ?? '',
      totalSales: (json['total_sales'] as num?)?.toDouble() ?? 0.0,
      productCount: json['product_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'category_name': categoryName,
      'total_sales': totalSales,
      'product_count': productCount,
    };
  }
}

class TopProduct {
  final String productId;
  final String productName;
  final double totalSales;
  final int quantitySold;

  TopProduct({
    required this.productId,
    required this.productName,
    required this.totalSales,
    required this.quantitySold,
  });

  factory TopProduct.fromJson(Map<String, dynamic> json) {
    return TopProduct(
      productId: json['product_id'] as String? ?? '',
      productName: json['product_name'] as String? ?? '',
      totalSales: (json['total_sales'] as num?)?.toDouble() ?? 0.0,
      quantitySold: json['quantity_sold'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'total_sales': totalSales,
      'quantity_sold': quantitySold,
    };
  }
}

class DailyRevenue {
  final DateTime date;
  final double totalSales;
  final double totalPaid;
  final double totalPending;
  final int salesCount;
  final double totalPurchases;
  final int purchasesCount;
  final double netRevenue;

  DailyRevenue({
    required this.date,
    required this.totalSales,
    required this.totalPaid,
    required this.totalPending,
    required this.salesCount,
    required this.totalPurchases,
    required this.purchasesCount,
    required this.netRevenue,
  });

  factory DailyRevenue.fromJson(Map<String, dynamic> json) {
    return DailyRevenue(
      date: DateTime.parse(json['date']),
      totalSales: (json['total_sales'] as num?)?.toDouble() ?? 0.0,
      totalPaid: (json['total_paid'] as num?)?.toDouble() ?? 0.0,
      totalPending: (json['total_pending'] as num?)?.toDouble() ?? 0.0,
      salesCount: json['sales_count'] as int? ?? 0,
      totalPurchases: (json['total_purchases'] as num?)?.toDouble() ?? 0.0,
      purchasesCount: json['purchases_count'] as int? ?? 0,
      netRevenue: (json['net_revenue'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'total_sales': totalSales,
      'total_paid': totalPaid,
      'total_pending': totalPending,
      'sales_count': salesCount,
      'total_purchases': totalPurchases,
      'purchases_count': purchasesCount,
      'net_revenue': netRevenue,
    };
  }
}

class ClientSummary {
  final ClientModel client;
  final double totalSpent;
  final int invoiceCount;
  final DateTime? lastPurchaseDate;

  ClientSummary({
    required this.client,
    required this.totalSpent,
    required this.invoiceCount,
    this.lastPurchaseDate,
  });

  factory ClientSummary.fromJson(Map<String, dynamic> json) {
    return ClientSummary(
      client: ClientModel.fromJson(json['client']),
      totalSpent: (json['total_spent'] as num?)?.toDouble() ?? 0.0,
      invoiceCount: json['invoice_count'] as int? ?? 0,
      lastPurchaseDate: json['last_purchase_date'] != null
          ? DateTime.parse(json['last_purchase_date'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'client': client.toJson(),
      'total_spent': totalSpent,
      'invoice_count': invoiceCount,
      'last_purchase_date': lastPurchaseDate?.toIso8601String(),
    };
  }
}

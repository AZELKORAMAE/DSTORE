import '../models/invoice_model.dart';
import '../services/invoice_service.dart';

/// A service that aggregates sold and purchased products over a date range.
///
/// This service reads invoices from the local storage via [InvoiceService],
/// filters them by date and type (sale or purchase) and aggregates the
/// quantities of each product. It can also filter by category and minimum
/// quantity. The result can then be exported to Excel via the report screen.
class TransactionReportService {
  final InvoiceService _invoiceService;

  TransactionReportService({InvoiceService? invoiceService})
      : _invoiceService = invoiceService ?? InvoiceService();

  /// Fetches and aggregates all sold and purchased products between [start] and [end].
  ///
  /// If [categoryId] is provided, only products whose category matches will be included.
  /// If [minQuantity] is provided, only items with quantity >= [minQuantity] are returned.
  Future<List<ReportItem>> getTransactions({
    required DateTime start,
    required DateTime end,
    String? categoryId,
    double? minQuantity,
    List<String>? productIds,
  }) async {
    final invoices = await _invoiceService.getAllInvoices();
    // Utiliser une structure pour agréger les transactions par produit, type, date et prix unitaire
    final Map<String, ReportItem> aggregated = {};

    for (final invoice in invoices) {
      // Filter invoices by date range using invoiceDate instead of createdAt.
      final invoiceDate = invoice.invoiceDate;
      final invoiceDateOnly = DateTime(invoiceDate.year, invoiceDate.month, invoiceDate.day);
      final startDateOnly = DateTime(start.year, start.month, start.day);
      final endDateOnly = DateTime(end.year, end.month, end.day);
      if (invoiceDateOnly.isBefore(startDateOnly) || invoiceDateOnly.isAfter(endDateOnly)) {
        continue;
      }
      // We only care about sale or purchase invoices
      if (invoice.type != InvoiceType.sale && invoice.type != InvoiceType.purchase) {
        continue;
      }
      if (invoice.items == null) continue;

      for (final item in invoice.items!) {
        final product = item.product;
        if (product == null) continue;
        // Filter by category if provided
        if (categoryId != null && product.categoryId != categoryId) {
          continue;
        }
        // Filter by minimum quantity
        if (minQuantity != null && item.quantity < minQuantity) {
          continue;
        }
        // Filtrer par identifiants de produits si une liste est fournie
        if (productIds != null && productIds.isNotEmpty && !productIds.contains(product.id)) {
          continue;
        }

        // Use a unique key per product, invoice type, date and unit price to merge duplicates
        final price = item.unitPrice;
        final key = '${product.id}_${invoice.type}_${invoiceDateOnly.toIso8601String()}_${price.toString()}';
        final existing = aggregated[key];
        if (existing != null) {
          // Update quantity, keep existing price and stock quantity
          aggregated[key] = ReportItem(
            productId: existing.productId,
            productName: existing.productName,
            categoryName: existing.categoryName,
            quantity: existing.quantity + item.quantity,
            type: existing.type,
            date: existing.date,
            unitPrice: existing.unitPrice,
            stockQuantity: existing.stockQuantity,
          );
        } else {
          aggregated[key] = ReportItem(
            productId: product.id,
            productName: product.name,
            categoryName: product.category?.name ?? '',
            quantity: item.quantity,
            type: invoice.type,
            date: invoiceDate,
            unitPrice: price,
            stockQuantity: product.stockQuantity,
          );
        }
      }
    }

    return aggregated.values.toList();
  }
}

/// Represents a single aggregated product transaction.
class ReportItem {
  final String productId;
  final String productName;
  final String categoryName;
  final double quantity;
  final InvoiceType type;
  final DateTime date;
  /// Prix unitaire de l'article à la date de la transaction.
  final double unitPrice;
  /// Quantité de stock du produit au moment du rapport.
  final double stockQuantity;

  const ReportItem({
    required this.productId,
    required this.productName,
    required this.categoryName,
    required this.quantity,
    required this.type,
    required this.date,
    required this.unitPrice,
    required this.stockQuantity,
  });
}
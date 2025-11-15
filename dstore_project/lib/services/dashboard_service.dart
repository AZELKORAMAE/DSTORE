import '../models/client_model.dart';
import '../models/product_model.dart';
import '../models/invoice_model.dart';
import 'local_storage_service.dart';
import 'product_service.dart';
import 'client_service.dart';
import 'supplier_service.dart';
import 'invoice_service.dart';
import 'revenue_service.dart';
import 'credit_service.dart';

class DashboardService {
  final LocalStorageService _localStorage = LocalStorageService.instance;
  final ProductService _productService = ProductService();
  final ClientService _clientService = ClientService();
  final SupplierService _supplierService = SupplierService();
  final InvoiceService _invoiceService = InvoiceService();
  final RevenueService _revenueService = RevenueService();
  final CreditService _creditService = CreditService();

  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      // Récupérer toutes les statistiques en parallèle
      final results = await Future.wait([
        _getTotalProducts(),
        _getTotalClients(),
        _getTotalSuppliers(),
        _getTotalInvoices(),
        _getTodayRevenue(),
        _getWeekRevenue(),
        _getMonthRevenue(),
        _getTotalRevenue(),
        _getPendingAmount(),
        _getLowStockProducts(),
        _getOutOfStockProducts(),
        _getTotalStockValue(),
      ]);

      return {
        'totalProducts': results[0],
        'totalClients': results[1],
        'totalSuppliers': results[2],
        'totalInvoices': results[3],
        'todayRevenue': results[4],
        'weekRevenue': results[5],
        'monthRevenue': results[6],
        'totalRevenue': results[7],
        'pendingAmount': results[8],
        'lowStockProducts': results[9],
        'outOfStockProducts': results[10],
        'totalStockValue': results[11],
      };
    } catch (e) {
      print('❌ Erreur getDashboardData: $e');
      return {
        'totalProducts': 0,
        'totalClients': 0,
        'totalSuppliers': 0,
        'totalInvoices': 0,
        'todayRevenue': 0.0,
        'weekRevenue': 0.0,
        'monthRevenue': 0.0,
        'totalRevenue': 0.0,
        'pendingAmount': 0.0,
        'lowStockProducts': 0,
        'outOfStockProducts': 0,
        'totalStockValue': 0.0,
      };
    }
  }

  Future<int> _getTotalProducts() async {
    try {
      final products = await _productService.getAllProducts();
      final activeProducts = products.where((p) => p.isActive ?? true).length;
      print('📦 Produits trouvés: $activeProducts');
      return activeProducts;
    } catch (e) {
      print('❌ Erreur getTotalProducts: $e');
      return 0;
    }
  }

  Future<int> _getTotalClients() async {
    try {
      final clients = await _clientService.getAllClients();
      return clients.where((c) => c.isActive ?? true).length;
    } catch (e) {
      print('❌ Erreur getTotalClients: $e');
      return 0;
    }
  }

  Future<int> _getTotalSuppliers() async {
    try {
      final suppliers = await _supplierService.getAllSuppliers();
      return suppliers.where((s) => s.isActive ?? true).length;
    } catch (e) {
      print('❌ Erreur getTotalSuppliers: $e');
      return 0;
    }
  }

  Future<int> _getTotalInvoices() async {
    try {
      final invoices = await _invoiceService.getAllInvoices();
      return invoices.length;
    } catch (e) {
      print('❌ Erreur getTotalInvoices: $e');
      return 0;
    }
  }

  Future<double> _getTodayRevenue() async {
    try {
      // Utiliser le nouveau service de revenus qui inclut les paiements de crédits
      final todayRevenue = await _revenueService.getTodayRevenue();
      print('💰 Total revenus du jour (incluant paiements de crédits): $todayRevenue DH');
      return todayRevenue;
    } catch (e) {
      print('❌ Erreur getTodayRevenue: $e');
      return 0.0;
    }
  }

  Future<double> _getWeekRevenue() async {
    try {
      // Utiliser le nouveau service de revenus qui inclut les paiements de crédits
      final weekRevenue = await _revenueService.getWeekRevenue();
      return weekRevenue;
    } catch (e) {
      print('❌ Erreur getWeekRevenue: $e');
      return 0.0;
    }
  }

  Future<double> _getMonthRevenue() async {
    try {
      // Utiliser le nouveau service de revenus qui inclut les paiements de crédits
      final monthRevenue = await _revenueService.getMonthRevenue();
      return monthRevenue;
    } catch (e) {
      print('❌ Erreur getMonthRevenue: $e');
      return 0.0;
    }
  }

  /// Calculer le bénéfice net d'un mois spécifique
  /// Bénéfice net = Revenus encaissés - Coût des marchandises vendues - Achats du mois
  Future<double> getMonthNetProfit(DateTime month) async {
    try {
      print('💰 Calcul du bénéfice net pour ${month.month}/${month.year}...');

      // 1. Calculer les revenus encaissés du mois (factures payées + paiements de crédits)
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

      double totalPaid = 0.0;
      double totalCostOfGoodsSold = 0.0;
      double totalPurchases = 0.0;

      // Charger toutes les factures du mois
      final allInvoices = await _invoiceService.getAllInvoices();
      final monthInvoices = allInvoices.where((invoice) {
        final invoiceDate = invoice.createdAt;
        return invoiceDate.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
               invoiceDate.isBefore(endOfMonth.add(const Duration(days: 1)));
      }).toList();

      print('📊 Factures du mois ${month.month}/${month.year}: ${monthInvoices.length}');

      for (final invoice in monthInvoices) {
        if (invoice.type == InvoiceType.sale) {
          // Factures de vente
          totalPaid += invoice.paidAmount;

          // Calculer le coût des marchandises vendues pour cette facture
          if (invoice.items != null) {
            for (final item in invoice.items!) {
              try {
                ProductModel? product = item.product;
                if (product == null) {
                  product = await _productService.getProductById(item.productId);
                }

                if (product != null) {
                  final purchasePrice = product.purchasePrice;
                  final quantity = item.quantity;
                  final itemCost = purchasePrice * quantity;
                  totalCostOfGoodsSold += itemCost;
                }
              } catch (e) {
                print('❌ Erreur chargement produit ${item.productId}: $e');
              }
            }
          }
        } else if (invoice.type == InvoiceType.purchase) {
          // Factures d'achat
          totalPurchases += invoice.paidAmount;
        }
      }

      // Ajouter les paiements de crédits du mois
      final creditPayments = await _getCreditPaymentsForPeriod(startOfMonth, endOfMonth);
      totalPaid += creditPayments;

      // Calculer le bénéfice net
      final netProfit = totalPaid - totalCostOfGoodsSold - totalPurchases;

      print('💰 Bénéfice net ${month.month}/${month.year}:');
      print('   Revenus encaissés: $totalPaid DH');
      print('   Coût marchandises vendues: $totalCostOfGoodsSold DH');
      print('   Achats du mois: $totalPurchases DH');
      print('   Bénéfice net: $netProfit DH');

      return netProfit;
    } catch (e) {
      print('❌ Erreur calcul bénéfice net mensuel: $e');
      return 0.0;
    }
  }

  Future<double> _getTotalRevenue() async {
    try {
      // Utiliser le nouveau service de revenus qui inclut les paiements de crédits
      final totalRevenue = await _revenueService.getTotalRevenue();
      return totalRevenue;
    } catch (e) {
      print('❌ Erreur getTotalRevenue: $e');
      return 0.0;
    }
  }

  Future<double> _getPendingAmount() async {
    try {
      final invoices = await _invoiceService.getAllInvoices();
      final pendingInvoices = invoices.where((invoice) {
        return invoice.status != InvoiceStatus.paid;
      }).toList();

      double total = 0.0;
      for (final invoice in pendingInvoices) {
        final totalAmount = invoice.totalAmount ?? 0.0;
        final paidAmount = invoice.paidAmount ?? 0.0;
        total += (totalAmount - paidAmount);
      }
      return total;
    } catch (e) {
      print('❌ Erreur getPendingAmount: $e');
      return 0.0;
    }
  }

  Future<int> _getLowStockProducts() async {
    try {
      final products = await _productService.getAllProducts();
      final activeProducts = products.where((p) => p.isActive ?? true).toList();

      int count = 0;
      for (final product in activeProducts) {
        final stock = product.stockQuantity ?? 0;
        final threshold = product.minStockThreshold ?? 10;
        if (stock <= threshold && stock > 0) {
          count++;
        }
      }
      return count;
    } catch (e) {
      print('❌ Erreur getLowStockProducts: $e');
      return 0;
    }
  }

  Future<int> _getOutOfStockProducts() async {
    try {
      final products = await _productService.getAllProducts();
      final outOfStockProducts = products.where((product) {
        return (product.stockQuantity ?? 0) == 0 && (product.isActive ?? true);
      }).toList();

      return outOfStockProducts.length;
    } catch (e) {
      print('❌ Erreur getOutOfStockProducts: $e');
      return 0;
    }
  }

  Future<double> _getTotalStockValue() async {
    try {
      final products = await _productService.getAllProducts();
      final activeProducts = products.where((p) => p.isActive ?? true).toList();

      double total = 0.0;
      for (final product in activeProducts) {
        final quantity = product.stockQuantity?.toDouble() ?? 0.0;
        final price = product.purchasePrice ?? 0.0;
        total += (quantity * price);
      }
      return total;
    } catch (e) {
      print('❌ Erreur getTotalStockValue: $e');
      return 0.0;
    }
  }

  // ==================== MÉTHODES POUR LES GRAPHIQUES ====================

  /// Données des revenus hebdomadaires (7 derniers jours)
  Future<List<double>> getWeeklyRevenueData() async {
    try {
      final now = DateTime.now();
      final weeklyData = <double>[];

      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final dayRevenue = await _getDayRevenue(date);
        weeklyData.add(dayRevenue);
      }

      return weeklyData;
    } catch (e) {
      print('❌ Erreur getWeeklyRevenueData: $e');
      return List.filled(7, 0.0);
    }
  }

  /// Revenus d'un jour spécifique (factures + paiements de crédits)
  Future<double> _getDayRevenue(DateTime date) async {
    try {
      double total = 0.0;

      // 1. Revenus des factures payées
      final invoices = await _invoiceService.getAllInvoices();
      final dayInvoices = invoices.where((invoice) {
        return invoice.invoiceDate != null &&
            invoice.invoiceDate!.year == date.year &&
            invoice.invoiceDate!.month == date.month &&
            invoice.invoiceDate!.day == date.day &&
            invoice.status == InvoiceStatus.paid &&
            invoice.type == InvoiceType.sale;
      }).toList();

      for (final invoice in dayInvoices) {
        total += invoice.paidAmount;
      }

      // 2. Revenus des paiements de crédits du jour
      final creditPayments = await _getCreditPaymentsForDay(date);
      total += creditPayments;

      print('💰 Revenus du ${date.day}/${date.month}: Factures=${total - creditPayments} DH + Crédits=$creditPayments DH = Total=$total DH');

      return total;
    } catch (e) {
      print('❌ Erreur _getDayRevenue: $e');
      return 0.0;
    }
  }

  /// Obtenir les paiements de crédits pour un jour spécifique
  Future<double> _getCreditPaymentsForDay(DateTime date) async {
    try {
      final creditService = CreditService();
      final allCredits = await creditService.getAllCredits();
      double totalPayments = 0.0;

      for (final credit in allCredits) {
        final payments = await creditService.getCreditPayments(credit.id);
        for (final payment in payments) {
          if (payment.paymentDate.year == date.year &&
              payment.paymentDate.month == date.month &&
              payment.paymentDate.day == date.day) {
            totalPayments += payment.amount;
          }
        }
      }

      return totalPayments;
    } catch (e) {
      print('❌ Erreur _getCreditPaymentsForDay: $e');
      return 0.0;
    }
  }

  /// Obtenir les données détaillées des revenus du jour
  Future<Map<String, dynamic>> getDailyRevenueDetails([DateTime? date]) async {
    try {
      final targetDate = date ?? DateTime.now();

      // 1. Factures de vente du jour
      final invoices = await _invoiceService.getAllInvoices();
      final dayInvoices = invoices.where((invoice) {
        return invoice.invoiceDate != null &&
            invoice.invoiceDate!.year == targetDate.year &&
            invoice.invoiceDate!.month == targetDate.month &&
            invoice.invoiceDate!.day == targetDate.day &&
            invoice.type == InvoiceType.sale;
      }).toList();

      double totalSales = 0.0;
      double totalPaid = 0.0;
      double totalPending = 0.0;
      double totalCostOfGoodsSold = 0.0; // Coût des marchandises vendues
      int salesCount = 0;

      for (final invoice in dayInvoices) {
        totalSales += invoice.totalAmount;
        totalPaid += invoice.paidAmount;
        totalPending += (invoice.totalAmount - invoice.paidAmount);
        salesCount++;

        // Calculer le coût des marchandises vendues pour cette facture
        if (invoice.items != null) {
          for (final item in invoice.items!) {
            try {
              // Charger le produit manuellement si pas déjà chargé
              ProductModel? product = item.product;
              if (product == null) {
                product = await _productService.getProductById(item.productId);
              }

              if (product != null) {
                final purchasePrice = product.purchasePrice;
                final quantity = item.quantity;
                final itemCost = purchasePrice * quantity;
                totalCostOfGoodsSold += itemCost;

                print('📦 Article: ${product.name}');
                print('   Prix achat: $purchasePrice DH');
                print('   Quantité: $quantity');
                print('   Coût total: $itemCost DH');
              } else {
                print('⚠️ Produit non trouvé pour item ${item.productId}');
              }
            } catch (e) {
              print('❌ Erreur chargement produit ${item.productId}: $e');
            }
          }
        }
      }

      // 2. Paiements de crédits du jour
      final creditPayments = await _getCreditPaymentsForDay(targetDate);
      totalPaid += creditPayments; // Ajouter les paiements de crédits aux encaissements

      // 3. Achats du jour (dépenses opérationnelles)
      final purchaseInvoices = invoices.where((invoice) {
        return invoice.invoiceDate != null &&
            invoice.invoiceDate!.year == targetDate.year &&
            invoice.invoiceDate!.month == targetDate.month &&
            invoice.invoiceDate!.day == targetDate.day &&
            invoice.type == InvoiceType.purchase;
      }).toList();

      double totalPurchases = 0.0;
      int purchasesCount = 0;

      for (final invoice in purchaseInvoices) {
        totalPurchases += invoice.totalAmount;
        purchasesCount++;
      }

      // 4. Calcul du bénéfice net = Revenus encaissés - Coût des marchandises vendues - Achats du jour
      final netRevenue = totalPaid - totalCostOfGoodsSold - totalPurchases;

      print('💰 Calcul bénéfice net du ${targetDate.day}/${targetDate.month}:');
      print('   Revenus encaissés: $totalPaid DH');
      print('   Coût marchandises vendues: $totalCostOfGoodsSold DH');
      print('   Achats du jour: $totalPurchases DH');
      print('   Bénéfice net: $netRevenue DH');

      return {
        'totalSales': totalSales,
        'salesCount': salesCount,
        'totalPaid': totalPaid,
        'totalPending': totalPending,
        'totalPurchases': totalPurchases,
        'purchasesCount': purchasesCount,
        'netRevenue': netRevenue,
        'creditPayments': creditPayments,
        'costOfGoodsSold': totalCostOfGoodsSold,
      };
    } catch (e) {
      print('❌ Erreur getDailyRevenueDetails: $e');
      return {
        'totalSales': 0.0,
        'salesCount': 0,
        'totalPaid': 0.0,
        'totalPending': 0.0,
        'totalPurchases': 0.0,
        'purchasesCount': 0,
        'netRevenue': 0.0,
        'creditPayments': 0.0,
        'costOfGoodsSold': 0.0,
      };
    }
  }

  /// Ventes par produit
  Future<Map<String, double>> getSalesByProduct() async {
    try {
      final invoices = await _invoiceService.getAllInvoices();
      final products = await _productService.getAllProducts();
      final salesByProduct = <String, double>{};

      // Créer un map des produits par ID
      final productMap = {for (var p in products) p.id: p};

      for (final invoice in invoices) {
        if (invoice.status == InvoiceStatus.paid &&
            invoice.type == InvoiceType.sale &&
            invoice.items != null) {
          for (final item in invoice.items!) {
            final product = productMap[item.productId];
            if (product != null) {
              final productName = product.name;
              final itemTotal = (item.quantity ?? 0) * (item.unitPrice ?? 0);
              salesByProduct[productName] =
                  (salesByProduct[productName] ?? 0) + itemTotal;
            }
          }
        }
      }

      return salesByProduct;
    } catch (e) {
      print('❌ Erreur getSalesByProduct: $e');
      return {};
    }
  }

  /// Stock par catégorie
  Future<Map<String, double>> getStockByCategory() async {
    try {
      final products = await _productService.getAllProducts();
      final stockByCategory = <String, double>{};

      for (final product in products) {
        if (product.isActive ?? true) {
          final categoryName = product.category?.name ?? 'Sans catégorie';
          final double stock = product.stockQuantity;
          stockByCategory[categoryName] =
              (stockByCategory[categoryName] ?? 0) + stock;
        }
      }

      return stockByCategory;
    } catch (e) {
      print('❌ Erreur getStockByCategory: $e');
      return {};
    }
  }

  /// Obtenir les paiements de crédits pour une période donnée
  Future<double> _getCreditPaymentsForPeriod(DateTime startDate, DateTime endDate) async {
    try {
      final allCredits = await _creditService.getAllCredits();
      double totalPayments = 0.0;

      for (final credit in allCredits) {
        final payments = await _creditService.getCreditPayments(credit.id);
        for (final payment in payments) {
          if (payment.paymentDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
              payment.paymentDate.isBefore(endDate.add(const Duration(days: 1)))) {
            totalPayments += payment.amount;
          }
        }
      }

      return totalPayments;
    } catch (e) {
      print('❌ Erreur _getCreditPaymentsForPeriod: $e');
      return 0.0;
    }
  }
}

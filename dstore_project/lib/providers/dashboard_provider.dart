import 'package:flutter/material.dart';
import '../services/dashboard_service.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardService _dashboardService = DashboardService();

  bool _isLoading = false;
  String? _errorMessage;

  // Statistiques générales
  int _totalProducts = 0;
  int _totalClients = 0;
  int _totalSuppliers = 0;
  int _totalInvoices = 0;

  // Statistiques financières
  double _todayRevenue = 0.0;
  double _weekRevenue = 0.0;
  double _monthRevenue = 0.0;
  double _totalRevenue = 0.0;
  double _pendingAmount = 0.0;

  // Statistiques de stock
  int _lowStockProducts = 0;
  int _outOfStockProducts = 0;
  double _totalStockValue = 0.0;

  // Données pour les graphiques
  List<DailySales> _dailySales = [];
  List<CategorySales> _categorySales = [];
  List<TopProduct> _topProducts = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get totalProducts => _totalProducts;
  int get totalClients => _totalClients;
  int get totalSuppliers => _totalSuppliers;
  int get totalInvoices => _totalInvoices;

  double get todayRevenue => _todayRevenue;
  double get weekRevenue => _weekRevenue;
  double get monthRevenue => _monthRevenue;
  double get totalRevenue => _totalRevenue;
  double get pendingAmount => _pendingAmount;

  int get lowStockProducts => _lowStockProducts;
  int get outOfStockProducts => _outOfStockProducts;
  double get totalStockValue => _totalStockValue;

  // Données pour les graphiques
  List<double> _weeklyRevenueData = [];
  Map<String, double> _salesByProduct = {};
  Map<String, double> _stockByCategory = {};

  List<double> get weeklyRevenueData => _weeklyRevenueData;
  Map<String, double> get salesByProduct => _salesByProduct;
  Map<String, double> get stockByCategory => _stockByCategory;

  List<DailySales> get dailySales => _dailySales;
  List<CategorySales> get categorySales => _categorySales;
  List<TopProduct> get topProducts => _topProducts;

  DashboardProvider() {
    // Pas de chargement automatique pour éviter les boucles infinies
    // Le chargement sera déclenché manuellement par les écrans
  }

  Future<void> loadDashboardData() async {
    _setLoading(true);
    _clearError();

    try {
      print('🔄 Chargement des données du dashboard...');
      final data = await _dashboardService.getDashboardData();
      print('📊 Données reçues: $data');

      _totalProducts = data['totalProducts'] ?? 0;
      _totalClients = data['totalClients'] ?? 0;
      _totalSuppliers = data['totalSuppliers'] ?? 0;
      _totalInvoices = data['totalInvoices'] ?? 0;

      _todayRevenue = data['todayRevenue']?.toDouble() ?? 0.0;
      _weekRevenue = data['weekRevenue']?.toDouble() ?? 0.0;
      _monthRevenue = data['monthRevenue']?.toDouble() ?? 0.0;
      _totalRevenue = data['totalRevenue']?.toDouble() ?? 0.0;
      _pendingAmount = data['pendingAmount']?.toDouble() ?? 0.0;

      _lowStockProducts = data['lowStockProducts'] ?? 0;
      _outOfStockProducts = data['outOfStockProducts'] ?? 0;
      _totalStockValue = data['totalStockValue']?.toDouble() ?? 0.0;

      // Charger les données des graphiques
      await _loadChartData();

      print(
          '✅ Dashboard mis à jour: Produits=$_totalProducts, Clients=$_totalClients, Revenus=$_todayRevenue');
      _setLoading(false);
    } catch (e) {
      print('❌ Erreur dashboard: $e');
      _setError('Erreur lors du chargement des données: $e');
      _setLoading(false);
    }
  }

  Future<void> loadSalesData() async {
    try {
      // Méthode simplifiée - pas de données détaillées pour l'instant
      _dailySales = [];
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors du chargement des ventes: $e');
    }
  }

  /// Obtenir le bénéfice net d'un mois spécifique
  Future<double> getMonthNetProfit(DateTime month) async {
    try {
      return await _dashboardService.getMonthNetProfit(month);
    } catch (e) {
      print('❌ Erreur getMonthNetProfit: $e');
      return 0.0;
    }
  }

  Future<void> loadCategorySales() async {
    try {
      // Méthode simplifiée - pas de données détaillées pour l'instant
      _categorySales = [];
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors du chargement des ventes par catégorie: $e');
    }
  }

  Future<void> loadTopProducts() async {
    try {
      // Méthode simplifiée - pas de données détaillées pour l'instant
      _topProducts = [];
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors du chargement des produits populaires: $e');
    }
  }

  Future<void> refreshAll() async {
    await Future.wait([
      loadDashboardData(),
      loadSalesData(),
      loadCategorySales(),
      loadTopProducts(),
    ]);
  }

  // Calculer la croissance par rapport à la période précédente
  double getRevenueGrowth() {
    if (_weekRevenue == 0) return 0.0;
    // Simuler une croissance (dans une vraie app, comparer avec la semaine précédente)
    return 12.5; // +12.5%
  }

  double getClientGrowth() {
    if (_totalClients == 0) return 0.0;
    // Simuler une croissance
    return 8.3; // +8.3%
  }

  double getProductGrowth() {
    if (_totalProducts == 0) return 0.0;
    // Simuler une croissance
    return 5.7; // +5.7%
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _loadChartData() async {
    try {
      // Charger les données des graphiques en parallèle
      final results = await Future.wait([
        _dashboardService.getWeeklyRevenueData(),
        _dashboardService.getSalesByProduct(),
        _dashboardService.getStockByCategory(),
      ]);

      _weeklyRevenueData = results[0] as List<double>;
      _salesByProduct = results[1] as Map<String, double>;
      _stockByCategory = results[2] as Map<String, double>;

      print(
          '📊 Données graphiques chargées: Revenus hebdo=${_weeklyRevenueData.length}, Ventes=${_salesByProduct.length}, Stock=${_stockByCategory.length}');
    } catch (e) {
      print('❌ Erreur chargement graphiques: $e');
      // En cas d'erreur, utiliser des données vides
      _weeklyRevenueData = List.filled(7, 0.0);
      _salesByProduct = {};
      _stockByCategory = {};
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}

// Classes pour les données du dashboard
class DailySales {
  final DateTime date;
  final double amount;
  final int invoiceCount;

  DailySales({
    required this.date,
    required this.amount,
    required this.invoiceCount,
  });

  factory DailySales.fromJson(Map<String, dynamic> json) {
    return DailySales(
      date: DateTime.parse(json['date']),
      amount: (json['amount'] as num).toDouble(),
      invoiceCount: json['invoice_count'] as int,
    );
  }
}

class CategorySales {
  final String categoryName;
  final double amount;
  final int productCount;
  final String color;

  CategorySales({
    required this.categoryName,
    required this.amount,
    required this.productCount,
    required this.color,
  });

  factory CategorySales.fromJson(Map<String, dynamic> json) {
    return CategorySales(
      categoryName: json['category_name'],
      amount: (json['amount'] as num).toDouble(),
      productCount: json['product_count'] as int,
      color: json['color'] ?? '#2196F3',
    );
  }
}

class TopProduct {
  final String productId;
  final String productName;
  final int quantitySold;
  final double revenue;
  final String? imageUrl;

  TopProduct({
    required this.productId,
    required this.productName,
    required this.quantitySold,
    required this.revenue,
    this.imageUrl,
  });

  factory TopProduct.fromJson(Map<String, dynamic> json) {
    return TopProduct(
      productId: json['product_id'],
      productName: json['product_name'],
      quantitySold: json['quantity_sold'] as int,
      revenue: (json['revenue'] as num).toDouble(),
      imageUrl: json['image_url'],
    );
  }
}

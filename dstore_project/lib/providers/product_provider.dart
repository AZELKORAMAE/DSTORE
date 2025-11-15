import 'dart:io';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import 'auth_provider.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();

  List<ProductModel> _products = [];
  List<ProductModel> _filteredProducts = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String? _selectedCategoryId;

  // Getters
  List<ProductModel> get products => _filteredProducts;
  List<ProductModel> get allProducts => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String? get selectedCategoryId => _selectedCategoryId;

  // Produits avec stock faible
  List<ProductModel> get lowStockProducts => _products
      .where((product) => product.isLowStock && product.isActive)
      .toList();

  // Produits en rupture de stock
  List<ProductModel> get outOfStockProducts => _products
      .where((product) => product.isOutOfStock && product.isActive)
      .toList();

  // Statistiques
  int get totalProducts => _products.where((p) => p.isActive).length;
  int get lowStockCount => lowStockProducts.length;
  int get outOfStockCount => outOfStockProducts.length;
  double get totalStockValue => _products
      .where((p) => p.isActive)
      .fold(0.0, (sum, product) => sum + product.totalStockValue);

  ProductProvider() {
    loadProducts();
  }

  Future<void> loadProducts() async {
    _setLoading(true);
    _clearError();

    try {
      _products = await _productService.getAllProducts();
      _applyFilters();
      _setLoading(false);
    } catch (e) {
      _setError('Erreur lors du chargement des produits: $e');
      _setLoading(false);
    }
  }

  /// Charger uniquement les produits de l'utilisateur connecté
  Future<void> loadUserProducts(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      final allProducts = await _productService.getAllProducts();
      _products = allProducts.where((product) => product.userId == userId).toList();
      _applyFilters();
      _setLoading(false);
    } catch (e) {
      _setError('Erreur lors du chargement des produits: $e');
      _setLoading(false);
    }
  }

  Future<ProductModel?> getProductById(String id) async {
    try {
      // Chercher d'abord dans la liste locale
      final localProduct = _products.firstWhere(
        (product) => product.id == id,
        orElse: () => throw Exception('Product not found locally'),
      );
      return localProduct;
    } catch (e) {
      // Si pas trouvé localement, charger depuis le service
      try {
        return await _productService.getProductById(id);
      } catch (e) {
        _setError('Erreur lors du chargement du produit: $e');
        return null;
      }
    }
  }

  Future<ProductModel?> getProductByBarcode(String barcode) async {
    try {
      return await _productService.getProductByBarcode(barcode);
    } catch (e) {
      _setError('Produit non trouvé avec ce code-barres');
      return null;
    }
  }

  Future<bool> createProduct(ProductModel product) async {
    _setLoading(true);
    _clearError();

    try {
      final newProduct = await _productService.createProduct(product);
      _products.add(newProduct);
      _applyFilters();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Erreur lors de la création du produit: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Créer un produit avec une image
  Future<bool> createProductWithImage({
    required ProductModel product,
    File? imageFile,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final newProduct = await _productService.createProductWithImage(
        product: product,
        imageFile: imageFile,
      );
      _products.add(newProduct);
      _applyFilters();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Erreur lors de la création du produit avec image: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateProduct(ProductModel product) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedProduct = await _productService.updateProduct(product);
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = updatedProduct;
        _applyFilters();
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Erreur lors de la mise à jour du produit: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Mettre à jour un produit avec gestion des images
  Future<bool> updateProductWithImage({
    required ProductModel product,
    File? newImageFile,
    bool removeCurrentImage = false,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedProduct = await _productService.updateProductWithImage(
        product: product,
        newImageFile: newImageFile,
        removeCurrentImage: removeCurrentImage,
      );
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = updatedProduct;
        _applyFilters();
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Erreur lors de la mise à jour du produit avec image: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteProduct(String id) async {
    _setLoading(true);
    _clearError();

    try {
      await _productService.deleteProduct(id);
      _products.removeWhere((product) => product.id == id);
      _applyFilters();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Erreur lors de la suppression du produit: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateStock(String productId, double newQuantity,
      {String? reason}) async {
    try {
      await _productService.updateStock(productId, newQuantity, reason: reason);

      // Mettre à jour localement
      final index = _products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        _products[index] =
            _products[index].copyWith(stockQuantity: newQuantity);
        _applyFilters();
      }

      return true;
    } catch (e) {
      _setError('Erreur lors de la mise à jour du stock: $e');
      return false;
    }
  }

  Future<bool> adjustStock(String productId, double adjustment,
      {String? reason}) async {
    try {
      final product = _products.firstWhere((p) => p.id == productId);
      final newQuantity = product.stockQuantity + adjustment;
      return await updateStock(productId, newQuantity, reason: reason);
    } catch (e) {
      _setError('Erreur lors de l\'ajustement du stock: $e');
      return false;
    }
  }

  void searchProducts(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void filterByCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    _applyFilters();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategoryId = null;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredProducts = _products.where((product) {
      // Filtre par recherche
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesName = product.name.toLowerCase().contains(query);
        final matchesBarcode =
            product.barcode?.toLowerCase().contains(query) ?? false;
        final matchesSku = product.sku?.toLowerCase().contains(query) ?? false;

        if (!matchesName && !matchesBarcode && !matchesSku) {
          return false;
        }
      }

      // Filtre par catégorie
      if (_selectedCategoryId != null &&
          product.categoryId != _selectedCategoryId) {
        return false;
      }

      return true;
    }).toList();

    // Trier par nom
    _filteredProducts.sort((a, b) => a.name.compareTo(b.name));

    notifyListeners();
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

  // Rechercher un produit par code-barres
  Future<ProductModel?> searchByBarcode(String barcode) async {
    try {
      // Rechercher dans les produits chargés
      final product = _products.where((p) => p.barcode == barcode).firstOrNull;
      if (product != null) {
        return product;
      }

      // TODO: Implémenter la recherche API si le produit n'est pas en cache
      await Future.delayed(const Duration(milliseconds: 500));

      return null;
    } catch (e) {
      _setError('Erreur lors de la recherche: $e');
      return null;
    }
  }

  // Upload d'image pour un produit
  Future<String?> uploadProductImage(String productId, File imageFile) async {
    try {
      return await _productService.uploadProductImage(productId, imageFile);
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'upload de l\'image: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Assigner plusieurs produits à une catégorie.
  ///
  /// [productIds] : ensemble d'identifiants de produits à mettre à jour.
  /// [categoryId] : identifiant de la catégorie cible.
  Future<void> assignProductsToCategory(Set<String> productIds, String categoryId) async {
    if (productIds.isEmpty || categoryId.isEmpty) {
      return;
    }
    _setLoading(true);
    _clearError();
    try {
      for (final id in productIds) {
        final index = _products.indexWhere((p) => p.id == id);
        if (index != -1) {
          final current = _products[index];
          final updated = current.copyWith(categoryId: categoryId);
          final updatedProduct = await _productService.updateProduct(updated);
          _products[index] = updatedProduct;
        }
      }
      _applyFilters();
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors de l\'assignation des produits: $e');
      _setLoading(false);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}

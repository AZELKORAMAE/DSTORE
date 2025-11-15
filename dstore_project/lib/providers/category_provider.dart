import 'dart:io';
import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/category_service.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryService _categoryService = CategoryService();

  List<CategoryModel> _categories = [];
  Map<String, int> _categoryProductCounts =
      {}; // Stockage du nombre de produits par catégorie
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get totalCategories => _categories.length;
  int get activeCategories => _categories.where((c) => c.isActive).length;
  int get totalProductsInCategories =>
      _categoryProductCounts.values.fold(0, (sum, count) => sum + count);

  // Récupérer le nombre de produits pour une catégorie spécifique
  int getProductCountForCategory(String categoryId) {
    return _categoryProductCounts[categoryId] ?? 0;
  }

  CategoryProvider() {
    loadCategories();
  }

  Future<void> loadCategories() async {
    _setLoading(true);
    _clearError();

    try {
      _categories = await _categoryService.getAllCategories();
      await _loadProductCounts(); // Charger les compteurs de produits
      _setLoading(false);
    } catch (e) {
      _setError('Erreur lors du chargement des catégories: $e');
      _setLoading(false);
    }
  }

  Future<void> _loadProductCounts() async {
    try {
      _categoryProductCounts.clear();
      for (final category in _categories) {
        if (category.id != null) {
          final count =
              await _categoryService.getCategoryProductsCount(category.id!);
          _categoryProductCounts[category.id!] = count;
        }
      }
      notifyListeners(); // Notifier les changements après le chargement des compteurs
    } catch (e) {
      print('Erreur lors du chargement des compteurs de produits: $e');
    }
  }

  Future<CategoryModel?> getCategoryById(String id) async {
    try {
      // Chercher d'abord dans la liste locale
      final localCategory = _categories.firstWhere(
        (category) => category.id == id,
        orElse: () => throw Exception('Category not found locally'),
      );
      return localCategory;
    } catch (e) {
      // Si pas trouvé localement, charger depuis le service
      try {
        return await _categoryService.getCategoryById(id);
      } catch (e) {
        _setError('Erreur lors du chargement de la catégorie: $e');
        return null;
      }
    }
  }

  Future<bool> createCategory(CategoryModel category) async {
    _setLoading(true);
    _clearError();

    try {
      // Vérifier si le nom existe déjà
      final existingCategory = _categories.firstWhere(
        (cat) => cat.name.toLowerCase() == category.name.toLowerCase(),
        orElse: () => throw Exception('Not found'),
      );

      if (existingCategory != null) {
        _setError('Une catégorie avec ce nom existe déjà');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      // Nom unique, continuer
    }

    try {
      final newCategory = await _categoryService.createCategory(category);
      _categories.add(newCategory);
      await _loadProductCounts(); // Recharger les compteurs
      _sortCategories();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Erreur lors de la création de la catégorie: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateCategory(CategoryModel category) async {
    _setLoading(true);
    _clearError();

    try {
      // Vérifier si le nom existe déjà (sauf pour la catégorie actuelle)
      final existingCategory = _categories.firstWhere(
        (cat) =>
            cat.name.toLowerCase() == category.name.toLowerCase() &&
            cat.id != category.id,
        orElse: () => throw Exception('Not found'),
      );

      if (existingCategory != null) {
        _setError('Une catégorie avec ce nom existe déjà');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      // Nom unique, continuer
    }

    try {
      final updatedCategory = await _categoryService.updateCategory(category);
      final index = _categories.indexWhere((cat) => cat.id == category.id);
      if (index != -1) {
        _categories[index] = updatedCategory;
        _sortCategories();
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Erreur lors de la mise à jour de la catégorie: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteCategory(String id) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _categoryService.deleteCategory(id);
      if (success) {
        _categories.removeWhere((category) => category.id == id);
        _categoryProductCounts.remove(id); // Supprimer aussi le compteur
        _setLoading(false);
        return true;
      } else {
        _setError('Échec de la suppression de la catégorie');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('$e');
      _setLoading(false);
      return false;
    }
  }

  List<CategoryModel> searchCategories(String query) {
    if (query.isEmpty) return _categories;

    final lowerQuery = query.toLowerCase();
    return _categories.where((category) {
      return category.name.toLowerCase().contains(lowerQuery) ||
          (category.description?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  void clearSearch() {
    // Cette méthode peut être utilisée pour effacer les filtres de recherche
    notifyListeners();
  }

  void _sortCategories() {
    _categories.sort((a, b) => a.name.compareTo(b.name));
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

  // Upload d'image pour une catégorie
  Future<String?> uploadCategoryImage(String categoryId, File imageFile) async {
    try {
      return await _categoryService.uploadCategoryImage(categoryId, imageFile);
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'upload de l\'image: $e';
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}

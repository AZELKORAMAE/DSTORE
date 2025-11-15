import 'package:flutter/material.dart';
import '../models/supplier_model.dart';
import '../services/supplier_service.dart';

class SupplierProvider extends ChangeNotifier {
  final SupplierService _supplierService = SupplierService();

  List<SupplierModel> _suppliers = [];
  List<SupplierModel> _filteredSuppliers = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  // Getters
  List<SupplierModel> get suppliers => _filteredSuppliers;
  List<SupplierModel> get allSuppliers => _suppliers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  // Statistiques
  int get totalSuppliers => _suppliers.where((s) => s.isActive).length;
  int get activeSuppliers => _suppliers.where((s) => s.isActive).length;
  int get totalProducts =>
      _suppliers.fold(0, (sum, s) => sum + (s.productCount ?? 0));

  SupplierProvider() {
    loadSuppliers();
  }

  Future<void> loadSuppliers() async {
    _setLoading(true);
    _clearError();

    try {
      _suppliers = await _supplierService.getAllSuppliers();
      _applyFilters();
      _setLoading(false);
    } catch (e) {
      _setError('Erreur lors du chargement des fournisseurs: $e');
      _setLoading(false);
    }
  }

  Future<SupplierModel?> getSupplierById(String id) async {
    try {
      // Chercher d'abord dans la liste locale
      final localSupplier = _suppliers.firstWhere(
        (supplier) => supplier.id == id,
        orElse: () => throw Exception('Supplier not found locally'),
      );
      return localSupplier;
    } catch (e) {
      // Si pas trouvé localement, charger depuis le service
      try {
        return await _supplierService.getSupplierById(id);
      } catch (e) {
        _setError('Erreur lors du chargement du fournisseur: $e');
        return null;
      }
    }
  }

  Future<bool> createSupplier(SupplierModel supplier) async {
    _setLoading(true);
    _clearError();

    try {
      final newSupplier = await _supplierService.createSupplier(supplier);
      _suppliers.add(newSupplier);
      _applyFilters();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Erreur lors de la création du fournisseur: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateSupplier(SupplierModel supplier) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedSupplier = await _supplierService.updateSupplier(supplier);
      final index = _suppliers.indexWhere((s) => s.id == supplier.id);
      if (index != -1) {
        _suppliers[index] = updatedSupplier;
        _applyFilters();
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Erreur lors de la mise à jour du fournisseur: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteSupplier(String id) async {
    _setLoading(true);
    _clearError();

    try {
      await _supplierService.deleteSupplier(id);
      _suppliers.removeWhere((supplier) => supplier.id == id);
      _applyFilters();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Erreur lors de la suppression du fournisseur: $e');
      _setLoading(false);
      return false;
    }
  }

  void searchSuppliers(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void clearSearch() {
    _searchQuery = '';
    _applyFilters();
  }

  void _applyFilters() {
    _filteredSuppliers = _suppliers.where((supplier) {
      // Filtre par recherche
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesName = supplier.name.toLowerCase().contains(query);
        final matchesEmail =
            supplier.email?.toLowerCase().contains(query) ?? false;
        final matchesPhone =
            supplier.phone?.toLowerCase().contains(query) ?? false;
        final matchesContact =
            supplier.contactPerson?.toLowerCase().contains(query) ?? false;

        if (!matchesName && !matchesEmail && !matchesPhone && !matchesContact) {
          return false;
        }
      }

      return true;
    }).toList();

    // Trier par nom
    _filteredSuppliers.sort((a, b) => a.name.compareTo(b.name));

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

  @override
  void dispose() {
    super.dispose();
  }
}

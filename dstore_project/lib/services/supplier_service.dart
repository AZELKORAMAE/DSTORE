import '../models/supplier_model.dart';
import 'local_storage_service.dart';

class SupplierService {
  final LocalStorageService _localStorage = LocalStorageService.instance;

  Future<List<SupplierModel>> getAllSuppliers() async {
    try {
      final suppliersData = _localStorage.getSuppliers();
      return suppliersData.map((json) {
        final Map<String, dynamic> supplierMap =
            Map<String, dynamic>.from(json);
        return SupplierModel.fromJson(supplierMap);
      }).toList();
    } catch (e) {
      print('Erreur lors du chargement des fournisseurs: $e');
      return [];
    }
  }

  Future<SupplierModel?> getSupplierById(String id) async {
    try {
      final suppliersData = _localStorage.getSuppliers();
      final supplierData = suppliersData.firstWhere(
        (supplier) => supplier['id'] == id,
        orElse: () => <String, dynamic>{},
      );

      if (supplierData.isEmpty) return null;
      return SupplierModel.fromJson(supplierData);
    } catch (e) {
      throw Exception('Erreur lors du chargement du fournisseur: $e');
    }
  }

  Future<SupplierModel> createSupplier(SupplierModel supplier) async {
    try {
      final supplierData = supplier.toJson();
      supplierData['id'] = DateTime.now().millisecondsSinceEpoch.toString();
      supplierData['created_at'] = DateTime.now().toIso8601String();
      supplierData['updated_at'] = DateTime.now().toIso8601String();

      await _localStorage.saveSupplier(supplierData);
      return SupplierModel.fromJson(supplierData);
    } catch (e) {
      throw Exception('Erreur lors de la création du fournisseur: $e');
    }
  }

  Future<SupplierModel> updateSupplier(SupplierModel supplier) async {
    try {
      final supplierData = supplier.toJson();
      supplierData['updated_at'] = DateTime.now().toIso8601String();

      await _localStorage.saveSupplier(supplierData);
      return SupplierModel.fromJson(supplierData);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du fournisseur: $e');
    }
  }

  Future<void> deleteSupplier(String id) async {
    try {
      await _localStorage.deleteSupplier(id);
    } catch (e) {
      throw Exception('Erreur lors de la suppression du fournisseur: $e');
    }
  }

  Future<List<SupplierModel>> searchSuppliers(String query) async {
    try {
      final suppliersData = _localStorage.getSuppliers();
      final filteredSuppliers = suppliersData.where((supplier) {
        final name = supplier['name']?.toString().toLowerCase() ?? '';
        final email = supplier['email']?.toString().toLowerCase() ?? '';
        final phone = supplier['phone']?.toString().toLowerCase() ?? '';
        final company = supplier['company']?.toString().toLowerCase() ?? '';
        final searchQuery = query.toLowerCase();

        return name.contains(searchQuery) ||
            email.contains(searchQuery) ||
            phone.contains(searchQuery) ||
            company.contains(searchQuery);
      }).toList();

      return filteredSuppliers
          .map((json) => SupplierModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la recherche: $e');
    }
  }

  Future<SupplierModel?> getSupplierByEmail(String email) async {
    try {
      final suppliersData = _localStorage.getSuppliers();
      final supplierData = suppliersData.firstWhere(
        (supplier) =>
            supplier['email']?.toString().toLowerCase() == email.toLowerCase(),
        orElse: () => <String, dynamic>{},
      );

      if (supplierData.isEmpty) return null;
      return SupplierModel.fromJson(supplierData);
    } catch (e) {
      return null;
    }
  }

  Future<SupplierModel?> getSupplierByPhone(String phone) async {
    try {
      final suppliersData = _localStorage.getSuppliers();
      final supplierData = suppliersData.firstWhere(
        (supplier) => supplier['phone'] == phone,
        orElse: () => <String, dynamic>{},
      );

      if (supplierData.isEmpty) return null;
      return SupplierModel.fromJson(supplierData);
    } catch (e) {
      return null;
    }
  }

  Future<List<SupplierModel>> getRecentSuppliers({int limit = 10}) async {
    try {
      final suppliersData = _localStorage.getSuppliers();

      // Trier par date de création (plus récent en premier)
      suppliersData.sort((a, b) {
        final dateA =
            DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(1970);
        final dateB =
            DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(1970);
        return dateB.compareTo(dateA);
      });

      final recentSuppliers = suppliersData.take(limit).toList();
      return recentSuppliers
          .map((json) => SupplierModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des fournisseurs récents: $e');
    }
  }

  Future<int> getSuppliersCount() async {
    try {
      final suppliersData = _localStorage.getSuppliers();
      return suppliersData.length;
    } catch (e) {
      return 0;
    }
  }

  Future<List<SupplierModel>> getActiveSuppliers() async {
    try {
      final suppliersData = _localStorage.getSuppliers();
      final activeSuppliers = suppliersData.where((supplier) {
        return supplier['is_active'] == true || supplier['is_active'] == null;
      }).toList();

      return activeSuppliers
          .map((json) => SupplierModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des fournisseurs actifs: $e');
    }
  }

  Future<void> toggleSupplierStatus(String supplierId) async {
    try {
      final supplier = await getSupplierById(supplierId);
      if (supplier != null) {
        final supplierData = supplier.toJson();
        supplierData['is_active'] = !(supplier.isActive ?? true);
        supplierData['updated_at'] = DateTime.now().toIso8601String();
        await _localStorage.saveSupplier(supplierData);
      }
    } catch (e) {
      throw Exception('Erreur lors du changement de statut: $e');
    }
  }

  Future<double> getSupplierTotalPurchases(String supplierId) async {
    try {
      // Pour l'instant, retourner 0 (sera implémenté avec InvoiceService)
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  Future<int> getSupplierOrdersCount(String supplierId) async {
    try {
      // Pour l'instant, retourner 0 (sera implémenté avec InvoiceService)
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<DateTime?> getSupplierLastOrderDate(String supplierId) async {
    try {
      // Pour l'instant, retourner null (sera implémenté avec InvoiceService)
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<SupplierModel>> getTopSuppliers({int limit = 5}) async {
    try {
      // Pour l'instant, retourner les fournisseurs récents
      return await getRecentSuppliers(limit: limit);
    } catch (e) {
      throw Exception(
          'Erreur lors du chargement des meilleurs fournisseurs: $e');
    }
  }

  Future<bool> isEmailExists(String email, {String? excludeId}) async {
    try {
      final supplier = await getSupplierByEmail(email);
      if (supplier == null) return false;
      if (excludeId != null && supplier.id == excludeId) return false;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isPhoneExists(String phone, {String? excludeId}) async {
    try {
      final supplier = await getSupplierByPhone(phone);
      if (supplier == null) return false;
      if (excludeId != null && supplier.id == excludeId) return false;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> updateSupplierCredit(String supplierId, double newCredit) async {
    try {
      final supplier = await getSupplierById(supplierId);
      if (supplier != null) {
        final supplierData = supplier.toJson();
        supplierData['credit_limit'] = newCredit;
        supplierData['updated_at'] = DateTime.now().toIso8601String();
        await _localStorage.saveSupplier(supplierData);
      }
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du crédit: $e');
    }
  }

  Future<void> addSupplierTransaction(
      String supplierId, double amount, String type) async {
    try {
      // Pour l'instant, ne rien faire (sera implémenté avec un système de transactions)
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout de la transaction: $e');
    }
  }
}

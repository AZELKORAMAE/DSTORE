import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorageService {
  static LocalStorageService? _instance;
  static LocalStorageService get instance =>
      _instance ??= LocalStorageService._();
  LocalStorageService._();

  // Stockage sécurisé pour les informations de connexion
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Boxes Hive pour chaque type de données (par utilisateur)
  late Box _productsBox;
  late Box _categoriesBox;
  late Box _clientsBox;
  late Box _suppliersBox;
  late Box _invoicesBox;
  late Box _expensesBox;
  late Box _settingsBox;
  late Box _creditsBox;
  late Box _creditPaymentsBox;
  late Box _revenuesBox;
  late Box _userInfoBox;

  // ID de l'utilisateur actuel
  String? _currentUserId;

  // Initialiser le stockage local pour un utilisateur spécifique
  Future<void> initialize({String? userId}) async {
    await Hive.initFlutter();

    // Utiliser l'ID utilisateur pour créer des boxes séparées
    _currentUserId = userId;
    final userPrefix = userId != null ? '${userId}_' : '';

    // Ouvrir les boxes avec préfixe utilisateur
    _productsBox = await Hive.openBox('${userPrefix}products');
    _categoriesBox = await Hive.openBox('${userPrefix}categories');
    _clientsBox = await Hive.openBox('${userPrefix}clients');
    _suppliersBox = await Hive.openBox('${userPrefix}suppliers');
    _invoicesBox = await Hive.openBox('${userPrefix}invoices');
    _expensesBox = await Hive.openBox('${userPrefix}expenses');
    _settingsBox = await Hive.openBox('${userPrefix}settings');
    _creditsBox = await Hive.openBox('${userPrefix}credits');
    _creditPaymentsBox = await Hive.openBox('${userPrefix}credit_payments');
    _revenuesBox = await Hive.openBox('${userPrefix}revenues');
    _userInfoBox = await Hive.openBox('${userPrefix}user_info');

    print(
        '✅ Stockage local initialisé pour utilisateur: ${userId ?? "anonyme"}');
  }

  // Changer d'utilisateur (fermer les boxes actuelles et en ouvrir de nouvelles)
  Future<void> switchUser(String userId) async {
    // Fermer les boxes actuelles
    await _productsBox.close();
    await _categoriesBox.close();
    await _clientsBox.close();
    await _suppliersBox.close();
    await _invoicesBox.close();
    await _expensesBox.close();
    await _settingsBox.close();
    await _creditsBox.close();
    await _creditPaymentsBox.close();
    await _revenuesBox.close();
    await _userInfoBox.close();

    // Réinitialiser avec le nouvel utilisateur
    await initialize(userId: userId);
  }

  // ==================== PRODUITS ====================

  Future<void> saveProduct(Map<String, dynamic> product) async {
    await _productsBox.put(product['id'], product);
  }

  Future<void> saveProducts(List<Map<String, dynamic>> products) async {
    for (var product in products) {
      await saveProduct(product);
    }
  }

  List<Map<String, dynamic>> getProducts() {
    return _productsBox.values
        .map((value) => Map<String, dynamic>.from(value))
        .toList();
  }

  Map<String, dynamic>? getProduct(String id) {
    return _productsBox.get(id);
  }

  Future<void> deleteProduct(String id) async {
    await _productsBox.delete(id);
  }

  // ==================== CATÉGORIES ====================

  Future<void> saveCategory(Map<String, dynamic> category) async {
    await _categoriesBox.put(category['id'], category);
  }

  List<Map<String, dynamic>> getCategories() {
    return _categoriesBox.values
        .map((value) => Map<String, dynamic>.from(value))
        .toList();
  }

  Future<void> deleteCategory(String id) async {
    await _categoriesBox.delete(id);
  }

  // ==================== CLIENTS ====================

  Future<void> saveClient(Map<String, dynamic> client) async {
    await _clientsBox.put(client['id'], client);
  }

  List<Map<String, dynamic>> getClients() {
    return _clientsBox.values
        .map((value) => Map<String, dynamic>.from(value))
        .toList();
  }

  Future<void> deleteClient(String id) async {
    await _clientsBox.delete(id);
  }

  // ==================== FOURNISSEURS ====================

  Future<void> saveSupplier(Map<String, dynamic> supplier) async {
    await _suppliersBox.put(supplier['id'], supplier);
  }

  List<Map<String, dynamic>> getSuppliers() {
    return _suppliersBox.values
        .map((value) => Map<String, dynamic>.from(value))
        .toList();
  }

  Future<void> deleteSupplier(String id) async {
    await _suppliersBox.delete(id);
  }

  // ==================== FACTURES ====================

  Future<void> saveInvoice(Map<String, dynamic> invoice) async {
    await _invoicesBox.put(invoice['id'], invoice);
  }

  List<Map<String, dynamic>> getInvoices() {
    return _invoicesBox.values
        .map((value) => Map<String, dynamic>.from(value))
        .toList();
  }

  Future<void> deleteInvoice(String id) async {
    await _invoicesBox.delete(id);
  }

  // ==================== DÉPENSES ====================

  Future<void> saveExpense(Map<String, dynamic> expense) async {
    await _expensesBox.put(expense['id'], expense);
  }

  List<Map<String, dynamic>> getExpenses() {
    return _expensesBox.values
        .map((value) => Map<String, dynamic>.from(value))
        .toList();
  }

  Future<void> deleteExpense(String id) async {
    await _expensesBox.delete(id);
  }

  // ==================== PARAMÈTRES ====================

  Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  T? getSetting<T>(String key) {
    try {
      final value = _settingsBox.get(key);
      if (value == null) return null;

      // Conversion sécurisée pour les Maps
      if (value is Map) {
        return Map<String, dynamic>.from(value) as T;
      }

      return value as T?;
    } catch (e) {
      // En cas d'erreur, retourner null
      return null;
    }
  }

  // ==================== SYNCHRONISATION ====================

  // Marquer les données comme modifiées (pour sync future)
  Future<void> markAsModified(String type, String id) async {
    final modifiedItems = getSetting<List<String>>('modified_$type') ?? [];
    if (!modifiedItems.contains(id)) {
      modifiedItems.add(id);
      await saveSetting('modified_$type', modifiedItems);
    }
  }

  // Obtenir les éléments modifiés
  List<String> getModifiedItems(String type) {
    return getSetting<List<String>>('modified_$type') ?? [];
  }

  // Effacer les éléments modifiés après sync
  Future<void> clearModifiedItems(String type) async {
    await saveSetting('modified_$type', <String>[]);
  }

  // ==================== GESTION UTILISATEUR ====================

  // Sauvegarder le statut d'abonnement
  Future<void> saveSubscriptionStatus(String status) async {
    await saveSetting('subscription_status', status);
    await saveSetting('last_status_check', DateTime.now().toIso8601String());
  }

  String getSubscriptionStatus() {
    return getSetting<String>('subscription_status') ?? 'pending';
  }

  DateTime? getLastStatusCheck() {
    final dateStr = getSetting<String>('last_status_check');
    return dateStr != null ? DateTime.parse(dateStr) : null;
  }

  // ==================== NETTOYAGE ====================

  // Effacer seulement les factures
  Future<void> clearInvoices() async {
    await _invoicesBox.clear();
  }

  // Effacer toutes les données (déconnexion)
  Future<void> clearAllData() async {
    await _productsBox.clear();
    await _categoriesBox.clear();
    await _clientsBox.clear();
    await _suppliersBox.clear();
    await _invoicesBox.clear();
    await _expensesBox.clear();
    await _settingsBox.clear();
    print('🗑️ Toutes les données locales effacées');
  }

  // Effacer seulement les données business (garder les paramètres)
  Future<void> clearBusinessData() async {
    await _productsBox.clear();
    await _categoriesBox.clear();
    await _clientsBox.clear();
    await _suppliersBox.clear();
    await _invoicesBox.clear();
    await _expensesBox.clear();
    print('🗑️ Données business effacées');
  }

  // Méthodes statiques pour la compatibilité avec AccountDeviceService
  static Future<void> clearAll() async {
    final instance = LocalStorageService.instance;
    await instance.clearAllData();
  }

  static Future<void> clearUserData(String userId) async {
    // Pour l'instant, nettoie toutes les données car elles ne sont pas séparées par utilisateur
    final instance = LocalStorageService.instance;
    await instance.clearAllData();
    print('✅ Données utilisateur $userId supprimées');
  }

  static Future<void> clearUserSession(String userId) async {
    // Nettoie seulement les paramètres qui pourraient contenir des tokens
    final instance = LocalStorageService.instance;
    await instance._settingsBox.clear();
    print('✅ Session utilisateur $userId nettoyée');
  }

  // ==================== STATISTIQUES ====================

  Map<String, int> getDataCounts() {
    return {
      'products': _productsBox.length,
      'categories': _categoriesBox.length,
      'clients': _clientsBox.length,
      'suppliers': _suppliersBox.length,
      'invoices': _invoicesBox.length,
    };
  }

  // ==================== BACKUP/RESTORE ====================

  // Exporter toutes les données
  Map<String, dynamic> exportAllData() {
    return {
      'products': getProducts(),
      'categories': getCategories(),
      'clients': getClients(),
      'suppliers': getSuppliers(),
      'invoices': getInvoices(),
      'settings': _settingsBox.toMap(),
      'exported_at': DateTime.now().toIso8601String(),
    };
  }

  // Importer des données
  Future<void> importAllData(Map<String, dynamic> data) async {
    if (data['products'] != null) {
      await saveProducts(List<Map<String, dynamic>>.from(data['products']));
    }

    if (data['categories'] != null) {
      for (var category in data['categories']) {
        await saveCategory(category);
      }
    }

    if (data['clients'] != null) {
      for (var client in data['clients']) {
        await saveClient(client);
      }
    }

    if (data['suppliers'] != null) {
      for (var supplier in data['suppliers']) {
        await saveSupplier(supplier);
      }
    }

    if (data['invoices'] != null) {
      for (var invoice in data['invoices']) {
        await saveInvoice(invoice);
      }
    }

    print('📥 Données importées avec succès');
  }

  // ==================== GESTION DES CRÉDITS ====================

  /// Sauvegarder un crédit
  Future<void> saveCredit(Map<String, dynamic> creditData) async {
    await _creditsBox.put(creditData['id'], creditData);
  }

  /// Obtenir tous les crédits
  List<Map<String, dynamic>> getCredits() {
    try {
      return _creditsBox.values
          .map((value) => Map<String, dynamic>.from(value))
          .toList();
    } catch (e) {
      print('❌ Erreur lors du chargement des crédits: $e');
      return [];
    }
  }

  /// Obtenir un crédit par ID
  Map<String, dynamic>? getCreditById(String id) {
    return _creditsBox.get(id);
  }

  /// Supprimer un crédit
  Future<void> deleteCredit(String id) async {
    await _creditsBox.delete(id);
  }

  /// Sauvegarder un paiement de crédit
  Future<void> saveCreditPayment(Map<String, dynamic> paymentData) async {
    await _creditPaymentsBox.put(paymentData['id'], paymentData);
  }

  /// Obtenir tous les paiements de crédit
  List<Map<String, dynamic>> getCreditPayments() {
    try {
      return _creditPaymentsBox.values
          .map((value) => Map<String, dynamic>.from(value))
          .toList();
    } catch (e) {
      print('❌ Erreur lors du chargement des paiements de crédit: $e');
      return [];
    }
  }

  /// Supprimer un paiement de crédit
  Future<void> deleteCreditPayment(String id) async {
    await _creditPaymentsBox.delete(id);
  }

  // ==================== GESTION DES REVENUS ====================

  /// Sauvegarder un revenu
  Future<void> saveRevenue(Map<String, dynamic> revenueData) async {
    await _revenuesBox.put(revenueData['id'], revenueData);
  }

  /// Obtenir tous les revenus
  List<Map<String, dynamic>> getRevenues() {
    try {
      return _revenuesBox.values
          .map((value) => Map<String, dynamic>.from(value))
          .toList();
    } catch (e) {
      print('❌ Erreur lors du chargement des revenus: $e');
      return [];
    }
  }

  /// Obtenir un revenu par ID
  Map<String, dynamic>? getRevenueById(String id) {
    return _revenuesBox.get(id);
  }

  /// Supprimer un revenu
  Future<void> deleteRevenue(String id) async {
    await _revenuesBox.delete(id);
  }

  // ==================== GESTION DES INFORMATIONS DE CONNEXION ====================

  /// Sauvegarder les informations de connexion
  Future<void> saveLoginCredentials({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    try {
      // Toujours sauvegarder l'email pour le SubscriptionService
      await _secureStorage.write(key: 'current_user_email', value: email);

      if (rememberMe) {
        await _secureStorage.write(key: 'saved_email', value: email);
        await _secureStorage.write(key: 'saved_password', value: password);
        await _secureStorage.write(key: 'remember_me', value: 'true');
        print('✅ Informations de connexion sauvegardées');
      } else {
        // Si "Se souvenir de moi" est désactivé, supprimer seulement les données de "remember me"
        await _secureStorage.delete(key: 'saved_email');
        await _secureStorage.delete(key: 'saved_password');
        await _secureStorage.write(key: 'remember_me', value: 'false');
        print('✅ Données "Se souvenir de moi" supprimées, email utilisateur conservé');
      }
    } catch (e) {
      print('❌ Erreur sauvegarde informations connexion: $e');
    }
  }

  /// Récupérer les informations de connexion sauvegardées
  Future<Map<String, String?>> getSavedLoginCredentials() async {
    try {
      final rememberMe = await _secureStorage.read(key: 'remember_me');
      if (rememberMe == 'true') {
        final email = await _secureStorage.read(key: 'saved_email');
        final password = await _secureStorage.read(key: 'saved_password');
        print('✅ Informations de connexion récupérées');
        return {
          'email': email,
          'password': password,
          'remember_me': 'true',
        };
      }
    } catch (e) {
      print('❌ Erreur récupération informations connexion: $e');
    }
    return {
      'email': null,
      'password': null,
      'remember_me': 'false',
    };
  }

  /// Récupérer l'email de l'utilisateur connecté
  Future<String?> getUserEmail() async {
    try {
      // D'abord essayer l'email de l'utilisateur actuel
      final currentEmail = await _secureStorage.read(key: 'current_user_email');
      if (currentEmail != null) {
        return currentEmail;
      }

      // Fallback sur l'email sauvegardé
      final savedEmail = await _secureStorage.read(key: 'saved_email');
      return savedEmail;
    } catch (e) {
      print('❌ Erreur récupération email utilisateur: $e');
      return null;
    }
  }

  /// Vérifier si "Se souvenir de moi" est activé
  Future<bool> isRememberMeEnabled() async {
    try {
      final rememberMe = await _secureStorage.read(key: 'remember_me');
      return rememberMe == 'true';
    } catch (e) {
      print('❌ Erreur vérification remember me: $e');
      return false;
    }
  }

  /// Supprimer les informations de connexion sauvegardées
  Future<void> clearLoginCredentials() async {
    try {
      await _secureStorage.delete(key: 'saved_email');
      await _secureStorage.delete(key: 'saved_password');
      await _secureStorage.delete(key: 'remember_me');
      await _secureStorage.delete(key: 'current_user_email');
      print('✅ Informations de connexion supprimées');
    } catch (e) {
      print('❌ Erreur suppression informations connexion: $e');
    }
  }

  // ==================== INFORMATIONS UTILISATEUR ====================

  /// Sauvegarder les informations utilisateur
  Future<void> saveUserInfo(Map<String, dynamic> userInfo) async {
    try {
      await _userInfoBox.put('user_info', userInfo);
      print('✅ Informations utilisateur sauvegardées localement');
    } catch (e) {
      print('❌ Erreur sauvegarde informations utilisateur: $e');
    }
  }

  /// Récupérer les informations utilisateur
  Map<String, dynamic>? getUserInfo() {
    try {
      final userInfo = _userInfoBox.get('user_info');
      if (userInfo != null) {
        return Map<String, dynamic>.from(userInfo);
      }
      return null;
    } catch (e) {
      print('❌ Erreur récupération informations utilisateur: $e');
      return null;
    }
  }

  /// Supprimer les informations utilisateur
  Future<void> clearUserInfo() async {
    try {
      await _userInfoBox.delete('user_info');
      print('✅ Informations utilisateur supprimées');
    } catch (e) {
      print('❌ Erreur suppression informations utilisateur: $e');
    }
  }

}

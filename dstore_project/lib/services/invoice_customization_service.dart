import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/invoice_customization_model.dart';

class InvoiceCustomizationService {
  static const String _storageKeyPrefix = 'invoice_customization_';

  String _getStorageKey(String userId) => '${_storageKeyPrefix}$userId';

  Future<InvoiceCustomizationModel?> loadCustomization(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storageKey = _getStorageKey(userId);
      final data = prefs.getString(storageKey);
      if (data != null) {
        final json = jsonDecode(data);
        return InvoiceCustomizationModel.fromJson(json);
      }
      return null;
    } catch (e) {
      print('Erreur lors du chargement de la personnalisation: $e');
      return null;
    }
  }

  Future<bool> saveCustomization(InvoiceCustomizationModel customization) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storageKey = _getStorageKey(customization.userId);
      final json = customization.toJson();
      await prefs.setString(storageKey, jsonEncode(json));
      return true;
    } catch (e) {
      print('Erreur lors de la sauvegarde de la personnalisation: $e');
      return false;
    }
  }

  Future<InvoiceCustomizationModel> resetToDefault(String userId) async {
    try {
      final defaultCustomization = InvoiceCustomizationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        companyName: 'Mon Entreprise',
        companyAddress: 'Adresse de l\'entreprise',
        companyPhone: '+212 6XX XXX XXX',
        companyEmail: 'contact@monentreprise.ma',
        headerText: 'Merci de votre confiance',
        footerText: 'Conditions de paiement: 30 jours',
        primaryColor: '#2196F3',
        secondaryColor: '#FFC107',
        fontSize: 12.0,
        showLogo: true,
        showHeader: true,
        showFooter: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await saveCustomization(defaultCustomization);
      return defaultCustomization;
    } catch (e) {
      print('Erreur lors de la réinitialisation: $e');
      throw Exception('Erreur lors de la réinitialisation: $e');
    }
  }

  Future<bool> deleteCustomization(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storageKey = _getStorageKey(userId);
      await prefs.remove(storageKey);
      return true;
    } catch (e) {
      print('Erreur lors de la suppression de la personnalisation: $e');
      return false;
    }
  }

  bool validateCustomization(InvoiceCustomizationModel customization) {
    if (customization.companyName.isEmpty) {
      return false;
    }
    if (customization.fontSize < 8.0 || customization.fontSize > 24.0) {
      return false;
    }
    return true;
  }

  InvoiceCustomizationModel getDefaultCustomization(String userId) {
    return InvoiceCustomizationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      companyName: 'Mon Entreprise',
      companyAddress: 'Adresse de l\'entreprise',
      companyPhone: '+212 6XX XXX XXX',
      companyEmail: 'contact@monentreprise.ma',
      headerText: 'Merci de votre confiance',
      footerText: 'Conditions de paiement: 30 jours',
      primaryColor: '#2196F3',
      secondaryColor: '#FFC107',
      fontSize: 12.0,
      showLogo: true,
      showHeader: true,
      showFooter: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
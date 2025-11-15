import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'lib/models/invoice_customization_model.dart';
import 'lib/services/invoice_customization_service.dart';

void main() async {
  // Test de débogage pour la personnalisation des factures
  print('=== Test de débogage personnalisation ===');
  
  final service = InvoiceCustomizationService();
  final testUserId = 'test-user-123';
  
  // Créer une personnalisation de test
  final testCustomization = InvoiceCustomizationModel(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    userId: testUserId,
    companyName: 'Test Entreprise',
    companyAddress: 'Test Adresse',
    companyPhone: '+212 600 000 000',
    companyEmail: 'test@test.com',
    headerText: 'Test Header',
    footerText: 'Test Footer',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
  
  print('1. Sauvegarde de la personnalisation...');
  final saveResult = await service.saveCustomization(testCustomization);
  print('Résultat sauvegarde: $saveResult');
  
  // Vérifier ce qui est stocké dans SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final storedData = prefs.getString('invoice_customization');
  print('2. Données stockées: $storedData');
  
  if (storedData != null) {
    final json = jsonDecode(storedData);
    print('3. JSON décodé: $json');
    print('4. UserId dans les données: ${json['user_id']}');
  }
  
  print('5. Chargement de la personnalisation...');
  final loadedCustomization = await service.loadCustomization(testUserId);
  
  if (loadedCustomization != null) {
    print('6. Personnalisation chargée avec succès:');
    print('   - Nom entreprise: ${loadedCustomization.companyName}');
    print('   - Header: ${loadedCustomization.headerText}');
    print('   - Footer: ${loadedCustomization.footerText}');
  } else {
    print('6. ERREUR: Aucune personnalisation chargée!');
  }
  
  // Test avec un autre userId
  print('7. Test avec un userId différent...');
  final loadedWithDifferentId = await service.loadCustomization('different-user');
  print('Résultat avec userId différent: ${loadedWithDifferentId != null ? "Trouvé" : "Non trouvé"}');
}
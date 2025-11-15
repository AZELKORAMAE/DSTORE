import 'dart:io';
import 'lib/services/excel_import_service.dart';

void main() async {
  print('🧪 Test d\'import Excel avec images');

  final filePath = 'fichier_nettoye_rapide_20250712_145109.xlsx';
  
  if (!await File(filePath).exists()) {
    print('❌ Fichier non trouvé: $filePath');
    print('💡 Placez votre fichier Excel dans le répertoire racine du projet');
    return;
  }
  
  try {
    print('📂 Test de lecture du fichier Excel...');
    final data = await ExcelImportService.pickAndReadExcelFile(filePath: filePath);
    
    if (data != null && data.isNotEmpty) {
      print('✅ ${data.length} lignes lues du fichier Excel');

      for (int i = 0; i < data.length && i < 5; i++) {
        print('Ligne $i: ${data[i]}');
      }

      final products = ExcelImportService.convertToProductModels(data, 'test_user');
      print('✅ ${products.length} produits convertis');

      for (final product in products) {
        print('📦 Produit: ${product.name}');
        print('   Code-barres: ${product.barcode}');
        print('   Image: ${product.imageUrl ?? 'Aucune'}');
        print('   ---');
      }
      
    } else {
      print('❌ Aucune donnée trouvée dans le fichier');
    }
    
  } catch (e) {
    print('❌ Erreur lors du test: $e');
  }
}

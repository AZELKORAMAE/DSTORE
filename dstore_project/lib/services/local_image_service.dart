import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';

class LocalImageService {
  static const String _imagesFolder = 'dstore_images';
  static const String _productsFolder = 'products';
  static const String _categoriesFolder = 'categories';
  static const String _invoicesFolder = 'invoices';

  /// Sauvegarder une image de produit
  static Future<String?> saveProductImage(File imageFile, String productId) async {
    try {
      if (kIsWeb) {
        // Pour le web, convertir en base64
        final bytes = await imageFile.readAsBytes();
        final base64String = base64Encode(bytes);
        return 'data:image/jpeg;base64,$base64String';
      } else {
        // Pour mobile/desktop, sauvegarder dans le dossier local
        final directory = await _getImagesDirectory();
        final productsDir = Directory(path.join(directory.path, _productsFolder));
        
        if (!await productsDir.exists()) {
          await productsDir.create(recursive: true);
        }

        final fileName = '${productId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedImage = File(path.join(productsDir.path, fileName));
        
        await imageFile.copy(savedImage.path);
        return savedImage.path;
      }
    } catch (e) {
      print('Erreur lors de la sauvegarde de l\'image: $e');
      return null;
    }
  }

  /// Sauvegarder une image de catégorie
  static Future<String?> saveCategoryImage(File imageFile, String categoryId) async {
    try {
      if (kIsWeb) {
        // Pour le web, convertir en base64
        final bytes = await imageFile.readAsBytes();
        final base64String = base64Encode(bytes);
        return 'data:image/jpeg;base64,$base64String';
      } else {
        // Pour mobile/desktop, sauvegarder dans le dossier local
        final directory = await _getImagesDirectory();
        final categoriesDir = Directory(path.join(directory.path, _categoriesFolder));

        if (!await categoriesDir.exists()) {
          await categoriesDir.create(recursive: true);
        }

        final fileName = '${categoryId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedImage = File(path.join(categoriesDir.path, fileName));

        await imageFile.copy(savedImage.path);
        return savedImage.path;
      }
    } catch (e) {
      print('Erreur lors de la sauvegarde de l\'image: $e');
      return null;
    }
  }

  /// Sauvegarder une image de facture
  static Future<String?> saveInvoiceImage(File imageFile, String invoiceId) async {
    try {
      if (kIsWeb) {
        // Pour le web, convertir en base64
        final bytes = await imageFile.readAsBytes();
        final base64String = base64Encode(bytes);
        return 'data:image/jpeg;base64,$base64String';
      } else {
        // Pour mobile/desktop, sauvegarder dans le dossier local
        final directory = await _getImagesDirectory();
        final invoicesDir = Directory(path.join(directory.path, _invoicesFolder));

        if (!await invoicesDir.exists()) {
          await invoicesDir.create(recursive: true);
        }

        final fileName = '${invoiceId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedImage = File(path.join(invoicesDir.path, fileName));

        await imageFile.copy(savedImage.path);
        return savedImage.path;
      }
    } catch (e) {
      print('Erreur lors de la sauvegarde de l\'image de facture: $e');
      return null;
    }
  }

  /// Supprimer une image de produit
  static Future<bool> deleteProductImage(String imagePath) async {
    try {
      if (kIsWeb) {
        // Pour le web, pas besoin de supprimer (base64)
        return true;
      } else {
        final file = File(imagePath);
        if (await file.exists()) {
          await file.delete();
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Erreur lors de la suppression de l\'image: $e');
      return false;
    }
  }

  /// Supprimer une image de catégorie
  static Future<bool> deleteCategoryImage(String imagePath) async {
    try {
      if (kIsWeb) {
        // Pour le web, pas besoin de supprimer (base64)
        return true;
      } else {
        final file = File(imagePath);
        if (await file.exists()) {
          await file.delete();
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Erreur lors de la suppression de l\'image: $e');
      return false;
    }
  }

  /// Supprimer une image de facture
  static Future<bool> deleteInvoiceImage(String imagePath) async {
    try {
      if (kIsWeb) {
        // Pour le web, pas besoin de supprimer (base64)
        return true;
      } else {
        final file = File(imagePath);
        if (await file.exists()) {
          await file.delete();
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Erreur lors de la suppression de l\'image de facture: $e');
      return false;
    }
  }

  /// Vérifier si une image existe
  static Future<bool> imageExists(String imagePath) async {
    try {
      if (kIsWeb) {
        // Pour le web, vérifier si c'est une chaîne base64 valide
        return imagePath.startsWith('data:image/');
      } else {
        final file = File(imagePath);
        return await file.exists();
      }
    } catch (e) {
      return false;
    }
  }

  /// Obtenir le répertoire des images
  static Future<Directory> _getImagesDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(path.join(appDir.path, _imagesFolder));
    
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    
    return imagesDir;
  }

  /// Obtenir la taille d'une image
  static Future<int> getImageSize(String imagePath) async {
    try {
      if (kIsWeb) {
        // Pour le web, estimer la taille à partir du base64
        if (imagePath.startsWith('data:image/')) {
          final base64Data = imagePath.split(',')[1];
          return base64Data.length;
        }
        return 0;
      } else {
        final file = File(imagePath);
        if (await file.exists()) {
          return await file.length();
        }
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Nettoyer les images orphelines
  static Future<void> cleanupOrphanedImages() async {
    try {
      if (kIsWeb) {
        // Pour le web, pas de nettoyage nécessaire
        return;
      }

      final directory = await _getImagesDirectory();
      
      // Nettoyer les images de produits
      final productsDir = Directory(path.join(directory.path, _productsFolder));
      if (await productsDir.exists()) {
        await _cleanupDirectoryImages(productsDir);
      }

      // Nettoyer les images de catégories
      final categoriesDir = Directory(path.join(directory.path, _categoriesFolder));
      if (await categoriesDir.exists()) {
        await _cleanupDirectoryImages(categoriesDir);
      }
    } catch (e) {
      print('Erreur lors du nettoyage des images: $e');
    }
  }

  /// Nettoyer les images d'un répertoire
  static Future<void> _cleanupDirectoryImages(Directory directory) async {
    try {
      final files = await directory.list().toList();
      final now = DateTime.now();
      
      for (final file in files) {
        if (file is File) {
          final stat = await file.stat();
          final daysSinceModified = now.difference(stat.modified).inDays;
          
          // Supprimer les images non utilisées depuis plus de 30 jours
          if (daysSinceModified > 30) {
            await file.delete();
            print('Image supprimée: ${file.path}');
          }
        }
      }
    } catch (e) {
      print('Erreur lors du nettoyage du répertoire: $e');
    }
  }

  /// Obtenir toutes les images de produits
  static Future<List<String>> getAllProductImages() async {
    try {
      if (kIsWeb) {
        return []; // Pour le web, les images sont stockées en base64
      }

      final directory = await _getImagesDirectory();
      final productsDir = Directory(path.join(directory.path, _productsFolder));
      
      if (!await productsDir.exists()) {
        return [];
      }

      final files = await productsDir.list().toList();
      return files
          .where((file) => file is File)
          .map((file) => file.path)
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Obtenir toutes les images de catégories
  static Future<List<String>> getAllCategoryImages() async {
    try {
      if (kIsWeb) {
        return []; // Pour le web, les images sont stockées en base64
      }

      final directory = await _getImagesDirectory();
      final categoriesDir = Directory(path.join(directory.path, _categoriesFolder));
      
      if (!await categoriesDir.exists()) {
        return [];
      }

      final files = await categoriesDir.list().toList();
      return files
          .where((file) => file is File)
          .map((file) => file.path)
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Copier une image depuis un chemin vers le stockage local
  static Future<String?> copyImageToLocal(String sourcePath, String entityId, String type) async {
    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        return null;
      }

      if (type == 'product') {
        return await saveProductImage(sourceFile, entityId);
      } else if (type == 'category') {
        return await saveCategoryImage(sourceFile, entityId);
      }
      
      return null;
    } catch (e) {
      print('Erreur lors de la copie de l\'image: $e');
      return null;
    }
  }
}

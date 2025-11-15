import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'local_storage_service.dart';


/// Service pour réinitialiser complètement les données d'un utilisateur
class UserResetService {
  static UserResetService? _instance;
  static UserResetService get instance => _instance ??= UserResetService._();
  UserResetService._();

  final LocalStorageService _localStorage = LocalStorageService.instance;
  // LocalImageService est statique, pas besoin d'instance

  /// Supprimer toutes les données d'un utilisateur et le remettre comme nouveau
  Future<bool> resetUserData({
    required String userId,
    bool keepSettings = false,
    bool keepImages = false,
  }) async {
    try {
      print('🔄 Début de la réinitialisation des données utilisateur: $userId');

      // 1. Supprimer toutes les boxes Hive de l'utilisateur
      await _deleteUserHiveBoxes(userId);

      // 2. Supprimer les images de l'utilisateur (optionnel)
      if (!keepImages) {
        await _deleteUserImages(userId);
      }

      // 3. Supprimer les préférences partagées de l'utilisateur (optionnel)
      if (!keepSettings) {
        await _deleteUserPreferences(userId);
      }

      // 4. Réinitialiser le stockage local pour cet utilisateur
      await _localStorage.initialize(userId: userId);

      print('✅ Réinitialisation terminée avec succès pour l\'utilisateur: $userId');
      return true;
    } catch (e) {
      print('❌ Erreur lors de la réinitialisation: $e');
      return false;
    }
  }

  /// Supprimer toutes les boxes Hive d'un utilisateur
  Future<void> _deleteUserHiveBoxes(String userId) async {
    try {
      final userPrefix = '${userId}_';
      final boxNames = [
        '${userPrefix}products',
        '${userPrefix}categories',
        '${userPrefix}clients',
        '${userPrefix}suppliers',
        '${userPrefix}invoices',
        '${userPrefix}expenses',
        '${userPrefix}settings',
        '${userPrefix}credits',
        '${userPrefix}credit_payments',
        '${userPrefix}revenues',
      ];

      for (final boxName in boxNames) {
        try {
          // Fermer la box si elle est ouverte
          if (Hive.isBoxOpen(boxName)) {
            await Hive.box(boxName).close();
          }
          
          // Supprimer la box
          await Hive.deleteBoxFromDisk(boxName);
          print('🗑️ Box supprimée: $boxName');
        } catch (e) {
          print('⚠️ Erreur suppression box $boxName: $e');
        }
      }
    } catch (e) {
      print('❌ Erreur suppression boxes Hive: $e');
    }
  }

  /// Supprimer toutes les images d'un utilisateur
  Future<void> _deleteUserImages(String userId) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final userImagesDir = Directory('${appDir.path}/images/$userId');
      
      if (await userImagesDir.exists()) {
        await userImagesDir.delete(recursive: true);
        print('🗑️ Dossier images utilisateur supprimé: ${userImagesDir.path}');
      }

      // Supprimer aussi les images de produits
      final productImagesDir = Directory('${appDir.path}/product_images/$userId');
      if (await productImagesDir.exists()) {
        await productImagesDir.delete(recursive: true);
        print('🗑️ Dossier images produits supprimé: ${productImagesDir.path}');
      }

      // Supprimer les images de factures
      final invoiceImagesDir = Directory('${appDir.path}/invoice_images/$userId');
      if (await invoiceImagesDir.exists()) {
        await invoiceImagesDir.delete(recursive: true);
        print('🗑️ Dossier images factures supprimé: ${invoiceImagesDir.path}');
      }
    } catch (e) {
      print('❌ Erreur suppression images: $e');
    }
  }

  /// Supprimer les préférences partagées spécifiques à l'utilisateur
  Future<void> _deleteUserPreferences(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      // Supprimer toutes les clés qui contiennent l'ID utilisateur
      for (final key in keys) {
        if (key.contains(userId)) {
          await prefs.remove(key);
          print('🗑️ Préférence supprimée: $key');
        }
      }
    } catch (e) {
      print('❌ Erreur suppression préférences: $e');
    }
  }

  /// Obtenir la taille des données d'un utilisateur
  Future<Map<String, dynamic>> getUserDataSize(String userId) async {
    try {
      int totalSize = 0;
      int fileCount = 0;
      Map<String, int> breakdown = {};

      // Taille des boxes Hive
      final appDir = await getApplicationDocumentsDirectory();
      final hiveDir = Directory('${appDir.path}');
      
      if (await hiveDir.exists()) {
        final userPrefix = '${userId}_';
        await for (final entity in hiveDir.list()) {
          if (entity is File && entity.path.contains(userPrefix)) {
            final size = await entity.length();
            totalSize += size;
            fileCount++;
            
            final fileName = entity.path.split('/').last;
            breakdown[fileName] = size;
          }
        }
      }

      // Taille des images
      final userImagesDir = Directory('${appDir.path}/images/$userId');
      if (await userImagesDir.exists()) {
        await for (final entity in userImagesDir.list(recursive: true)) {
          if (entity is File) {
            final size = await entity.length();
            totalSize += size;
            fileCount++;
          }
        }
      }

      return {
        'totalSize': totalSize,
        'fileCount': fileCount,
        'breakdown': breakdown,
        'formattedSize': _formatBytes(totalSize),
      };
    } catch (e) {
      print('❌ Erreur calcul taille données: $e');
      return {
        'totalSize': 0,
        'fileCount': 0,
        'breakdown': {},
        'formattedSize': '0 B',
      };
    }
  }

  /// Formater la taille en bytes en format lisible
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Vérifier si un utilisateur a des données
  Future<bool> userHasData(String userId) async {
    try {
      final dataSize = await getUserDataSize(userId);
      return dataSize['totalSize'] > 0;
    } catch (e) {
      return false;
    }
  }

  /// Créer une sauvegarde avant réinitialisation
  Future<String?> createBackupBeforeReset(String userId) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${appDir.path}/backups');
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final backupPath = '${backupDir.path}/backup_${userId}_$timestamp.json';

      // Exporter toutes les données
      final data = _localStorage.exportAllData();
      final file = File(backupPath);
      await file.writeAsString(data.toString());

      print('💾 Sauvegarde créée: $backupPath');
      return backupPath;
    } catch (e) {
      print('❌ Erreur création sauvegarde: $e');
      return null;
    }
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'local_storage_service.dart';

/// Service pour la sauvegarde et restauration des données
class BackupService {
  static BackupService? _instance;
  static BackupService get instance => _instance ??= BackupService._();
  BackupService._();

  final LocalStorageService _localStorage = LocalStorageService.instance;

  /// Créer une sauvegarde complète des données
  Future<String?> createBackup({String? customFileName}) async {
    try {
      print('💾 Création de la sauvegarde...');

      // Exporter toutes les données
      final allData = _localStorage.exportAllData();
      
      // Ajouter des métadonnées
      final backupData = {
        'app_name': 'DSTORE',
        'backup_version': '1.0',
        'created_at': DateTime.now().toIso8601String(),
        'device_info': await _getDeviceInfo(),
        'data': allData,
      };

      // Convertir en JSON
      final jsonData = jsonEncode(backupData);

      // Nom du fichier
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = customFileName ?? 'DSTORE_Backup_$timestamp.json';

      // Obtenir le répertoire de sauvegarde
      final directory = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${directory.path}/backups');
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      // Créer le fichier
      final file = File('${backupDir.path}/$fileName');
      await file.writeAsString(jsonData);

      print('✅ Sauvegarde créée: ${file.path}');
      return file.path;
    } catch (e) {
      print('❌ Erreur création sauvegarde: $e');
      return null;
    }
  }

  /// Télécharger une sauvegarde (pour transfert vers autre appareil)
  Future<String?> downloadBackup() async {
    try {
      final backupPath = await createBackup();
      if (backupPath == null) return null;

      // Copier vers le dossier de téléchargements
      final downloadsPath = await _getDownloadsPath();
      if (downloadsPath == null) {
        // Si pas d'accès aux téléchargements, utiliser le partage
        return await _shareBackupFile(backupPath);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'DSTORE_Backup_$timestamp.json';
      final downloadFile = File('$downloadsPath/$fileName');

      final originalFile = File(backupPath);
      await originalFile.copy(downloadFile.path);

      print('✅ Sauvegarde téléchargée: ${downloadFile.path}');
      return downloadFile.path;
    } catch (e) {
      print('❌ Erreur téléchargement sauvegarde: $e');
      return null;
    }
  }

  /// Partager une sauvegarde
  Future<String?> shareBackup() async {
    try {
      final backupPath = await createBackup();
      if (backupPath == null) return null;

      return await _shareBackupFile(backupPath);
    } catch (e) {
      print('❌ Erreur partage sauvegarde: $e');
      return null;
    }
  }

  /// Partager un fichier de sauvegarde
  Future<String?> _shareBackupFile(String backupPath) async {
    try {
      final file = XFile(backupPath);
      await Share.shareXFiles(
        [file],
        text: 'Sauvegarde DSTORE - ${DateTime.now().toString()}',
        subject: 'Sauvegarde DSTORE - Importez ce fichier sur votre nouvel appareil',
      );

      return backupPath;
    } catch (e) {
      print('❌ Erreur partage fichier: $e');
      return null;
    }
  }

  /// Lister les sauvegardes locales
  Future<List<Map<String, dynamic>>> listLocalBackups() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${directory.path}/backups');
      
      if (!await backupDir.exists()) {
        return [];
      }

      final backups = <Map<String, dynamic>>[];
      
      await for (final entity in backupDir.list()) {
        if (entity is File && entity.path.endsWith('.json')) {
          final stat = await entity.stat();
          final fileName = entity.path.split('/').last;
          
          backups.add({
            'path': entity.path,
            'name': fileName,
            'size': stat.size,
            'created': stat.modified,
            'formattedSize': _formatBytes(stat.size),
          });
        }
      }

      // Trier par date de création (plus récent en premier)
      backups.sort((a, b) => b['created'].compareTo(a['created']));
      
      return backups;
    } catch (e) {
      print('❌ Erreur listage sauvegardes: $e');
      return [];
    }
  }

  /// Restaurer depuis un fichier de sauvegarde
  Future<bool> restoreFromFile(String filePath) async {
    try {
      print('📥 Restauration depuis: $filePath');

      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Fichier de sauvegarde introuvable');
      }

      // Lire le contenu
      final jsonString = await file.readAsString();
      final backupData = jsonDecode(jsonString) as Map<String, dynamic>;

      // Vérifier la validité
      if (!_isValidBackup(backupData)) {
        throw Exception('Fichier de sauvegarde invalide');
      }

      // Créer une sauvegarde locale avant restauration
      await createBackup(customFileName: 'backup_before_restore_${DateTime.now().millisecondsSinceEpoch}.json');

      // Restaurer les données
      await _restoreData(backupData['data']);

      print('✅ Restauration réussie');
      return true;
    } catch (e) {
      print('❌ Erreur restauration: $e');
      return false;
    }
  }

  /// Rechercher les sauvegardes dans le dossier de téléchargements
  Future<List<Map<String, dynamic>>> findDownloadedBackups() async {
    try {
      final downloadsPath = await _getDownloadsPath();
      if (downloadsPath == null) return [];

      final downloadsDir = Directory(downloadsPath);
      if (!await downloadsDir.exists()) return [];

      final backups = <Map<String, dynamic>>[];

      await for (final entity in downloadsDir.list()) {
        if (entity is File &&
            entity.path.contains('DSTORE_Backup') &&
            entity.path.endsWith('.json')) {

          final stat = await entity.stat();
          final fileName = entity.path.split('/').last;

          backups.add({
            'path': entity.path,
            'name': fileName,
            'size': stat.size,
            'created': stat.modified,
            'formattedSize': _formatBytes(stat.size),
            'source': 'Téléchargements',
          });
        }
      }

      // Trier par date de création (plus récent en premier)
      backups.sort((a, b) => b['created'].compareTo(a['created']));

      return backups;
    } catch (e) {
      print('❌ Erreur recherche téléchargements: $e');
      return [];
    }
  }

  /// Importer une sauvegarde depuis un fichier externe
  Future<bool> importBackup() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
        dialogTitle: 'Sélectionner un fichier de sauvegarde DSTORE',
      );

      if (result == null || result.files.isEmpty) {
        return false;
      }

      final file = result.files.first;
      if (file.path == null) {
        throw Exception('Chemin du fichier invalide');
      }

      return await restoreFromFile(file.path!);
    } catch (e) {
      print('❌ Erreur import sauvegarde: $e');
      return false;
    }
  }

  /// Importer automatiquement depuis les téléchargements
  Future<bool> importFromDownloads() async {
    try {
      final downloadedBackups = await findDownloadedBackups();
      if (downloadedBackups.isEmpty) {
        throw Exception('Aucune sauvegarde trouvée dans les téléchargements');
      }

      // Prendre la sauvegarde la plus récente
      final latestBackup = downloadedBackups.first;
      return await restoreFromFile(latestBackup['path']);
    } catch (e) {
      print('❌ Erreur import depuis téléchargements: $e');
      return false;
    }
  }

  /// Supprimer une sauvegarde locale
  Future<bool> deleteBackup(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        print('✅ Sauvegarde supprimée: $filePath');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Erreur suppression sauvegarde: $e');
      return false;
    }
  }

  /// Vérifier si une sauvegarde est valide
  bool _isValidBackup(Map<String, dynamic> backupData) {
    return backupData.containsKey('app_name') &&
           backupData['app_name'] == 'DSTORE' &&
           backupData.containsKey('data');
  }

  /// Restaurer les données dans le stockage local
  Future<void> _restoreData(Map<String, dynamic> data) async {
    try {
      print('🔄 Début de la restauration des données...');
      
      // Effacer toutes les données actuelles
      await _localStorage.clearAllData();
      
      // Restaurer les produits
      if (data.containsKey('products') && data['products'] is List) {
        for (final product in data['products']) {
          try {
            await _localStorage.saveProduct(Map<String, dynamic>.from(product));
          } catch (e) {
            print('⚠️ Erreur restauration produit: $e');
          }
        }
        print('✅ ${data['products'].length} produits restaurés');
      }
      
      // Restaurer les catégories
      if (data.containsKey('categories') && data['categories'] is List) {
        for (final category in data['categories']) {
          try {
            await _localStorage.saveCategory(Map<String, dynamic>.from(category));
          } catch (e) {
            print('⚠️ Erreur restauration catégorie: $e');
          }
        }
        print('✅ ${data['categories'].length} catégories restaurées');
      }
      
      // Restaurer les clients
      if (data.containsKey('clients') && data['clients'] is List) {
        for (final client in data['clients']) {
          try {
            await _localStorage.saveClient(Map<String, dynamic>.from(client));
          } catch (e) {
            print('⚠️ Erreur restauration client: $e');
          }
        }
        print('✅ ${data['clients'].length} clients restaurés');
      }
      
      // Restaurer les fournisseurs
      if (data.containsKey('suppliers') && data['suppliers'] is List) {
        for (final supplier in data['suppliers']) {
          try {
            await _localStorage.saveSupplier(Map<String, dynamic>.from(supplier));
          } catch (e) {
            print('⚠️ Erreur restauration fournisseur: $e');
          }
        }
        print('✅ ${data['suppliers'].length} fournisseurs restaurés');
      }
      
      // Restaurer les factures
      if (data.containsKey('invoices') && data['invoices'] is List) {
        for (final invoice in data['invoices']) {
          try {
            await _localStorage.saveInvoice(Map<String, dynamic>.from(invoice));
          } catch (e) {
            print('⚠️ Erreur restauration facture: $e');
          }
        }
        print('✅ ${data['invoices'].length} factures restaurées');
      }
      
      // Restaurer les dépenses
      if (data.containsKey('expenses') && data['expenses'] is List) {
        for (final expense in data['expenses']) {
          try {
            await _localStorage.saveExpense(Map<String, dynamic>.from(expense));
          } catch (e) {
            print('⚠️ Erreur restauration dépense: $e');
          }
        }
        print('✅ ${data['expenses'].length} dépenses restaurées');
      }
      
      // Restaurer les crédits
      if (data.containsKey('credits') && data['credits'] is List) {
        for (final credit in data['credits']) {
          try {
            await _localStorage.saveCredit(Map<String, dynamic>.from(credit));
          } catch (e) {
            print('⚠️ Erreur restauration crédit: $e');
          }
        }
        print('✅ ${data['credits'].length} crédits restaurés');
      }
      
      // Restaurer les paiements de crédit
      if (data.containsKey('creditPayments') && data['creditPayments'] is List) {
        for (final payment in data['creditPayments']) {
          try {
            await _localStorage.saveCreditPayment(Map<String, dynamic>.from(payment));
          } catch (e) {
            print('⚠️ Erreur restauration paiement crédit: $e');
          }
        }
        print('✅ ${data['creditPayments'].length} paiements de crédit restaurés');
      }
      
      // Restaurer les revenus
      if (data.containsKey('revenues') && data['revenues'] is List) {
        for (final revenue in data['revenues']) {
          try {
            await _localStorage.saveRevenue(Map<String, dynamic>.from(revenue));
          } catch (e) {
            print('⚠️ Erreur restauration revenu: $e');
          }
        }
        print('✅ ${data['revenues'].length} revenus restaurés');
      }
      
      print('✅ Restauration complète terminée avec succès');
    } catch (e) {
      print('❌ Erreur lors de la restauration: $e');
      throw e;
    }
  }

  /// Obtenir les informations de l'appareil
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    return {
      'platform': kIsWeb ? 'web' : Platform.operatingSystem,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Obtenir le chemin du dossier de téléchargements
  Future<String?> _getDownloadsPath() async {
    try {
      if (kIsWeb) return null;

      if (Platform.isAndroid) {
        // Pour Android, utiliser le dossier Downloads public
        return '/storage/emulated/0/Download';
      } else if (Platform.isIOS) {
        // Pour iOS, utiliser le dossier Documents de l'app
        final directory = await getApplicationDocumentsDirectory();
        return directory.path;
      } else {
        // Pour autres plateformes, utiliser le dossier Downloads
        final directory = await getDownloadsDirectory();
        return directory?.path;
      }
    } catch (e) {
      print('❌ Erreur accès dossier téléchargements: $e');
      return null;
    }
  }

  /// Obtenir tous les fichiers de sauvegarde (locaux + téléchargements)
  Future<List<Map<String, dynamic>>> getAllBackups() async {
    try {
      final localBackups = await listLocalBackups();
      final downloadedBackups = await findDownloadedBackups();

      // Marquer la source
      for (final backup in localBackups) {
        backup['source'] = 'Local';
      }

      // Combiner et trier par date
      final allBackups = [...localBackups, ...downloadedBackups];
      allBackups.sort((a, b) => b['created'].compareTo(a['created']));

      return allBackups;
    } catch (e) {
      print('❌ Erreur récupération toutes sauvegardes: $e');
      return [];
    }
  }

  /// Formater la taille en bytes
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

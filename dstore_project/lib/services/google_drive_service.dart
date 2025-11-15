import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'local_storage_service.dart';

/// Service pour la sauvegarde et restauration via Google Drive
class GoogleDriveService {
  static GoogleDriveService? _instance;
  static GoogleDriveService get instance => _instance ??= GoogleDriveService._();
  GoogleDriveService._();

  final LocalStorageService _localStorage = LocalStorageService.instance;
  
  // Configuration Google Sign-In
  static const List<String> _scopes = [
    'https://www.googleapis.com/auth/drive.file',
    'https://www.googleapis.com/auth/drive.appdata',
  ];

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: _scopes,
  );

  GoogleSignInAccount? _currentUser;
  drive.DriveApi? _driveApi;

  /// Vérifier si l'utilisateur est connecté à Google
  bool get isSignedIn => _currentUser != null;

  /// Obtenir l'utilisateur actuel
  GoogleSignInAccount? get currentUser => _currentUser;

  /// Se connecter à Google Drive
  Future<bool> signIn() async {
    try {
      print('🔐 Tentative de connexion à Google Drive...');
      
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        print('❌ Connexion annulée par l\'utilisateur');
        return false;
      }

      _currentUser = account;
      
      // Obtenir les credentials pour l'API Drive
      final GoogleSignInAuthentication auth = await account.authentication;
      final credentials = AccessCredentials(
        AccessToken('Bearer', auth.accessToken!, DateTime.now().add(Duration(hours: 1))),
        auth.idToken,
        _scopes,
      );

      // Initialiser l'API Drive
      final client = authenticatedClient(http.Client(), credentials);
      _driveApi = drive.DriveApi(client);

      print('✅ Connexion réussie à Google Drive: ${account.email}');
      return true;
    } catch (e) {
      print('❌ Erreur connexion Google Drive: $e');
      return false;
    }
  }

  /// Se déconnecter de Google Drive
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      _currentUser = null;
      _driveApi = null;
      print('✅ Déconnexion de Google Drive réussie');
    } catch (e) {
      print('❌ Erreur déconnexion Google Drive: $e');
    }
  }

  /// Sauvegarder toutes les données sur Google Drive
  Future<String?> backupToGoogleDrive({String? customFileName}) async {
    try {
      if (!isSignedIn || _driveApi == null) {
        throw Exception('Non connecté à Google Drive');
      }

      print('💾 Début de la sauvegarde sur Google Drive...');

      // Exporter toutes les données
      final allData = _localStorage.exportAllData();
      
      // Ajouter des métadonnées
      final backupData = {
        'app_name': 'DSTORE',
        'backup_version': '1.0',
        'created_at': DateTime.now().toIso8601String(),
        'user_email': _currentUser?.email,
        'device_info': await _getDeviceInfo(),
        'data': allData,
      };

      // Convertir en JSON
      final jsonData = jsonEncode(backupData);
      final bytes = utf8.encode(jsonData);

      // Nom du fichier
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = customFileName ?? 'DSTORE_Backup_$timestamp.json';

      // Créer le fichier sur Google Drive
      final driveFile = drive.File()
        ..name = fileName
        ..description = 'Sauvegarde DSTORE - ${DateTime.now().toString()}'
        ..parents = ['appDataFolder']; // Dossier privé de l'app

      final media = drive.Media(Stream.fromIterable([bytes]), bytes.length);
      
      final result = await _driveApi!.files.create(
        driveFile,
        uploadMedia: media,
      );

      print('✅ Sauvegarde réussie sur Google Drive: ${result.id}');
      return result.id;
    } catch (e) {
      print('❌ Erreur sauvegarde Google Drive: $e');
      return null;
    }
  }

  /// Lister les sauvegardes disponibles sur Google Drive
  Future<List<Map<String, dynamic>>> listBackups() async {
    try {
      if (!isSignedIn || _driveApi == null) {
        throw Exception('Non connecté à Google Drive');
      }

      print('📋 Recherche des sauvegardes sur Google Drive...');

      final response = await _driveApi!.files.list(
        q: "parents in 'appDataFolder' and name contains 'DSTORE_Backup'",
        orderBy: 'createdTime desc',
        spaces: 'appDataFolder',
      );

      final backups = <Map<String, dynamic>>[];
      
      for (final file in response.files ?? []) {
        backups.add({
          'id': file.id,
          'name': file.name,
          'size': file.size,
          'createdTime': file.createdTime,
          'modifiedTime': file.modifiedTime,
          'description': file.description,
        });
      }

      print('✅ ${backups.length} sauvegardes trouvées');
      return backups;
    } catch (e) {
      print('❌ Erreur listage sauvegardes: $e');
      return [];
    }
  }

  /// Restaurer les données depuis Google Drive
  Future<bool> restoreFromGoogleDrive(String fileId) async {
    try {
      if (!isSignedIn || _driveApi == null) {
        throw Exception('Non connecté à Google Drive');
      }

      print('📥 Début de la restauration depuis Google Drive...');

      // Télécharger le fichier
      final response = await _driveApi!.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      // Lire le contenu
      final bytes = <int>[];
      await for (final chunk in response.stream) {
        bytes.addAll(chunk);
      }

      final jsonString = utf8.decode(bytes);
      final backupData = jsonDecode(jsonString) as Map<String, dynamic>;

      // Vérifier la validité de la sauvegarde
      if (!_isValidBackup(backupData)) {
        throw Exception('Fichier de sauvegarde invalide');
      }

      // Créer une sauvegarde locale avant restauration
      await _createLocalBackup();

      // Restaurer les données
      await _restoreData(backupData['data']);

      print('✅ Restauration réussie depuis Google Drive');
      return true;
    } catch (e) {
      print('❌ Erreur restauration Google Drive: $e');
      return false;
    }
  }

  /// Supprimer une sauvegarde de Google Drive
  Future<bool> deleteBackup(String fileId) async {
    try {
      if (!isSignedIn || _driveApi == null) {
        throw Exception('Non connecté à Google Drive');
      }

      await _driveApi!.files.delete(fileId);
      print('✅ Sauvegarde supprimée de Google Drive');
      return true;
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

  /// Créer une sauvegarde locale avant restauration
  Future<void> _createLocalBackup() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${appDir.path}/local_backups');
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final backupFile = File('${backupDir.path}/backup_before_restore_$timestamp.json');
      
      final data = _localStorage.exportAllData();
      await backupFile.writeAsString(jsonEncode(data));
      
      print('💾 Sauvegarde locale créée avant restauration');
    } catch (e) {
      print('⚠️ Erreur création sauvegarde locale: $e');
    }
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

      // Restaurer les paramètres
      if (data.containsKey('settings') && data['settings'] is List) {
        for (final setting in data['settings']) {
          try {
            await _localStorage.saveSetting(
              setting['key'],
              setting['value']
            );
          } catch (e) {
            print('⚠️ Erreur restauration paramètre: $e');
          }
        }
        print('✅ ${data['settings'].length} paramètres restaurés');
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
}

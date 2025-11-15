import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/device_model.dart';
import '../services/device_service.dart';
import '../services/local_storage_service.dart';

class AccountDeviceService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Obtenir tous les comptes qui ont été utilisés sur cet appareil
  static Future<List<Map<String, dynamic>>> getAccountsOnCurrentDevice() async {
    try {
      final currentDeviceId = await DeviceService.getCurrentDeviceId();
      
      // Récupérer tous les appareils avec ce device_id
      final response = await _supabase
          .from('user_devices')
          .select('user_id, device_name, last_login_at, is_authorized, created_at')
          .eq('device_id', currentDeviceId)
          .order('last_login_at', ascending: false);

      // Convertir en format attendu avec des infos basiques
      return (response as List).map((item) {
        final userId = item['user_id'] as String;
        return {
          'user_id': userId,
          'email': 'Utilisateur ${userId.substring(0, 8)}', // ID court pour l'affichage
          'user_name': 'Compte ${userId.substring(0, 8)}',
          'last_login_at': DateTime.parse(item['last_login_at']),
          'is_authorized': item['is_authorized'],
          'created_at': DateTime.parse(item['created_at']),
        };
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération des comptes: $e');
      return [];
    }
  }

  /// Supprimer un compte spécifique de cet appareil
  static Future<bool> removeAccountFromCurrentDevice(String userId) async {
    try {
      final currentDeviceId = await DeviceService.getCurrentDeviceId();
      
      // Supprimer l'enregistrement de l'appareil pour cet utilisateur
      await _supabase
          .from('user_devices')
          .delete()
          .eq('user_id', userId)
          .eq('device_id', currentDeviceId);

      // Nettoyer le stockage local pour cet utilisateur
      await _clearLocalDataForUser(userId);

      return true;
    } catch (e) {
      print('Erreur lors de la suppression du compte: $e');
      return false;
    }
  }

  /// Supprimer tous les comptes de cet appareil
  static Future<bool> removeAllAccountsFromCurrentDevice() async {
    try {
      final currentDeviceId = await DeviceService.getCurrentDeviceId();
      
      // Récupérer tous les user_ids pour cet appareil
      final accounts = await getAccountsOnCurrentDevice();
      
      // Supprimer tous les enregistrements
      await _supabase
          .from('user_devices')
          .delete()
          .eq('device_id', currentDeviceId);

      // Nettoyer le stockage local pour tous les utilisateurs
      for (final account in accounts) {
        await _clearLocalDataForUser(account['user_id']);
      }

      // Nettoyer le stockage local général
      await LocalStorageService.clearAll();

      return true;
    } catch (e) {
      print('Erreur lors de la suppression de tous les comptes: $e');
      return false;
    }
  }

  /// Vérifier si un compte est autorisé sur cet appareil
  static Future<bool> isAccountAuthorizedOnCurrentDevice(String userId) async {
    try {
      final currentDeviceId = await DeviceService.getCurrentDeviceId();
      
      final response = await _supabase
          .from('user_devices')
          .select('is_authorized')
          .eq('user_id', userId)
          .eq('device_id', currentDeviceId)
          .maybeSingle();

      return response?['is_authorized'] as bool? ?? false;
    } catch (e) {
      print('Erreur lors de la vérification de l\'autorisation: $e');
      return false;
    }
  }

  /// Obtenir les informations d'un compte sur cet appareil
  static Future<Map<String, dynamic>?> getAccountInfoOnCurrentDevice(String userId) async {
    try {
      final currentDeviceId = await DeviceService.getCurrentDeviceId();
      
      final response = await _supabase
          .from('user_devices')
          .select('user_id, device_name, last_login_at, is_authorized, first_login_at, created_at')
          .eq('user_id', userId)
          .eq('device_id', currentDeviceId)
          .maybeSingle();

      if (response == null) return null;

      return {
        'user_id': response['user_id'],
        'email': 'Utilisateur ${userId.substring(0, 8)}',
        'user_name': 'Compte ${userId.substring(0, 8)}',
        'last_login_at': DateTime.parse(response['last_login_at']),
        'first_login_at': DateTime.parse(response['first_login_at']),
        'is_authorized': response['is_authorized'],
        'created_at': DateTime.parse(response['created_at']),
      };
    } catch (e) {
      print('Erreur lors de la récupération des infos du compte: $e');
      return null;
    }
  }

  /// Obtenir le nombre de comptes sur cet appareil
  static Future<Map<String, int>> getAccountStatsOnCurrentDevice() async {
    try {
      final accounts = await getAccountsOnCurrentDevice();
      
      return {
        'total': accounts.length,
        'authorized': accounts.where((a) => a['is_authorized'] == true).length,
        'unauthorized': accounts.where((a) => a['is_authorized'] == false).length,
      };
    } catch (e) {
      print('Erreur lors de la récupération des statistiques: $e');
      return {'total': 0, 'authorized': 0, 'unauthorized': 0};
    }
  }

  /// Déconnecter un compte spécifique (sans le supprimer)
  static Future<bool> logoutAccountFromCurrentDevice(String userId) async {
    try {
      // Nettoyer seulement les données de session locale
      await _clearLocalSessionForUser(userId);
      return true;
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
      return false;
    }
  }

  /// Obtenir le dernier compte utilisé sur cet appareil
  static Future<Map<String, dynamic>?> getLastUsedAccount() async {
    try {
      final accounts = await getAccountsOnCurrentDevice();
      if (accounts.isEmpty) return null;
      
      // Le premier compte est le plus récemment utilisé (tri par last_login_at desc)
      return accounts.first;
    } catch (e) {
      print('Erreur lors de la récupération du dernier compte: $e');
      return null;
    }
  }

  /// Marquer un compte comme utilisé récemment
  static Future<void> updateLastLoginForAccount(String userId) async {
    try {
      final currentDeviceId = await DeviceService.getCurrentDeviceId();
      
      await _supabase
          .from('user_devices')
          .update({
            'last_login_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .eq('device_id', currentDeviceId);
    } catch (e) {
      print('Erreur lors de la mise à jour de la dernière connexion: $e');
    }
  }

  /// Nettoyer les données locales pour un utilisateur spécifique
  static Future<void> _clearLocalDataForUser(String userId) async {
    try {
      // Nettoyer les données spécifiques à l'utilisateur
      await LocalStorageService.clearUserData(userId);
    } catch (e) {
      print('Erreur lors du nettoyage des données locales: $e');
    }
  }

  /// Nettoyer seulement la session locale pour un utilisateur
  static Future<void> _clearLocalSessionForUser(String userId) async {
    try {
      // Nettoyer seulement les données de session (tokens, etc.)
      await LocalStorageService.clearUserSession(userId);
    } catch (e) {
      print('Erreur lors du nettoyage de la session: $e');
    }
  }

  /// Vérifier si cet appareil a des comptes enregistrés
  static Future<bool> hasAccountsOnCurrentDevice() async {
    try {
      final accounts = await getAccountsOnCurrentDevice();
      return accounts.isNotEmpty;
    } catch (e) {
      print('Erreur lors de la vérification des comptes: $e');
      return false;
    }
  }

  /// Obtenir les comptes autorisés uniquement
  static Future<List<Map<String, dynamic>>> getAuthorizedAccountsOnCurrentDevice() async {
    try {
      final allAccounts = await getAccountsOnCurrentDevice();
      return allAccounts.where((account) => account['is_authorized'] == true).toList();
    } catch (e) {
      print('Erreur lors de la récupération des comptes autorisés: $e');
      return [];
    }
  }

  /// Obtenir les comptes non autorisés uniquement
  static Future<List<Map<String, dynamic>>> getUnauthorizedAccountsOnCurrentDevice() async {
    try {
      final allAccounts = await getAccountsOnCurrentDevice();
      return allAccounts.where((account) => account['is_authorized'] == false).toList();
    } catch (e) {
      print('Erreur lors de la récupération des comptes non autorisés: $e');
      return [];
    }
  }

  /// Nettoyer les comptes inactifs (plus de X jours)
  static Future<int> cleanupInactiveAccounts({int inactiveDays = 30}) async {
    try {
      final currentDeviceId = await DeviceService.getCurrentDeviceId();
      final cutoffDate = DateTime.now().subtract(Duration(days: inactiveDays));
      
      // Récupérer les comptes inactifs
      final inactiveAccounts = await _supabase
          .from('user_devices')
          .select('user_id')
          .eq('device_id', currentDeviceId)
          .lt('last_login_at', cutoffDate.toIso8601String());

      final count = (inactiveAccounts as List).length;

      // Supprimer les comptes inactifs
      await _supabase
          .from('user_devices')
          .delete()
          .eq('device_id', currentDeviceId)
          .lt('last_login_at', cutoffDate.toIso8601String());

      // Nettoyer les données locales pour ces comptes
      for (final account in inactiveAccounts) {
        await _clearLocalDataForUser(account['user_id']);
      }

      return count;
    } catch (e) {
      print('Erreur lors du nettoyage des comptes inactifs: $e');
      return 0;
    }
  }
}

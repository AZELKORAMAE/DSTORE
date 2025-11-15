import 'package:supabase_flutter/supabase_flutter.dart';
import 'local_storage_service.dart';

class AdminAuthService {
  AdminAuthService._();
  static final AdminAuthService instance = AdminAuthService._();

  final _supabase = Supabase.instance.client;
  final _localStorage = LocalStorageService.instance;

  // ==================== AUTHENTIFICATION ADMIN ====================

  /// Connexion admin avec email/mot de passe (via RPC)
  Future<Map<String, dynamic>?> signInAdmin(String email, String password) async {
    try {
      final response = await _supabase.rpc('verify_admin_password', params: {
        'input_email': email,
        'input_password': password,
      });

      if (response != null && response is List && response.isNotEmpty) {
        final adminData = response[0] as Map<String, dynamic>;

        // Sauvegarder la session admin localement (7 jours)
        await _localStorage.saveSetting('admin_session', {
          'admin_id': adminData['admin_id'],
          'email': adminData['email'],
          'full_name': adminData['full_name'],
          'is_super_admin': adminData['is_super_admin'],
          'login_time': DateTime.now().toIso8601String(),
        });

        return adminData;
      }
      return null;
    } catch (e) {
      print('❌ Erreur connexion admin: $e');
      return null;
    }
  }

  /// Vérifie si un admin est connecté (session locale < 7 jours)
  bool isAdminLoggedIn() {
    final session = _localStorage.getSetting<Map<String, dynamic>>('admin_session');
    if (session == null) return false;
    final loginTime = DateTime.tryParse(session['login_time'] ?? '');
    if (loginTime == null) return false;
    return DateTime.now().difference(loginTime).inDays < 7;
  }

  Map<String, dynamic>? getAdminInfo() {
    if (!isAdminLoggedIn()) return null;
    return _localStorage.getSetting<Map<String, dynamic>>('admin_session');
  }

  Future<void> signOutAdmin() async {
    await _localStorage.saveSetting('admin_session', null);
  }

  // ==================== GESTION DES UTILISATEURS ====================

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final response = await _supabase.rpc('get_all_users_for_admin');
      return List<Map<String, dynamic>>.from(response ?? []);
    } catch (e) {
      print('❌ Erreur récupération utilisateurs: $e');
      return [];
    }
  }

  Future<bool> activateUser(
    String userId, {
    String subscriptionType = 'basic',
    int subscriptionDays = 30,
  }) async {
    try {
      final response = await _supabase.rpc('update_user_status', params: {
        'target_user_id': userId,
        'new_status': 'active',
        'new_subscription_type': subscriptionType,
        'subscription_days': subscriptionDays,
      });
      return response == true;
    } catch (e) {
      print('❌ Erreur activation utilisateur: $e');
      return false;
    }
  }

  Future<bool> suspendUser(String userId) async {
    try {
      final response = await _supabase.rpc('update_user_status', params: {
        'target_user_id': userId,
        'new_status': 'suspended',
      });
      return response == true;
    } catch (e) {
      print('❌ Erreur suspension utilisateur: $e');
      return false;
    }
  }

  Future<bool> reactivateUser(String userId) async {
    try {
      final response = await _supabase.rpc('update_user_status', params: {
        'target_user_id': userId,
        'new_status': 'active',
      });
      return response == true;
    } catch (e) {
      print('❌ Erreur réactivation utilisateur: $e');
      return false;
    }
  }

  /// Prolonger un abonnement d’un utilisateur
  Future<bool> extendSubscription(String userId, int additionalDays) async {
    try {
      final users = await getAllUsers();
      final user = users.firstWhere((u) => u['user_id'] == userId, orElse: () => {});
      if (user.isEmpty) return false;

      final currentEndDate = user['subscription_end_date'] as String?;
      final baseDate = currentEndDate != null ? DateTime.parse(currentEndDate) : DateTime.now();
      final totalDaysFromNow = baseDate.difference(DateTime.now()).inDays + additionalDays;

      final response = await _supabase.rpc('update_user_status', params: {
        'target_user_id': userId,
        'new_status': 'active',
        'subscription_days': totalDaysFromNow > 0 ? totalDaysFromNow : additionalDays,
      });
      return response == true;
    } catch (e) {
      print('❌ Erreur prolongation abonnement: $e');
      return false;
    }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      final response = await _supabase.rpc('delete_user_admin', params: {
        'target_user_id': userId,
      });
      return response == true;
    } catch (e) {
      print('❌ Erreur suppression utilisateur: $e');
      return false;
    }
  }

  Future<bool> updateUser(
    String userId, {
    String? email,
    String? fullName,
    String? businessName,
  }) async {
    try {
      final response = await _supabase.rpc('update_user_info_admin', params: {
        'target_user_id': userId,
        'new_email': email,
        'new_full_name': fullName,
        'new_business_name': businessName,
      });
      return response == true;
    } catch (e) {
      print('❌ Erreur modification utilisateur: $e');
      return false;
    }
  }

  // ==================== STATISTIQUES ====================

  Future<Map<String, dynamic>> getAdminStats() async {
    try {
      final response = await _supabase.from('admin_stats').select().single();
      return Map<String, dynamic>.from(response);
    } catch (e) {
      print('❌ Erreur récupération statistiques: $e');
      return {};
    }
  }

  // ==================== APPAREILS ====================

  Future<List<Map<String, dynamic>>> getAllUserDevices() async {
    try {
      final response = await _supabase
          .from('user_devices')
          .select('*')
          .order('last_login_at', ascending: false);
      return List<Map<String, dynamic>>.from(response ?? []);
    } catch (e) {
      print('❌ Erreur récupération appareils: $e');
      return [];
    }
  }

  /// Comptes + appareils (RPC si dispo, sinon fallback)
  Future<List<Map<String, dynamic>>> getAccountsWithDevices() async {
    try {
      // 1) RPC (contourne RLS si configuré)
      try {
        final result = await _supabase.rpc('get_all_accounts_with_devices');
        if (result != null && result is List) {
          return List<Map<String, dynamic>>.from(result);
        }
      } catch (rpcError) {
        print('⚠️ RPC get_all_accounts_with_devices échoué: $rpcError');
      }

      // 2) Fallback manuel
      final users = await getAllUsers();
      final accountsWithDevices = <Map<String, dynamic>>[];

      for (final user in users) {
        final userId = user['user_id'] as String;
        final email = user['email'] as String;

        try {
          final devicesResponse = await _supabase
              .from('user_devices')
              .select('*')
              .eq('user_id', userId)
              .order('last_login_at', ascending: false);

          final devices = List<Map<String, dynamic>>.from(devicesResponse ?? []);
          accountsWithDevices.add({
            'user_id': userId,
            'email': email,
            'subscription_status': user['subscription_status'] ?? 'active',
            'subscription_type': user['subscription_type'] ?? 'basic',
            'subscription_end_date': user['subscription_end_date'],
            'created_at': user['created_at'],
            'devices': devices,
          });
        } catch (_) {
          accountsWithDevices.add({
            'user_id': userId,
            'email': email,
            'subscription_status': user['subscription_status'] ?? 'active',
            'subscription_type': user['subscription_type'] ?? 'basic',
            'subscription_end_date': user['subscription_end_date'],
            'created_at': user['created_at'],
            'devices': <Map<String, dynamic>>[],
          });
        }
      }
      return accountsWithDevices;
    } catch (e) {
      print('❌ Erreur récupération comptes avec appareils: $e');
      return [];
    }
  }

  /// Autoriser un appareil
  Future<bool> authorizeUserDevice(String userId, String deviceId) async {
    try {
      await _supabase
          .from('user_devices')
          .update({
            'is_authorized': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .eq('device_id', deviceId);
    } catch (e) {
      print('❌ Erreur autorisation appareil: $e');
      return false;
    }
    return true;
  }

  /// Révoquer l'autorisation d'un appareil
  Future<bool> revokeUserDevice(String userId, String deviceId) async {
    try {
      await _supabase
          .from('user_devices')
          .update({
            'is_authorized': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .eq('device_id', deviceId);
    } catch (e) {
      print('❌ Erreur révocation appareil: $e');
      return false;
    }
    return true;
  }

  /// Modifier l'autorisation (toggle depuis l'UI)
  Future<bool> updateDeviceAuthorization(String userId, String deviceId, bool isAuthorized) async {
    try {
      await _supabase
          .from('user_devices')
          .update({
            'is_authorized': isAuthorized,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .eq('device_id', deviceId);
      return true;
    } catch (e) {
      print('❌ Erreur modification autorisation: $e');
      return false;
    }
  }

  /// Supprimer un appareil (clé fonctionnelle user_id + device_id)
  Future<bool> removeUserDevice(String userId, String deviceId) async {
    try {
      await _supabase
          .from('user_devices')
          .delete()
          .match({'user_id': userId, 'device_id': deviceId});
      return true;
    } catch (e) {
      print('❌ Erreur suppression appareil: $e');
      return false;
    }
  }

  /// Alias utilisé par l’écran admin (même chose que removeUserDevice)
  Future<bool> deleteDevice(String userId, String deviceId) async {
    return await removeUserDevice(userId, deviceId);
  }

  /// Applique la limite d’appareils autorisés selon le type d’abonnement
  Future<bool> enforceDeviceLimit(String userId) async {
    try {
      final users = await getAllUsers();
      final user = users.firstWhere((u) => u['user_id'] == userId, orElse: () => {});
      if (user.isEmpty) return false;

      final subscriptionType = (user['subscription_type'] ?? 'basic').toString().toLowerCase();
      final deviceLimit = switch (subscriptionType) {
        'basic' => 1,
        'premium' => 2,
        'family' => 4,
        _ => 1,
      };

      final devicesResponse = await _supabase
          .from('user_devices')
          .select('*')
          .eq('user_id', userId)
          .eq('is_authorized', true)
          .order('last_login_at', ascending: false);

      final authorizedDevices = List<Map<String, dynamic>>.from(devicesResponse ?? []);
      if (authorizedDevices.length > deviceLimit) {
        final toRevoke = authorizedDevices.skip(deviceLimit);
        for (final d in toRevoke) {
          await revokeUserDevice(userId, d['device_id'] as String);
        }
      }
      return true;
    } catch (e) {
      print('❌ Erreur application limite appareils: $e');
      return false;
    }
  }

  // ==================== UTILITAIRES ====================

  String formatDate(String? dateStr) {
    if (dateStr == null) return 'Non défini';
    try {
      final date = DateTime.parse(dateStr);
      final dd = date.day.toString().padLeft(2, '0');
      final mm = date.month.toString().padLeft(2, '0');
      final yyyy = date.year.toString();
      return '$dd/$mm/$yyyy';
    } catch (_) {
      return 'Date invalide';
    }
  }

  int getDaysRemaining(String? endDateStr) {
    if (endDateStr == null) return 0;
    try {
      final endDate = DateTime.parse(endDateStr);
      return endDate.difference(DateTime.now()).inDays;
    } catch (_) {
      return 0;
    }
  }

  String getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return '#4CAF50';
      case 'pending':
        return '#FF9800';
      case 'suspended':
        return '#F44336';
      case 'expired':
        return '#9E9E9E';
      default:
        return '#2196F3';
    }
  }

  String getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return '✅';
      case 'pending':
        return '⏳';
      case 'suspended':
        return '⛔';
      case 'expired':
        return '❌';
      default:
        return '❓';
    }
  }
}

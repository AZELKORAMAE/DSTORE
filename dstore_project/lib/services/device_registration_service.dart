
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../services/local_storage_service.dart';
import '../utils/local_storage.dart' as AppLocalStorage;

import 'device_fingerprint_service.dart';
import 'user_device_service.dart';

class DeviceRegistrationService {
  static final DeviceRegistrationService _instance = DeviceRegistrationService._internal();
  factory DeviceRegistrationService() => _instance;
  DeviceRegistrationService._internal();

  static DeviceRegistrationService get instance => _instance;

  final _supabase = Supabase.instance.client;
  final _uuid = const Uuid();
  final LocalStorageService _localStorage = LocalStorageService.instance;

  Future<bool> registerCurrentDevice() async {
    try {
      final userId = await _resolveUserId();
      if (userId == null) {
        print('❌ Aucun identifiant utilisateur disponible pour enregistrer l\'appareil');
        return false;
      }

      await UserDeviceService.instance.registerCurrentDevice(userId);
      await UserDeviceService.instance.assertAuthorized(userId);
      print('✅ Appareil enregistré/actualisé et autorisé');
      return true;
    } on StateError catch (e) {
      final msg = e.toString();
      if (msg.contains('DEVICE_PENDING')) {
        throw Exception('🚫 Pas d\'accès avec cet appareil pour ce compte.\n\nVotre appareil est en attente d\'autorisation.\nContactez l\'administrateur pour autoriser cet appareil.');
      }
      if (msg.contains('DEVICE_SUSPENDED')) {
        throw Exception('🚫 Pas d\'accès avec cet appareil pour ce compte.\n\nVotre appareil a été suspendu par l\'administrateur.\nContactez l\'administrateur pour réactiver l\'accès.');
      }
      rethrow;
    } catch (e) {
      print('❌ Erreur lors de l\'enregistrement de l\'appareil: $e');
      return false;
    }
  }

  Future<bool> isCurrentDeviceAuthorized() async {
    try {
      final userId = await _resolveUserId();
      if (userId == null) return false;
      await UserDeviceService.instance.assertAuthorized(userId);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> checkDeviceAuthorization() async {
    try {
      final userId = await _resolveUserId();
      String? userEmail = _supabase.auth.currentUser?.email;
      if (userId == null) {
        print('❌ DEVICE_AUTH: Aucun utilisateur disponible pour la vérification');
        return false;
      }

      final fp = await DeviceFingerprintService.instance.current();
      print('🔍 DEVICE_AUTH: Vérification pour deviceId=${fp.deviceId} (${fp.platform})');
      print('🔍 DEVICE_AUTH: Utilisateur: ${userEmail ?? 'Inconnu'} ($userId)');

      final row = await _supabase
          .from('user_devices')
          .select('is_authorized, device_name, last_login_at')
          .match({'user_id': userId, 'device_id': fp.deviceId, 'platform': fp.platform})
          .maybeSingle();

      print('📊 DEVICE_AUTH: Réponse base: $row');
      if (row == null) return false;
      final isAuthorized = row['is_authorized'] == true;
      print('📱 DEVICE_AUTH: ${isAuthorized ? "AUTORISÉ" : "SUSPENDU"} • ${row['device_name'] ?? '—'}');
      return isAuthorized;
    } catch (e) {
      print('❌ DEVICE_AUTH: Erreur vérification autorisation: $e');
      return false;
    }
  }

  Future<void> updateLastLogin() async {
    try {
      final userId = await _resolveUserId();
      if (userId == null) return;
      await UserDeviceService.instance.registerCurrentDevice(userId);
      print('✅ Dernière connexion mise à jour');
    } catch (e) {
      print('❌ Erreur mise à jour connexion: $e');
    }
  }

  Future<void> disconnectCurrentDevice() async {
    try {
      final userId = await _resolveUserId();
      if (userId == null) return;
      final fp = await DeviceFingerprintService.instance.current();
      await _supabase
          .from('user_devices')
          .update({'is_current_device': false})
          .match({'user_id': userId, 'device_id': fp.deviceId, 'platform': fp.platform});
      print('📱 Appareil déconnecté (is_current_device=false)');
    } catch (e) {
      print('❌ Erreur déconnexion appareil: $e');
    }
  }

  Future<String> getDeviceId() async {
    final fp = await DeviceFingerprintService.instance.current();
    return fp.deviceId;
  }

  Future<String?> _resolveUserId() async {
    var user = _supabase.auth.currentUser;
    if (user != null) return user.id;
    final info = _localStorage.getUserInfo();
    if (info != null && info['id'] is String) return info['id'] as String;
    return null;
  }
}

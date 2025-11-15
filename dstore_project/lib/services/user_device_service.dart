import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/user_device.dart';
import 'device_fingerprint_service.dart';

/// Service unifié pour gérer les appareils (mobile + desktop + web)
/// Table : public.user_devices
class UserDeviceService {
  UserDeviceService._();
  static final UserDeviceService instance = UserDeviceService._();

  final _sb = Supabase.instance.client;
  static const _table = 'user_devices';

  /// Compte des appareils autorisés (compatible toutes versions)
  Future<int> _authorizedCount(String userId) async {
    final rows = await _sb
        .from(_table)
        .select('id')
        .eq('user_id', userId)
        .eq('is_authorized', true);
    return (rows as List).length;
  }

  /// Enregistre ou met à jour l'appareil courant
  /// - 1er appareil => autorisé
  /// - suivants => en attente (is_authorized=false)
  /// - met à jour last_login_at + is_current_device (les autres passent à false)
  /// - évite les doublons (user_id, device_id, platform)
  Future<UserDevice> registerCurrentDevice(String userId) async {
    final fp = await DeviceFingerprintService.instance.current();
    final nowIso = DateTime.now().toIso8601String();

    // 1) Existe déjà ?
    final existing = await _sb
        .from(_table)
        .select()
        .match({'user_id': userId, 'device_id': fp.deviceId, 'platform': fp.platform})
        .maybeSingle();

    if (existing != null && existing['is_authorized'] == false) {
      throw StateError('DEVICE_SUSPENDED');
    }

    // 2) Un seul "courant" par user
    await _sb.from(_table).update({'is_current_device': false}).eq('user_id', userId);

    if (existing != null) {
      final updated = await _sb
          .from(_table)
          .update({
            'device_name': fp.deviceName,
            'device_type': fp.deviceType,
            'app_version': fp.appVersion,
            'os_version': fp.osVersion,
            'last_login_at': nowIso,
            'is_current_device': true,
            'updated_at': nowIso,
          })
          .eq('id', existing['id'])
          .select()
          .single();

      return UserDevice.fromMap(updated);
    }

    // 3) Nouvel appareil
    final nbAuth = await _authorizedCount(userId);
    final bool authorize = nbAuth == 0;

    final payload = {
      'id': const Uuid().v4(),
      'user_id': userId,
      'device_id': fp.deviceId,
      'device_name': fp.deviceName,
      'device_type': fp.deviceType,  // mobile/desktop/web
      'platform': fp.platform,
      'app_version': fp.appVersion,
      'os_version': fp.osVersion,
      'is_authorized': authorize,
      'is_current_device': true,
      'first_login_at': nowIso,
      'last_login_at': nowIso,
      'created_at': nowIso,
      'updated_at': nowIso,
    };

    Map<String, dynamic> inserted;
    try {
      // upsert si disponible (empêche les doublons s'il y a déjà l'index unique)
      inserted = await _sb
          .from(_table)
          .upsert(payload, onConflict: 'user_id,device_id,platform')
          .select()
          .single();
    } catch (_) {
      // fallback insert classique
      inserted = await _sb.from(_table).insert(payload).select().single();
    }

    final device = UserDevice.fromMap(inserted);

    if (!device.isAuthorized) {
      // on bloque l'accès tant que l'admin n'autorise pas
      throw StateError('DEVICE_PENDING');
    }
    return device;
  }

  /// Vérifie que l'appareil courant est autorisé pour ce user
  Future<void> assertAuthorized(String userId) async {
    final fp = await DeviceFingerprintService.instance.current();
    final row = await _sb
        .from(_table)
        .select('is_authorized')
        .match({'user_id': userId, 'device_id': fp.deviceId, 'platform': fp.platform})
        .maybeSingle();

    if (row != null && row['is_authorized'] == false) {
      throw StateError('DEVICE_SUSPENDED');
    }
  }

  /// Liste des appareils d'un utilisateur
  Future<List<UserDevice>> listUserDevices(String userId) async {
    final rows = await _sb
        .from(_table)
        .select()
        .eq('user_id', userId)
        .order('last_login_at', ascending: false);
    return (rows as List).map((e) => UserDevice.fromMap(e as Map<String, dynamic>)).toList();
  }

  /// Autorise / suspend un appareil via son id (uuid)
  Future<void> setAuthorized({required String id, required bool authorized}) async {
    final nowIso = DateTime.now().toIso8601String();
    await _sb.from(_table).update({'is_authorized': authorized, 'updated_at': nowIso}).eq('id', id);
  }

  /// ➕ Supprimer un appareil par identifiant de la ligne
  Future<void> deleteById(String id) async {
    await _sb.from(_table).delete().eq('id', id);
  }

  /// ➕ Supprimer par (user_id, device_id)
  Future<void> deleteByDeviceId(String userId, String deviceId) async {
    await _sb.from(_table).delete().match({'user_id': userId, 'device_id': deviceId});
  }
}


import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/device_model.dart';
import 'device_fingerprint_service.dart';
import 'user_device_service.dart';

class DeviceService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  static String? _currentDeviceId;

  static Future<String> getCurrentDeviceId() async {
    if (_currentDeviceId != null) return _currentDeviceId!;
    final fp = await DeviceFingerprintService.instance.current();
    _currentDeviceId = fp.deviceId;
    return _currentDeviceId!;
  }

  static Future<Map<String, String>> getCurrentDeviceInfo() async {
    final fp = await DeviceFingerprintService.instance.current();
    return {
      'deviceName': fp.deviceName,
      'deviceType': fp.deviceType,
      'platform': fp.platform,
      'osVersion': fp.osVersion ?? 'unknown',
      'appVersion': fp.appVersion ?? '1.0.0',
    };
  }

  static Future<DeviceModel?> registerCurrentDevice(String userId) async {
    try {
      await UserDeviceService.instance.registerCurrentDevice(userId);
      final deviceId = await getCurrentDeviceId();
      final row = await _supabase
          .from('user_devices')
          .select()
          .match({'user_id': userId, 'device_id': deviceId})
          .maybeSingle();
      if (row == null) return null;
      return DeviceModel.fromJson(row);
    } catch (e) {
      print('Erreur lors de l\'enregistrement de l\'appareil: $e');
      return null;
    }
  }

  static Future<bool> isCurrentDeviceAuthorized(String userId) async {
    try {
      await UserDeviceService.instance.assertAuthorized(userId);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<List<DeviceModel>> getUserDevices(String userId) async {
    try {
      final currentDeviceId = await getCurrentDeviceId();
      final response = await _supabase
          .from('user_devices')
          .select()
          .eq('user_id', userId)
          .order('last_login_at', ascending: false);
      return (response as List).map((json) {
        final device = DeviceModel.fromJson(json);
        return device.copyWith(isCurrentDevice: device.deviceId == currentDeviceId);
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération des appareils: $e');
      return [];
    }
  }

  static Future<bool> authorizeDevice(String deviceId, String userId) async {
    try {
      await _supabase
          .from('user_devices')
          .update({'is_authorized': true, 'updated_at': DateTime.now().toIso8601String()})
          .eq('device_id', deviceId)
          .eq('user_id', userId);
      return true;
    } catch (e) {
      print('Erreur lors de l\'autorisation de l\'appareil: $e');
      return false;
    }
  }

  static Future<bool> revokeDeviceAuthorization(String deviceId, String userId) async {
    try {
      await _supabase
          .from('user_devices')
          .update({'is_authorized': false, 'updated_at': DateTime.now().toIso8601String()})
          .eq('device_id', deviceId)
          .eq('user_id', userId);
      return true;
    } catch (e) {
      print('Erreur lors de la révocation de l\'autorisation: $e');
      return false;
    }
  }

  static Future<bool> removeDevice(String deviceId, String userId) async {
    try {
      await _supabase.from('user_devices').delete().eq('device_id', deviceId).eq('user_id', userId);
      return true;
    } catch (e) {
      print('Erreur lors de la suppression de l\'appareil: $e');
      return false;
    }
  }

  static Future<List<DeviceModel>> getPendingDevices(String userId) async {
    try {
      final response = await _supabase
          .from('user_devices')
          .select()
          .eq('user_id', userId)
          .eq('is_authorized', false)
          .order('created_at', ascending: false);
      return (response as List).map((json) => DeviceModel.fromJson(json)).toList();
    } catch (e) {
      print('Erreur lors de la récupération des appareils en attente: $e');
      return [];
    }
  }

  static Future<bool> authorizeCurrentDevice(String userId) async {
    try {
      final deviceId = await getCurrentDeviceId();
      return await authorizeDevice(deviceId, userId);
    } catch (e) {
      print('Erreur lors de l\'autorisation de l\'appareil actuel: $e');
      return false;
    }
  }

  static Future<void> cleanupOldDevices(String userId) async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      await _supabase
          .from('user_devices')
          .delete()
          .eq('user_id', userId)
          .lt('last_login_at', thirtyDaysAgo.toIso8601String());
    } catch (e) {
      print('Erreur lors du nettoyage des anciens appareils: $e');
    }
  }
}

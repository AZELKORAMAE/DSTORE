import 'package:supabase_flutter/supabase_flutter.dart';

class AdminSettingsService {
  static final AdminSettingsService _instance = AdminSettingsService._internal();
  factory AdminSettingsService() => _instance;
  AdminSettingsService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  /// Récupérer les informations de contact admin depuis Supabase
  Future<Map<String, dynamic>> getContactInfo() async {
    try {
      final response = await _supabase
          .from('admin_settings')
          .select('setting_value')
          .eq('setting_key', 'contact_info')
          .single();

      if (response['setting_value'] != null) {
        return Map<String, dynamic>.from(response['setting_value']);
      }
    } catch (e) {
      print('❌ Erreur récupération paramètres admin: $e');
    }

    // Retourner les valeurs par défaut en cas d'erreur
    return {
      'business_name': 'DStore',
      'email': 'admin@dstore.com',
      'phone': '+212 693700583',
      'whatsapp': '+212 693700583',
    };
  }

  /// Sauvegarder les informations de contact admin dans Supabase
  Future<bool> saveContactInfo(Map<String, dynamic> contactInfo) async {
    try {
      print('🔄 Tentative de sauvegarde des paramètres admin...');
      print('📝 Données à sauvegarder: $contactInfo');

      // Vérifier la connexion Supabase
      print('🔑 Utilisateur connecté: ${_supabase.auth.currentUser?.id}');
      print('📧 Email utilisateur: ${_supabase.auth.currentUser?.email}');

      // Ajouter la date de mise à jour
      final updatedInfo = Map<String, dynamic>.from(contactInfo);
      updatedInfo['updated_at'] = DateTime.now().toIso8601String();

      print('📝 Données finales: $updatedInfo');

      // Essayer d'abord un simple SELECT pour tester la connexion
      try {
        final testSelect = await _supabase
            .from('admin_settings')
            .select('*')
            .eq('setting_key', 'contact_info');
        print('✅ Test SELECT réussi: $testSelect');
      } catch (selectError) {
        print('❌ Erreur lors du test SELECT: $selectError');
      }

      // Essayer d'abord un UPDATE, puis un INSERT si ça échoue
      try {
        final response = await _supabase
            .from('admin_settings')
            .update({
              'setting_value': updatedInfo,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('setting_key', 'contact_info');

        print('✅ UPDATE réussi: $response');
      } catch (updateError) {
        print('⚠️ UPDATE échoué, tentative INSERT: $updateError');

        final response = await _supabase
            .from('admin_settings')
            .insert({
              'setting_key': 'contact_info',
              'setting_value': updatedInfo,
            });

        print('✅ INSERT réussi: $response');
      }

      print('✅ Paramètres admin sauvegardés dans Supabase');
      return true;
    } catch (e) {
      print('❌ Erreur sauvegarde paramètres admin: $e');
      print('❌ Type d\'erreur: ${e.runtimeType}');
      if (e is PostgrestException) {
        print('❌ Code erreur PostgreSQL: ${e.code}');
        print('❌ Message erreur PostgreSQL: ${e.message}');
        print('❌ Détails erreur PostgreSQL: ${e.details}');
        print('❌ Hint PostgreSQL: ${e.hint}');
      }
      return false;
    }
  }

  /// Écouter les changements en temps réel des paramètres admin
  Stream<Map<String, dynamic>> watchContactInfo() {
    return _supabase
        .from('admin_settings')
        .stream(primaryKey: ['id'])
        .eq('setting_key', 'contact_info')
        .map((data) {
          if (data.isNotEmpty && data.first['setting_value'] != null) {
            return Map<String, dynamic>.from(data.first['setting_value']);
          }
          
          // Retourner les valeurs par défaut
          return {
            'business_name': 'DStore',
            'email': 'admin@dstore.com',
            'phone': '+212 693700583',
            'whatsapp': '+212 693700583',
          };
        });
  }

  /// Récupérer un paramètre spécifique
  Future<dynamic> getSetting(String key) async {
    try {
      final response = await _supabase
          .from('admin_settings')
          .select('setting_value')
          .eq('setting_key', key)
          .single();

      return response['setting_value'];
    } catch (e) {
      print('❌ Erreur récupération paramètre $key: $e');
      return null;
    }
  }

  /// Sauvegarder un paramètre spécifique
  Future<bool> saveSetting(String key, dynamic value) async {
    try {
      await _supabase
          .from('admin_settings')
          .upsert({
            'setting_key': key,
            'setting_value': value,
          });

      print('✅ Paramètre $key sauvegardé');
      return true;
    } catch (e) {
      print('❌ Erreur sauvegarde paramètre $key: $e');
      return false;
    }
  }
}

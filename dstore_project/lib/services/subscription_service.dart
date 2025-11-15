import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'local_storage_service.dart';

enum SubscriptionStatus {
  pending, // En attente d'activation
  active, // Actif
  suspended, // Suspendu (non-paiement)
  expired, // Expiré
}

enum SubscriptionType {
  basic, // Basique
  premium, // Premium
  enterprise, // Entreprise
}

class SubscriptionService {
  static SubscriptionService? _instance;
  static SubscriptionService get instance =>
      _instance ??= SubscriptionService._();
  SubscriptionService._();

  final _supabase = Supabase.instance.client;
  final _localStorage = LocalStorageService.instance;

  // ==================== VÉRIFICATION D'ABONNEMENT ====================

  Future<SubscriptionStatus> checkSubscriptionStatus() async {
    try {
      print('🔍 SUBSCRIPTION: Vérification du statut d\'abonnement...');

      final userEmail = await _localStorage.getUserEmail();
      print('📧 SUBSCRIPTION: Email utilisateur récupéré: $userEmail');

      if (userEmail == null) {
        print('❌ SUBSCRIPTION: Aucun email utilisateur trouvé');
        return SubscriptionStatus.pending;
      }

      print('🔍 SUBSCRIPTION: Recherche utilisateur dans la base...');
      final response = await _supabase
          .from('users')
          .select('id, account_status, subscription_end_date')
          .eq('email', userEmail)
          .maybeSingle();

      print('📊 SUBSCRIPTION: Réponse base de données: $response');

      if (response == null) {
        print('❌ SUBSCRIPTION: Utilisateur non trouvé dans la base');
        return SubscriptionStatus.pending;
      }

      final userId = response['id'] as String;
      final status = response['account_status'] as String?;
      final endDate = response['subscription_end_date'] as String?;

      print('📋 SUBSCRIPTION: Statut compte: $status');
      print('📅 SUBSCRIPTION: Date fin: $endDate');

      if (endDate != null) {
        final expirationDate = DateTime.parse(endDate);
        if (DateTime.now().isAfter(expirationDate)) {
          await _updateUserStatus(userId, 'expired');
          await _localStorage.saveSubscriptionStatus('expired');
          return SubscriptionStatus.expired;
        }
      }

      final subscriptionStatus = _parseStatus(status ?? 'pending');
      await _localStorage.saveSubscriptionStatus(subscriptionStatus.name);
      return subscriptionStatus;
    } catch (e) {
      print('❌ Erreur vérification abonnement: $e');
      final localStatus = _localStorage.getSubscriptionStatus();
      return _parseStatus(localStatus);
    }
  }

  Future<bool> canAccessApp() async {
    final status = await checkSubscriptionStatus();
    return status == SubscriptionStatus.active;
  }

  SubscriptionStatus getLocalSubscriptionStatus() {
    final status = _localStorage.getSubscriptionStatus();
    return _parseStatus(status);
  }

  bool needsStatusCheck() {
    final lastCheck = _localStorage.getLastStatusCheck();
    if (lastCheck == null) return true;
    final now = DateTime.now();
    final difference = now.difference(lastCheck);
    return difference.inHours >= 24;
  }

  // ==================== GESTION ADMIN ====================

  Future<bool> activateUserAccount(
    String userId, {
    SubscriptionType type = SubscriptionType.basic,
    int durationDays = 30,
  }) async {
    try {
      final now = DateTime.now();
      final endDate = now.add(Duration(days: durationDays));

      await _supabase.from('users').update({
        'account_status': 'active',
        'subscription_type': type.name,
        'subscription_start_date': now.toIso8601String(),
        'subscription_end_date': endDate.toIso8601String(),
        'last_payment_date': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      }).eq('id', userId);

      print('✅ Compte activé pour l\'utilisateur: $userId');
      return true;
    } catch (e) {
      print('❌ Erreur activation compte: $e');
      return false;
    }
  }

  Future<bool> suspendUserAccount(String userId) async {
    try {
      await _updateUserStatus(userId, 'suspended');
      print('⏸️ Compte suspendu pour l\'utilisateur: $userId');
      return true;
    } catch (e) {
      print('❌ Erreur suspension compte: $e');
      return false;
    }
  }

  Future<bool> reactivateUserAccount(String userId) async {
    try {
      await _updateUserStatus(userId, 'active');
      print('▶️ Compte réactivé pour l\'utilisateur: $userId');
      return true;
    } catch (e) {
      print('❌ Erreur réactivation compte: $e');
      return false;
    }
  }

  Future<bool> extendSubscription(String userId, int additionalDays) async {
    try {
      final response = await _supabase
          .from('users')
          .select('subscription_end_date')
          .eq('id', userId)
          .single();

      final currentEndDate = response['subscription_end_date'] as String?;
      final baseDate = currentEndDate != null
          ? DateTime.parse(currentEndDate)
          : DateTime.now();

      final newEndDate = baseDate.add(Duration(days: additionalDays));

      await _supabase.from('users').update({
        'subscription_end_date': newEndDate.toIso8601String(),
        'last_payment_date': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      print('📅 Abonnement prolongé de $additionalDays jours pour: $userId');
      return true;
    } catch (e) {
      print('❌ Erreur prolongation abonnement: $e');
      return false;
    }
  }

  // ==================== INFORMATIONS ABONNEMENT ====================

  /// Obtenir les détails d'abonnement
  Future<Map<String, dynamic>?> getSubscriptionDetails([String? userId, String? userEmail]) async {
    try {
      // Essayer d'abord avec les paramètres fournis
      if (userId != null) {
        print('🔍 DEBUG: Recherche par ID fourni: $userId');
        final response = await _supabase.from('users').select('*').eq('id', userId).maybeSingle();
        if (response != null) {
          print('✅ DEBUG: Utilisateur trouvé par ID fourni');
          print('📊 DEBUG: Données récupérées: $response');
          return response;
        }
      }

      // Sinon, essayer avec l'utilisateur courant de Supabase
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('❌ DEBUG: Utilisateur Supabase null');
        return null;
      }

      print('🔍 DEBUG: Recherche utilisateur - ID: ${user.id}, Email: ${user.email}');

      // Essayer par ID
      final response = await _supabase.from('users').select('*').eq('id', user.id).maybeSingle();
      if (response != null) {
        print('✅ DEBUG: Utilisateur trouvé par ID');
        print('📊 DEBUG: Données récupérées: $response');
        return response;
      }

      print('❌ DEBUG: Aucun utilisateur trouvé par ID, essai par email');

      // Si rien, essayer par email (seulement si email n'est pas null)
      if (user.email != null) {
        final responseByEmail = await _supabase.from('users').select('*').eq('email', user.email!).maybeSingle();
        if (responseByEmail != null) {
          print('✅ DEBUG: Utilisateur trouvé par email');
          print('📊 DEBUG: Données récupérées: $responseByEmail');
          return responseByEmail;
        }
        print('❌ DEBUG: Aucun utilisateur trouvé par email non plus');
      } else {
        print('❌ DEBUG: Email utilisateur null');
      }
      
      print('❌ DEBUG: Aucune donnée trouvée');
      return null;
    } catch (e) {
      print('❌ Erreur récupération détails: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final response = await _supabase
          .from('users')
          .select('*')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Erreur récupération utilisateurs: $e');
      return [];
    }
  }

  // ==================== MÉTHODES PRIVÉES ====================

  SubscriptionStatus _parseStatus(String status) {
    print('🔄 SUBSCRIPTION: Parsing statut: "$status"');
    switch (status.toLowerCase()) {
      case 'active':
        print('✅ SUBSCRIPTION: Statut parsé -> ACTIF');
        return SubscriptionStatus.active;
      case 'suspended':
        print('🚫 SUBSCRIPTION: Statut parsé -> SUSPENDU');
        return SubscriptionStatus.suspended;
      case 'expired':
        print('⏰ SUBSCRIPTION: Statut parsé -> EXPIRÉ');
        return SubscriptionStatus.expired;
      default:
        print('⏳ SUBSCRIPTION: Statut parsé -> EN ATTENTE');
        return SubscriptionStatus.pending;
    }
  }

  Future<void> _updateUserStatus(String userId, String status) async {
    await _supabase.from('users').update({
      'account_status': status,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', userId);
  }

  // ==================== MESSAGES D'ÉTAT ====================

  String getStatusMessage(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.pending:
        return 'Votre compte est en attente d\'activation. Contactez l\'administrateur.';
      case SubscriptionStatus.active:
        return 'Votre abonnement est actif.';
      case SubscriptionStatus.suspended:
        return 'Votre compte est suspendu. Contactez l\'administrateur.';
      case SubscriptionStatus.expired:
        return 'Votre abonnement a expiré. Renouvelez votre abonnement.';
    }
  }

  Color getStatusColor(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.pending:
        return Colors.orange;
      case SubscriptionStatus.active:
        return Colors.green;
      case SubscriptionStatus.suspended:
        return Colors.red;
      case SubscriptionStatus.expired:
        return Colors.grey;
    }
  }

  /// Rafraîchir les détails de l'abonnement
  Future<void> refreshSubscriptionDetails(String userId) async {
    try {
      print('🔄 SUBSCRIPTION: Rafraîchissement des détails pour l\'utilisateur: $userId');
      
      final response = await _supabase
          .from('users')
          .select('*')
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        print('✅ SUBSCRIPTION: Détails mis à jour');
        // Mettre à jour le stockage local si nécessaire
        final status = response['account_status'] as String? ?? 'pending';
        await _localStorage.saveSubscriptionStatus(status);
      } else {
        print('❌ SUBSCRIPTION: Utilisateur non trouvé');
      }
    } catch (e) {
      print('❌ SUBSCRIPTION: Erreur lors du rafraîchissement: $e');
    }
  }
}

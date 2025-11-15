import 'dart:convert';
import 'dart:math';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../config/supabase_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  static AuthService get instance => _instance;
  
  AuthService._internal();
  
  final SupabaseClient _supabase = Supabase.instance.client;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // ===== AUTHENTIFICATION DE BASE =====
  
  /// Connexion avec email et mot de passe - Via table users
  Future<AuthResponse> signInWithEmailAndPassword(String email, String password) async {
    try {
      print('🔐 CONNEXION : Tentative avec email: $email');

      // Vérifier les informations dans la table users avec le mot de passe et le statut
      final userResponse = await _supabase
          .from('users')
          .select('id, email, business_name, password, account_status, subscription_end_date')
          .eq('email', email)
          .maybeSingle();

      if (userResponse == null) {
        print('❌ Utilisateur non trouvé dans la table users');
        throw Exception('Email ou mot de passe incorrect');
      }

      print('✅ Utilisateur trouvé: ${userResponse['business_name']}');

      // ÉTAPE 1: Vérifier d'abord le statut du compte (priorité sur le mot de passe)
      final accountStatus = userResponse['account_status'] as String?;
      print('📊 Statut du compte: $accountStatus');

      if (accountStatus == null || accountStatus == 'pending') {
        print('⏳ Compte en attente d\'activation');
        // Pour les comptes en attente, générer l'exception spéciale pour redirection
        throw Exception('PENDING_ACCOUNT');
      }

      if (accountStatus == 'suspended') {
        print('🚫 Compte suspendu par l\'administrateur');
        print('🔄 DEBUG AUTH_SERVICE: Lancement de l\'exception SUSPENDED_ACCOUNT');
        // Pour les comptes suspendus, générer l'exception spéciale pour redirection
        throw Exception('SUSPENDED_ACCOUNT');
      }

      if (accountStatus == 'expired') {
        print('⏰ Compte expiré');
        throw Exception('Votre abonnement a expiré. Contactez l\'administrateur.');
      }

      // ÉTAPE 2: Vérifier le mot de passe seulement si le compte est actif
      final storedPassword = userResponse['password'] as String?;

      print('🔍 DIAGNOSTIC MOT DE PASSE:');
      print('   - Mot de passe saisi: "$password"');
      print('   - Mot de passe stocké: "$storedPassword"');
      print('   - Mot de passe stocké null: ${storedPassword == null}');
      print('   - Longueur mot de passe saisi: ${password.length}');
      print('   - Longueur mot de passe stocké: ${storedPassword?.length ?? 0}');
      print('   - Comparaison directe: ${storedPassword == password}');

      if (storedPassword == null) {
        print('❌ Aucun mot de passe défini pour cet utilisateur');
        throw Exception('Compte non configuré. Contactez l\'administrateur.');
      }

      if (storedPassword != password) {
        print('❌ Mot de passe incorrect');
        throw Exception('Email ou mot de passe incorrect');
      }

      print('✅ Mot de passe correct dans la table users');

      // Vérifier la date d'expiration si le compte est actif
      if (accountStatus == 'active') {
        final endDateStr = userResponse['subscription_end_date'] as String?;
        if (endDateStr != null) {
          final endDate = DateTime.parse(endDateStr);
          if (endDate.isBefore(DateTime.now())) {
            print('⏰ Abonnement expiré');
            throw Exception('Votre abonnement a expiré. Contactez l\'administrateur.');
          }
        }
      }

      print('✅ Compte actif et valide');

      // Mettre à jour le stockage local avec le mot de passe qui a fonctionné
      await _updateStoredPassword(password);
      print('✅ Mot de passe synchronisé dans le stockage local');

      // Créer une réponse d'authentification simulée
      final fakeResponse = AuthResponse(
        user: User(
          id: userResponse['id'],
          email: email,
          createdAt: DateTime.now().toIso8601String(),
          appMetadata: {},
          userMetadata: {},
          aud: '',
        ),
        session: null,
      );

      return fakeResponse;
    } catch (e) {
      print('❌ Erreur de connexion: $e');
      if (e.toString().contains('PENDING_ACCOUNT')) {
        throw Exception('PENDING_ACCOUNT');
      }
      if (e.toString().contains('SUSPENDED_ACCOUNT')) {
        throw Exception('SUSPENDED_ACCOUNT');
      }
      // Préserver les messages spécifiques pour les comptes expirés
      if (e.toString().contains('expiré') ||
          e.toString().contains('Contactez l\'administrateur')) {
        rethrow; // Relancer l'exception originale avec son message spécifique
      }
      throw Exception('Email ou mot de passe incorrect');
    }
  }

  /// Inscription avec email et mot de passe
  Future<AuthResponse> signUpWithEmailAndPassword(String email, String password) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      throw Exception('Erreur d\'inscription: $e');
    }
  }

  /// Déconnexion
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Erreur de déconnexion: $e');
    }
  }

  // ===== GESTION DU PROFIL =====
  
  /// Créer le profil utilisateur
  Future<UserModel> createUserProfile(
    String userId,
    String email, {
    String? fullName,
    String? businessName,
    String? phone,
    String? address,
    String? password,
  }) async {
    try {
      final userData = {
        'id': userId,
        'email': email,
        'full_name': fullName,
        'business_name': businessName,
        'phone': phone,
        'address': address,
        'password': password, // Ajouter le mot de passe
      };

      final response = await _supabase
          .from(SupabaseConfig.usersTable)
          .insert(userData)
          .select()
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Erreur de création du profil: $e');
    }
  }

  /// Récupérer le profil utilisateur
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.usersTable)
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        return UserModel.fromJson(response);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur de récupération du profil: $e');
    }
  }

  /// Mettre à jour le profil utilisateur
  Future<UserModel> updateUserProfile(
    String userId, {
    String? fullName,
    String? businessName,
    String? phone,
    String? address,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (fullName != null) updateData['full_name'] = fullName;
      if (businessName != null) updateData['business_name'] = businessName;
      if (phone != null) updateData['phone'] = phone;
      if (address != null) updateData['address'] = address;

      final response = await _supabase
          .from(SupabaseConfig.usersTable)
          .update(updateData)
          .eq('id', userId)
          .select()
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Erreur de mise à jour du profil: $e');
    }
  }

  // ===== PROPRIÉTÉS UTILES =====
  
  /// Vérifier si l'utilisateur est connecté
  bool get isSignedIn => _supabase.auth.currentUser != null;

  /// Obtenir l'utilisateur actuel
  User? get currentUser => _supabase.auth.currentUser;

  /// Obtenir l'ID de l'utilisateur actuel
  String? get currentUserId => _supabase.auth.currentUser?.id;

  /// Stream des changements d'authentification
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // ===== RÉCUPÉRATION DE MOT DE PASSE =====
  
  // Stockage temporaire des codes de vérification
  static final Map<String, Map<String, dynamic>> _resetCodes = {};
  
  /// Envoyer un code de récupération de mot de passe par email
  Future<void> sendPasswordResetCode(String email) async {
    try {
      print('🔄 Génération du code de récupération pour: $email');

      // MODE TEST : Accepter tous les emails pour les tests
      // En production, il faudrait vérifier dans la base de données
      print('📧 Email à vérifier: $email');
      print('✅ Mode test activé - Email accepté pour les tests');
      
      // Générer un code à 6 chiffres
      final code = _generateVerificationCode();
      final expiryTime = DateTime.now().add(const Duration(minutes: 1));
      
      // Stocker le code temporairement (en production, utiliser une base de données)
      _resetCodes[email] = {
        'code': code,
        'expiry': expiryTime,
        'attempts': 0,
      };
      
      print('✅ Code généré: $code (expire à ${expiryTime.toLocal()})');
      
      // Envoyer l'email avec le code
      await _sendResetCodeEmail(email, code);
      
      print('✅ Email de récupération envoyé à: $email');
      
    } catch (e) {
      print('❌ Erreur envoi code récupération: $e');
      throw Exception('Erreur lors de l\'envoi du code: $e');
    }
  }
  
  /// Vérifier le code de récupération
  Future<bool> verifyPasswordResetCode(String email, String code) async {
    try {
      print('🔄 Vérification du code: $code pour $email');
      
      final resetData = _resetCodes[email];
      if (resetData == null) {
        print('❌ Aucun code trouvé pour cet email');
        return false;
      }
      
      // Vérifier l'expiration
      final expiry = resetData['expiry'] as DateTime;
      if (DateTime.now().isAfter(expiry)) {
        print('❌ Code expiré');
        _resetCodes.remove(email);
        return false;
      }
      
      // Vérifier le nombre de tentatives
      final attempts = resetData['attempts'] as int;
      if (attempts >= 3) {
        print('❌ Trop de tentatives');
        _resetCodes.remove(email);
        return false;
      }
      
      // Vérifier le code
      final storedCode = resetData['code'] as String;
      if (code != storedCode) {
        print('❌ Code incorrect');
        _resetCodes[email]!['attempts'] = attempts + 1;
        return false;
      }
      
      print('✅ Code valide');
      return true;
      
    } catch (e) {
      print('❌ Erreur vérification code: $e');
      return false;
    }
  }
  
  /// Réinitialiser le mot de passe
  Future<void> resetPassword(String email, String code, String newPassword) async {
    try {
      print('🔄 Réinitialisation mot de passe pour: $email');

      // Vérifier une dernière fois le code
      final isValidCode = await verifyPasswordResetCode(email, code);
      if (!isValidCode) {
        throw Exception('Code invalide ou expiré');
      }

      print('🔄 Mise à jour du mot de passe dans la table users...');

      // Mettre à jour le mot de passe dans la table users via la fonction SQL
      await _supabase.rpc('update_user_password_simple', params: {
        'user_email': email,
        'new_password': newPassword,
      });

      print('✅ Mot de passe mis à jour dans la table users');

      // Mettre à jour le stockage local
      await _storage.write(key: 'user_password', value: newPassword);
      print('✅ Mot de passe mis à jour localement');

      // Supprimer le code utilisé
      _resetCodes.remove(email);

      print('✅ Mot de passe réinitialisé avec succès');

    } catch (e) {
      print('❌ Erreur réinitialisation: $e');
      throw Exception('Erreur lors de la réinitialisation: $e');
    }
  }

  /// Forcer la mise à jour du mot de passe (pour les tests)
  Future<void> forceUpdatePassword(String email, String newPassword) async {
    try {
      print('🔧 Mise à jour forcée du mot de passe pour: $email');

      // Sauvegarder le nouveau mot de passe localement
      await _updateStoredPassword(newPassword);
      print('✅ Mot de passe mis à jour dans le stockage local');

      // Essayer de mettre à jour dans Supabase si possible
      try {
        final currentUser = _supabase.auth.currentUser;
        if (currentUser != null && currentUser.email == email) {
          final response = await _supabase.auth.updateUser(
            UserAttributes(password: newPassword)
          );
          if (response.user != null) {
            print('✅ Mot de passe mis à jour dans Supabase');
          }
        } else {
          print('⚠️ Utilisateur non connecté, mise à jour locale uniquement');
        }
      } catch (e) {
        print('⚠️ Erreur mise à jour Supabase: $e (continuons avec le local)');
      }

    } catch (e) {
      print('❌ Erreur mise à jour forcée: $e');
      throw Exception('Erreur lors de la mise à jour forcée: $e');
    }
  }
  
  /// Générer un code de vérification à 6 chiffres
  String _generateVerificationCode() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }
  
  /// Envoyer l'email avec le code de récupération
  Future<void> _sendResetCodeEmail(String email, String code) async {
    try {
      print('📧 Envoi email à: $email avec code: $code');

      // Envoyer un vrai email avec Supabase Edge Function
      await _sendEmailWithSupabase(email, code);
      print('✅ Email envoyé via Supabase');

    } catch (e) {
      print('❌ Erreur envoi email: $e');

      // Fallback : afficher le code dans les logs pour les tests
      print('📧 ========== CODE DE RÉCUPÉRATION ==========');
      print('📧 Email: $email');
      print('📧 Code: $code');
      print('📧 ==========================================');

      // En mode développement, on continue même si l'email échoue
      print('⚠️ Mode développement : code affiché ci-dessus');
    }
  }

  /// Mettre à jour le mot de passe automatiquement
  Future<void> updatePasswordAutomatically(String email, String newPassword) async {
    try {
      print('🔄 Mise à jour automatique du mot de passe pour: $email');

      // 1. D'abord, essayer de connecter l'utilisateur avec l'ancien mot de passe
      final storedPassword = await _getStoredPassword();

      if (storedPassword != null) {
        try {
          print('🔄 Connexion avec l\'ancien mot de passe...');
          await signInWithEmailAndPassword(email, storedPassword);
          print('✅ Connexion réussie avec l\'ancien mot de passe');

          // 2. Maintenant mettre à jour le mot de passe
          print('🔄 Mise à jour du mot de passe dans Supabase...');
          final response = await _supabase.auth.updateUser(
            UserAttributes(password: newPassword)
          );

          if (response.user != null) {
            print('✅ Mot de passe mis à jour dans Supabase');

            // 3. Mettre à jour le stockage local
            await _updateStoredPassword(newPassword);
            print('✅ Mot de passe mis à jour dans le stockage local');

            // 4. Reconnecter avec le nouveau mot de passe pour vérifier
            await _supabase.auth.signOut();
            await signInWithEmailAndPassword(email, newPassword);
            print('✅ Vérification réussie avec le nouveau mot de passe');

          } else {
            throw Exception('Erreur lors de la mise à jour du mot de passe dans Supabase');
          }
        } catch (e) {
          print('❌ Erreur lors de la mise à jour: $e');
          // Essayer une approche alternative : mise à jour directe du stockage local
          print('🔄 Mise à jour du stockage local uniquement...');
          await _updateStoredPassword(newPassword);
          print('✅ Mot de passe mis à jour dans le stockage local');
        }
      } else {
        print('⚠️ Aucun mot de passe stocké trouvé');
        // Juste mettre à jour le stockage local
        await _updateStoredPassword(newPassword);
        print('✅ Nouveau mot de passe sauvegardé dans le stockage local');
      }

    } catch (e) {
      print('❌ Erreur mise à jour automatique mot de passe: $e');
      // Toujours essayer de sauvegarder le nouveau mot de passe localement
      try {
        await _updateStoredPassword(newPassword);
        print('✅ Mot de passe sauvegardé localement malgré l\'erreur');
      } catch (saveError) {
        print('❌ Impossible de sauvegarder le mot de passe: $saveError');
      }
    }
  }

  /// Récupérer l'email stocké
  Future<String?> _getStoredEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('user_email');
    } catch (e) {
      return null;
    }
  }

  /// Récupérer le mot de passe stocké
  Future<String?> _getStoredPassword() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('user_password');
    } catch (e) {
      return null;
    }
  }

  /// Mettre à jour le mot de passe stocké
  Future<void> _updateStoredPassword(String newPassword) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_password', newPassword);
    } catch (e) {
      print('❌ Erreur sauvegarde nouveau mot de passe: $e');
    }
  }

  /// Envoyer email avec Gmail SMTP
  Future<void> _sendEmailWithSupabase(String email, String code) async {
    try {
      // Configuration Gmail SMTP
      const gmailEmail = 'dstoreauth@gmail.com';
      const gmailPassword = 'qrax oipj zqre fhos'; // Mot de passe d'application Gmail

      // Configuration du serveur SMTP Gmail
      final smtpServer = gmail(gmailEmail, gmailPassword);

      // Création du message
      final message = Message()
        ..from = Address(gmailEmail, 'DSTORE Auth')
        ..recipients.add(email)
        ..subject = 'Code de récupération - DSTORE'
        ..html = '''
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <h2 style="color: #333;">Code de récupération DSTORE</h2>
            <p>Bonjour,</p>
            <p>Votre code de récupération de mot de passe est :</p>
            <div style="background: #f5f5f5; padding: 20px; text-align: center; margin: 20px 0;">
              <h1 style="color: #007bff; font-size: 32px; margin: 0;">$code</h1>
            </div>
            <p><strong>Ce code expire dans 1 minute.</strong></p>
            <p>Si vous n'avez pas demandé cette récupération, ignorez cet email.</p>
            <hr style="margin: 30px 0;">
            <p style="color: #666; font-size: 14px;">
              Cordialement,<br>
              L'équipe DSTORE Auth
            </p>
          </div>
        ''';

      // Envoi de l'email
      final sendReport = await send(message, smtpServer);
      print('✅ Email envoyé avec succès: ${sendReport.toString()}');

    } catch (e) {
      print('❌ Erreur envoi email Gmail: $e');
      throw Exception('Erreur envoi email: $e');
    }
  }
}

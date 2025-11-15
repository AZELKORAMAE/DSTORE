import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PasswordResetService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Générer un code de vérification à 6 chiffres
  String _generateVerificationCode() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  /// Envoyer un code de vérification par email
  Future<bool> sendVerificationCode(String email) async {
    try {
      print('🔄 Envoi du code de vérification à: $email');

      // 1. Vérifier si l'utilisateur existe dans la table users
      final userResponse = await _supabase
          .from('users')
          .select('id, email')
          .eq('email', email)
          .maybeSingle();

      if (userResponse == null) {
        throw Exception('Utilisateur non trouvé');
      }

      final userId = userResponse['id'];
      print('✅ Utilisateur trouvé: $userId');

      // 2. Générer le code de vérification
      final verificationCode = _generateVerificationCode();
      print('🔢 Code généré: $verificationCode');

      // 3. Supprimer les anciens codes pour cet email
      await _supabase
          .from('password_reset_codes')
          .delete()
          .eq('email', email);

      // 4. Insérer le nouveau code en base
      await _supabase.from('password_reset_codes').insert({
        'user_id': userId,
        'email': email,
        'verification_code': verificationCode,
        'expires_at': DateTime.now().add(Duration(minutes: 1)).toIso8601String(),
      });

      print('✅ Code sauvegardé en base de données');

      // 5. Envoyer l'email
      final emailSent = await _sendEmail(email, verificationCode);
      
      if (emailSent) {
        print('✅ Email envoyé avec succès');
        return true;
      } else {
        print('❌ Échec de l\'envoi de l\'email');
        return false;
      }
    } catch (e) {
      print('❌ Erreur lors de l\'envoi du code: $e');
      return false;
    }
  }

  /// Envoyer l'email avec le code de vérification
  Future<bool> _sendEmail(String email, String code) async {
    try {
      // Pour l'instant, simuler l'envoi d'email (à remplacer par vraie configuration SMTP)
      print('📧 SIMULATION EMAIL - Code pour $email: $code');

      // TODO: Configurer SMTP réel
      // final smtpServer = gmail('azelkoramae23@gmail.com', 'votre_mot_de_passe_app');

      // Simuler l'envoi d'email pour les tests
      await Future.delayed(Duration(seconds: 2)); // Simuler délai réseau

      // Afficher le code dans la console pour les tests
      print('');
      print('═══════════════════════════════════════');
      print('📧 EMAIL SIMULÉ POUR: $email');
      print('🔢 CODE DE VÉRIFICATION: $code');
      print('⏰ VALABLE 1 MINUTE');
      print('═══════════════════════════════════════');
      print('');

      return true;
    } catch (e) {
      print('❌ Erreur envoi email: $e');
      return false;
    }
  }

  /// Vérifier le code de vérification
  Future<Map<String, dynamic>> verifyCode(String email, String code) async {
    try {
      print('🔍 Vérification du code: $code pour $email');

      // 1. Chercher le code en base
      final response = await _supabase
          .from('password_reset_codes')
          .select('*')
          .eq('email', email)
          .eq('verification_code', code)
          .eq('used', false)
          .single();

      print('✅ Code trouvé en base: ${response['id']}');

      // 2. Vérifier si le code n'a pas expiré
      final expiresAt = DateTime.parse(response['expires_at']);
      if (DateTime.now().isAfter(expiresAt)) {
        print('❌ Code expiré');
        return {'success': false, 'message': 'Code expiré'};
      }

      // 3. Marquer le code comme utilisé
      await _supabase
          .from('password_reset_codes')
          .update({'used': true})
          .eq('id', response['id']);

      print('✅ Code vérifié avec succès');
      return {
        'success': true,
        'user_id': response['user_id'],
        'email': response['email']
      };
    } catch (e) {
      print('❌ Erreur vérification code: $e');
      return {'success': false, 'message': 'Code invalide'};
    }
  }

  /// Réinitialiser le mot de passe
  Future<bool> resetPassword(String userId, String newPassword) async {
    try {
      print('🔄 Réinitialisation du mot de passe pour: $userId');

      // 1. Récupérer l'email de l'utilisateur
      final userResponse = await _supabase
          .from('users')
          .select('email')
          .eq('id', userId)
          .single();

      final email = userResponse['email'] as String;
      print('📧 Email utilisateur: $email');

      // 2. Mettre à jour le mot de passe dans la table users
      await _supabase
          .from('users')
          .update({'password': newPassword})
          .eq('id', userId);
      print('✅ Mot de passe mis à jour dans la table users');

      // 3. Mettre à jour le mot de passe dans Supabase Auth
      await _updateSupabaseAuthPassword(email, newPassword);

      // 4. Mettre à jour le stockage local avec le nouveau mot de passe
      await _updateLocalPassword(newPassword);

      // 5. FORCER une vérification de connexion avec le nouveau mot de passe
      await _verifyNewPasswordConnection(email, newPassword);

      print('✅ Mot de passe réinitialisé et vérifié avec succès partout');
      return true;
    } catch (e) {
      print('❌ Erreur réinitialisation mot de passe: $e');
      return false;
    }
  }

  /// Forcer la vérification de connexion avec le nouveau mot de passe
  Future<void> _verifyNewPasswordConnection(String email, String newPassword) async {
    try {
      print('🔐 Vérification obligatoire de connexion avec le nouveau mot de passe...');

      // Se déconnecter d'abord
      await _supabase.auth.signOut();
      print('🔄 Déconnexion effectuée');

      // Attendre un peu pour que la déconnexion soit effective
      await Future.delayed(Duration(milliseconds: 500));

      // Essayer de se connecter avec le nouveau mot de passe
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: newPassword,
      );

      if (response.user != null) {
        print('✅ VÉRIFICATION RÉUSSIE : Connexion confirmée avec le nouveau mot de passe');
        print('👤 Utilisateur connecté: ${response.user!.email}');
      } else {
        throw Exception('Échec de la vérification de connexion');
      }

    } catch (e) {
      print('❌ ERREUR CRITIQUE : Impossible de se connecter avec le nouveau mot de passe');
      print('❌ Erreur: $e');
      throw Exception('Vérification de connexion échouée avec le nouveau mot de passe: $e');
    }
  }

  /// Mettre à jour le mot de passe dans Supabase Auth avec le nouveau mot de passe
  Future<void> _updateSupabaseAuthPassword(String email, String newPassword) async {
    try {
      print('🔄 Mise à jour Supabase Auth avec le nouveau mot de passe...');

      // 1. D'abord, forcer la mise à jour du mot de passe dans Supabase Auth
      // en utilisant l'API Admin ou la méthode de réinitialisation
      try {
        // Essayer de se connecter avec le nouveau mot de passe pour vérifier
        print('🔄 Test de connexion avec le nouveau mot de passe...');
        await _supabase.auth.signInWithPassword(
          email: email,
          password: newPassword,
        );
        print('✅ Connexion réussie avec le nouveau mot de passe');

      } catch (e) {
        print('⚠️ Connexion échouée avec le nouveau mot de passe: $e');

        // Si la connexion échoue, essayer de forcer la mise à jour
        // via l'ancien mot de passe puis changer
        final storedPassword = await _getStoredPassword();

        if (storedPassword != null) {
          try {
            print('🔄 Tentative avec l\'ancien mot de passe pour mise à jour...');
            await _supabase.auth.signInWithPassword(
              email: email,
              password: storedPassword,
            );

            // Mettre à jour le mot de passe
            final response = await _supabase.auth.updateUser(
              UserAttributes(password: newPassword)
            );

            if (response.user != null) {
              print('✅ Mot de passe mis à jour dans Supabase Auth');

              // Vérifier immédiatement avec le nouveau mot de passe
              await _supabase.auth.signOut();
              await _supabase.auth.signInWithPassword(
                email: email,
                password: newPassword,
              );
              print('✅ Vérification réussie avec le nouveau mot de passe');
            }

          } catch (updateError) {
            print('❌ Erreur lors de la mise à jour: $updateError');
            throw Exception('Impossible de mettre à jour le mot de passe dans Supabase Auth');
          }
        } else {
          throw Exception('Aucun mot de passe de référence trouvé');
        }
      }

    } catch (e) {
      print('❌ Erreur critique lors de la mise à jour Supabase Auth: $e');
      throw Exception('Erreur lors de la mise à jour du mot de passe: $e');
    }
  }

  /// Récupérer le mot de passe stocké localement
  Future<String?> _getStoredPassword() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('user_password');
    } catch (e) {
      return null;
    }
  }

  /// Mettre à jour le mot de passe stocké localement
  Future<void> _updateLocalPassword(String newPassword) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_password', newPassword);
      print('✅ Mot de passe mis à jour dans le stockage local');
    } catch (e) {
      print('❌ Erreur sauvegarde mot de passe local: $e');
    }
  }

  /// Nettoyer les codes expirés
  Future<void> cleanupExpiredCodes() async {
    try {
      await _supabase
          .from('password_reset_codes')
          .delete()
          .lt('expires_at', DateTime.now().toIso8601String());
      
      print('✅ Codes expirés nettoyés');
    } catch (e) {
      print('❌ Erreur nettoyage codes: $e');
    }
  }
}

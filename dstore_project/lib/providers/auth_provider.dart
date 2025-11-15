
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/subscription_service.dart';
import '../services/local_storage_service.dart';

import '../services/user_device_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService.instance;
  final SubscriptionService _subscriptionService = SubscriptionService.instance;
  final LocalStorageService _localStorage = LocalStorageService.instance;
  final _supabase = Supabase.instance.client;

  User? _user;
  UserModel? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _sessionTimer;
  DateTime? _lastLoginTime;

  static const bool _enablePeriodicDeviceCheck = false;

  User? get user => _user;
  User? get currentUser => _user;
  UserModel? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  Future<bool> isCurrentDeviceAuthorized() async {
    if (_user == null) return false;
    try {
      await UserDeviceService.instance.assertAuthorized(_user!.id);
      return true;
    } catch (_) {
      return false;
    }
  }

  AuthProvider() {
    _initializeAuth();
    _checkForceReauth();
  }

  void _initializeAuth() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      switch (event) {
        case AuthChangeEvent.signedIn:
          _user = session?.user;
          if (_user != null) {
            _loadUserProfile();
          }
          break;
        case AuthChangeEvent.signedOut:
          _user = null;
          _userProfile = null;
          break;
        case AuthChangeEvent.userUpdated:
          _user = session?.user;
          if (_user != null) {
            _loadUserProfile();
          }
          break;
        default:
          break;
      }
      notifyListeners();
    });

    _user = Supabase.instance.client.auth.currentUser;
    if (_user != null) {
      _loadUserProfile();
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      if (_user != null) {
        _userProfile = await _authService.getUserProfile(_user!.id);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement du profil: $e');
    }
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.signInWithEmailAndPassword(email, password);
      if (response.user != null) {
        _user = response.user;
        await _loadUserProfile();

        await checkSubscriptionAccess();
        await _updateLastLogin();
        await initializeLocalStorage(userId: _user!.id);

        try {
          await UserDeviceService.instance.registerCurrentDevice(_user!.id);
          await UserDeviceService.instance.assertAuthorized(_user!.id);
        } catch (deviceError) {
          await signOut();
          final msg = deviceError.toString();
          if (msg.contains('DEVICE_PENDING')) {
            throw Exception('Appareil en attente d\'autorisation');
          }
          if (msg.contains('DEVICE_SUSPENDED')) {
            throw Exception('Accès suspendu: appareil non autorisé');
          }
          throw deviceError;
        }

        _startSessionTimer();

        _setLoading(false);
        return true;
      } else {
        _setError('Erreur de connexion');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      print('🔍 DEBUG AUTH_PROVIDER: Exception capturée: "$e"');
      if (e.toString().contains('PENDING_ACCOUNT')) {
        _setError('PENDING_ACCOUNT');
      } else if (e.toString().contains('SUSPENDED_ACCOUNT')) {
        _setError('SUSPENDED_ACCOUNT');
      } else if (e.toString().contains('expiré') ||
          e.toString().contains('Contactez l\'administrateur') ||
          e.toString().contains('Appareil en attente') ||
          e.toString().contains('Accès suspendu')) {
        _setError(e.toString().replaceFirst('Exception: ', ''));
      } else {
        _setError(_getErrorMessage(e));
      }
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signUp(
    String email,
    String password, {
    String? fullName,
    String? businessName,
    String? phone,
    String? address,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.signUpWithEmailAndPassword(email, password);
      if (response.user != null) {
        await _authService.createUserProfile(
          response.user!.id,
          email,
          fullName: fullName,
          businessName: businessName,
          phone: phone,
          address: address,
          password: password,
        );

        _user = response.user;
        await _loadUserProfile();
        await initializeLocalStorage(userId: _user!.id);

        _setLoading(false);
        return true;
      } else {
        _setError('Erreur lors de l\'inscription');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    print('🔴 SIGNOUT: Déconnexion manuelle déclenchée');
    print('🔍 SIGNOUT: Utilisateur: ${_user?.email ?? "Aucun"}');
    print('🔍 SIGNOUT: Heure: ${DateTime.now()}');
    print('🔍 SIGNOUT: Stack trace: ${StackTrace.current}');

    _setLoading(true);
    _clearError();

    try {
      await _authService.signOut();
      _user = null;
      _userProfile = null;
      _sessionTimer?.cancel();
      _deviceCheckTimer?.cancel();

      final rememberMe = await _localStorage.isRememberMeEnabled();
      if (!rememberMe) {
        await _localStorage.clearLoginCredentials();
      }

      await _localStorage.initialize();

      _setLoading(false);
      print('✅ SIGNOUT: Déconnexion manuelle terminée');
    } catch (e) {
      print('❌ SIGNOUT: Erreur lors de la déconnexion: $e');
      _setError(_getErrorMessage(e));
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.sendPasswordResetCode(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }

  Future<void> updatePassword(String newPassword) async {
    _setLoading(true);
    _clearError();

    try {
      _setLoading(false);
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
      rethrow;
    }
  }

  Future<bool> verifyResetCode(String email, String code) async {
    _setLoading(true);
    _clearError();

    try {
      final isValid = await _authService.verifyPasswordResetCode(email, code);
      _setLoading(false);
      return isValid;
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
      rethrow;
    }
  }

  Future<bool> updateProfile({
    String? fullName,
    String? businessName,
    String? phone,
    String? address,
  }) async {
    if (_user == null) return false;

    _setLoading(true);
    _clearError();

    try {
      final updatedProfile = await _authService.updateUserProfile(
        _user!.id,
        fullName: fullName,
        businessName: businessName,
        phone: phone,
        address: address,
      );

      _userProfile = updatedProfile;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> changePassword(String newPassword) async {
    if (_user == null) return false;

    _setLoading(true);
    _clearError();

    try {
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _getErrorMessage(dynamic error) {
    if (error is AuthException) {
      switch (error.message) {
        case 'Invalid login credentials':
          return 'Email ou mot de passe incorrect';
        case 'Email not confirmed':
          return 'Veuillez confirmer votre email';
        case 'User already registered':
          return 'Cet email est déjà utilisé';
        case 'Password should be at least 6 characters':
          return 'Le mot de passe doit contenir au moins 6 caractères';
        default:
          return error.message;
      }
    }
    return error.toString();
  }

  Future<bool> checkSubscriptionAccess() async {
    try {
      final canAccess = await _subscriptionService.canAccessApp();
      if (!canAccess) {
        _setError('Votre abonnement n\'est pas actif. Contactez l\'administrateur.');
      }
      return canAccess;
    } catch (e) {
      _setError('Erreur de vérification d\'abonnement');
      return false;
    }
  }

  SubscriptionStatus getLocalSubscriptionStatus() {
    return _subscriptionService.getLocalSubscriptionStatus();
  }

  Future<Map<String, dynamic>?> getSubscriptionDetails() async {
    if (_user == null) return null;
    return await _subscriptionService.getSubscriptionDetails(_user!.id, _user!.email);
  }

  Future<int> getDaysRemaining() async {
    try {
      final details = await getSubscriptionDetails();
      if (details == null) return 0;

      final endDateStr = details['subscription_end_date'] as String?;
      if (endDateStr == null) return 0;

      final endDate = DateTime.parse(endDateStr);
      final now = DateTime.now();
      final difference = endDate.difference(now);
      return difference.inDays;
    } catch (e) {
      print('❌ Erreur calcul jours restants: $e');
      return 0;
    }
  }

  static int getDaysRemainingFromDate(String? endDateStr) {
    if (endDateStr == null) return 0;
    try {
      final endDate = DateTime.parse(endDateStr);
      final now = DateTime.now();
      final difference = endDate.difference(now);
      return difference.inDays;
    } catch (e) {
      return 0;
    }
  }

  Future<String> getSubscriptionStatusText() async {
    try {
      final details = await getSubscriptionDetails();
      if (details == null) return 'Statut inconnu';

      final status = details['account_status'] as String?;
      final daysRemaining = await getDaysRemaining();

      switch (status) {
        case 'active':
          if (daysRemaining > 0) {
            return daysRemaining == 1 ? '1 jour restant' : '$daysRemaining jours restants';
          } else {
            return 'Expiré';
          }
        case 'pending':
          return 'En attente d\'activation';
        case 'suspended':
          return 'Compte suspendu';
        case 'expired':
          return 'Abonnement expiré';
        default:
          return 'Statut inconnu';
      }
    } catch (e) {
      print('❌ Erreur récupération statut: $e');
      return 'Erreur de statut';
    }
  }

  Future<Duration?> getDaysAndHoursRemaining() async {
    try {
      final details = await getSubscriptionDetails();
      if (details == null) return null;
      final endDateStr = details['subscription_end_date'] as String?;
      if (endDateStr == null) return null;
      final endDate = DateTime.parse(endDateStr);
      final now = DateTime.now();
      if (endDate.isBefore(now)) return Duration.zero;
      return endDate.difference(now);
    } catch (e) {
      return null;
    }
  }

  Future<int?> getDaysRemainingFromDb() async {
    try {
      final details = await getSubscriptionDetails();
      if (details == null) return null;
      final endDateStr = details['subscription_end_date'] as String?;
      return getDaysRemainingFromDate(endDateStr);
    } catch (e) {
      return null;
    }
  }

  Future<void> refreshSubscription() async {
    await getSubscriptionDetails();
    notifyListeners();
  }

  Future<void> initializeLocalStorage({String? userId}) async {
    try {
      await _localStorage.initialize(userId: userId);

      if (_user != null && _userProfile != null) {
        await _localStorage.saveUserInfo({
          'id': _user!.id,
          'email': _user!.email,
          'full_name': _userProfile!.fullName,
          'business_name': _userProfile!.businessName,
        });
      }
    } catch (e) {
      print('❌ Erreur initialisation stockage local: $e');
    }
  }

  Future<void> _updateLastLogin() async {
    try {
      if (_user != null) {
      }
    } catch (e) {
      debugPrint('❌ Erreur mise à jour dernière connexion: $e');
    }
  }

  Future<void> clearLocalData() async {
    try {
      await _localStorage.clearAllData();
    } catch (e) {
      debugPrint('❌ Erreur nettoyage données locales: $e');
    }
  }

  void _checkForceReauth() {
    if (_user != null) {
      _forceSignOut();
    }
  }

  void _startSessionTimer() {
    _sessionTimer?.cancel();
    _lastLoginTime = DateTime.now();

    _sessionTimer = Timer(const Duration(days: 7), () {
      _forceSignOut();
    });

    _deviceCheckTimer?.cancel();

    if (_enablePeriodicDeviceCheck) {
      _deviceCheckTimer = Timer.periodic(const Duration(minutes: 30), (timer) {
        _checkDeviceAuthorization();
      });
    }
  }

  Timer? _deviceCheckTimer;

  Future<void> _checkDeviceAuthorization() async {
    if (_user == null) return;
    try {
      await UserDeviceService.instance.assertAuthorized(_user!.id);
    } catch (e) {
      await signOut();
    }
  }

  void _forceSignOut() {
    _sessionTimer?.cancel();
    _deviceCheckTimer?.cancel();
    _user = null;
    _userProfile = null;
    _lastLoginTime = null;

    Supabase.instance.client.auth.signOut();
    _localStorage.initialize();

    notifyListeners();
  }

  bool isSessionExpired() {
    if (_lastLoginTime == null) return true;
    final now = DateTime.now();
    final difference = now.difference(_lastLoginTime!);
    return difference.inDays >= 7;
  }

  int getHoursUntilExpiration() {
    if (_lastLoginTime == null) return 0;
    final now = DateTime.now();
    final difference = now.difference(_lastLoginTime!);
    final hoursElapsed = difference.inHours;
    final totalHours = 7 * 24;
    return (totalHours - hoursElapsed).clamp(0, totalHours);
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }

  Future<void> refreshSubscriptionDetails() async {
    try {
      if (_user != null) {
        await _subscriptionService.refreshSubscriptionDetails(_user!.id);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erreur lors du rafraîchissement des détails d\'abonnement: $e');
    }
  }

  Future<void> logout() async {
    try {
      await signOut();
    } catch (e) {
      debugPrint('Erreur lors de la déconnexion: $e');
    }
  }

  Future<Map<String, dynamic>?> loadUserInfo() async {
    try {
      if (_user == null) return null;

      final response = await _supabase
          .from('users')
          .select('*')
          .eq('id', _user!.id)
          .maybeSingle();

      if (response != null) {
        final userMetadata = {
          'full_name': response['full_name'] ?? '',
          'business_name': response['business_name'] ?? '',
          'phone': response['phone'] ?? '',
          'address': response['address'] ?? '',
          'account_status': response['account_status'] ?? 'pending',
          'subscription_type': response['subscription_type'] ?? 'basic',
          'subscription_start_date': response['subscription_start_date'] ?? '',
          'subscription_end_date': response['subscription_end_date'] ?? '',
          'last_payment_date': response['last_payment_date'] ?? '',
          'last_login_date': response['last_login_date'] ?? DateTime.now().toIso8601String(),
        };

        await _localStorage.saveUserInfo(userMetadata);
        notifyListeners();
        return userMetadata;
      }
      return null;
    } catch (e) {
      debugPrint('Erreur lors du chargement des informations utilisateur: $e');
      return null;
    }
  }

  Map<String, dynamic>? get userInfo {
    return _localStorage.getUserInfo();
  }
}

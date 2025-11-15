import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/device_registration_service.dart';
import '../services/auth_service.dart';
import '../utils/app_utils.dart';

class DeviceAuthorizationScreen extends StatefulWidget {
  const DeviceAuthorizationScreen({super.key});

  @override
  State<DeviceAuthorizationScreen> createState() => _DeviceAuthorizationScreenState();
}

class _DeviceAuthorizationScreenState extends State<DeviceAuthorizationScreen> {
  final _deviceService = DeviceRegistrationService.instance;
  final _authService = AuthService.instance;

  bool _isChecking = true;   // vérification initiale (au chargement de l’écran)
  bool _verifying = false;   // état du bouton "Vérifier"

  @override
  void initState() {
    super.initState();
    _checkDeviceAuthorization(); // vérif auto au démarrage
  }

  /// Vérification au chargement de l’écran (pas de snackbar si suspendu)
  Future<void> _checkDeviceAuthorization() async {
    try {
      final isAuthorized = await _deviceService.isCurrentDeviceAuthorized();
      if (!mounted) return;

      if (isAuthorized) {
        // Appareil autorisé -> on peut continuer
        context.go('/');
      } else {
        // Appareil non autorisé -> on affiche l’écran avec le bouton Vérifier
        setState(() => _isChecking = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isChecking = false);
    }
  }

  /// Vérification déclenchée par le bouton "Vérifier"
  Future<void> _verifyNow() async {
    setState(() => _verifying = true);
    try {
      // Utilise la vérif détaillée (retourne bool)
      final authorized = await _deviceService.checkDeviceAuthorization();
      if (!mounted) return;

      if (authorized) {
        AppUtils.showSnackBar(context, '✅ Accès autorisé. Vous pouvez vous connecter.', isError: false);
        context.go('/'); // adapte la route si besoin (/login, /home, ...)
      } else {
        AppUtils.showSnackBar(context, '🚫 Vous êtes toujours suspendu. Réessayez plus tard.', isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      AppUtils.showSnackBar(context, '❌ Erreur de vérification: $e', isError: true);
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Vérification de l\'autorisation...',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Autorisation Requise'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.security, size: 80, color: Colors.orange[600]),
            const SizedBox(height: 24),
            Text(
              'Appareil Non Autorisé',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[800],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Cet appareil n\'est pas encore autorisé à accéder à votre compte.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Veuillez contacter l\'administrateur pour autoriser cet appareil.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Informations',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[800],
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '• Votre appareil a été enregistré automatiquement\n'
                      '• Un administrateur doit l\'autoriser manuellement\n'
                      '• Vous pouvez cliquer sur "Vérifier" après autorisation\n'
                      '• Tant que non autorisé, l’accès est refusé',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _verifying ? null : _verifyNow,
                    icon: _verifying
                        ? const SizedBox(
                            width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.refresh),
                    label: Text(_verifying ? 'Vérification...' : 'Vérifier'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _verifying ? null : _signOut,
                    icon: const Icon(Icons.logout),
                    label: const Text('Se Déconnecter'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _signOut() async {
    try {
      await _authService.signOut();
      if (!mounted) return;
      AppUtils.showSnackBar(context, 'Déconnexion réussie', isError: false);
      context.go('/login');
    } catch (e) {
      if (!mounted) return;
      AppUtils.showSnackBar(context, 'Erreur lors de la déconnexion: $e', isError: true);
    }
  }
}

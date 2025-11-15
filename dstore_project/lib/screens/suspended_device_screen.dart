import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/auth_service.dart';
import '../utils/app_utils.dart';

/// Écran affiché lorsque l'appareil actuel est suspendu par l'administrateur.
///
/// Cet écran informe l'utilisateur que son appareil ne peut pas accéder au compte
/// car l'autorisation a été révoquée. Il lui propose uniquement de se déconnecter
/// et de contacter l'administrateur pour réactiver l'accès. Cette page est
/// différente de l'écran d'autorisation des appareils en attente, afin de
/// distinguer clairement les deux cas.
class SuspendedDeviceScreen extends StatelessWidget {
  const SuspendedDeviceScreen({super.key});

  /// Déconnecte l'utilisateur et le redirige vers la page de connexion.
  Future<void> _signOut(BuildContext context) async {
    try {
      await AuthService.instance.signOut();
      if (context.mounted) {
        AppUtils.showSnackBar(context, 'Déconnexion réussie', isError: false);
        context.go('/login');
      }
    } catch (e) {
      if (context.mounted) {
        AppUtils.showSnackBar(
          context,
          'Erreur lors de la déconnexion: $e',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appareil Suspendu'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.block,
              size: 80,
              color: Colors.red[600],
            ),
            const SizedBox(height: 24),
            Text(
              'Appareil Suspendu',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red[800],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Cet appareil a été suspendu par l\'administrateur et ne peut pas accéder à votre compte.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Veuillez contacter l\'administrateur pour réactiver l\'accès.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _signOut(context),
              icon: const Icon(Icons.logout),
              label: const Text('Se Déconnecter'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
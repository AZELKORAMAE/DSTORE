import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../utils/app_utils.dart';
import '../../services/local_storage_service.dart';
import '../../services/admin_settings_service.dart';
import '../../services/device_registration_service.dart'; // ⬅️ AJOUT

class PendingAccountScreen extends StatefulWidget {
  const PendingAccountScreen({super.key});

  @override
  State<PendingAccountScreen> createState() => _PendingAccountScreenState();
}

class _PendingAccountScreenState extends State<PendingAccountScreen> {
  final AdminSettingsService _adminSettingsService = AdminSettingsService();
  String _adminEmail = 'admin@dstore.com';
  String _adminPhone = '+212 693700583';
  String _adminWhatsApp = '+212 693700583';

  bool _verifying = false; // ⬅️ état du bouton "Vérifier le statut"

  @override
  void initState() {
    super.initState();
    _loadAdminSettings();
    // Recharger les paramètres toutes les 5 secondes
    _startPeriodicRefresh();
  }

  void _startPeriodicRefresh() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _loadAdminSettings();
        _startPeriodicRefresh();
      }
    });
  }

  void _loadAdminSettings() async {
    try {
      // Charger depuis Supabase au lieu du stockage local
      final settings = await _adminSettingsService.getContactInfo();

      if (mounted) {
        setState(() {
          _adminEmail = settings['email'] ?? 'admin@dstore.com';
          _adminPhone = settings['phone'] ?? '+212 693700583';
          _adminWhatsApp = settings['whatsapp'] ?? '+212 693700583';
        });
      }
    } catch (e) {
      // Utiliser les valeurs par défaut en cas d'erreur (garde les valeurs par défaut déjà définies)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Compte en attente'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),

            // Icône d'attente
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.orange[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.hourglass_empty,
                size: 60,
                color: Colors.orange[600],
              ),
            ),

            const SizedBox(height: 32),

            // Titre
            Text(
              'Compte en attente d\'activation',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Description
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[600], size: 24),
                  const SizedBox(height: 8),
                  Text(
                    'Félicitations ! Votre compte a été créé avec succès.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.blue[800],
                          fontWeight: FontWeight.w600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Votre compte nécessite maintenant une activation par l\'administrateur. '
                    'Veuillez contacter l\'administrateur en utilisant les informations ci-dessous pour activer votre compte rapidement.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Informations de contact
            _buildContactCard(context),

            const SizedBox(height: 32),

            // Boutons d'action
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.contact_support, color: Theme.of(context).primaryColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Contacter l\'administrateur',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              )),
                      Text(
                        'Pour activer votre nouveau compte',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Email
            _buildContactItem(
              context,
              icon: Icons.email,
              label: 'Email',
              value: _adminEmail,
              onTap: () => _copyToClipboard(context, _adminEmail, 'Email copié'),
            ),

            const SizedBox(height: 16),

            // Téléphone
            _buildContactItem(
              context,
              icon: Icons.phone,
              label: 'Téléphone',
              value: _adminPhone,
              onTap: () => _copyToClipboard(context, _adminPhone.replaceAll(' ', ''), 'Numéro copié'),
            ),

            const SizedBox(height: 16),

            // WhatsApp
            _buildContactItem(
              context,
              icon: Icons.chat,
              label: 'WhatsApp',
              value: _adminWhatsApp,
              onTap: () =>
                  _copyToClipboard(context, _adminWhatsApp.replaceAll(' ', ''), 'Numéro WhatsApp copié'),
            ),

            const SizedBox(height: 20),

            // Note d'information
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.amber[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Conseil pour un traitement rapide :',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Mentionnez votre adresse email d\'inscription et précisez que vous venez de créer un nouveau compte.',
                          style: TextStyle(fontSize: 12, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                  Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            Icon(Icons.copy, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Bouton Vérifier le statut
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _verifying ? null : () => _checkStatus(context),
            icon: _verifying
                ? const SizedBox(
                    width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.refresh),
            label: Text(_verifying ? 'Vérification...' : 'Vérifier le statut'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Bouton Se déconnecter
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _verifying ? null : () => _logout(context),
            icon: const Icon(Icons.logout),
            label: const Text('Se déconnecter'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }

  void _copyToClipboard(BuildContext context, String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    AppUtils.showSnackBar(context, message);
  }

  /// Vérifie le **statut du compte** ET l’**autorisation de l’appareil**
  Future<void> _checkStatus(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    setState(() => _verifying = true);
    AppUtils.showSnackBar(context, 'Vérification du statut...');

    try {
      // (optionnel) rafraîchir les détails d’abonnement en local
      await authProvider.refreshSubscriptionDetails();

      // 1) Compte/abonnement actif ?
      final hasAccess = await authProvider.checkSubscriptionAccess();

      // 2) Appareil autorisé ?
      final deviceOk = await DeviceRegistrationService.instance.checkDeviceAuthorization();

      if (!mounted) return;

      if (hasAccess && deviceOk) {
        AppUtils.showSnackBar(context, '✅ Accès autorisé. Vous pouvez vous connecter.', isError: false);
        context.go('/dashboard'); // change la route si besoin (/login, /home, ...)
      } else if (!hasAccess) {
        AppUtils.showSnackBar(context, 'Votre compte est toujours en attente d\'activation', isError: true);
      } else {
        AppUtils.showSnackBar(
          context,
          'Votre appareil est toujours en attente d’autorisation (suspendu).',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;
      AppUtils.showSnackBar(context, '❌ Erreur lors de la vérification: $e', isError: true);
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  Future<void> _logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.signOut();
    if (context.mounted) {
      context.go('/login');
    }
  }
}

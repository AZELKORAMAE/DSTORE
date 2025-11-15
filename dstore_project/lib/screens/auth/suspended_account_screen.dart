import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/auth_provider.dart';
import '../../services/admin_settings_service.dart';
import '../../services/device_registration_service.dart';
import '../../utils/app_utils.dart';

class SuspendedAccountScreen extends StatefulWidget {
  const SuspendedAccountScreen({super.key});

  @override
  State<SuspendedAccountScreen> createState() => _SuspendedAccountScreenState();
}

class _SuspendedAccountScreenState extends State<SuspendedAccountScreen> {
  final AdminSettingsService _adminSettingsService = AdminSettingsService();
  Map<String, dynamic> _adminSettings = {};
  bool _isLoading = true;
  bool _verifying = false; // <-- état du bouton "Vérifier à nouveau"

  @override
  void initState() {
    super.initState();
    _loadAdminSettings();
  }

  Future<void> _loadAdminSettings() async {
    try {
      final settings = await _adminSettingsService.getContactInfo();
      if (mounted) {
        setState(() {
          _adminSettings = settings;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _adminSettings = {
            'business_name': 'DStore',
            'email': 'admin@dstore.com',
            'phone': '+212 693700583',
            'whatsapp': '+212 693700583',
          };
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Compte Suspendu'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // Icône de suspension
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.block,
                      size: 60,
                      color: Colors.red[600],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Titre
                  Text(
                    'Compte Suspendu',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Description
                  Text(
                    'Votre compte a été temporairement suspendu par l\'administrateur. '
                    'Pour réactiver votre compte, veuillez contacter l\'administrateur.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                    textAlign: TextAlign.center,
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.contact_support,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Contacter l\'Administrateur',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Nom de l'entreprise
            _buildContactItem(
              Icons.business,
              'Entreprise',
              _adminSettings['business_name'] ?? 'DStore',
              null,
            ),

            const SizedBox(height: 12),

            // Email
            _buildContactItem(
              Icons.email,
              'Email',
              _adminSettings['email'] ?? 'admin@dstore.com',
              () => _launchEmail(_adminSettings['email'] ?? 'admin@dstore.com'),
            ),

            const SizedBox(height: 12),

            // Téléphone
            _buildContactItem(
              Icons.phone,
              'Téléphone',
              _adminSettings['phone'] ?? '+212 693700583',
              () => _launchPhone(_adminSettings['phone'] ?? '+212 693700583'),
            ),

            const SizedBox(height: 12),

            // WhatsApp
            _buildContactItem(
              Icons.chat,
              'WhatsApp',
              _adminSettings['whatsapp'] ?? '+212 693700583',
              () => _launchWhatsApp(_adminSettings['whatsapp'] ?? '+212 693700583'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(
    IconData icon,
    String label,
    String value,
    VoidCallback? onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: onTap != null ? Theme.of(context).primaryColor : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
            if (onTap != null) Icon(Icons.launch, size: 16, color: Theme.of(context).primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Bouton vérifier à nouveau
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _verifying ? null : _checkStatus,
            icon: _verifying
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.refresh),
            label: Text(_verifying ? 'Vérification...' : 'Vérifier à nouveau'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Bouton déconnexion
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _verifying ? null : _signOut,
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

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query:
          'subject=Demande de réactivation de compte&body=Bonjour,%0A%0AJe souhaiterais réactiver mon compte qui a été suspendu.%0A%0AMerci.',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      if (mounted) {
        AppUtils.showSnackBar(context, 'Impossible d\'ouvrir l\'application email', isError: true);
      }
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (mounted) {
        AppUtils.showSnackBar(context, 'Impossible d\'ouvrir l\'application téléphone', isError: true);
      }
    }
  }

  Future<void> _launchWhatsApp(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri whatsappUri = Uri.parse(
      'https://wa.me/$cleanPhone?text=Bonjour, je souhaiterais réactiver mon compte qui a été suspendu.',
    );

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        AppUtils.showSnackBar(context, 'Impossible d\'ouvrir WhatsApp', isError: true);
      }
    }
  }

  /// Vérifie le statut du compte **et** l'autorisation de l'appareil
  Future<void> _checkStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    setState(() => _verifying = true);
    AppUtils.showSnackBar(context, 'Vérification du statut...');

    try {
      // (facultatif) rafraîchir les détails d'abonnement en local
      await authProvider.refreshSubscriptionDetails();

      // 1) Compte/abonnement actif ?
      final hasAccess = await authProvider.checkSubscriptionAccess();

      // 2) Appareil autorisé ?
      final deviceOk = await DeviceRegistrationService.instance.checkDeviceAuthorization();

      if (!mounted) return;

      if (hasAccess && deviceOk) {
        AppUtils.showSnackBar(context, '✅ Accès autorisé. Vous pouvez vous connecter.', isError: false);
        context.go('/dashboard'); // adapte la route si besoin
      } else if (!hasAccess) {
        AppUtils.showSnackBar(context, 'Votre compte est toujours suspendu', isError: true);
      } else {
        // compte OK mais appareil non autorisé
        AppUtils.showSnackBar(
          context,
          'Votre appareil est toujours suspendu (en attente d’autorisation).',
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

  Future<void> _signOut() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.signOut();

    if (mounted) {
      context.go('/login');
    }
  }
}

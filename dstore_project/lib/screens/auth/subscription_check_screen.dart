import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../services/subscription_service.dart';
import '../../services/local_storage_service.dart';
import '../../services/admin_settings_service.dart';

class SubscriptionCheckScreen extends StatefulWidget {
  const SubscriptionCheckScreen({super.key});

  @override
  State<SubscriptionCheckScreen> createState() =>
      _SubscriptionCheckScreenState();
}

class _SubscriptionCheckScreenState extends State<SubscriptionCheckScreen> {
  bool _isChecking = true;
  SubscriptionStatus? _status;
  Map<String, dynamic>? _subscriptionDetails;

  @override
  void initState() {
    super.initState();
    _checkSubscription();
  }

  Future<void> _checkSubscription() async {
    setState(() {
      _isChecking = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Vérifier l'abonnement
      final canAccess = await authProvider.checkSubscriptionAccess();
      final status = authProvider.getLocalSubscriptionStatus();
      final details = await authProvider.getSubscriptionDetails();

      setState(() {
        _status = status;
        _subscriptionDetails = details;
        _isChecking = false;
      });

      // Si l'accès est autorisé, rediriger vers le dashboard
      if (canAccess && mounted) {
        // Initialiser le stockage local
        await authProvider.initializeLocalStorage();
        context.go('/dashboard');
      }
    } catch (e) {
      setState(() {
        _isChecking = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo ou icône
              Icon(
                _isChecking ? Icons.hourglass_empty : _getStatusIcon(),
                size: 80,
                color: _isChecking ? Colors.blue : _getStatusColor(),
              ),

              const SizedBox(height: 24),

              // Titre
              Text(
                _isChecking
                    ? 'Vérification de votre abonnement...'
                    : _getStatusTitle(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Message
              if (_isChecking)
                const CircularProgressIndicator()
              else
                _buildStatusContent(),

              const SizedBox(height: 32),

              // Actions
              if (!_isChecking) _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusContent() {
    final message = SubscriptionService.instance.getStatusMessage(_status!);

    return Column(
      children: [
        Text(
          message,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        if (_subscriptionDetails != null) _buildSubscriptionInfo(),
      ],
    );
  }

  Widget _buildSubscriptionInfo() {
    final details = _subscriptionDetails!;
    final endDate = details['subscription_end_date'] as String?;
    final type = details['subscription_type'] as String?;

    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Détails de l\'abonnement',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (type != null) _buildInfoRow('Type', type.toUpperCase()),
          if (endDate != null)
            _buildInfoRow(
              'Expire le',
              _formatDate(DateTime.parse(endDate)),
            ),
          _buildInfoRow('Statut', _status!.name.toUpperCase()),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Bouton principal selon le statut
        if (_status == SubscriptionStatus.pending ||
            _status == SubscriptionStatus.suspended ||
            _status == SubscriptionStatus.expired)
          ElevatedButton(
            onPressed: _checkSubscription,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
            ),
            child: const Text('Vérifier à nouveau'),
          ),

        const SizedBox(height: 16),

        // Bouton contact admin
        TextButton(
          onPressed: _contactAdmin,
          child: const Text('Contacter l\'administrateur'),
        ),

        const SizedBox(height: 8),

        // Bouton déconnexion
        TextButton(
          onPressed: _signOut,
          child: const Text('Se déconnecter'),
        ),
      ],
    );
  }

  IconData _getStatusIcon() {
    switch (_status!) {
      case SubscriptionStatus.pending:
        return Icons.pending;
      case SubscriptionStatus.active:
        return Icons.check_circle;
      case SubscriptionStatus.suspended:
        return Icons.pause_circle;
      case SubscriptionStatus.expired:
        return Icons.cancel;
    }
  }

  Color _getStatusColor() {
    return SubscriptionService.instance.getStatusColor(_status!);
  }

  String _getStatusTitle() {
    switch (_status!) {
      case SubscriptionStatus.pending:
        return 'Compte en attente';
      case SubscriptionStatus.active:
        return 'Abonnement actif';
      case SubscriptionStatus.suspended:
        return 'Compte suspendu';
      case SubscriptionStatus.expired:
        return 'Abonnement expiré';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  void _contactAdmin() async {
    // Charger les paramètres admin depuis Supabase
    try {
      final adminSettingsService = AdminSettingsService();
      final settings = await adminSettingsService.getContactInfo();

      final email = settings['email'] ?? 'admin@dstore.com';
      final phone = settings['phone'] ?? '+212 693700583';
      final whatsapp = settings['whatsapp'] ?? '+212 693700583';
      final businessName = settings['business_name'] ?? 'DStore';

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.support_agent, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Text('Contacter $businessName'),
            ],
          ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pour activer votre abonnement, contactez l\'administrateur :',
                style: TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 20),

              // Email
              _buildContactItem(
                Icons.email,
                'Email',
                email,
                Colors.blue,
              ),

              const SizedBox(height: 12),

              // Téléphone
              _buildContactItem(
                Icons.phone,
                'Téléphone',
                phone,
                Colors.green,
              ),

              const SizedBox(height: 12),

              // WhatsApp
              _buildContactItem(
                Icons.chat,
                'WhatsApp',
                whatsapp,
                Colors.green[600]!,
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.amber[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Mentionnez votre email d\'inscription pour un traitement rapide.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
    } catch (e) {
      print('❌ Erreur lors du chargement des paramètres admin: $e');
      // Utiliser les valeurs par défaut en cas d'erreur
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.support_agent, color: Colors.blue[700]),
              const SizedBox(width: 8),
              const Text('Contacter DStore'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pour activer votre abonnement, contactez l\'administrateur :',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                _buildContactItem(
                  Icons.email,
                  'Email',
                  'admin@dstore.com',
                  Colors.blue,
                ),
                const SizedBox(height: 12),
                _buildContactItem(
                  Icons.phone,
                  'Téléphone',
                  '+212 693700583',
                  Colors.green,
                ),
                const SizedBox(height: 12),
                _buildContactItem(
                  Icons.chat,
                  'WhatsApp',
                  '+212 693700583',
                  Colors.green[600]!,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildContactItem(
      IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _signOut() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.signOut();
    if (mounted) {
      context.go('/login');
    }
  }
}

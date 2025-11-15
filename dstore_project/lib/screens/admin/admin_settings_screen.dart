import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/admin_auth_service.dart';
import '../../services/local_storage_service.dart';
import '../../services/admin_settings_service.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final _adminService = AdminAuthService.instance;
  final _localStorage = LocalStorageService.instance;
  final _adminSettingsService = AdminSettingsService();

  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _businessNameController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Charger les paramètres après que le widget soit construit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSettings();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _businessNameController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Charger les paramètres depuis Supabase
      final settings = await _adminSettingsService.getContactInfo();

      if (mounted) {
        _emailController.text = settings['email'] ?? 'admin@dstore.com';
        _phoneController.text = settings['phone'] ?? '+212 693700583';
        _whatsappController.text = settings['whatsapp'] ?? '+212 693700583';
        _businessNameController.text = settings['business_name'] ?? 'DStore';
      }
    } catch (e) {
      // Ignorer les erreurs de chargement et utiliser les valeurs par défaut
      if (mounted) {
        _emailController.text = 'admin@dstore.com';
        _phoneController.text = '+212 693700583';
        _whatsappController.text = '+212 693700583';
        _businessNameController.text = 'DStore';
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final settings = {
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'whatsapp': _whatsappController.text.trim(),
        'business_name': _businessNameController.text.trim(),
      };

      // Sauvegarder dans Supabase (global)
      final success = await _adminSettingsService.saveContactInfo(settings);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Paramètres sauvegardés avec succès dans Supabase'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors de la sauvegarde dans Supabase'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres Admin'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _saveSettings,
            icon: const Icon(Icons.save),
            tooltip: 'Sauvegarder',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.indigo.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.settings,
                          size: 32,
                          color: Colors.indigo,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Informations de contact',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Ces informations seront affichées aux utilisateurs en attente d\'activation.',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Formulaire
                  Form(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nom du business
                        const Text(
                          'Nom du business',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _businessNameController,
                          decoration: const InputDecoration(
                            hintText: 'Ex: DStore',
                            prefixIcon: Icon(Icons.business),
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Email
                        const Text(
                          'Email de contact',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: 'admin@dstore.com',
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Téléphone
                        const Text(
                          'Numéro de téléphone',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            hintText: '+212 6XX XXX XXX',
                            prefixIcon: Icon(Icons.phone),
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // WhatsApp
                        const Text(
                          'Numéro WhatsApp',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _whatsappController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            hintText: '+212 6XX XXX XXX',
                            prefixIcon: Icon(Icons.chat),
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Boutons d'action
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _isLoading ? null : _saveSettings,
                                icon: const Icon(Icons.save),
                                label: const Text('Sauvegarder'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _loadSettings,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Réinitialiser'),
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Aperçu
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.preview, color: Colors.grey[600]),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Aperçu pour les utilisateurs',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Pour activer votre abonnement, contactez l\'administrateur :',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 8),
                              Text('📧 Email: ${_emailController.text}'),
                              Text('📱 Téléphone: ${_phoneController.text}'),
                              Text('💬 WhatsApp: ${_whatsappController.text}'),
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
}

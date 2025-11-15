import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/app_theme.dart';
import '../../utils/app_utils.dart';
import '../../l10n/app_localizations.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pré-remplir l'email si disponible
    _emailController.text = 'votre@email.com';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildContactInfo(),
              const SizedBox(height: 24),
              _buildContactForm(),
              const SizedBox(height: 24),
              _buildAlternativeContact(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.support_agent,
                  color: AppTheme.primaryColor,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Besoin d\'aide ?',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Notre équipe est là pour vous aider',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo() {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.contactInfo ?? 'Informations de contact',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            ListTile(
              leading: const Icon(Icons.email, color: Colors.blue),
              title: Text(l10n?.email ?? 'Email'),
              subtitle: const Text('dstoreteam@gmail.com'),
              onTap: () => _launchEmail('dstoreteam@gmail.com'),
            ),
            
            const Divider(),
            
            // Téléphone: mettre à jour le numéro pour le support DStore
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.green),
              title: Text(l10n?.phone ?? 'Téléphone'),
              subtitle: const Text('+212 778523571'),
              // Ouvrir l'application téléphone avec le nouveau numéro
              onTap: () => _launchPhone('+212778523571'),
            ),
            
            const Divider(),
            
            // WhatsApp: mettre à jour le numéro et rediriger vers le chat avec le nouveau numéro
            ListTile(
              leading: const Icon(Icons.chat, color: Colors.green),
              title: Text(l10n?.whatsapp ?? 'WhatsApp'),
              subtitle: const Text('+212 778523571'),
              // WhatsApp nécessite un numéro sans le préfixe '+'
              onTap: () => _launchWhatsApp('212778523571'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactForm() {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.sendMessage ?? 'Envoyer un message',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Email
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: l10n?.yourEmail ?? 'Votre adresse email',
                hintText: 'exemple@email.com',
                prefixIcon: const Icon(Icons.email),
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n?.pleaseEnter != null 
                    ? '${l10n!.pleaseEnter} ${l10n.yourEmail.toLowerCase()}'
                    : 'Veuillez saisir votre email';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return l10n?.invalidFormat != null 
                    ? l10n!.invalidFormat
                    : 'Veuillez saisir un email valide';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Sujet
            TextFormField(
              controller: _subjectController,
              decoration: InputDecoration(
                labelText: l10n?.subject ?? 'Objet',
                hintText: l10n?.subject != null 
                  ? '${l10n!.subject.toLowerCase()} de votre message'
                  : 'Sujet de votre message',
                prefixIcon: const Icon(Icons.subject),
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n?.pleaseEnter != null 
                    ? '${l10n!.pleaseEnter} ${l10n.subject.toLowerCase()}'
                    : 'Veuillez saisir un objet';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Message
            TextFormField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: l10n?.message ?? 'Message',
                hintText: 'Décrivez votre problème ou question...',
                prefixIcon: const Icon(Icons.message),
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n?.pleaseEnter != null 
                    ? '${l10n!.pleaseEnter} ${l10n.message.toLowerCase()}'
                    : 'Veuillez saisir un message';
                }
                if (value.length < 10) {
                  return 'Le message doit contenir au moins 10 caractères';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _sendEmail,
                icon: _isLoading 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
                label: Text(_isLoading ? 'Envoi...' : (l10n?.sendMessage ?? 'Envoyer le message')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlternativeContact() {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Autres moyens de contact',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            ListTile(
              leading: const Icon(Icons.schedule, color: Colors.orange),
              title: Text(l10n?.availability ?? 'Heures de disponibilité'),
              subtitle: const Text('Lun-Ven: 9h-18h (GMT+1)'),
            ),
            
            const Divider(),
            
            ListTile(
              leading: const Icon(Icons.language, color: Colors.purple),
              title: Text(l10n?.supportedLanguages ?? 'Langues supportées'),
              subtitle: const Text('Français, Anglais, Arabe'),
            ),
            
            const Divider(),
            
            ListTile(
              leading: const Icon(Icons.timer, color: Colors.blue),
              title: Text(l10n?.responseTime ?? 'Temps de réponse'),
              subtitle: const Text('24-48 heures'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendEmail() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text;
      final subject = _subjectController.text;
      final message = _messageController.text;
      
      final mailtoUrl = Uri.encodeFull(
        'mailto:dstoreteam@gmail.com?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent('Email de: $email\n\n$message')}'
      );
      
      final uri = Uri.parse(mailtoUrl);
      
      if (await canLaunchUrl(uri)) {
        // Utiliser le mode par défaut pour ouvrir l'email
        await launchUrl(uri);
        AppUtils.showSnackBar(
          context,
          'Application email ouverte avec succès',
          isError: false,
        );

        // Réinitialiser le formulaire
        _subjectController.clear();
        _messageController.clear();
      } else {
        throw Exception('Impossible d\'ouvrir l\'application email');
      }
    } catch (e) {
      AppUtils.showSnackBar(
        context, 
        'Erreur: $e',
        isError: true,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _launchEmail(String email) async {
    // Utiliser le schéma mailto pour ouvrir l'application de messagerie par défaut.
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      // Utiliser le mode par défaut pour laisser le système choisir l'application appropriée
      await launchUrl(uri);
    } else {
      AppUtils.showSnackBar(
        context,
        'Impossible d\'ouvrir l\'application email',
        isError: true,
      );
    }
  }

  Future<void> _launchPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      AppUtils.showSnackBar(
        context, 
        'Impossible d\'ouvrir l\'application téléphone',
        isError: true,
      );
    }
  }

  Future<void> _launchWhatsApp(String phone) async {
    final uri = Uri.parse('https://wa.me/$phone');
    if (await canLaunchUrl(uri)) {
      // Utiliser le mode par défaut sans imposer une application externe
      await launchUrl(uri);
    } else {
      AppUtils.showSnackBar(
        context,
        'Impossible d\'ouvrir WhatsApp',
        isError: true,
      );
    }
  }
} 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/sound_service.dart';
import '../../utils/app_utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'advanced_settings_screen.dart';
import 'cv_screen.dart';
import 'support_screen.dart';
import '../auth/login_screen.dart';
import '../../config/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _selectedCurrency = 'MAD';
  final TextEditingController _companyNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialiser le contrôleur avec le nom d'entreprise actuel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = context.read<SettingsProvider>();
      _companyNameController.text = settings.companyName;
      _loadUserInfo();
    });
  }

  Future<void> _loadUserInfo() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.loadUserInfo();
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.settings ?? 'Paramètres'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.isLoading) {
            return Center(
              child: Text(l10n?.loading ?? 'Chargement...'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildUserProfile(context, authProvider),
                const SizedBox(height: 16),
                _buildAppSettings(context),
                const SizedBox(height: 16),
                _buildBusinessSettings(context),
                const SizedBox(height: 16),
                _buildDataSettings(context),
                const SizedBox(height: 16),
                _buildAboutSection(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context, AuthProvider authProvider) {
    final l10n = AppLocalizations.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.primaryColor,
                  child: Text(
                    (authProvider.userInfo?['full_name']?.toString() ?? authProvider.user?.userMetadata?['full_name']?.toString() ?? 'U').substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authProvider.userInfo?['full_name']?.toString() ?? authProvider.user?.userMetadata?['full_name']?.toString() ?? l10n?.profile ?? 'Profil',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        authProvider.user?.email ?? '',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () async {
                    await authProvider.loadUserInfo();
                    await authProvider.refreshSubscriptionDetails();
                    AppUtils.showSnackBar(context, l10n?.subscriptionUpdated ?? 'Statut d\'abonnement actualisé !', isError: false);
                  },
                  tooltip: l10n?.refresh ?? 'Actualiser',
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Informations détaillées
            _buildInfoRow(l10n?.businessName ?? 'Nom de l\'entreprise', authProvider.userInfo?['business_name']?.toString() ?? authProvider.user?.userMetadata?['business_name']?.toString() ?? ''),
            _buildInfoRow(l10n?.phoneNumber ?? 'Numéro de téléphone', authProvider.userInfo?['phone']?.toString() ?? authProvider.user?.userMetadata?['phone']?.toString() ?? ''),
            _buildInfoRow(l10n?.address ?? 'Adresse', authProvider.userInfo?['address']?.toString() ?? authProvider.user?.userMetadata?['address']?.toString() ?? ''),
            _buildInfoRow(l10n?.subscriptionStatus ?? 'Statut de l\'abonnement', authProvider.userInfo?['account_status']?.toString() ?? authProvider.user?.userMetadata?['account_status']?.toString() ?? ''),
            _buildInfoRow(l10n?.subscriptionType ?? 'Type d\'abonnement', authProvider.userInfo?['subscription_type']?.toString() ?? authProvider.user?.userMetadata?['subscription_type']?.toString() ?? ''),
            _buildInfoRow(l10n?.subscriptionStartDate ?? 'Date de début d\'abonnement', _formatDate(authProvider.userInfo?['subscription_start_date']?.toString() ?? authProvider.user?.userMetadata?['subscription_start_date']?.toString())),
            _buildInfoRow(l10n?.subscriptionEndDate ?? 'Date de fin d\'abonnement', _formatDate(authProvider.userInfo?['subscription_end_date']?.toString() ?? authProvider.user?.userMetadata?['subscription_end_date']?.toString())),
            _buildInfoRow(l10n?.lastPaymentDate ?? 'Date du dernier paiement', _formatDate(authProvider.userInfo?['last_payment_date']?.toString() ?? authProvider.user?.userMetadata?['last_payment_date']?.toString())),
            _buildInfoRow(l10n?.lastLoginDate ?? 'Date de dernière connexion', _formatDate(authProvider.userInfo?['last_login_date']?.toString() ?? authProvider.user?.userMetadata?['last_login_date']?.toString())),

            // Affichage des jours restants
            FutureBuilder<Duration?>(
              future: authProvider.getDaysAndHoursRemaining(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink();
                }
                final duration = snapshot.data;
                if (duration == null) {
                  return Container(
                    margin: const EdgeInsets.only(top: 8, left: 16, right: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.grey, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n?.noActiveSubscription ?? 'Aucun abonnement actif',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (duration.inSeconds <= 0) {
                  return Container(
                    margin: const EdgeInsets.only(top: 8, left: 16, right: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n?.subscriptionExpired ?? 'Abonnement expiré',
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final days = duration.inDays;
                final hours = duration.inHours % 24;
                String remainingText;
                Color displayColor = _getDaysRemainingColor(days);

                if (days > 1) {
                  remainingText = l10n?.subscriptionRemainingDays.replaceAll('{days}', days.toString()) ?? 'Il vous reste $days jours d\'abonnement';
                } else if (days == 1) {
                  remainingText = l10n?.subscriptionRemainingTime.replaceAll('{days}', '1').replaceAll('{hours}', hours.toString()) ?? 'Il vous reste 1 jour et $hours heures d\'abonnement';
                } else { // days == 0
                  remainingText = l10n?.subscriptionRemainingHours.replaceAll('{hours}', hours.toString()) ?? 'Il vous reste $hours heures d\'abonnement';
                  if (hours == 0 && duration.inMinutes > 0) {
                    remainingText = l10n?.subscriptionRemainingHours.replaceAll('{hours}', '< 1') ?? 'Il vous reste moins d\'une heure d\'abonnement';
                  } else if (hours == 0 && duration.inMinutes <= 0) {
                    remainingText = l10n?.subscriptionExpired ?? 'Abonnement expiré';
                    displayColor = Colors.red;
                  }
                }

                return Container(
                  margin: const EdgeInsets.only(top: 8, left: 16, right: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: displayColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: displayColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        color: displayColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          remainingText,
                          style: TextStyle(
                            color: displayColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          const Text(': ', style: TextStyle(fontWeight: FontWeight.w500)),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppSettings(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.appSettings ?? 'Paramètres de l\'application',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Thème
            ListTile(
              title: Text(l10n?.theme ?? 'Thème'),
              subtitle: Consumer<SettingsProvider>(
                builder: (context, settings, child) {
                  return Text(_getThemeText(settings.themeMode));
                },
              ),
              leading: const Icon(Icons.palette),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showThemeDialog(context),
            ),

            const Divider(),

            // Langue
            ListTile(
              title: Text(l10n?.language ?? 'Langue'),
              subtitle: Consumer<SettingsProvider>(
                builder: (context, settings, child) {
                  return Text(_getLanguageText(settings.languageCode));
                },
              ),
              leading: const Icon(Icons.language),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showLanguageDialog(context),
            ),

            const Divider(),

            // Son de scan
            ListTile(
              title: Text(l10n?.scanSound ?? 'Son de scan'),
              subtitle: Consumer<SettingsProvider>(
                builder: (context, settings, child) {
                  return Text(_getScanSoundText(settings.scanSound));
                },
              ),
              leading: const Icon(Icons.volume_up),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showScanSoundDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessSettings(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.businessSettings ?? 'Paramètres de l\'entreprise',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // TVA
                _buildTVASettings(settings),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTVASettings(SettingsProvider settings) {
    final l10n = AppLocalizations.of(context);
    final tvaController = TextEditingController(text: settings.tvaRate.toString());
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${l10n?.tvaRate ?? 'Taux de TVA'} (%)',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: tvaController,
          decoration: InputDecoration(
            hintText: l10n?.pleaseEnter != null 
              ? '${l10n!.pleaseEnter} ${l10n.tvaRate.toLowerCase()} (ex: 20)'
              : 'Entrez le taux de TVA (ex: 20)',
            border: const OutlineInputBorder(),
            suffixText: '%',
          ),
          keyboardType: TextInputType.number,
          onSubmitted: (value) {
            final tvaRate = double.tryParse(value);
            if (tvaRate != null && tvaRate >= 0) {
              settings.setTVARate(tvaRate);
              AppUtils.showSnackBar(
                context,
                '${l10n?.tvaRate ?? 'Taux de TVA'} mis à jour: ${tvaRate.toStringAsFixed(1)}%',
              );
            }
          },
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            final tvaRate = double.tryParse(tvaController.text);
            if (tvaRate != null && tvaRate >= 0) {
              settings.setTVARate(tvaRate);
              AppUtils.showSnackBar(
                context,
                '${l10n?.tvaRate ?? 'Taux de TVA'} mis à jour: ${tvaRate.toStringAsFixed(1)}%',
              );
            }
          },
          child: Text(l10n?.save ?? 'Sauvegarder'),
        ),
      ],
    );
  }

  Widget _buildDataSettings(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.dataBackup ?? 'Données et sauvegarde',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Paramètres avancés
            ListTile(
              title: Text(l10n?.advancedSettings ?? 'Paramètres avancés'),
              subtitle: Text(l10n?.dataManagement ?? 'Gestion des données et réinitialisation'),
              leading: const Icon(Icons.settings_applications),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _navigateToAdvancedSettings(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.aboutSupport ?? 'À propos et support',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Version
            ListTile(
              title: Text(l10n?.version ?? 'Version'),
              subtitle: const Text('1.0.0'),
              leading: const Icon(Icons.info),
            ),

            const Divider(),

            // Support
            ListTile(
              title: Text(l10n?.support ?? 'Support'),
              subtitle: Text(l10n?.contactUs ?? 'Contactez-nous'),
              leading: const Icon(Icons.support_agent),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _navigateToSupport(),
            ),

            const Divider(),

            // Déconnexion
            ListTile(
              title: Text(l10n?.logout ?? 'Déconnexion'),
              leading: const Icon(Icons.logout, color: Colors.red),
              onTap: () => _showLogoutDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.logoutConfirmation ?? 'Se déconnecter'),
        content: Text(l10n?.logoutConfirmationMessage ?? 'Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n?.cancel ?? 'Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _logout();
            },
            child: Text(l10n?.logout ?? 'Se déconnecter'),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.chooseTheme ?? 'Choisir un thème'),
        content: Consumer<SettingsProvider>(
          builder: (context, settings, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: SettingsProvider.availableThemes.map((theme) {
                return RadioListTile<ThemeMode>(
                  title: Text(_getThemeText(theme['mode'])),
                  value: theme['mode'],
                  groupValue: settings.themeMode,
                  onChanged: (value) {
                    settings.setThemeMode(value!);
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.chooseLanguage ?? 'Choisir une langue'),
        content: Consumer<SettingsProvider>(
          builder: (context, settings, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: SettingsProvider.availableLanguages.map((language) {
                return RadioListTile<String>(
                  title: Row(
                    children: [
                      Text(language['flag'] ?? ''),
                      const SizedBox(width: 8),
                      Text(language['name'] ?? ''),
                    ],
                  ),
                  value: language['code'] ?? '',
                  groupValue: settings.languageCode,
                  onChanged: (value) {
                    settings.setLanguageCode(value!);
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  void _showScanSoundDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.chooseSound ?? 'Choisir un son'),
        content: Consumer<SettingsProvider>(
          builder: (context, settings, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: SettingsProvider.availableSounds.map((sound) {
                return RadioListTile<String>(
                  title: Text(_getScanSoundText(sound['id'] ?? '')),
                  value: sound['id'] ?? '',
                  groupValue: settings.scanSound,
                  onChanged: (value) {
                    settings.setScanSound(value!);
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  String _getThemeText(ThemeMode mode) {
    final l10n = AppLocalizations.of(context);
    switch (mode) {
      case ThemeMode.light:
        return l10n?.lightTheme ?? 'Clair';
      case ThemeMode.dark:
        return l10n?.darkTheme ?? 'Sombre';
      case ThemeMode.system:
        return l10n?.systemTheme ?? 'Système';
    }
  }

  String _getLanguageText(String code) {
    final language = SettingsProvider.availableLanguages.firstWhere(
      (lang) => lang['code'] == code,
      orElse: () => {'name': 'Français'},
    );
    return language['name']!;
  }

  String _getScanSoundText(String soundId) {
    final l10n = AppLocalizations.of(context);
    switch (soundId) {
      case 'beep':
        return l10n?.classicBeep ?? 'Bip classique';
      case 'success':
        return l10n?.success ?? 'Succès';
      case 'notification':
        return l10n?.notification ?? 'Notification';
      case 'cash_register':
        return l10n?.cashRegister ?? 'Caisse enregistreuse';
      case 'none':
        return l10n?.noSound ?? 'Aucun son';
      default:
        return l10n?.classicBeep ?? 'Bip classique';
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  Color _getDaysRemainingColor(int days) {
    if (days <= 0) return Colors.red;
    if (days <= 7) return Colors.orange;
    if (days <= 30) return Colors.yellow.shade700;
    return Colors.green;
  }

  void _navigateToAdvancedSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AdvancedSettingsScreen(),
      ),
    );
  }

  void _navigateToSupport() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SupportScreen(),
      ),
    );
  }

  void _logout() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }
}

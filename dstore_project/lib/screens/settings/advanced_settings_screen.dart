import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/user_reset_service.dart';
import '../../services/local_storage_service.dart';
import 'backup_screen.dart';

class AdvancedSettingsScreen extends StatefulWidget {
  const AdvancedSettingsScreen({super.key});

  @override
  State<AdvancedSettingsScreen> createState() => _AdvancedSettingsScreenState();
}

class _AdvancedSettingsScreenState extends State<AdvancedSettingsScreen> {
  final UserResetService _resetService = UserResetService.instance;
  final LocalStorageService _localStorage = LocalStorageService.instance;
  
  bool _isLoading = false;
  Map<String, dynamic>? _userDataSize;

  @override
  void initState() {
    super.initState();
    _loadUserDataSize();
  }

  Future<void> _loadUserDataSize() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      final dataSize = await _resetService.getUserDataSize(authProvider.user!.id);
      setState(() {
        _userDataSize = dataSize;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres Avancés'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDataManagementSection(),
            const SizedBox(height: 24),
            _buildDangerZoneSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildDataManagementSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.storage, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Gestion des Données',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Informations sur les données
            if (_userDataSize != null) ...[
              _buildDataInfoRow('Taille totale des données', _userDataSize!['formattedSize']),
              _buildDataInfoRow('Nombre de fichiers', '${_userDataSize!['fileCount']}'),
              const SizedBox(height: 16),
            ],

            // Boutons d'action
            _buildActionButton(
              icon: Icons.refresh,
              title: 'Actualiser les informations',
              subtitle: 'Recalculer la taille des données',
              onTap: _loadUserDataSize,
              color: Colors.blue,
            ),
            const SizedBox(height: 8),
            _buildActionButton(
              icon: Icons.backup,
              title: 'Créer une sauvegarde locale',
              subtitle: 'Sauvegarder toutes vos données localement',
              onTap: _createBackup,
              color: Colors.green,
            ),
            const SizedBox(height: 8),
            _buildActionButton(
              icon: Icons.cloud_upload,
              title: 'Sauvegarde et Partage',
              subtitle: 'Sauvegarder et partager vos données',
              onTap: _navigateToBackup,
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerZoneSection() {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: Colors.red),
                const SizedBox(width: 8),
                const Text(
                  'Zone Dangereuse',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            const Text(
              'Les actions suivantes sont irréversibles. Assurez-vous de créer une sauvegarde avant de continuer.',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),

            _buildDangerButton(
              icon: Icons.delete_sweep,
              title: 'Supprimer les données business',
              subtitle: 'Supprimer produits, factures, clients (garder paramètres)',
              onTap: () => _showResetDialog(ResetType.businessOnly),
            ),
            const SizedBox(height: 8),
            _buildDangerButton(
              icon: Icons.restore,
              title: 'Réinitialisation complète',
              subtitle: 'Supprimer TOUTES les données et redevenir utilisateur nouveau',
              onTap: () => _showResetDialog(ResetType.complete),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: _isLoading ? null : onTap,
      trailing: _isLoading ? const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ) : const Icon(Icons.arrow_forward_ios),
    );
  }

  Widget _buildDangerButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.red.withOpacity(0.1),
        child: Icon(icon, color: Colors.red),
      ),
      title: Text(title, style: const TextStyle(color: Colors.red)),
      subtitle: Text(subtitle),
      onTap: _isLoading ? null : onTap,
      trailing: _isLoading ? const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ) : const Icon(Icons.arrow_forward_ios, color: Colors.red),
    );
  }

  Future<void> _createBackup() async {
    setState(() => _isLoading = true);
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null) {
        final backupPath = await _resetService.createBackupBeforeReset(authProvider.user!.id);
        
        if (backupPath != null) {
          _showSuccessDialog('Sauvegarde créée avec succès !', 
            'Vos données ont été sauvegardées.');
        } else {
          _showErrorDialog('Erreur lors de la création de la sauvegarde.');
        }
      }
    } catch (e) {
      _showErrorDialog('Erreur: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showResetDialog(ResetType resetType) {
    showDialog(
      context: context,
      builder: (context) => ResetConfirmationDialog(
        resetType: resetType,
        onConfirm: () => _performReset(resetType),
      ),
    );
  }

  Future<void> _performReset(ResetType resetType) async {
    setState(() => _isLoading = true);
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user == null) return;

      bool success = false;
      
      if (resetType == ResetType.businessOnly) {
        // Supprimer seulement les données business
        await _localStorage.clearBusinessData();
        success = true;
      } else {
        // Réinitialisation complète
        success = await _resetService.resetUserData(
          userId: authProvider.user!.id,
          keepSettings: false,
          keepImages: false,
        );
      }

      if (success) {
        _showSuccessDialog(
          'Réinitialisation terminée !',
          resetType == ResetType.businessOnly 
            ? 'Vos données business ont été supprimées.'
            : 'Toutes vos données ont été supprimées. Vous êtes maintenant comme un utilisateur nouveau.',
        );
        await _loadUserDataSize();
      } else {
        _showErrorDialog('Erreur lors de la réinitialisation.');
      }
    } catch (e) {
      _showErrorDialog('Erreur: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.error, color: Colors.red, size: 48),
        title: const Text('Erreur'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _navigateToBackup() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const BackupScreen(),
      ),
    );
  }
}

enum ResetType { businessOnly, complete }

class ResetConfirmationDialog extends StatefulWidget {
  final ResetType resetType;
  final VoidCallback onConfirm;

  const ResetConfirmationDialog({
    super.key,
    required this.resetType,
    required this.onConfirm,
  });

  @override
  State<ResetConfirmationDialog> createState() => _ResetConfirmationDialogState();
}

class _ResetConfirmationDialogState extends State<ResetConfirmationDialog> {
  final TextEditingController _confirmController = TextEditingController();
  bool _canConfirm = false;

  @override
  Widget build(BuildContext context) {
    final isComplete = widget.resetType == ResetType.complete;
    final confirmText = isComplete ? 'SUPPRIMER TOUT' : 'SUPPRIMER BUSINESS';
    
    return AlertDialog(
      icon: Icon(Icons.warning, color: Colors.red, size: 48),
      title: Text(isComplete ? 'Réinitialisation Complète' : 'Suppression Données Business'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isComplete 
              ? 'Cette action va supprimer TOUTES vos données :\n• Produits\n• Factures\n• Clients\n• Paramètres\n• Images\n\nVous redeviendrez comme un utilisateur nouveau.'
              : 'Cette action va supprimer vos données business :\n• Produits\n• Factures\n• Clients\n• Fournisseurs\n\nVos paramètres seront conservés.',
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
          const Text('Pour confirmer, tapez exactement :'),
          Text(confirmText, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _confirmController,
            decoration: const InputDecoration(
              hintText: 'Tapez ici...',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _canConfirm = value == confirmText;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _canConfirm ? () {
            Navigator.of(context).pop();
            widget.onConfirm();
          } : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Confirmer'),
        ),
      ],
    );
  }
}

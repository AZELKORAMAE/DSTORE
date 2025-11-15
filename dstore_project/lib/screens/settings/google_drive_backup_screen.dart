import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../services/google_drive_service.dart';

class GoogleDriveBackupScreen extends StatefulWidget {
  const GoogleDriveBackupScreen({super.key});

  @override
  State<GoogleDriveBackupScreen> createState() => _GoogleDriveBackupScreenState();
}

class _GoogleDriveBackupScreenState extends State<GoogleDriveBackupScreen> {
  final GoogleDriveService _driveService = GoogleDriveService.instance;
  
  bool _isLoading = false;
  List<Map<String, dynamic>> _backups = [];

  @override
  void initState() {
    super.initState();
    _checkSignInStatus();
  }

  Future<void> _checkSignInStatus() async {
    if (_driveService.isSignedIn) {
      await _loadBackups();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sauvegarde Google Drive'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (_driveService.isSignedIn)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _isLoading ? null : _loadBackups,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    if (!_driveService.isSignedIn) {
      return _buildSignInSection();
    }

    return Column(
      children: [
        _buildAccountSection(),
        _buildActionsSection(),
        const Divider(),
        Expanded(child: _buildBackupsList()),
      ],
    );
  }

  Widget _buildSignInSection() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            const Text(
              'Connectez-vous à Google Drive',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sauvegardez et synchronisez vos données DSTORE sur tous vos appareils avec Google Drive.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _signIn,
              icon: const Icon(Icons.login),
              label: const Text('Se connecter à Google Drive'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection() {
    final user = _driveService.currentUser;
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: user?.photoUrl != null 
                  ? NetworkImage(user!.photoUrl!) 
                  : null,
              child: user?.photoUrl == null 
                  ? const Icon(Icons.person) 
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.displayName ?? 'Utilisateur',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: _signOut,
              child: const Text('Déconnexion'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _createBackup,
              icon: const Icon(Icons.cloud_upload),
              label: const Text('Sauvegarder'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _loadBackups,
              icon: const Icon(Icons.refresh),
              label: const Text('Actualiser'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackupsList() {
    if (_backups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_queue,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucune sauvegarde trouvée',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Créez votre première sauvegarde',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _backups.length,
      itemBuilder: (context, index) {
        final backup = _backups[index];
        return _buildBackupItem(backup);
      },
    );
  }

  Widget _buildBackupItem(Map<String, dynamic> backup) {
    final createdTime = backup['createdTime'] != null 
        ? DateTime.parse(backup['createdTime'])
        : DateTime.now();
    
    final formattedDate = DateFormat('dd/MM/yyyy à HH:mm').format(createdTime);
    final size = backup['size'] != null 
        ? _formatBytes(int.parse(backup['size']))
        : 'Taille inconnue';

    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.cloud, color: Colors.white),
        ),
        title: Text(backup['name'] ?? 'Sauvegarde'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Créée le $formattedDate'),
            Text('Taille: $size', style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'restore',
              child: const Row(
                children: [
                  Icon(Icons.cloud_download, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Restaurer'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: const Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Supprimer'),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'restore') {
              _restoreBackup(backup['id']);
            } else if (value == 'delete') {
              _deleteBackup(backup['id']);
            }
          },
        ),
      ),
    );
  }

  Future<void> _signIn() async {
    setState(() => _isLoading = true);
    
    try {
      final success = await _driveService.signIn();
      if (success) {
        await _loadBackups();
        _showSuccessSnackBar('Connexion réussie à Google Drive');
      } else {
        _showErrorSnackBar('Échec de la connexion à Google Drive');
      }
    } catch (e) {
      _showErrorSnackBar('Erreur: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    await _driveService.signOut();
    setState(() {
      _backups.clear();
    });
    _showSuccessSnackBar('Déconnexion réussie');
  }

  Future<void> _createBackup() async {
    setState(() => _isLoading = true);
    
    try {
      final fileId = await _driveService.backupToGoogleDrive();
      if (fileId != null) {
        await _loadBackups();
        _showSuccessSnackBar('Sauvegarde créée avec succès');
      } else {
        _showErrorSnackBar('Échec de la création de la sauvegarde');
      }
    } catch (e) {
      _showErrorSnackBar('Erreur: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadBackups() async {
    setState(() => _isLoading = true);

    try {
      final backups = await _driveService.listBackups();
      setState(() {
        _backups = backups;
      });
    } catch (e) {
      _showErrorSnackBar('Erreur chargement sauvegardes: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _restoreBackup(String fileId) async {
    final confirmed = await _showRestoreConfirmDialog();
    if (!confirmed) return;

    setState(() => _isLoading = true);

    try {
      final success = await _driveService.restoreFromGoogleDrive(fileId);
      if (success) {
        _showSuccessSnackBar('Restauration réussie');
      } else {
        _showErrorSnackBar('Échec de la restauration');
      }
    } catch (e) {
      _showErrorSnackBar('Erreur: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteBackup(String fileId) async {
    final confirmed = await _showDeleteConfirmDialog();
    if (!confirmed) return;

    setState(() => _isLoading = true);

    try {
      final success = await _driveService.deleteBackup(fileId);
      if (success) {
        await _loadBackups();
        _showSuccessSnackBar('Sauvegarde supprimée');
      } else {
        _showErrorSnackBar('Échec de la suppression');
      }
    } catch (e) {
      _showErrorSnackBar('Erreur: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<bool> _showRestoreConfirmDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la restauration'),
        content: const Text(
          'Cette action va remplacer toutes vos données actuelles par celles de la sauvegarde. Voulez-vous continuer ?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Restaurer'),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<bool> _showDeleteConfirmDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text(
          'Voulez-vous vraiment supprimer cette sauvegarde de Google Drive ?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

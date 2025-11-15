import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../config/app_theme.dart';
import '../../services/backup_service.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final BackupService _backupService = BackupService.instance;
  
  bool _isLoading = false;
  List<Map<String, dynamic>> _backups = [];

  @override
  void initState() {
    super.initState();
    _loadBackups();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sauvegarde et Restauration'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadBackups,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Traitement en cours...'),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildActionsSection(),
                  if (_backups.isNotEmpty) ...[
                    const Divider(),
                    _buildBackupsList(),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildActionsSection() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700, size: 32),
                const SizedBox(height: 8),
                Text(
                  'Sauvegarde et Restauration',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Utilisez "Sauvegarder" pour créer un fichier de vos données.\nUtilisez "Importer" pour restaurer des données depuis un fichier.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Les 2 boutons principaux
          Row(
            children: [
              // Bouton Sauvegarder
              Expanded(
                child: Container(
                  height: 120,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _downloadBackup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.save_alt, size: 40),
                        const SizedBox(height: 8),
                        const Text(
                          'SAUVEGARDER',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Créer un fichier\nde sauvegarde',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Bouton Importer
              Expanded(
                child: Container(
                  height: 120,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _importBackup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.file_upload, size: 40),
                        const SizedBox(height: 8),
                        const Text(
                          'IMPORTER',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Restaurer depuis\nun fichier',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackupsList() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sauvegardes créées (${_backups.length})',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...(_backups.map((backup) => _buildBackupItem(backup)).toList()),
        ],
      ),
    );
  }

  Widget _buildBackupItem(Map<String, dynamic> backup) {
    final createdTime = backup['created'] as DateTime;
    final formattedDate = DateFormat('dd/MM/yyyy à HH:mm').format(createdTime);
    final size = backup['formattedSize'] as String;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.green,
          child: Icon(Icons.backup, color: Colors.white),
        ),
        title: Text(
          backup['name'] ?? 'Sauvegarde',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Créée le $formattedDate'),
            Text('Taille: $size', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.share, color: Colors.blue),
              onPressed: () => _shareSpecificBackup(backup['path']),
              tooltip: 'Partager',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteBackup(backup['path']),
              tooltip: 'Supprimer',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createBackup() async {
    setState(() => _isLoading = true);
    
    try {
      final backupPath = await _backupService.createBackup();
      if (backupPath != null) {
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

  Future<void> _downloadBackup() async {
    setState(() => _isLoading = true);

    try {
      // Créer et partager la sauvegarde
      final backupPath = await _backupService.shareBackup();
      if (backupPath != null) {
        await _loadBackups();
        _showSuccessSnackBar('Sauvegarde créée et partagée avec succès');
      } else {
        _showErrorSnackBar('Échec de la création de la sauvegarde');
      }
    } catch (e) {
      _showErrorSnackBar('Erreur: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _shareSpecificBackup(String filePath) async {
    setState(() => _isLoading = true);
    
    try {
      // Partager un fichier spécifique
      await Share.shareXFiles([XFile(filePath)]);
      _showSuccessSnackBar('Sauvegarde partagée');
    } catch (e) {
      _showErrorSnackBar('Erreur partage: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _importBackup() async {
    setState(() => _isLoading = true);

    try {
      final success = await _backupService.importBackup();
      if (success) {
        await _loadBackups();
        _showSuccessSnackBar('Sauvegarde importée et restaurée avec succès');
      } else {
        _showErrorSnackBar('Importation annulée ou échec');
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
      // Charger seulement les sauvegardes locales
      final backups = await _backupService.listLocalBackups();
      setState(() {
        _backups = backups;
      });
    } catch (e) {
      _showErrorSnackBar('Erreur chargement sauvegardes: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }



  Future<void> _deleteBackup(String filePath) async {
    final confirmed = await _showDeleteConfirmDialog();
    if (!confirmed) return;

    setState(() => _isLoading = true);
    
    try {
      final success = await _backupService.deleteBackup(filePath);
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



  Future<bool> _showDeleteConfirmDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text(
          'Voulez-vous vraiment supprimer cette sauvegarde ?'
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
}

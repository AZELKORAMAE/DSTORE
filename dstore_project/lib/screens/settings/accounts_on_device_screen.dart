import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/account_device_service.dart';
import '../../utils/app_utils.dart';

class AccountsOnDeviceScreen extends StatefulWidget {
  const AccountsOnDeviceScreen({super.key});

  @override
  State<AccountsOnDeviceScreen> createState() => _AccountsOnDeviceScreenState();
}

class _AccountsOnDeviceScreenState extends State<AccountsOnDeviceScreen> {
  List<Map<String, dynamic>> _accounts = [];
  Map<String, int> _stats = {'total': 0, 'authorized': 0, 'unauthorized': 0};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final accounts = await AccountDeviceService.getAccountsOnCurrentDevice();
      final stats = await AccountDeviceService.getAccountStatsOnCurrentDevice();
      
      setState(() {
        _accounts = accounts;
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du chargement des comptes: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comptes sur cet appareil'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadAccounts,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'cleanup',
                child: Row(
                  children: [
                    Icon(Icons.cleaning_services, size: 20),
                    SizedBox(width: 8),
                    Text('Nettoyer les inactifs'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'remove_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Supprimer tous', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Erreur de chargement',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAccounts,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAccounts,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsCard(),
            const SizedBox(height: 16),
            _buildAccountsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.phone_android,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  'Comptes sur cet appareil',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total',
                    _stats['total'].toString(),
                    Icons.account_circle,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Autorisés',
                    _stats['authorized'].toString(),
                    Icons.verified,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Non autorisés',
                    _stats['unauthorized'].toString(),
                    Icons.pending,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountsList() {
    if (_accounts.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.account_circle_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucun compte trouvé',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Aucun compte n\'a encore accédé à cet appareil',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comptes (${_accounts.length})',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...(_accounts.map((account) => _buildAccountCard(account))),
      ],
    );
  }

  Widget _buildAccountCard(Map<String, dynamic> account) {
    final isAuthorized = account['is_authorized'] as bool;
    final lastLogin = account['last_login_at'] as DateTime;
    final createdAt = account['created_at'] as DateTime;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: isAuthorized ? Colors.green : Colors.orange,
                    child: Icon(
                      isAuthorized ? Icons.verified : Icons.pending,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account['user_name'] ?? 'Utilisateur',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          account['email'] ?? '',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(isAuthorized),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Dernière connexion: ${_formatDateTime(lastLogin)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Premier accès: ${_formatDateTime(createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildAccountActions(account),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool isAuthorized) {
    final color = isAuthorized ? Colors.green : Colors.orange;
    final text = isAuthorized ? 'Autorisé' : 'Non autorisé';
    final icon = isAuthorized ? Icons.verified : Icons.pending;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountActions(Map<String, dynamic> account) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.user?.id;
    final accountUserId = account['user_id'] as String;
    final isCurrentUser = currentUserId == accountUserId;

    return Row(
      children: [
        if (isCurrentUser) ...[
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Compte actuellement connecté',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ] else ...[
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _logoutAccount(account),
              icon: const Icon(Icons.logout, size: 16),
              label: const Text('Déconnecter'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _removeAccount(account),
              icon: const Icon(Icons.delete, size: 16),
              label: const Text('Supprimer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'cleanup':
        _cleanupInactiveAccounts();
        break;
      case 'remove_all':
        _removeAllAccounts();
        break;
    }
  }

  void _logoutAccount(Map<String, dynamic> account) async {
    final confirmed = await _showConfirmationDialog(
      'Déconnecter le compte',
      'Êtes-vous sûr de vouloir déconnecter "${account['user_name']}" ?\n\nLes données locales seront conservées.',
      'Déconnecter',
      Colors.orange,
    );

    if (confirmed) {
      final success = await AccountDeviceService.logoutAccountFromCurrentDevice(
        account['user_id'],
      );

      if (success && mounted) {
        AppUtils.showSnackBar(
          context,
          'Compte "${account['user_name']}" déconnecté',
          isError: false,
        );
        _loadAccounts();
      } else if (mounted) {
        AppUtils.showSnackBar(
          context,
          'Erreur lors de la déconnexion',
          isError: true,
        );
      }
    }
  }

  void _removeAccount(Map<String, dynamic> account) async {
    final confirmed = await _showConfirmationDialog(
      'Supprimer le compte',
      'Êtes-vous sûr de vouloir supprimer définitivement "${account['user_name']}" de cet appareil ?\n\nToutes les données locales seront supprimées.',
      'Supprimer',
      Colors.red,
    );

    if (confirmed) {
      final success = await AccountDeviceService.removeAccountFromCurrentDevice(
        account['user_id'],
      );

      if (success && mounted) {
        AppUtils.showSnackBar(
          context,
          'Compte "${account['user_name']}" supprimé de cet appareil',
          isError: false,
        );
        _loadAccounts();
      } else if (mounted) {
        AppUtils.showSnackBar(
          context,
          'Erreur lors de la suppression',
          isError: true,
        );
      }
    }
  }

  void _cleanupInactiveAccounts() async {
    final confirmed = await _showConfirmationDialog(
      'Nettoyer les comptes inactifs',
      'Supprimer tous les comptes qui n\'ont pas été utilisés depuis 30 jours ?',
      'Nettoyer',
      Colors.blue,
    );

    if (confirmed) {
      final count = await AccountDeviceService.cleanupInactiveAccounts();

      if (mounted) {
        AppUtils.showSnackBar(
          context,
          '$count compte(s) inactif(s) supprimé(s)',
          isError: false,
        );
        _loadAccounts();
      }
    }
  }

  void _removeAllAccounts() async {
    final confirmed = await _showConfirmationDialog(
      'Supprimer tous les comptes',
      'Êtes-vous sûr de vouloir supprimer TOUS les comptes de cet appareil ?\n\nCette action est irréversible et supprimera toutes les données locales.',
      'Supprimer tout',
      Colors.red,
    );

    if (confirmed) {
      final success = await AccountDeviceService.removeAllAccountsFromCurrentDevice();

      if (success && mounted) {
        AppUtils.showSnackBar(
          context,
          'Tous les comptes ont été supprimés de cet appareil',
          isError: false,
        );
        _loadAccounts();
      } else if (mounted) {
        AppUtils.showSnackBar(
          context,
          'Erreur lors de la suppression',
          isError: true,
        );
      }
    }
  }

  Future<bool> _showConfirmationDialog(
    String title,
    String content,
    String actionText,
    Color actionColor,
  ) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: actionColor,
              foregroundColor: Colors.white,
            ),
            child: Text(actionText),
          ),
        ],
      ),
    ) ?? false;
  }
}

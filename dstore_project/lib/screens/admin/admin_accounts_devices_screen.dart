import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/admin_auth_service.dart';
import '../../utils/app_utils.dart';

class AdminAccountsDevicesScreen extends StatefulWidget {
  const AdminAccountsDevicesScreen({super.key});

  @override
  State<AdminAccountsDevicesScreen> createState() => _AdminAccountsDevicesScreenState();
}

class _AdminAccountsDevicesScreenState extends State<AdminAccountsDevicesScreen> {
  final _adminService = AdminAuthService.instance;
  List<Map<String, dynamic>> _accountsWithDevices = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkAdminAccess();
  }

  Future<void> _checkAdminAccess() async {
    if (!_adminService.isAdminLoggedIn()) {
      if (mounted) {
        context.go('/admin-login');
      }
      return;
    }
    await _loadAccountsWithDevices();
  }

  Future<void> _loadAccountsWithDevices() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final accountsWithDevices = await _adminService.getAccountsWithDevices();
      
      setState(() {
        _accountsWithDevices = accountsWithDevices;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du chargement: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administration - Comptes et Appareils'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadAccountsWithDevices,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'global_stats',
                child: Row(
                  children: [
                    Icon(Icons.analytics, size: 20),
                    SizedBox(width: 8),
                    Text('Statistiques globales'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'device_limits',
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 20),
                    SizedBox(width: 8),
                    Text('Configurer limites'),
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
              onPressed: _loadAccountsWithDevices,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAccountsWithDevices,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGlobalStatsCard(),
            const SizedBox(height: 16),
            _buildAccountsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildGlobalStatsCard() {
    final totalAccounts = _accountsWithDevices.length;
    final totalDevices = _accountsWithDevices.fold<int>(
      0, 
      (sum, account) => sum + (account['devices'] as List).length
    );
    final authorizedDevices = _accountsWithDevices.fold<int>(
      0, 
      (sum, account) => sum + (account['devices'] as List).where((d) => d['is_authorized'] == true).length
    );
    final accountsWithMultipleDevices = _accountsWithDevices.where(
      (account) => (account['devices'] as List).where((d) => d['is_authorized'] == true).length > 1
    ).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.admin_panel_settings,
                  color: Colors.deepPurple,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  'Contrôle des accès - Vue globale',
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
                    'Comptes totaux',
                    totalAccounts.toString(),
                    Icons.account_circle,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Appareils totaux',
                    totalDevices.toString(),
                    Icons.devices,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Autorisés',
                    authorizedDevices.toString(),
                    Icons.verified,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Multi-appareils',
                    accountsWithMultipleDevices.toString(),
                    Icons.warning,
                    Colors.red,
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
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAccountsList() {
    if (_accountsWithDevices.isEmpty) {
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
                  'Aucun compte utilisateur n\'est encore enregistré',
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
          'Comptes utilisateurs (${_accountsWithDevices.length})',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ..._accountsWithDevices.map((account) => _buildAccountCard(account)),
      ],
    );
  }

  Widget _buildAccountCard(Map<String, dynamic> account) {
    final devices = account['devices'] as List;
    final authorizedDevices = devices.where((d) => d['is_authorized'] == true).toList();
    final pendingDevices = devices.where((d) => d['is_authorized'] == false).toList();
    
    final isMultiDevice = authorizedDevices.length > 1;
    final subscriptionStatus = account['subscription_status'] ?? 'unknown';
    final subscriptionType = account['subscription_type'] ?? 'basic';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: isMultiDevice ? 4 : 2,
        color: isMultiDevice ? Colors.red[50] : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête du compte
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _getAccountStatusColor(subscriptionStatus),
                    child: Icon(
                      _getAccountStatusIcon(subscriptionStatus),
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
                          account['email'] ?? 'Email inconnu',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${subscriptionType.toUpperCase()} • ${subscriptionStatus.toUpperCase()}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _getAccountStatusColor(subscriptionStatus),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isMultiDevice)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.warning, color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'MULTI-APPAREILS',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Statistiques des appareils
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildDeviceStatItem(
                        'Total',
                        devices.length.toString(),
                        Icons.devices,
                        Colors.blue,
                      ),
                    ),
                    Expanded(
                      child: _buildDeviceStatItem(
                        'Autorisés',
                        authorizedDevices.length.toString(),
                        Icons.verified,
                        Colors.green,
                      ),
                    ),
                    Expanded(
                      child: _buildDeviceStatItem(
                        'En attente',
                        pendingDevices.length.toString(),
                        Icons.pending,
                        Colors.orange,
                      ),
                    ),
                    Expanded(
                      child: _buildDeviceStatItem(
                        'Limite',
                        _getDeviceLimit(subscriptionType).toString(),
                        Icons.security,
                        Colors.purple,
                      ),
                    ),
                  ],
                ),
              ),

              if (devices.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Appareils connectés :',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ...devices.map((device) => _buildDeviceItem(account, device)),
              ],

              const SizedBox(height: 12),
              _buildAccountActions(account),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceItem(Map<String, dynamic> account, Map<String, dynamic> device) {
    final isAuthorized = device['is_authorized'] as bool;
    final deviceName = device['device_name'] as String;
    final platform = device['platform'] as String;
    final lastLogin = DateTime.tryParse(device['last_login_at'] ?? '') ?? DateTime.now();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isAuthorized ? Colors.green[300]! : Colors.orange[300]!,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: isAuthorized ? Colors.green[50] : Colors.orange[50],
      ),
      child: Row(
        children: [
          Icon(
            _getPlatformIcon(platform),
            color: isAuthorized ? Colors.green : Colors.orange,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deviceName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${platform.toUpperCase()} • ${_formatLastLogin(lastLogin)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          _buildDeviceStatusChip(isAuthorized),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            onSelected: (action) => _handleDeviceAction(action, account, device),
            itemBuilder: (context) => [
              if (!isAuthorized)
                const PopupMenuItem(
                  value: 'authorize',
                  child: Row(
                    children: [
                      Icon(Icons.check, color: Colors.green, size: 16),
                      SizedBox(width: 8),
                      Text('Autoriser'),
                    ],
                  ),
                ),
              if (isAuthorized)
                const PopupMenuItem(
                  value: 'revoke',
                  child: Row(
                    children: [
                      Icon(Icons.block, color: Colors.orange, size: 16),
                      SizedBox(width: 8),
                      Text('Révoquer'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'remove',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red, size: 16),
                    SizedBox(width: 8),
                    Text('Supprimer'),
                  ],
                ),
              ),
            ],
            child: const Icon(Icons.more_vert, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceStatusChip(bool isAuthorized) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isAuthorized ? Colors.green : Colors.orange,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        isAuthorized ? 'AUTORISÉ' : 'EN ATTENTE',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAccountActions(Map<String, dynamic> account) {
    final devices = account['devices'] as List;
    final authorizedCount = devices.where((d) => d['is_authorized'] == true).length;
    final subscriptionType = account['subscription_type'] ?? 'basic';
    final deviceLimit = _getDeviceLimit(subscriptionType);
    final isOverLimit = authorizedCount > deviceLimit;

    return Row(
      children: [
        if (isOverLimit)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _enforceDeviceLimit(account),
              icon: const Icon(Icons.security, size: 16),
              label: const Text('APPLIQUER LIMITE'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        if (isOverLimit) const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _suspendAccount(account),
            icon: const Icon(Icons.pause, size: 16),
            label: const Text('Suspendre'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orange,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showAccountDetails(account),
            icon: const Icon(Icons.info, size: 16),
            label: const Text('Détails'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }

  // Méthodes utilitaires
  Color _getAccountStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'suspended':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getAccountStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'suspended':
        return Icons.block;
      default:
        return Icons.help;
    }
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'android':
        return Icons.android;
      case 'ios':
        return Icons.phone_iphone;
      case 'windows':
        return Icons.computer;
      case 'web':
        return Icons.web;
      default:
        return Icons.device_unknown;
    }
  }

  int _getDeviceLimit(String subscriptionType) {
    switch (subscriptionType.toLowerCase()) {
      case 'basic':
        return 1;
      case 'premium':
        return 2;
      case 'family':
        return 4;
      default:
        return 1;
    }
  }

  String _formatLastLogin(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes}min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays}j';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }

  // Actions
  void _handleMenuAction(String action) {
    switch (action) {
      case 'global_stats':
        _showGlobalStats();
        break;
      case 'device_limits':
        _configureDeviceLimits();
        break;
    }
  }

  void _handleDeviceAction(String action, Map<String, dynamic> account, Map<String, dynamic> device) {
    switch (action) {
      case 'authorize':
        _authorizeDevice(account, device);
        break;
      case 'revoke':
        _revokeDevice(account, device);
        break;
      case 'remove':
        _removeDevice(account, device);
        break;
    }
  }

  void _authorizeDevice(Map<String, dynamic> account, Map<String, dynamic> device) async {
    final success = await _adminService.authorizeUserDevice(
      account['user_id'],
      device['device_id'],
    );

    if (success && mounted) {
      AppUtils.showSnackBar(
        context,
        'Appareil autorisé pour ${account['email']}',
        isError: false,
      );
      _loadAccountsWithDevices();
    } else if (mounted) {
      AppUtils.showSnackBar(
        context,
        'Erreur lors de l\'autorisation',
        isError: true,
      );
    }
  }

  void _revokeDevice(Map<String, dynamic> account, Map<String, dynamic> device) async {
    final confirmed = await _showConfirmationDialog(
      'Révoquer l\'autorisation',
      'Révoquer l\'accès de "${device['device_name']}" pour ${account['email']} ?',
      'Révoquer',
      Colors.orange,
    );

    if (confirmed) {
      final success = await _adminService.revokeUserDevice(
        account['user_id'],
        device['device_id'],
      );

      if (success && mounted) {
        AppUtils.showSnackBar(
          context,
          'Autorisation révoquée',
          isError: false,
        );
        _loadAccountsWithDevices();
      } else if (mounted) {
        AppUtils.showSnackBar(
          context,
          'Erreur lors de la révocation',
          isError: true,
        );
      }
    }
  }

  void _removeDevice(Map<String, dynamic> account, Map<String, dynamic> device) async {
    final confirmed = await _showConfirmationDialog(
      'Supprimer l\'appareil',
      'Supprimer définitivement "${device['device_name']}" du compte ${account['email']} ?',
      'Supprimer',
      Colors.red,
    );

    if (confirmed) {
      final success = await _adminService.removeUserDevice(
        account['user_id'],
        device['device_id'],
      );

      if (success && mounted) {
        AppUtils.showSnackBar(
          context,
          'Appareil supprimé',
          isError: false,
        );
        _loadAccountsWithDevices();
      } else if (mounted) {
        AppUtils.showSnackBar(
          context,
          'Erreur lors de la suppression',
          isError: true,
        );
      }
    }
  }

  void _enforceDeviceLimit(Map<String, dynamic> account) async {
    final confirmed = await _showConfirmationDialog(
      'Appliquer la limite d\'appareils',
      'Révoquer l\'accès aux appareils en excès pour ${account['email']} ?',
      'Appliquer',
      Colors.red,
    );

    if (confirmed) {
      final success = await _adminService.enforceDeviceLimit(account['user_id']);

      if (success && mounted) {
        AppUtils.showSnackBar(
          context,
          'Limite d\'appareils appliquée',
          isError: false,
        );
        _loadAccountsWithDevices();
      } else if (mounted) {
        AppUtils.showSnackBar(
          context,
          'Erreur lors de l\'application de la limite',
          isError: true,
        );
      }
    }
  }

  void _suspendAccount(Map<String, dynamic> account) async {
    final confirmed = await _showConfirmationDialog(
      'Suspendre le compte',
      'Suspendre temporairement le compte ${account['email']} ?',
      'Suspendre',
      Colors.orange,
    );

    if (confirmed) {
      final success = await _adminService.suspendUser(account['user_id']);

      if (success && mounted) {
        AppUtils.showSnackBar(
          context,
          'Compte suspendu',
          isError: false,
        );
        _loadAccountsWithDevices();
      } else if (mounted) {
        AppUtils.showSnackBar(
          context,
          'Erreur lors de la suspension',
          isError: true,
        );
      }
    }
  }

  void _showAccountDetails(Map<String, dynamic> account) {
    AppUtils.showSnackBar(
      context,
      'Détails du compte en cours de développement',
      isError: false,
    );
  }

  void _showGlobalStats() {
    AppUtils.showSnackBar(
      context,
      'Statistiques globales en cours de développement',
      isError: false,
    );
  }

  void _configureDeviceLimits() {
    AppUtils.showSnackBar(
      context,
      'Configuration des limites en cours de développement',
      isError: false,
    );
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

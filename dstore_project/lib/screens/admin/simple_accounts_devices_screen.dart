import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/admin_auth_service.dart';
import '../../utils/app_utils.dart';

class SimpleAccountsDevicesScreen extends StatefulWidget {
  const SimpleAccountsDevicesScreen({super.key});

  @override
  State<SimpleAccountsDevicesScreen> createState() => _SimpleAccountsDevicesScreenState();
}

class _SimpleAccountsDevicesScreenState extends State<SimpleAccountsDevicesScreen> {
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
        title: const Text('Comptes et Appareils'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadAccountsWithDevices,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text('Erreur de chargement', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadAccountsWithDevices, child: const Text('Réessayer')),
          ],
        ),
      );
    }

    if (_accountsWithDevices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_circle_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Aucun compte trouvé',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600])),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAccountsWithDevices,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _accountsWithDevices.length,
        itemBuilder: (context, index) {
          final account = _accountsWithDevices[index];
          return _buildAccountCard(account);
        },
      ),
    );
  }

  Widget _buildAccountCard(Map<String, dynamic> account) {
    final devices = account['devices'] as List;
    final email = account['email'] ?? 'Email inconnu';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.deepPurple,
                    child: Text(
                      email.substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(email,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        Text('${devices.length} appareil(s) connecté(s)',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.grey[600])),
                      ],
                    ),
                  ),
                ],
              ),

              if (devices.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Text('Appareils connectés :',
                    style:
                        Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ...devices.map((device) => _buildDeviceItem(account, device)),
              ] else ...[
                const SizedBox(height: 16),
                Center(
                  child: Text('Aucun appareil connecté',
                      style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceItem(Map<String, dynamic> account, Map<String, dynamic> device) {
    final deviceName = (device['device_name'] as String?) ?? 'Appareil';
    final platform = (device['platform'] as String?) ?? 'unknown';
    final lastLogin = DateTime.tryParse(device['last_login_at'] ?? '') ?? DateTime.now();
    final isAuthorized = device['is_authorized'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[50],
      ),
      child: Row(
        children: [
          Icon(_getPlatformIcon(platform), color: Colors.deepPurple, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(deviceName,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isAuthorized ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isAuthorized ? Colors.green : Colors.orange, width: 1),
                      ),
                      child: Text(
                        isAuthorized ? 'AUTORISÉ' : 'SUSPENDU',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isAuthorized ? Colors.green.shade700 : Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${platform.toUpperCase()} • ${_formatLastLogin(lastLogin)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          // Autoriser / Suspendre
          ElevatedButton.icon(
            onPressed: () => _suspendDeviceAccess(account, device),
            icon: Icon(isAuthorized ? Icons.pause_circle : Icons.play_circle, size: 16),
            label: Text(isAuthorized ? 'Suspendre' : 'Autoriser'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isAuthorized ? Colors.orange : Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          const SizedBox(width: 8),
          // SUPPRIMER
          OutlinedButton.icon(
            onPressed: () => _deleteDevice(account, device),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Supprimer'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'android':
        return Icons.android;
      case 'ios':
        return Icons.phone_iphone;
      case 'windows':
      case 'macos':
      case 'linux':
        return Icons.computer;
      case 'web':
        return Icons.web;
      default:
        return Icons.device_unknown;
    }
  }

  String _formatLastLogin(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes}min';
    if (diff.inHours   < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays    < 7)  return 'Il y a ${diff.inDays}j';
    return '${dateTime.day}/${dateTime.month}';
    }

  void _suspendDeviceAccess(Map<String, dynamic> account, Map<String, dynamic> device) async {
    final isAuthorized = device['is_authorized'] == true;
    final action = isAuthorized ? 'suspendre' : 'autoriser';
    final actionCapitalized = isAuthorized ? 'Suspendre' : 'Autoriser';

    // si on autorise, vérifier la limite de 3
    if (!isAuthorized) {
      final devices = account['devices'] as List;
      final authorizedDevices = devices.where((d) => d['is_authorized'] == true).length;
      const maxDevices = 3;
      if (authorizedDevices >= maxDevices) {
        if (mounted) {
          AppUtils.showSnackBar(
            context,
            '❌ Dépassé nombre d\'appareils par compte\n'
            'Maximum: $maxDevices • Actuels: $authorizedDevices',
            isError: true,
          );
        }
        return;
      }
    }

    final confirmed = await _showConfirmationDialog(
      '$actionCapitalized l\'accès',
      'Êtes-vous sûr de vouloir $action l\'accès de "${device['device_name']}" pour ${account['email']} ?',
      actionCapitalized,
    );

    if (confirmed) {
      final success = await _adminService.updateDeviceAuthorization(
        account['user_id'],
        device['device_id'],
        !isAuthorized,
      );

      if (success && mounted) {
        AppUtils.showSnackBar(
          context,
          '✅ Accès ${isAuthorized ? "suspendu" : "autorisé"} pour "${device['device_name']}"',
          isError: false,
        );
        _loadAccountsWithDevices();
      } else if (mounted) {
        AppUtils.showSnackBar(context, '❌ Erreur lors de la modification de l\'accès', isError: true);
      }
    }
  }

  Future<void> _deleteDevice(Map<String, dynamic> account, Map<String, dynamic> device) async {
    final ok = await _showConfirmationDialog(
      'Supprimer l\'appareil',
      'Supprimer définitivement "${device['device_name']}" pour ${account['email']} ?',
      'Supprimer',
    );

    if (ok) {
      final success = await _adminService.deleteDevice(
        account['user_id'],
        device['device_id'],
      );
      if (success && mounted) {
        AppUtils.showSnackBar(context, '🗑️ Appareil supprimé', isError: false);
        _loadAccountsWithDevices();
      } else if (mounted) {
        AppUtils.showSnackBar(context, '❌ Suppression impossible', isError: true);
      }
    }
  }

  Future<bool> _showConfirmationDialog(String title, String content, String actionText) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annuler')),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                child: Text(actionText),
              ),
            ],
          ),
        ) ??
        false;
  }
}

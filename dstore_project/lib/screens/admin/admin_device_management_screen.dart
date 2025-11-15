import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/device_provider.dart';
import '../../services/admin_auth_service.dart';
import '../settings/device_management_actions.dart';
import '../../models/device_model.dart';

class AdminDeviceManagementScreen extends StatefulWidget {
  const AdminDeviceManagementScreen({super.key});

  @override
  State<AdminDeviceManagementScreen> createState() => _AdminDeviceManagementScreenState();
}

class _AdminDeviceManagementScreenState extends State<AdminDeviceManagementScreen> {
  final _adminService = AdminAuthService.instance;
  List<Map<String, dynamic>> _allUserDevices = [];
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
    await _loadAllDevices();
  }

  Future<void> _loadAllDevices() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Récupérer tous les appareils de tous les utilisateurs
      final devices = await _adminService.getAllUserDevices();
      
      setState(() {
        _allUserDevices = devices;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du chargement des appareils: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administration - Gestion des appareils'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadAllDevices,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'cleanup_all',
                child: Row(
                  children: [
                    Icon(Icons.cleaning_services, size: 20),
                    SizedBox(width: 8),
                    Text('Nettoyer tous les inactifs'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'stats',
                child: Row(
                  children: [
                    Icon(Icons.analytics, size: 20),
                    SizedBox(width: 8),
                    Text('Statistiques globales'),
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
              onPressed: _loadAllDevices,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAllDevices,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGlobalStatsCard(),
            const SizedBox(height: 16),
            _buildDevicesByUserSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildGlobalStatsCard() {
    final totalDevices = _allUserDevices.length;
    final authorizedDevices = _allUserDevices.where((d) => d['is_authorized'] == true).length;
    final pendingDevices = totalDevices - authorizedDevices;
    final uniqueUsers = _allUserDevices.map((d) => d['user_id']).toSet().length;

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
                  'Statistiques globales des appareils',
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
                    'Total appareils',
                    totalDevices.toString(),
                    Icons.devices,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Autorisés',
                    authorizedDevices.toString(),
                    Icons.verified,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'En attente',
                    pendingDevices.toString(),
                    Icons.pending,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Utilisateurs',
                    uniqueUsers.toString(),
                    Icons.people,
                    Colors.purple,
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

  Widget _buildDevicesByUserSection() {
    if (_allUserDevices.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.devices_other,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucun appareil trouvé',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Aucun appareil n\'est encore enregistré dans le système',
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

    // Grouper les appareils par utilisateur
    final devicesByUser = <String, List<Map<String, dynamic>>>{};
    for (final device in _allUserDevices) {
      final userId = device['user_id'] as String;
      devicesByUser.putIfAbsent(userId, () => []).add(device);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Appareils par utilisateur (${devicesByUser.length} utilisateurs)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...devicesByUser.entries.map((entry) => _buildUserDevicesCard(entry.key, entry.value)),
      ],
    );
  }

  Widget _buildUserDevicesCard(String userId, List<Map<String, dynamic>> devices) {
    final authorizedCount = devices.where((d) => d['is_authorized'] == true).length;
    final pendingCount = devices.length - authorizedCount;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
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
                      userId.substring(0, 2).toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Utilisateur ${userId.substring(0, 8)}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${devices.length} appareil(s) • $authorizedCount autorisé(s) • $pendingCount en attente',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...devices.map((device) => _buildAdminDeviceCard(device)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminDeviceCard(Map<String, dynamic> device) {
    // Convertir en DeviceModel pour utiliser les actions existantes
    final deviceModel = DeviceModel(
      id: device['id'] ?? '',
      userId: device['user_id'] ?? '',
      deviceId: device['device_id'] ?? '',
      deviceName: device['device_name'] ?? 'Appareil inconnu',
      deviceType: device['device_type'] ?? 'mobile',
      platform: device['platform'] ?? 'unknown',
      appVersion: device['app_version'] ?? '1.0.0',
      osVersion: device['os_version'] ?? 'unknown',
      isAuthorized: device['is_authorized'] ?? false,
      isCurrentDevice: false, // Jamais l'appareil actuel en mode admin
      firstLoginAt: DateTime.tryParse(device['first_login_at'] ?? '') ?? DateTime.now(),
      lastLoginAt: DateTime.tryParse(device['last_login_at'] ?? '') ?? DateTime.now(),
      createdAt: DateTime.tryParse(device['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(device['updated_at'] ?? '') ?? DateTime.now(),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: DeviceManagementActions.buildDeviceCard(
        context,
        deviceModel,
        Provider.of<DeviceProvider>(context, listen: false),
        isPending: !deviceModel.isAuthorized,
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'cleanup_all':
        _cleanupAllInactiveDevices();
        break;
      case 'stats':
        _showGlobalStats();
        break;
    }
  }

  void _cleanupAllInactiveDevices() async {
    // TODO: Implémenter le nettoyage global
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité de nettoyage global en cours de développement'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showGlobalStats() async {
    // TODO: Implémenter l'affichage des statistiques détaillées
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Statistiques détaillées en cours de développement'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

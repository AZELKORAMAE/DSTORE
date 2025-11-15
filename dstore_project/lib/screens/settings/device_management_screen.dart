import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/device_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/device_model.dart';
import '../../utils/app_utils.dart';
import 'device_management_actions.dart';

class DeviceManagementScreen extends StatefulWidget {
  const DeviceManagementScreen({super.key});

  @override
  State<DeviceManagementScreen> createState() => _DeviceManagementScreenState();
}

class _DeviceManagementScreenState extends State<DeviceManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDevices();
    });
  }

  void _loadDevices() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final deviceProvider = Provider.of<DeviceProvider>(context, listen: false);
    
    if (authProvider.currentUser != null) {
      deviceProvider.loadUserDevices(authProvider.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des appareils'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadDevices,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: Consumer<DeviceProvider>(
        builder: (context, deviceProvider, child) {
          if (deviceProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (deviceProvider.error != null) {
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
                    deviceProvider.error!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadDevices,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadDevices(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(deviceProvider),
                  const SizedBox(height: 16),
                  if (deviceProvider.hasPendingDevices) ...[
                    _buildPendingDevicesSection(deviceProvider),
                    const SizedBox(height: 16),
                  ],
                  _buildAuthorizedDevicesSection(deviceProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(DeviceProvider deviceProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.devices,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  'Résumé des appareils',
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
                  child: _buildSummaryItem(
                    'Total',
                    deviceProvider.totalDevicesCount.toString(),
                    Icons.devices,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Autorisés',
                    deviceProvider.authorizedDevicesCount.toString(),
                    Icons.verified,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'En attente',
                    deviceProvider.pendingDevicesCount.toString(),
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

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
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

  Widget _buildPendingDevicesSection(DeviceProvider deviceProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.pending_actions,
                  color: Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Appareils en attente d\'autorisation',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${deviceProvider.pendingDevicesCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...deviceProvider.pendingDevices.map((device) =>
              DeviceManagementActions.buildDeviceCard(context, device, deviceProvider, isPending: true)
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorizedDevicesSection(DeviceProvider deviceProvider) {
    final authorizedDevices = deviceProvider.authorizedDevices;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.verified,
                  color: Colors.green,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Appareils autorisés',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (authorizedDevices.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.devices_other,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Aucun appareil autorisé',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...authorizedDevices.map((device) =>
                DeviceManagementActions.buildDeviceCard(context, device, deviceProvider, isPending: false)
              ),
          ],
        ),
      ),
    );
  }
}

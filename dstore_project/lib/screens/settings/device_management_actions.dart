import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/device_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/device_model.dart';
import '../../utils/app_utils.dart';

class DeviceManagementActions {
  static Widget buildDeviceCard(
    BuildContext context,
    DeviceModel device, 
    DeviceProvider deviceProvider, {
    required bool isPending
  }) {
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
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getDeviceColor(device).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      device.platformIcon,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          device.deviceName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${device.platform.toUpperCase()} • ${device.osVersion}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(context, device),
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
                    'Dernière connexion: ${device.lastLoginText}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              if (device.location != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      device.location!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              _buildDeviceActions(context, device, deviceProvider, isPending),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildStatusChip(BuildContext context, DeviceModel device) {
    Color color;
    IconData icon;
    String text;

    if (device.isCurrentDevice) {
      color = Colors.blue;
      icon = Icons.smartphone;
      text = 'Cet appareil';
    } else if (device.isAuthorized) {
      color = Colors.green;
      icon = Icons.verified;
      text = 'Autorisé';
    } else {
      color = Colors.orange;
      icon = Icons.pending;
      text = 'En attente';
    }

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

  static Widget _buildDeviceActions(
    BuildContext context,
    DeviceModel device, 
    DeviceProvider deviceProvider, 
    bool isPending
  ) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id;

    if (userId == null) return const SizedBox.shrink();

    return Row(
      children: [
        if (isPending) ...[
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _authorizeDevice(context, device, deviceProvider, userId),
              icon: const Icon(Icons.check, size: 16),
              label: const Text('Autoriser'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _removeDevice(context, device, deviceProvider, userId),
              icon: const Icon(Icons.delete, size: 16),
              label: const Text('Supprimer'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ),
        ] else ...[
          if (!device.isCurrentDevice) ...[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _revokeDevice(context, device, deviceProvider, userId),
                icon: const Icon(Icons.block, size: 16),
                label: const Text('Révoquer'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _removeDevice(context, device, deviceProvider, userId),
                icon: const Icon(Icons.delete, size: 16),
                label: const Text('Supprimer'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
            ),
          ] else ...[
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Vous utilisez actuellement cet appareil',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }

  static Color _getDeviceColor(DeviceModel device) {
    if (device.isCurrentDevice) return Colors.blue;
    if (device.isAuthorized) return Colors.green;
    return Colors.orange;
  }

  static void _authorizeDevice(
    BuildContext context,
    DeviceModel device, 
    DeviceProvider deviceProvider, 
    String userId
  ) async {
    final success = await deviceProvider.authorizeDevice(device.deviceId, userId);
    if (success && context.mounted) {
      AppUtils.showSnackBar(
        context,
        'Appareil "${device.deviceName}" autorisé avec succès',
        isError: false,
      );
    } else if (context.mounted) {
      AppUtils.showSnackBar(
        context,
        'Erreur lors de l\'autorisation de l\'appareil',
        isError: true,
      );
    }
  }

  static void _revokeDevice(
    BuildContext context,
    DeviceModel device, 
    DeviceProvider deviceProvider, 
    String userId
  ) async {
    final confirmed = await _showConfirmationDialog(
      context,
      'Révoquer l\'autorisation',
      'Êtes-vous sûr de vouloir révoquer l\'autorisation de "${device.deviceName}" ?\n\nCet appareil ne pourra plus accéder à votre compte.',
      'Révoquer',
      Colors.orange,
    );

    if (confirmed && context.mounted) {
      final success = await deviceProvider.revokeDeviceAuthorization(device.deviceId, userId);
      if (success && context.mounted) {
        AppUtils.showSnackBar(
          context,
          'Autorisation révoquée pour "${device.deviceName}"',
          isError: false,
        );
      } else if (context.mounted) {
        AppUtils.showSnackBar(
          context,
          'Erreur lors de la révocation',
          isError: true,
        );
      }
    }
  }

  static void _removeDevice(
    BuildContext context,
    DeviceModel device, 
    DeviceProvider deviceProvider, 
    String userId
  ) async {
    final confirmed = await _showConfirmationDialog(
      context,
      'Supprimer l\'appareil',
      'Êtes-vous sûr de vouloir supprimer définitivement "${device.deviceName}" ?\n\nCette action est irréversible.',
      'Supprimer',
      Colors.red,
    );

    if (confirmed && context.mounted) {
      final success = await deviceProvider.removeDevice(device.deviceId, userId);
      if (success && context.mounted) {
        AppUtils.showSnackBar(
          context,
          'Appareil "${device.deviceName}" supprimé',
          isError: false,
        );
      } else if (context.mounted) {
        AppUtils.showSnackBar(
          context,
          'Erreur lors de la suppression',
          isError: true,
        );
      }
    }
  }

  static Future<bool> _showConfirmationDialog(
    BuildContext context,
    String title, 
    String content, 
    String actionText, 
    Color actionColor
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

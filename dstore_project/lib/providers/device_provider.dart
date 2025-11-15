import 'package:flutter/material.dart';

import '../models/device_model.dart';
import '../services/device_service.dart';

class DeviceProvider with ChangeNotifier {
  List<DeviceModel> _devices = [];
  List<DeviceModel> _pendingDevices = [];
  bool _isLoading = false;
  String? _error;
  DeviceModel? _currentDevice;

  // Getters
  List<DeviceModel> get devices => _devices;
  List<DeviceModel> get pendingDevices => _pendingDevices;
  List<DeviceModel> get authorizedDevices => _devices.where((d) => d.isAuthorized).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;
  DeviceModel? get currentDevice => _currentDevice;
  int get pendingDevicesCount => _pendingDevices.length;

  /// Charger tous les appareils d'un utilisateur
  Future<void> loadUserDevices(String userId) async {
    _setLoading(true);
    _error = null;

    try {
      _devices = await DeviceService.getUserDevices(userId);
      _currentDevice = _devices.firstWhere(
        (device) => device.isCurrentDevice,
        orElse: () => _devices.isNotEmpty ? _devices.first : DeviceModel(
          id: '',
          userId: userId,
          deviceId: '',
          deviceName: 'Appareil inconnu',
          deviceType: 'mobile',
          platform: 'unknown',
          appVersion: '1.0.0',
          osVersion: 'unknown',
          isAuthorized: false,
          isCurrentDevice: true,
          firstLoginAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      
      await loadPendingDevices(userId);
    } catch (e) {
      _error = 'Erreur lors du chargement des appareils: $e';
      print(_error);
    } finally {
      _setLoading(false);
    }
  }

  /// Charger les appareils en attente d'autorisation
  Future<void> loadPendingDevices(String userId) async {
    try {
      _pendingDevices = await DeviceService.getPendingDevices(userId);
      notifyListeners();
    } catch (e) {
      print('Erreur lors du chargement des appareils en attente: $e');
    }
  }

  /// Enregistrer l'appareil actuel
  Future<DeviceModel?> registerCurrentDevice(String userId) async {
    try {
      final device = await DeviceService.registerCurrentDevice(userId);
      if (device != null) {
        _currentDevice = device;
        await loadUserDevices(userId);
      }
      return device;
    } catch (e) {
      _error = 'Erreur lors de l\'enregistrement de l\'appareil: $e';
      print(_error);
      notifyListeners();
      return null;
    }
  }

  /// Vérifier si l'appareil actuel est autorisé
  Future<bool> isCurrentDeviceAuthorized(String userId) async {
    try {
      return await DeviceService.isCurrentDeviceAuthorized(userId);
    } catch (e) {
      print('Erreur lors de la vérification de l\'autorisation: $e');
      return false;
    }
  }

  /// Autoriser un appareil
  Future<bool> authorizeDevice(String deviceId, String userId) async {
    _setLoading(true);
    
    try {
      final success = await DeviceService.authorizeDevice(deviceId, userId);
      if (success) {
        // Mettre à jour la liste locale
        _devices = _devices.map((device) {
          if (device.deviceId == deviceId) {
            return device.copyWith(isAuthorized: true);
          }
          return device;
        }).toList();

        // Retirer des appareils en attente
        _pendingDevices.removeWhere((device) => device.deviceId == deviceId);
        
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = 'Erreur lors de l\'autorisation: $e';
      print(_error);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Révoquer l'autorisation d'un appareil
  Future<bool> revokeDeviceAuthorization(String deviceId, String userId) async {
    _setLoading(true);
    
    try {
      final success = await DeviceService.revokeDeviceAuthorization(deviceId, userId);
      if (success) {
        // Mettre à jour la liste locale
        _devices = _devices.map((device) {
          if (device.deviceId == deviceId) {
            return device.copyWith(isAuthorized: false);
          }
          return device;
        }).toList();

        // Ajouter aux appareils en attente si ce n'est pas l'appareil actuel
        final revokedDevice = _devices.firstWhere((d) => d.deviceId == deviceId);
        if (!revokedDevice.isCurrentDevice) {
          _pendingDevices.add(revokedDevice.copyWith(isAuthorized: false));
        }
        
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = 'Erreur lors de la révocation: $e';
      print(_error);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Supprimer un appareil
  Future<bool> removeDevice(String deviceId, String userId) async {
    _setLoading(true);
    
    try {
      final success = await DeviceService.removeDevice(deviceId, userId);
      if (success) {
        // Retirer de toutes les listes locales
        _devices.removeWhere((device) => device.deviceId == deviceId);
        _pendingDevices.removeWhere((device) => device.deviceId == deviceId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = 'Erreur lors de la suppression: $e';
      print(_error);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Autoriser l'appareil actuel (pour le premier appareil)
  Future<bool> authorizeCurrentDevice(String userId) async {
    try {
      final success = await DeviceService.authorizeCurrentDevice(userId);
      if (success) {
        await loadUserDevices(userId);
      }
      return success;
    } catch (e) {
      _error = 'Erreur lors de l\'autorisation de l\'appareil actuel: $e';
      print(_error);
      notifyListeners();
      return false;
    }
  }

  /// Nettoyer les anciens appareils
  Future<void> cleanupOldDevices(String userId) async {
    try {
      await DeviceService.cleanupOldDevices(userId);
      await loadUserDevices(userId);
    } catch (e) {
      print('Erreur lors du nettoyage: $e');
    }
  }

  /// Rafraîchir les données
  Future<void> refresh(String userId) async {
    await loadUserDevices(userId);
  }

  /// Obtenir un appareil par son ID
  DeviceModel? getDeviceById(String deviceId) {
    try {
      return _devices.firstWhere((device) => device.deviceId == deviceId);
    } catch (e) {
      return null;
    }
  }

  /// Vérifier si un appareil est autorisé
  bool isDeviceAuthorized(String deviceId) {
    final device = getDeviceById(deviceId);
    return device?.isAuthorized ?? false;
  }

  /// Obtenir le nombre d'appareils autorisés
  int get authorizedDevicesCount => _devices.where((d) => d.isAuthorized).length;

  /// Obtenir le nombre total d'appareils
  int get totalDevicesCount => _devices.length;

  /// Vider les données (lors de la déconnexion)
  void clear() {
    _devices.clear();
    _pendingDevices.clear();
    _currentDevice = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Méthode privée pour gérer l'état de chargement
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Méthode pour définir une erreur
  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// Vérifier si l'utilisateur a des appareils autorisés
  bool get hasAuthorizedDevices => authorizedDevicesCount > 0;

  /// Vérifier si l'utilisateur a des appareils en attente
  bool get hasPendingDevices => pendingDevicesCount > 0;
}

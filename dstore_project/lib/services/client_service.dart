import '../models/client_model.dart';
import 'local_storage_service.dart';

class ClientService {
  final LocalStorageService _localStorage = LocalStorageService.instance;

  Future<List<ClientModel>> getAllClients() async {
    try {
      final clientsData = _localStorage.getClients();
      return clientsData.map((json) {
        final Map<String, dynamic> clientMap = Map<String, dynamic>.from(json);
        return ClientModel.fromJson(clientMap);
      }).toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des clients: $e');
    }
  }

  Future<ClientModel?> getClientById(String id) async {
    try {
      final clientsData = _localStorage.getClients();
      final clientData = clientsData.firstWhere(
        (client) => client['id'] == id,
        orElse: () => <String, dynamic>{},
      );

      if (clientData.isEmpty) return null;
      final Map<String, dynamic> clientMap =
          Map<String, dynamic>.from(clientData);
      return ClientModel.fromJson(clientMap);
    } catch (e) {
      throw Exception('Erreur lors du chargement du client: $e');
    }
  }

  Future<ClientModel> createClient(ClientModel client) async {
    try {
      final clientData = client.toJson();
      clientData['id'] = DateTime.now().millisecondsSinceEpoch.toString();
      clientData['created_at'] = DateTime.now().toIso8601String();
      clientData['updated_at'] = DateTime.now().toIso8601String();

      await _localStorage.saveClient(clientData);
      return ClientModel.fromJson(clientData);
    } catch (e) {
      throw Exception('Erreur lors de la création du client: $e');
    }
  }

  Future<ClientModel> updateClient(ClientModel client) async {
    try {
      final clientData = client.toJson();
      clientData['updated_at'] = DateTime.now().toIso8601String();

      await _localStorage.saveClient(clientData);
      return ClientModel.fromJson(clientData);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du client: $e');
    }
  }

  Future<void> deleteClient(String id) async {
    try {
      await _localStorage.deleteClient(id);
    } catch (e) {
      throw Exception('Erreur lors de la suppression du client: $e');
    }
  }

  Future<List<ClientModel>> searchClients(String query) async {
    try {
      final clientsData = _localStorage.getClients();
      final filteredClients = clientsData.where((client) {
        final name = client['name']?.toString().toLowerCase() ?? '';
        final email = client['email']?.toString().toLowerCase() ?? '';
        final phone = client['phone']?.toString().toLowerCase() ?? '';
        final searchQuery = query.toLowerCase();

        return name.contains(searchQuery) ||
            email.contains(searchQuery) ||
            phone.contains(searchQuery);
      }).toList();

      return filteredClients.map((json) => ClientModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la recherche: $e');
    }
  }

  Future<ClientModel?> getClientByEmail(String email) async {
    try {
      final clientsData = _localStorage.getClients();
      final clientData = clientsData.firstWhere(
        (client) =>
            client['email']?.toString().toLowerCase() == email.toLowerCase(),
        orElse: () => <String, dynamic>{},
      );

      if (clientData.isEmpty) return null;
      return ClientModel.fromJson(clientData);
    } catch (e) {
      return null;
    }
  }

  Future<ClientModel?> getClientByPhone(String phone) async {
    try {
      final clientsData = _localStorage.getClients();
      final clientData = clientsData.firstWhere(
        (client) => client['phone'] == phone,
        orElse: () => <String, dynamic>{},
      );

      if (clientData.isEmpty) return null;
      return ClientModel.fromJson(clientData);
    } catch (e) {
      return null;
    }
  }

  Future<List<ClientModel>> getRecentClients({int limit = 10}) async {
    try {
      final clientsData = _localStorage.getClients();

      // Trier par date de création (plus récent en premier)
      clientsData.sort((a, b) {
        final dateA =
            DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(1970);
        final dateB =
            DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(1970);
        return dateB.compareTo(dateA);
      });

      final recentClients = clientsData.take(limit).toList();
      return recentClients.map((json) => ClientModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des clients récents: $e');
    }
  }

  Future<int> getClientsCount() async {
    try {
      final clientsData = _localStorage.getClients();
      return clientsData.length;
    } catch (e) {
      return 0;
    }
  }

  Future<List<ClientModel>> getActiveClients() async {
    try {
      final clientsData = _localStorage.getClients();
      final activeClients = clientsData.where((client) {
        return client['is_active'] == true || client['is_active'] == null;
      }).toList();

      return activeClients.map((json) => ClientModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des clients actifs: $e');
    }
  }

  Future<void> toggleClientStatus(String clientId) async {
    try {
      final client = await getClientById(clientId);
      if (client != null) {
        final clientData = client.toJson();
        clientData['is_active'] = !(client.isActive ?? true);
        clientData['updated_at'] = DateTime.now().toIso8601String();
        await _localStorage.saveClient(clientData);
      }
    } catch (e) {
      throw Exception('Erreur lors du changement de statut: $e');
    }
  }

  Future<double> getClientTotalPurchases(String clientId) async {
    try {
      // Pour l'instant, retourner 0 (sera implémenté avec InvoiceService)
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  Future<int> getClientOrdersCount(String clientId) async {
    try {
      // Pour l'instant, retourner 0 (sera implémenté avec InvoiceService)
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<DateTime?> getClientLastOrderDate(String clientId) async {
    try {
      // Pour l'instant, retourner null (sera implémenté avec InvoiceService)
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<ClientModel>> getTopClients({int limit = 5}) async {
    try {
      // Pour l'instant, retourner les clients récents
      return await getRecentClients(limit: limit);
    } catch (e) {
      throw Exception('Erreur lors du chargement des meilleurs clients: $e');
    }
  }

  Future<bool> isEmailExists(String email, {String? excludeId}) async {
    try {
      final client = await getClientByEmail(email);
      if (client == null) return false;
      if (excludeId != null && client.id == excludeId) return false;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isPhoneExists(String phone, {String? excludeId}) async {
    try {
      final client = await getClientByPhone(phone);
      if (client == null) return false;
      if (excludeId != null && client.id == excludeId) return false;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> updateClientCredit(String clientId, double newCredit) async {
    try {
      final client = await getClientById(clientId);
      if (client != null) {
        final clientData = client.toJson();
        clientData['credit_limit'] = newCredit;
        clientData['updated_at'] = DateTime.now().toIso8601String();
        await _localStorage.saveClient(clientData);
      }
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du crédit: $e');
    }
  }

  Future<void> addClientTransaction(
      String clientId, double amount, String type) async {
    try {
      // Pour l'instant, ne rien faire (sera implémenté avec un système de transactions)
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout de la transaction: $e');
    }
  }
}

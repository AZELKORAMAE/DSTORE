import 'package:flutter/material.dart';
import '../models/client_model.dart';
import '../services/client_service.dart';
import '../services/credit_service.dart';

class ClientProvider extends ChangeNotifier {
  final ClientService _clientService = ClientService();
  // Ajout du service de crédit pour gérer les ajustements depuis le détail client
  final CreditService _creditService = CreditService();

  List<ClientModel> _clients = [];
  List<ClientModel> _filteredClients = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  // Getters
  List<ClientModel> get clients => _filteredClients;
  List<ClientModel> get filteredClients => _filteredClients;
  List<ClientModel> get allClients => _clients;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  // Statistiques
  int get totalClients => _clients.where((c) => c.isActive).length;
  int get clientsWithCredit =>
      _clients.where((c) => c.currentCredit > 0 && c.isActive).length;
  int get clientsWithPositiveCredit =>
      _clients.where((c) => c.currentCredit > 0 && c.isActive).length;
  int get clientsWithNegativeCredit =>
      _clients.where((c) => c.currentCredit < 0 && c.isActive).length;
  int get clientsAtCreditLimit =>
      _clients.where((c) => c.isAtCreditLimit && c.isActive).length;
  double get totalCreditUsed => _clients
      .where((c) => c.isActive)
      .fold(0.0, (sum, client) => sum + client.currentCredit);
  double get totalCreditBalance => _clients
      .where((c) => c.isActive)
      .fold(0.0, (sum, client) => sum + client.currentCredit);
  double get totalCreditLimit => _clients
      .where((c) => c.isActive)
      .fold(0.0, (sum, client) => sum + client.creditLimit);

  ClientProvider() {
    loadClients();
  }

  Future<void> loadClients() async {
    _setLoading(true);
    _clearError();

    try {
      _clients = await _clientService.getAllClients();
      _applyFilters();
      _setLoading(false);
    } catch (e) {
      _setError('Erreur lors du chargement des clients: $e');
      _setLoading(false);
    }
  }

  Future<ClientModel?> getClientById(String id) async {
    try {
      // Chercher d'abord dans la liste locale
      final localClient = _clients.firstWhere(
        (client) => client.id == id,
        orElse: () => throw Exception('Client not found locally'),
      );
      return localClient;
    } catch (e) {
      // Si pas trouvé localement, charger depuis le service
      try {
        return await _clientService.getClientById(id);
      } catch (e) {
        _setError('Erreur lors du chargement du client: $e');
        return null;
      }
    }
  }

  Future<bool> createClient(ClientModel client) async {
    _setLoading(true);
    _clearError();

    try {
      final newClient = await _clientService.createClient(client);
      _clients.add(newClient);
      _applyFilters();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Erreur lors de la création du client: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateClient(ClientModel client) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedClient = await _clientService.updateClient(client);
      final index = _clients.indexWhere((c) => c.id == client.id);
      if (index != -1) {
        _clients[index] = updatedClient;
        _applyFilters();
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Erreur lors de la mise à jour du client: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteClient(String id) async {
    _setLoading(true);
    _clearError();

    try {
      await _clientService.deleteClient(id);
      _clients.removeWhere((client) => client.id == id);
      _applyFilters();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Erreur lors de la suppression du client: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateClientCredit(String clientId, double newCredit) async {
    try {
      await _clientService.updateClientCredit(clientId, newCredit);

      // Mettre à jour localement
      final index = _clients.indexWhere((c) => c.id == clientId);
      if (index != -1) {
        _clients[index] = _clients[index].copyWith(currentCredit: newCredit);
        _applyFilters();
      }

      return true;
    } catch (e) {
      _setError('Erreur lors de la mise à jour du crédit: $e');
      return false;
    }
  }

  Future<bool> addCredit(String clientId, double amount) async {
    try {
      final client = _clients.firstWhere((c) => c.id == clientId);
      final newCredit = client.currentCredit + amount;
      return await updateClientCredit(clientId, newCredit);
    } catch (e) {
      _setError('Erreur lors de l\'ajout de crédit: $e');
      return false;
    }
  }

  Future<bool> subtractCredit(String clientId, double amount) async {
    try {
      final client = _clients.firstWhere((c) => c.id == clientId);
      final newCredit =
          (client.currentCredit - amount).clamp(0.0, double.infinity);
      return await updateClientCredit(clientId, newCredit);
    } catch (e) {
      _setError('Erreur lors de la déduction de crédit: $e');
      return false;
    }
  }

  void searchClients(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void clearSearch() {
    _searchQuery = '';
    _applyFilters();
  }

  List<ClientModel> getClientsWithCredit() {
    return _clients
        .where((client) => client.currentCredit > 0 && client.isActive)
        .toList();
  }

  List<ClientModel> getClientsAtCreditLimit() {
    return _clients
        .where((client) => client.isAtCreditLimit && client.isActive)
        .toList();
  }

  void _applyFilters() {
    _filteredClients = _clients.where((client) {
      // Filtre par recherche
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesName = client.name.toLowerCase().contains(query);
        final matchesEmail =
            client.email?.toLowerCase().contains(query) ?? false;
        final matchesPhone =
            client.phone?.toLowerCase().contains(query) ?? false;

        if (!matchesName && !matchesEmail && !matchesPhone) {
          return false;
        }
      }

      return true;
    }).toList();

    // Trier par nom
    _filteredClients.sort((a, b) => a.name.compareTo(b.name));

    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Méthodes manquantes pour compatibilité
  void clearFilters() {
    _searchQuery = '';
    _applyFilters();
  }

  void filterClients(String filterType) {
    // TODO: Implémenter le filtrage par type
    notifyListeners();
  }

  Future<bool> adjustCredit(
      String clientId, double amount, String reason) async {
    try {
      // Si le montant est positif, on ajoute du crédit au client
      // Cela crée un nouveau crédit « manuel » pour que le montant apparaisse dans la gestion des crédits
      if (amount > 0) {
        // Créer un crédit sans facture pour représenter cet ajout manuel
        try {
          await _creditService.createCreditFromInvoice(
            invoiceId: 'manual-${DateTime.now().millisecondsSinceEpoch}',
            clientId: clientId,
            totalAmount: amount,
            paidAmount: 0.0,
            dueDays: 30,
            notes: reason.isNotEmpty ? reason : 'Ajustement manuel',
          );
        } catch (e) {
          // Ne pas interrompre, mais enregistrer l'erreur si la création échoue
          print('❌ Erreur création crédit manuel: $e');
        }
      } else if (amount < 0) {
        // Si le montant est négatif, le client paie une partie de son crédit
        double paymentToApply = -amount;
        try {
          // Récupérer les crédits en cours du client (restant > 0)
          final credits = await _creditService.getCreditsByClient(clientId);
          // Trier les crédits par date d'échéance croissante pour rembourser en priorité les plus anciens
          credits.sort((a, b) => a.dueDate.compareTo(b.dueDate));
          for (final credit in credits) {
            if (paymentToApply <= 0) break;
            if (credit.remainingAmount > 0) {
              final amountToPay = paymentToApply < credit.remainingAmount
                  ? paymentToApply
                  : credit.remainingAmount;
              await _creditService.makePayment(
                creditId: credit.id,
                paymentAmount: amountToPay,
                paymentMethod: 'Manuel',
                notes: reason.isNotEmpty ? reason : 'Ajustement manuel',
              );
              paymentToApply -= amountToPay;
            }
          }
          // S'il reste un montant à appliquer et qu'aucun crédit n'était disponible, réduire directement le crédit courant du client
          if (paymentToApply > 0) {
            final client = _clients.firstWhere((c) => c.id == clientId);
            final newCredit = (client.currentCredit - paymentToApply).clamp(0.0, double.infinity);
            await _clientService.updateClient(client.copyWith(
              currentCredit: newCredit,
              updatedAt: DateTime.now(),
            ));
          }
        } catch (e) {
          print('❌ Erreur lors de l\'application du paiement du crédit: $e');
          _setError('Erreur lors de l\'ajustement du crédit: $e');
          return false;
        }
      }
      // Recharger les clients depuis le service pour mettre à jour les crédits courants
      await loadClients();
      return true;
    } catch (e) {
      _setError('Erreur lors de l\'ajustement du crédit: $e');
      return false;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}

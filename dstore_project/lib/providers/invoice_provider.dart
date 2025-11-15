import 'package:flutter/material.dart';
import '../models/invoice_model.dart';
import '../services/invoice_service.dart';

class InvoiceProvider extends ChangeNotifier {
  final InvoiceService _invoiceService = InvoiceService();

  List<InvoiceModel> _invoices = [];
  List<InvoiceModel> _filteredInvoices = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  InvoiceStatus? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;

  // Getters
  List<InvoiceModel> get invoices => _filteredInvoices;
  List<InvoiceModel> get filteredInvoices => _filteredInvoices;
  List<InvoiceModel> get allInvoices => _invoices;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  InvoiceStatus? get selectedStatus => _selectedStatus;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  // Statistiques
  int get totalInvoices => _invoices.length;
  int get draftInvoices =>
      _invoices.where((i) => i.status == InvoiceStatus.draft).length;
  int get validatedInvoices =>
      _invoices.where((i) => i.status == InvoiceStatus.validated).length;
  int get paidInvoices =>
      _invoices.where((i) => i.status == InvoiceStatus.paid).length;
  int get pendingInvoices =>
      _invoices.where((i) => i.status == InvoiceStatus.validated).length;
  int get overdueInvoices => _invoices.where((i) => i.isOverdue).length;

  double get totalRevenue => _invoices
      .where((i) => i.status == InvoiceStatus.paid)
      .fold(0.0, (sum, invoice) => sum + invoice.totalAmount);

  double get pendingAmount => _invoices
      .where((i) => i.status == InvoiceStatus.validated)
      .fold(0.0, (sum, invoice) => sum + invoice.remainingAmount);

  InvoiceProvider() {
    loadInvoices();
  }

  Future<void> loadInvoices() async {
    _setLoading(true);
    _clearError();

    try {
      _invoices = await _invoiceService.getAllInvoices();
      _applyFilters();
      _setLoading(false);
    } catch (e) {
      _setError('Erreur lors du chargement des factures: $e');
      _setLoading(false);
    }
  }

  Future<InvoiceModel?> getInvoiceById(String id) async {
    try {
      // Chercher d'abord dans la liste locale
      final localInvoice = _invoices.firstWhere(
        (invoice) => invoice.id == id,
        orElse: () => throw Exception('Invoice not found locally'),
      );
      return localInvoice;
    } catch (e) {
      // Si pas trouvé localement, charger depuis le service
      try {
        return await _invoiceService.getInvoiceById(id);
      } catch (e) {
        _setError('Erreur lors du chargement de la facture: $e');
        return null;
      }
    }
  }

  Future<String> generateInvoiceNumber(String type) async {
    try {
      return await _invoiceService.generateInvoiceNumber(type);
    } catch (e) {
      _setError('Erreur lors de la génération du numéro de facture: $e');
      return 'FAC-${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  Future<bool> createInvoice(
      InvoiceModel invoice, List<InvoiceItemModel> items) async {
    print(
        '🎯 PROVIDER: createInvoice appelée - Type: ${invoice.type}, Items: ${items.length}');
    _setLoading(true);
    _clearError();

    try {
      // Ajouter les items à la facture avant de la créer
      final invoiceWithItems = invoice.copyWith(items: items);
      print('🎯 PROVIDER: Appel du service createInvoice...');
      final newInvoice = await _invoiceService.createInvoice(invoiceWithItems);
      print('🎯 PROVIDER: Service createInvoice terminé avec succès');
      _invoices.add(newInvoice);
      _applyFilters();
      _setLoading(false);
      print('🎯 PROVIDER: createInvoice terminée avec succès');
      return true;
    } catch (e) {
      print('🎯 PROVIDER: Erreur dans createInvoice: $e');
      _setError('Erreur lors de la création de la facture: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateInvoice(
      InvoiceModel invoice, List<InvoiceItemModel> items) async {
    _setLoading(true);
    _clearError();

    try {
      // Ajouter les items à la facture avant de la mettre à jour
      final invoiceWithItems = invoice.copyWith(items: items);
      final updatedInvoice =
          await _invoiceService.updateInvoice(invoiceWithItems);
      final index = _invoices.indexWhere((i) => i.id == invoice.id);
      if (index != -1) {
        _invoices[index] = updatedInvoice;
        _applyFilters();
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Erreur lors de la mise à jour de la facture: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> validateInvoice(String invoiceId) async {
    _setLoading(true);
    _clearError();

    try {
      await _invoiceService.validateInvoice(invoiceId);

      // Mettre à jour localement
      final index = _invoices.indexWhere((i) => i.id == invoiceId);
      if (index != -1) {
        _invoices[index] =
            _invoices[index].copyWith(status: InvoiceStatus.validated);
        _applyFilters();
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Erreur lors de la validation de la facture: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> markAsPaid(String invoiceId, double paidAmount) async {
    _setLoading(true);
    _clearError();

    try {
      await _invoiceService.markAsPaid(invoiceId, paidAmount);

      // Mettre à jour localement
      final index = _invoices.indexWhere((i) => i.id == invoiceId);
      if (index != -1) {
        final invoice = _invoices[index];
        final newPaidAmount = invoice.paidAmount + paidAmount;
        final newStatus = newPaidAmount >= invoice.totalAmount
            ? InvoiceStatus.paid
            : InvoiceStatus.validated;

        _invoices[index] = invoice.copyWith(
          paidAmount: newPaidAmount,
          status: newStatus,
        );
        _applyFilters();
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Erreur lors du marquage comme payée: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> cancelInvoice(String invoiceId) async {
    _setLoading(true);
    _clearError();

    try {
      await _invoiceService.cancelInvoice(invoiceId);

      // Mettre à jour localement
      final index = _invoices.indexWhere((i) => i.id == invoiceId);
      if (index != -1) {
        _invoices[index] =
            _invoices[index].copyWith(status: InvoiceStatus.cancelled);
        _applyFilters();
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Erreur lors de l\'annulation de la facture: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteInvoice(String id) async {
    _setLoading(true);
    _clearError();

    try {
      await _invoiceService.deleteInvoice(id);
      _invoices.removeWhere((invoice) => invoice.id == id);
      _applyFilters();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Erreur lors de la suppression de la facture: $e');
      _setLoading(false);
      return false;
    }
  }

  void searchInvoices(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void filterByStatus(dynamic status) {
    if (status is String) {
      // Convertir string en enum
      switch (status) {
        case 'draft':
          _selectedStatus = InvoiceStatus.draft;
          break;
        case 'sent':
        case 'validated':
          _selectedStatus = InvoiceStatus.validated;
          break;
        case 'paid':
          _selectedStatus = InvoiceStatus.paid;
          break;
        case 'overdue':
          _selectedStatus = null; // Géré par isOverdue
          break;
        case 'all':
        default:
          _selectedStatus = null;
          break;
      }
    } else if (status is InvoiceStatus?) {
      _selectedStatus = status;
    }
    _applyFilters();
  }

  void filterByDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    _applyFilters();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedStatus = null;
    _startDate = null;
    _endDate = null;
    _applyFilters();
  }

  List<InvoiceModel> getInvoicesByClient(String clientId) {
    return _invoices.where((invoice) => invoice.clientId == clientId).toList();
  }

  List<InvoiceModel> getOverdueInvoices() {
    return _invoices.where((invoice) => invoice.isOverdue).toList();
  }

  double getRevenueForPeriod(DateTime start, DateTime end) {
    return _invoices
        .where((invoice) =>
            invoice.status == InvoiceStatus.paid &&
            invoice.invoiceDate
                .isAfter(start.subtract(const Duration(days: 1))) &&
            invoice.invoiceDate.isBefore(end.add(const Duration(days: 1))))
        .fold(0.0, (sum, invoice) => sum + invoice.totalAmount);
  }

  void _applyFilters() {
    _filteredInvoices = _invoices.where((invoice) {
      // Filtre par recherche
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesNumber =
            invoice.invoiceNumber.toLowerCase().contains(query);
        final matchesClient =
            invoice.client?.name.toLowerCase().contains(query) ?? false;

        if (!matchesNumber && !matchesClient) {
          return false;
        }
      }

      // Filtre par statut
      if (_selectedStatus != null && invoice.status != _selectedStatus) {
        return false;
      }

      // Filtre par date
      if (_startDate != null && invoice.invoiceDate.isBefore(_startDate!)) {
        return false;
      }
      if (_endDate != null && invoice.invoiceDate.isAfter(_endDate!)) {
        return false;
      }

      return true;
    }).toList();

    // Trier par date (plus récent en premier)
    _filteredInvoices.sort((a, b) => b.invoiceDate.compareTo(a.invoiceDate));

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
}

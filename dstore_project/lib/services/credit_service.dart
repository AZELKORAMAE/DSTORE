import 'package:uuid/uuid.dart';
import '../models/credit_model.dart';
import '../models/invoice_model.dart';
import '../models/revenue_model.dart';
import 'local_storage_service.dart';
import 'client_service.dart';
import 'revenue_service.dart';

class CreditService {
  final LocalStorageService _localStorage = LocalStorageService.instance;
  final ClientService _clientService = ClientService();
  final RevenueService _revenueService = RevenueService();
  final Uuid _uuid = const Uuid();

  // NOTE: Ne pas instancier InvoiceService ici pour éviter une dépendance circulaire.
  // La mise à jour des factures après paiement de crédit est gérée directement via
  // LocalStorageService dans makePayment.

  // ==================== GESTION DES CRÉDITS ====================

  /// Créer un crédit automatiquement lors d'un paiement partiel
  Future<CreditModel> createCreditFromInvoice({
    required String invoiceId,
    required String clientId,
    required double totalAmount,
    required double paidAmount,
    int dueDays = 30,
    String? notes,
  }) async {
    try {
      final remainingAmount = totalAmount - paidAmount;
      final dueDate = DateTime.now().add(Duration(days: dueDays));

      final credit = CreditModel(
        id: _uuid.v4(),
        userId: '', // Sera défini par l'utilisateur connecté
        clientId: clientId,
        invoiceId: invoiceId,
        totalAmount: totalAmount,
        paidAmount: paidAmount,
        remainingAmount: remainingAmount,
        dueDate: dueDate,
        status: CreditPaymentStatus.pending,
        notes: notes,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _localStorage.saveCredit(credit.toJson());
      print('💾 Crédit sauvegardé avec clientId: ${credit.clientId}');
      print(
          '💳 Crédit créé: ${credit.remainingAmount} DH pour client $clientId');

      // Mettre à jour le crédit du client
      await _updateClientCredit(clientId, remainingAmount);

      return credit;
    } catch (e) {
      throw Exception('Erreur lors de la création du crédit: $e');
    }
  }

  /// Obtenir tous les crédits
  Future<List<CreditModel>> getAllCredits() async {
    try {
      final creditsData = _localStorage.getCredits();
      print('🔍 CreditService.getAllCredits: ${creditsData.length} crédits bruts trouvés');

      final credits = <CreditModel>[];
      for (int i = 0; i < creditsData.length; i++) {
        try {
          final credit = CreditModel.fromJson(creditsData[i]);
          credits.add(credit);
          print('✅ Crédit $i converti: ${credit.id} pour client ${credit.clientId}');
        } catch (e) {
          print('❌ Erreur conversion crédit $i: $e');
          print('📄 Données brutes: ${creditsData[i]}');
        }
      }

      print('🎯 CreditService.getAllCredits: ${credits.length} crédits convertis avec succès');

      // Charger les relations (client et facture) - optionnel
      for (int i = 0; i < credits.length; i++) {
        final credit = credits[i];

        // Charger le client
        try {
          final client = await _clientService.getClientById(credit.clientId);
          credits[i] = credit.copyWith(client: client);
          print('✅ Client chargé pour crédit ${credit.id}');
        } catch (e) {
          print('⚠️ Client non trouvé pour crédit ${credit.id}: $e');
          // Continuer sans le client
        }

        // Charger la facture depuis le stockage local
        try {
          final invoicesData = _localStorage.getInvoices();
          final invoiceData = invoicesData.firstWhere(
            (inv) => inv['id'] == credit.invoiceId,
            orElse: () => <String, dynamic>{},
          );
          if (invoiceData.isNotEmpty) {
            final invoice = InvoiceModel.fromJson(invoiceData);
            credits[i] = credits[i].copyWith(invoice: invoice);
            print('✅ Facture chargée pour crédit ${credit.id}');
          } else {
            print('⚠️ Facture non trouvée pour crédit ${credit.id}');
          }
        } catch (e) {
          print('⚠️ Erreur chargement facture pour crédit ${credit.id}: $e');
          // Continuer sans la facture
        }
      }

      print('🎯 CreditService.getAllCredits: Retour de ${credits.length} crédits');

      return credits;
    } catch (e) {
      throw Exception('Erreur lors du chargement des crédits: $e');
    }
  }

  /// Obtenir les crédits d'un client spécifique
  Future<List<CreditModel>> getCreditsByClient(String clientId) async {
    try {
      print('🔍 CreditService: Recherche crédits pour clientId: $clientId');
      final allCredits = await getAllCredits();
      print('📊 CreditService: Total crédits dans la base: ${allCredits.length}');

      final clientCredits = allCredits.where((credit) {
        print('🔍 Comparaison: credit.clientId="${credit.clientId}" vs clientId="$clientId"');
        return credit.clientId == clientId;
      }).toList();

      print('✅ CreditService: Crédits trouvés pour ce client: ${clientCredits.length}');
      return clientCredits;
    } catch (e) {
      print('❌ CreditService: Erreur lors du chargement des crédits du client: $e');
      throw Exception('Erreur lors du chargement des crédits du client: $e');
    }
  }

  /// Obtenir les crédits d'une facture spécifique
  Future<List<CreditModel>> getCreditsByInvoice(String invoiceId) async {
    try {
      final allCredits = await getAllCredits();
      return allCredits.where((credit) => credit.invoiceId == invoiceId).toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des crédits de la facture: $e');
    }
  }

  /// Obtenir un crédit par ID
  Future<CreditModel?> getCreditById(String creditId) async {
    try {
      final allCredits = await getAllCredits();
      return allCredits.firstWhere(
        (credit) => credit.id == creditId,
        orElse: () => throw Exception('Crédit non trouvé'),
      );
    } catch (e) {
      return null;
    }
  }

  /// Effectuer un paiement sur un crédit
  Future<CreditModel> makePayment({
    required String creditId,
    required double paymentAmount,
    String? paymentMethod,
    String? notes,
  }) async {
    try {
      final credit = await getCreditById(creditId);
      if (credit == null) {
        throw Exception('Crédit non trouvé');
      }

      if (paymentAmount <= 0) {
        throw Exception('Le montant du paiement doit être positif');
      }

      if (paymentAmount > credit.remainingAmount) {
        throw Exception(
            'Le montant du paiement ne peut pas dépasser le montant restant');
      }

      // Mettre à jour le crédit
      final newPaidAmount = credit.paidAmount + paymentAmount;
      final newRemainingAmount = credit.totalAmount - newPaidAmount;

      CreditPaymentStatus newStatus;
      if (newRemainingAmount <= 0) {
        newStatus = CreditPaymentStatus.paid;
      } else if (newPaidAmount > 0) {
        newStatus = CreditPaymentStatus.partiallyPaid;
      } else {
        newStatus = credit.status;
      }

      final updatedCredit = credit.copyWith(
        paidAmount: newPaidAmount,
        remainingAmount: newRemainingAmount,
        status: newStatus,
        updatedAt: DateTime.now(),
      );

      // Sauvegarder le crédit mis à jour
      await _localStorage.saveCredit(updatedCredit.toJson());

      // Enregistrer le paiement dans l'historique
      await _saveCreditPayment(
        creditId: creditId,
        amount: paymentAmount,
        paymentMethod: paymentMethod,
        notes: notes,
      );

      // Mettre à jour le crédit du client (réduire le crédit)
      await _updateClientCredit(credit.clientId, -paymentAmount);

      // Enregistrer le paiement comme un revenu
      await _revenueService.recordRevenue(
        amount: paymentAmount,
        type: RevenueType.creditPayment,
        sourceId: creditId,
        clientId: credit.clientId,
        description: 'Paiement de crédit - ${notes ?? 'Aucune note'}',
      );

      // Mettre à jour la facture associée avec le montant payé supplémentaire
      try {
        // Récupérer la facture liée à ce crédit directement depuis le stockage local
        final invoicesData = _localStorage.getInvoices();
        final index = invoicesData.indexWhere((inv) => inv['id'] == credit.invoiceId);
        if (index != -1) {
          final invoiceData = Map<String, dynamic>.from(invoicesData[index]);
          // Extraire le montant payé actuel et le total
          double currentPaid = 0.0;
          final paidRaw = invoiceData['paid_amount'];
          if (paidRaw != null) {
            if (paidRaw is int) {
              currentPaid = paidRaw.toDouble();
            } else if (paidRaw is double) {
              currentPaid = paidRaw;
            } else if (paidRaw is String) {
              currentPaid = double.tryParse(paidRaw) ?? 0.0;
            }
          }
          double totalAmount = 0.0;
          final totalRaw = invoiceData['total_amount'];
          if (totalRaw != null) {
            if (totalRaw is int) {
              totalAmount = totalRaw.toDouble();
            } else if (totalRaw is double) {
              totalAmount = totalRaw;
            } else if (totalRaw is String) {
              totalAmount = double.tryParse(totalRaw) ?? 0.0;
            }
          }
          // Calculer nouveau montant payé
          final newPaidAmount = currentPaid + paymentAmount;
          // Déterminer le nouveau statut
          final String newStatus = newPaidAmount >= totalAmount
              ? InvoiceStatus.paid.value
              : InvoiceStatus.validated.value;
          // Mettre à jour les champs
          invoiceData['paid_amount'] = newPaidAmount;
          invoiceData['status'] = newStatus;
          invoiceData['updated_at'] = DateTime.now().toIso8601String();
          // Sauvegarder la facture mise à jour
          await _localStorage.saveInvoice(invoiceData);
          print(
              '📄 Facture ${invoiceData['id']} mise à jour avec nouveau paiement: $newPaidAmount DH');
        }
      } catch (e) {
        print('⚠️ Erreur mise à jour facture après paiement de crédit: $e');
      }

      print('💰 Paiement de $paymentAmount DH effectué sur crédit $creditId');
      print('📊 Revenu enregistré pour le paiement de crédit');
      return updatedCredit;
    } catch (e) {
      throw Exception('Erreur lors du paiement: $e');
    }
  }

  /// Sauvegarder un paiement dans l'historique
  Future<void> _saveCreditPayment({
    required String creditId,
    required double amount,
    String? paymentMethod,
    String? notes,
  }) async {
    try {
      final payment = CreditPaymentModel(
        id: _uuid.v4(),
        creditId: creditId,
        amount: amount,
        paymentDate: DateTime.now(),
        paymentMethod: paymentMethod,
        notes: notes,
        createdAt: DateTime.now(),
      );

      await _localStorage.saveCreditPayment(payment.toJson());
    } catch (e) {
      print('❌ Erreur sauvegarde paiement crédit: $e');
    }
  }

  /// Obtenir l'historique des paiements d'un crédit
  Future<List<CreditPaymentModel>> getCreditPayments(String creditId) async {
    try {
      final paymentsData = _localStorage.getCreditPayments();
      final payments = paymentsData
          .map((data) => CreditPaymentModel.fromJson(data))
          .where((payment) => payment.creditId == creditId)
          .toList();

      // Trier par date de paiement (plus récent en premier)
      payments.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));

      return payments;
    } catch (e) {
      throw Exception(
          'Erreur lors du chargement de l\'historique des paiements: $e');
    }
  }

  /// Obtenir les statistiques des crédits
  Future<Map<String, dynamic>> getCreditStats() async {
    try {
      final credits = await getAllCredits();

      double totalCreditAmount = 0;
      double totalPaidAmount = 0;
      double totalRemainingAmount = 0;
      int pendingCredits = 0;
      int overdueCredits = 0;

      final now = DateTime.now();

      for (final credit in credits) {
        totalCreditAmount += credit.totalAmount;
        totalPaidAmount += credit.paidAmount;
        totalRemainingAmount += credit.remainingAmount;

        if (credit.status == CreditPaymentStatus.pending ||
            credit.status == CreditPaymentStatus.partiallyPaid) {
          pendingCredits++;

          if (credit.dueDate.isBefore(now)) {
            overdueCredits++;
          }
        }
      }

      return {
        'totalCredits': credits.length,
        'totalCreditAmount': totalCreditAmount,
        'totalPaidAmount': totalPaidAmount,
        'totalRemainingAmount': totalRemainingAmount,
        'pendingCredits': pendingCredits,
        'overdueCredits': overdueCredits,
        'paymentRate': totalCreditAmount > 0
            ? (totalPaidAmount / totalCreditAmount) * 100
            : 0,
      };
    } catch (e) {
      throw Exception('Erreur lors du calcul des statistiques: $e');
    }
  }

  /// Supprimer un crédit
  Future<void> deleteCredit(String creditId) async {
    try {
      await _localStorage.deleteCredit(creditId);

      // Supprimer aussi l'historique des paiements
      final payments = await getCreditPayments(creditId);
      for (final payment in payments) {
        await _localStorage.deleteCreditPayment(payment.id);
      }

      print('🗑️ Crédit $creditId supprimé');
    } catch (e) {
      throw Exception('Erreur lors de la suppression du crédit: $e');
    }
  }

  /// Mettre à jour le crédit actuel d'un client
  Future<void> _updateClientCredit(String clientId, double creditAmount) async {
    try {
      final client = await _clientService.getClientById(clientId);
      if (client != null) {
        final updatedClient = client.copyWith(
          currentCredit: client.currentCredit + creditAmount,
          updatedAt: DateTime.now(),
        );
        await _clientService.updateClient(updatedClient);
        print(
            '💳 Crédit client mis à jour: ${client.name} - Nouveau crédit: ${updatedClient.currentCredit} DH');
      }
    } catch (e) {
      print('❌ Erreur mise à jour crédit client: $e');
      // Ne pas faire échouer la création du crédit pour ce problème
    }
  }
}

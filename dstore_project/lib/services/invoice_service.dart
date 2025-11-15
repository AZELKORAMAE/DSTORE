import '../models/invoice_model.dart';
import '../models/revenue_model.dart';
import 'local_storage_service.dart';
import 'product_service.dart';
import 'credit_service.dart';
import 'revenue_service.dart';

class InvoiceService {
  final LocalStorageService _localStorage = LocalStorageService.instance;
  final ProductService _productService = ProductService();
  final CreditService _creditService = CreditService();
  final RevenueService _revenueService = RevenueService();

  Future<List<InvoiceModel>> getAllInvoices() async {
    try {
      print('🔍 Début du chargement des factures...');
      final invoicesData = _localStorage.getInvoices();
      print('📊 Données reçues: ${invoicesData.length} factures');

      if (invoicesData.isEmpty) {
        print('✅ Aucune facture trouvée');
        return [];
      }

      final List<InvoiceModel> invoices = [];
      for (int i = 0; i < invoicesData.length; i++) {
        try {
          // Conversion récursive pour gérer les structures imbriquées
          final Map<String, dynamic> invoiceMap =
              _convertToStringDynamicMap(invoicesData[i]);
          final invoice = InvoiceModel.fromJson(invoiceMap);

          // Charger les produits pour les articles de facture
          final invoiceWithProducts = await _loadProductsForInvoice(invoice);
          invoices.add(invoiceWithProducts);
        } catch (e) {
          print('⚠️ Facture corrompue à l\'index $i, ignorée: $e');
          // Continuer avec les autres factures
        }
      }

      print(
          '✅ ${invoices.length} factures chargées (${invoicesData.length - invoices.length} ignorées)');
      return invoices;
    } catch (e) {
      print('❌ Erreur chargement factures: $e');
      print('🔍 Détails de l\'erreur: ${e.toString()}');

      // En cas d'erreur critique, nettoyer les données corrompues
      print('🧹 Nettoyage des données corrompues...');
      await _cleanCorruptedData();
      return [];
    }
  }

  // Méthode pour nettoyer les données corrompues
  Future<void> _cleanCorruptedData() async {
    try {
      print('🧹 Suppression des factures corrompues...');
      _localStorage.clearInvoices();
      print('✅ Données nettoyées avec succès');
    } catch (e) {
      print('❌ Erreur lors du nettoyage: $e');
    }
  }

  // Méthode utilitaire pour convertir récursivement Map<dynamic, dynamic> en Map<String, dynamic>
  Map<String, dynamic> _convertToStringDynamicMap(dynamic data) {
    if (data is Map) {
      return Map<String, dynamic>.from(
        data.map((key, value) => MapEntry(
              key.toString(),
              _convertDynamicValue(value),
            )),
      );
    }
    return {};
  }

  // Méthode utilitaire pour convertir les valeurs dynamiques
  dynamic _convertDynamicValue(dynamic value) {
    if (value is Map) {
      return _convertToStringDynamicMap(value);
    } else if (value is List) {
      return value.map((item) => _convertDynamicValue(item)).toList();
    }
    return value;
  }

  Future<InvoiceModel?> getInvoiceById(String id) async {
    try {
      final invoicesData = _localStorage.getInvoices();
      final invoiceData = invoicesData.firstWhere(
        (invoice) => invoice['id'] == id,
        orElse: () => <String, dynamic>{},
      );

      if (invoiceData.isEmpty) return null;

      // Conversion récursive pour gérer les structures imbriquées
      final Map<String, dynamic> invoiceMap =
          _convertToStringDynamicMap(invoiceData);
      final invoice = InvoiceModel.fromJson(invoiceMap);

      // Charger les produits pour les articles de facture
      return await _loadProductsForInvoice(invoice);
    } catch (e) {
      throw Exception('Erreur lors du chargement de la facture: $e');
    }
  }

  /// Charger les produits pour les articles d'une facture
  Future<InvoiceModel> _loadProductsForInvoice(InvoiceModel invoice) async {
    try {
      if (invoice.items == null || invoice.items!.isEmpty) {
        return invoice;
      }

      final List<InvoiceItemModel> itemsWithProducts = [];

      for (final item in invoice.items!) {
        try {
          // Charger le produit depuis le service
          final product = await _productService.getProductById(item.productId);

          // Créer un nouvel item avec le produit chargé
          final itemWithProduct = item.copyWith(product: product);
          itemsWithProducts.add(itemWithProduct);

          if (product != null) {
            print('✅ Produit chargé pour item: ${product.name}');
          } else {
            print('⚠️ Produit non trouvé pour ID: ${item.productId}');
          }
        } catch (e) {
          print('❌ Erreur chargement produit ${item.productId}: $e');
          // Ajouter l'item sans produit
          itemsWithProducts.add(item);
        }
      }

      // Retourner la facture avec les items mis à jour
      return invoice.copyWith(items: itemsWithProducts);
    } catch (e) {
      print('❌ Erreur chargement produits pour facture ${invoice.id}: $e');
      return invoice;
    }
  }

  Future<InvoiceModel> createInvoice(InvoiceModel invoice) async {
    try {
      print(
          '🔄 Début création facture - Type: ${invoice.type}, Items: ${invoice.items?.length ?? 0}');

      final invoiceData = invoice.toJson();
      invoiceData['id'] = DateTime.now().millisecondsSinceEpoch.toString();
      invoiceData['created_at'] = DateTime.now().toIso8601String();
      invoiceData['updated_at'] = DateTime.now().toIso8601String();

      // Sauvegarder la facture
      await _localStorage.saveInvoice(invoiceData);
      final createdInvoice = InvoiceModel.fromJson(invoiceData);
      print('✅ Facture sauvegardée - ID: ${createdInvoice.id}');

      // Mettre à jour automatiquement les stocks
      print('🔄 Début mise à jour des stocks...');
      await _updateStockForInvoice(createdInvoice);
      print('✅ Mise à jour des stocks terminée');

      // Enregistrer le revenu si c'est une vente avec un montant payé
      if (createdInvoice.type == InvoiceType.sale && createdInvoice.paidAmount > 0) {
        await _revenueService.recordRevenue(
          amount: createdInvoice.paidAmount,
          type: RevenueType.invoice,
          sourceId: createdInvoice.id,
          clientId: createdInvoice.clientId,
          description: 'Paiement facture ${createdInvoice.invoiceNumber}',
        );
        print('📊 Revenu enregistré lors de la création: ${createdInvoice.paidAmount} DH');
      }

      // Créer automatiquement un crédit si paiement partiel
      await _createCreditIfNeeded(createdInvoice);

      return createdInvoice;
    } catch (e) {
      print('❌ Erreur création facture: $e');
      throw Exception('Erreur lors de la création de la facture: $e');
    }
  }

  Future<InvoiceModel> updateInvoice(InvoiceModel invoice) async {
    try {
      print(
          '🔄 Début mise à jour facture - Type: ${invoice.type}, Items: ${invoice.items?.length ?? 0}');

      // Récupérer l'ancienne facture pour comparer les changements
      final oldInvoice = await getInvoiceById(invoice.id);
      
      final invoiceData = invoice.toJson();
      invoiceData['updated_at'] = DateTime.now().toIso8601String();

      // Sauvegarder la facture mise à jour
      await _localStorage.saveInvoice(invoiceData);
      final updatedInvoice = InvoiceModel.fromJson(invoiceData);
      print('✅ Facture mise à jour - ID: ${updatedInvoice.id}');

      // Restaurer les stocks de l'ancienne facture si elle existait
      if (oldInvoice != null) {
        print('🔄 Restauration des stocks de l\'ancienne facture...');
        await _restoreStockForInvoice(oldInvoice);
        print('✅ Stocks restaurés');
      }

      // Appliquer les nouveaux changements de stock
      print('🔄 Application des nouveaux changements de stock...');
      await _updateStockForInvoice(updatedInvoice);
      print('✅ Nouveaux stocks appliqués');

      // Enregistrer le revenu si c'est une vente avec un montant payé
      if (updatedInvoice.type == InvoiceType.sale && updatedInvoice.paidAmount > 0) {
        // Supprimer l'ancien revenu s'il existait
        if (oldInvoice != null && oldInvoice.paidAmount > 0) {
          await _removeOldRevenue(oldInvoice);
        }
        
        await _revenueService.recordRevenue(
          amount: updatedInvoice.paidAmount,
          type: RevenueType.invoice,
          sourceId: updatedInvoice.id,
          clientId: updatedInvoice.clientId,
          description: 'Paiement facture ${updatedInvoice.invoiceNumber} (mise à jour)',
        );
        print('📊 Revenu enregistré lors de la mise à jour: ${updatedInvoice.paidAmount} DH');
      }

      // Gérer les crédits automatiquement
      await _updateCreditsForInvoice(oldInvoice, updatedInvoice);

      return updatedInvoice;
    } catch (e) {
      print('❌ Erreur mise à jour facture: $e');
      throw Exception('Erreur lors de la mise à jour de la facture: $e');
    }
  }

  Future<void> deleteInvoice(String id) async {
    try {
      await _localStorage.deleteInvoice(id);
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la facture: $e');
    }
  }

  Future<List<InvoiceModel>> getInvoicesByDateRange(
      DateTime startDate, DateTime endDate) async {
    try {
      final invoicesData = _localStorage.getInvoices();
      final filteredInvoices = invoicesData.where((invoice) {
        final invoiceDate = DateTime.tryParse(invoice['invoice_date'] ?? '');
        if (invoiceDate == null) return false;

        return invoiceDate
                .isAfter(startDate.subtract(const Duration(days: 1))) &&
            invoiceDate.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();

      return filteredInvoices
          .map((json) => InvoiceModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors du filtrage par date: $e');
    }
  }

  Future<List<InvoiceModel>> getInvoicesByType(String type) async {
    try {
      final invoicesData = _localStorage.getInvoices();
      final filteredInvoices = invoicesData.where((invoice) {
        return invoice['invoice_type'] == type;
      }).toList();

      return filteredInvoices
          .map((json) => InvoiceModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors du filtrage par type: $e');
    }
  }

  Future<List<InvoiceModel>> getInvoicesByStatus(String status) async {
    try {
      final invoicesData = _localStorage.getInvoices();
      final filteredInvoices = invoicesData.where((invoice) {
        return invoice['status'] == status;
      }).toList();

      return filteredInvoices
          .map((json) => InvoiceModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors du filtrage par statut: $e');
    }
  }

  Future<List<InvoiceModel>> getInvoicesByClient(String clientId) async {
    try {
      final invoicesData = _localStorage.getInvoices();
      final filteredInvoices = invoicesData.where((invoice) {
        return invoice['client_id'] == clientId;
      }).toList();

      return filteredInvoices
          .map((json) => InvoiceModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors du filtrage par client: $e');
    }
  }

  Future<List<InvoiceModel>> getInvoicesBySupplier(String supplierId) async {
    try {
      final invoicesData = _localStorage.getInvoices();
      final filteredInvoices = invoicesData.where((invoice) {
        return invoice['supplier_id'] == supplierId;
      }).toList();

      return filteredInvoices
          .map((json) => InvoiceModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors du filtrage par fournisseur: $e');
    }
  }

  Future<double> getTotalRevenue(
      {DateTime? startDate, DateTime? endDate}) async {
    try {
      final invoicesData = _localStorage.getInvoices();
      double total = 0.0;

      for (final invoiceData in invoicesData) {
        final invoiceDate =
            DateTime.tryParse(invoiceData['invoice_date'] ?? '');
        if (invoiceDate == null) continue;

        // Filtrer par date si spécifié
        if (startDate != null && invoiceDate.isBefore(startDate)) continue;
        if (endDate != null && invoiceDate.isAfter(endDate)) continue;

        // Seulement les factures de vente payées
        if (invoiceData['invoice_type'] == 'sale' &&
            invoiceData['status'] == 'paid') {
          total += (invoiceData['total_amount'] ?? 0.0).toDouble();
        }
      }

      return total;
    } catch (e) {
      return 0.0;
    }
  }

  Future<double> getTodayRevenue() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    return await getTotalRevenue(startDate: startOfDay, endDate: endOfDay);
  }

  Future<double> getWeekRevenue() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfDay =
        DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

    return await getTotalRevenue(startDate: startOfDay);
  }

  Future<double> getMonthRevenue() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    return await getTotalRevenue(startDate: startOfMonth);
  }

  Future<int> getInvoicesCount() async {
    try {
      final invoicesData = _localStorage.getInvoices();
      return invoicesData.length;
    } catch (e) {
      return 0;
    }
  }

  Future<double> getPendingAmount() async {
    try {
      final invoicesData = _localStorage.getInvoices();
      double total = 0.0;

      for (final invoiceData in invoicesData) {
        if (invoiceData['status'] == 'pending' ||
            invoiceData['status'] == 'partial') {
          final totalAmount = (invoiceData['total_amount'] ?? 0.0).toDouble();
          final paidAmount = (invoiceData['paid_amount'] ?? 0.0).toDouble();
          total += (totalAmount - paidAmount);
        }
      }

      return total;
    } catch (e) {
      return 0.0;
    }
  }

  Future<List<InvoiceModel>> searchInvoices(String query) async {
    try {
      final invoicesData = _localStorage.getInvoices();
      final filteredInvoices = invoicesData.where((invoice) {
        final invoiceNumber =
            invoice['invoice_number']?.toString().toLowerCase() ?? '';
        final clientName =
            invoice['client_name']?.toString().toLowerCase() ?? '';
        final supplierName =
            invoice['supplier_name']?.toString().toLowerCase() ?? '';
        final searchQuery = query.toLowerCase();

        return invoiceNumber.contains(searchQuery) ||
            clientName.contains(searchQuery) ||
            supplierName.contains(searchQuery);
      }).toList();

      return filteredInvoices
          .map((json) => InvoiceModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la recherche: $e');
    }
  }

  Future<String> generateInvoiceNumber(String type) async {
    try {
      final invoicesData = _localStorage.getInvoices();
      final now = DateTime.now();
      final year = now.year.toString();
      final month = now.month.toString().padLeft(2, '0');

      final prefix = type == 'sale' ? 'VTE' : 'ACH';
      final existingNumbers = invoicesData
          .where((invoice) =>
              invoice['invoice_number']
                  ?.toString()
                  .startsWith('$prefix-$year$month') ==
              true)
          .length;

      final nextNumber = (existingNumbers + 1).toString().padLeft(4, '0');
      return '$prefix-$year$month-$nextNumber';
    } catch (e) {
      final now = DateTime.now();
      final year = now.year.toString();
      final month = now.month.toString().padLeft(2, '0');
      final prefix = type == 'sale' ? 'VTE' : 'ACH';
      return '$prefix-$year$month-0001';
    }
  }

  Future<Map<String, double>> getRevenueByPeriod(int days) async {
    try {
      final invoicesData = _localStorage.getInvoices();
      final Map<String, double> revenueByDay = {};
      final now = DateTime.now();

      for (int i = 0; i < days; i++) {
        final date = now.subtract(Duration(days: i));
        final dateKey = '${date.day}/${date.month}';
        revenueByDay[dateKey] = 0.0;
      }

      for (final invoiceData in invoicesData) {
        final invoiceDate =
            DateTime.tryParse(invoiceData['invoice_date'] ?? '');
        if (invoiceDate == null) continue;

        final daysDiff = now.difference(invoiceDate).inDays;
        if (daysDiff >= 0 && daysDiff < days) {
          final dateKey = '${invoiceDate.day}/${invoiceDate.month}';
          if (invoiceData['invoice_type'] == 'sale' &&
              invoiceData['status'] == 'paid') {
            revenueByDay[dateKey] = (revenueByDay[dateKey] ?? 0.0) +
                (invoiceData['total_amount'] ?? 0.0).toDouble();
          }
        }
      }

      return revenueByDay;
    } catch (e) {
      return {};
    }
  }

  Future<void> validateInvoice(String invoiceId) async {
    try {
      final invoice = await getInvoiceById(invoiceId);
      if (invoice != null) {
        final invoiceData = invoice.toJson();
        invoiceData['status'] = 'validated';
        invoiceData['updated_at'] = DateTime.now().toIso8601String();
        await _localStorage.saveInvoice(invoiceData);
      }
    } catch (e) {
      throw Exception('Erreur lors de la validation de la facture: $e');
    }
  }

  Future<void> markAsPaid(String invoiceId, double paidAmount) async {
    try {
      final invoice = await getInvoiceById(invoiceId);
      if (invoice != null) {
        final invoiceData = invoice.toJson();
        final totalAmount = (invoiceData['total_amount'] ?? 0.0).toDouble();

        invoiceData['paid_amount'] = paidAmount;
        if (paidAmount >= totalAmount) {
          invoiceData['status'] = 'paid';
        } else if (paidAmount > 0) {
          invoiceData['status'] = 'partial';

          // Créer automatiquement un crédit pour le montant restant
          final updatedInvoice = InvoiceModel.fromJson(invoiceData);
          await _createCreditIfNeeded(updatedInvoice);
        }
        invoiceData['updated_at'] = DateTime.now().toIso8601String();
        await _localStorage.saveInvoice(invoiceData);

        // Enregistrer le paiement comme un revenu si c'est une vente
        if (invoice.type == InvoiceType.sale && paidAmount > 0) {
          await _revenueService.recordRevenue(
            amount: paidAmount,
            type: RevenueType.invoice,
            sourceId: invoiceId,
            clientId: invoice.clientId,
            description: 'Paiement facture ${invoice.invoiceNumber}',
          );
          print('📊 Revenu enregistré pour paiement de facture: $paidAmount DH');
        }
      }
    } catch (e) {
      throw Exception('Erreur lors du marquage comme payé: $e');
    }
  }

  Future<void> cancelInvoice(String invoiceId) async {
    try {
      final invoice = await getInvoiceById(invoiceId);
      if (invoice != null) {
        final invoiceData = invoice.toJson();
        invoiceData['status'] = 'cancelled';
        invoiceData['updated_at'] = DateTime.now().toIso8601String();
        await _localStorage.saveInvoice(invoiceData);
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'annulation de la facture: $e');
    }
  }

  /// Mettre à jour automatiquement les stocks selon le type de facture
  Future<void> _updateStockForInvoice(InvoiceModel invoice) async {
    try {
      print('🔍 _updateStockForInvoice appelée - Type: ${invoice.type}');

      if (invoice.items == null || invoice.items!.isEmpty) {
        print(
            '⚠️ Aucun item dans la facture, arrêt de la mise à jour des stocks');
        return;
      }

      print('📋 Nombre d\'items à traiter: ${invoice.items!.length}');

      for (final item in invoice.items!) {
        print(
            '🔍 Traitement item - ProductID: ${item.productId}, Quantity: ${item.quantity}');

        if (item.productId == null || item.quantity == null) {
          print('⚠️ Item ignoré - ProductID ou Quantity null');
          continue;
        }

        final product = await _productService.getProductById(item.productId!);
        if (product == null) {
          print('⚠️ Produit non trouvé - ID: ${item.productId}');
          continue;
        }

        print(
            '📦 Produit trouvé: ${product.name} - Stock actuel: ${product.stockQuantity}');
        final double currentStock = product.stockQuantity;
        double newStock;

        if (invoice.type == InvoiceType.sale) {
          // Vente : réduire le stock
          newStock = currentStock - item.quantity!;
          print(
              '📦 Vente: ${product.name} - Stock réduit de ${item.quantity} (${currentStock} → ${newStock})');
        } else if (invoice.type == InvoiceType.purchase) {
          // Achat : augmenter le stock
          newStock = currentStock + item.quantity!;
          print(
              '📦 Achat: ${product.name} - Stock augmenté de ${item.quantity} (${currentStock} → ${newStock})');
        } else {
          print(
              '⚠️ Type de facture non supporté pour mise à jour stock: ${invoice.type}');
          continue; // Autres types de factures
        }

        // Empêcher les stocks négatifs
        if (newStock < 0) {
          print(
              '⚠️ Stock insuffisant pour ${product.name}. Stock actuel: $currentStock, Demandé: ${item.quantity}');
          newStock = 0;
        }

        // Mettre à jour le stock
        print(
            '🔄 Mise à jour stock pour ${product.name}: ${currentStock} → ${newStock}');
        await _productService.updateProductStock(item.productId!, newStock);
        print('✅ Stock mis à jour avec succès pour ${product.name}');
      }
    } catch (e) {
      print('❌ Erreur mise à jour stock: $e');
      // Ne pas faire échouer la création de facture pour un problème de stock
    }
  }

  /// Créer automatiquement un crédit si paiement partiel
  Future<void> _createCreditIfNeeded(InvoiceModel invoice) async {
    try {
      // Vérifier si c'est une vente avec paiement partiel
      if (invoice.type != InvoiceType.sale) return;
      if (invoice.clientId == null || invoice.clientId!.isEmpty) return;
      if (invoice.paidAmount >= invoice.totalAmount) return;

      final remainingAmount = invoice.totalAmount - invoice.paidAmount;
      if (remainingAmount <= 0) return;

      // Vérifier si un crédit existe déjà pour cette facture
      final existingCredits = await _creditService.getCreditsByInvoice(invoice.id);
      if (existingCredits.isNotEmpty) {
        print('⚠️ Crédit déjà existant pour facture ${invoice.invoiceNumber}');
        return;
      }

      // Créer automatiquement le crédit
      await _creditService.createCreditFromInvoice(
        invoiceId: invoice.id,
        clientId: invoice.clientId!,
        totalAmount: invoice.totalAmount,
        paidAmount: invoice.paidAmount,
        dueDays: 30, // 30 jours par défaut
        notes:
            'Crédit automatique - Paiement partiel de ${invoice.paidAmount.toStringAsFixed(2)} DH sur ${invoice.totalAmount.toStringAsFixed(2)} DH',
      );

      print(
          '💳 Crédit automatique créé pour facture ${invoice.invoiceNumber} - Montant: ${remainingAmount.toStringAsFixed(2)} DH');
    } catch (e) {
      print('❌ Erreur création crédit automatique: $e');
      // Ne pas faire échouer la création de facture pour un problème de crédit
    }
  }

  /// Restaurer les stocks de l'ancienne facture (inverse des opérations)
  Future<void> _restoreStockForInvoice(InvoiceModel invoice) async {
    try {
      print('🔍 _restoreStockForInvoice appelée - Type: ${invoice.type}');

      if (invoice.items == null || invoice.items!.isEmpty) {
        print('⚠️ Aucun item dans l\'ancienne facture, arrêt de la restauration');
        return;
      }

      for (final item in invoice.items!) {
        if (item.productId == null || item.quantity == null) continue;

        final product = await _productService.getProductById(item.productId!);
        if (product == null) continue;

        final double currentStock = product.stockQuantity;
        double restoredStock;

        if (invoice.type == InvoiceType.sale) {
          // Restaurer une vente : augmenter le stock
          restoredStock = currentStock + item.quantity!;
          print('🔄 Restauration vente: ${product.name} - Stock restauré +${item.quantity} (${currentStock} → ${restoredStock})');
        } else if (invoice.type == InvoiceType.purchase) {
          // Restaurer un achat : réduire le stock
          restoredStock = currentStock - item.quantity!;
          if (restoredStock < 0) restoredStock = 0;
          print('🔄 Restauration achat: ${product.name} - Stock restauré -${item.quantity} (${currentStock} → ${restoredStock})');
        } else {
          continue;
        }

        await _productService.updateProductStock(item.productId!, restoredStock);
      }
    } catch (e) {
      print('❌ Erreur restauration stock: $e');
    }
  }

  /// Supprimer l'ancien revenu lors de la mise à jour
  Future<void> _removeOldRevenue(InvoiceModel oldInvoice) async {
    try {
      // Récupérer tous les revenus et supprimer ceux liés à cette facture
      final allRevenues = await _revenueService.getAllRevenues();
      final oldRevenues = allRevenues.where((revenue) => 
        revenue.sourceId == oldInvoice.id && revenue.type == RevenueType.invoice
      ).toList();
      
      for (final revenue in oldRevenues) {
        await _revenueService.deleteRevenue(revenue.id);
        print('🗑️ Ancien revenu supprimé: ${revenue.amount} DH');
      }
    } catch (e) {
      print('❌ Erreur suppression ancien revenu: $e');
    }
  }

  /// Gérer les crédits lors de la mise à jour de facture
  Future<void> _updateCreditsForInvoice(InvoiceModel? oldInvoice, InvoiceModel newInvoice) async {
    try {
      // Supprimer les anciens crédits si ils existent
      if (oldInvoice != null) {
        final oldCredits = await _creditService.getCreditsByInvoice(oldInvoice.id);
        for (final credit in oldCredits) {
          await _creditService.deleteCredit(credit.id);
          print('🗑️ Ancien crédit supprimé: ${credit.id}');
        }
      }

      // Créer un nouveau crédit si nécessaire
      await _createCreditIfNeeded(newInvoice);
    } catch (e) {
      print('❌ Erreur gestion crédits: $e');
    }
  }
}

import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/category_model.dart';
import '../../providers/category_provider.dart';
import '../../services/transaction_report_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../utils/app_utils.dart';
import '../../models/invoice_model.dart';
import '../../models/product_model.dart';
import '../../providers/product_provider.dart';
// Search bar widget import removed; we use product filter instead

/// Screen that allows the user to generate a report of sold and purchased products
/// over a custom date range. The user can filter by category and minimum
/// quantity. The results can be exported as an Excel file.
class ProductTransactionsReportScreen extends StatefulWidget {
  const ProductTransactionsReportScreen({super.key});

  @override
  State<ProductTransactionsReportScreen> createState() => _ProductTransactionsReportScreenState();
}

class _ProductTransactionsReportScreenState extends State<ProductTransactionsReportScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  CategoryModel? _selectedCategory;
  final TextEditingController _minQuantityController = TextEditingController();
  bool _isLoading = false;
  List<ReportItem> _results = [];

  // Liste des produits sélectionnés pour filtrer le rapport. Si vide, tous les produits sont pris en compte.
  List<String> _selectedProductIds = [];
  List<ProductModel> _selectedProducts = [];

  @override
  void initState() {
    super.initState();
    // Charger les catégories après la première frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        Provider.of<CategoryProvider>(context, listen: false).loadCategories();
      } catch (_) {
        // Ignore errors
      }
    });
  }

  @override
  void dispose() {
    _minQuantityController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final initialDate = _startDate ?? now;
    final newDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );
    if (newDate != null) {
      setState(() {
        _startDate = newDate;
        // Ensure start date is not after end date
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = _startDate;
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    final now = DateTime.now();
    final initialDate = _endDate ?? now;
    final newDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );
    if (newDate != null) {
      setState(() {
        _endDate = newDate;
        // Ensure end date is not before start date
        if (_startDate != null && _endDate!.isBefore(_startDate!)) {
          _startDate = _endDate;
        }
      });
    }
  }

  Future<void> _generateReport() async {
    final l10n = AppLocalizations.of(context)!;
    if (_startDate == null || _endDate == null) {
      AppUtils.showSnackBar(context, l10n.selectDateRangeFirst, isError: true);
      return;
    }
    setState(() {
      _isLoading = true;
    });
    final reportService = TransactionReportService();
    final minQty = double.tryParse(_minQuantityController.text.trim());
    final categoryId = _selectedCategory?.id;
    try {
      final results = await reportService.getTransactions(
        start: _startDate!,
        end: _endDate!,
        categoryId: categoryId,
        minQuantity: minQty,
        productIds: _selectedProductIds.isNotEmpty ? _selectedProductIds : null,
      );
      setState(() {
        // Pas de recherche dynamique, assigner directement
        _results = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      AppUtils.showSnackBar(context, '${l10n.errorLoadingReport}: $e', isError: true);
    }
  }

  // Aucune recherche dynamique par nom de produit; les résultats sont assignés directement

  Future<void> _exportToExcel() async {
    final l10n = AppLocalizations.of(context)!;
    if (_results.isEmpty) {
      AppUtils.showSnackBar(context, l10n.noDataToExport, isError: true);
      return;
    }
    try {
      // Générer un fichier CSV compatible Excel.
      // On utilise le point-virgule comme séparateur et on ajoute un BOM (\uFEFF) en début de fichier
      // pour que les caractères spéciaux (notamment l'arabe) soient correctement interprétés.
      final List<String> lines = [];
      // En-tête incluant prix unitaire et stock
      lines.add([
        l10n.productName,
        l10n.category,
        l10n.quantity,
        l10n.unitPriceLabel,
        l10n.stockColumn
            .replaceAll('•', '')
            .replaceAll('stock - ', '')
            .trim(),
        l10n.transactionType,
        l10n.date,
      ].join(';'));
      // Données
      for (final item in _results) {
        lines.add([
          item.productName,
          item.categoryName,
          item.quantity.toString(),
          item.unitPrice.toStringAsFixed(2),
          item.stockQuantity.toString(),
          item.type == InvoiceType.sale ? l10n.sale : l10n.purchase,
          DateFormat('yyyy-MM-dd').format(item.date),
        ].join(';'));
      }
      // Ajouter un BOM (Byte Order Mark) pour l'encodage UTF-8
      final csvContent = '\uFEFF' + lines.join('\n');
      final directory = await getTemporaryDirectory();
      final fileName =
          'transactions_report_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File('${directory.path}/$fileName')
        ..createSync(recursive: true)
        ..writeAsStringSync(csvContent, encoding: const Utf8Codec());
      await Share.shareXFiles(
        [XFile(file.path)],
        text: l10n.productTransactionReport,
        subject: l10n.productTransactionReport,
      );
    } catch (e) {
      AppUtils.showSnackBar(context, '${l10n.exportFailed}: $e', isError: true);
    }
  }

  /// Ouvre une feuille de sélection des produits pour filtrer le rapport.
  Future<void> _openProductSelection() async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;
    // Charger les produits si nécessaire
    await productProvider.loadProducts();
    final List<ProductModel> products = productProvider.allProducts
        .where((p) => p.isActive)
        .toList();

    // Utiliser StatefulBuilder pour mettre à jour la liste filtrée localement
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        // Liste filtrée locale et contrôleur de recherche
        List<ProductModel> filtered = List.from(products);
        final TextEditingController searchController = TextEditingController();

        void filter(String value) {
          filtered = products
              .where((product) => product.name
                  .toLowerCase()
                  .contains(value.toLowerCase()))
              .toList();
        }

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  height: MediaQuery.of(context).size.height * 0.75,
                  child: Column(
                    children: [
                      // Barre de recherche interne
                      TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          labelText: l10n.searchProducts,
                          prefixIcon: const Icon(Icons.search),
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setModalState(() {
                            filter(value);
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: filtered.isEmpty
                            ? Center(child: Text(l10n.noDataFound))
                            : ListView.builder(
                                itemCount: filtered.length,
                                itemBuilder: (context, index) {
                                  final product = filtered[index];
                                  final isSelected =
                                      _selectedProductIds.contains(product.id);
                                  return CheckboxListTile(
                                    value: isSelected,
                                    onChanged: (value) {
                                      setModalState(() {
                                        if (value == true) {
                                          if (!_selectedProductIds.contains(product.id)) {
                                            _selectedProductIds.add(product.id);
                                            _selectedProducts.add(product);
                                          }
                                        } else {
                                          _selectedProductIds.remove(product.id);
                                          _selectedProducts.removeWhere(
                                              (p) => p.id == product.id);
                                        }
                                      });
                                    },
                                    title: Text(product.name),
                                    subtitle: Text(
                                      // Afficher les prix d'achat et de vente pour distinguer les doublons
                                      '${product.purchasePrice.toStringAsFixed(2)} / ${product.sellingPrice.toStringAsFixed(2)}',
                                    ),
                                  );
                                },
                              ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              // Réinitialiser la sélection si annulé
                              searchController.dispose();
                              Navigator.of(context).pop();
                            },
                            child: Text(l10n.cancel),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () {
                              searchController.dispose();
                              Navigator.of(context).pop();
                              setState(() {});
                            },
                            child: Text(l10n.confirm),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categories = Provider.of<CategoryProvider>(context).categories;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.productTransactionReport),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filtres de produits sélectionnés
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Afficher des chips pour chaque produit sélectionné
                Expanded(
                  child: _selectedProducts.isEmpty
                      ? Text(
                          // Texte pour indiquer que tous les produits sont pris en compte
                          'Tous les produits',
                          style: TextStyle(color: Colors.grey[600]),
                        )
                      : Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: _selectedProducts
                              .map(
                                (product) => Chip(
                                  label: Text(product.name),
                                  onDeleted: () {
                                    setState(() {
                                      _selectedProductIds.remove(product.id);
                                      _selectedProducts.removeWhere(
                                          (p) => p.id == product.id);
                                    });
                                  },
                                ),
                              )
                              .toList(),
                        ),
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  tooltip: 'Sélectionner des produits',
                  onPressed: _openProductSelection,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Date range selectors
            Row(
              children: [
                Expanded(
                  child: _buildDateSelector(
                    label: l10n.startDate,
                    date: _startDate,
                    onTap: _pickStartDate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateSelector(
                    label: l10n.endDate,
                    date: _endDate,
                    onTap: _pickEndDate,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Category filter
            DropdownButtonFormField<CategoryModel>(
              decoration: InputDecoration(
                labelText: l10n.category,
                border: const OutlineInputBorder(),
              ),
              value: _selectedCategory,
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(l10n.allCategories),
                ),
                ...categories.map(
                  (category) => DropdownMenuItem(
                    value: category,
                    child: Text(category.name),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
            const SizedBox(height: 16),
            // Minimum quantity filter
            TextFormField(
              controller: _minQuantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.minimumQuantity,
                hintText: '0',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            // Action buttons
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _generateReport,
                  icon: const Icon(Icons.search),
                  label: Text(l10n.viewReport),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _isLoading || _results.isEmpty
                      ? null
                      : _exportToExcel,
                  icon: const Icon(Icons.download),
                  label: Text(l10n.exportToExcel),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Results
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                    ? Center(
                        child: Text(l10n.noDataFound),
                      )
                    : _buildResultsTable(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12,
                      )),
                  const SizedBox(height: 4),
                  Text(
                    date != null
                        ? DateFormat('yyyy-MM-dd').format(date)
                        : '--',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.calendar_today, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsTable(AppLocalizations l10n) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text(l10n.productName)),
          DataColumn(label: Text(l10n.category)),
          DataColumn(label: Text(l10n.quantity)),
          // Afficher le prix unitaire
          DataColumn(label: Text(l10n.unitPriceLabel)),
          // Afficher la quantité en stock ; supprimer le point noir et le préfixe éventuel
          DataColumn(
            label: Text(
              l10n.stockColumn
                  .replaceAll('•', '')
                  .replaceAll('stock - ', '')
                  .trim(),
            ),
          ),
          DataColumn(label: Text(l10n.transactionType)),
          DataColumn(label: Text(l10n.date)),
        ],
        rows: _results
            .map(
              (item) => DataRow(cells: [
                DataCell(Text(item.productName)),
                DataCell(Text(item.categoryName)),
                DataCell(Text(item.quantity.toString())),
                DataCell(Text(item.unitPrice.toStringAsFixed(2))),
                DataCell(Text(item.stockQuantity.toString())),
                DataCell(Text(item.type == InvoiceType.sale
                    ? l10n.sale
                    : l10n.purchase)),
                DataCell(
                  Text(DateFormat('yyyy-MM-dd').format(item.date)),
                ),
              ]),
            )
            .toList(),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:go_router/go_router.dart';

import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
import '../../config/app_router.dart';
import '../../main.dart';
import '../../widgets/products/product_card.dart';
import '../../widgets/products/product_list_item.dart';
import 'import_products_screen.dart';
import '../../widgets/search/advanced_search_bar.dart';
import '../../widgets/common/filter_chip_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProductsScreen extends StatefulWidget {
  final String? categoryId;
  final String? categoryName;

  const ProductsScreen({
    super.key,
    this.categoryId,
    this.categoryName,
  });

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  bool _isGridView = true;
  String _sortBy = 'name';
  bool _isSelectionMode = false;
  Set<String> _selectedProductIds = <String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);
      final categoryProvider =
          Provider.of<CategoryProvider>(context, listen: false);

      productProvider.loadProducts();
      categoryProvider.loadCategories();

      // Si une catégorie est spécifiée, filtrer par cette catégorie
      if (widget.categoryId != null) {
        productProvider.filterByCategory(widget.categoryId);
      }
    });
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedProductIds.clear();
      }
    });
  }

  void _toggleProductSelection(String productId) {
    setState(() {
      if (_selectedProductIds.contains(productId)) {
        _selectedProductIds.remove(productId);
      } else {
        _selectedProductIds.add(productId);
      }
    });
  }

  void _selectAllProducts() {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    setState(() {
      _selectedProductIds.addAll(productProvider.products.map((p) => p.id));
    });
  }

  /// Afficher une boîte de dialogue pour sélectionner une catégorie et assigner
  /// les produits sélectionnés à cette catégorie.
  Future<void> _showAssignCategoryDialog() async {
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    String? selectedCategoryId;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Assigner à une catégorie'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: categoryProvider.categories.map((category) {
                  return RadioListTile<String>(
                    title: Text(category.name),
                    value: category.id,
                    groupValue: selectedCategoryId,
                    secondary: CircleAvatar(
                      backgroundColor: category.colorValue,
                      radius: 8,
                    ),
                    onChanged: (value) {
                      selectedCategoryId = value;
                      // Rebuild dialog
                      (context as Element).markNeedsBuild();
                    },
                  );
                }).toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: selectedCategoryId == null
                  ? null
                  : () async {
                      await productProvider.assignProductsToCategory(
                          _selectedProductIds, selectedCategoryId!);
                      // Recharger les catégories pour mettre à jour les statistiques
                      await categoryProvider.loadCategories();
                      // Sortir du mode sélection
                      setState(() {
                        _selectedProductIds.clear();
                        _isSelectionMode = false;
                      });
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                                'Produits assignés à la catégorie avec succès'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                      Navigator.of(context).pop();
                    },
              child: const Text('Assigner'),
            ),
          ],
        );
      },
    );
  }

  void _deselectAllProducts() {
    setState(() {
      _selectedProductIds.clear();
    });
  }

  Future<void> _deleteSelectedProducts() async {
    if (_selectedProductIds.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer ${_selectedProductIds.length} produit(s) sélectionné(s) ?\n\nCette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);

      try {
        // Supprimer tous les produits sélectionnés
        for (String productId in _selectedProductIds) {
          await productProvider.deleteProduct(productId);
        }

        if (mounted) {
          // Afficher un message de succès
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_selectedProductIds.length} produit(s) supprimé(s) avec succès'),
              backgroundColor: Colors.green,
            ),
          );

          // Sortir du mode sélection
          _toggleSelectionMode();
        }

      } catch (e) {
        if (mounted) {
          // Afficher l'erreur
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la suppression: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    return Scaffold(
      body: Column(
        children: [
          // Barre de sélection multiple (si activée)
          if (_isSelectionMode) _buildSelectionBar(context),

          // Barre de recherche et filtres
          _buildSearchAndFilters(context),

          // Statistiques rapides
          _buildQuickStats(context),

          // Liste/Grille des produits
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, productProvider, child) {
                if (productProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (productProvider.errorMessage != null) {
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
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          productProvider.errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => productProvider.loadProducts(),
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                }

                final products = productProvider.products;

                if (products.isEmpty) {
                  return _buildEmptyState(context);
                }

                return RefreshIndicator(
                  onRefresh: () => productProvider.loadProducts(),
                  child: _isGridView
                      ? _buildGridView(context, products, isDesktop, isTablet)
                      : _buildListView(context, products),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "import",
            onPressed: () => _showImportOptions(context),
            backgroundColor: Colors.orange,
            child: const Icon(Icons.upload_file),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            heroTag: "add",
            onPressed: () => context.goToAddProduct(),
            icon: const Icon(Icons.add),
            label: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).primaryColor.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Bouton fermer le mode sélection
          IconButton(
            onPressed: _toggleSelectionMode,
            icon: const Icon(Icons.close),
            tooltip: 'Quitter le mode sélection',
          ),

          // Compteur de sélection
          Expanded(
            child: Text(
              '${_selectedProductIds.length} produit(s) sélectionné(s)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Actions
          if (_selectedProductIds.isNotEmpty) ...[
            // Bouton assigner à une catégorie
            IconButton(
              onPressed: _showAssignCategoryDialog,
              icon: const Icon(Icons.label),
              tooltip: 'Assigner à une catégorie',
            ),

            // Bouton tout désélectionner
            IconButton(
              onPressed: _deselectAllProducts,
              icon: const Icon(Icons.deselect),
              tooltip: 'Tout désélectionner',
            ),

            // Bouton supprimer
            ElevatedButton.icon(
              onPressed: _deleteSelectedProducts,
              icon: const Icon(Icons.delete, size: 18),
              label: Text('${_selectedProductIds.length}'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(60, 36),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ] else ...[
            // Bouton tout sélectionner
            IconButton(
              onPressed: _selectAllProducts,
              icon: const Icon(Icons.select_all),
              tooltip: 'Tout sélectionner',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Titre conditionnel si on filtre par catégorie
          if (widget.categoryName != null) ...[
            Row(
              children: [
                Icon(
                  Icons.category,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Produits de la catégorie: ${widget.categoryName}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => context.goToProducts(),
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Voir tous'),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // Barre de recherche avancée
          Consumer2<ProductProvider, CategoryProvider>(
            builder: (context, productProvider, categoryProvider, child) {
              final l10n = AppLocalizations.of(context);
              return AdvancedSearchBar(
                hintText: l10n?.searchProducts ?? 'Rechercher des produits',
                onChanged: (query) => productProvider.searchProducts(query),
                onBarcodeScanned: (barcode) =>
                    productProvider.searchProducts(barcode),
                showCategoryFilter: true,
                categories:
                    categoryProvider.categories.map((c) => c.name).toList(),
                onCategoryChanged: (categoryName) {
                  if (categoryName == null) {
                    productProvider.filterByCategory(null);
                  } else {
                    final category = categoryProvider.categories
                        .firstWhere((c) => c.name == categoryName);
                    productProvider.filterByCategory(category.id);
                  }
                },
              );
            },
          ),

          const SizedBox(height: 12),

          // Filtres et options d'affichage
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Filtres par catégorie
              Flexible(
                child: Consumer2<ProductProvider, CategoryProvider>(
                  builder: (context, productProvider, categoryProvider, child) {
                    return Row(
                      children: [
                        FilterChipWidget(
                          label: 'Tous',
                          isSelected:
                              productProvider.selectedCategoryId == null,
                          onSelected: (_) =>
                              productProvider.filterByCategory(null),
                        ),
                        const SizedBox(width: 8),
                        ...categoryProvider.categories.map(
                          (category) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChipWidget(
                              label: category.name,
                              isSelected: productProvider.selectedCategoryId ==
                                  category.id,
                              onSelected: (_) =>
                                  productProvider.filterByCategory(category.id),
                              color: category.colorValue,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(width: 16),

              // Options d'affichage
              Row(
                children: [
                  // Tri
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.sort),
                    onSelected: (value) {
                      setState(() {
                        _sortBy = value;
                      });
                      // Implémenter le tri
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'name',
                        child: Text('Nom'),
                      ),
                      const PopupMenuItem(
                        value: 'price',
                        child: Text('Prix'),
                      ),
                      const PopupMenuItem(
                        value: 'stock',
                        child: Text('Stock'),
                      ),
                      const PopupMenuItem(
                        value: 'category',
                        child: Text('Catégorie'),
                      ),
                    ],
                  ),

                  // Mode sélection multiple
                  if (!_isSelectionMode)
                    IconButton(
                      icon: const Icon(Icons.checklist),
                      onPressed: _toggleSelectionMode,
                      tooltip: 'Mode sélection multiple',
                    ),

                  // Vue grille/liste
                  IconButton(
                    icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
                    onPressed: () {
                      setState(() {
                        _isGridView = !_isGridView;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildStatChip(
                      context,
                      AppLocalizations.of(context)!.total,
                      productProvider.totalProducts.toString(),
                      Icons.inventory_2,
                      Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    _buildStatChip(
                      context,
                      AppLocalizations.of(context)!.stockFaible,
                      productProvider.lowStockCount.toString(),
                      Icons.warning,
                      Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    _buildStatChip(
                      context,
                      AppLocalizations.of(context)!.rupture,
                      productProvider.outOfStockCount.toString(),
                      Icons.error,
                      Colors.red,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${AppLocalizations.of(context)!.valeur}: ${AppUtils.formatCurrency(productProvider.totalStockValue)}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatChip(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            '$label: $value',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(
    BuildContext context,
    List products,
    bool isDesktop,
    bool isTablet,
  ) {
    final crossAxisCount = isDesktop ? 4 : (isTablet ? 3 : 2);

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        // Ajuster le rapport d'aspect pour donner plus de hauteur aux cartes.
        // Une valeur plus faible augmente la hauteur disponible pour éviter
        // les débordements lorsqu'il y a beaucoup d'informations.
        childAspectRatio: 0.68,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(
          product: product,
          isSelectionMode: _isSelectionMode,
          isSelected: _selectedProductIds.contains(product.id),
          onSelectionToggle: () => _toggleProductSelection(product.id),
        );
      },
    );
  }

  Widget _buildListView(BuildContext context, List products) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductListItem(
          product: product,
          isSelectionMode: _isSelectionMode,
          isSelected: _selectedProductIds.contains(product.id),
          onSelectionToggle: () => _toggleProductSelection(product.id),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'Aucun produit',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Commencez par ajouter votre premier produit',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.goToAddProduct(),
            icon: const Icon(Icons.add),
            label: const Text('Ajouter un produit'),
          ),
        ],
      ),
    );
  }

  void _showImportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Importer des produits',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.upload_file, color: Colors.green),
                title: const Text('Depuis un fichier Excel/CSV'),
                subtitle: const Text('Importer des produits depuis un fichier .xlsx, .xls ou .csv'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ImportProductsScreen(),
                    ),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.blue),
                title: const Text('Format des fichiers supportés'),
                subtitle: const Text('Aide pour les formats Excel (.xlsx, .xls) et CSV'),
                onTap: () {
                  Navigator.pop(context);
                  _showExcelFormatInfo(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showExcelFormatInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Formats de fichiers supportés'),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Formats acceptés:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('• .xlsx - Excel moderne (recommandé)'),
                Text('• .csv - Fichier CSV (alternative)'),
                Text('• .xls - Excel ancien (conversion recommandée)'),
                SizedBox(height: 16),
                Text(
                  'Colonnes requises:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('• nom - Nom du produit (obligatoire)'),
                SizedBox(height: 16),
                Text(
                  'Colonnes optionnelles:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('• code barre - Code-barres du produit'),
                Text('• image - URL de l\'image du produit'),
                Text('• description - Description du produit'),
                Text('• prix_achat - Prix d\'achat'),
                Text('• prix_vente - Prix de vente'),
                Text('• stock - Quantité en stock'),
                Text('• unite - Unité de mesure'),
                Text('• categorie - Nom de la catégorie'),
                SizedBox(height: 16),
                Text(
                  'Problème avec .xls?',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                ),
                SizedBox(height: 4),
                Text(
                  'Si votre fichier .xls ne fonctionne pas, convertissez-le en .xlsx dans Excel ou sauvegardez-le en format CSV.',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Compris'),
            ),
          ],
        );
      },
    );
  }
}

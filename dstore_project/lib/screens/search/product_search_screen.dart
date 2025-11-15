import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/product_model.dart';
import '../../widgets/search/advanced_search_bar.dart';
import '../../widgets/products/product_card.dart';
import '../../main.dart';

class ProductSearchScreen extends StatefulWidget {
  const ProductSearchScreen({super.key});

  @override
  State<ProductSearchScreen> createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ProductModel> _searchResults = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);

    productProvider.loadProducts();
    categoryProvider.loadCategories();

    // Afficher tous les produits au début
    setState(() {
      _searchResults = productProvider.products;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.searchProducts ?? 'Rechercher des produits'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Barre de recherche avancée
          Consumer2<ProductProvider, CategoryProvider>(
            builder: (context, productProvider, categoryProvider, child) {
              return AdvancedSearchBar(
                controller: _searchController,
                hintText: l10n?.searchProducts ?? 'Rechercher des produits',
                onChanged: _onSearchChanged,
                onSubmitted: _onSearchSubmitted,
                onBarcodeScanned: _onBarcodeScanned,
                showCategoryFilter: true,
                categories:
                    categoryProvider.categories.map((c) => c.name).toList(),
                selectedCategory: _selectedCategory,
                onCategoryChanged: _onCategoryChanged,
              );
            },
          ),

          // Résultats de recherche
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? _buildEmptyState(l10n)
                    : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations? l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'Commencez à taper pour rechercher'
                : l10n?.noResults ?? 'Aucun résultat trouvé',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Recherche: "$_searchQuery"',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final product = _searchResults[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: () => _onProductTap(product),
            child: ProductCard(product: product),
          ),
        );
      },
    );
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _performSearch(query);
  }

  void _onSearchSubmitted(String query) {
    _performSearch(query);
  }

  void _onBarcodeScanned(String barcode) {
    _performSearch(barcode);
  }

  void _onCategoryChanged(String? category) {
    setState(() {
      _selectedCategory = category;
    });
    _performSearch(_searchQuery);
  }

  void _performSearch(String query) {
    setState(() {
      _isLoading = true;
    });

    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    List<ProductModel> results = [];

    if (query.isEmpty && _selectedCategory == null) {
      // Afficher tous les produits
      results = productProvider.products;
    } else {
      // Filtrer les produits
      results = productProvider.products.where((product) {
        bool matchesQuery = true;
        bool matchesCategory = true;

        // Filtrer par requête de recherche
        if (query.isNotEmpty) {
          final queryLower = query.toLowerCase();
          matchesQuery = product.name.toLowerCase().contains(queryLower) ||
              (product.description?.toLowerCase().contains(queryLower) ??
                  false) ||
              (product.barcode?.toLowerCase().contains(queryLower) ?? false);
        }

        // Filtrer par catégorie
        if (_selectedCategory != null) {
          matchesCategory = product.category?.name.toLowerCase() ==
              _selectedCategory!.toLowerCase();
        }

        return matchesQuery && matchesCategory;
      }).toList();
    }

    // Simuler un délai de recherche pour l'UX
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    });
  }

  void _onProductTap(ProductModel product) {
    // Afficher les détails du produit
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product.description?.isNotEmpty == true) ...[
              Text('Description: ${product.description}'),
              const SizedBox(height: 8),
            ],
            Text(
                'Prix de vente: ${AppUtils.formatCurrency(product.sellingPrice)}'),
            const SizedBox(height: 4),
            Text('Stock: ${product.stockQuantity} ${product.unit}'),
            if (product.barcode?.isNotEmpty == true) ...[
              const SizedBox(height: 4),
              Text('Code-barres: ${product.barcode}'),
            ],
            if (product.category?.name != null) ...[
              const SizedBox(height: 4),
              Text('Catégorie: ${product.category!.name}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Naviguer vers les détails du produit
            },
            child: const Text('Voir détails'),
          ),
        ],
      ),
    );
  }
}

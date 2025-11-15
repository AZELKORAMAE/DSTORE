import 'package:flutter/material.dart';
import '../../services/product_service.dart';
import '../../config/app_theme.dart';
import '../../models/product_model.dart';
import '../../l10n/app_localizations.dart';

class RealLowStockCard extends StatefulWidget {
  const RealLowStockCard({Key? key}) : super(key: key);

  @override
  State<RealLowStockCard> createState() => _RealLowStockCardState();
}

class _RealLowStockCardState extends State<RealLowStockCard> {
  final ProductService _productService = ProductService();
  List<ProductModel> _lowStockProducts = [];
  bool _isLoading = true;
  bool _isExpanded = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLowStockProducts();
  }

  Future<void> _loadLowStockProducts() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final allProducts = await _productService.getAllProducts();
      final products = allProducts.where((product) {
        final stock = product.stockQuantity ?? 0;
        final threshold = product.minStockThreshold ?? 10;
        return stock <= threshold && (product.isActive ?? true);
      }).toList();

      if (mounted) {
        setState(() {
          _lowStockProducts = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.inventory_2,
                      color: _lowStockProducts.isNotEmpty ? Colors.orange : Colors.grey,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.stockFaibleLabel,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_isLoading)
                            Text(
                              AppLocalizations.of(context)!.chargement,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            )
                          else if (_error != null)
                            Text(
                              AppLocalizations.of(context)!.erreurDeChargement,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.red[600],
                              ),
                            )
                          else if (_lowStockProducts.isNotEmpty)
                            Text(
                              '${_lowStockProducts.length} ${AppLocalizations.of(context)!.produitsEnStockFaibleLabel}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            )
                          else
                            Text(
                              AppLocalizations.of(context)!.stockOptimalPourTousLesProduits,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.green[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (_lowStockProducts.isNotEmpty && !_isLoading)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _lowStockProducts.length.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 20),
                      onPressed: _loadLowStockProducts,
                      color: Colors.grey[600],
                    ),
                    Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ),
            ),

            if (_isExpanded) ...[
              const SizedBox(height: 16),
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_error != null)
                Center(
                  child: Column(
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 48),
                      const SizedBox(height: 8),
                      Text(
                        'Erreur de chargement',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _error!,
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _loadLowStockProducts,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              else if (_lowStockProducts.isNotEmpty)
                _buildLowStockContent()
              else
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 64,
                        color: Colors.green[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Stock optimal',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.green[600],
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tous vos produits ont un stock suffisant',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLowStockContent() {
    // Grouper par statut simplifié
    final outOfStockProducts =
        _lowStockProducts.where((p) => (p.stockQuantity ?? 0) == 0).toList();
    final lowProducts =
        _lowStockProducts.where((p) => (p.stockQuantity ?? 0) > 0).toList();

    return Column(
      children: [
        // Résumé des alertes
        if (outOfStockProducts.isNotEmpty)
          _buildStockStatusCard(
            AppLocalizations.of(context)!.ruptureDeStock,
            outOfStockProducts.length,
            Colors.red,
            Icons.error,
          ),

        if (lowProducts.isNotEmpty) ...[
          if (outOfStockProducts.isNotEmpty) const SizedBox(height: 12),
          _buildStockStatusCard(
            AppLocalizations.of(context)!.stockFaible,
            lowProducts.length,
            Colors.orange,
            Icons.inventory_2,
          ),
        ],

        const SizedBox(height: 16),

        // Liste des produits (top 5)
        Text(
          AppLocalizations.of(context)!.produitsNecessitantAttention,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _lowStockProducts.take(5).length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final lowStockProduct = _lowStockProducts[index];
            return _buildProductTile(lowStockProduct);
          },
        ),

        if (_lowStockProducts.length > 5) ...[
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              // TODO: Navigation vers la gestion des stocks
            },
            child: Text(
              AppLocalizations.of(context)!.voirAutresProduits.replaceAll('{count}', '${_lowStockProducts.length - 5}'),
              style: TextStyle(
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],

        const SizedBox(height: 16),

        // Bouton d'action
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              // TODO: Navigation vers la gestion des stocks
            },
            icon: const Icon(Icons.inventory),
            label: Text(AppLocalizations.of(context)!.gererLesStocks),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStockStatusCard(
      String title, int count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Text(
                  '$count produit${count > 1 ? 's' : ''}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
          Text(
            count.toString(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductTile(ProductModel product) {
    final stock = product.stockQuantity ?? 0;
    final statusColor = stock == 0 ? Colors.red : Colors.orange;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Image du produit
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.inventory_2,
                        color: statusColor,
                      ),
                    ),
                  )
                : Icon(
                    Icons.inventory_2,
                    color: statusColor,
                  ),
          ),

          const SizedBox(width: 12),

          // Informations du produit
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${AppLocalizations.of(context)!.stock}: ${product.stockQuantity} ${product.unit}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${AppLocalizations.of(context)!.min}: ${product.minStockThreshold} ${product.unit}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Statut et recommandation
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  stock == 0 ? AppLocalizations.of(context)!.ruptureLabel : AppLocalizations.of(context)!.faibleLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${AppLocalizations.of(context)!.stock}: $stock',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

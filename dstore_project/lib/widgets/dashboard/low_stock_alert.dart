import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/product_provider.dart';
import '../../config/app_router.dart';
import '../../l10n/app_localizations.dart';

class LowStockAlert extends StatefulWidget {
  const LowStockAlert({super.key});

  @override
  State<LowStockAlert> createState() => _LowStockAlertState();
}

class _LowStockAlertState extends State<LowStockAlert> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final lowStockProducts = productProvider.lowStockProducts;

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
                          Icons.warning,
                          color: lowStockProducts.isNotEmpty ? Colors.orange : Colors.grey,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.alertesDeStock,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (lowStockProducts.isNotEmpty)
                                Text(
                                  () {
                                    final count = lowStockProducts.length;
                                    final attention = count > 1
                                        ? l10n.needAttentionPlural
                                        : l10n.needAttentionSingular;
                                    return '$count $attention';
                                  }(),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                )
                              else
                                Text(
                                  l10n.allProductsSufficientStock,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.green[600],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (lowStockProducts.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              lowStockProducts.length.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
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
                  if (lowStockProducts.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Tous vos produits ont un stock suffisant',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      children: [
                        ...lowStockProducts.take(5).map((product) =>
                          _buildLowStockItem(context, product)
                        ),
                        if (lowStockProducts.length > 5) ...[
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => context.goToProducts(),
                            child: Text(
                              l10n.seeOtherProducts.replaceAll('{count}', (lowStockProducts.length - 5).toString()),
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLowStockItem(BuildContext context, product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.orange.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: product.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.inventory_2,
                        color: Colors.orange,
                      ),
                    ),
                  )
                : Icon(
                    Icons.inventory_2,
                    color: Colors.orange,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Stock: ${product.stockQuantity} ${product.unit}',
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, size: 18),
            onPressed: () => context.goToEditProduct(product.id),
            color: Colors.orange,
          ),
        ],
      ),
    );
  }
}

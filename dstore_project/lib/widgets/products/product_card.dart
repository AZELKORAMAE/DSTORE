import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';

import '../../models/product_model.dart';
import '../../config/app_router.dart';
import '../../main.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onSelectionToggle;

  const ProductCard({
    super.key,
    required this.product,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onSelectionToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Stack(
        children: [
          InkWell(
            onTap: isSelectionMode
                ? onSelectionToggle
                : () => context.goToProductDetail(product.id),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: isSelectionMode && isSelected
                    ? Border.all(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      )
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image du produit
                  Expanded(
                    flex: 3,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(12)),
                        color: Colors.grey[100],
                      ),
                      child: product.imageUrl != null
                          ? ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12)),
                              child: _buildProductImage(product.imageUrl!),
                            )
                          : Icon(
                              Icons.inventory_2,
                              size: 40,
                              color: Colors.grey[400],
                            ),
                    ),
                  ),

                  // Informations du produit
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nom du produit
                          Text(
                            product.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 4),

                          // Catégorie
                          if (product.category != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: product.category!.colorValue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                product.category!.name,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: product.category!.colorValue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                          const Spacer(),

                          // Prix et stock
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppUtils.formatCurrency(product.sellingPrice),
                                style:
                                    Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                              ),
                              _buildStockIndicator(context),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Case à cocher pour le mode sélection
          if (isSelectionMode)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Checkbox(
                  value: isSelected,
                  onChanged: (_) => onSelectionToggle?.call(),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStockIndicator(BuildContext context) {
    Color color;
    IconData icon;

    if (product.isOutOfStock) {
      color = Colors.red;
      icon = Icons.error;
    } else if (product.isLowStock) {
      color = Colors.orange;
      icon = Icons.warning;
    } else {
      color = Colors.green;
      icon = Icons.check_circle;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            '${product.stockQuantity}',
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(String imageUrl) {
    // Vérifier si c'est une image locale ou réseau
    if (imageUrl.startsWith('http') || imageUrl.startsWith('https')) {
      // Image réseau
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[200],
          child: Icon(
            Icons.inventory_2,
            size: 40,
            color: Colors.grey[400],
          ),
        ),
      );
    } else if (imageUrl.startsWith('data:image')) {
      // Image base64 (web)
      return Image.memory(
        Uri.parse(imageUrl).data!.contentAsBytes(),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[200],
          child: Icon(
            Icons.inventory_2,
            size: 40,
            color: Colors.grey[400],
          ),
        ),
      );
    } else {
      // Image locale (fichier)
      return Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[200],
          child: Icon(
            Icons.inventory_2,
            size: 40,
            color: Colors.grey[400],
          ),
        ),
      );
    }
  }
}

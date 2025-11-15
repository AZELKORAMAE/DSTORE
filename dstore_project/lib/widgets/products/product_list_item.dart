import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';

import '../../models/product_model.dart';
import '../../config/app_router.dart';
import '../../main.dart';
import '../../l10n/app_localizations.dart';

class ProductListItem extends StatelessWidget {
  final ProductModel product;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onSelectionToggle;

  const ProductListItem({
    super.key,
    required this.product,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onSelectionToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
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
        child: ListTile(
          isThreeLine: true,
          contentPadding: const EdgeInsets.all(12),
          onTap: isSelectionMode
              ? onSelectionToggle
              : () => context.goToProductDetail(product.id),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[100],
          ),
          child: product.imageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildProductImage(product.imageUrl!),
                )
              : Icon(
                  Icons.inventory_2,
                  color: Colors.grey[400],
                ),
        ),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product.category != null) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'Stock: ${product.stockQuantity} ${product.unit}',
                  style: TextStyle(
                    color: _getStockColor(),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                if (product.barcode != null)
                  Text(
                    'Code: ${product.barcode}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: isSelectionMode
            ? Checkbox(
                value: isSelected,
                onChanged: (_) => onSelectionToggle?.call(),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppUtils.formatCurrency(product.sellingPrice),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                  const SizedBox(height: 4),
                  _buildStockIndicator(context),
                ],
              ),
        ),
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
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Icon(
          Icons.inventory_2,
          color: Colors.grey[400],
        ),
      );
    } else if (imageUrl.startsWith('data:image')) {
      // Image base64 (web)
      return Image.memory(
        Uri.parse(imageUrl).data!.contentAsBytes(),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.inventory_2,
          color: Colors.grey[400],
        ),
      );
    } else {
      // Image locale (fichier)
      return Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.inventory_2,
          color: Colors.grey[400],
        ),
      );
    }
  }

  Color _getStockColor() {
    if (product.isOutOfStock) {
      return Colors.red;
    } else if (product.isLowStock) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  Widget _buildStockIndicator(BuildContext context) {
    Color color = _getStockColor();
    IconData icon;
    String text;

    if (product.isOutOfStock) {
      icon = Icons.error;
      text = AppLocalizations.of(context)!.rupture;
    } else if (product.isLowStock) {
      icon = Icons.warning;
      text = AppLocalizations.of(context)!.faible;
    } else {
      icon = Icons.check_circle;
      text = AppLocalizations.of(context)!.okStatus;
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
            text,
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
}

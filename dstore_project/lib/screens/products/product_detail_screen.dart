import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'dart:io';

import '../../providers/product_provider.dart';
import '../../models/product_model.dart';
import '../../config/app_router.dart';
import '../../main.dart';
import '../../l10n/app_localizations.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  ProductModel? _product;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    setState(() => _isLoading = true);

    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    final product = await productProvider.getProductById(widget.productId);

    if (mounted) {
      setState(() {
        _product = product;
        _isLoading = false;
      });
    }
  }

  Future<void> _showStockAdjustmentDialog() async {
    if (_product == null) return;

    final l10n = AppLocalizations.of(context);
    final TextEditingController quantityController = TextEditingController();
    final TextEditingController reasonController = TextEditingController();
    String adjustmentType = 'add';

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n?.stockAdjustment ?? 'Ajuster le stock'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Type d'ajustement
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(
                    value: 'add',
                    label: Text(l10n?.addStock ?? 'Ajouter'),
                    icon: const Icon(Icons.add),
                  ),
                  ButtonSegment(
                    value: 'remove',
                    label: Text(l10n?.removeStock ?? 'Retirer'),
                    icon: const Icon(Icons.remove),
                  ),
                  ButtonSegment(
                    value: 'set',
                    label: Text(l10n?.setStock ?? 'Définir'),
                    icon: const Icon(Icons.edit),
                  ),
                ],
                selected: {adjustmentType},
                onSelectionChanged: (Set<String> selection) {
                  setDialogState(() {
                    adjustmentType = selection.first;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Quantité (autorise les nombres décimaux)
              TextField(
                controller: quantityController,
                decoration: InputDecoration(
                  labelText: adjustmentType == 'set'
                      ? l10n?.newQuantity ?? 'Nouvelle quantité'
                      : l10n?.quantity ?? 'Quantité',
                  hintText: '0.0',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
              ),
              const SizedBox(height: 16),

              // Raison
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  labelText: l10n?.reasonHint ?? 'Raison (optionnel)',
                  hintText: 'Ex: Inventaire, Retour client...',
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n?.cancel ?? 'Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                // Convertir la chaîne en double en remplaçant les virgules par des points
                final String raw = quantityController.text.trim().replaceAll(',', '.');
                final double? qty = double.tryParse(raw);
                if (qty != null && qty > 0) {
                  Navigator.of(context).pop({
                    'type': adjustmentType,
                    'quantity': qty,
                    'reason': reasonController.text.trim(),
                  });
                }
              },
              child: Text(l10n?.confirm ?? 'Confirmer'),
            ),
          ],
        ),
      ),
    );

    if (result != null && mounted) {
      await _adjustStock(result);
    }
  }

  Future<void> _adjustStock(Map<String, dynamic> adjustment) async {
    if (_product == null) return;

    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    final type = adjustment['type'] as String;
    final quantity = (adjustment['quantity'] as num).toDouble();
    final reason = adjustment['reason'] as String;

    bool success = false;

    switch (type) {
      case 'add':
        success = await productProvider.adjustStock(
          _product!.id,
          quantity,
          reason: reason.isNotEmpty ? reason : 'Ajout manuel',
        );
        break;
      case 'remove':
        success = await productProvider.adjustStock(
          _product!.id,
          -quantity,
          reason: reason.isNotEmpty ? reason : 'Retrait manuel',
        );
        break;
      case 'set':
        success = await productProvider.updateStock(
          _product!.id,
          quantity,
          reason: reason.isNotEmpty ? reason : 'Ajustement manuel',
        );
        break;
    }

    if (success && mounted) {
      AppUtils.showSnackBar(context, 'Stock mis à jour avec succès');
      await _loadProduct(); // Recharger le produit
    } else if (mounted) {
      AppUtils.showSnackBar(
        context,
        productProvider.errorMessage ?? 'Erreur lors de la mise à jour',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_product?.name ?? 'Détails du produit'),
        actions: [
          if (_product != null) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => context.goToEditProduct(_product!.id),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'adjust_stock':
                    _showStockAdjustmentDialog();
                    break;
                  case 'duplicate':
                    // TODO: Implémenter la duplication
                    break;
                  case 'delete':
                    _showDeleteConfirmation();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'adjust_stock',
                  child: ListTile(
                    leading: Icon(Icons.inventory),
                    title: Text('Ajuster le stock'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'duplicate',
                  child: ListTile(
                    leading: Icon(Icons.copy),
                    title: Text('Dupliquer'),
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title:
                        Text('Supprimer', style: TextStyle(color: Colors.red)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _product == null
              ? _buildErrorState()
              : _buildProductDetails(),
    );
  }

  Widget _buildErrorState() {
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
            'Produit non trouvé',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.pop(),
            child: const Text('Retour'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image et informations principales
          _buildHeaderSection(),
          const SizedBox(height: 24),

          // Statistiques rapides
          _buildStatsSection(),
          const SizedBox(height: 24),

          // Informations détaillées
          _buildDetailsSection(),
          const SizedBox(height: 24),

          // Actions rapides
          _buildActionsSection(),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Image du produit
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[100],
              ),
              child: _product!.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _buildProductImage(_product!.imageUrl!),
                    )
                  : Icon(
                      Icons.inventory_2,
                      size: 40,
                      color: Colors.grey[400],
                    ),
            ),
            const SizedBox(width: 16),

            // Informations principales
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _product!.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),

                  if (_product!.category != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _product!.category!.colorValue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _product!.category!.name,
                        style: TextStyle(
                          color: _product!.category!.colorValue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  const SizedBox(height: 8),

                  // Prix
                  Text(
                    AppUtils.formatCurrency(_product!.sellingPrice),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),

                  // Statut du stock
                  const SizedBox(height: 8),
                  _buildStockStatus(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockStatus() {
    Color color;
    IconData icon;
    String text;

    if (_product!.isOutOfStock) {
      color = Colors.red;
      icon = Icons.error;
      text = AppLocalizations.of(context)!.ruptureDeStock;
    } else if (_product!.isLowStock) {
      color = Colors.orange;
      icon = Icons.warning;
      text = AppLocalizations.of(context)!.stockFaible;
    } else {
      color = Colors.green;
      icon = Icons.check_circle;
      text = AppLocalizations.of(context)!.stockSuffisant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            AppLocalizations.of(context)!.stockActuel,
            '${_product!.stockQuantity} ${_product!.unit}',
            Icons.inventory,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            AppLocalizations.of(context)!.valeurStock,
            AppUtils.formatCurrency(_product!.totalStockValue),
            Icons.attach_money,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            AppLocalizations.of(context)!.marge,
            '${_product!.profitMargin.toStringAsFixed(1)}%',
            Icons.trending_up,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection() {
    final l10n = AppLocalizations.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.productDetails ?? 'Détails',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
                l10n?.description ?? 'Description', _product!.description ?? l10n?.noDescription ?? 'Aucune description'),
            _buildDetailRow(l10n?.barcode ?? 'Code-barres', _product!.barcode ?? l10n?.notDefined ?? 'Non défini'),
            _buildDetailRow(l10n?.sku ?? 'SKU', _product!.sku ?? l10n?.notDefined ?? 'Non défini'),
            _buildDetailRow(l10n?.purchasePrice ?? 'Prix d\'achat',
                AppUtils.formatCurrency(_product!.purchasePrice)),
            _buildDetailRow(l10n?.salePrice ?? 'Prix de vente',
                AppUtils.formatCurrency(_product!.sellingPrice)),
            _buildDetailRow(l10n?.profitPerUnit ?? 'Profit par unité',
                AppUtils.formatCurrency(_product!.profitPerUnit)),
            _buildDetailRow(l10n?.threshold ?? 'Seuil d\'alerte',
                '${_product!.minStockThreshold} ${_product!.unit}'),
            _buildDetailRow(l10n?.productStatus ?? 'Statut', _product!.isActive ? l10n?.active ?? 'Actif' : l10n?.inactive ?? 'Inactif'),
            _buildDetailRow(
                l10n?.createdOn ?? 'Créé le', AppUtils.formatDate(_product!.createdAt)),
            _buildDetailRow(
                l10n?.modifiedOn ?? 'Modifié le', AppUtils.formatDate(_product!.updatedAt)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection() {
    final l10n = AppLocalizations.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.quickActions ?? 'Actions rapides',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showStockAdjustmentDialog,
                    icon: const Icon(Icons.inventory),
                    label: Text(l10n?.adjustStock ?? 'Ajuster stock'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.goToEditProduct(_product!.id),
                    icon: const Icon(Icons.edit),
                    label: const Text('Modifier'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation() async {
    final confirmed = await AppUtils.showConfirmDialog(
      context,
      'Supprimer le produit',
      'Êtes-vous sûr de vouloir supprimer "${_product!.name}" ?\n\nCette action est irréversible.',
    );

    if (confirmed && mounted) {
      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);
      final success = await productProvider.deleteProduct(_product!.id);

      if (success && mounted) {
        AppUtils.showSnackBar(context, 'Produit supprimé avec succès');
        context.pop();
      } else if (mounted) {
        AppUtils.showSnackBar(
          context,
          productProvider.errorMessage ?? 'Erreur lors de la suppression',
          isError: true,
        );
      }
    }
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
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => Icon(
          Icons.inventory_2,
          size: 40,
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
          size: 40,
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
          size: 40,
          color: Colors.grey[400],
        ),
      );
    }
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/category_model.dart';
import '../../config/app_router.dart';
import '../../screens/categories/category_detail_management_screen.dart';
import '../../providers/category_provider.dart';

class CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final int? productCount; // Nombre de produits dans cette catégorie

  const CategoryCard({
    super.key,
    required this.category,
    this.productCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => context.goToProductsByCategory(category.id, category.name),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12), // Réduit de 16 à 12
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                category.colorValue.withOpacity(0.1),
                category.colorValue.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image de la catégorie ou icône par défaut
              Expanded(
                flex:
                    10, // Augmenté de 8 à 10 pour doubler la taille de l'image
                child:
                    ((category.imageUrl ?? '').isNotEmpty)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: double.infinity,
                              height: double
                                  .infinity, // Utilise tout l'espace disponible
                              child: _buildCategoryImage(),
                            ),
                          )
                        : _buildDefaultIcon(),
              ),

              const SizedBox(height: 8), // Réduit de 12 à 8

              // En-tête avec couleur et statut
              Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: category.colorValue,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Spacer(),
                  if (!category.isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Inactive',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  // Menu contextuel
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      size: 18,
                      color: Colors.grey[600],
                    ),
                    onSelected: (value) => _handleMenuAction(context, value),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Modifier'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Supprimer', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 6), // Réduit de 8 à 6

              // Nom de la catégorie et nombre de produits
              Row(
                children: [
                  Expanded(
                    child: Text(
                      category.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: category.colorValue,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (productCount != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: category.colorValue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: category.colorValue.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '$productCount',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: category.colorValue,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 4), // Réduit de 8 à 4

              // Description
              if ((category.description ?? '').isNotEmpty)
                Text(
                  category.description!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                  maxLines: 1, // Réduit de 2 à 1
                  overflow: TextOverflow.ellipsis,
                ),

              const Spacer(),

              // Statistiques
              Row(
                children: [
                  Icon(
                    Icons.inventory_2,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${category.productCount ?? 0} produits',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.edit,
                    size: 16,
                    color: category.colorValue,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryImage() {
    final imageUrl = category.imageUrl!;

    // Vérifier si c'est une image locale (chemin de fichier) ou réseau (URL)
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      // Image réseau
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildDefaultIcon(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: double.infinity,
            height: double.infinity, // Utilise tout l'espace disponible
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
                color: category.colorValue,
              ),
            ),
          );
        },
      );
    } else {
      // Image locale
      final file = File(imageUrl);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildDefaultIcon(),
        );
      } else {
        return _buildDefaultIcon();
      }
    }
  }

  Widget _buildDefaultIcon() {
    return Container(
      width: double.infinity,
      height: double.infinity, // Utilise tout l'espace disponible
      decoration: BoxDecoration(
        color: category.colorValue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: category.colorValue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category,
            size:
                70, // Augmenté de 56 à 70 pour correspondre à la nouvelle taille d'image
            color: category.colorValue,
          ),
          const SizedBox(height: 10), // Augmenté de 8 à 10
          Text(
            'Aucune image',
            style: TextStyle(
              fontSize: 13, // Augmenté de 12 à 13
              color: category.colorValue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'edit':
        context.go('/categories/edit/${category.id}');
        break;
      case 'delete':
        _showDeleteConfirmation(context);
        break;
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Êtes-vous sûr de vouloir supprimer la catégorie "${category.name}" ?'),
              const SizedBox(height: 8),
              if (productCount != null && productCount! > 0)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Cette catégorie contient $productCount produit(s). Vous devez d\'abord supprimer ou déplacer ces produits.',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: (productCount != null && productCount! > 0)
                  ? null
                  : () => _deleteCategory(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  void _deleteCategory(BuildContext context) async {
    Navigator.of(context).pop(); // Fermer le dialog

    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);

    // Afficher un indicateur de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final success = await categoryProvider.deleteCategory(category.id!);

      // Fermer l'indicateur de chargement
      if (context.mounted) Navigator.of(context).pop();

      if (success) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Catégorie "${category.name}" supprimée avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(categoryProvider.errorMessage ?? 'Erreur lors de la suppression'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Fermer l'indicateur de chargement
      if (context.mounted) Navigator.of(context).pop();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

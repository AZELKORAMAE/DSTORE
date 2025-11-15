import 'dart:io';
import '../models/category_model.dart';
import 'local_storage_service.dart';
import 'local_image_service.dart';

class CategoryService {
  final LocalStorageService _localStorage = LocalStorageService.instance;

  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final categoriesData = _localStorage.getCategories();
      return categoriesData.map((json) {
        final Map<String, dynamic> categoryMap =
            Map<String, dynamic>.from(json);
        return CategoryModel.fromJson(categoryMap);
      }).toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des catégories: $e');
    }
  }

  Future<CategoryModel?> getCategoryById(String id) async {
    try {
      final categoriesData = _localStorage.getCategories();
      final categoryData = categoriesData.firstWhere(
        (category) => category['id'] == id,
        orElse: () => <String, dynamic>{},
      );

      if (categoryData.isEmpty) return null;
      return CategoryModel.fromJson(categoryData);
    } catch (e) {
      throw Exception('Erreur lors du chargement de la catégorie: $e');
    }
  }

  Future<CategoryModel> createCategory(CategoryModel category) async {
    try {
      final categoryData = category.toJson();
      categoryData['id'] = DateTime.now().millisecondsSinceEpoch.toString();
      categoryData['created_at'] = DateTime.now().toIso8601String();
      categoryData['updated_at'] = DateTime.now().toIso8601String();

      await _localStorage.saveCategory(categoryData);
      return CategoryModel.fromJson(categoryData);
    } catch (e) {
      throw Exception('Erreur lors de la création de la catégorie: $e');
    }
  }

  Future<CategoryModel> updateCategory(CategoryModel category) async {
    try {
      final categoryData = category.toJson();
      categoryData['updated_at'] = DateTime.now().toIso8601String();

      await _localStorage.saveCategory(categoryData);
      return CategoryModel.fromJson(categoryData);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la catégorie: $e');
    }
  }



  Future<List<CategoryModel>> searchCategories(String query) async {
    try {
      final categoriesData = _localStorage.getCategories();
      final filteredCategories = categoriesData.where((category) {
        final name = category['name']?.toString().toLowerCase() ?? '';
        final description =
            category['description']?.toString().toLowerCase() ?? '';
        final searchQuery = query.toLowerCase();

        return name.contains(searchQuery) || description.contains(searchQuery);
      }).toList();

      return filteredCategories
          .map((json) => CategoryModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la recherche: $e');
    }
  }

  Future<CategoryModel?> getCategoryByName(String name) async {
    try {
      final categoriesData = _localStorage.getCategories();
      final categoryData = categoriesData.firstWhere(
        (category) =>
            category['name']?.toString().toLowerCase() == name.toLowerCase(),
        orElse: () => <String, dynamic>{},
      );

      if (categoryData.isEmpty) return null;
      return CategoryModel.fromJson(categoryData);
    } catch (e) {
      return null;
    }
  }

  Future<List<CategoryModel>> getRecentCategories({int limit = 10}) async {
    try {
      final categoriesData = _localStorage.getCategories();

      // Trier par date de création (plus récent en premier)
      categoriesData.sort((a, b) {
        final dateA =
            DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(1970);
        final dateB =
            DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(1970);
        return dateB.compareTo(dateA);
      });

      final recentCategories = categoriesData.take(limit).toList();
      return recentCategories
          .map((json) => CategoryModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des catégories récentes: $e');
    }
  }

  Future<int> getCategoriesCount() async {
    try {
      final categoriesData = _localStorage.getCategories();
      return categoriesData.length;
    } catch (e) {
      return 0;
    }
  }

  Future<List<CategoryModel>> getActiveCategories() async {
    try {
      final categoriesData = _localStorage.getCategories();
      final activeCategories = categoriesData.where((category) {
        return category['is_active'] == true || category['is_active'] == null;
      }).toList();

      return activeCategories
          .map((json) => CategoryModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des catégories actives: $e');
    }
  }

  Future<void> toggleCategoryStatus(String categoryId) async {
    try {
      final category = await getCategoryById(categoryId);
      if (category != null) {
        final categoryData = category.toJson();
        categoryData['is_active'] = !(category.isActive ?? true);
        categoryData['updated_at'] = DateTime.now().toIso8601String();
        await _localStorage.saveCategory(categoryData);
      }
    } catch (e) {
      throw Exception('Erreur lors du changement de statut: $e');
    }
  }

  Future<bool> deleteCategory(String categoryId) async {
    try {
      // Vérifier si la catégorie a des produits associés
      final productCount = await getCategoryProductsCount(categoryId);
      if (productCount > 0) {
        throw Exception('Impossible de supprimer une catégorie qui contient des produits ($productCount produits)');
      }

      // Supprimer l'image si elle existe
      final category = await getCategoryById(categoryId);
      if (category?.imageUrl != null && category!.imageUrl!.isNotEmpty) {
        try {
          final file = File(category.imageUrl!);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          print('Erreur lors de la suppression de l\'image: $e');
          // Continuer même si la suppression de l'image échoue
        }
      }

      // Supprimer la catégorie du stockage local
      await _localStorage.deleteCategory(categoryId);
      return true;
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la catégorie: $e');
    }
  }

  Future<int> getCategoryProductsCount(String categoryId) async {
    try {
      final productsData = _localStorage.getProducts();
      final categoryProducts = productsData.where((product) {
        return product['category_id'] == categoryId;
      }).toList();

      return categoryProducts.length;
    } catch (e) {
      return 0;
    }
  }

  Future<bool> isCategoryNameExists(String name, {String? excludeId}) async {
    try {
      final category = await getCategoryByName(name);
      if (category == null) return false;
      if (excludeId != null && category.id == excludeId) return false;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> canDeleteCategory(String categoryId) async {
    try {
      final productsCount = await getCategoryProductsCount(categoryId);
      return productsCount == 0;
    } catch (e) {
      return false;
    }
  }

  Future<CategoryModel> createCategoryWithImage({
    required CategoryModel category,
    File? imageFile,
  }) async {
    try {
      // Créer d'abord la catégorie pour obtenir un ID
      final createdCategory = await createCategory(category);

      // Si une image est fournie, la sauvegarder
      if (imageFile != null) {
        final imagePath = await LocalImageService.saveCategoryImage(
            imageFile, createdCategory.id!);
        if (imagePath != null) {
          // Mettre à jour la catégorie avec le chemin de l'image
          final categoryWithImage =
              createdCategory.copyWith(imageUrl: imagePath);
          return await updateCategory(categoryWithImage);
        }
      }

      return createdCategory;
    } catch (e) {
      throw Exception(
          'Erreur lors de la création de la catégorie avec image: $e');
    }
  }

  Future<CategoryModel> updateCategoryWithImage({
    required CategoryModel category,
    File? newImageFile,
    bool removeCurrentImage = false,
  }) async {
    try {
      // Pour l'instant, on ignore l'image et on met à jour juste la catégorie
      return await updateCategory(category);
    } catch (e) {
      throw Exception(
          'Erreur lors de la mise à jour de la catégorie avec image: $e');
    }
  }

  Future<String?> uploadCategoryImage(String categoryId, File imageFile) async {
    try {
      print('📸 Début sauvegarde image catégorie: $categoryId');

      // Sauvegarder l'image localement
      final imagePath =
          await LocalImageService.saveCategoryImage(imageFile, categoryId);

      if (imagePath != null) {
        print('✅ Image sauvegardée: $imagePath');

        // Mettre à jour la catégorie avec le chemin de l'image
        final category = await getCategoryById(categoryId);
        if (category != null) {
          final updatedCategory = category.copyWith(imageUrl: imagePath);
          await updateCategory(updatedCategory);
          print('✅ Catégorie mise à jour avec l\'image');
        }

        return imagePath;
      } else {
        print('❌ Échec de la sauvegarde de l\'image');
        return null;
      }
    } catch (e) {
      print('❌ Erreur lors de l\'upload de l\'image: $e');
      return null;
    }
  }

  Future<void> deleteCategoryImage(String categoryId) async {
    try {
      // Pour l'instant, ne rien faire
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'image: $e');
    }
  }

  Future<List<CategoryModel>> getCategoriesWithProductCount() async {
    try {
      final categories = await getAllCategories();
      final categoriesWithCount = <CategoryModel>[];

      for (final category in categories) {
        final productsCount = await getCategoryProductsCount(category.id!);
        // On peut ajouter le count comme propriété personnalisée si nécessaire
        categoriesWithCount.add(category);
      }

      return categoriesWithCount;
    } catch (e) {
      throw Exception(
          'Erreur lors du chargement des catégories avec comptage: $e');
    }
  }

  Future<Map<String, int>> getCategoriesStats() async {
    try {
      final categoriesData = _localStorage.getCategories();
      final productsData = _localStorage.getProducts();

      final stats = <String, int>{};

      for (final categoryData in categoriesData) {
        final categoryId = categoryData['id'];
        final categoryName = categoryData['name'] ?? 'Sans nom';

        final productsCount = productsData.where((product) {
          return product['category_id'] == categoryId;
        }).length;

        stats[categoryName] = productsCount;
      }

      return stats;
    } catch (e) {
      return {};
    }
  }

  Future<List<CategoryModel>> getTopCategories({int limit = 5}) async {
    try {
      final categories = await getAllCategories();
      final categoriesWithCount = <Map<String, dynamic>>[];

      for (final category in categories) {
        final productsCount = await getCategoryProductsCount(category.id!);
        categoriesWithCount.add({
          'category': category,
          'products_count': productsCount,
        });
      }

      // Trier par nombre de produits (décroissant)
      categoriesWithCount.sort((a, b) =>
          (b['products_count'] as int).compareTo(a['products_count'] as int));

      return categoriesWithCount
          .take(limit)
          .map((item) => item['category'] as CategoryModel)
          .toList();
    } catch (e) {
      throw Exception(
          'Erreur lors du chargement des meilleures catégories: $e');
    }
  }
}

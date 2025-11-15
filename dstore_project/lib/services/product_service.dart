import 'dart:io';
import '../models/product_model.dart';
import 'local_storage_service.dart';
import 'local_image_service.dart';

class ProductService {
  final LocalStorageService _localStorage = LocalStorageService.instance;

  Future<List<ProductModel>> getAllProducts() async {
    try {
      final productsData = _localStorage.getProducts();
      return productsData.map((json) {
        // Convertir explicitement en Map<String, dynamic>
        final Map<String, dynamic> productMap = Map<String, dynamic>.from(json);
        return ProductModel.fromJson(productMap);
      }).toList();
    } catch (e) {
      print('Erreur chargement produits: $e');
      throw Exception('Erreur lors du chargement des produits: $e');
    }
  }

  Future<ProductModel?> getProductById(String id) async {
    try {
      final productsData = _localStorage.getProducts();
      final productData = productsData.firstWhere(
        (product) => product['id'] == id,
        orElse: () => <String, dynamic>{},
      );

      if (productData.isEmpty) return null;
      final Map<String, dynamic> productMap =
          Map<String, dynamic>.from(productData);
      return ProductModel.fromJson(productMap);
    } catch (e) {
      throw Exception('Erreur lors du chargement du produit: $e');
    }
  }

  Future<ProductModel?> getProductByBarcode(String barcode) async {
    try {
      final productsData = _localStorage.getProducts();
      final productData = productsData.firstWhere(
        (product) => product['barcode'] == barcode,
        orElse: () => <String, dynamic>{},
      );

      if (productData.isEmpty) return null;
      final Map<String, dynamic> productMap =
          Map<String, dynamic>.from(productData);
      return ProductModel.fromJson(productMap);
    } catch (e) {
      return null; // Produit non trouvé
    }
  }

  Future<ProductModel> createProduct(ProductModel product) async {
    try {
      final productData = product.toJson();
      productData['id'] = DateTime.now().millisecondsSinceEpoch.toString();
      productData['created_at'] = DateTime.now().toIso8601String();
      productData['updated_at'] = DateTime.now().toIso8601String();

      await _localStorage.saveProduct(productData);
      return ProductModel.fromJson(productData);
    } catch (e) {
      throw Exception('Erreur lors de la création du produit: $e');
    }
  }

  Future<ProductModel> updateProduct(ProductModel product) async {
    try {
      final productData = product.toJson();
      productData['updated_at'] = DateTime.now().toIso8601String();

      await _localStorage.saveProduct(productData);
      return ProductModel.fromJson(productData);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du produit: $e');
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _localStorage.deleteProduct(id);
    } catch (e) {
      throw Exception('Erreur lors de la suppression du produit: $e');
    }
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final productsData = _localStorage.getProducts();
      final filteredProducts = productsData.where((product) {
        final name = product['name']?.toString().toLowerCase() ?? '';
        final barcode = product['barcode']?.toString().toLowerCase() ?? '';
        final description =
            product['description']?.toString().toLowerCase() ?? '';
        final searchQuery = query.toLowerCase();

        return name.contains(searchQuery) ||
            barcode.contains(searchQuery) ||
            description.contains(searchQuery);
      }).toList();

      return filteredProducts.map((json) {
        final Map<String, dynamic> productMap = Map<String, dynamic>.from(json);
        return ProductModel.fromJson(productMap);
      }).toList();
    } catch (e) {
      throw Exception('Erreur lors de la recherche: $e');
    }
  }

  Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    try {
      final productsData = _localStorage.getProducts();
      final filteredProducts = productsData.where((product) {
        return product['category_id'] == categoryId;
      }).toList();

      return filteredProducts.map((json) {
        final Map<String, dynamic> productMap = Map<String, dynamic>.from(json);
        return ProductModel.fromJson(productMap);
      }).toList();
    } catch (e) {
      throw Exception(
          'Erreur lors du chargement des produits par catégorie: $e');
    }
  }

  Future<List<ProductModel>> getLowStockProducts({int threshold = 10}) async {
    try {
      final productsData = _localStorage.getProducts();
      final lowStockProducts = productsData.where((product) {
        final stock = product['stock_quantity'] ?? 0;
        return stock <= threshold;
      }).toList();

      return lowStockProducts.map((json) {
        final Map<String, dynamic> productMap = Map<String, dynamic>.from(json);
        return ProductModel.fromJson(productMap);
      }).toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des produits en rupture: $e');
    }
  }

  Future<void> updateProductStock(String productId, double newStock) async {
    try {
      final product = await getProductById(productId);
      if (product != null) {
        final productData = product.toJson();
        productData['stock_quantity'] = newStock;
        productData['updated_at'] = DateTime.now().toIso8601String();
        await _localStorage.saveProduct(productData);
        print('✅ Stock mis à jour: ${product.name} → $newStock unités');
      }
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du stock: $e');
    }
  }

  Future<void> updateStock(String productId, double newQuantity,
      {String? reason}) async {
    try {
      await updateProductStock(productId, newQuantity);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du stock: $e');
    }
  }

  Future<ProductModel> createProductWithImage({
    required ProductModel product,
    File? imageFile,
  }) async {
    try {
      // Créer d'abord le produit pour obtenir un ID
      final createdProduct = await createProduct(product);

      // Si une image est fournie, la sauvegarder
      if (imageFile != null) {
        final imagePath = await LocalImageService.saveProductImage(
            imageFile, createdProduct.id!);
        if (imagePath != null) {
          // Mettre à jour le produit avec le chemin de l'image
          final productWithImage = createdProduct.copyWith(imageUrl: imagePath);
          return await updateProduct(productWithImage);
        }
      }

      return createdProduct;
    } catch (e) {
      throw Exception('Erreur lors de la création du produit avec image: $e');
    }
  }

  Future<ProductModel> updateProductWithImage({
    required ProductModel product,
    File? newImageFile,
    bool removeCurrentImage = false,
  }) async {
    try {
      String? newImagePath = product.imageUrl;

      // Supprimer l'ancienne image si demandé
      if (removeCurrentImage && product.imageUrl != null) {
        await LocalImageService.deleteProductImage(product.imageUrl!);
        newImagePath = null;
      }

      // Ajouter la nouvelle image si fournie
      if (newImageFile != null) {
        // Supprimer l'ancienne image d'abord
        if (product.imageUrl != null) {
          await LocalImageService.deleteProductImage(product.imageUrl!);
        }

        newImagePath =
            await LocalImageService.saveProductImage(newImageFile, product.id!);
      }

      // Mettre à jour le produit avec le nouveau chemin d'image
      final productWithImage = product.copyWith(imageUrl: newImagePath);
      return await updateProduct(productWithImage);
    } catch (e) {
      throw Exception(
          'Erreur lors de la mise à jour du produit avec image: $e');
    }
  }

  Future<String?> uploadProductImage(String productId, File imageFile) async {
    try {
      return await LocalImageService.saveProductImage(imageFile, productId);
    } catch (e) {
      print('Erreur lors de l\'upload de l\'image: $e');
      return null;
    }
  }

  Future<void> deleteProductWithImage(String id) async {
    try {
      // Récupérer le produit pour obtenir le chemin de l'image
      final product = await getProductById(id);

      // Supprimer l'image si elle existe
      if (product?.imageUrl != null) {
        await LocalImageService.deleteProductImage(product!.imageUrl!);
      }

      // Supprimer le produit
      await deleteProduct(id);
    } catch (e) {
      throw Exception(
          'Erreur lors de la suppression du produit avec image: $e');
    }
  }
}

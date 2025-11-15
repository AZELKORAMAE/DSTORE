import 'category_model.dart';

class ProductModel {
  final String id;
  final String userId;
  final String? categoryId;
  final String name;
  final String? description;
  final String? barcode;
  final String? sku;
  final double purchasePrice;
  final double sellingPrice;
  final double stockQuantity;
  final int minStockThreshold;
  final String unit;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relations
  final CategoryModel? category;

  ProductModel({
    required this.id,
    required this.userId,
    this.categoryId,
    required this.name,
    this.description,
    this.barcode,
    this.sku,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.stockQuantity,
    required this.minStockThreshold,
    required this.unit,
    this.imageUrl,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.category,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      categoryId: json['category_id']?.toString(),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      barcode: json['barcode']?.toString(),
      sku: json['sku']?.toString(),
      purchasePrice: (json['purchase_price'] as num?)?.toDouble() ?? 0.0,
      sellingPrice: (json['selling_price'] as num?)?.toDouble() ?? 0.0,
      stockQuantity: (json['stock_quantity'] as num?)?.toDouble() ?? 0.0,
      minStockThreshold: (json['min_stock_threshold'] as num?)?.toInt() ?? 10,
      unit: json['unit']?.toString() ?? 'pièce',
      imageUrl: json['image_url']?.toString(),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
      category: json['categories'] != null
          ? _createCategoryFromPartialJson(
              json['categories'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Créer une CategoryModel à partir de données partielles de la jointure SQL
  static CategoryModel? _createCategoryFromPartialJson(
      Map<String, dynamic> json) {
    try {
      return CategoryModel(
        id: json['id'] as String,
        userId: '', // Non disponible dans la jointure, mais pas critique
        name: json['name'] as String,
        description: null,
        color: json['color'] as String? ?? '#2196F3',
        imageUrl: null,
        isActive: true,
        productCount: null,
        createdAt: DateTime.now(), // Valeur par défaut
        updatedAt: DateTime.now(), // Valeur par défaut
      );
    } catch (e) {
      print('Erreur lors de la création de CategoryModel: $e');
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'name': name,
      'description': description,
      'barcode': barcode,
      'sku': sku,
      'purchase_price': purchasePrice,
      'selling_price': sellingPrice,
      'stock_quantity': stockQuantity,
      'min_stock_threshold': minStockThreshold,
      'unit': unit,
      'image_url': imageUrl,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'category_id': categoryId,
      'name': name,
      'description': description,
      'barcode': barcode,
      'sku': sku,
      'purchase_price': purchasePrice,
      'selling_price': sellingPrice,
      'stock_quantity': stockQuantity,
      'min_stock_threshold': minStockThreshold,
      'unit': unit,
      'image_url': imageUrl,
      'is_active': isActive,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'category_id': categoryId,
      'name': name,
      'description': description,
      'barcode': barcode,
      'sku': sku,
      'purchase_price': purchasePrice,
      'selling_price': sellingPrice,
      'stock_quantity': stockQuantity,
      'min_stock_threshold': minStockThreshold,
      'unit': unit,
      'image_url': imageUrl,
      'is_active': isActive,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  ProductModel copyWith({
    String? id,
    String? userId,
    String? categoryId,
    String? name,
    String? description,
    String? barcode,
    String? sku,
    double? purchasePrice,
    double? sellingPrice,
    double? stockQuantity,
    int? minStockThreshold,
    String? unit,
    String? imageUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    CategoryModel? category,
  }) {
    return ProductModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      barcode: barcode ?? this.barcode,
      sku: sku ?? this.sku,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      minStockThreshold: minStockThreshold ?? this.minStockThreshold,
      unit: unit ?? this.unit,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      category: category ?? this.category,
    );
  }

  // Calculer la marge bénéficiaire
  double get profitMargin {
    if (purchasePrice == 0) return 0;
    return ((sellingPrice - purchasePrice) / purchasePrice) * 100;
  }

  // Calculer le profit par unité
  double get profitPerUnit {
    return sellingPrice - purchasePrice;
  }
  
  // Créer un produit vide
  factory ProductModel.empty() {
    return ProductModel(
      id: '',
      userId: '',
      name: '',
      purchasePrice: 0.0,
      sellingPrice: 0.0,
      stockQuantity: 0.0,
      minStockThreshold: 10,
      unit: 'pièce',
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Vérifier si le stock est faible
  bool get isLowStock {
    return stockQuantity <= minStockThreshold;
  }

  // Vérifier si le produit est en rupture de stock
  bool get isOutOfStock {
    return stockQuantity <= 0;
  }

  // Calculer la valeur totale du stock
  double get totalStockValue {
    return stockQuantity * purchasePrice;
  }

  // Calculer la valeur de vente potentielle du stock
  double get totalSellingValue {
    return stockQuantity * sellingPrice;
  }

  @override
  String toString() {
    return 'ProductModel(id: $id, name: $name, stockQuantity: $stockQuantity, sellingPrice: $sellingPrice)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Énumération pour les unités de mesure
enum ProductUnit {
  piece('pièce'),
  kg('kg'),
  g('g'),
  liter('L'),
  ml('ml'),
  meter('m'),
  cm('cm'),
  box('boîte'),
  pack('pack'),
  bottle('bouteille'),
  can('canette'),
  bag('sac');

  const ProductUnit(this.label);
  final String label;

  static List<String> get allUnits =>
      ProductUnit.values.map((e) => e.label).toList();
}

// Statut du stock
enum StockStatus {
  inStock,
  lowStock,
  outOfStock,
}

extension ProductStockStatus on ProductModel {
  StockStatus get stockStatus {
    if (isOutOfStock) return StockStatus.outOfStock;
    if (isLowStock) return StockStatus.lowStock;
    return StockStatus.inStock;
  }
}

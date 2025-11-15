import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String color;
  final String? imageUrl;
  final bool isActive;
  final int? productCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  CategoryModel({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.color,
    this.imageUrl,
    required this.isActive,
    this.productCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      color: json['color'] as String? ?? '#2196F3',
      imageUrl: json['image_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      productCount: json['product_count'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'color': color,
      'image_url': imageUrl,
      'is_active': isActive,
      'product_count': productCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'name': name,
      'description': description,
      'color': color,
      'image_url': imageUrl,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'description': description,
      'color': color,
      'image_url': imageUrl,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  CategoryModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? color,
    String? imageUrl,
    bool? isActive,
    int? productCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      productCount: productCount ?? this.productCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Color get colorValue {
    try {
      return Color(int.parse(color.replaceFirst('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF2196F3);
    }
  }

  @override
  String toString() {
    return 'CategoryModel(id: $id, name: $name, color: $color)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Couleurs prédéfinies pour les catégories
class CategoryColors {
  static const List<Color> predefinedColors = [
    Color(0xFF2196F3), // Bleu
    Color(0xFF4CAF50), // Vert
    Color(0xFFFF9800), // Orange
    Color(0xFFE91E63), // Rose
    Color(0xFF9C27B0), // Violet
    Color(0xFF00BCD4), // Cyan
    Color(0xFFFF5722), // Rouge-orange
    Color(0xFF795548), // Marron
    Color(0xFF607D8B), // Bleu-gris
    Color(0xFFFFC107), // Ambre
    Color(0xFF8BC34A), // Vert clair
    Color(0xFF3F51B5), // Indigo
  ];

  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  static Color hexToColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF2196F3);
    }
  }
}

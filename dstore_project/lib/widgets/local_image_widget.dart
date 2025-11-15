import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class LocalImageWidget extends StatelessWidget {
  final String? imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const LocalImageWidget({
    super.key,
    this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath == null || imagePath!.isEmpty) {
      return _buildPlaceholder();
    }

    Widget imageWidget;

    if (kIsWeb && imagePath!.startsWith('data:image/')) {
      // Image base64 pour le web
      try {
        final base64Data = imagePath!.split(',')[1];
        final bytes = base64Decode(base64Data);
        imageWidget = Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
        );
      } catch (e) {
        return _buildErrorWidget();
      }
    } else if (!kIsWeb) {
      // Image fichier pour mobile/desktop
      final file = File(imagePath!);
      imageWidget = Image.file(
        file,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
      );
    } else {
      // Fallback pour les cas non supportés
      return _buildErrorWidget();
    }

    // Appliquer le borderRadius si spécifié
    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildPlaceholder() {
    return placeholder ??
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: borderRadius,
          ),
          child: Icon(
            Icons.image,
            size: (width != null && height != null) 
                ? (width! < height! ? width! * 0.4 : height! * 0.4)
                : 40,
            color: Colors.grey[400],
          ),
        );
  }

  Widget _buildErrorWidget() {
    return errorWidget ??
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: borderRadius,
          ),
          child: Icon(
            Icons.broken_image,
            size: (width != null && height != null) 
                ? (width! < height! ? width! * 0.4 : height! * 0.4)
                : 40,
            color: Colors.red[300],
          ),
        );
  }
}

/// Widget spécialisé pour les images de produits
class ProductImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final bool showBorder;

  const ProductImageWidget({
    super.key,
    this.imageUrl,
    this.size = 60,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: showBorder ? Border.all(color: Colors.grey[300]!) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: LocalImageWidget(
        imagePath: imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        borderRadius: BorderRadius.circular(8),
        placeholder: Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.inventory_2_outlined,
            size: size * 0.4,
            color: Colors.grey[400],
          ),
        ),
      ),
    );
  }
}

/// Widget spécialisé pour les images de catégories
class CategoryImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final bool showBorder;

  const CategoryImageWidget({
    super.key,
    this.imageUrl,
    this.size = 60,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: showBorder ? Border.all(color: Colors.grey[300]!) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: LocalImageWidget(
        imagePath: imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        borderRadius: BorderRadius.circular(8),
        placeholder: Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.category_outlined,
            size: size * 0.4,
            color: Colors.grey[400],
          ),
        ),
      ),
    );
  }
}

/// Widget pour afficher une image en plein écran
class FullScreenImageWidget extends StatelessWidget {
  final String imagePath;
  final String? title;

  const FullScreenImageWidget({
    super.key,
    required this.imagePath,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: title != null ? Text(title!) : null,
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 4.0,
          child: LocalImageWidget(
            imagePath: imagePath,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  static void show(BuildContext context, String imagePath, {String? title}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenImageWidget(
          imagePath: imagePath,
          title: title,
        ),
      ),
    );
  }
}

/// Widget pour sélectionner et prévisualiser une image
class ImagePickerWidget extends StatelessWidget {
  final String? currentImagePath;
  final Function(File?) onImageSelected;
  final double size;
  final String label;

  const ImagePickerWidget({
    super.key,
    this.currentImagePath,
    required this.onImageSelected,
    this.size = 120,
    this.label = 'Ajouter une image',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _pickImage(context),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!, width: 2, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[50],
            ),
            child: currentImagePath != null
                ? Stack(
                    children: [
                      LocalImageWidget(
                        imagePath: currentImagePath,
                        width: size,
                        height: size,
                        fit: BoxFit.cover,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => onImageSelected(null),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
                        size: size * 0.3,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        label,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  void _pickImage(BuildContext context) {
    // TODO: Implémenter la sélection d'image
    // Pour l'instant, on ne fait rien
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sélection d\'image à implémenter'),
      ),
    );
  }
}

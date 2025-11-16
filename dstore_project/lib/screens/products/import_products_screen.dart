import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../models/category_model.dart';
import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/excel_import_service.dart';
import '../../services/local_image_service.dart';
import '../../utils/app_utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ImportProductsScreen extends StatefulWidget {
  const ImportProductsScreen({super.key});

  @override
  State<ImportProductsScreen> createState() => _ImportProductsScreenState();
}

class _ImportProductsScreenState extends State<ImportProductsScreen> {
  List<ProductModel> _importedProducts = [];
  List<Map<String, dynamic>> _rawExcelData = [];
  bool _isLoading = false;
  bool _isImporting = false;
  String? _errorMessage;
  bool _removeProductsWithoutImages = false;
  
  // Controllers pour les champs manquants
  final Map<String, TextEditingController> _purchasePriceControllers = {};
  final Map<String, TextEditingController> _sellingPriceControllers = {};
  final Map<String, TextEditingController> _stockControllers = {};
  final Map<String, String?> _selectedCategories = {};
  final Map<String, String> _selectedUnits = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
      categoryProvider.loadCategories();
    });
  }

  @override
  void dispose() {
    // Nettoyer les controllers
    for (final controller in _purchasePriceControllers.values) {
      controller.dispose();
    }
    for (final controller in _sellingPriceControllers.values) {
      controller.dispose();
    }
    for (final controller in _stockControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickExcelFile() async {
    final l10n = AppLocalizations.of(context);
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final excelData = await ExcelImportService.pickAndReadExcelFileWithImageFilter(
        removeProductsWithoutImages: _removeProductsWithoutImages,
      );
      if (excelData != null && excelData.isNotEmpty) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final userId = authProvider.currentUser?.id ?? 'anonymous';
        
        _rawExcelData = excelData;
        final excelService = ExcelImportService();
        _importedProducts = excelService.convertToProductModels(excelData, userId);
        
        // Initialiser les controllers pour les champs manquants
        _initializeControllers();
        
        setState(() {});
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text((l10n?.productsFoundInExcel ?? '{count} produits trouvés dans le fichier Excel').replaceAll('{count}', _importedProducts.length.toString())),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _errorMessage = l10n?.noProductsFoundInExcel ?? 'Aucun produit trouvé dans le fichier Excel';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = (l10n?.errorReadingFile ?? 'Erreur lors de la lecture du fichier: {error}').replaceAll('{error}', e.toString());
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _initializeControllers() {
    for (final product in _importedProducts) {
      // Prix d'achat
      _purchasePriceControllers[product.id] = TextEditingController(
        text: product.purchasePrice > 0 ? product.purchasePrice.toString() : '',
      );
      
      // Prix de vente
      _sellingPriceControllers[product.id] = TextEditingController(
        text: product.sellingPrice > 0 ? product.sellingPrice.toString() : '',
      );
      
      // Stock
      _stockControllers[product.id] = TextEditingController(
        text: product.stockQuantity > 0 ? product.stockQuantity.toString() : '',
      );
      
      // Unité
      _selectedUnits[product.id] = product.unit;
    }
  }

  Future<void> _importProducts() async {
    setState(() {
      _isImporting = true;
      _errorMessage = null;
    });

    try {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      int successCount = 0;
      int errorCount = 0;

      print('🚀 Début de l\'importation de ${_importedProducts.length} produits...');

      for (int i = 0; i < _importedProducts.length; i++) {
        final product = _importedProducts[i];
        print('📦 Import produit ${i + 1}/${_importedProducts.length}: ${product.name}');

        try {
          // Mettre à jour le produit avec les valeurs saisies
          final updatedProduct = product.copyWith(
            categoryId: _selectedCategories[product.id],
            purchasePrice: double.tryParse(_purchasePriceControllers[product.id]?.text ?? '0') ?? 0.0,
            sellingPrice: double.tryParse(_sellingPriceControllers[product.id]?.text ?? '0') ?? 0.0,
            stockQuantity: double.tryParse(_stockControllers[product.id]?.text ?? '0') ?? 0.0,
            unit: _selectedUnits[product.id] ?? 'pièce',
          );

          print('   📝 Données: Prix achat=${updatedProduct.purchasePrice}, Prix vente=${updatedProduct.sellingPrice}, Stock=${updatedProduct.stockQuantity}');

          // Traiter l'image si une URL est fournie
          File? imageFile;
          if ((product.imageUrl ?? '').isNotEmpty) {
            print('   🖼️ Traitement image: ${product.imageUrl}');
            try {
              // Vérifier si c'est un fichier local (image intégrée) ou une URL
              if (await File(product.imageUrl!).exists()) {
                // Image intégrée - fichier local temporaire
                imageFile = File(product.imageUrl!);
                print('   ✅ Image intégrée trouvée: ${product.imageUrl}');
              } else {
                // URL réseau - télécharger l'image
                final excelService = ExcelImportService();
                final imageBytes = await excelService.downloadImageFromUrl(product.imageUrl!);
                if (imageBytes != null) {
                  // Sauvegarder l'image temporairement
                  final tempDir = Directory.systemTemp;
                  final tempFile = File('${tempDir.path}/temp_${product.id}.jpg');
                  await tempFile.writeAsBytes(imageBytes);
                  imageFile = tempFile;
                  print('   ✅ Image téléchargée et sauvegardée');
                } else {
                  print('   ⚠️ Échec téléchargement image');
                }
              }
            } catch (e) {
              print('   ❌ Erreur traitement image: $e');
            }
          }

          // Créer le produit
          print('   💾 Création du produit en base...');
          final success = await productProvider.createProductWithImage(
            product: updatedProduct,
            imageFile: imageFile,
          );

          if (success) {
            successCount++;
            print('   ✅ Produit créé avec succès');
          } else {
            errorCount++;
            print('   ❌ Échec création produit');
          }

          // Nettoyer le fichier temporaire
          if (imageFile != null && await imageFile.exists()) {
            await imageFile.delete();
          }
        } catch (e) {
          print('❌ Erreur import produit ${product.name}: $e');
          errorCount++;
        }

        // Petite pause pour éviter de surcharger la base de données
        if (i < _importedProducts.length - 1) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }

      print('🏁 Import terminé: $successCount succès, $errorCount erreurs');

      // Afficher le résultat
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Import terminé: $successCount produits importés, $errorCount erreurs',
            ),
            backgroundColor: errorCount == 0 ? Colors.green : Colors.orange,
          ),
        );

        if (successCount > 0) {
          Navigator.of(context).pop(); // Retourner à l'écran des produits
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de l\'importation: $e';
      });
    } finally {
      setState(() {
        _isImporting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Importer des produits'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (_importedProducts.isNotEmpty && !_isImporting)
            IconButton(
              onPressed: _importProducts,
              icon: const Icon(Icons.save),
              tooltip: 'Importer les produits',
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Lecture du fichier Excel...'),
          ],
        ),
      );
    }

    if (_isImporting) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Importation des produits en cours...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
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
              _errorMessage!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _pickExcelFile,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_importedProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.upload_file,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Sélectionnez un fichier Excel ou CSV pour importer des produits',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Formats supportés: .xlsx, .xls, .csv',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Option pour supprimer les produits sans image
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.image_not_supported,
                      color: _removeProductsWithoutImages ? Colors.orange : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Supprimer les produits sans image',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Les produits qui n\'ont pas d\'image seront automatiquement supprimés lors de l\'importation',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _removeProductsWithoutImages,
                      onChanged: (value) {
                        setState(() {
                          _removeProductsWithoutImages = value;
                        });
                      },
                      activeColor: Colors.orange,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickExcelFile,
                  icon: const Icon(Icons.file_upload),
                  label: const Text('Choisir un fichier'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 50),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: _showFileFormatHelp,
                  icon: const Icon(Icons.help_outline, size: 20),
                  label: const Text('Aide sur les formats'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return _buildProductsList();
  }

  Widget _buildProductsList() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${_importedProducts.length} produits trouvés. Complétez les informations manquantes ci-dessous.',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _importedProducts.length,
            itemBuilder: (context, index) {
              return _buildProductCard(_importedProducts[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(ProductModel product) {
    final l10n = AppLocalizations.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec nom et code-barres
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if ((product.barcode ?? '').isNotEmpty)
                        Text(
                          '${l10n?.barcode ?? 'Code-barres'}: ${product.barcode}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
                if ((product.imageUrl ?? '').isNotEmpty)
                  GestureDetector(
                    onTap: () => _showImagePreview(product.imageUrl!),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _buildImagePreview(product.imageUrl!),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Champs à compléter
            Row(
              children: [
                // Catégorie
                Expanded(
                  child: Consumer<CategoryProvider>(
                    builder: (context, categoryProvider, child) {
                      return DropdownButtonFormField<String>(
                        value: _selectedCategories[product.id],
                        decoration: InputDecoration(
                          labelText: '${l10n?.category ?? 'Catégorie'} *',
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: [
                          DropdownMenuItem<String>(
                            value: null,
                            child: Text(l10n?.selectCategory ?? 'Sélectionner une catégorie'),
                          ),
                          ...categoryProvider.categories.map((category) {
                            return DropdownMenuItem<String>(
                              value: category.id,
                              child: Text(category.name),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCategories[product.id] = value;
                          });
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),

                // Unité
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedUnits[product.id],
                    decoration: InputDecoration(
                      labelText: l10n?.unit ?? 'Unité',
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'pièce', child: Text('Pièce')),
                      DropdownMenuItem(value: 'kg', child: Text('Kilogramme')),
                      DropdownMenuItem(value: 'g', child: Text('Gramme')),
                      DropdownMenuItem(value: 'l', child: Text('Litre')),
                      DropdownMenuItem(value: 'ml', child: Text('Millilitre')),
                      DropdownMenuItem(value: 'm', child: Text('Mètre')),
                      DropdownMenuItem(value: 'cm', child: Text('Centimètre')),
                      DropdownMenuItem(value: 'boîte', child: Text('Boîte')),
                      DropdownMenuItem(value: 'paquet', child: Text('Paquet')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedUnits[product.id] = value ?? 'pièce';
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Prix et stock
            Row(
              children: [
                // Prix d'achat
                Expanded(
                  child: TextFormField(
                    controller: _purchasePriceControllers[product.id],
                    decoration: InputDecoration(
                      labelText: '${l10n?.purchasePrice ?? 'Prix d\'achat'} *',
                      border: const OutlineInputBorder(),
                      isDense: true,
                      suffixText: 'DH',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),

                // Prix de vente
                Expanded(
                  child: TextFormField(
                    controller: _sellingPriceControllers[product.id],
                    decoration: InputDecoration(
                      labelText: '${l10n?.salePrice ?? 'Prix de vente'} *',
                      border: const OutlineInputBorder(),
                      isDense: true,
                      suffixText: 'DH',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),

                // Stock
                Expanded(
                  child: TextFormField(
                    controller: _stockControllers[product.id],
                    decoration: InputDecoration(
                      labelText: '${l10n?.stock ?? 'Stock'} initial',
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFileFormatHelp() {
    final l10n = AppLocalizations.of(context);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n?.supportedFileFormats ?? 'Formats de fichiers supportés'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n?.acceptedFormats ?? '📁 Formats acceptés:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('✅ .xlsx - Excel moderne (recommandé)'),
                const Text('✅ .csv - Fichier CSV (alternative fiable)'),
                const Text('⚠️ .xls - Excel ancien (peut nécessiter conversion)'),
                const SizedBox(height: 16),
                Text(
                  l10n?.requiredColumns ?? '📋 Colonnes requises:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(l10n?.productNameRequiredForImport ?? '• nom - Nom du produit (obligatoire)'),
                const SizedBox(height: 12),
                Text(
                  l10n?.optionalColumns ?? '📋 Colonnes optionnelles:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(l10n?.barcodeColumn ?? '• code barre - Code-barres'),
                Text(l10n?.imageColumn ?? '• image - URL de l\'image'),
                Text(l10n?.descriptionColumn ?? '• description - Description'),
                Text(l10n?.purchasePriceColumn ?? '• prix_achat - Prix d\'achat'),
                Text(l10n?.salePriceColumn ?? '• prix_vente - Prix de vente'),
                Text(l10n?.stockColumn ?? '• stock - Quantité en stock'),
                Text(l10n?.unitColumn ?? '• unite - Unité de mesure'),
                Text('• categorie - Nom de la catégorie'),
                SizedBox(height: 16),
                Text(
                  '🔧 Problème avec votre fichier?',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                ),
                SizedBox(height: 4),
                Text(
                  '1. Convertissez .xls en .xlsx dans Excel\n'
                  '2. Ou sauvegardez en format CSV\n'
                  '3. Vérifiez que la colonne "nom" existe',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Compris'),
            ),
          ],
        );
      },
    );
  }

  /// Construire l'aperçu d'image selon le type
  Widget _buildImagePreview(String imageUrl) {
    // Image base64
    if (imageUrl.startsWith('data:image/')) {
      try {
        final base64Data = imageUrl.split(',')[1];
        final bytes = base64Decode(base64Data);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildImageError(),
        );
      } catch (e) {
        return _buildImageError();
      }
    }

    // URL réseau
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildImageError(),
      );
    }

    // Fichier local
    if (File(imageUrl).existsSync()) {
      return Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildImageError(),
      );
    }

    // Fallback
    return _buildImageError();
  }

  /// Widget d'erreur pour les images
  Widget _buildImageError() {
    return Container(
      color: Colors.grey[100],
      child: Icon(
        Icons.image_not_supported,
        color: Colors.grey[400],
        size: 24,
      ),
    );
  }

  /// Afficher l'aperçu d'image en plein écran
  void _showImagePreview(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black,
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  panEnabled: true,
                  boundaryMargin: const EdgeInsets.all(20),
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: _buildImagePreview(imageUrl),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

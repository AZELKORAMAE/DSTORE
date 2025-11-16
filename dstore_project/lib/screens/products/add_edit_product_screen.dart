import 'dart:async';
import 'dart:io' show File, Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/sound_service.dart';
import '../../utils/app_utils.dart';
import '../../widgets/barcode_preview_widget.dart';
import 'package:dstore/widgets/windows_camera_capture.dart';

class AddEditProductScreen extends StatefulWidget {
  final String? productId;

  const AddEditProductScreen({
    super.key,
    this.productId,
  });

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _skuController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _stockQuantityController = TextEditingController();
  final _minStockController = TextEditingController();

  String? _selectedCategoryId;
  String _selectedUnit = 'pièce';
  bool _isActive = true;
  bool _isLoading = false;
  ProductModel? _existingProduct;
  File? _selectedImage;

  Timer? _barcodeDebounceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryProvider>(context, listen: false).loadCategories();
      if (widget.productId != null) {
        _loadProduct();
      }
    });
  }

  @override
  void dispose() {
    _barcodeDebounceTimer?.cancel();
    _nameController.dispose();
    _descriptionController.dispose();
    _barcodeController.dispose();
    _skuController.dispose();
    _purchasePriceController.dispose();
    _sellingPriceController.dispose();
    _stockQuantityController.dispose();
    _minStockController.dispose();
    super.dispose();
  }

  Future<void> _loadProduct() async {
    if (widget.productId == null) return;

    setState(() => _isLoading = true);

    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    final product = await productProvider.getProductById(widget.productId!);

    if (product != null && mounted) {
      setState(() {
        _existingProduct = product;
        _nameController.text = product.name;
        _descriptionController.text = product.description ?? '';
        _barcodeController.text = product.barcode ?? '';
        _skuController.text = product.sku ?? '';
        _purchasePriceController.text = product.purchasePrice.toString();
        _sellingPriceController.text = product.sellingPrice.toString();
        _stockQuantityController.text = product.stockQuantity.toString();
        _minStockController.text = product.minStockThreshold.toString();
        _selectedCategoryId = product.categoryId;
        _selectedUnit = product.unit;
        _isActive = product.isActive;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context);

    // Vérifier que l'utilisateur est connecté
    if (authProvider.currentUser == null) {
      setState(() => _isLoading = false);
      if (mounted) {
        AppUtils.showSnackBar(
          context,
          l10n?.userNotConnected ?? 'Erreur: Utilisateur non connecté',
          isError: true,
        );
      }
      return;
    }

    // Vérifier le code-barres (nouveau produit uniquement)
    if (_existingProduct == null && _barcodeController.text.trim().isNotEmpty) {
      final existingProduct = await productProvider
          .getProductByBarcode(_barcodeController.text.trim());
      if (existingProduct != null) {
        setState(() => _isLoading = false);
        if (mounted) {
          _showExistingProductDialog(existingProduct);
        }
        return;
      }
    }

    // Valider que categoryId n'est pas une chaîne vide
    String? validCategoryId = _selectedCategoryId;
    if (validCategoryId != null && validCategoryId.trim().isEmpty) {
      validCategoryId = null;
    }

    final product = ProductModel(
      id: _existingProduct?.id ?? '',
      userId: authProvider.currentUser!.id,
      categoryId: validCategoryId,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      barcode: _barcodeController.text.trim().isNotEmpty
          ? _barcodeController.text.trim()
          : null,
      sku: _skuController.text.trim().isNotEmpty
          ? _skuController.text.trim()
          : null,
      purchasePrice: double.parse(_purchasePriceController.text),
      sellingPrice: double.parse(_sellingPriceController.text),
      stockQuantity: double.parse(_stockQuantityController.text),
      minStockThreshold: int.parse(_minStockController.text),
      unit: _selectedUnit,
      imageUrl: _existingProduct?.imageUrl,
      isActive: _isActive,
      createdAt: _existingProduct?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    bool success;

    try {
      if (_existingProduct != null) {
        success = await productProvider.updateProductWithImage(
          product: product.copyWith(id: _existingProduct!.id),
          newImageFile: _selectedImage,
        );
      } else {
        success = await productProvider.createProductWithImage(
          product: product,
          imageFile: _selectedImage,
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        AppUtils.showSnackBar(
          context,
          (l10n?.saveErrorMessage ??
                  'Erreur lors de la sauvegarde: {error}')
              .replaceAll('{error}', e.toString()),
          isError: true,
        );
      }
      return;
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      AppUtils.showSnackBar(
        context,
        _existingProduct != null
            ? l10n?.productUpdatedSuccess ?? 'Produit modifié avec succès'
            : l10n?.productCreatedSuccess ?? 'Produit créé avec succès',
      );
      context.pop(true); // informer l'appelant
    } else if (mounted) {
      AppUtils.showSnackBar(
        context,
        productProvider.errorMessage ??
            (l10n?.saveError ?? 'Erreur lors de la sauvegarde'),
        isError: true,
      );
    }
  }

  // --- Scan code-barres (protégé pour Windows) ---
  void _scanBarcode() async {
    if (Platform.isWindows) {
      AppUtils.showSnackBar(
        context,
        'Le scan via caméra n’est pas disponible sur Windows. Utilisez la saisie ou un lecteur USB.',
        isError: true,
      );
      return;
    }

    try {
      final result = await Navigator.of(context).push<String>(
        MaterialPageRoute(
          builder: (context) => _DirectMobileScannerScreen(),
        ),
      );

      if (!mounted || result == null || result.isEmpty) return;

      setState(() {
        _barcodeController.text = result;
      });

      AppUtils.showSnackBar(context, 'Code-barres scanné: $result');

      if (_existingProduct == null) {
        final productProvider =
            Provider.of<ProductProvider>(context, listen: false);
        final existingProduct =
            await productProvider.getProductByBarcode(result);
        if (!mounted) return;
        if (existingProduct != null) {
          _showExistingProductDialog(existingProduct);
        }
      }
    } catch (e) {
      if (!mounted) return;
      AppUtils.showSnackBar(
        context,
        'Erreur lors du scan: $e',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_existingProduct != null
            ? l10n?.editProduct ?? 'Modifier le produit'
            : l10n?.addProduct ?? 'Ajouter un produit'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveProduct,
              child: Text(l10n?.save ?? 'Sauvegarder'),
            ),
        ],
      ),
      body: _isLoading && _existingProduct == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageSection(),
                    const SizedBox(height: 24),
                    _buildBasicInfoSection(),
                    const SizedBox(height: 24),
                    _buildPriceStockSection(),
                    const SizedBox(height: 24),
                    _buildAdvancedSection(),
                    const SizedBox(height: 32),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildImageSection() {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.productImage ?? 'Image du produit',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : _existingProduct?.imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: _buildProductImage(
                                  _existingProduct!.imageUrl!),
                            )
                          : _buildImagePlaceholder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate,
          size: 40,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 8),
        Text(
          'Ajouter une image',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    try {
      // Windows : Webcam OU Fichier
      if (Platform.isWindows) {
        final String? choice = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Choisir une image'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Prendre une photo'),
                  onTap: () => Navigator.pop(context, 'camera'),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choisir depuis un fichier'),
                  onTap: () => Navigator.pop(context, 'gallery'),
                ),
              ],
            ),
          ),
        );

        if (choice == null) return;

        if (choice == 'camera') {
          final capturedPath = await showDialog<String>(
            context: context,
            barrierDismissible: true,
            builder: (_) => Dialog(
              clipBehavior: Clip.antiAlias,
              child: const SizedBox(
                width: 800,
                height: 560,
                child: WindowsCameraCapture(),
              ),
            ),
          );

          if (capturedPath != null && mounted) {
            setState(() => _selectedImage = File(capturedPath));
            AppUtils.showSnackBar(context, 'Image sélectionnée avec succès');
          }
        } else {
          final XFile? image =
              await ImagePicker().pickImage(source: ImageSource.gallery);
          if (image != null && mounted) {
            setState(() => _selectedImage = File(image.path));
            AppUtils.showSnackBar(context, 'Image sélectionnée avec succès');
          }
        }
        return;
      }

      // Android / iOS / Web
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Choisir une image'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Prendre une photo'),
                  onTap: () => Navigator.of(context).pop(ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choisir depuis la galerie'),
                  onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                ),
              ],
            ),
          );
        },
      );

      if (source != null) {
        final XFile? image = await ImagePicker().pickImage(source: source);
        if (image != null && mounted) {
          setState(() => _selectedImage = File(image.path));
          AppUtils.showSnackBar(context, 'Image sélectionnée avec succès');
        }
      }
    } catch (e) {
      if (mounted) {
        AppUtils.showSnackBar(
          context,
          'Erreur lors de la sélection de l\'image: $e',
          isError: true,
        );
      }
    }
  }

  Future<void> _generateBarcode() async {
    try {
      final result = await context.pushNamed(
        'generate-barcode',
        queryParameters: {
          if (_nameController.text.trim().isNotEmpty)
            'productName': _nameController.text.trim(),
          if (_selectedCategoryId != null)
            'categoryName': _getCategoryName(_selectedCategoryId!),
        },
      );

      if (result != null && result is Map<String, dynamic>) {
        final barcode = result['barcode'] as String?;
        final image = result['image'] as File?;

        if (barcode != null) {
          setState(() {
            _barcodeController.text = barcode;
            if (image != null) {
              _selectedImage = image;
            }
          });

          if (mounted) {
            AppUtils.showSnackBar(
              context,
              'Code-barres généré: $barcode',
              isError: false,
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        AppUtils.showSnackBar(
          context,
          'Erreur lors de la génération: $e',
          isError: true,
        );
      }
    }
  }

  String _getCategoryName(String categoryId) {
    try {
      final categoryProvider =
          Provider.of<CategoryProvider>(context, listen: false);
      final category = categoryProvider.categories.firstWhere(
        (cat) => cat.id == categoryId,
        orElse: () => throw Exception('Category not found'),
      );
      return category.name;
    } catch (e) {
      return 'Autre';
    }
  }

  void _printBarcode() {
    final barcode = _barcodeController.text.trim();
    if (barcode.isEmpty) {
      AppUtils.showSnackBar(
        context,
        'Aucun code-barres à imprimer',
        isError: true,
      );
      return;
    }

    BarcodePreviewDialog.show(
      context: context,
      barcodeData: barcode,
      productName: _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim()
          : 'Produit sans nom',
      productDescription: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      price: double.tryParse(_sellingPriceController.text.trim()),
      unit: _selectedUnit,
    );
  }

  // Vérifier le code-barres lors de la saisie manuelle
  void _onBarcodeChanged(String value) {
    if (value.trim().isEmpty || _existingProduct != null) return;

    _barcodeDebounceTimer?.cancel();
    _barcodeDebounceTimer = Timer(const Duration(milliseconds: 800), () {
      _checkBarcodeExists(value.trim());
    });
  }

  Future<void> _checkBarcodeExists(String barcode) async {
    if (barcode.isEmpty || _existingProduct != null) return;

    try {
      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);
      final existingProduct = await productProvider.getProductByBarcode(barcode);

      if (existingProduct != null && mounted) {
        _showExistingProductDialog(existingProduct);
      }
    } catch (e) {
      debugPrint('Erreur lors de la vérification du code-barres: $e');
    }
  }

  void _showExistingProductDialog(ProductModel product) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 28,
              ),
              const SizedBox(width: 8),
              const Text('Produit existant'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Un produit existe déjà avec ce code-barres :',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (product.description?.isNotEmpty == true) ...[
                      const SizedBox(height: 4),
                      Text(
                        product.description!,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Prix: ${product.sellingPrice.toStringAsFixed(2)} €',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Stock: ${product.stockQuantity} ${product.unit}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Que souhaitez-vous faire ?',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _barcodeController.clear();
                });
                AppUtils.showSnackBar(
                  context,
                  'Code-barres supprimé. Vous pouvez saisir un nouveau code.',
                  isError: false,
                );
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                AppUtils.showSnackBar(
                  context,
                  'Attention: Vous allez créer un produit avec un code-barres existant',
                  isError: true,
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.orange),
              child: const Text('Remplacer'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _confirmNavigateToExisting(product);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Modifier existant'),
            ),
          ],
        );
      },
    );
  }

  void _confirmNavigateToExisting(ProductModel product) {
    final hasData = _nameController.text.isNotEmpty ||
        _descriptionController.text.isNotEmpty ||
        _skuController.text.isNotEmpty ||
        _purchasePriceController.text.isNotEmpty ||
        _sellingPriceController.text.isNotEmpty ||
        _stockQuantityController.text.isNotEmpty ||
        _selectedImage != null ||
        _selectedCategoryId != null;

    if (hasData) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Attention'),
            content: const Text(
              'Vous avez des données non sauvegardées. '
              'Êtes-vous sûr de vouloir les perdre pour modifier le produit existant ?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/products/edit/${product.id}');
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Perdre les données'),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Produit existant trouvé'),
            content: Text(
              'Le produit "${product.name}" existe déjà avec ce code-barres.\n\n'
              'Voulez-vous modifier ce produit existant ou continuer à créer un nouveau produit ?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Créer nouveau'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/products/edit/${product.id}');
                },
                child: const Text('Modifier existant'),
              ),
            ],
          );
        },
      );
    }
  }

  Widget _buildBasicInfoSection() {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.basicInfo ?? 'Informations de base',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),

            // Nom du produit
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '${l10n?.productName ?? 'Nom du produit'} *',
                hintText: l10n?.productNameHint ?? 'Ex: iPhone 15 Pro',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n?.productNameRequired ?? 'Le nom est obligatoire';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: l10n?.description ?? 'Description',
                hintText:
                    l10n?.descriptionHint ?? 'Description détaillée du produit',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Catégorie (nullable)
            Consumer<CategoryProvider>(
              builder: (context, categoryProvider, child) {
                return DropdownButtonFormField<String?>(
                  value: _selectedCategoryId,
                  decoration: InputDecoration(
                    labelText: l10n?.category ?? 'Catégorie',
                  ),
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(l10n?.noCategory ?? 'Aucune catégorie'),
                    ),
                    ...categoryProvider.categories.map(
                      (category) => DropdownMenuItem<String?>(
                        value: category.id,
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: category.colorValue,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(category.name),
                          ],
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 16),

            // Code-barres / actions / SKU
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _barcodeController,
                  decoration: InputDecoration(
                    labelText: l10n?.barcode ?? 'Code-barres',
                    hintText: l10n?.barcodeHint ?? '1234567890123',
                  ),
                  onChanged: _onBarcodeChanged,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      onPressed: _scanBarcode,
                      icon: const Icon(Icons.qr_code_scanner),
                      tooltip:
                          l10n?.scanBarcodeTooltip ?? 'Scanner code-barres',
                      style: IconButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).primaryColor.withOpacity(0.1),
                        foregroundColor: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _generateBarcode,
                      icon: const Icon(Icons.add_circle_outline),
                      tooltip: l10n?.generateBarcodeTooltip ??
                          'Pas de code-barres ? Générer',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.orange.withOpacity(0.1),
                        foregroundColor: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _barcodeController.text.trim().isNotEmpty
                          ? _printBarcode
                          : null,
                      icon: const Icon(Icons.print),
                      tooltip:
                          l10n?.printBarcodeTooltip ?? 'Imprimer le code-barres',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.green.withOpacity(0.1),
                        foregroundColor: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _skuController,
                  decoration: InputDecoration(
                    labelText: l10n?.sku ?? 'SKU',
                    hintText: l10n?.skuHint ?? 'PROD-001',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceStockSection() {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.priceStock ?? 'Prix et stock',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),

            // Prix d'achat et de vente
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _purchasePriceController,
                    decoration: InputDecoration(
                      labelText:
                          '${l10n?.purchasePrice ?? 'Prix d\'achat'} *',
                      hintText: l10n?.purchasePriceHint ?? '0.00',
                      suffixText: 'DH',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n?.purchasePriceRequired ??
                            'Prix d\'achat obligatoire';
                      }
                      if (double.tryParse(value) == null) {
                        return l10n?.invalidPrice ?? 'Prix invalide';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _sellingPriceController,
                    decoration: InputDecoration(
                      labelText:
                          '${l10n?.salePrice ?? 'Prix de vente'} *',
                      hintText: l10n?.salePriceHint ?? '0.00',
                      suffixText: 'DH',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n?.salePriceRequired ??
                            'Prix de vente obligatoire';
                      }
                      if (double.tryParse(value) == null) {
                        return l10n?.invalidPrice ?? 'Prix invalide';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Stock et unité
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _stockQuantityController,
                    decoration: InputDecoration(
                      labelText:
                          '${l10n?.stock ?? 'Stock'} ${l10n?.quantity ?? 'Quantité'} *',
                      hintText: l10n?.stockQuantityHint ?? '0.0',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n?.stockQuantityRequired ??
                            'Quantité obligatoire';
                      }
                      final normalized = value.replaceAll(',', '.');
                      if (double.tryParse(normalized) == null) {
                        return l10n?.invalidQuantity ?? 'Quantité invalide';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedUnit,
                    decoration: InputDecoration(
                      labelText: l10n?.unit ?? 'Unité',
                    ),
                    items: ProductUnit.allUnits
                        .map(
                          (unit) => DropdownMenuItem<String>(
                            value: unit,
                            child: Text(unit),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedUnit = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Seuil minimum
            TextFormField(
              controller: _minStockController,
              decoration: InputDecoration(
                labelText:
                    l10n?.stockAlertThreshold ?? 'Seuil d\'alerte stock *',
                hintText: l10n?.stockAlertThresholdHint ?? '10',
                helperText: l10n?.stockAlertThresholdHelper ??
                    'Alerte quand le stock descend en dessous de cette valeur',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n?.thresholdRequired ?? 'Seuil obligatoire';
                }
                if (int.tryParse(value) == null) {
                  return l10n?.invalidThreshold ?? 'Seuil invalide';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedSection() {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.advancedOptions ?? 'Options avancées',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(l10n?.activeProduct ?? 'Produit actif'),
              subtitle: Text(l10n?.activeProductDescription ??
                  'Le produit est visible et disponible à la vente'),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => context.pop(),
            child: Text(l10n?.cancel ?? 'Annuler'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveProduct,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(_existingProduct != null
                    ? l10n?.edit ?? 'Modifier'
                    : l10n?.add ?? 'Créer'),
          ),
        ),
      ],
    );
  }

  Widget _buildProductImage(String imageUrl) {
    if (imageUrl.startsWith('http') || imageUrl.startsWith('https')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
      );
    } else if (imageUrl.startsWith('data:image')) {
      return Image.memory(
        Uri.parse(imageUrl).data!.contentAsBytes(),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
      );
    } else {
      return Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
      );
    }
  }
}

// --- Scanner mobile direct ---
class _DirectMobileScannerScreen extends StatefulWidget {
  @override
  State<_DirectMobileScannerScreen> createState() =>
      _DirectMobileScannerScreenState();
}

class _DirectMobileScannerScreenState
    extends State<_DirectMobileScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;
      if (code != null && code.isNotEmpty) {
        setState(() {
          _isProcessing = true;
        });

        try {
          final settings =
              Provider.of<SettingsProvider>(context, listen: false);
          SoundService.playSound(settings.scanSound);
        } catch (_) {
          SoundService.playScanSound();
        }

        Navigator.of(context).pop(code);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner le code-barres'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
          ),
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    color: Colors.white,
                    size: 32,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Pointez la caméra vers le code-barres',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Le scan se fera automatiquement',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Annuler',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

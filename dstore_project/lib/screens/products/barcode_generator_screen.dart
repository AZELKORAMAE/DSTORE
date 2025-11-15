import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/barcode_generator_service.dart';
import '../../utils/app_utils.dart';
import '../../widgets/local_image_widget.dart';
import '../../widgets/barcode_preview_widget.dart';

class BarcodeGeneratorScreen extends StatefulWidget {
  final String? productName;
  final String? categoryName;

  const BarcodeGeneratorScreen({
    super.key,
    this.productName,
    this.categoryName,
  });

  @override
  State<BarcodeGeneratorScreen> createState() => _BarcodeGeneratorScreenState();
}

class _BarcodeGeneratorScreenState extends State<BarcodeGeneratorScreen> {
  final _productNameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _customBarcodeController = TextEditingController();
  
  List<String> _generatedBarcodes = [];
  String? _selectedBarcode;
  File? _selectedImage;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _productNameController.text = widget.productName ?? '';
    _categoryController.text = widget.categoryName ?? '';
    _generateBarcodes();
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _categoryController.dispose();
    _customBarcodeController.dispose();
    super.dispose();
  }

  void _generateBarcodes() {
    setState(() {
      _isGenerating = true;
    });

    // Générer les options de codes-barres
    _generatedBarcodes = BarcodeGeneratorService.generateBarcodeOptions(
      productName: _productNameController.text.trim(),
      categoryName: _categoryController.text.trim(),
    );

    setState(() {
      _isGenerating = false;
      _selectedBarcode = _generatedBarcodes.isNotEmpty ? _generatedBarcodes.first : null;
    });
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
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

  void _useBarcode() {
    if (_selectedBarcode != null) {
      // Retourner le code-barres sélectionné et l'image
      context.pop({
        'barcode': _selectedBarcode,
        'image': _selectedImage,
      });
    }
  }

  void _useCustomBarcode() {
    final customBarcode = _customBarcodeController.text.trim();
    if (customBarcode.isNotEmpty) {
      if (BarcodeGeneratorService.isValidBarcode(customBarcode)) {
        context.pop({
          'barcode': customBarcode,
          'image': _selectedImage,
        });
      } else {
        AppUtils.showSnackBar(
          context,
          'Code-barres invalide. Utilisez seulement des lettres et chiffres (4-10 caractères)',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Générer un code-barres'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _generateBarcodes,
            icon: const Icon(Icons.refresh),
            tooltip: 'Régénérer',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 16),
            _buildProductInfoSection(),
            const SizedBox(height: 16),
            _buildImageSection(),
            const SizedBox(height: 16),
            _buildGeneratedBarcodesSection(),
            const SizedBox(height: 16),
            _buildCustomBarcodeSection(),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  'Générateur de codes-barres',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Créez des codes-barres courts et mémorisables pour vos produits sans code-barres (légumes, produits frais, etc.)',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.blue[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations du produit',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _productNameController,
              decoration: const InputDecoration(
                labelText: 'Nom du produit',
                hintText: 'Ex: Tomate, Pomme, Salade...',
                prefixIcon: Icon(Icons.inventory_2),
              ),
              onChanged: (_) => _generateBarcodes(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Catégorie',
                hintText: 'Ex: Légumes, Fruits, Viande...',
                prefixIcon: Icon(Icons.category),
              ),
              onChanged: (_) => _generateBarcodes(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Photo du produit (optionnel)',
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
                    border: Border.all(color: Colors.grey[300]!, width: 2),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[50],
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo,
                              size: 40,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Ajouter une photo',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            if (_selectedImage != null) ...[
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  onPressed: () => setState(() => _selectedImage = null),
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('Supprimer'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGeneratedBarcodesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Codes-barres générés',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (_isGenerating)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (_generatedBarcodes.isEmpty && !_isGenerating)
              const Text('Aucun code-barres généré')
            else
              ...List.generate(_generatedBarcodes.length, (index) {
                final barcode = _generatedBarcodes[index];
                final isSelected = _selectedBarcode == barcode;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () => setState(() => _selectedBarcode = barcode),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                            color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  barcode,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                                Text(
                                  _getBarcodeDescription(barcode, index),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: barcode));
                                  AppUtils.showSnackBar(
                                    context,
                                    'Code-barres copié: $barcode',
                                    isError: false,
                                  );
                                },
                                icon: const Icon(Icons.copy, size: 20),
                                tooltip: 'Copier',
                              ),
                              IconButton(
                                onPressed: () => _previewBarcode(barcode),
                                icon: const Icon(Icons.print, size: 20),
                                tooltip: 'Aperçu et impression',
                                style: IconButton.styleFrom(
                                  foregroundColor: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomBarcodeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Code-barres personnalisé',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _customBarcodeController,
              decoration: const InputDecoration(
                labelText: 'Votre code-barres',
                hintText: 'Ex: TOMATE01, LEG123...',
                prefixIcon: Icon(Icons.qr_code),
                helperText: 'Lettres et chiffres uniquement (4-10 caractères)',
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                LengthLimitingTextInputFormatter(10),
              ],
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _customBarcodeController.text.trim().isNotEmpty ? _useCustomBarcode : null,
                icon: const Icon(Icons.check),
                label: const Text('Utiliser ce code-barres'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _selectedBarcode != null ? _useBarcode : null,
            icon: const Icon(Icons.check_circle),
            label: const Text('Utiliser le code-barres sélectionné'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.cancel),
            label: const Text('Annuler'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  String _getBarcodeDescription(String barcode, int index) {
    switch (index) {
      case 0:
        return 'Code court simple';
      case 1:
        return 'Code numérique';
      case 2:
        return 'Code basé sur la date';
      case 3:
        return 'Code basé sur la catégorie';
      case 4:
        return 'Code basé sur le nom du produit';
      default:
        return 'Code généré';
    }
  }

  void _previewBarcode(String barcode) {
    BarcodePreviewDialog.show(
      context: context,
      barcodeData: barcode,
      productName: _productNameController.text.trim().isNotEmpty
        ? _productNameController.text.trim()
        : 'Produit sans nom',
      productDescription: _categoryController.text.trim().isNotEmpty
        ? _categoryController.text.trim()
        : null,
    );
  }
}

// lib/screens/categories/add_edit_category_screen.dart
import 'dart:io' show File, Platform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../providers/category_provider.dart';
import '../../models/category_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../utils/app_utils.dart' as apputils;
import '../../widgets/windows_camera_capture.dart';

class AddEditCategoryScreen extends StatefulWidget {
  final String? categoryId;

  const AddEditCategoryScreen({super.key, this.categoryId});

  @override
  State<AddEditCategoryScreen> createState() => _AddEditCategoryScreenState();
}

class _AddEditCategoryScreenState extends State<AddEditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  Color _selectedColor = Colors.blue;
  bool _isActive = true;
  bool _isLoading = false;
  CategoryModel? _existingCategory;
  File? _selectedImage;

  // Palette de couleurs proposée
  final List<Color> _predefinedColors = const [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.amber,
    Colors.cyan,
    Colors.lime,
    Colors.deepOrange,
    Colors.brown,
    Colors.blueGrey,
    Colors.deepPurple,
    Colors.lightGreen,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.categoryId != null) {
      _loadCategory();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadCategory() async {
    if (widget.categoryId == null) return;
    setState(() => _isLoading = true);

    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    final category = await categoryProvider.getCategoryById(widget.categoryId!);

    if (!mounted) return;
    if (category != null) {
      setState(() {
        _existingCategory = category;
        _nameController.text = category.name;
        _descriptionController.text = category.description ?? '';
        _selectedColor = category.colorValue;
        _isActive = category.isActive;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveCategory() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);

    bool success;
    String? uploadedUrl;

    final base = CategoryModel(
      id: _existingCategory?.id ?? '',
      userId: _existingCategory?.userId ?? '', // adapte si tu gères l'utilisateur
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      color: _selectedColor.value.toRadixString(16),
      imageUrl: _existingCategory?.imageUrl,
      isActive: _isActive,
      createdAt: _existingCategory?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    String? categoryId;
    if (_existingCategory != null) {
      categoryId = _existingCategory!.id;
      success =
          await categoryProvider.updateCategory(base.copyWith(id: categoryId));
    } else {
      success = await categoryProvider.createCategory(base);
      if (success && categoryProvider.categories.isNotEmpty) {
        categoryId = categoryProvider.categories.last.id;
      }
    }

    if (success && _selectedImage != null && categoryId != null) {
      try {
        uploadedUrl = await categoryProvider.uploadCategoryImage(
          categoryId,
          _selectedImage!,
        );
        if (uploadedUrl != null) {
          await categoryProvider.updateCategory(
            base.copyWith(id: categoryId, imageUrl: uploadedUrl),
          );
        }
      } catch (e) {
        apputils.AppUtils.showSnackBar(
          context,
          l10n.categoryImageUploadError.replaceAll('{error}', e.toString()),
          isError: true,
        );
      }
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      apputils.AppUtils.showSnackBar(
        context,
        _existingCategory != null
            ? l10n.categoryUpdatedSuccess
            : l10n.categoryCreatedSuccess,
      );
      context.pop();
    } else {
      apputils.AppUtils.showSnackBar(
        context,
        categoryProvider.errorMessage ?? l10n.saveErrorMessage,
        isError: true,
      );
    }
  }

  /// Sélection d'image cross-platform :
  /// - Windows : choix Webcam (camera Windows) ou Fichier (explorateur)
  /// - Mobile : caméra / galerie via image_picker
Future<void> _pickImage() async {
  try {
    // 🖥 Windows : Webcam OU Fichier
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
        // Ouvre la webcam Windows (widget custom)
        final capturedPath = await showDialog<String>(
          context: context,
          barrierDismissible: true,
          builder: (_) => Dialog(
            clipBehavior: Clip.antiAlias,
            child: const SizedBox(
              width: 900,
              height: 600,
              child: WindowsCameraCapture(),
            ),
          ),
        );

        if (capturedPath != null && mounted) {
          setState(() => _selectedImage = File(capturedPath));
          apputils.AppUtils.showSnackBar(context, 'Image sélectionnée avec succès');
        }
      } else {
        // Choisir un fichier image
        final XFile? image =
            await ImagePicker().pickImage(source: ImageSource.gallery);
        if (image != null && mounted) {
          setState(() => _selectedImage = File(image.path));
          apputils.AppUtils.showSnackBar(context, 'Image sélectionnée avec succès');
        }
      }
      return; // fin Windows
    }

    // 📱 Android / iOS : Caméra / Galerie
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
        apputils.AppUtils.showSnackBar(context, 'Image sélectionnée avec succès');
      }
    }
  } catch (e) {
    if (mounted) {
      apputils.AppUtils.showSnackBar(
        context,
        'Erreur lors de la sélection de l\'image: $e',
        isError: true,
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(_existingCategory != null
            ? l10n.editCategory
            : l10n.addCategoryTitle),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(onPressed: _saveCategory, child: Text(l10n.save)),
        ],
      ),
      body: _isLoading && _existingCategory == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPreviewSection(l10n),
                    const SizedBox(height: 24),
                    _buildBasicInfoSection(l10n),
                    const SizedBox(height: 24),
                    _buildColorSection(l10n),
                    const SizedBox(height: 24),
                    _buildOptionsSection(l10n),
                    const SizedBox(height: 32),
                    _buildActionButtons(l10n),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPreviewSection(AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.categoryPreview,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _selectedColor.withOpacity(0.1),
                    _selectedColor.withOpacity(0.05),
                  ],
                ),
                border: Border.all(color: _selectedColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  // vignette
                  _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _selectedImage!,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _selectedColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.category,
                              color: Colors.white, size: 20),
                        ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _nameController.text.isNotEmpty
                              ? _nameController.text
                              : l10n.categoryNameLabel.replaceAll('*', ''),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _selectedColor,
                          ),
                        ),
                        if (_descriptionController.text.isNotEmpty)
                          Text(
                            _descriptionController.text,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (!_isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        l10n.inactive,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Bouton sélectionner / prendre une image
            Center(
              child: FilledButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.add_a_photo),
                label: Text(l10n.chooseImage),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection(AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.basicInfo,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.categoryNameLabel,
                hintText: l10n.categoryNameHint,
              ),
              onChanged: (_) => setState(() {}),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l10n.categoryNameRequired : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: l10n.description,
                hintText: l10n.categoryDescriptionHint,
              ),
              maxLines: 3,
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSection(AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.categoryColor,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _predefinedColors.map((color) {
                final isSelected = color.value == _selectedColor.value;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.grey[300]!,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsSection(AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.options,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(l10n.categoryActive),
              subtitle: Text(l10n.categoryActiveHelper),
              value: _isActive,
              onChanged: (v) => setState(() => _isActive = v),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => context.pop(),
            child: Text(l10n.cancel),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveCategory,
            child: _isLoading
                ? const SizedBox(
                    width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(_existingCategory != null ? l10n.edit : l10n.createCategory),
          ),
        ),
      ],
    );
  }
}

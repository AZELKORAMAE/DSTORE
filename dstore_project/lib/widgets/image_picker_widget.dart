import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImagePickerWidget extends StatefulWidget {
  final Function(File) onImageSelected;
  final String? initialImageUrl;
  final double size;
  final String placeholder;

  const ImagePickerWidget({
    super.key,
    required this.onImageSelected,
    this.initialImageUrl,
    this.size = 120,
    this.placeholder = 'Ajouter une image',
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _showImageSourceDialog,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[300]!,
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: _buildImageContent(),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.placeholder,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        if (_selectedImage != null)
          TextButton(
            onPressed: () {
              setState(() {
                _selectedImage = null;
              });
            },
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }

  Widget _buildImageContent() {
    if (_selectedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          _selectedImage!,
          fit: BoxFit.cover,
          width: widget.size,
          height: widget.size,
        ),
      );
    }

    if ((widget.initialImageUrl ?? '').isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          widget.initialImageUrl!,
          fit: BoxFit.cover,
          width: widget.size,
          height: widget.size,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholder();
          },
        ),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_a_photo,
          size: widget.size * 0.3,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 4),
        Text(
          'Ajouter',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Prendre une photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choisir depuis la galerie'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_selectedImage != null || 
                  ((widget.initialImageUrl ?? '').isNotEmpty))
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Supprimer l\'image'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedImage = null;
                    });
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      // Vérifier les permissions
      Permission permission = source == ImageSource.camera 
          ? Permission.camera 
          : Permission.photos;
      
      PermissionStatus status = await permission.request();
      
      if (status != PermissionStatus.granted) {
        _showPermissionDialog(source);
        return;
      }

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final File imageFile = File(image.path);
        setState(() {
          _selectedImage = imageFile;
        });
        widget.onImageSelected(imageFile);
      }
    } catch (e) {
      _showErrorDialog('Erreur lors de la sélection de l\'image: $e');
    }
  }

  void _showPermissionDialog(ImageSource source) {
    String message = source == ImageSource.camera
        ? 'Permission caméra requise pour prendre des photos'
        : 'Permission galerie requise pour sélectionner des images';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permission requise'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                openAppSettings();
              },
              child: const Text('Paramètres'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Erreur'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

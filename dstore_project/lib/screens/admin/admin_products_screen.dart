import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
// import '../../services/admin_service.dart'; // Service non implémenté
import '../../models/product_model.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  // final AdminService _adminService = AdminService(); // Service non implémenté
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();

  List<ProductModel> _globalProducts = [];
  bool _isLoading = false;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadGlobalProducts();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _barcodeController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _loadGlobalProducts() async {
    setState(() => _isLoading = true);
    try {
      final products = await _adminService.getGlobalProducts();
      setState(() {
        _globalProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    if (!settings.isAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Accès refusé'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.block, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Accès administrateur requis',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Vous n\'avez pas les permissions nécessaires.'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Produits Globaux'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _showAddProductDialog,
            icon: const Icon(Icons.add),
            tooltip: 'Ajouter un produit',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildProductsList(),
    );
  }

  Widget _buildProductsList() {
    if (_globalProducts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Aucun produit global',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
                'Ajoutez des produits pour que les utilisateurs puissent les utiliser.'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _globalProducts.length,
      itemBuilder: (context, index) {
        final product = _globalProducts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Text(
                product.name.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              product.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (product.description?.isNotEmpty == true)
                  Text(product.description!),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (product.barcode?.isNotEmpty == true) ...[
                      Icon(Icons.qr_code, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          product.barcode!,
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    Icon(Icons.straighten, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        product.unit,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Modifier'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Supprimer', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'assign',
                  child: Row(
                    children: [
                      Icon(Icons.person_add),
                      SizedBox(width: 8),
                      Text('Assigner aux utilisateurs'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _showEditProductDialog(product);
                    break;
                  case 'delete':
                    _showDeleteConfirmation(product);
                    break;
                  case 'assign':
                    _showAssignToUsersDialog(product);
                    break;
                }
              },
            ),
          ),
        );
      },
    );
  }

  void _showAddProductDialog() {
    _clearControllers();
    _showProductDialog(isEdit: false);
  }

  void _showEditProductDialog(ProductModel product) {
    _nameController.text = product.name;
    _descriptionController.text = product.description ?? '';
    _barcodeController.text = product.barcode ?? '';
    _unitController.text = product.unit;
    _selectedCategoryId = product.categoryId;
    _showProductDialog(isEdit: true, product: product);
  }

  void _showProductDialog({required bool isEdit, ProductModel? product}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Modifier le produit' : 'Ajouter un produit'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du produit *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _barcodeController,
                decoration: const InputDecoration(
                  labelText: 'Code-barres',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _unitController,
                decoration: const InputDecoration(
                  labelText: 'Unité *',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => _saveProduct(isEdit, product),
            child: Text(isEdit ? 'Modifier' : 'Ajouter'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProduct(bool isEdit, ProductModel? product) async {
    if (_nameController.text.trim().isEmpty ||
        _unitController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le nom et l\'unité sont obligatoires'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      if (isEdit && product != null) {
        await _adminService.updateGlobalProduct(
          product.id,
          _nameController.text.trim(),
          _descriptionController.text.trim(),
          _barcodeController.text.trim(),
          _unitController.text.trim(),
          _selectedCategoryId,
        );
      } else {
        await _adminService.createGlobalProduct(
          _nameController.text.trim(),
          _descriptionController.text.trim(),
          _barcodeController.text.trim(),
          _unitController.text.trim(),
          _selectedCategoryId,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEdit ? 'Produit modifié' : 'Produit ajouté'),
            backgroundColor: Colors.green,
          ),
        );
        _loadGlobalProducts();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteConfirmation(ProductModel product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le produit'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${product.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => _deleteProduct(product),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProduct(ProductModel product) async {
    try {
      await _adminService.deleteGlobalProduct(product.id);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produit supprimé'),
            backgroundColor: Colors.green,
          ),
        );
        _loadGlobalProducts();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAssignToUsersDialog(ProductModel product) {
    // TODO: Implémenter l'assignation aux utilisateurs
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Assignation aux utilisateurs à implémenter'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _clearControllers() {
    _nameController.clear();
    _descriptionController.clear();
    _barcodeController.clear();
    _unitController.clear();
    _selectedCategoryId = null;
  }
}

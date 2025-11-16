import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../models/client_model.dart';
import '../../models/supplier_model.dart';
import '../../models/product_model.dart';
import '../../models/invoice_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/client_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/invoice_provider.dart';
import '../../providers/supplier_provider.dart';
import '../../utils/local_storage.dart';
import '../../widgets/common/safe_text.dart';
import '../../widgets/common/responsive_row.dart';
import '../../widgets/common/search_bar_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Classe pour representer un article dans le panier
class CartItem {
  final ProductModel product;
  double quantity;
  double unitPrice;
  String unit;

  CartItem({
    required this.product,
    required this.quantity,
    required this.unitPrice,
    this.unit = 'piece',
  });

  double get totalPrice => quantity * unitPrice;

  Map<String, dynamic> toJson() => {
    'product': product.toJson(),
    'quantity': quantity,
    'unitPrice': unitPrice,
    'unit': unit,
  };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    product: ProductModel.fromJson(json['product']),
    quantity: json['quantity']?.toDouble() ?? 0.0,
    unitPrice: json['unitPrice']?.toDouble() ?? 0.0,
    unit: json['unit'] ?? 'piece',
  );
}

/// Ecran permettant de modifier une facture existante.
class InvoiceEditScreen extends StatefulWidget {
  final String invoiceId;

  const InvoiceEditScreen({super.key, required this.invoiceId});

  @override
  State<InvoiceEditScreen> createState() => _InvoiceEditScreenState();
}

class _InvoiceEditScreenState extends State<InvoiceEditScreen> {
  InvoiceModel? _invoice;
  List<CartItem> _cartItems = [];
  bool _isLoading = true;
  bool _isScannerActive = false;
  ClientModel? _selectedClient;
  SupplierModel? _selectedSupplier;
  MobileScannerController? _scannerController;
  final TextEditingController _barcodeController = TextEditingController();
  List<String> _selectedProductIds = [];
  final TextEditingController _quantityController = TextEditingController(text: '1');
  final TextEditingController _paidAmountController = TextEditingController();
  // [removed obsolete] final TextEditingController _clientSearchController = TextEditingController();

  // Variables pour la selection client/fournisseur
  bool _showSupplierDropdown = false;
  List<SupplierModel> _filteredSuppliers = [];

  // Controleur pour la recherche de clients
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInvoice();
    _loadSelectedProducts();
    
    // Ecouter les changements du controleur de code-barres
    _barcodeController.addListener(() {
      if (_barcodeController.text.isNotEmpty) {
        // Delai pour eviter les appels multiples pendant la saisie
        Future.delayed(const Duration(milliseconds: 500), () {
          if (_barcodeController.text.isNotEmpty) {
            _processBarcode(_barcodeController.text);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    _barcodeController.dispose();
    _quantityController.dispose();
    _paidAmountController.dispose();
    // [removed obsolete] _clientSearchController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInvoice() async {
    try {
      final invoiceProvider = context.read<InvoiceProvider>();
      final invoice = await invoiceProvider.getInvoiceById(widget.invoiceId);
      
      if (invoice != null) {
        setState(() {
          _invoice = invoice;
          _cartItems = invoice.items?.map((item) => CartItem(
            product: item.product!,
            quantity: item.quantity ?? 1.0,
            unitPrice: item.unitPrice ?? 0.0,
          )).toList() ?? [];
          if (invoice.type == InvoiceType.sale) {
            _selectedClient = invoice.client;
          } else if (invoice.type == InvoiceType.purchase) {
            _selectedSupplier = invoice.supplier;
          }
          _paidAmountController.text = invoice.paidAmount.toString();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Facture non trouvee')),
          );
          context.pop();
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement: $e')),
        );
      }
    }
  }

  Future<void> _processBarcode(String barcode) async {
    try {
      final productProvider = context.read<ProductProvider>();
      final authProvider = context.read<AuthProvider>();
      
      if (authProvider.currentUser == null) return;
      
      final products = productProvider.products
          .where((p) => p.userId == authProvider.currentUser!.id)
          .toList();
      
      final product = products.where((p) => p.barcode == barcode).firstOrNull;
      
      if (product == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Produit avec code-barres $barcode non trouve'),
              action: SnackBarAction(
                label: 'Ajouter',
                onPressed: () => _navigateToAddProduct(barcode),
              ),
            ),
          );
        }
        return;
      }
      
      // Verifier si le produit est deja dans le panier
      final existingItemIndex = _cartItems.indexWhere(
          (item) => item.product.id == product.id);
      
      if (existingItemIndex != -1) {
        // Mettre a jour la quantite du produit existant
        setState(() {
          _cartItems[existingItemIndex].quantity += 
              double.tryParse(_quantityController.text) ?? 1.0;
        });
      } else {
        // Ajouter un nouveau produit au panier
        setState(() {
          _cartItems.add(CartItem(
            product: product,
            quantity: double.tryParse(_quantityController.text) ?? 1.0,
            unitPrice: product.sellingPrice,
            unit: 'piece',
          ));
        });
      }
      
      // Reinitialiser la quantite a 1
      _quantityController.text = '1';
      _barcodeController.clear();
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du traitement: $e')),
        );
      }
    }
    
    // Reinitialiser la liste des produits selectionnes pour affichage
    _selectedProductIds.clear();
    _loadSelectedProducts(); // Charger les produits selectionnes sauvegardes
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_invoice == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Erreur')),
        body: const Center(
          child: Text('Facture non trouvee'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier Facture #${_invoice!.invoiceNumber}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveInvoice,
          ),
        ],
      ),
      body: Column(
        children: [
          // Selection du client/fournisseur
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (_invoice!.type == InvoiceType.sale) ...[
                  // Selection client pour vente
                  _buildClientSelection(),
                ] else ...[
                  // Selection fournisseur pour achat
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showSupplierDropdown = !_showSupplierDropdown;
                      });
                      if (_showSupplierDropdown) {
                        _loadSuppliers();
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _selectedSupplier?.name ?? 'Selectionner un fournisseur',
                              style: TextStyle(
                                color: _selectedSupplier != null
                                    ? Colors.black
                                    : Colors.grey[600],
                              ),
                            ),
                          ),
                          Icon(
                            _showSupplierDropdown
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.grey[600],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_showSupplierDropdown) ...[
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                hintText: 'Rechercher un fournisseur...',
                                prefixIcon: Icon(Icons.search),
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              onChanged: (value) {
                                _filterSuppliers(value);
                              },
                            ),
                          ),
                          Container(
                            constraints: const BoxConstraints(maxHeight: 200),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: _filteredSuppliers.length,
                              itemBuilder: (context, index) {
                                final supplier = _filteredSuppliers[index];
                                return ListTile(
                                  title: Text(supplier.name),
                                  subtitle: supplier.phone != null && supplier.phone!.isNotEmpty
                                      ? Text(supplier.phone!)
                                      : null,
                                  onTap: () {
                                    setState(() {
                                      _selectedSupplier = supplier;
                                      _showSupplierDropdown = false;
                                    });
                                    _searchController.clear();
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _barcodeController,
                        decoration: const InputDecoration(
                          labelText: 'Code-barres',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.qr_code_scanner),
                        ),
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            _processBarcode(value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 100,
                      child: TextField(
                        controller: _quantityController,
                        decoration: const InputDecoration(
                          labelText: 'Qte',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d*')),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        _isScannerActive ? Icons.close : Icons.qr_code_scanner,
                        color: _isScannerActive ? Colors.red : Colors.blue,
                      ),
                      onPressed: _toggleScanner,
                      tooltip: _isScannerActive ? 'Fermer scanner' : 'Scanner',
                    ),
                    
                  ],
                ),
              ],
            ),
          ),
          
          // Scanner (si actif)
          if (_isScannerActive)
            Container(
              height: 200,
              margin: const EdgeInsets.all(16),
              child: MobileScanner(
                controller: _scannerController,
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    if (barcode.rawValue != null) {
                      _barcodeController.text = barcode.rawValue!;
                      _processBarcode(barcode.rawValue!);
                      break;
                    }
                  }
                },
              ),
            ),
          
          // Liste des produits dans le panier
          Expanded(
            child: _cartItems.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Aucun produit ajoute',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Scannez un code-barres ou selectionnez des produits',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _cartItems.length,
                    itemBuilder: (context, index) {
                      final item = _cartItems[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  // Image du produit
                                  Container(
                                    width: 60,
                                    height: 60,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey[300]!),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: item.product.imageUrl != null &&
                                               item.product.imageUrl!.isNotEmpty
                                           ? Image.file(
                                               File(item.product.imageUrl!),
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  color: Colors.grey[200],
                                                  child: const Icon(
                                                    Icons.image_not_supported,
                                                    color: Colors.grey,
                                                    size: 30,
                                                  ),
                                                );
                                              },
                                            )
                                          : Container(
                                              color: Colors.grey[200],
                                              child: const Icon(
                                                Icons.inventory_2,
                                                color: Colors.grey,
                                                size: 30,
                                              ),
                                            ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.product.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (item.product.barcode?.isNotEmpty ==
                                            true)
                                          Text(
                                            'Code: ${item.product.barcode}',
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () => _showDeleteConfirmation(index),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Quantite: ${item.quantity.toStringAsFixed(2)}'),
                                        Text(
                                            'Prix unitaire: ${item.unitPrice.toStringAsFixed(2)} DH'),
                                        Text(
                                          'Total: ${item.totalPrice.toStringAsFixed(2)} DH',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            width: 36,
                                            height: 36,
                                            child: IconButton(
                                              icon: const Icon(Icons.remove, size: 18),
                                              onPressed: () =>
                                                  _updateQuantity(index, -1),
                                              padding: EdgeInsets.zero,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 36,
                                            height: 36,
                                            child: IconButton(
                                              icon: const Icon(Icons.add, size: 18),
                                              onPressed: () =>
                                                  _updateQuantity(index, 1),
                                              padding: EdgeInsets.zero,
                                            ),
                                          ),
                                        ],
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            _editPrice(index),
                                        child: const Text('Modifier prix'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          
          // Section montant paye
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: const Border(
                top: BorderSide(color: Colors.grey, width: 0.5),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _paidAmountController,
                        decoration: const InputDecoration(
                          labelText: 'Montant paye (DH)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.payments),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d*')),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Montant paye:'),
                    Text(
                      '${double.tryParse(_paidAmountController.text) ?? 0.0} DH',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Totaux
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              border: const Border(
                top: BorderSide(color: Colors.blue, width: 1),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Sous-total:'),
                    Text('${_calculateSubtotal().toStringAsFixed(2)} DH'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('TVA:'),
                    Text('${_calculateTax().toStringAsFixed(2)} DH'),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_calculateTotal().toStringAsFixed(2)} DH',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'edit_quantity',
            onPressed: _showQuantityDialog,
            child: const Icon(Icons.edit),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'select_products',
            onPressed: _showProductGrid,
            child: const Icon(Icons.grid_view),
          ),
        ],
      ),
    );
  }

  void _showQuantityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier quantite'),
        content: TextField(
          controller: _quantityController,
          decoration: const InputDecoration(
            labelText: 'Quantite',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showProductGrid() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Selectionner un produit',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: _configureDisplayedProducts,
                  tooltip: 'Configurer les produits a afficher',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Consumer<ProductProvider>(
                builder: (context, productProvider, child) {
                  final authProvider = context.read<AuthProvider>();
                  if (authProvider.currentUser == null) {
                    return const Center(child: Text('Utilisateur non connecte'));
                  }
                  
                  // Filtrer les produits selon la selection de l'utilisateur
                  final userProducts = productProvider.products
                      .where((p) => p.userId == authProvider.currentUser!.id)
                      .where((p) => _selectedProductIds.isEmpty || _selectedProductIds.contains(p.id))
                      .toList();
                  
                  if (userProducts.isEmpty) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text('Aucun produit selectionne pour affichage'),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _configureDisplayedProducts,
                          icon: const Icon(Icons.settings),
                          label: const Text('Configurer les produits a afficher'),
                        ),
                      ],
                    );
                  }
                  
                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 6,
                    ),
                    itemCount: userProducts.length,
                    itemBuilder: (context, index) {
                      final product = userProducts[index];
                      final quantityController = TextEditingController(text: '1');
                      
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 3,
                              child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                                  ? Image.file(
                                      File(product.imageUrl!),
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Center(
                                          child: Icon(
                                            Icons.image_not_supported,
                                            size: 36,
                                            color: Colors.grey,
                                          ),
                                        );
                                      },
                                    )
                                  : const Center(
                                      child: Icon(
                                        Icons.inventory_2,
                                        size: 36,
                                        color: Colors.grey,
                                      ),
                                    ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SafeText(
                                      product.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                      maxLines: 2,
                                    ),
                                    const SizedBox(height: 1),
                                    SafeText(
                                      '${(_invoice?.type == InvoiceType.sale ? product.sellingPrice : product.purchasePrice).toStringAsFixed(2)} DH',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 9,
                                      ),
                                    ),
                                    const Spacer(),
                                    ResponsiveRow(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: SizedBox(
                                            height: 24,
                                            child: TextField(
                                              controller: quantityController,
                                              decoration: const InputDecoration(
                                                labelText: 'Qté',
                                                border: OutlineInputBorder(),
                                                contentPadding: EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                                labelStyle: TextStyle(fontSize: 7),
                                                isDense: true,
                                              ),
                                              style: const TextStyle(fontSize: 9),
                                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        Expanded(
                                          flex: 2,
                                          child: SizedBox(
                                            height: 24,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                final quantity = double.tryParse(quantityController.text.replaceAll(',', '.')) ?? 1.0;
                                                if (quantity > 0) {
                                                  _addProductToCartWithQuantity(product, quantity);
                                                  Navigator.pop(context);
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text('${product.name} ajouté à la facture (${quantity.toStringAsFixed(1)})'),
                                                      backgroundColor: Colors.green,
                                                      duration: Duration(seconds: 2),
                                                    ),
                                                  );
                                                } else {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text('Veuillez entrer une quantité valide'),
                                                      backgroundColor: Colors.red,
                                                      duration: Duration(seconds: 2),
                                                    ),
                                                  );
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                foregroundColor: Colors.white,
                                                padding: EdgeInsets.zero,
                                                minimumSize: Size(0, 24),
                                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              ),
                                              child: Icon(Icons.add, size: 10),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _configureDisplayedProducts() {
    String searchQuery = '';
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => DraggableScrollableSheet(
          initialChildSize: 0.8,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (context, scrollController) => Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Configurer les produits a afficher',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Rechercher des produits...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setModalState(() {
                        searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final authProvider = context.read<AuthProvider>();
                            if (authProvider.currentUser != null) {
                              final productProvider = context.read<ProductProvider>();
                              final userProducts = productProvider.products
                                  .where((p) => p.userId == authProvider.currentUser!.id)
                                  .toList();
                              
                              setModalState(() {
                                _selectedProductIds.clear();
                                _selectedProductIds.addAll(userProducts.map((p) => p.id));
                              });
                              _saveSelectedProducts();
                            }
                          },
                          child: const Text('Selectionner tous les produits'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${_selectedProductIds.length} produits selectionnes'),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Confirmer selection'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Consumer<ProductProvider>(
                    builder: (context, productProvider, child) {
                      final authProvider = context.read<AuthProvider>();
                      if (authProvider.currentUser == null) {
                        return const Center(child: Text('Utilisateur non connecte'));
                      }
                      
                      final userProducts = productProvider.products
                          .where((p) => p.userId == authProvider.currentUser!.id)
                          .where((p) => searchQuery.isEmpty || 
                              p.name.toLowerCase().contains(searchQuery) ||
                              (p.barcode?.toLowerCase().contains(searchQuery) ?? false))
                          .toList();
                      
                      return ListView.builder(
                        controller: scrollController,
                        itemCount: userProducts.length,
                        itemBuilder: (context, index) {
                          final product = userProducts[index];
                          final isSelected = _selectedProductIds.contains(product.id);
                          
                          return CheckboxListTile(
                            value: isSelected,
                            onChanged: (bool? value) {
                              setModalState(() {
                                if (value == true) {
                                  _selectedProductIds.add(product.id);
                                } else {
                                  _selectedProductIds.remove(product.id);
                                }
                              });
                              _saveSelectedProducts();
                            },
                            title: Text(product.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${product.sellingPrice.toStringAsFixed(2)} DH',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Stock: ${product.stockQuantity}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadSelectedProducts() async {
    try {
      final savedProductIds = await AppLocalStorage.getStringList('selected_product_ids');
      if (savedProductIds != null) {
        setState(() {
          _selectedProductIds = savedProductIds;
        });
      }
    } catch (e) {
      print('Erreur lors du chargement des produits selectionnes: $e');
    }
  }

  Future<void> _saveSelectedProducts() async {
    try {
      await AppLocalStorage.setStringList('selected_product_ids', _selectedProductIds);
    } catch (e) {
      print('Erreur lors de la sauvegarde des produits selectionnes: $e');
    }
  }

  void _addProductToCart(ProductModel product) {
    final existingItemIndex = _cartItems.indexWhere(
        (item) => item.product.id == product.id);
    
    if (existingItemIndex != -1) {
      setState(() {
        _cartItems[existingItemIndex].quantity += 
            double.tryParse(_quantityController.text) ?? 1.0;
      });
    } else {
      setState(() {
        _cartItems.add(CartItem(
          product: product,
          quantity: double.tryParse(_quantityController.text) ?? 1.0,
          unitPrice: _invoice!.type == InvoiceType.sale
              ? product.sellingPrice
              : product.purchasePrice,
          unit: 'piece',
        ));
      });
    }
  }

  /// Ajoute un produit au panier avec une quantité spécifique
  void _addProductToCartWithQuantity(ProductModel product, double quantity) {
    final existingItemIndex = _cartItems.indexWhere(
        (item) => item.product.id == product.id);
    
    if (existingItemIndex != -1) {
      setState(() {
        _cartItems[existingItemIndex].quantity += quantity;
      });
    } else {
      setState(() {
        _cartItems.add(CartItem(
          product: product,
          quantity: quantity,
          unitPrice: _invoice!.type == InvoiceType.sale
              ? product.sellingPrice
              : product.purchasePrice,
          unit: 'piece',
        ));
      });
    }
  }

  void _removeItem(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });
  }

  void _showDeleteConfirmation(int index) {
    final item = _cartItems[index];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('Confirmer la suppression'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Êtes-vous sûr de vouloir supprimer ce produit de la facture ?'),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Quantité: ${item.quantity.toStringAsFixed(1)}'),
                    Text(
                      'Total: ${item.totalPrice.toStringAsFixed(2)} DH',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                _removeItem(index);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${item.product.name} supprimé de la facture'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  void _updateQuantity(int index, double change) {
    setState(() {
      _cartItems[index].quantity += change;
      if (_cartItems[index].quantity <= 0) {
        _cartItems.removeAt(index);
      }
    });
  }

  void _editPrice(int index) {
    final item = _cartItems[index];
    final priceController = TextEditingController(text: item.unitPrice.toStringAsFixed(2));
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.attach_money, color: Colors.green),
              const SizedBox(width: 8),
              Text('Modifier le prix'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.inventory, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Quantité: ${item.quantity.toStringAsFixed(1)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                decoration: InputDecoration(
                  labelText: 'Prix unitaire',
                  prefixIcon: Icon(Icons.attach_money, color: Colors.green),
                  suffixText: 'DH',
                  border: OutlineInputBorder(),
                  helperText: 'Entrez le nouveau prix unitaire',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total estimé:'),
                    Text(
                      '${(item.quantity * (double.tryParse(priceController.text) ?? item.unitPrice)).toStringAsFixed(2)} DH',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                final newPrice = double.tryParse(priceController.text.replaceAll(',', '.'));
                if (newPrice != null && newPrice >= 0) {
                  setState(() {
                    _cartItems[index].unitPrice = newPrice;
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Prix de ${item.product.name} modifié avec succès'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Veuillez entrer un prix valide'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirmer'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveInvoice() async {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun produit dans la facture')),
      );
      return;
    }

    try {
      final invoiceProvider = context.read<InvoiceProvider>();
      
      final updatedInvoice = _invoice!.copyWith(
        client: _selectedClient,
        supplierId: _invoice!.type == InvoiceType.purchase ? _selectedSupplier?.id : null,
        clientId: _invoice!.type == InvoiceType.sale ? _selectedClient?.id : null,
        subtotal: _calculateSubtotal(),
        taxAmount: _calculateTax(),
        totalAmount: _calculateTotal(),
        paidAmount: double.tryParse(_paidAmountController.text) ?? 0.0,

      );
      
      final items = _cartItems.map((item) => InvoiceItemModel(
        id: '',
        invoiceId: _invoice!.id,
        productId: item.product.id,
        quantity: item.quantity,
        unitPrice: item.unitPrice,
        totalPrice: item.totalPrice,
        createdAt: DateTime.now(),
        product: item.product,
      )).toList();
      
      final success = await invoiceProvider.updateInvoice(updatedInvoice, items);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Facture mise a jour avec succes'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la sauvegarde: $e')),
        );
      }
    }
  }

  double _calculateSubtotal() {
    return _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  double _calculateTax() {
    return _calculateSubtotal() * 0.2;
  }

  double _calculateTotal() {
    return _calculateSubtotal() + _calculateTax();
  }

  void _toggleScanner() {
    setState(() {
      _isScannerActive = !_isScannerActive;
      if (_isScannerActive) {
        _scannerController = MobileScannerController();
      } else {
        _scannerController?.dispose();
        _scannerController = null;
      }
    });
  }

  Future<void> _navigateToAddProduct([String? barcode]) async {
    final result = await context.push('/add-product', extra: {
      'barcode': barcode,
    });
    
    if (result == true && mounted) {
      await context.read<ProductProvider>().loadProducts();
      
      if (barcode != null) {
        _processBarcode(barcode);
      }
    }
  }

  // Anciennes méthodes client supprimées (obsolètes)

  Future<void> _loadSuppliers() async {
    final supplierProvider = context.read<SupplierProvider>();
    final authProvider = context.read<AuthProvider>();
    
    if (authProvider.currentUser != null) {
      await supplierProvider.loadSuppliers();
      setState(() {
        _filteredSuppliers = supplierProvider.suppliers
            .where((s) => s.userId == authProvider.currentUser!.id)
            .toList();
      });
    }
  }

  Widget _buildClientSelection() {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<ClientProvider>(
      builder: (context, clientProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<ClientModel>(
                    value: _selectedClient,
                    decoration: InputDecoration(
                      labelText: l10n.clientOptionalLabel,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.person),
                    ),
                    items: [
                      DropdownMenuItem<ClientModel>(
                        value: null,
                        child: Text(l10n.anonymousClient),
                      ),
                      ...clientProvider.clients.map((client) => DropdownMenuItem(
                            value: client,
                            child: Text(client.name),
                          )),
                    ],
                    onChanged: (client) {
                      setState(() {
                        _selectedClient = client;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.search),
                  tooltip: l10n.searchByName,
                  onPressed: _openClientSearch,
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.person_add, color: Colors.green),
                  tooltip: 'Créer un nouveau client',
                  onPressed: _navigateToClientCreationPage,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _openClientSearch() {
    final l10n = AppLocalizations.of(context)!;
    final clientProvider = Provider.of<ClientProvider>(context, listen: false);
    final List<ClientModel> allClients = List.from(clientProvider.clients);
    List<ClientModel> filteredClients = List.from(allClients);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.searchByName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  SearchBarWidget(
                    hintText: l10n.searchByName,
                    onChanged: (value) {
                      setStateModal(() {
                        final query = value.toLowerCase();
                        filteredClients = allClients
                            .where((c) => c.name.toLowerCase().contains(query))
                            .toList();
                      });
                    },
                    onClear: () {
                      setStateModal(() {
                        filteredClients = List.from(allClients);
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 300,
                    child: filteredClients.isEmpty
                        ? Center(
                            child: Text(l10n.noResults),
                          )
                        : ListView.builder(
                            itemCount: filteredClients.length,
                            itemBuilder: (context, index) {
                              final client = filteredClients[index];
                              return ListTile(
                                title: Text(client.name),
                                onTap: () {
                                  setState(() {
                                    _selectedClient = client;
                                  });
                                  Navigator.of(context).pop();
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _navigateToClientCreationPage() {
    context.push('/clients/add').then((_) {
      // Recharger la liste des clients après retour de la page de création
      Provider.of<ClientProvider>(context, listen: false).loadClients();
    });
  }

  void _filterSuppliers(String query) {
    final supplierProvider = context.read<SupplierProvider>();
    final authProvider = context.read<AuthProvider>();
    
    if (authProvider.currentUser != null) {
      setState(() {
        _filteredSuppliers = supplierProvider.suppliers
            .where((s) => s.userId == authProvider.currentUser!.id)
            .where((s) => s.name.toLowerCase().contains(query.toLowerCase()) ||
                         (s.phone?.toLowerCase().contains(query.toLowerCase()) ?? false))
            .toList();
      });
    }
  }
}
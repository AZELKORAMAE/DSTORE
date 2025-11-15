import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../models/invoice_model.dart';

import '../../models/product_model.dart';
import '../../models/client_model.dart';
import '../../models/supplier_model.dart';
import '../../providers/invoice_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/client_provider.dart';
import '../../services/supplier_service.dart';
import '../../services/sound_service.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/local_storage.dart';
import '../products/add_edit_product_screen.dart';

// Classe pour representer un article dans le panier
class CartItem {
  final ProductModel product;
  final double quantity;
  final double unitPrice;

  CartItem({
    required this.product,
    required this.quantity,
    required this.unitPrice,
  });

  double get totalPrice => quantity * unitPrice;

  CartItem copyWith({
    ProductModel? product,
    double? quantity,
    double? unitPrice,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
    );
    }
}

/// Ecran permettant de modifier une facture existante.
///
/// Cette interface charge la facture a partir de son identifiant, puis
/// affiche la liste des lignes de facture (produits, quantites et prix).
/// L'utilisateur peut ajuster les quantites, modifier les prix unitaires,
/// supprimer des lignes ou en ajouter de nouvelles. Lors de la sauvegarde,
/// les montants (sous-total, taxe, total) sont recalcules et la facture est
/// mise a jour via le `InvoiceProvider` avec gestion automatique des credits,
/// revenus et stock.
class InvoiceEditScreen extends StatefulWidget {
  final String invoiceId;
  const InvoiceEditScreen({super.key, required this.invoiceId});

  @override
  State<InvoiceEditScreen> createState() => _InvoiceEditScreenState();
}

class _InvoiceEditScreenState extends State<InvoiceEditScreen> {
  InvoiceModel? _invoice;
  final List<CartItem> _cartItems = [];
  bool _loading = true;
  bool _saving = false;
  
  // Variables pour le scan de code-barres
  bool _isScanning = false;
  MobileScannerController? _scannerController;
  final TextEditingController _barcodeController = TextEditingController();
  List<String> _selectedProductIds = []; // IDs des produits selectionnes pour affichage
  final TextEditingController _quantityController = TextEditingController(text: '1');
  final TextEditingController _paidAmountController = TextEditingController();
  final FocusNode _barcodeFocusNode = FocusNode();
  
  // Variables pour la sélection client/fournisseur
  ClientModel? _selectedClient;
  SupplierModel? _selectedSupplier;
  bool _isAnonymousSupplier = false;
  bool _isProcessing = false;
  final SupplierService _supplierService = SupplierService();
  List<SupplierModel> _suppliers = [];
  
  // Contrôleur pour la recherche de clients
  final TextEditingController _clientSearchController = TextEditingController();
  
  // Calculs des montants
  double get _subtotal =>
      _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  
  double get _taxAmount {
    final tvaRate = Provider.of<SettingsProvider>(context, listen: false).tvaRate;
    return _subtotal * (tvaRate / 100);
  }
  
  double get _totalAmount => _subtotal + _taxAmount;
  
  double get _paidAmount {
    final text = _paidAmountController.text.replaceAll(',', '.');
    return double.tryParse(text) ?? 0.0;
  }
  
  Future<void> _loadSuppliers() async {
    try {
      final suppliers = await _supplierService.getAllSuppliers();
      setState(() {
        _suppliers = suppliers;
      });
    } catch (e) {
      print('Erreur lors du chargement des fournisseurs: $e');
    }
  }
  
  void _addProductByBarcode(String barcode) async {
    if (barcode.isEmpty) return;
    
    final productProvider = context.read<ProductProvider>();
    final authProvider = context.read<AuthProvider>();
    
    if (authProvider.currentUser == null) return;
    
    await productProvider.loadUserProducts(authProvider.currentUser!.id);
    final product = productProvider.products.firstWhere(
      (p) => p.barcode == barcode,
      orElse: () => ProductModel(
        id: '',
        userId: authProvider.currentUser!.id,
        name: '',
        barcode: '',
        sellingPrice: 0.0,
        purchasePrice: 0.0,
        stockQuantity: 0.0,
        minStockThreshold: 10,
        unit: 'pièce',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
      
      if (product.id.isNotEmpty) {
      _addProductToCart(product);
      _barcodeController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Produit avec code-barres $barcode non trouvé'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
  
  void _addProductToCart(ProductModel product) {
    final quantity = double.tryParse(_quantityController.text.replaceAll(',', '.')) ?? 1.0;
    final unitPrice = _invoice?.type == InvoiceType.purchase 
        ? product.purchasePrice 
        : product.sellingPrice;
    
    // Vérifier si le produit est déjà dans le panier
    final existingIndex = _cartItems.indexWhere((item) => item.product.id == product.id);
    
    setState(() {
      if (existingIndex >= 0) {
        // Mettre à jour la quantité du produit existant
        final existingItem = _cartItems[existingIndex];
        _cartItems[existingIndex] = existingItem.copyWith(
          quantity: existingItem.quantity + quantity,
        );
      } else {
        // Ajouter un nouveau produit
        _cartItems.add(CartItem(
          product: product,
          quantity: quantity,
          unitPrice: unitPrice,
        ));
      }
    });
    
    // Réinitialiser la quantité à 1
    _quantityController.text = '1';
    
    // Jouer un son de confirmation
    SoundService.playScanSound();
  }

  @override
  void initState() {
    super.initState();
    // Réinitialiser la liste des produits sélectionnés pour affichage
    _selectedProductIds.clear();
    _loadSelectedProducts(); // Charger les produits sélectionnés sauvegardés
    _loadInvoice();
    _scannerController = MobileScannerController();
    _loadSuppliers();
    
    // Écouter les changements du contrôleur de code-barres
    _barcodeController.addListener(() {
      if (_barcodeController.text.isNotEmpty && _barcodeController.text.length > 3) {
        // Délai pour éviter les appels multiples pendant la saisie
        Future.delayed(const Duration(milliseconds: 500), () {
          if (_barcodeController.text.isNotEmpty) {
            _addProductByBarcode(_barcodeController.text);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _quantityController.dispose();
    _paidAmountController.dispose();
    _clientSearchController.dispose();
    _barcodeFocusNode.dispose();
    _scannerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_invoice == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.edit),
        ),
        body: const Center(
          child: Text('Facture introuvable'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier Facture #${_invoice!.invoiceNumber}'),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveInvoice,
              tooltip: 'Sauvegarder les modifications',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Informations de la facture
            _buildInvoiceInfo(),
            const SizedBox(height: 16),
            
            // Sélection du client/fournisseur
            if (_invoice!.type == InvoiceType.sale) _buildClientSelection(),
            if (_invoice!.type == InvoiceType.purchase) _buildSupplierSelection(),
            const SizedBox(height: 12),
            
            // Champ code-barres et boutons
            _buildBarcodeSection(),
            
            // Scanner de codes-barres
            if (_isScanning) _buildBarcodeScanner(),
            
            const SizedBox(height: 16),
            
            // Liste des produits dans le panier
            _buildCartSection(),
            
            const SizedBox(height: 16),
            
            // Section paiement
            _buildPaymentSection(),
            
            const SizedBox(height: 24),
            
            // Bouton de sauvegarde
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Future<void> _loadInvoice() async {
    final invoiceProvider = context.read<InvoiceProvider>();
    final invoice = await invoiceProvider.getInvoiceById(widget.invoiceId);
    if (mounted && invoice != null) {
      // Convertir les items en CartItem
      final cartItems = <CartItem>[];
      if (invoice.items != null) {
        for (final item in invoice.items!) {
          if (item.product != null) {
            cartItems.add(CartItem(
              product: item.product!,
              quantity: item.quantity ?? 1.0,
              unitPrice: item.unitPrice ?? 0.0,
            ));
          }
        }
      }
      
      // Charger le client ou fournisseur
      if (invoice.type == InvoiceType.sale && invoice.clientId != null) {
        final clientProvider = context.read<ClientProvider>();
        await clientProvider.loadClients();
        _selectedClient = clientProvider.clients.firstWhere(
          (c) => c.id == invoice.clientId,
          orElse: () => ClientModel(
            id: '',
            userId: '',
            name: 'Client supprimé',
            creditLimit: 0.0,
            currentCredit: 0.0,
            totalPurchases: 0.0,
            isActive: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
      } else if (invoice.type == InvoiceType.purchase && invoice.supplierId != null) {
        final supplier = _suppliers.firstWhere(
          (s) => s.id == invoice.supplierId,
          orElse: () => SupplierModel(
            id: '',
            userId: '',
            name: 'Fournisseur supprimé',
            isActive: false,
            totalPurchases: 0.0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        _selectedSupplier = supplier;
      }
      
      setState(() {
        _invoice = invoice;
        _cartItems.clear();
        _cartItems.addAll(cartItems);
        _paidAmountController.text = invoice.paidAmount.toString();
        _loading = false;
      });
    }
  }


  
  Widget _buildInvoiceInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Facture #${_invoice!.invoiceNumber}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text('Type: ${_invoice!.type == InvoiceType.sale ? "Vente" : "Achat"}'),
                      Text('Date: ${_invoice!.createdAt?.toString().split(' ')[0] ?? "N/A"}'),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total: ${_totalAmount.toStringAsFixed(2)} DH',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text('Statut: ${_invoice!.statusDisplayName}'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
                  icon: const Icon(Icons.add_circle),
                  tooltip: 'Créer un nouveau client',
                  onPressed: () {
                    // Navigation vers création de client
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildSupplierSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<SupplierModel>(
                value: _selectedSupplier,
                decoration: const InputDecoration(
                  labelText: 'Fournisseur',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                items: [
                  const DropdownMenuItem<SupplierModel>(
                    value: null,
                    child: Text('Fournisseur anonyme'),
                  ),
                  ..._suppliers.map((supplier) => DropdownMenuItem(
                        value: supplier,
                        child: Text(supplier.name),
                      )),
                ],
                onChanged: (supplier) {
                  setState(() {
                    _selectedSupplier = supplier;
                    _isAnonymousSupplier = supplier == null;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildBarcodeSection() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _barcodeController,
          focusNode: _barcodeFocusNode,
          decoration: InputDecoration(
            labelText: l10n.barcode,
            hintText: l10n.barcodeEntryHint,
            prefixIcon: const Icon(Icons.qr_code_scanner),
            border: const OutlineInputBorder(),
          ),
          onSubmitted: _addProductByBarcode,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: l10n.quantityShort,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _toggleScanner,
              icon: Icon(_isScanning ? Icons.close : Icons.qr_code_scanner),
              tooltip: _isScanning ? l10n.closeScannerTooltip : l10n.scannerTooltip,
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _showProductsGrid,
              icon: const Icon(Icons.grid_view),
              tooltip: 'Afficher les produits',
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildBarcodeScanner() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: MobileScanner(
          controller: _scannerController,
          onDetect: _onBarcodeDetected,
        ),
      ),
    );
   }
   
   Widget _buildCartSection() {
     return Card(
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Padding(
             padding: const EdgeInsets.all(16),
             child: Row(
               children: [
                 const Icon(Icons.shopping_cart),
                 const SizedBox(width: 8),
                 Text(
                   'Produits (${_cartItems.length})',
                   style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                 ),
               ],
             ),
           ),
           if (_cartItems.isEmpty)
             const Padding(
               padding: EdgeInsets.all(32),
               child: Center(
                 child: Column(
                   children: [
                     Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                     SizedBox(height: 16),
                     Text(
                       'Aucun produit ajouté',
                       style: TextStyle(color: Colors.grey, fontSize: 16),
                     ),
                     SizedBox(height: 8),
                     Text(
                       'Scannez un code-barres ou sélectionnez des produits',
                       style: TextStyle(color: Colors.grey, fontSize: 12),
                       textAlign: TextAlign.center,
                     ),
                   ],
                 ),
               ),
             )
           else
             ListView.separated(
               shrinkWrap: true,
               physics: const NeverScrollableScrollPhysics(),
               itemCount: _cartItems.length,
               separatorBuilder: (context, index) => const Divider(height: 1),
               itemBuilder: (context, index) {
                 final item = _cartItems[index];
                 return _buildCartItemTile(item, index);
               },
             ),
           if (_cartItems.isNotEmpty)
             Padding(
               padding: const EdgeInsets.all(16),
               child: Column(
                 children: [
                   const Divider(),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       const Text('Sous-total:', style: TextStyle(fontSize: 16)),
                       Text('${_subtotal.toStringAsFixed(2)} DH', style: const TextStyle(fontSize: 16)),
                     ],
                   ),
                   const SizedBox(height: 4),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       const Text('TVA:', style: TextStyle(fontSize: 16)),
                       Text('${_taxAmount.toStringAsFixed(2)} DH', style: const TextStyle(fontSize: 16)),
                     ],
                   ),
                   const SizedBox(height: 8),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       const Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                       Text('${_totalAmount.toStringAsFixed(2)} DH', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                     ],
                   ),
                 ],
               ),
             ),
         ],
       ),
     );
   }
   
   Widget _buildCartItemTile(CartItem item, int index) {
     return ListTile(
       leading: CircleAvatar(
         backgroundColor: Colors.blue.shade100,
         child: Text(
           item.product.name.isNotEmpty ? item.product.name[0].toUpperCase() : 'P',
           style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold),
         ),
       ),
       title: Text(item.product.name),
       subtitle: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Text('Prix unitaire: ${item.unitPrice.toStringAsFixed(2)} DH'),
           Text('Quantité: ${item.quantity.toStringAsFixed(2)}'),
         ],
       ),
       trailing: Row(
         mainAxisSize: MainAxisSize.min,
         children: [
           Text(
             '${item.totalPrice.toStringAsFixed(2)} DH',
             style: const TextStyle(fontWeight: FontWeight.bold),
           ),
           const SizedBox(width: 8),
           IconButton(
             icon: const Icon(Icons.edit, size: 20),
             onPressed: () => _editCartItem(index),
           ),
           IconButton(
             icon: const Icon(Icons.delete, size: 20, color: Colors.red),
             onPressed: () => _removeCartItem(index),
           ),
         ],
       ),
     );
   }
   
   Widget _buildPaymentSection() {
     return Card(
       child: Padding(
         padding: const EdgeInsets.all(16),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             const Row(
               children: [
                 Icon(Icons.payment),
                 SizedBox(width: 8),
                 Text(
                   'Paiement',
                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                 ),
               ],
             ),
             const SizedBox(height: 16),
             TextField(
               controller: _paidAmountController,
               decoration: const InputDecoration(
                 labelText: 'Montant payé (DH)',
                 border: OutlineInputBorder(),
                 prefixIcon: Icon(Icons.attach_money),
               ),
               keyboardType: const TextInputType.numberWithOptions(decimal: true),
               inputFormatters: [
                 FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
               ],
             ),
             const SizedBox(height: 12),
             if (_paidAmount > 0)
               Column(
                 children: [
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       const Text('Montant payé:'),
                       Text('${_paidAmount.toStringAsFixed(2)} DH'),
                     ],
                   ),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       const Text('Montant restant:'),
                       Text(
                         '${(_totalAmount - _paidAmount).toStringAsFixed(2)} DH',
                         style: TextStyle(
                           color: _paidAmount >= _totalAmount ? Colors.green : Colors.orange,
                           fontWeight: FontWeight.bold,
                         ),
                       ),
                     ],
                   ),
                 ],
               ),
           ],
         ),
       ),
     );
   }
   
   Widget _buildSaveButton() {
     return SizedBox(
       width: double.infinity,
       height: 50,
       child: ElevatedButton.icon(
         onPressed: _saving ? null : _saveInvoice,
         icon: _saving 
             ? const SizedBox(
                 width: 20,
                 height: 20,
                 child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
               )
             : const Icon(Icons.save),
         label: Text(_saving ? 'Sauvegarde...' : 'Sauvegarder les modifications'),
         style: ElevatedButton.styleFrom(
           backgroundColor: Colors.green,
           foregroundColor: Colors.white,
         ),
       ),
     );
   }
   
   void _editCartItem(int index) {
    final item = _cartItems[index];
    final quantityController = TextEditingController(text: item.quantity.toString());
    final priceController = TextEditingController(text: item.unitPrice.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier ${item.product.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(
                labelText: 'Quantité',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(
                labelText: 'Prix unitaire (DH)',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final quantity = double.tryParse(quantityController.text.replaceAll(',', '.')) ?? item.quantity;
              final price = double.tryParse(priceController.text.replaceAll(',', '.')) ?? item.unitPrice;
              
              setState(() {
                _cartItems[index] = CartItem(
                  product: item.product,
                  quantity: quantity,
                  unitPrice: price,
                );
              });
              
              Navigator.pop(context);
            },
            child: const Text('Sauvegarder'),
          ),
        ],
      ),
    );
  }
  
  void _removeCartItem(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });
    SoundService.playScanSound();
  }
  
  void _showProductsGrid() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
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
                      'Sélectionner un produit',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _configureDisplayedProducts,
                          icon: const Icon(Icons.settings),
                          tooltip: 'Configurer les produits à afficher',
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
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
                      return const Center(child: Text('Utilisateur non connecté'));
                    }
                    
                    // Filtrer les produits selon la sélection de l'utilisateur
                    // Afficher seulement les produits sélectionnés (liste vide par défaut)
                    final availableProducts = productProvider.products
                        .where((product) => 
                            product.userId == authProvider.currentUser!.id &&
                            _selectedProductIds.contains(product.id))
                        .toList();
                    
                    if (availableProducts.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            const Text('Aucun produit sélectionné pour affichage'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _configureDisplayedProducts,
                              child: const Text('Configurer les produits'),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    return GridView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: availableProducts.length,
                      itemBuilder: (context, index) {
                        final product = availableProducts[index];
                        return Card(
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              _addProductToCart(product);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Center(
                                      child: Icon(
                                        Icons.inventory_2,
                                        size: 48,
                                        color: Colors.blue.shade300,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    product.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${(_invoice?.type == 'achat' ? product.purchasePrice : product.sellingPrice).toStringAsFixed(2)} DH',
                                    style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Stock: ${product.stockQuantity}',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
    );
  }

  void _toggleScanner() {
    setState(() {
      _isScanning = !_isScanning;
    });
  }

  /// Configure les produits à afficher dans la grille
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
                        'Configurer les produits à afficher',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                // Barre de recherche
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Rechercher par nom ou code-barres',
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
                          final productProvider = context.read<ProductProvider>();
                          if (authProvider.currentUser != null) {
                            setState(() {
                              _selectedProductIds.clear();
                              _selectedProductIds.addAll(
                                productProvider.products
                                    .where((product) => product.userId == authProvider.currentUser!.id)
                                    .map((product) => product.id)
                              );
                            });
                            _saveSelectedProducts(); // Sauvegarder après sélection de tous
                          }
                          Navigator.pop(context);
                        },
                        child: const Text('Sélectionner tous les produits'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${_selectedProductIds.length} produits sélectionnés'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Confirmer sélection'),
                      ),
                    ),
                  ],
                ),
              ),
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Confirmer sélection'),
                      ),
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
                      return const Center(child: Text('Utilisateur non connecté'));
                    }
                    
                    final userProducts = productProvider.products
                        .where((product) => 
                            product.userId == authProvider.currentUser!.id &&
                            (searchQuery.isEmpty ||
                             product.name.toLowerCase().contains(searchQuery) ||
                             (product.barcode?.toLowerCase().contains(searchQuery) ?? false)))
                        .toList();
                    
                    if (userProducts.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('Aucun produit disponible'),
                          ],
                        ),
                      );
                    }
                    
                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: userProducts.length,
                      itemBuilder: (context, index) {
                        final product = userProducts[index];
                        final isSelected = _selectedProductIds.contains(product.id);
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: CheckboxListTile(
                            value: isSelected,
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  _selectedProductIds.add(product.id);
                                } else {
                                  _selectedProductIds.remove(product.id);
                                }
                              });
                              _saveSelectedProducts(); // Sauvegarder après modification
                            },
                            title: Text(
                              product.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Achat: \${product.purchasePrice.toStringAsFixed(2)} DH',
                                        style: TextStyle(
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        'Vente: \${product.sellingPrice.toStringAsFixed(2)} DH',
                                        style: TextStyle(
                                          color: Colors.green.shade700,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Stock: \${product.stockQuantity}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
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
    );
  }

  /// Charger les produits sélectionnés depuis le stockage local
  Future<void> _loadSelectedProducts() async {
    try {
      final savedProductIds = await AppLocalStorage.getStringList('selected_product_ids');
      if (savedProductIds != null) {
        setState(() {
          _selectedProductIds = savedProductIds;
        });
      }
    } catch (e) {
      print('Erreur lors du chargement des produits sélectionnés: $e');
    }
  }

  /// Sauvegarder les produits sélectionnés dans le stockage local
  Future<void> _saveSelectedProducts() async {
    try {
      await AppLocalStorage.setStringList('selected_product_ids', _selectedProductIds);
    } catch (e) {
      print('Erreur lors de la sauvegarde des produits sélectionnés: $e');
    }
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final barcode = barcodes.first.rawValue ?? '';
      if (barcode.isNotEmpty) {
        SoundService.playScanSound();
        _barcodeController.text = barcode;
        _addProductByBarcode(barcode);
        setState(() {
          _isScanning = false;
        });
      }
    }
  }
  
  Future<void> _saveInvoice() async {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez ajouter au moins un produit'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _saving = true;
    });
    
    try {
      // Convertir les CartItem en InvoiceItemModel
      final items = _cartItems.map((cartItem) => InvoiceItemModel(
        id: '',
        invoiceId: _invoice!.id,
        productId: cartItem.product.id,
        quantity: cartItem.quantity,
        unitPrice: cartItem.unitPrice,
        totalPrice: cartItem.totalPrice,
        createdAt: DateTime.now(),
        product: cartItem.product,
      )).toList();
      
      // Créer la facture mise à jour
      final updatedInvoice = _invoice!.copyWith(
        clientId: _selectedClient?.id,
        supplierId: _selectedSupplier?.id,
        items: items,
        subtotal: _subtotal,
        taxAmount: _taxAmount,
        totalAmount: _totalAmount,
        paidAmount: _paidAmount,
        status: _paidAmount >= _totalAmount ? InvoiceStatus.paid : InvoiceStatus.validated,
        updatedAt: DateTime.now(),
      );
      
      // Sauvegarder avec gestion automatique des stocks, crédits et revenus
      await context.read<InvoiceProvider>().updateInvoice(updatedInvoice, items);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Facture mise à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sauvegarde: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }
}
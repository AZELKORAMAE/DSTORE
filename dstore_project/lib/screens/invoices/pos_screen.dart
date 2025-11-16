import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_router.dart';
import '../../models/invoice_model.dart';
import '../../models/product_model.dart';
import '../../models/client_model.dart';
import '../../models/supplier_model.dart';
import '../../providers/product_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/client_provider.dart';
import '../../providers/invoice_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/supplier_service.dart';
import '../../services/sound_service.dart';
import '../../services/credit_service.dart';
import '../../services/local_image_service.dart';
import '../../services/invoice_print_service.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/invoices/invoice_image_picker.dart';
import '../../widgets/common/search_bar_widget.dart';
import '../../widgets/common/safe_text.dart';
import '../../widgets/common/responsive_row.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../utils/local_storage.dart';
import '../products/add_edit_product_screen.dart';

// Classe pour représenter un article dans le panier
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

class POSScreen extends StatefulWidget {
  final InvoiceType invoiceType;

  const POSScreen({
    super.key,
    required this.invoiceType,
  });

  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  final List<CartItem> _cartItems = [];
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _quantityController =
      TextEditingController(text: '1');
  final TextEditingController _paidAmountController = TextEditingController();
  final FocusNode _barcodeFocusNode = FocusNode();

  ClientModel? _selectedClient;
  SupplierModel? _selectedSupplier;
  bool _isAnonymousSupplier = false;
  bool _isScanning = false;
  bool _isProcessing = false;
  MobileScannerController? _scannerController;
  final SupplierService _supplierService = SupplierService();
  final InvoicePrintService _printService = InvoicePrintService();
  List<SupplierModel> _suppliers = [];
  File? _selectedInvoiceImage; // Image de la facture pour les achats
  InvoiceModel? _lastCreatedInvoice; // Stocker la dernière facture créée

  // Stocke temporairement un code-barres scanné qui n'existe pas. Utilisé pour
  // ajouter automatiquement le produit après qu'il a été créé puis revenir à la facture.
  String? _pendingBarcode;

  // Contrôleur utilisé pour la recherche de clients dans le sélecteur personnalisé
  final TextEditingController _clientSearchController = TextEditingController();
  
  // IDs des produits sélectionnés pour affichage (vide par défaut)
  List<String> _selectedProductIds = [];

  double get _subtotal =>
      _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  // Calcul dynamique du montant de la TVA basé sur le taux défini dans les paramètres
  double get _taxAmount {
    // Récupérer le taux de TVA depuis les paramètres (par exemple, 20.0 pour 20%)
    final tvaRate = Provider.of<SettingsProvider>(context, listen: false).tvaRate;
    return _subtotal * (tvaRate / 100);
  }
  double get _totalAmount => _subtotal + _taxAmount;
  double get _paidAmount => double.tryParse(_paidAmountController.text) ?? 0.0;
  double get _changeAmount => _paidAmount - _totalAmount;

  @override
  void initState() {
    super.initState();
    _loadSelectedProducts(); // Charger les produits sélectionnés sauvegardés
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _barcodeFocusNode.requestFocus();
      if (widget.invoiceType == InvoiceType.purchase) {
        _loadSuppliers();
      }
    });
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

  Future<void> _loadSuppliers() async {
    try {
      final suppliers = await _supplierService.getAllSuppliers();
      setState(() {
        _suppliers = suppliers;
      });
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.errorLoadingSuppliers}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _quantityController.dispose();
    _paidAmountController.dispose();
    _barcodeFocusNode.dispose();
    _scannerController?.dispose();
    _clientSearchController.dispose();
    super.dispose();
  }
  
  /// Navigue vers la page de création de client
  void _navigateToClientCreationPage() {
    context.push('/clients/add').then((_) {
      // Recharger la liste des clients après retour de la page de création
      Provider.of<ClientProvider>(context, listen: false).loadClients();
    });
  }
  
  /// Affiche une grille de produits avec images pour sélection rapide
  void _showProductsGrid() async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;
    
    // Vérifier que l'utilisateur est connecté
    if (authProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur: Utilisateur non connecté')),
      );
      return;
    }
    
    // Charger uniquement les produits de l'utilisateur connecté
    await productProvider.loadUserProducts(authProvider.currentUser!.id);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Sélectionner un produit',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings),
                          onPressed: () {
                            Navigator.pop(context);
                            _configureDisplayedProducts();
                          },
                          tooltip: 'Configurer les produits à afficher',
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _navigateToAddProduct();
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Ajouter un nouveau produit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  Expanded(
                    child: Consumer<ProductProvider>(
                      builder: (context, productProvider, child) {
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
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _configureDisplayedProducts();
                                  },
                                  child: const Text('Configurer les produits à afficher'),
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
              childAspectRatio: 0.75,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
                          itemCount: availableProducts.length,
                          itemBuilder: (context, index) {
                            final product = availableProducts[index];
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
                                            '${(widget.invoiceType == InvoiceType.purchase ? product.purchasePrice : product.sellingPrice).toStringAsFixed(2)} DH',
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
                                                      labelStyle: TextStyle(fontSize: 6),
                                                      isDense: true,
                                                    ),
                                                    style: const TextStyle(fontSize: 8),
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
                                                            content: SafeText('${product.name} ajouté au panier (${quantity.toStringAsFixed(1)})'),
                                                            backgroundColor: Colors.green,
                                                            duration: const Duration(seconds: 2),
                                                          ),
                                                        );
                                                      } else {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          const SnackBar(
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
                                                      minimumSize: const Size(0, 24),
                                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                    ),
                                                    child: const Icon(Icons.add, size: 10),
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
            );
          },
        );
      },
    );
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
                              content: Text('\${_selectedProductIds.length} produits sélectionnés'),
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
                                        'Achat: ${product.purchasePrice.toStringAsFixed(2)} DH',
                                        style: TextStyle(
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        'Vente: ${product.sellingPrice.toStringAsFixed(2)} DH',
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
                                  'Stock: ${product.stockQuantity}',
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
    ),
    );
  }
  
  /// Ajoute un produit au panier depuis la grille de produits
  void _addProductToCart(ProductModel product) {
    final quantity = double.tryParse(_quantityController.text.replaceAll(',', '.')) ?? 1.0;
    
    // Vérifier si le produit est déjà dans le panier
    final existingItemIndex = _cartItems.indexWhere((item) => item.product.id == product.id);
    
    setState(() {
      if (existingItemIndex >= 0) {
        // Mettre à jour la quantité si le produit existe déjà
        final existingItem = _cartItems[existingItemIndex];
        _cartItems[existingItemIndex] = existingItem.copyWith(
          quantity: existingItem.quantity + quantity,
        );
      } else {
        // Ajouter un nouvel article au panier
        _cartItems.add(CartItem(
          product: product,
          quantity: quantity,
          unitPrice: widget.invoiceType == InvoiceType.sale
              ? product.sellingPrice
              : product.purchasePrice,
        ));
      }
      
      // Réinitialiser les champs
      _barcodeController.clear();
      _quantityController.text = '1';
      _barcodeFocusNode.requestFocus();
    });
    
    // Jouer un son de confirmation
    SoundService.playScanSound();
  }

  /// Ajoute un produit au panier avec une quantité spécifique
  void _addProductToCartWithQuantity(ProductModel product, double quantity) {
    // Vérifier si le produit est déjà dans le panier
    final existingItemIndex = _cartItems.indexWhere((item) => item.product.id == product.id);
    
    setState(() {
      if (existingItemIndex >= 0) {
        // Mettre à jour la quantité si le produit existe déjà
        final existingItem = _cartItems[existingItemIndex];
        _cartItems[existingItemIndex] = existingItem.copyWith(
          quantity: existingItem.quantity + quantity,
        );
      } else {
        // Ajouter un nouvel article au panier
        _cartItems.add(CartItem(
          product: product,
          quantity: quantity,
          unitPrice: widget.invoiceType == InvoiceType.sale
              ? product.sellingPrice
              : product.purchasePrice,
        ));
      }
    });
    
    // Jouer un son de confirmation
    SoundService.playScanSound();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.invoiceType == InvoiceType.sale
            ? l10n.posSaleTitle
            : l10n.posPurchaseTitle),
        backgroundColor:
            widget.invoiceType == InvoiceType.sale ? Colors.green : Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (_cartItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: _clearCart,
              tooltip: l10n.clearCart,
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: LoadingOverlay(
            isLoading: _isProcessing,
            child: Column(
              children: [
                // Section de scan et saisie
                _buildScanSection(),

                // Liste des articles avec hauteur fixe
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.35,
                  child: _buildCartList(),
                ),

                // Section totaux et paiement
                _buildTotalSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScanSection() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Sélection du client (pour les ventes)
          if (widget.invoiceType == InvoiceType.sale) _buildClientSelection(),

          // Sélection du fournisseur (pour les achats)
          if (widget.invoiceType == InvoiceType.purchase)
            _buildSupplierSelection(),

          const SizedBox(height: 12),

          // Champ code-barres et boutons
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Champ code-barres sur toute la largeur
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
              // Ligne pour quantité et bouton scanner
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        labelText: l10n.quantityShort,
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        // Autoriser chiffres, points et virgules pour saisir des quantités décimales
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _toggleScanner,
                    icon: Icon(_isScanning ? Icons.close : Icons.qr_code_scanner),
                    tooltip:
                        _isScanning ? l10n.closeScannerTooltip : l10n.scannerTooltip,
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: () => _showProductsGrid(),
                    icon: const Icon(Icons.grid_view),
                    tooltip: 'Afficher les produits',
                  ),
                ],
              ),
            ],
          ),

          // Scanner de codes-barres
          if (_isScanning)
            Container(
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
            ),
        ],
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

  // Ouvrir une feuille modale pour rechercher des clients par nom
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

  Widget _buildSupplierSelection() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        // Option fournisseur anonyme
        CheckboxListTile(
          title: Text(l10n.anonymousSupplier),
          value: _isAnonymousSupplier,
          onChanged: (value) {
            setState(() {
              _isAnonymousSupplier = value ?? false;
              if (_isAnonymousSupplier) {
                _selectedSupplier = null;
              }
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
        ),

        // Sélection du fournisseur
        if (!_isAnonymousSupplier)
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<SupplierModel>(
                  value: _selectedSupplier,
                  decoration: InputDecoration(
                    labelText: l10n.supplierLabel,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.business),
                  ),
                  items: _suppliers
                      .map((supplier) => DropdownMenuItem(
                            value: supplier,
                            child: Text(supplier.name),
                          ))
                      .toList(),
                  onChanged: (supplier) {
                    setState(() {
                      _selectedSupplier = supplier;
                    });
                  },
                  validator: (value) {
                    if (!_isAnonymousSupplier && value == null) {
                      return l10n.selectSupplierError;
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.search),
                tooltip: l10n.searchByName,
                onPressed: () => _openSupplierSearch(),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.business_center),
                tooltip: l10n.addSupplier,
                onPressed: () => context.goToAddSupplier(),
              ),
            ],
          ),
      ],
    );
  }

  
  void _openSupplierSearch() {
    final l10n = AppLocalizations.of(context)!;
    List<SupplierModel> filteredSuppliers = List.from(_suppliers);

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
                        filteredSuppliers = _suppliers
                            .where((s) => s.name.toLowerCase().contains(query))
                            .toList();
                      });
                    },
                    onClear: () {
                      setStateModal(() {
                        filteredSuppliers = List.from(_suppliers);
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 300,
                    child: filteredSuppliers.isEmpty
                        ? Center(
                            child: Text(l10n.noResults),
                          )
                        : ListView.builder(
                            itemCount: filteredSuppliers.length,
                            itemBuilder: (context, index) {
                              final supplier = filteredSuppliers[index];
                              return ListTile(
                                title: Text(supplier.name),
                                onTap: () {
                                  setState(() {
                                    _selectedSupplier = supplier;
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

  Widget _buildCartList() {
    final l10n = AppLocalizations.of(context)!;
    if (_cartItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.emptyCartTitle,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.emptyCartSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _cartItems.length,
      itemBuilder: (context, index) {
        final item = _cartItems[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
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
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                          if (item.product.barcode?.isNotEmpty == true)
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
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _showDeleteConfirmation(index),
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Quantité: ${item.quantity.toStringAsFixed(2)}'),
                          Text('Prix unitaire: ${item.unitPrice.toStringAsFixed(2)} DH'),
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
                                onPressed: () => _updateQuantity(index, -1),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                            SizedBox(
                              width: 36,
                              height: 36,
                              child: IconButton(
                                icon: const Icon(Icons.add, size: 18),
                                onPressed: () => _updateQuantity(index, 1),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () => _editPrice(index),
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
    );
  }

  Widget _buildTotalSection() {
    final l10n = AppLocalizations.of(context)!;
    // Ajouter un padding inférieur en fonction de la hauteur du clavier pour éviter les débordements
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    // Ajouter un espace supplémentaire lorsque le clavier est visible pour éviter
    // que la zone de saisie et le total ne soient masqués par le clavier.
    final extraPadding = bottomInset > 0 ? 32.0 : 0.0;
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + bottomInset + extraPadding,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Totaux
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.subtotal + ':', style: const TextStyle(fontSize: 16)),
              Text(
                '${_subtotal.toStringAsFixed(2)} DH',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          if (_taxAmount > 0) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.tax + ':', style: const TextStyle(fontSize: 16)),
                Text(
                  '${_taxAmount.toStringAsFixed(2)} DH',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.total + ':',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                '${_totalAmount.toStringAsFixed(2)} DH',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Saisie du montant payé
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _paidAmountController,
                  decoration: InputDecoration(
                    labelText: l10n.amountPaid,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.payments),
                    suffixText: 'DH',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 16),

              // Affichage de la monnaie
              if (_paidAmount > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _changeAmount >= 0
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _changeAmount >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _changeAmount >= 0 ? l10n.changeLabelPositive : l10n.changeLabelNegative,
                        style: TextStyle(
                          fontSize: 12,
                          color: _changeAmount >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                      Text(
                        '${_changeAmount.abs().toStringAsFixed(2)} DH',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _changeAmount >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Boutons d'action
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _cartItems.isEmpty ? null : _processInvoice,
                  icon: const Icon(Icons.receipt_long),
              label: Text(widget.invoiceType == InvoiceType.sale
                      ? l10n.finalizeSale
                      : l10n.finalizePurchase),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.invoiceType == InvoiceType.sale
                        ? Colors.green
                        : Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Méthodes pour la gestion du scanner et des produits
  void _toggleScanner() {
    setState(() {
      _isScanning = !_isScanning;
      if (_isScanning) {
        _scannerController = MobileScannerController();
      } else {
        _scannerController?.dispose();
        _scannerController = null;
      }
    });
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final barcode = barcodes.first.rawValue;
      if (barcode != null) {
        // Jouer le son de scan selon les paramètres utilisateur
        final settings = context.read<SettingsProvider>();
        SoundService.playSound(settings.scanSound);

        _barcodeController.text = barcode;
        _addProductByBarcode(barcode);
        _toggleScanner(); // Fermer le scanner après scan
      }
    }
  }

  void _addProductByBarcode(String barcode) async {
    // Ne rien faire si le code-barres est vide
    if (barcode.isEmpty) return;

    final l10n = AppLocalizations.of(context)!;
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Vérifier que l'utilisateur est connecté
    if (authProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur: Utilisateur non connecté')),
      );
      return;
    }
    
    // Charger uniquement les produits de l'utilisateur connecté
    await productProvider.loadUserProducts(authProvider.currentUser!.id);

    // Rechercher le produit correspondant. Utiliser un try/catch pour éviter
    // l'exception lorsqu'aucun produit n'est trouvé.
    ProductModel? product;
    try {
      product = productProvider.products
          .firstWhere((p) => p.barcode == barcode);
    } catch (_) {
      product = null;
    }

    // Si aucun produit n'est trouvé ou que son id est vide, afficher un message et
    // rediriger vers l'ajout de produit. À la différence de la navigation
    // précédente, on utilise context.push() pour conserver l'historique afin
    // de revenir sur l'écran actuel avec un résultat.
    if (product == null || product.id.isEmpty) {
      _showErrorSnackBar('${l10n.productNotFound}');
      // Stocker le code-barres manquant pour pouvoir l'ajouter après création
      _pendingBarcode = barcode;
      
      // Demander à l'utilisateur s'il souhaite ajouter le produit
      bool? shouldAddProduct = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.productNotFound),
          content: Text(l10n.addProductWithBarcodeQuestion),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.addProduct),
            ),
          ],
        ),
      );
      
      if (shouldAddProduct != true) {
        // L'utilisateur a annulé, nettoyer l'état et les champs
        _pendingBarcode = null;
        _barcodeController.clear();
        _quantityController.text = '1';
        _barcodeFocusNode.requestFocus();
        return;
      }
      
      // Pousser la route d'ajout de produit et attendre la valeur retournée
      final result = await context.push('/products/add');
      // Si le produit a bien été créé (AddEditProduct renvoie true), essayer de
      // l'ajouter automatiquement au panier
      if (result == true && _pendingBarcode != null) {
        final updatedProductProvider =
            Provider.of<ProductProvider>(context, listen: false);
        ProductModel? createdProduct;
        try {
          createdProduct = updatedProductProvider.products
              .firstWhere((p) => p.barcode == _pendingBarcode);
        } catch (_) {
          createdProduct = null;
        }
        if (createdProduct != null && createdProduct.id.isNotEmpty) {
          final qty = double.tryParse(_quantityController.text) ?? 1.0;
          _addToCart(createdProduct, qty);
        }
      }
      // Nettoyer l'état et les champs après tentative d'ajout
      _pendingBarcode = null;
      _barcodeController.clear();
      _quantityController.text = '1';
      _barcodeFocusNode.requestFocus();
      return;
    }

    // Si un produit est trouvé, l'ajouter au panier
    final quantity = double.tryParse(_quantityController.text) ?? 1.0;
    _addToCart(product, quantity);

    // Réinitialiser les champs pour la prochaine saisie
    _barcodeController.clear();
    _quantityController.text = '1';
    _barcodeFocusNode.requestFocus();
  }

  void _addToCart(ProductModel product, double quantity) {
    setState(() {
      // Vérifier si le produit est déjà dans le panier
      final existingIndex =
          _cartItems.indexWhere((item) => item.product.id == product.id);

      if (existingIndex != -1) {
        // Mettre à jour la quantité
        _cartItems[existingIndex] = _cartItems[existingIndex].copyWith(
          quantity: _cartItems[existingIndex].quantity + quantity,
        );
      } else {
        // Ajouter un nouvel article
        _cartItems.add(CartItem(
          product: product,
          quantity: quantity,
          unitPrice: widget.invoiceType == InvoiceType.sale
              ? product.sellingPrice
              : product.purchasePrice,
        ));
      }
    });
  }

  void _removeFromCart(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });
  }

  void _showDeleteConfirmation(int index) {
    final item = _cartItems[index];
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.delete),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Êtes-vous sûr de vouloir supprimer ce produit du panier ?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
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
                  const SizedBox(height: 4),
                  Text(
                    'Quantité: ${item.quantity}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Prix total: ${item.totalPrice.toStringAsFixed(2)} DH',
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
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              _removeFromCart(index);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${item.product.name} supprimé du panier'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  void _updateQuantity(int index, int delta) {
    setState(() {
      final newQuantity = _cartItems[index].quantity + delta;
      if (newQuantity > 0) {
        _cartItems[index] = _cartItems[index].copyWith(quantity: newQuantity);
      }
    });
  }

  void _editPrice(int index) {
    final item = _cartItems[index];
    final priceController = TextEditingController(text: item.unitPrice.toStringAsFixed(2));
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.attach_money, color: Colors.green),
              const SizedBox(width: 8),
              Text(l10n.modifyPrice),
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
                            'Quantité: ${item.quantity}',
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Prix actuel:',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${item.unitPrice.toStringAsFixed(2)} DH',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Nouveau prix unitaire',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.attach_money),
                  suffixText: 'DH',
                  helperText: 'Prix minimum: 0.00 DH',
                ),
                autofocus: true,
                onChanged: (value) {
                  setDialogState(() {}); // Refresh dialog to update total
                },
                onSubmitted: (value) {
                  final newPrice = double.tryParse(value);
                  if (newPrice != null && newPrice >= 0) {
                    setState(() {
                      _cartItems[index] = item.copyWith(unitPrice: newPrice);
                    });
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Prix de ${item.product.name} modifié: ${newPrice.toStringAsFixed(2)} DH'),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Veuillez saisir un prix valide'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Nouveau total:',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${((double.tryParse(priceController.text) ?? 0) * item.quantity).toStringAsFixed(2)} DH',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.orange,
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
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final newPrice = double.tryParse(priceController.text);
                if (newPrice != null && newPrice >= 0) {
                  setState(() {
                    _cartItems[index] = item.copyWith(unitPrice: newPrice);
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Prix de ${item.product.name} modifié: ${newPrice.toStringAsFixed(2)} DH'),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Veuillez saisir un prix valide'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.modify),
            ),
          ],
        ),
      ),
    );
  }

  void _clearCart() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearCart),
        content: Text(l10n.clearCartConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _cartItems.clear();
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.clear),
          ),
        ],
      ),
    );
  }

  void _processInvoice() async {
    final l10n = AppLocalizations.of(context)!;
    print(
        '🎯 POS: _processInvoice appelée - Items dans le panier: ${_cartItems.length}');

    if (_cartItems.isEmpty) {
      print('⚠️ POS: Panier vide, arrêt du traitement');
      return;
    }

    // Vérifier le paiement pour les ventes
    if (widget.invoiceType == InvoiceType.sale && _paidAmount < _totalAmount) {
      // Gérer le crédit client
      if (_selectedClient == null) {
        _showErrorSnackBar(l10n.partialPaymentError);
        return;
      }

      final remainingAmount = _totalAmount - _paidAmount;
      if (!_selectedClient!.canPurchase(remainingAmount)) {
        _showErrorSnackBar(l10n.creditLimitExceeded);
        return;
      }
    }

    // Pour les achats, afficher un dialog pour ajouter une image
    if (widget.invoiceType == InvoiceType.purchase) {
      final shouldContinue = await _showPurchaseConfirmationDialog();
      if (!shouldContinue) return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final invoiceProvider =
          Provider.of<InvoiceProvider>(context, listen: false);

      // Générer un numéro de facture
      final invoiceNumber = _generateInvoiceNumber();

      // Sauvegarder l'image de facture si elle existe (pour les achats)
      String? savedImagePath;
      if (widget.invoiceType == InvoiceType.purchase && _selectedInvoiceImage != null) {
        // Générer un ID temporaire pour la facture pour nommer l'image
        final tempInvoiceId = DateTime.now().millisecondsSinceEpoch.toString();
        savedImagePath = await LocalImageService.saveInvoiceImage(_selectedInvoiceImage!, tempInvoiceId);
        print('📸 Image de facture sauvegardée: $savedImagePath');
      }

      // Créer la facture
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id ?? '';
      
      final invoice = InvoiceModel(
        id: '',
        userId: userId,
        clientId:
            widget.invoiceType == InvoiceType.sale ? _selectedClient?.id : null,
        supplierId:
            widget.invoiceType == InvoiceType.purchase && !_isAnonymousSupplier
                ? _selectedSupplier?.id
                : null,
        invoiceNumber: invoiceNumber,
        type: widget.invoiceType,
        invoiceDate: DateTime.now(),
        dueDate: null,
        subtotal: _subtotal,
        taxAmount: _taxAmount,
        discountAmount: 0.0,
        totalAmount: _totalAmount,
        paidAmount: _paidAmount,
        status: _paidAmount >= _totalAmount
            ? InvoiceStatus.paid
            : InvoiceStatus.validated,
        notes: null,
        imagePath: savedImagePath, // Ajouter le chemin de l'image
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        client: widget.invoiceType == InvoiceType.sale ? _selectedClient : null,
        supplier:
            widget.invoiceType == InvoiceType.purchase && !_isAnonymousSupplier
                ? _selectedSupplier
                : null,
      );

      // Créer les articles de la facture
      final items = _cartItems
          .map((cartItem) => InvoiceItemModel(
                id: '',
                invoiceId: '',
                productId: cartItem.product.id,
                quantity: cartItem.quantity,
                unitPrice: cartItem.unitPrice,
                totalPrice: cartItem.totalPrice,
                createdAt: DateTime.now(),
                product: cartItem.product,
              ))
          .toList();

      // Sauvegarder la facture
      print(
          '🎯 POS: Appel de invoiceProvider.createInvoice avec ${items.length} items');
      final success = await invoiceProvider.createInvoice(invoice, items);
      print('🎯 POS: Résultat de createInvoice: $success');

      if (success) {
        // Le crédit sera automatiquement créé par InvoiceService.markAsPaid()
        // si c'est un paiement partiel - pas besoin de le faire ici
        print('✅ Facture créée avec succès');

        // Récupérer la facture créée avec son ID pour l'impression
        final createdInvoices = invoiceProvider.invoices
            .where((inv) => inv.invoiceNumber == invoiceNumber)
            .toList();
        if (createdInvoices.isNotEmpty) {
          _lastCreatedInvoice = createdInvoices.first;
        }

        _showSuccessDialog();
      } else {
        _showErrorSnackBar(l10n.invoiceCreationError);
      }
    } catch (e) {
      _showErrorSnackBar('${l10n.genericErrorPrefix} $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  String _generateInvoiceNumber() {
    final now = DateTime.now();
    final prefix = widget.invoiceType == InvoiceType.sale ? 'VTE' : 'ACH';
    return '$prefix${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(8)}';
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 32,
            ),
            const SizedBox(width: 12),
            Text(widget.invoiceType == InvoiceType.sale
                ? l10n.saleSuccess
                : l10n.purchaseSuccess),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${l10n.invoiceTotalLabel}: ${_totalAmount.toStringAsFixed(2)} DH'),
            Text('${l10n.invoicePaidLabel}: ${_paidAmount.toStringAsFixed(2)} DH'),
            if (_changeAmount > 0)
              Text(
                '${l10n.invoiceChangeToReturnLabel}: ${_changeAmount.toStringAsFixed(2)} DH',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            if (_changeAmount < 0)
              Text(
                '${l10n.creditAddedLabel}: ${_changeAmount.abs().toStringAsFixed(2)} DH',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
          ],
        ),
        actions: [
          if (_lastCreatedInvoice != null)
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  await _printService.printInvoice(context, _lastCreatedInvoice!);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Facture imprimée avec succès'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur lors de l\'impression: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              icon: Icon(Icons.print),
              label: Text('Imprimer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Fermer le dialog
              _resetForm();
            },
            child: Text(l10n.newTransaction),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Fermer le dialog
              context.pop(); // Retourner à l'écran précédent
            },
            child: Text(l10n.finish),
          ),
        ]
      ),
    );
  }

  void _resetForm() {
    setState(() {
      _cartItems.clear();
      _selectedClient = null;
      _paidAmountController.clear();
      _barcodeController.clear();
      _quantityController.text = '1';
      _lastCreatedInvoice = null;
      _selectedInvoiceImage = null; // Réinitialiser l'image
    });
    _barcodeFocusNode.requestFocus();
  }

  Future<bool> _showPurchaseConfirmationDialog() async {
    File? tempImage = _selectedInvoiceImage;

    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(l10n.finalizePurchase),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l10n.totalAmountLabel}: ${_totalAmount.toStringAsFixed(2)} DH',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    InvoiceImagePicker(
                      initialImage: tempImage,
                      onImageSelected: (File? image) {
                        setDialogState(() {
                          tempImage = image;
                        });
                      },
                      title: l10n.invoiceImageOptional,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(l10n.cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedInvoiceImage = tempImage;
                    });
                    Navigator.of(context).pop(true);
                  },
                  child: Text(l10n.confirm),
                ),
              ],
            );
          },
        );
      },
    );

    return result ?? false;
  }

  /// Navigue vers l'écran d'ajout de produit
  void _navigateToAddProduct() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditProductScreen(),
      ),
    );

    // Si un produit a été ajouté avec succès, recharger les produits de l'utilisateur
    if (result == true) {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      if (authProvider.currentUser != null) {
        await productProvider.loadUserProducts(authProvider.currentUser!.id);
      }
    }
  }
}

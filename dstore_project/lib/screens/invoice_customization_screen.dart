import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/invoice_customization_model.dart';
import '../models/invoice_model.dart';
import '../models/client_model.dart';
import '../models/product_model.dart';
import '../services/invoice_customization_service.dart';
import '../providers/auth_provider.dart';
import '../widgets/common/custom_text_field.dart';
import '../widgets/common/loading_overlay.dart';

class InvoiceCustomizationScreen extends StatefulWidget {
  const InvoiceCustomizationScreen({Key? key}) : super(key: key);

  @override
  State<InvoiceCustomizationScreen> createState() => _InvoiceCustomizationScreenState();
}

class _InvoiceCustomizationScreenState extends State<InvoiceCustomizationScreen> {
  final InvoiceCustomizationService _customizationService = InvoiceCustomizationService();
  final ImagePicker _imagePicker = ImagePicker();
  
  // Controllers pour les champs de texte
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _companyAddressController = TextEditingController();
  final TextEditingController _companyPhoneController = TextEditingController();
  final TextEditingController _companyEmailController = TextEditingController();
  final TextEditingController _companyWebsiteController = TextEditingController();
  final TextEditingController _headerTextController = TextEditingController();
  final TextEditingController _footerTextController = TextEditingController();
  
  InvoiceCustomizationModel? _customization;
  bool _isLoading = false;
  String? _logoPath;
  
  // Variables pour l'aperçu
  bool _showPreview = false;
  InvoiceModel? _sampleInvoice;

  @override
  void initState() {
    super.initState();
    _loadCustomization();
    _createSampleInvoice();
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _companyAddressController.dispose();
    _companyPhoneController.dispose();
    _companyEmailController.dispose();
    _companyWebsiteController.dispose();
    _headerTextController.dispose();
    _footerTextController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomization() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id ?? '';
      
      _customization = await _customizationService.loadCustomization(userId);
      
      // Si aucune personnalisation n'existe, créer une par défaut
      if (_customization == null) {
        _customization = InvoiceCustomizationModel.createDefault(userId);
      }
      
      _updateControllers();
    } catch (e) {
      _showErrorSnackBar('Erreur lors du chargement: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _updateControllers() {
    if (_customization != null) {
      _companyNameController.text = _customization!.companyName;
      _companyAddressController.text = _customization!.companyAddress ?? '';
      _companyPhoneController.text = _customization!.companyPhone ?? '';
      _companyEmailController.text = _customization!.companyEmail ?? '';
      _companyWebsiteController.text = _customization!.companyWebsite ?? '';
      _headerTextController.text = _customization!.headerText ?? '';
      _footerTextController.text = _customization!.footerText ?? '';
      _logoPath = _customization!.logoPath;
      
      // Initialiser les variables d'état avec les valeurs chargées
      _primaryColor = Color(int.parse(_customization!.primaryColor.replaceFirst('#', '0xFF')));
      _secondaryColor = Color(int.parse(_customization!.secondaryColor.replaceFirst('#', '0xFF')));
      _fontSize = _customization!.fontSize;
      _showLogo = _customization!.showLogo;
      _showCompanyInfo = _customization!.showCompanyInfo;
      _showHeader = _customization!.showHeader;
      _showFooter = _customization!.showFooter;
    }
  }

  void _createSampleInvoice() {
    // Créer une facture d'exemple pour l'aperçu
    _sampleInvoice = InvoiceModel(
      id: 'sample',
      userId: 'sample',
      invoiceNumber: 'VTE-202401-0001',
      type: InvoiceType.sale,
      invoiceDate: DateTime.now(),
      subtotal: 1000.0,
      taxAmount: 200.0,
      discountAmount: 0.0,
      totalAmount: 1200.0,
      paidAmount: 1200.0,
      status: InvoiceStatus.paid,
      notes: 'Facture d\'exemple pour l\'aperçu',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      client: ClientModel(
        id: 'sample',
        userId: 'sample',
        name: 'Client Exemple',
        email: 'client@exemple.com',
        phone: '+212 6XX XXX XXX',
        address: 'Adresse du client',
        city: 'Casablanca',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      items: [
        InvoiceItemModel(
          id: 'item1',
          invoiceId: 'sample',
          productId: 'product1',
          quantity: 2,
          unitPrice: 500.0,
          totalPrice: 1000.0,
          createdAt: DateTime.now(),
          product: ProductModel(
            id: 'product1',
            userId: 'sample',
            name: 'Produit Exemple',
            description: 'Description du produit',
            sellingPrice: 500.0,
            purchasePrice: 300.0,
            stock: 10,
            minStock: 5,
            barcode: '1234567890',
            category: 'Catégorie',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ),
      ],
    );
  }

  Future<void> _pickLogo() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _logoPath = image.path;
        });
        _updateCustomization();
      }
    } catch (e) {
      _showErrorSnackBar(AppLocalizations.of(context)!.logoPickError.replaceFirst('{error}', e.toString()));
    }
  }

  void _updateCustomization() {
    if (_customization != null) {
      setState(() {
        _customization = _customization!.copyWith(
          companyName: _companyNameController.text,
          companyAddress: _companyAddressController.text.isEmpty ? null : _companyAddressController.text,
          companyPhone: _companyPhoneController.text.isEmpty ? null : _companyPhoneController.text,
          companyEmail: _companyEmailController.text.isEmpty ? null : _companyEmailController.text,
          companyWebsite: _companyWebsiteController.text.isEmpty ? null : _companyWebsiteController.text,
          headerText: _headerTextController.text.isEmpty ? null : _headerTextController.text,
          footerText: _footerTextController.text.isEmpty ? null : _footerTextController.text,
          logoPath: _logoPath,
          primaryColor: '#${_primaryColor.value.toRadixString(16).substring(2).toUpperCase()}',
          secondaryColor: '#${_secondaryColor.value.toRadixString(16).substring(2).toUpperCase()}',
          fontSize: _fontSize,
          showLogo: _showLogo,
          showCompanyInfo: _showCompanyInfo,
          showHeader: _showHeader,
          showFooter: _showFooter,
          updatedAt: DateTime.now(),
        );
      });
    }
  }

  Future<void> _saveCustomization() async {
    if (_customization == null) return;
    
    setState(() => _isLoading = true);
    try {
      _updateCustomization();
      
      if (!_customizationService.validateCustomization(_customization!)) {
        _showErrorSnackBar('Veuillez vérifier les informations saisies');
        return;
      }
      
      await _customizationService.saveCustomization(_customization!);
      _showSuccessSnackBar('Personnalisation sauvegardée avec succès');
    } catch (e) {
      _showErrorSnackBar('Erreur lors de la sauvegarde: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resetToDefault() async {
    final confirmed = await _showConfirmDialog(
      'Réinitialiser',
      'Êtes-vous sûr de vouloir réinitialiser la personnalisation aux valeurs par défaut ?',
    );
    
    if (confirmed) {
      setState(() => _isLoading = true);
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final userId = authProvider.currentUser?.id ?? '';
        
        _customization = await _customizationService.resetToDefault(userId);
        _updateControllers();
        _showSuccessSnackBar('Personnalisation réinitialisée');
      } catch (e) {
        _showErrorSnackBar('Erreur lors de la réinitialisation: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _previewPDF() async {
    if (_customization == null || _sampleInvoice == null) return;
    
    try {
      final pdf = await _generateCustomPDF(_sampleInvoice!, _customization!);
      await Printing.layoutPdf(
        onLayout: (format) async => pdf,
        name: 'Apercu_Facture_Personnalisee.pdf',
      );
    } catch (e) {
      _showErrorSnackBar('Erreur lors de la génération de l\'aperçu: $e');
    }
  }

  Future<Uint8List> _generateCustomPDF(InvoiceModel invoice, InvoiceCustomizationModel customization) async {
    final pdf = pw.Document();
    
    // Convertir les couleurs hex en PdfColor
    final primaryColor = PdfColor.fromHex(customization.primaryColor);
    final secondaryColor = PdfColor.fromHex(customization.secondaryColor);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // En-tête personnalisé
              if (customization.showHeader && customization.headerText != null) ..[
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: primaryColor,
                  ),
                  child: pw.Text(
                    customization.headerText!,
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: customization.fontSize + 2,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.SizedBox(height: 20),
              ],
              
              // Logo et informations de l'entreprise
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Informations de l'entreprise
                  if (customization.showCompanyInfo)
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          customization.companyName,
                          style: pw.TextStyle(
                            fontSize: customization.fontSize + 4,
                            fontWeight: pw.FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        if (customization.companyAddress != null) ..[
                          pw.SizedBox(height: 5),
                          pw.Text(
                            customization.companyAddress!,
                            style: pw.TextStyle(fontSize: customization.fontSize),
                          ),
                        ],
                        if (customization.companyPhone != null) ..[
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'Tél: ${customization.companyPhone!}',
                            style: pw.TextStyle(fontSize: customization.fontSize),
                          ),
                        ],
                        if (customization.companyEmail != null) ..[
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'Email: ${customization.companyEmail!}',
                            style: pw.TextStyle(fontSize: customization.fontSize),
                          ),
                        ],
                        if (customization.companyWebsite != null) ..[
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'Web: ${customization.companyWebsite!}',
                            style: pw.TextStyle(fontSize: customization.fontSize),
                          ),
                        ],
                      ],
                    ),
                  
                  // Informations de la facture
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        invoice.type == InvoiceType.sale ? 'FACTURE DE VENTE' : 'BON D\'ACHAT',
                        style: pw.TextStyle(
                          fontSize: customization.fontSize + 6,
                          fontWeight: pw.FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        'N° ${invoice.invoiceNumber}',
                        style: pw.TextStyle(
                          fontSize: customization.fontSize + 2,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        'Date: ${_formatDate(invoice.invoiceDate)}',
                        style: pw.TextStyle(fontSize: customization.fontSize),
                      ),
                    ],
                  ),
                ],
              ),
              
              pw.SizedBox(height: 30),
              
              // Informations client
              if (invoice.client != null) ..[
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: primaryColor),
                    borderRadius: pw.BorderRadius.circular(5),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'FACTURÉ À:',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: customization.fontSize,
                          color: primaryColor,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        invoice.client!.name,
                        style: pw.TextStyle(
                          fontSize: customization.fontSize + 1,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      if (invoice.client!.email != null)
                        pw.Text(
                          invoice.client!.email!,
                          style: pw.TextStyle(fontSize: customization.fontSize),
                        ),
                      if (invoice.client!.phone != null)
                        pw.Text(
                          invoice.client!.phone!,
                          style: pw.TextStyle(fontSize: customization.fontSize),
                        ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
              ],
              
              // Tableau des articles
              if ((invoice.items ?? '').isNotEmpty) ..[
                pw.Table(
                  border: pw.TableBorder.all(color: primaryColor),
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: primaryColor),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Article',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: customization.fontSize,
                              color: PdfColors.white,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Qté',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: customization.fontSize,
                              color: PdfColors.white,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Prix U.',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: customization.fontSize,
                              color: PdfColors.white,
                            ),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Total',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: customization.fontSize,
                              color: PdfColors.white,
                            ),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    ...invoice.items!.map((item) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            item.product?.name ?? 'Produit inconnu',
                            style: pw.TextStyle(fontSize: customization.fontSize),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            '${item.quantity}',
                            style: pw.TextStyle(fontSize: customization.fontSize),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            '${item.unitPrice.toStringAsFixed(2)} DH',
                            style: pw.TextStyle(fontSize: customization.fontSize),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            '${item.totalPrice.toStringAsFixed(2)} DH',
                            style: pw.TextStyle(fontSize: customization.fontSize),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    )),
                  ],
                ),
                pw.SizedBox(height: 20),
              ],
              
              // Résumé des totaux
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Container(
                  width: 250,
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: primaryColor),
                    borderRadius: pw.BorderRadius.circular(5),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Sous-total:',
                            style: pw.TextStyle(fontSize: customization.fontSize),
                          ),
                          pw.Text(
                            '${invoice.subtotal.toStringAsFixed(2)} DH',
                            style: pw.TextStyle(fontSize: customization.fontSize),
                          ),
                        ],
                      ),
                      if (invoice.taxAmount > 0) ..[
                        pw.SizedBox(height: 5),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              'TVA:',
                              style: pw.TextStyle(fontSize: customization.fontSize),
                            ),
                            pw.Text(
                              '${invoice.taxAmount.toStringAsFixed(2)} DH',
                              style: pw.TextStyle(fontSize: customization.fontSize),
                            ),
                          ],
                        ),
                      ],
                      pw.Divider(color: primaryColor),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'TOTAL:',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: customization.fontSize + 2,
                              color: primaryColor,
                            ),
                          ),
                          pw.Text(
                            '${invoice.totalAmount.toStringAsFixed(2)} DH',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: customization.fontSize + 2,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              pw.Spacer(),
              
              // Pied de page personnalisé
              if (customization.showFooter && customization.footerText != null) ..[
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: secondaryColor,
                  ),
                  child: pw.Text(
                    customization.footerText!,
                    style: pw.TextStyle(
                      fontSize: customization.fontSize,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<bool> _showConfirmDialog(String title, String content) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Confirmer'),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.invoiceCustomizationTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.preview),
            onPressed: _previewPDF,
            tooltip: AppLocalizations.of(context)!.pdfPreview,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetToDefault,
            tooltip: 'Réinitialiser',
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: _customization == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Informations de l'entreprise
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.companyInfoSectionTitle,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 16),
                            
                            // Logo
                            Row(
                              children: [
                                if (_logoPath != null)
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Image.file(
                                      File(_logoPath!),
                                      fit: BoxFit.contain,
                                    ),
                                  )
                                else
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.business,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  ),
                                const SizedBox(width: 16),
                                Column(
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: _pickLogo,
                                      icon: const Icon(Icons.upload),
                                      label: Text(AppLocalizations.of(context)!.chooseLogoShort),
                                    ),
                                    if (_logoPath != null)
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            _logoPath = null;
                                          });
                                          _updateCustomization();
                                        },
                                        child: Text(AppLocalizations.of(context)!.delete),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            CustomTextField(
                              controller: _companyNameController,
                              label: AppLocalizations.of(context)!.companyNameLabel + ' *',
                              onChanged: (_) => _updateCustomization(),
                            ),
                            const SizedBox(height: 12),
                            
                            CustomTextField(
                              controller: _companyAddressController,
                              label: AppLocalizations.of(context)!.addressLabel,
                              maxLines: 2,
                              onChanged: (_) => _updateCustomization(),
                            ),
                            const SizedBox(height: 12),
                            
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    controller: _companyPhoneController,
                                    label: AppLocalizations.of(context)!.phoneLabel,
                                    onChanged: (_) => _updateCustomization(),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: CustomTextField(
                                    controller: _companyEmailController,
                                    label: AppLocalizations.of(context)!.emailLabel,
                                    onChanged: (_) => _updateCustomization(),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            
                            CustomTextField(
                              controller: _companyWebsiteController,
                              label: AppLocalizations.of(context)!.websiteLabel,
                              onChanged: (_) => _updateCustomization(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Section En-tête et pied de page
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.headerFooterSectionTitle,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 16),
                            
                            SwitchListTile(
                              title: Text(AppLocalizations.of(context)!.showCustomHeader),
                              value: _customization!.showHeader,
                              onChanged: (value) {
                                setState(() {
                                  _customization = _customization!.copyWith(showHeader: value);
                                });
                              },
                            ),
                            
                            if (_customization!.showHeader) ..[
                              const SizedBox(height: 12),
                              CustomTextField(
                                controller: _headerTextController,
                                label: AppLocalizations.of(context)!.headerTextLabel,
                                maxLines: 2,
                                onChanged: (_) => _updateCustomization(),
                              ),
                            ],
                            
                            const SizedBox(height: 16),
                            
                            SwitchListTile(
                              title: Text(AppLocalizations.of(context)!.showCustomFooter),
                              value: _customization!.showFooter,
                              onChanged: (value) {
                                setState(() {
                                  _customization = _customization!.copyWith(showFooter: value);
                                });
                              },
                            ),
                            
                            if (_customization!.showFooter) ..[
                              const SizedBox(height: 12),
                              CustomTextField(
                                controller: _footerTextController,
                                label: AppLocalizations.of(context)!.footerTextLabel,
                                maxLines: 2,
                                onChanged: (_) => _updateCustomization(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Section Apparence
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.appearanceSectionTitle,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 16),
                            
                            // Couleurs
                            Text(AppLocalizations.of(context)!.primaryColorLabel + ':'),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: _customizationService.getAvailableColors().map((color) {
                                final isSelected = _customization!.primaryColor == color;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _customization = _customization!.copyWith(primaryColor: color);
                                    });
                                  },
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Color(int.parse(color.substring(1), radix: 16) + 0xFF000000),
                                      border: Border.all(
                                        color: isSelected ? Colors.black : Colors.grey,
                                        width: isSelected ? 3 : 1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: isSelected
                                        ? const Icon(Icons.check, color: Colors.white)
                                        : null,
                                  ),
                                );
                              }).toList(),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Taille de police
                            Text(AppLocalizations.of(context)!.fontSizeLabel + ': ' + _customization!.fontSize.toInt().toString()),
                            Slider(
                              value: _customization!.fontSize,
                              min: 8,
                              max: 16,
                              divisions: 8,
                              onChanged: (value) {
                                setState(() {
                                  _customization = _customization!.copyWith(fontSize: value);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Boutons d'action
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _previewPDF,
                            icon: const Icon(Icons.preview),
                            label: Text('Aperçu PDF'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _saveCustomization,
                            icon: const Icon(Icons.save),
                            label: Text('Sauvegarder'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
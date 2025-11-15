import 'package:flutter/material.dart';
import '../version.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'dart:typed_data';
import '../models/invoice_model.dart';
import '../models/invoice_customization_model.dart';
import '../services/auth_service.dart';
import '../services/email_service.dart';
import '../services/invoice_customization_service.dart';
import '../widgets/local_image_widget.dart';
import '../providers/product_provider.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';

import '../config/app_theme.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';

class InvoiceDetailScreen extends StatefulWidget {
  final InvoiceModel invoice;

  const InvoiceDetailScreen({
    Key? key,
    required this.invoice,
  }) : super(key: key);

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

// Classe utilitaire pour le formatage
class _FormatUtils {
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatCurrency(double amount) {
    return '${amount.toStringAsFixed(2)} DH';
  }
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  final AuthService _authService = AuthService.instance;
  final InvoiceCustomizationService _customizationService = InvoiceCustomizationService();
  InvoiceCustomizationModel? _customization;

  @override
  void initState() {
    // ignore: avoid_print
    print('[InvoiceDetail] init '+kBuildPatch);
    super.initState();
    _loadCustomization();
  }

  Future<void> _loadCustomization() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id ?? '';
      _customization = await _customizationService.loadCustomization(userId);
      setState(() {});
    } catch (e) {
      print('Erreur lors du chargement de la personnalisation: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.invoiceNumber.replaceFirst(':', '') + ' ${widget.invoice.invoiceNumber}'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _printInvoice,
            tooltip: AppLocalizations.of(context)!.standardPdf,
          ),
          IconButton(
            icon: const Icon(Icons.receipt),
            onPressed: _printThermalInvoice,
            tooltip: AppLocalizations.of(context)!.thermalPdf,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {}, // TODO: Implémenter le partage de facture
            tooltip: AppLocalizations.of(context)!.shareInvoice,
          ),
          IconButton(
            icon: const Icon(Icons.palette),
            onPressed: () => context.go('/invoice-customization'),
            tooltip: AppLocalizations.of(context)!.customizePdf,
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'email',
                child: Row(
                  children: [
                    Icon(Icons.email),
                    SizedBox(width: 8),
                    Text('Envoyer par email'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'duplicate',
                child: Row(
                  children: [
                    Icon(Icons.copy),
                    SizedBox(width: 8),
                    Text('Dupliquer'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    // Remplacer libellé codé en dur par la traduction
                    // Utilise un Builder pour accéder au context
                    Builder(builder: (context) => Text(AppLocalizations.of(context)!.edit)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'customize',
                child: Row(
                  children: [
                    Icon(Icons.palette),
                    SizedBox(width: 8),
                    Builder(builder: (context) => Text(AppLocalizations.of(context)!.customizePdf)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInvoiceHeader(),
            const SizedBox(height: 20),
            _buildClientSupplierInfo(),
            const SizedBox(height: 20),
            _buildInvoiceItems(),
            const SizedBox(height: 20),
            _buildInvoiceSummary(),
            const SizedBox(height: 20),
            _buildPaymentInfo(),
            if (widget.invoice.notes != null &&
                (widget.invoice.notes ?? '').isNotEmpty) ...[
              const SizedBox(height: 20),
              _buildNotes(),
            ],
            if (widget.invoice.imagePath != null &&
                (widget.invoice.imagePath ?? '').isNotEmpty) ...[
              const SizedBox(height: 20),
              _buildInvoiceImage(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.invoice.type == InvoiceType.sale
                          ? AppLocalizations.of(context)!.salesInvoiceTitle
                          : AppLocalizations.of(context)!.purchaseVoucherTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.invoiceNumber + ' ${widget.invoice.invoiceNumber}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(widget.invoice.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusText(widget.invoice.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context)!.invoiceDate,
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      Text(_FormatUtils.formatDate(widget.invoice.invoiceDate)),
                    ],
                  ),
                ),
                if (widget.invoice.dueDate != null)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppLocalizations.of(context)!.dueDate,
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        Text(_FormatUtils.formatDate(widget.invoice.dueDate!)),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

    Widget _buildClientSupplierInfo() {
  final isClient = widget.invoice.type == InvoiceType.sale;
  final client = widget.invoice.client;
  final supplier = widget.invoice.supplier;

  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isClient
                ? AppLocalizations.of(context)!.clientHeader
                : AppLocalizations.of(context)!.supplierDetails,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          if (isClient && client != null) ...[
            _buildInfoRow(AppLocalizations.of(context)!.fullName, client.name ?? ''),
            if ((client.email ?? '').isNotEmpty)
              _buildInfoRow(AppLocalizations.of(context)!.emailLabel, client.email ?? ''),
            if ((client.phone ?? '').isNotEmpty)
              _buildInfoRow(AppLocalizations.of(context)!.phoneLabel, client.phone ?? ''),
          ] else if (!isClient && supplier != null) ...[
            _buildInfoRow(AppLocalizations.of(context)!.fullName, supplier.name ?? ''),
            if ((supplier.email ?? '').isNotEmpty)
              _buildInfoRow(AppLocalizations.of(context)!.emailLabel, supplier.email ?? ''),
            if ((supplier.phone ?? '').isNotEmpty)
              _buildInfoRow(AppLocalizations.of(context)!.phoneLabel, supplier.phone ?? ''),
          ] else ...[
            Text(
              isClient
                  ? AppLocalizations.of(context)!.anonymousClient
                  : AppLocalizations.of(context)!.anonymousSupplier,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    ),
  );
}

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildInvoiceItems() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.itemLabel,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            if (widget.invoice.items != null &&
                (widget.invoice.items?.isNotEmpty ?? false)) ...[
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(3),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1.5),
                  3: FlexColumnWidth(1.5),
                },
                children: [
                  TableRow(
                    decoration: const BoxDecoration(color: Colors.grey),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(AppLocalizations.of(context)!.itemLabel,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(AppLocalizations.of(context)!.quantityLabel,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(AppLocalizations.of(context)!.unitPriceLabel,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(AppLocalizations.of(context)!.totalAmount,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  ...(widget.invoice.items ?? <InvoiceItemModel>[]).map((item) => TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Builder(
                                  builder: (context) {
                                    // Afficher le nom du produit même si l'objet produit est null
                                    String name = '';
                                    if (item.product != null &&
                                        (item.product?.name ?? '').isNotEmpty) {
                                      name = item.product?.name ?? '';
                                    } else {
                                      // Rechercher le produit dans le provider par ID pour récupérer son nom
                                      try {
                                        final productProvider = Provider.of<ProductProvider>(context,
                                                listen: false);
                                        final product = productProvider.products
                                            .firstWhere((p) => p.id == item.productId);
                                        name = product.name;
                                      } catch (_) {
                                        name = 'Produit inconnu';
                                      }
                                    }
                                    return Text(
                                      name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500),
                                    );
                                  },
                                ),
                                if (item.product?.unit != null)
                                  Text(
                                    'Unité: ${item.product?.unit ?? ''}',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text('${item.quantity}'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                                _FormatUtils.formatCurrency(item.unitPrice)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              _FormatUtils.formatCurrency(item.totalPrice),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      )),
                ],
              ),
            ] else ...[
              Text(AppLocalizations.of(context)!.noDataAvailable),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.invoiceTotalLabel,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(AppLocalizations.of(context)!.subtotal, widget.invoice.subtotal),
            if (widget.invoice.discountAmount > 0)
              _buildSummaryRow(AppLocalizations.of(context)!.discountAmount, -widget.invoice.discountAmount),
            if (widget.invoice.taxAmount > 0)
              _buildSummaryRow(AppLocalizations.of(context)!.taxAmount, widget.invoice.taxAmount),
            const Divider(),
            _buildSummaryRow(
              AppLocalizations.of(context)!.invoiceTotalLabel,
              widget.invoice.totalAmount,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            _FormatUtils.formatCurrency(amount),
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? AppTheme.primaryColor : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.invoiceTotalLabel,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildPaymentRow(AppLocalizations.of(context)!.paidAmount, widget.invoice.paidAmount),
            _buildPaymentRow(AppLocalizations.of(context)!.remainingAmount, widget.invoice.remainingAmount),
            const SizedBox(height: 12),
            _buildSummaryRow(
              AppLocalizations.of(context)!.totalAmount,
              widget.invoice.totalAmount,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotes() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.paidAmount,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.invoice.notes ?? '',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return Colors.grey;
      case InvoiceStatus.validated:
        return Colors.blue;
      case InvoiceStatus.paid:
        return Colors.green;
      case InvoiceStatus.cancelled:
        return Colors.orange;
    }
  }

  String _getStatusText(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return AppLocalizations.of(context)!.filterDraft;
      case InvoiceStatus.validated:
        return ''; // filterValidated n'existe pas
      case InvoiceStatus.paid:
        return AppLocalizations.of(context)!.invoicePaidLabel;
      case InvoiceStatus.cancelled:
        return AppLocalizations.of(context)!.cancel;
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'email':
        _sendByEmail() {
          // TODO: Implémenter l'envoi par email
          print('Envoi par email non implémenté');
        }
        break;
      case 'duplicate':
        // TODO: Implémenter la duplication de facture
        print('Duplication de facture non implémentée');
        break;
      case 'edit':
        // Naviguer vers l'écran d'édition avec l'identifiant de la facture
        if (mounted) {
          // Utiliser GoRouter pour naviguer vers la page d'édition
          // en transmettant l'ID de la facture dans le chemin
          context.go('/invoices/edit/${widget.invoice.id}');
        }
        break;
      case 'customize':
        if (mounted) {
          context.go('/invoice-customization');
        }
        break;
    }
  }

  Future<void> _printInvoice() async {
    try {
      final pdf = await _generateThermalCustomPDF(widget.invoice, _customization ?? InvoiceCustomizationModel.createDefault(Provider.of<AuthProvider>(context, listen: false).currentUser?.id ?? ''));
      await Printing.layoutPdf(
        onLayout: (format) async => pdf,
        name: '${AppLocalizations.of(context)!.invoice}_${widget.invoice.invoiceNumber}.pdf',
      );
    } catch (e) {
      _showErrorSnackBar('${AppLocalizations.of(context)!.genericErrorPrefix} lors de l\'impression: $e');
    }
  }

  Future<void> _printThermalInvoice() async {
    try {
      final pdfData = await _generateThermalPDF();
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfData,
        format: PdfPageFormat.roll80,
      );
    } catch (e) {
      _showErrorSnackBar('${AppLocalizations.of(context)!.genericErrorPrefix} lors de l\'impression thermique: $e');
    }
  }

  Future<Uint8List> _generateThermalPDF() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id ?? '';
    final customization = _customization ?? InvoiceCustomizationModel.createDefault(userId);
    return await _generateThermalCustomPDF(widget.invoice, customization);
  }

  Future<Uint8List> _generateThermalCustomPDF(InvoiceModel invoice, InvoiceCustomizationModel customization) async {
    final pdf = pw.Document();
    
    // Convertir les couleurs hex en PdfColor
    final primaryColor = PdfColor.fromHex(customization.primaryColor);
    final secondaryColor = PdfColor.fromHex(customization.secondaryColor);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // En-tête personnalisé pour thermique
              if (customization.showHeader && customization.headerText != null) ...[
                pw.Text(
                  customization.headerText!,
                  style: pw.TextStyle(
                    fontSize: customization.fontSize + 2,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 10),
              ],
              
              // Informations de l'entreprise (compactes)
              if (customization.showCompanyInfo) ...[
                pw.Text(
                  customization.companyName,
                  style: pw.TextStyle(
                    fontSize: customization.fontSize + 1,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                if (customization.companyPhone != null)
                  pw.Text(
                    customization.companyPhone!,
                    style: pw.TextStyle(fontSize: customization.fontSize - 1),
                    textAlign: pw.TextAlign.center,
                  ),
                pw.SizedBox(height: 10),
              ],
              
              // Type de facture et numéro
              pw.Text(
                widget.invoice.type == InvoiceType.sale ? 'FACTURE DE VENTE' : 'BON D\'ACHAT',
                style: pw.TextStyle(
                  fontSize: customization.fontSize + 1,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
              pw.Text(
                'N° ${widget.invoice.invoiceNumber}',
                style: pw.TextStyle(
                  fontSize: customization.fontSize,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
              pw.Text(
                'Date: ${_FormatUtils.formatDate(widget.invoice.invoiceDate)}',
                style: pw.TextStyle(fontSize: customization.fontSize - 1),
                textAlign: pw.TextAlign.center,
              ),
              
              pw.SizedBox(height: 10),
              pw.Divider(),
              
              // Client/Fournisseur (compact)
              if (widget.invoice.client != null || widget.invoice.supplier != null) ...[
                pw.Text(
                  widget.invoice.type == InvoiceType.sale ? 'CLIENT:' : 'FOURNISSEUR:',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: customization.fontSize,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                if (widget.invoice.client != null)
                  pw.Text(
                    (widget.invoice.client?.name ?? ''),
                    style: pw.TextStyle(fontSize: customization.fontSize),
                    textAlign: pw.TextAlign.center,
                  ),
                if (widget.invoice.supplier != null)
                  pw.Text(
                    (widget.invoice.supplier?.name ?? ''),
                    style: pw.TextStyle(fontSize: customization.fontSize),
                    textAlign: pw.TextAlign.center,
                  ),
                pw.SizedBox(height: 10),
                pw.Divider(),
              ],
              
              // Articles (format compact)
              if (widget.invoice.items != null && (widget.invoice.items?.isNotEmpty ?? false)) ...[
                ...(widget.invoice.items ?? <InvoiceItemModel>[]).map((item) => pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      item.product?.name ?? 'Produit inconnu',
                      style: pw.TextStyle(
                        fontSize: customization.fontSize,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          '${item.quantity} x ${_FormatUtils.formatCurrency(item.unitPrice)}',
                          style: pw.TextStyle(fontSize: customization.fontSize - 1),
                        ),
                        pw.Text(
                          _FormatUtils.formatCurrency(item.totalPrice),
                          style: pw.TextStyle(
                            fontSize: customization.fontSize,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 5),
                  ],
                )),
                pw.Divider(),
              ],
              
              // Totaux (compact)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Sous-total:',
                    style: pw.TextStyle(fontSize: customization.fontSize),
                  ),
                  pw.Text(
                    _FormatUtils.formatCurrency(widget.invoice.subtotal),
                    style: pw.TextStyle(fontSize: customization.fontSize),
                  ),
                ],
              ),
              
              if (widget.invoice.discountAmount > 0)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Remise:',
                      style: pw.TextStyle(fontSize: customization.fontSize),
                    ),
                    pw.Text(
                      _FormatUtils.formatCurrency(-widget.invoice.discountAmount),
                      style: pw.TextStyle(fontSize: customization.fontSize),
                    ),
                  ],
                ),
              
              if (widget.invoice.taxAmount > 0)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'TVA:',
                      style: pw.TextStyle(fontSize: customization.fontSize),
                    ),
                    pw.Text(
                      _FormatUtils.formatCurrency(widget.invoice.taxAmount),
                      style: pw.TextStyle(fontSize: customization.fontSize),
                    ),
                  ],
                ),
              
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'TOTAL:',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: customization.fontSize + 1,
                    ),
                  ),
                  pw.Text(
                    _FormatUtils.formatCurrency(widget.invoice.totalAmount),
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: customization.fontSize,
                    ),
                  ),
                ],
              ),
              
              // Pied de page personnalisé pour thermique
              if (customization.showFooter && customization.footerText != null) ...[
                pw.SizedBox(height: 15),
                pw.Text(
                  customization.footerText!,
                  style: pw.TextStyle(
                    fontSize: customization.fontSize,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ],
              
              pw.SizedBox(height: 20),
              pw.Text(
                'Merci de votre visite!',
                style: pw.TextStyle(
                  fontSize: customization.fontSize,
                  fontStyle: pw.FontStyle.italic,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  Widget _buildPaymentRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            _FormatUtils.formatCurrency(amount),
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildInvoiceImage() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.image,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'IMAGE DE LA FACTURE',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _showFullScreenImage(),
                  icon: const Icon(Icons.fullscreen),
                  tooltip: 'Voir en plein écran',
                ),
              ],
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _showFullScreenImage,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LocalImageWidget(
                    imagePath: widget.invoice.imagePath!,
                    fit: BoxFit.cover,
                    placeholder: Container(
                      color: Colors.grey[100],
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported,
                              size: 48,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Image non disponible',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                    errorWidget: Container(
                      color: Colors.grey[100],
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Erreur de chargement',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullScreenImage() {
    if (widget.invoice.imagePath != null && (widget.invoice.imagePath ?? '').isNotEmpty) {
      FullScreenImageWidget.show(
        context,
        widget.invoice.imagePath!,
        title: 'Facture ${widget.invoice.invoiceNumber}',
      );
    }
  }
}

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'package:intl/intl.dart';

import '../models/invoice_model.dart';
import '../models/invoice_customization_model.dart';
import 'invoice_customization_service.dart';

class InvoicePrintService {
  static final InvoicePrintService _instance = InvoicePrintService._internal();
  factory InvoicePrintService() => _instance;
  InvoicePrintService._internal();

  final InvoiceCustomizationService _customizationService = InvoiceCustomizationService();

  /// Imprime une facture avec la mise en page thermique (par défaut)
  Future<void> printInvoice(BuildContext context, InvoiceModel invoice) async {
    try {
      final l10n = AppLocalizations.of(context)!;
      final pdfData = await _generateThermalPDF(invoice, l10n);
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfData,
        format: PdfPageFormat.roll80,
        name: '${invoice.type == InvoiceType.sale ? l10n.salesInvoiceTitle : l10n.purchaseVoucherTitle}_${invoice.invoiceNumber}.pdf',
      );
    } catch (e) {
      throw Exception('Erreur lors de l\'impression: $e');
    }
  }

  /// Imprime une facture avec la mise en page standard (A4)
  Future<void> printStandardInvoice(BuildContext context, InvoiceModel invoice) async {
    try {
      final l10n = AppLocalizations.of(context)!;
      final pdf = await _generatePDF(invoice, l10n);
      await Printing.layoutPdf(
        onLayout: (format) async => pdf,
        name: '${invoice.type == InvoiceType.sale ? l10n.salesInvoiceTitle : l10n.purchaseVoucherTitle}_${invoice.invoiceNumber}.pdf',
      );
    } catch (e) {
      throw Exception('Erreur lors de l\'impression standard: $e');
    }
  }

  /// Imprime une facture avec la mise en page thermique (ticket de caisse)
  Future<void> printThermalInvoice(BuildContext context, InvoiceModel invoice) async {
    try {
      final l10n = AppLocalizations.of(context)!;
      final pdfData = await _generateThermalPDF(invoice, l10n);
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfData,
        format: PdfPageFormat.roll80,
      );
    } catch (e) {
      throw Exception('Erreur lors de l\'impression thermique: $e');
    }
  }

  /// Génère un PDF standard pour la facture
  Future<Uint8List> _generatePDF(InvoiceModel invoice, AppLocalizations l10n) async {
    // Récupérer la personnalisation ou utiliser les valeurs par défaut
    InvoiceCustomizationModel customization;
    try {
      final loadedCustomization = await _customizationService.loadCustomization(invoice.userId);
      customization = loadedCustomization ?? InvoiceCustomizationModel.createDefault(invoice.userId);
    } catch (e) {
      // Utiliser les valeurs par défaut si pas de personnalisation
      customization = InvoiceCustomizationModel.createDefault(invoice.userId);
    }

    return await _generateCustomPDF(invoice, customization, l10n);
  }

  /// Génère un PDF thermique pour la facture
  Future<Uint8List> _generateThermalPDF(InvoiceModel invoice, AppLocalizations l10n) async {
    // Récupérer la personnalisation ou utiliser les valeurs par défaut
    InvoiceCustomizationModel customization;
    try {
      final loadedCustomization = await _customizationService.loadCustomization(invoice.userId);
      customization = loadedCustomization ?? InvoiceCustomizationModel.createDefault(invoice.userId);
    } catch (e) {
      // Utiliser les valeurs par défaut si pas de personnalisation
      customization = InvoiceCustomizationModel.createDefault(invoice.userId);
    }

    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    // Couleur primaire personnalisée
    final primaryColor = PdfColor.fromHex(customization.primaryColor);
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // En-tête personnalisé
              if (customization.headerText?.isNotEmpty == true)
                pw.Center(
                  child: pw.Text(
                    customization.headerText!,
                    style: pw.TextStyle(
                      fontSize: customization.fontSize,
                      fontWeight: pw.FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
              
              // Nom de l'entreprise
              if (customization.companyName.isNotEmpty)
                pw.Center(
                  child: pw.Text(
                    customization.companyName,
                    style: pw.TextStyle(
                      fontSize: customization.fontSize + 2,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              
              // Informations de l'entreprise
              if (customization.companyAddress?.isNotEmpty == true)
                pw.Center(
                  child: pw.Text(
                    customization.companyAddress!,
                    style: pw.TextStyle(fontSize: customization.fontSize - 2),
                  ),
                ),
              if (customization.companyPhone?.isNotEmpty == true)
                pw.Center(
                  child: pw.Text(
                    '${l10n.phone}: ${customization.companyPhone!}',
                    style: pw.TextStyle(fontSize: customization.fontSize - 2),
                  ),
                ),
              
              pw.SizedBox(height: 10),
              
              // Type de facture
              pw.Center(
                child: pw.Text(
                  invoice.type == InvoiceType.sale ? l10n.salesInvoiceTitle : l10n.purchaseVoucherTitle,
                  style: pw.TextStyle(
                    fontSize: customization.fontSize + 2,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              
              // Informations de base
              pw.Text('${l10n.invoiceNumber}: ${invoice.invoiceNumber}', style: pw.TextStyle(fontSize: customization.fontSize)),
              pw.Text('${l10n.date}: ${dateFormat.format(invoice.invoiceDate)}', style: pw.TextStyle(fontSize: customization.fontSize)),
              if (invoice.client != null)
                pw.Text('${l10n.clientHeader}: ${invoice.client!.name}', style: pw.TextStyle(fontSize: customization.fontSize)),
              if (invoice.supplier != null)
                pw.Text('${l10n.supplierHeader}: ${invoice.supplier!.name}', style: pw.TextStyle(fontSize: customization.fontSize)),
              
              pw.Divider(),
              
              // Articles
              ...invoice.items?.map((item) => pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    item.product?.name ?? l10n.itemLabel,
                    style: pw.TextStyle(
                      fontSize: customization.fontSize - 1,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        '${item.quantity?.toStringAsFixed(0)} x ${item.unitPrice?.toStringAsFixed(2)} DH',
                        style: pw.TextStyle(fontSize: customization.fontSize - 2),
                      ),
                      pw.Text(
                        '${item.totalPrice?.toStringAsFixed(2)} DH',
                        style: pw.TextStyle(fontSize: customization.fontSize - 2),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 5),
                ],
              )) ?? [],
              
              pw.Divider(),
              
              // Totaux
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(l10n.subtotal + ':', style: pw.TextStyle(fontSize: customization.fontSize)),
                  pw.Text('${invoice.subtotal.toStringAsFixed(2)} DH', style: pw.TextStyle(fontSize: customization.fontSize)),
                ],
              ),
              if (invoice.taxAmount > 0)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(l10n.tax + ':', style: pw.TextStyle(fontSize: customization.fontSize)),
                    pw.Text('${invoice.taxAmount.toStringAsFixed(2)} DH', style: pw.TextStyle(fontSize: customization.fontSize)),
                  ],
                ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(l10n.totalAmountLabel + ':', style: pw.TextStyle(
                    fontSize: customization.fontSize + 2,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryColor,
                  )),
                  pw.Text('${invoice.totalAmount.toStringAsFixed(2)} DH', style: pw.TextStyle(
                    fontSize: customization.fontSize + 2,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryColor,
                  )),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(l10n.paidAmount + ':', style: pw.TextStyle(fontSize: customization.fontSize)),
                  pw.Text('${invoice.paidAmount.toStringAsFixed(2)} DH', style: pw.TextStyle(fontSize: customization.fontSize)),
                ],
              ),
              if (invoice.remainingAmount > 0)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(l10n.remainingAmount + ':', style: pw.TextStyle(fontSize: customization.fontSize)),
                    pw.Text('${invoice.remainingAmount.toStringAsFixed(2)} DH', style: pw.TextStyle(fontSize: customization.fontSize)),
                  ],
                ),
              
              pw.SizedBox(height: 20),
              
              // Pied de page personnalisé
              if (customization.footerText?.isNotEmpty == true)
                pw.Center(
                  child: pw.Text(
                    customization.footerText!,
                    style: pw.TextStyle(
                      fontSize: customization.fontSize,
                      color: primaryColor,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                )
              else
                pw.Center(
                  child: pw.Text(
                    l10n.thankYouVisit,
                    style: pw.TextStyle(fontSize: customization.fontSize),
                  ),
                ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Génère un PDF personnalisé pour la facture
  Future<Uint8List> _generateCustomPDF(InvoiceModel invoice, InvoiceCustomizationModel customization, AppLocalizations l10n) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // En-tête avec logo et informations entreprise
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (customization.companyName.isNotEmpty)
                        pw.Text(
                          customization.companyName,
                          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                        ),
                      if (customization.companyAddress?.isNotEmpty == true)
                         pw.Text(customization.companyAddress ?? '', style: pw.TextStyle(fontSize: 12)),
                      if (customization.companyPhone?.isNotEmpty == true)
                        pw.Text('${l10n.phone}: ${customization.companyPhone}', style: pw.TextStyle(fontSize: 12)),
                      if (customization.companyEmail?.isNotEmpty == true)
                        pw.Text('${l10n.email}: ${customization.companyEmail}', style: pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        invoice.type == InvoiceType.sale ? l10n.salesInvoiceTitle : l10n.purchaseVoucherTitle,
                        style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text('${l10n.invoiceNumber}: ${invoice.invoiceNumber}', style: pw.TextStyle(fontSize: 14)),
                      pw.Text('${l10n.date}: ${dateFormat.format(invoice.invoiceDate)}', style: pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
              
              pw.SizedBox(height: 30),
              
              // Informations client/fournisseur
              if (invoice.client != null || invoice.supplier != null)
                pw.Container(
                  padding: pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (invoice.client != null) ...[
                        pw.Text('${l10n.clientHeader.toUpperCase()}:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text(invoice.client!.name),
                        if (invoice.client!.email?.isNotEmpty == true)
                          pw.Text('${l10n.email}: ${invoice.client!.email}'),
                        if (invoice.client!.phone?.isNotEmpty == true)
                          pw.Text('${l10n.phone}: ${invoice.client!.phone}'),
                      ],
                      if (invoice.supplier != null) ...[
                        pw.Text('${l10n.supplierHeader.toUpperCase()}:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text(invoice.supplier!.name),
                        if (invoice.supplier!.email?.isNotEmpty == true)
                          pw.Text('${l10n.email}: ${invoice.supplier!.email}'),
                        if (invoice.supplier!.phone?.isNotEmpty == true)
                          pw.Text('${l10n.phone}: ${invoice.supplier!.phone}'),
                      ],
                    ],
                  ),
                ),
              
              pw.SizedBox(height: 20),
              
              // Tableau des articles
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  // En-tête du tableau
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(l10n.itemLabel, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(l10n.quantityShort, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(l10n.unitPriceShort, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(l10n.totalAmountLabel, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  // Lignes des articles
                  ...invoice.items?.map((item) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(item.product?.name ?? l10n.itemLabel),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(item.quantity?.toStringAsFixed(0) ?? '0'),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text('${item.unitPrice?.toStringAsFixed(2) ?? '0.00'} DH'),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text('${item.totalPrice?.toStringAsFixed(2) ?? '0.00'} DH'),
                      ),
                    ],
                  )) ?? [],
                ],
              ),
              
              pw.SizedBox(height: 20),
              
              // Totaux
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('${l10n.subtotal}: ${invoice.subtotal.toStringAsFixed(2)} DH'),
                      if (invoice.taxAmount > 0)
                        pw.Text('${l10n.tax}: ${invoice.taxAmount.toStringAsFixed(2)} DH'),
                      pw.Divider(),
                      pw.Text(
                        '${l10n.totalAmountLabel}: ${invoice.totalAmount.toStringAsFixed(2)} DH',
                        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text('${l10n.paidAmount}: ${invoice.paidAmount.toStringAsFixed(2)} DH'),
                      if (invoice.remainingAmount > 0)
                        pw.Text(
                          '${l10n.remainingAmount}: ${invoice.remainingAmount.toStringAsFixed(2)} DH',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.red),
                        ),
                    ],
                  ),
                ],
              ),
              
              pw.Spacer(),
              
              // Pied de page
              if (customization.footerText?.isNotEmpty == true)
                pw.Center(
                  child: pw.Text(
                    customization.footerText ?? '',
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
                  ),
                ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:barcode/barcode.dart';

import '../models/product_model.dart';

class BarcodePrintService {
  /// Générer un PDF avec un code-barres pour impression
  static Future<Uint8List> generateBarcodePDF({
    required String barcodeData,
    required String productName,
    String? productDescription,
    double? price,
    String? unit,
    BarcodeType barcodeType = BarcodeType.Code128,
    PdfPageFormat pageFormat = PdfPageFormat.a4,
    bool multipleLabels = false,
    int labelsPerPage = 12,
  }) async {
    final pdf = pw.Document();

    // Créer le code-barres
    final barcode = Barcode.fromType(barcodeType);

    if (multipleLabels) {
      // Générer plusieurs étiquettes par page
      pdf.addPage(
        pw.MultiPage(
          pageFormat: pageFormat,
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            return [
              pw.Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(labelsPerPage, (index) {
                  return _buildBarcodeLabel(
                    barcode: barcode,
                    barcodeData: barcodeData,
                    productName: productName,
                    productDescription: productDescription,
                    price: price,
                    unit: unit,
                    isSmall: true,
                  );
                }),
              ),
            ];
          },
        ),
      );
    } else {
      // Générer une seule étiquette grande
      pdf.addPage(
        pw.Page(
          pageFormat: pageFormat,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return _buildBarcodeLabel(
              barcode: barcode,
              barcodeData: barcodeData,
              productName: productName,
              productDescription: productDescription,
              price: price,
              unit: unit,
              isSmall: false,
            );
          },
        ),
      );
    }

    return pdf.save();
  }

  /// Construire une étiquette de code-barres
  static pw.Widget _buildBarcodeLabel({
    required Barcode barcode,
    required String barcodeData,
    required String productName,
    String? productDescription,
    double? price,
    String? unit,
    bool isSmall = false,
  }) {
    final double labelWidth = isSmall ? 180 : 400;
    final double labelHeight = isSmall ? 120 : 250;
    final double fontSize = isSmall ? 8 : 12;
    final double titleFontSize = isSmall ? 10 : 16;
    final double barcodeHeight = isSmall ? 40 : 80;

    return pw.Container(
      width: labelWidth,
      height: labelHeight,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      padding: const pw.EdgeInsets.all(8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          // Nom du produit
          pw.Text(
            productName,
            style: pw.TextStyle(
              fontSize: titleFontSize,
              fontWeight: pw.FontWeight.bold,
            ),
            textAlign: pw.TextAlign.center,
            maxLines: isSmall ? 1 : 2,
          ),
          
          if (productDescription != null && productDescription.isNotEmpty && !isSmall) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              productDescription,
              style: pw.TextStyle(fontSize: fontSize - 1),
              textAlign: pw.TextAlign.center,
              maxLines: 2,
            ),
          ],

          pw.Spacer(),

          // Code-barres
          pw.Container(
            height: barcodeHeight,
            child: pw.BarcodeWidget(
              barcode: barcode,
              data: barcodeData,
              width: labelWidth - 16,
              height: barcodeHeight,
              drawText: true,
              textStyle: pw.TextStyle(fontSize: fontSize),
            ),
          ),

          pw.Spacer(),

          // Prix et unité
          if (price != null) ...[
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  '${price.toStringAsFixed(2)} DH',
                  style: pw.TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800,
                  ),
                ),
                if (unit != null && unit.isNotEmpty) ...[
                  pw.SizedBox(width: 4),
                  pw.Text(
                    '/ $unit',
                    style: pw.TextStyle(fontSize: fontSize),
                  ),
                ],
              ],
            ),
          ],

          // Date de génération
          if (!isSmall) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              'Généré le ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
              style: pw.TextStyle(
                fontSize: fontSize - 2,
                color: PdfColors.grey600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Imprimer directement un code-barres
  static Future<void> printBarcode({
    required BuildContext context,
    required String barcodeData,
    required String productName,
    String? productDescription,
    double? price,
    String? unit,
    BarcodeType barcodeType = BarcodeType.Code128,
    bool multipleLabels = false,
    int labelsPerPage = 12,
  }) async {
    try {
      final pdfData = await generateBarcodePDF(
        barcodeData: barcodeData,
        productName: productName,
        productDescription: productDescription,
        price: price,
        unit: unit,
        barcodeType: barcodeType,
        multipleLabels: multipleLabels,
        labelsPerPage: labelsPerPage,
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfData,
        name: 'Étiquette_${productName.replaceAll(' ', '_')}_$barcodeData',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'impression: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Partager un code-barres en PDF
  static Future<void> shareBarcode({
    required BuildContext context,
    required String barcodeData,
    required String productName,
    String? productDescription,
    double? price,
    String? unit,
    BarcodeType barcodeType = BarcodeType.Code128,
    bool multipleLabels = false,
    int labelsPerPage = 12,
  }) async {
    try {
      final pdfData = await generateBarcodePDF(
        barcodeData: barcodeData,
        productName: productName,
        productDescription: productDescription,
        price: price,
        unit: unit,
        barcodeType: barcodeType,
        multipleLabels: multipleLabels,
        labelsPerPage: labelsPerPage,
      );

      await Printing.sharePdf(
        bytes: pdfData,
        filename: 'Étiquette_${productName.replaceAll(' ', '_')}_$barcodeData.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du partage: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Générer des étiquettes pour plusieurs produits
  static Future<void> printMultipleProducts({
    required BuildContext context,
    required List<ProductModel> products,
    BarcodeType barcodeType = BarcodeType.Code128,
    int labelsPerProduct = 1,
    PdfPageFormat pageFormat = PdfPageFormat.a4,
  }) async {
    try {
      final pdf = pw.Document();
      final barcode = Barcode.fromType(barcodeType);

      // Grouper les produits par pages
      final List<ProductModel> allLabels = [];
      for (final product in products) {
        for (int i = 0; i < labelsPerProduct; i++) {
          allLabels.add(product);
        }
      }

      // Générer les pages (6 étiquettes par page)
      const int labelsPerPage = 6;
      for (int i = 0; i < allLabels.length; i += labelsPerPage) {
        final pageProducts = allLabels.skip(i).take(labelsPerPage).toList();
        
        pdf.addPage(
          pw.Page(
            pageFormat: pageFormat,
            margin: const pw.EdgeInsets.all(20),
            build: (pw.Context context) {
              return pw.Wrap(
                spacing: 10,
                runSpacing: 10,
                children: pageProducts.map((product) {
                  return _buildBarcodeLabel(
                    barcode: barcode,
                    barcodeData: product.barcode ?? 'NO_BARCODE',
                    productName: product.name,
                    productDescription: product.description,
                    price: product.sellingPrice,
                    unit: product.unit,
                    isSmall: true,
                  );
                }).toList(),
              );
            },
          ),
        );
      }

      final pdfData = await pdf.save();

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfData,
        name: 'Étiquettes_Produits_${DateTime.now().millisecondsSinceEpoch}',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'impression: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Obtenir les types de codes-barres disponibles
  static List<BarcodeType> getAvailableBarcodeTypes() {
    return [
      BarcodeType.Code128,
      BarcodeType.Code39,
      BarcodeType.Code93,
    ];
  }

  /// Obtenir le nom d'affichage d'un type de code-barres
  static String getBarcodeTypeName(BarcodeType type) {
    switch (type) {
      case BarcodeType.Code128:
        return 'Code 128 (Recommandé)';
      case BarcodeType.Code39:
        return 'Code 39';
      case BarcodeType.Code93:
        return 'Code 93';
      default:
        return type.toString();
    }
  }
}

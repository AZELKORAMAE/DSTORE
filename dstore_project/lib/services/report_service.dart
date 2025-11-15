import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../main.dart';

class ReportService {
  static Future<void> shareReport({
    required String title,
    required Map<String, dynamic> data,
    GlobalKey? chartKey,
  }) async {
    try {
      // Générer le PDF
      final pdf = await _generatePDF(title, data, chartKey);

      // Sauvegarder le fichier
      final directory = await getTemporaryDirectory();
      final fileName =
          '${title.replaceAll(' ', '_')}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      // Partager le fichier
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Rapport: $title',
        subject: title,
      );
    } catch (e) {
      print('Erreur lors du partage du rapport: $e');
      throw Exception('Impossible de partager le rapport: $e');
    }
  }

  static Future<void> shareTextReport({
    required String title,
    required Map<String, dynamic> data,
  }) async {
    try {
      final text = _generateTextReport(title, data);
      await Share.share(
        text,
        subject: title,
      );
    } catch (e) {
      print('Erreur lors du partage du rapport texte: $e');
      throw Exception('Impossible de partager le rapport: $e');
    }
  }

  static Future<pw.Document> _generatePDF(
    String title,
    Map<String, dynamic> data,
    GlobalKey? chartKey,
  ) async {
    final pdf = pw.Document();

    // Capture du graphique si disponible
    Uint8List? chartImage;
    if (chartKey != null) {
      try {
        final boundary = chartKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
        if (boundary != null) {
          final image = await boundary.toImage(pixelRatio: 2.0);
          final byteData = await image.toByteData(format: ImageByteFormat.png);
          chartImage = byteData?.buffer.asUint8List();
        }
      } catch (e) {
        print('Erreur capture graphique: $e');
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // En-tête
            pw.Header(
              level: 0,
              child: pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),

            // Date de génération
            pw.Text(
              'Généré le: ${DateFormat('dd/MM/yyyy à HH:mm').format(DateTime.now())}',
              style: pw.TextStyle(
                fontSize: 12,
                color: PdfColors.grey700,
              ),
            ),
            pw.SizedBox(height: 30),

            // Données principales
            if (data.containsKey('stats')) ...[
              pw.Text(
                'Statistiques principales',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              _buildStatsTable(data['stats']),
              pw.SizedBox(height: 30),
            ],

            // Graphique
            if (chartImage != null) ...[
              pw.Text(
                'Graphique',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Image(
                pw.MemoryImage(chartImage),
                height: 300,
                fit: pw.BoxFit.contain,
              ),
              pw.SizedBox(height: 30),
            ],

            // Données détaillées
            if (data.containsKey('details')) ...[
              pw.Text(
                'Détails',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              _buildDetailsTable(data['details']),
            ],
          ];
        },
      ),
    );

    return pdf;
  }

  static pw.Widget _buildStatsTable(Map<String, dynamic> stats) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: stats.entries.map((entry) {
        return pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                entry.key,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(_formatValue(entry.value)),
            ),
          ],
        );
      }).toList(),
    );
  }

  static pw.Widget _buildDetailsTable(List<Map<String, dynamic>> details) {
    if (details.isEmpty) {
      return pw.Text('Aucun détail disponible');
    }

    final headers = details.first.keys.toList();

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        // En-têtes
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: headers.map((header) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                header,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            );
          }).toList(),
        ),
        // Données
        ...details.map((row) {
          return pw.TableRow(
            children: headers.map((header) {
              return pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(_formatValue(row[header])),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  static String _generateTextReport(String title, Map<String, dynamic> data) {
    final buffer = StringBuffer();

    buffer.writeln('📊 $title');
    buffer.writeln('=' * (title.length + 4));
    buffer.writeln();
    buffer.writeln(
        '📅 Généré le: ${DateFormat('dd/MM/yyyy à HH:mm').format(DateTime.now())}');
    buffer.writeln();

    if (data.containsKey('stats')) {
      buffer.writeln('📈 STATISTIQUES PRINCIPALES');
      buffer.writeln('-' * 30);
      final stats = data['stats'] as Map<String, dynamic>;
      stats.forEach((key, value) {
        buffer.writeln('• $key: ${_formatValue(value)}');
      });
      buffer.writeln();
    }

    if (data.containsKey('details')) {
      buffer.writeln('📋 DÉTAILS');
      buffer.writeln('-' * 30);
      final details = data['details'] as List<Map<String, dynamic>>;
      for (int i = 0; i < details.length; i++) {
        buffer.writeln(
            '${i + 1}. ${details[i].entries.map((e) => '${e.key}: ${_formatValue(e.value)}').join(', ')}');
      }
    }

    buffer.writeln();
    buffer.writeln('---');
    buffer.writeln('Généré par Stock Management App');

    return buffer.toString();
  }

  static String _formatValue(dynamic value) {
    if (value is double) {
      return AppUtils.formatCurrency(value);
    } else if (value is DateTime) {
      return DateFormat('dd/MM/yyyy').format(value);
    } else {
      return value.toString();
    }
  }
}

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../models/invoice_model.dart';

class EmailService {
  /// Affiche un dialogue pour envoyer la facture par email
  static Future<void> showEmailDialog({
    required BuildContext context,
    required InvoiceModel invoice,
    required Uint8List pdfBytes,
  }) async {
    final isClient = invoice.type == InvoiceType.sale;
    
    // Récupérer l'email selon le type de facture
    String? recipientEmail;
    String? recipientName;
    
    if (isClient && invoice.client != null) {
      recipientEmail = invoice.client!.email;
      recipientName = invoice.client!.name;
    } else if (!isClient && invoice.supplier != null) {
      recipientEmail = invoice.supplier!.email;
      recipientName = invoice.supplier!.name;
    }
    
    if (recipientEmail == null || recipientEmail.isEmpty) {
      _showErrorDialog(
        context,
        'Aucune adresse email',
        'Aucune adresse email n\'est renseignée pour ce ${isClient ? 'client' : 'fournisseur'}.',
      );
      return;
    }

    final emailController = TextEditingController(text: recipientEmail);
    final messageController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Envoyer la ${isClient ? 'facture' : 'commande'} par email'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('À : ${recipientName ?? 'Destinataire'}'),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Adresse email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 15),
              TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  labelText: 'Message personnalisé (optionnel)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _sendEmailWithPlatform(
        context: context,
        invoice: invoice,
        recipientEmail: emailController.text.trim(),
        recipientName: recipientName ?? 'Destinataire',
        pdfBytes: pdfBytes,
        customMessage: messageController.text.trim().isNotEmpty 
            ? messageController.text.trim() 
            : null,
      );
    }
  }

  /// Envoie l'email en utilisant l'application email par défaut du système
  static Future<void> _sendEmailWithPlatform({
    required BuildContext context,
    required InvoiceModel invoice,
    required String recipientEmail,
    required String recipientName,
    required Uint8List pdfBytes,
    String? customMessage,
  }) async {
    try {
      // Sauvegarder le PDF temporairement
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/Facture_${invoice.invoiceNumber}.pdf');
      await file.writeAsBytes(pdfBytes);

      // Construire le sujet et le corps de l'email
      final subject = 'Facture ${invoice.invoiceNumber}';
      final body = _buildEmailBody(invoice, customMessage);

      // Partager le fichier avec l'application email
      await Share.shareXFiles(
        [XFile(file.path)],
        text: body,
        subject: subject,
      );

      _showSuccessDialog(context, 'Application email ouverte avec succès !');
    } catch (e) {
      _showErrorDialog(
        context,
        'Erreur d\'envoi',
        'Impossible d\'ouvrir l\'application email: $e',
      );
    }
  }

  /// Construit le corps de l'email
  static String _buildEmailBody(InvoiceModel invoice, String? customMessage) {
    final isClient = invoice.type == InvoiceType.sale;
    final entityName = isClient 
        ? (invoice.client?.name ?? 'Client')
        : (invoice.supplier?.name ?? 'Fournisseur');

    final buffer = StringBuffer();
    buffer.writeln('Bonjour $entityName,');
    buffer.writeln();
    buffer.writeln('Veuillez trouver ci-joint votre ${isClient ? 'facture' : 'bon d\'achat'} en pièce jointe.');
    buffer.writeln();
    buffer.writeln('Détails de la ${isClient ? 'facture' : 'commande'} :');
    buffer.writeln('- Numéro : ${invoice.invoiceNumber}');
    buffer.writeln('- Date : ${_formatDate(invoice.invoiceDate)}');
    buffer.writeln('- Montant total : ${_formatCurrency(invoice.totalAmount)}');
    buffer.writeln('- Statut : ${_getStatusText(invoice.status)}');
    buffer.writeln();
    
    if (customMessage != null) {
      buffer.writeln('Message personnalisé :');
      buffer.writeln(customMessage);
      buffer.writeln();
    }
    
    buffer.writeln('Si vous avez des questions concernant cette ${isClient ? 'facture' : 'commande'}, n\'hésitez pas à nous contacter.');
    buffer.writeln();
    buffer.writeln('Cordialement,');
    buffer.writeln('L\'équipe de Votre Entreprise');

    return buffer.toString();
  }

  static void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Succès'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(2)} DH';
  }

  static String _getStatusText(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return 'Brouillon';
      case InvoiceStatus.validated:
        return 'Validée';
      case InvoiceStatus.paid:
        return 'Payée';
      case InvoiceStatus.cancelled:
        return 'Annulée';
    }
  }
}

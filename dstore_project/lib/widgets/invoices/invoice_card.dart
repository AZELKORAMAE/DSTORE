import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/invoice_model.dart';
import '../../config/app_router.dart';
import '../../main.dart';
import '../../services/invoice_print_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class InvoiceCard extends StatelessWidget {
  final InvoiceModel invoice;

  const InvoiceCard({
    super.key,
    required this.invoice,
  });

  @override
  Widget build(BuildContext context) {
    // Couleurs selon le type de facture
    final Color cardColor = invoice.type == InvoiceType.sale
        ? Colors.blue.withOpacity(0.1)  // Bleu pour les ventes
        : Colors.amber.withOpacity(0.1); // Jaune pour les achats

    final Color borderColor = invoice.type == InvoiceType.sale
        ? Colors.blue.withOpacity(0.3)
        : Colors.amber.withOpacity(0.3);

    return Card(
      elevation: 2,
      color: cardColor,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: InkWell(
          onTap: () => context.goToInvoiceDetail(invoice.id),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec numéro et statut
              Row(
                children: [
                  Expanded(
                    child: Text(
                      invoice.invoiceNumber,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Bouton d'impression PDF
                  IconButton(
                    onPressed: () => _printPDFInvoice(context),
                    icon: const Icon(Icons.picture_as_pdf),
                    tooltip: AppLocalizations.of(context)!.printPDF,
                    iconSize: 20,
                    color: Colors.red,
                  ),
                  // Bouton d'impression thermique
                  IconButton(
                    onPressed: () => _printThermalInvoice(context),
                    icon: const Icon(Icons.receipt),
                    tooltip: AppLocalizations.of(context)!.printThermal,
                    iconSize: 20,
                    color: Colors.orange,
                  ),
                  _buildStatusChip(context),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Client
              if (invoice.clientName != null)
                Text(
                  invoice.clientName!,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              
              const SizedBox(height: 8),
              
              // Date
              Text(
                'Date: ${AppUtils.formatDate(invoice.invoiceDate)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              
              if (invoice.dueDate != null)
                Text(
                  'Échéance: ${AppUtils.formatDate(invoice.dueDate!)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: invoice.isOverdue ? Colors.red : Colors.grey[600],
                  ),
                ),
              
              const Spacer(),
              
              // Montant
              Text(
                AppUtils.formatCurrency(invoice.totalAmount),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    Color color;
    IconData icon;
    
    switch (invoice.status) {
      case 'draft':
        color = Colors.grey;
        icon = Icons.edit;
        break;
      case 'sent':
        color = Colors.blue;
        icon = Icons.send;
        break;
      case 'paid':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'overdue':
        color = Colors.red;
        icon = Icons.warning;
        break;
      case 'cancelled':
        color = Colors.orange;
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            invoice.statusDisplayName,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _printPDFInvoice(BuildContext context) async {
    try {
      final printService = InvoicePrintService();
      await printService.printStandardInvoice(context, invoice);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.printingPDFSuccess),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.printingPDFError}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _printThermalInvoice(BuildContext context) async {
    try {
      final printService = InvoicePrintService();
      await printService.printThermalInvoice(context, invoice);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.printingThermalSuccess),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.printingThermalError}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/invoice_model.dart';
import '../../config/app_router.dart';
import '../../main.dart';
import '../../services/invoice_print_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class InvoiceListItem extends StatelessWidget {
  final InvoiceModel invoice;

  const InvoiceListItem({
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
      margin: const EdgeInsets.only(bottom: 8),
      color: cardColor,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: _getStatusColor().withOpacity(0.1),
          child: Icon(
            _getStatusIcon(),
            color: _getStatusColor(),
          ),
        ),
        title: Text(
          invoice.invoiceNumber,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (invoice.clientName != null) ...[
              const SizedBox(height: 4),
              Text(
                'Client: ${invoice.clientName}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'Date: ${AppUtils.formatDate(invoice.invoiceDate)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                if (invoice.dueDate != null) ...[
                  const SizedBox(width: 16),
                  Text(
                    'Échéance: ${AppUtils.formatDate(invoice.dueDate!)}',
                    style: TextStyle(
                      color: invoice.isOverdue ? Colors.red : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  AppUtils.formatCurrency(invoice.totalAmount),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                _buildStatusChip(context),
              ],
            ),
            const SizedBox(width: 8),
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
          ],
        ),
        onTap: () => context.goToInvoiceDetail(invoice.id),
      ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    final color = _getStatusColor();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        invoice.statusDisplayName,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (invoice.status) {
      case 'draft':
        return Colors.grey;
      case 'sent':
        return Colors.blue;
      case 'paid':
        return Colors.green;
      case 'overdue':
        return Colors.red;
      case 'cancelled':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (invoice.status) {
      case 'draft':
        return Icons.edit;
      case 'sent':
        return Icons.send;
      case 'paid':
        return Icons.check_circle;
      case 'overdue':
        return Icons.warning;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
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

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/invoice_model.dart';
import '../../screens/invoices/pos_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class POSQuickAccess extends StatelessWidget {
  const POSQuickAccess({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre
            Row(
              children: [
                Icon(
                  Icons.point_of_sale,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.pointDeVente,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Text(
              AppLocalizations.of(context)!.accesRapideVente,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),

            const SizedBox(height: 20),

            // Boutons d'action
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateToPos(context, InvoiceType.sale),
                    icon: const Icon(Icons.shopping_cart),
                    label: Text(AppLocalizations.of(context)!.vente),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _navigateToPos(context, InvoiceType.purchase),
                    icon: const Icon(Icons.add_shopping_cart),
                    label: Text(AppLocalizations.of(context)!.achat),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Bouton pour créer une facture classique
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.go('/invoices/create'),
                icon: const Icon(Icons.receipt_long),
                label: Text(AppLocalizations.of(context)!.createInvoice),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPos(BuildContext context, InvoiceType type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => POSScreen(invoiceType: type),
      ),
    );
  }
}

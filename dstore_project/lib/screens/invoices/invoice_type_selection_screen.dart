import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/invoice_model.dart';
import 'pos_screen.dart';

class InvoiceTypeSelectionScreen extends StatelessWidget {
  const InvoiceTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createInvoice),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Titre
              Text(
                l10n.invoiceTypeChoiceTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                l10n.invoiceTypeChoiceSubtitle,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Bouton Vente
              _buildTypeCard(
                context: context,
                title: l10n.salesInvoiceTitle,
                subtitle: l10n.salesInvoiceSubtitle,
                icon: Icons.point_of_sale,
                color: Colors.green,
                onTap: () => _navigateToPos(context, InvoiceType.sale),
                features: [
                  l10n.featureBarcodeScanner,
                  l10n.featureClientManagement,
                  l10n.featureCalculateChange,
                  l10n.featureCreditManagement,
                  l10n.featureAutoStockUpdate,
                ],
              ),

              const SizedBox(height: 24),

              // Bouton Achat
              _buildTypeCard(
                context: context,
                title: l10n.purchaseVoucherTitle,
                subtitle: l10n.purchaseVoucherSubtitle,
                icon: Icons.shopping_cart,
                color: Colors.blue,
                onTap: () => _navigateToPos(context, InvoiceType.purchase),
                features: [
                  l10n.featureBarcodeScanner,
                  l10n.featureSupplierManagement,
                  l10n.featureAutoAddToStock,
                  l10n.featureCostTracking,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required List<String> features,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              // Icône et titre
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      size: 32,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                  ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: color,
                    size: 20,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Fonctionnalités
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.includedFeaturesLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                    ),
                    const SizedBox(height: 8),
                    ...features.map((feature) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 16,
                                color: color,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  feature,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
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

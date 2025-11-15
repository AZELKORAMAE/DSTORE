import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../config/app_router.dart';
import '../../l10n/app_localizations.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;
    final l10n = AppLocalizations.of(context)!;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.flash_on,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.quickActions,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: isDesktop ? 20 : 18,
                            ),
                      ),
                      if (isDesktop)
                        Text(
                          l10n.quickActionsSubtitle,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Grille principale avec toutes les actions
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: isDesktop ? 4 : (isTablet ? 3 : 2),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: isDesktop ? 1.4 : (isTablet ? 1.3 : 0.95),
              children: [
                _buildActionButton(
                  context,
                  AppLocalizations.of(context)!.nouvelleFacture,
                  Icons.receipt_long,
                  Colors.blue,
                  () => context.goToCreateInvoice(),
                ),
                _buildActionButton(
                  context,
                  AppLocalizations.of(context)!.ajouterProduit,
                  Icons.add_box,
                  Colors.green,
                  () => context.goToAddProduct(),
                ),
                _buildActionButton(
                  context,
                  AppLocalizations.of(context)!.nouveauClient,
                  Icons.person_add,
                  Colors.purple,
                  () => context.goToAddClient(),
                ),
                _buildActionButton(
                  context,
                  AppLocalizations.of(context)!.ajouterCategorie,
                  Icons.category,
                  Colors.orange,
                  () => context.go('/categories/add'),
                ),
                _buildActionButton(
                  context,
                  AppLocalizations.of(context)!.nouveauFournisseur,
                  Icons.business,
                  Colors.teal,
                  () => context.goToAddSupplier(),
                ),
                // Rapport des transactions produits (ventes/achats)
                _buildActionButton(
                  context,
                  AppLocalizations.of(context)!.productTransactionReport,
                  Icons.bar_chart,
                  Colors.deepOrange,
                  () => context.go('/transactions-report'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final isMobile = !ResponsiveBreakpoints.of(context).isDesktop &&
                     !ResponsiveBreakpoints.of(context).isTablet;

    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 6 : 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(isMobile ? 6 : 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color,
                        color.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: isMobile ? 20 : 24,
                  ),
                ),
                SizedBox(height: isMobile ? 4 : 8),
                Flexible(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: color,
                          fontSize: isMobile ? 10 : 12,
                        ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

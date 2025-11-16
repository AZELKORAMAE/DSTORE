import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../config/app_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TopActionBar extends StatelessWidget {
  const TopActionBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    if (!isDesktop && !isTablet) {
      return const SizedBox.shrink(); // Ne pas afficher sur mobile
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.speed,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            AppLocalizations.of(context)!.actionsRapides,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Row(
              children: [
                _buildQuickButton(
                  context,
                  AppLocalizations.of(context)!.facture,
                  Icons.receipt_long,
                  Colors.blue,
                  () => context.goToCreateInvoice(),
                ),
                const SizedBox(width: 12),
                _buildQuickButton(
                  context,
                  AppLocalizations.of(context)!.product,
                  Icons.add_box,
                  Colors.green,
                  () => context.goToAddProduct(),
                ),
                const SizedBox(width: 12),
                _buildQuickButton(
                  context,
                  AppLocalizations.of(context)!.clients,
                  Icons.person_add,
                  Colors.purple,
                  () => context.goToAddClient(),
                ),
                const SizedBox(width: 12),
                _buildQuickButton(
                  context,
                  AppLocalizations.of(context)!.scanner,
                  Icons.qr_code_scanner,
                  Colors.indigo,
                  () => context.go('/scanner'),
                ),
                const Spacer(),
                _buildNavigationButton(
                  context,
                  'Produits',
                  Icons.inventory_2,
                  () => context.goToProducts(),
                ),
                const SizedBox(width: 8),
                _buildNavigationButton(
                  context,
                  'Clients',
                  Icons.people,
                  () => context.goToClients(),
                ),
                const SizedBox(width: 8),
                _buildNavigationButton(
                  context,
                  'Factures',
                  Icons.receipt,
                  () => context.goToInvoices(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      elevation: 1,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Material(
      elevation: 0,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class NavigationHelper {
  static List<NavigationItem> getMainItems(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return [
      NavigationItem(
        label: l10n?.dashboard ?? 'Tableau de bord',
        icon: Icons.dashboard_outlined,
        selectedIcon: Icons.dashboard,
        route: '/dashboard',
      ),
      NavigationItem(
        label: l10n?.products ?? 'Produits',
        icon: Icons.inventory_2_outlined,
        selectedIcon: Icons.inventory_2,
        route: '/products',
      ),
      NavigationItem(
        label: l10n?.categories ?? 'Catégories',
        icon: Icons.category_outlined,
        selectedIcon: Icons.category,
        route: '/categories',
      ),
      NavigationItem(
        label: l10n?.clients ?? 'Clients',
        icon: Icons.people_outline,
        selectedIcon: Icons.people,
        route: '/clients',
      ),
      NavigationItem(
        label: l10n?.suppliers ?? 'Fournisseurs',
        icon: Icons.business_outlined,
        selectedIcon: Icons.business,
        route: '/suppliers',
      ),
      NavigationItem(
        label: l10n?.invoices ?? 'Factures',
        icon: Icons.receipt_long_outlined,
        selectedIcon: Icons.receipt_long,
        route: '/invoices',
      ),
      NavigationItem(
        label: l10n?.expenses ?? 'Dépenses',
        icon: Icons.account_balance_wallet_outlined,
        selectedIcon: Icons.account_balance_wallet,
        route: '/expenses',
      ),
      NavigationItem(
        label: l10n?.reports ?? 'Rapports',
        icon: Icons.analytics_outlined,
        selectedIcon: Icons.analytics,
        route: '/reports',
      ),
      NavigationItem(
        label: 'Crédits',
        icon: Icons.credit_card_outlined,
        selectedIcon: Icons.credit_card,
        route: '/credits',
      ),
      NavigationItem(
        label: l10n?.settings ?? 'Paramètres',
        icon: Icons.settings_outlined,
        selectedIcon: Icons.settings,
        route: '/settings',
      ),
    ];
  }

  static List<NavigationItem> getBottomNavItems(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return [
      NavigationItem(
        label: l10n?.home ?? 'Accueil',
        icon: Icons.home_outlined,
        selectedIcon: Icons.home,
        route: '/dashboard',
      ),
      NavigationItem(
        label: l10n?.products ?? 'Produits',
        icon: Icons.inventory_2_outlined,
        selectedIcon: Icons.inventory_2,
        route: '/products',
      ),
      NavigationItem(
        label: l10n?.invoices ?? 'Factures',
        icon: Icons.receipt_long_outlined,
        selectedIcon: Icons.receipt_long,
        route: '/invoices',
      ),
      NavigationItem(
        label: l10n?.more ?? 'Plus',
        icon: Icons.more_horiz_outlined,
        selectedIcon: Icons.more_horiz,
        route: '/settings',
      ),
    ];
  }
}

class NavigationItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String route;

  const NavigationItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.route,
  });
}

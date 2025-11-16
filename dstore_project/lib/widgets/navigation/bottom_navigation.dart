import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/navigation_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppBottomNavigation extends StatelessWidget {
  final String currentRoute;

  const AppBottomNavigation({
    super.key,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    final bottomNavItems = NavigationHelper.getBottomNavItems(context);
    final currentIndex = _getCurrentIndex(bottomNavItems);

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: (index) => _onItemTapped(context, index),
      items: bottomNavItems.map((item) {
        final isSelected = _isItemSelected(item.route);
        return BottomNavigationBarItem(
          icon: Icon(isSelected ? item.selectedIcon : item.icon),
          label: item.label,
        );
      }).toList(),
    );
  }

  int _getCurrentIndex(List<NavigationItem> bottomNavItems) {
    for (int i = 0; i < bottomNavItems.length; i++) {
      if (_isItemSelected(bottomNavItems[i].route)) {
        return i;
      }
    }
    return 0;
  }

  bool _isItemSelected(String route) {
    if (route == '/settings') {
      // Pour "Plus", vérifier si on est sur une page non couverte par les autres onglets
      return !currentRoute.startsWith('/dashboard') &&
          !currentRoute.startsWith('/products') &&
          !currentRoute.startsWith('/scanner') &&
          !currentRoute.startsWith('/invoices');
    }
    return currentRoute.startsWith(route);
  }

  void _onItemTapped(BuildContext context, int index) {
    final bottomNavItems = NavigationHelper.getBottomNavItems(context);
    final item = bottomNavItems[index];

    if (item.route == '/settings') {
      // Afficher un menu pour "Plus"
      _showMoreMenu(context);
    } else {
      context.go(item.route);
    }
  }

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Poignée
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Titre
            Text(
              'Plus d\'options',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),

            // Options
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildMenuOption(
                  context,
                  AppLocalizations.of(context)?.clients ?? 'Clients',
                  Icons.people,
                  () => context.go('/clients'),
                ),
                _buildMenuOption(
                  context,
                  AppLocalizations.of(context)?.suppliers ?? 'Fournisseurs',
                  Icons.business,
                  () => context.go('/suppliers'),
                ),
                _buildMenuOption(
                  context,
                  AppLocalizations.of(context)?.categories ?? 'Catégories',
                  Icons.category,
                  () => context.go('/categories'),
                ),
                _buildMenuOption(
                  context,
                  AppLocalizations.of(context)?.reports ?? 'Rapports',
                  Icons.analytics,
                  () => context.go('/reports'),
                ),
                _buildMenuOption(
                  context,
                  AppLocalizations.of(context)?.settings ?? 'Paramètres',
                  Icons.settings,
                  () => context.go('/settings'),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

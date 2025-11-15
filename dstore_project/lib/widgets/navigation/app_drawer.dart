import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../config/navigation_helper.dart';
import '../../providers/auth_provider.dart';
import '../../main.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;
    final currentRoute = GoRouterState.of(context).matchedLocation;

    return Container(
      width: isDesktop ? 280 : null,
      child: Drawer(
        child: Column(
          children: [
            // En-tête du drawer
            _buildDrawerHeader(context),

            // Menu principal
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ...NavigationHelper.getMainItems(context).map((item) =>
                      _buildNavigationItem(context, item, currentRoute)),

                  const Divider(),

                  // Actions rapides
                  _buildSectionHeader(context, 'Actions rapides'),

                  _buildQuickActionItem(
                    context,
                    'Nouvelle facture',
                    Icons.receipt_long,
                    () => context.go('/invoices/create'),
                  ),
                  _buildQuickActionItem(
                    context,
                    'Ajouter produit',
                    Icons.add_box,
                    () => context.go('/products/add'),
                  ),
                ],
              ),
            ),

            // Pied du drawer
            _buildDrawerFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.userProfile;

        return UserAccountsDrawerHeader(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
            ),
          ),
          accountName: Text(
            user?.businessName ?? user?.fullName ?? 'Utilisateur',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          accountEmail: Text(
            user?.email ?? '',
            style: const TextStyle(fontSize: 14),
          ),
          currentAccountPicture: CircleAvatar(
            backgroundColor: Colors.white,
            child: Text(
              (user?.businessName ?? user?.fullName ?? 'U')[0].toUpperCase(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          otherAccountsPictures: [
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () => context.go('/settings'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNavigationItem(
      BuildContext context, NavigationItem item, String currentRoute) {
    final isSelected = currentRoute.startsWith(item.route);

    return ListTile(
      leading: Icon(
        isSelected ? (item.selectedIcon ?? item.icon) : item.icon,
        color: isSelected ? Theme.of(context).primaryColor : null,
      ),
      title: Text(
        item.label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? Theme.of(context).primaryColor : null,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.1),
      onTap: () {
        context.go(item.route);
        // Fermer le drawer sur mobile
        if (ResponsiveBreakpoints.of(context).isMobile) {
          Navigator.of(context).pop();
        }
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildQuickActionItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, size: 20),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14),
      ),
      dense: true,
      onTap: () {
        onTap();
        // Fermer le drawer sur mobile
        if (ResponsiveBreakpoints.of(context).isMobile) {
          Navigator.of(context).pop();
        }
      },
    );
  }

  Widget _buildDrawerFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Déconnexion',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () => _handleLogout(context),
          ),
          const SizedBox(height: 8),
          Text(
            'Version ${AppConstants.appVersion}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await AppUtils.showConfirmDialog(
      context,
      'Déconnexion',
      'Êtes-vous sûr de vouloir vous déconnecter ?',
    );

    if (confirmed && context.mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signOut();
      if (context.mounted) {
        context.go('/login');
      }
    }
  }
}

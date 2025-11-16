import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../config/app_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final bool showMenuButton;
  final String? title;
  final List<Widget>? actions;

  const AppBarWidget({
    super.key,
    this.scaffoldKey,
    this.showMenuButton = false,
    this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;
    final currentRoute = GoRouterState.of(context).matchedLocation;

    return AppBar(
      title: isDesktop
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo et titre pour desktop
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.inventory_2,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title ?? _getPageTitle(currentRoute),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ],
            )
          : Text(
              title ?? _getPageTitle(currentRoute),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
      leading: !isDesktop && showMenuButton
          ? IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => scaffoldKey?.currentState?.openDrawer(),
            )
          : null,
      actions: [
        ...?actions,

        // Recherche
        if (isDesktop) ...[
          SizedBox(
            width: 300,
            child: _buildSearchField(context),
          ),
          const SizedBox(width: 16),
        ],

        // Notifications
        _buildNotificationButton(context),

        // Profil utilisateur
        _buildProfileButton(context),

        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Rechercher...',
          hintStyle: const TextStyle(color: Colors.white70),
          prefixIcon: const Icon(Icons.search, color: Colors.white70),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        style: const TextStyle(color: Colors.white),
        onSubmitted: (value) {
          // Implémenter la recherche
          _handleSearch(context, value);
        },
      ),
    );
  }

  Widget _buildNotificationButton(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final lowStockCount = productProvider.lowStockProducts.length;

        return Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              tooltip: 'Notifications',
              onPressed: () => _showNotifications(context),
            ),
            if (lowStockCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    lowStockCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildProfileButton(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.userProfile;

        return PopupMenuButton<String>(
          icon: CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white,
            child: Text(
              (user?.businessName ?? user?.fullName ?? 'U')[0].toUpperCase(),
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          onSelected: (value) => _handleProfileMenuAction(context, value),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  const Icon(Icons.person_outline),
                  const SizedBox(width: 12),
                  Text(user?.fullName ?? 'Profil'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings_outlined),
                  SizedBox(width: 12),
                  Text('Paramètres'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, color: Colors.red),
                  SizedBox(width: 12),
                  Text('Déconnexion', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String _getPageTitle(String route) {
    switch (route) {
      case '/dashboard':
        return 'Tableau de bord';
      case '/products':
        return 'Produits';
      case '/categories':
        return 'Catégories';
      case '/clients':
        return 'Clients';
      case '/suppliers':
        return 'Fournisseurs';
      case '/invoices':
        return 'Factures';
      case '/reports':
        return 'Rapports';
      case '/settings':
        return 'Paramètres';
      case '/scanner':
        return 'Scanner';
      default:
        if (route.contains('/products/add')) return 'Ajouter un produit';
        if (route.contains('/products/edit')) return 'Modifier le produit';
        if (route.contains('/products/detail')) return 'Détails du produit';
        if (route.contains('/clients/add')) return 'Ajouter un client';
        if (route.contains('/clients/edit')) return 'Modifier le client';
        if (route.contains('/invoices/create')) return 'Créer une facture';
        return 'Gestion de Stock';
    }
  }

  void _handleSearch(BuildContext context, String query) {
    // Implémenter la recherche globale
    if (query.isNotEmpty) {
      // Rediriger vers la page de recherche ou filtrer les résultats
      context.go('/products?search=$query');
    }
  }

  void _showNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.notifications),
        content: Consumer<ProductProvider>(
          builder: (context, productProvider, child) {
            final lowStockProducts = productProvider.lowStockProducts;

            if (lowStockProducts.isEmpty) {
              return Text(AppLocalizations.of(context)!.aucuneNotification);
            }

            return SizedBox(
              width: 300,
              height: 200,
              child: ListView.builder(
                itemCount: lowStockProducts.length,
                itemBuilder: (context, index) {
                  final product = lowStockProducts[index];
                  return ListTile(
                    leading: const Icon(Icons.warning, color: Colors.orange),
                    title: Text(product.name),
                    subtitle: Text(
                        'Stock faible: ${product.stockQuantity} ${product.unit}'),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.goToProductDetail(product.id);
                    },
                  );
                },
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.fermer),
          ),
        ],
      ),
    );
  }

  void _handleProfileMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'profile':
        context.goToSettings();
        break;
      case 'settings':
        context.goToSettings();
        break;
      case 'logout':
        _handleLogout(context);
        break;
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.signOut();
    if (context.mounted) {
      context.goToLogin();
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

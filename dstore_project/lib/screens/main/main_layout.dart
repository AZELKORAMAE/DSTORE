import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:provider/provider.dart';

import '../../config/app_router.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/navigation/app_drawer.dart';
import '../../widgets/navigation/bottom_navigation.dart';
import '../../widgets/common/app_bar_widget.dart';
import '../../utils/app_utils.dart';
import '../../l10n/app_localizations.dart';

class MainLayout extends StatefulWidget {
  final Widget child;

  const MainLayout({
    super.key,
    required this.child,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<bool> _onWillPop() async {
    final l10n = AppLocalizations.of(context)!;
    final shouldExit = await AppUtils.showConfirmDialog(
      context,
      title: l10n.warning,
      message: l10n.exitConfirmationMessage,
      confirmText: l10n.confirm,
      cancelText: l10n.cancel,
    );
    return shouldExit;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;
    final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;

    final currentRoute = GoRouterState.of(context).matchedLocation;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBarWidget(
          scaffoldKey: _scaffoldKey,
          showMenuButton: isMobile || isTablet,
        ),
        drawer: (isMobile || isTablet) ? const AppDrawer() : null,
        body: Row(
          children: [
            // Sidebar pour desktop
            if (isDesktop) const AppDrawer(),

            // Contenu principal
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.background,
                child: widget.child,
              ),
            ),
          ],
        ),
        bottomNavigationBar:
            isMobile ? AppBottomNavigation(currentRoute: currentRoute) : null,
        floatingActionButton: _buildFloatingActionButton(context, currentRoute),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  Widget? _buildFloatingActionButton(
      BuildContext context, String currentRoute) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    // Sur mobile, afficher un FAB contextuel selon la page
    if (isMobile) {
      switch (currentRoute) {
        case '/products':
          return FloatingActionButton.extended(
            onPressed: () => context.goToAddProduct(),
            tooltip: 'Ajouter un produit',
            icon: const Icon(Icons.add),
            label: const Text('Produit'),
          );
        case '/clients':
          return FloatingActionButton.extended(
            onPressed: () => context.goToAddClient(),
            tooltip: 'Ajouter un client',
            icon: const Icon(Icons.person_add),
            label: const Text('Client'),
          );
        case '/suppliers':
          return FloatingActionButton.extended(
            onPressed: () => context.goToAddSupplier(),
            tooltip: 'Ajouter un fournisseur',
            icon: const Icon(Icons.business),
            label: const Text('Fournisseur'),
          );
        case '/categories':
          return FloatingActionButton.extended(
            onPressed: () => context.goToAddCategory(),
            tooltip: 'Ajouter une catégorie',
            icon: const Icon(Icons.category),
            label: const Text('Catégorie'),
          );
        case '/invoices':
          return FloatingActionButton.extended(
            onPressed: () => context.goToCreateInvoice(),
            tooltip: 'Créer une facture',
            icon: const Icon(Icons.receipt_long),
            label: const Text('Facture'),
          );
        case '/dashboard':
          return FloatingActionButton.extended(
            onPressed: () => context.goToCreateInvoice(),
            tooltip: 'Nouvelle facture',
            icon: const Icon(Icons.receipt_long),
            label: const Text('Facture'),
            backgroundColor: Colors.blue,
          );
        default:
          return null;
      }
    }

    // Sur desktop/tablet, pas de FAB car on a la barre d'actions en haut
    return null;
  }
}

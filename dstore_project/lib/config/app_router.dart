import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/auth/verify_code_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/verify_reset_code_screen.dart';
import '../screens/auth/subscription_check_screen.dart';
import '../screens/auth/pending_account_screen.dart';
import '../screens/auth/suspended_account_screen.dart';
import '../screens/admin/admin_login_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/admin_settings_screen.dart';
import '../screens/main/main_layout.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/products/products_screen.dart';
import '../screens/products/add_edit_product_screen.dart';
import '../screens/products/product_detail_screen.dart';
import '../screens/products/barcode_generator_screen.dart';
import '../screens/admin/admin_device_management_screen.dart';
import '../screens/admin/admin_accounts_devices_screen.dart';
import '../screens/admin/simple_accounts_devices_screen.dart';
import '../screens/suspended_device_screen.dart';
import '../screens/settings/accounts_on_device_screen.dart';
import '../screens/device_authorization_screen.dart';
import '../screens/categories/categories_screen.dart';
import '../screens/categories/add_edit_category_screen.dart';
import '../screens/clients/clients_screen.dart';
import '../screens/clients/add_edit_client_screen.dart';
import '../screens/clients/client_detail_screen.dart';
import '../screens/suppliers/suppliers_screen.dart';
import '../screens/suppliers/add_edit_supplier_screen.dart';
import '../screens/invoices/invoices_screen.dart';
import '../screens/invoices/invoice_type_selection_screen.dart';
import '../screens/invoice_detail_wrapper.dart';
import '../screens/expenses/expenses_screen.dart';
import '../screens/expenses/add_expense_screen.dart';
import '../screens/search/product_search_screen.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/reports/product_transactions_report_screen.dart';
import '../screens/credit_screen.dart';
import '../screens/invoices/invoice_edit_screen.dart';
import '../screens/auth/terms_screen.dart';
import '../screens/invoices/invoice_customization_screen.dart';

import '../screens/settings/settings_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login', // Toujours commencer par la page de connexion
    redirect: (context, state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isLoggedIn = authProvider.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/reset-password' ||
          state.matchedLocation == '/verify-code' ||
          state.matchedLocation == '/forgot-password' ||
          state.matchedLocation == '/verify-reset-code';
      final isPendingPage = state.matchedLocation == '/pending-account';
      final isAdminRoute = state.matchedLocation.startsWith('/admin');
      final isSuspendedPage = state.matchedLocation == '/suspended-account';
      // Autoriser l'accès aux écrans d'autorisation et de suspension d'appareil
      final isDeviceAuthPage = state.matchedLocation == '/device-authorization';
      final isSuspendedDevicePage = state.matchedLocation == '/suspended-device';

      // Page des conditions et politique: accessible sans authentification
      final isTermsPage = state.matchedLocation == '/terms';

      // Exclure les routes admin de la logique de redirection
      if (isAdminRoute) {
        return null;
      }

      if (!isLoggedIn &&
          !isLoggingIn &&
          !isPendingPage &&
          !isSuspendedPage &&
          !isDeviceAuthPage &&
          !isSuspendedDevicePage &&
          !isTermsPage) {
        return '/login';
      }

      // Vérifier l'expiration de session
      if (isLoggedIn && authProvider.isSessionExpired()) {
        return '/login';
      }

      // Si l'utilisateur est connecté, vérifier son statut d'abonnement
      if (isLoggedIn) {
        final subscriptionStatus = authProvider.getLocalSubscriptionStatus();

        // Si le compte est en attente et pas déjà sur la page pending
        if (subscriptionStatus.name == 'pending' && !isPendingPage) {
          print('🔄 ROUTER: Redirection vers /pending-account pour compte pending');
          return '/pending-account';
        }
        if (subscriptionStatus.name == 'suspended' && !isSuspendedPage) {
          return '/suspended-account';
        }
        // Si le compte est actif et sur une page de connexion ou pending
        if (subscriptionStatus.name == 'active' &&
            (isLoggingIn || isPendingPage)) {
          return '/dashboard';
        }

        // Si sur une page de connexion avec un compte non-actif
        if (isLoggingIn && subscriptionStatus.name != 'active') {
          return '/pending-account';
        }
      }

      return null;
    },
    routes: [
      // Routes d'authentification
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        name: 'reset-password',
        builder: (context, state) {
          final data = state.extra as Map<String, String>;
          return ResetPasswordScreen(
            email: data['email']!,
            code: data['code']!,
          );
        },
      ),
      GoRoute(
        path: '/verify-code',
        name: 'verify-code',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return VerifyCodeScreen(email: email);
        },
      ),

      // Nouvelles routes pour le système de récupération de mot de passe
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/verify-reset-code',
        name: 'verify-reset-code',
        builder: (context, state) {
          final email = state.extra as String;
          return VerifyResetCodeScreen(email: email);
        },
      ),
      GoRoute(
        path: '/subscription-check',
        name: 'subscription-check',
        builder: (context, state) => const SubscriptionCheckScreen(),
      ),
      GoRoute(
        path: '/pending-account',
        name: 'pending-account',
        builder: (context, state) => const PendingAccountScreen(),
      ),
      GoRoute(
        path: '/suspended-account',
        name: 'suspended-account',
        builder: (context, state) => const SuspendedAccountScreen(),
      ),

      // Routes admin
      GoRoute(
        path: '/admin-login',
        name: 'admin-login',
        builder: (context, state) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: '/admin-dashboard',
        name: 'admin-dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin-settings',
        name: 'admin-settings',
        builder: (context, state) => const AdminSettingsScreen(),
      ),
      GoRoute(
        path: '/admin/devices',
        name: 'admin-device-management',
        builder: (context, state) => const AdminDeviceManagementScreen(),
      ),
      GoRoute(
        path: '/admin/accounts-devices',
        name: 'admin-accounts-devices',
        builder: (context, state) => const AdminAccountsDevicesScreen(),
      ),
      GoRoute(
        path: '/admin/simple-accounts',
        name: 'admin-simple-accounts',
        builder: (context, state) => const SimpleAccountsDevicesScreen(),
      ),
      GoRoute(
        path: '/device-authorization',
        name: 'device-authorization',
        builder: (context, state) => const DeviceAuthorizationScreen(),
      ),

      // Écran pour les appareils suspendus. Permet d'informer l'utilisateur
      // que son appareil est suspendu et de se déconnecter.
      GoRoute(
        path: '/suspended-device',
        name: 'suspended-device',
        builder: (context, state) => const SuspendedDeviceScreen(),
      ),

      // Routes principales avec layout
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          // Dashboard
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),

          // Produits
          GoRoute(
            path: '/products',
            name: 'products',
            builder: (context, state) => ProductsScreen(
              categoryId: state.uri.queryParameters['categoryId'],
              categoryName: state.uri.queryParameters['categoryName'],
            ),
            routes: [
              GoRoute(
                path: 'add',
                name: 'add-product',
                builder: (context, state) => const AddEditProductScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                name: 'edit-product',
                builder: (context, state) => AddEditProductScreen(
                  productId: state.pathParameters['id'],
                ),
              ),
              GoRoute(
                path: 'detail/:id',
                name: 'product-detail',
                builder: (context, state) => ProductDetailScreen(
                  productId: state.pathParameters['id']!,
                ),
              ),
              GoRoute(
                path: 'search',
                name: 'product-search',
                builder: (context, state) => const ProductSearchScreen(),
              ),
              GoRoute(
                path: 'generate-barcode',
                name: 'generate-barcode',
                builder: (context, state) => BarcodeGeneratorScreen(
                  productName: state.uri.queryParameters['productName'],
                  categoryName: state.uri.queryParameters['categoryName'],
                ),
              ),
            ],
          ),

          // Écrans temporaires (à implémenter)
          // Catégories
          GoRoute(
            path: '/categories',
            name: 'categories',
            builder: (context, state) => const CategoriesScreen(),
            routes: [
              GoRoute(
                path: 'add',
                name: 'add-category',
                builder: (context, state) => const AddEditCategoryScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                name: 'edit-category',
                builder: (context, state) => AddEditCategoryScreen(
                  categoryId: state.pathParameters['id'],
                ),
              ),
            ],
          ),
          // Clients
          GoRoute(
            path: '/clients',
            name: 'clients',
            builder: (context, state) => const ClientsScreen(),
            routes: [
              GoRoute(
                path: 'add',
                name: 'add-client',
                builder: (context, state) => const AddEditClientScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                name: 'edit-client',
                builder: (context, state) => AddEditClientScreen(
                  clientId: state.pathParameters['id'],
                ),
              ),
              GoRoute(
                path: 'detail/:id',
                name: 'client-detail',
                builder: (context, state) => ClientDetailScreen(
                  clientId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          // Fournisseurs
          GoRoute(
            path: '/suppliers',
            name: 'suppliers',
            builder: (context, state) => const SuppliersScreen(),
            routes: [
              GoRoute(
                path: 'add',
                name: 'add-supplier',
                builder: (context, state) => const AddEditSupplierScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                name: 'edit-supplier',
                builder: (context, state) => AddEditSupplierScreen(
                  supplierId: state.pathParameters['id'],
                ),
              ),
            ],
          ),
          // Factures
          GoRoute(
            path: '/invoices',
            name: 'invoices',
            builder: (context, state) => const InvoicesScreen(),
            routes: [
              GoRoute(
                path: 'create',
                name: 'create-invoice',
                builder: (context, state) => const InvoiceTypeSelectionScreen(),
              ),
              GoRoute(
                path: 'detail/:id',
                name: 'invoice-detail',
                builder: (context, state) {
                  final invoiceId = state.pathParameters['id']!;
                  return InvoiceDetailScreenWrapper(invoiceId: invoiceId);
                },
              ),
          GoRoute(
            path: 'edit/:id',
            name: 'edit-invoice',
            builder: (context, state) {
              final invoiceId = state.pathParameters['id']!;
              return InvoiceEditScreen(invoiceId: invoiceId);
            },
          ),
            ],
          ),
          // Dépenses
          GoRoute(
            path: '/expenses',
            name: 'expenses',
            builder: (context, state) => const ExpensesScreen(),
            routes: [
              GoRoute(
                path: 'add',
                name: 'add-expense',
                builder: (context, state) => const AddExpenseScreen(),
              ),
            ],
          ),

          // Rapports
          GoRoute(
            path: '/reports',
            name: 'reports',
            builder: (context, state) => const ReportsScreen(),
          ),

          // Rapport transactions produits (ventes et achats)
          GoRoute(
            path: '/transactions-report',
            name: 'transactions-report',
            builder: (context, state) => const ProductTransactionsReportScreen(),
          ),

          // Crédits
          GoRoute(
            path: '/credits',
            name: 'credits',
            builder: (context, state) => const CreditScreen(),
          ),

          // Conditions d'utilisation et politique de confidentialité
          GoRoute(
            path: '/terms',
            name: 'terms',
            builder: (context, state) => const TermsScreen(),
          ),

          // Paramètres
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),

          // Personnalisation des factures
          GoRoute(
            path: '/invoice-customization',
            name: 'invoice-customization',
            builder: (context, state) => const InvoiceCustomizationScreen(),
          ),
        ],
      ),
    ],
  );
}

// Extension pour faciliter la navigation
extension AppRouterExtension on BuildContext {
  void goToLogin() => go('/login');
  void goToRegister() => go('/register');
  void goToDashboard() => go('/dashboard');
  void goToSuspendedAccount() => go('/suspended-account');
  void goToPendingAccount() => go('/pending-account');
  void goToProducts() => go('/products');
  void goToAddProduct() => go('/products/add');
  void goToEditProduct(String id) => go('/products/edit/$id');
  void goToProductDetail(String id) => go('/products/detail/$id');
  void goToProductSearch() => go('/products/search');
  void goToProductsByCategory(String categoryId, String categoryName) => go(
      '/products?categoryId=$categoryId&categoryName=${Uri.encodeComponent(categoryName)}');
  void goToBarcodeGenerator({String? productName, String? categoryName}) {
    final params = <String, String>{};
    if (productName != null) params['productName'] = productName;
    if (categoryName != null) params['categoryName'] = categoryName;

    final uri = Uri(path: '/products/generate-barcode', queryParameters: params.isNotEmpty ? params : null);
    go(uri.toString());
  }
  void goToCategories() => go('/categories');
  void goToAddCategory() => go('/categories/add');
  void goToEditCategory(String id) => go('/categories/edit/$id');
  void goToClients() => go('/clients');
  void goToAddClient() => go('/clients/add');
  void goToEditClient(String id) => go('/clients/edit/$id');
  void goToClientDetail(String id) => go('/clients/detail/$id');
  void goToSuppliers() => go('/suppliers');
  void goToAddSupplier() => go('/suppliers/add');
  void goToEditSupplier(String id) => go('/suppliers/edit/$id');
  void goToInvoices() => go('/invoices');
  void goToCreateInvoice() => go('/invoices/create');
  void goToInvoiceDetail(String id) => go('/invoices/detail/$id');
  void goToExpenses() => go('/expenses');
  void goToAddExpense() => go('/expenses/add');
  void goToReports() => go('/reports');
  void goToSettings() => go('/settings');
  void goToInvoiceCustomization() => go('/invoice-customization');
}

// Classe pour les éléments de navigation
class NavigationItem {
  final String label;
  final IconData icon;
  final IconData? selectedIcon;
  final String route;
  final List<NavigationItem>? children;

  const NavigationItem({
    required this.label,
    required this.icon,
    this.selectedIcon,
    required this.route,
    this.children,
  });
}

// Navigation helper - utilise maintenant NavigationHelper pour les traductions

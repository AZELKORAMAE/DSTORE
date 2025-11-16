import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'config/supabase_config.dart';
import 'config/app_theme.dart';
import 'config/app_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/category_provider.dart';
import 'providers/client_provider.dart';
import 'providers/supplier_provider.dart';
import 'providers/invoice_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/device_provider.dart';
import 'services/local_storage_service.dart';
import 'services/device_registration_service.dart';
import 'utils/local_storage.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Supabase
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  // Initialiser le stockage local
  try {
    await LocalStorageService.instance.initialize();
    await AppLocalStorage.init();
    print('✅ Stockage local initialisé');
  } catch (e) {
    print('❌ Erreur initialisation stockage local: $e');
  }

  // Vérifier l'autorisation de l'appareil si un utilisateur est connecté
  try {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      print('✅ Utilisateur connecté détecté, vérification autorisation appareil...');
      final isAuthorized = await DeviceRegistrationService.instance.checkDeviceAuthorization();

      if (!isAuthorized) {
        print('❌ Appareil suspendu - déconnexion forcée au démarrage');
        await Supabase.instance.client.auth.signOut();
        print('🔒 Utilisateur déconnecté car appareil suspendu');

        // L'utilisateur sera redirigé vers l'écran de connexion
        // Le message d'erreur sera géré par le provider
      } else {
        print('✅ Appareil autorisé - mise à jour connexion');
        await DeviceRegistrationService.instance.updateLastLogin();
      }
    }
  } catch (e) {
    print('❌ Erreur vérification appareil: $e');
    // En cas d'erreur, déconnecter par sécurité
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (_) {}
  }

  // Lancer l'application avec un splash animé. Le widget Directionality
  // fournit le sens de lecture nécessaire aux widgets Flutter avant la
  // construction du MaterialApp.
  runApp(Directionality(
    textDirection: TextDirection.ltr,
    child: const SplashRoot(),
  ));
}

class StockManagementApp extends StatelessWidget {
  const StockManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => ClientProvider()),
        ChangeNotifierProvider(create: (_) => SupplierProvider()),
        ChangeNotifierProvider(create: (_) => InvoiceProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => DeviceProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp.router(
            title: 'DStore',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.themeMode,
            locale: Locale(settings.languageCode),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: AppRouter.router,
            builder: (context, child) => ResponsiveBreakpoints.builder(
              child: child!,
              breakpoints: [
                const Breakpoint(start: 0, end: 450, name: MOBILE),
                const Breakpoint(start: 451, end: 800, name: TABLET),
                const Breakpoint(start: 801, end: 1920, name: DESKTOP),
                const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Extension pour accéder facilement à Supabase
extension SupabaseExtension on BuildContext {
  SupabaseClient get supabase => Supabase.instance.client;
}

// Constantes globales
class AppConstants {
  static const String appName = 'DStore';
  static const String appVersion = '1.0.0';

  // Couleurs principales
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color errorColor = Color(0xFFB00020);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);

  // Tailles
  static const double borderRadius = 12.0;
  static const double cardElevation = 4.0;
  static const double iconSize = 24.0;

  // Animations
  static const Duration animationDuration = Duration(milliseconds: 300);

  // Pagination
  static const int itemsPerPage = 20;

  // Seuils par défaut
  static const int defaultStockThreshold = 10;
}

// Utilitaires globaux
class AppUtils {
  static String formatCurrency(double amount) {
    return '${amount.toStringAsFixed(2)} DH';
  }

  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static String formatDateShort(DateTime date) {
    return '${date.day}/${date.month}';
  }

  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  static void showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? AppConstants.errorColor : AppConstants.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
      ),
    );
  }

  static Future<bool> showConfirmDialog(
    BuildContext context,
    String title,
    String content,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Confirmer'),
              ),
            ],
          ),
        ) ??
        false;
  }
}

// SplashRoot affiche un écran d'animation au démarrage de l'application.
// De petites boîtes convergent vers le centre, puis le logo DStore apparaît.
class SplashRoot extends StatefulWidget {
  const SplashRoot({super.key});

  @override
  State<SplashRoot> createState() => _SplashRootState();
}

class _SplashRootState extends State<SplashRoot> with TickerProviderStateMixin {
  bool _showSplash = true;
  bool _hideBoxes = false;
  late final AnimationController _boxesController;
  late final AnimationController _logoController;

  // Positions de départ et d'arrivée des petites boîtes pour l'animation.
  final List<Alignment> _startAlignments = const [
    Alignment(-1.0, -1.0),
    Alignment(1.0, -1.0),
    Alignment(-1.0, 1.0),
    Alignment(1.0, 1.0),
    Alignment(0.0, -1.0),
    Alignment(-1.0, 0.0),
    Alignment(1.0, 0.0),
    Alignment(0.0, 1.0),
    Alignment(-0.4, -0.2),
  ];
  final List<Alignment> _endAlignments = const [
    Alignment(-0.10, -0.10),
    Alignment(0.10, -0.10),
    Alignment(-0.10, 0.10),
    Alignment(0.10, 0.10),
    Alignment(0.00, -0.15),
    Alignment(-0.15, 0.00),
    Alignment(0.15, 0.00),
    Alignment(0.00, 0.15),
    Alignment(0.00, 0.00),
  ];

  @override
  void initState() {
    super.initState();
    // Animation des boîtes convergentes
    _boxesController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
    // Animation d'apparition du logo
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    // Quand les boîtes ont fini de bouger, lancer l'animation du logo puis masquer le splash
    _boxesController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Lorsque les boîtes ont fini de se regrouper, cacher les boîtes et lancer l'animation du logo
        setState(() {
          _hideBoxes = true;
        });
        _logoController.forward();
        Future.delayed(const Duration(milliseconds: 900), () {
          if (mounted) {
            setState(() {
              _showSplash = false;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _boxesController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Lorsque le splash est terminé, retourner l'application principale
    if (!_showSplash) {
      return const StockManagementApp();
    }
    const Color splashBackground = Color(0xFF0BA3FF);
    return Scaffold(
      backgroundColor: splashBackground,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Générer les boîtes en mouvement uniquement si elles ne sont pas cachées
          if (!_hideBoxes) ...List.generate(_startAlignments.length, (index) {
            final animation = AlignmentTween(
              begin: _startAlignments[index],
              end: _endAlignments[index],
            ).animate(
              CurvedAnimation(
                parent: _boxesController,
                curve: Curves.easeOutCubic,
              ),
            );
            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return Align(
                  alignment: animation.value,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: const [
                        BoxShadow(blurRadius: 10, color: Colors.white24),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
          // Logo et textes apparaissent après la convergence des boîtes
          Center(
            child: FadeTransition(
              opacity: CurvedAnimation(
                parent: _logoController,
                curve: Curves.easeOutCubic,
              ),
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.85, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _logoController,
                    curve: Curves.easeOut,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset(
                        'assets/images/dstore_logo.png',
                        width: 140,
                        height: 140,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'DSTORE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Gestion des stocks simplifiée',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

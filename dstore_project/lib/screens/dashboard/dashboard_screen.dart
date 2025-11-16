import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:go_router/go_router.dart';

import '../../providers/dashboard_provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/app_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../utils/app_utils.dart';
import '../../widgets/dashboard/stats_card.dart';
import '../../widgets/dashboard/quick_actions.dart';
import '../../widgets/dashboard/low_stock_alert.dart';
import '../../widgets/dashboard/pos_quick_access.dart';
import '../../widgets/dashboard/daily_revenue_card.dart';
import '../../widgets/dashboard/real_low_stock_card.dart';
import '../../widgets/dashboard/top_action_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardProvider>(context, listen: false).refreshAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await Provider.of<DashboardProvider>(context, listen: false)
              .refreshAll();
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop ? 24 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête de bienvenue
              _buildWelcomeHeader(context),
              const SizedBox(height: 24),

              // Barre d'actions rapides en haut (desktop/tablet)
              const TopActionBar(),

              // Actions rapides en haut pour un accès facile
              const QuickActions(),
              const SizedBox(height: 24),

              // Point de vente rapide
              const POSQuickAccess(),
              const SizedBox(height: 24),

              // Cartes de statistiques déplacées vers le bas
              _buildStatsCards(context, isDesktop, isTablet),
              const SizedBox(height: 24),

              // Revenus du jour
              if (isDesktop)
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: DailyRevenueCard(),
                    ),
                  ],
                )
              else
                const DailyRevenueCard(),

              const SizedBox(height: 24),

              // Section des alertes de stock en bas (collapsibles)
              Text(
                AppLocalizations.of(context)!.gestionDesStocks,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              if (isDesktop)
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: LowStockAlert(),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: RealLowStockCard(),
                    ),
                  ],
                )
              else ...[
                const LowStockAlert(),
                const SizedBox(height: 16),
                const RealLowStockCard(),
              ],


            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.userProfile;
        final businessName = user?.businessName;
        final fullName = user?.fullName;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      businessName ?? fullName ?? AppLocalizations.of(context)!.utilisateur,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getActivityOverview(context),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.dashboard,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsCards(BuildContext context, bool isDesktop, bool isTablet) {
    return Consumer<DashboardProvider>(
      builder: (context, dashboardProvider, child) {
        if (dashboardProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final crossAxisCount = isDesktop ? 4 : (isTablet ? 2 : 1);
        final childAspectRatio = isDesktop ? 1.5 : (isTablet ? 1.3 : 2.5);

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: childAspectRatio,
          children: [
            StatsCard(
              title: AppLocalizations.of(context)?.todayRevenue ??
                  AppLocalizations.of(context)!.revenusDuJour,
              value: AppUtils.formatCurrency(dashboardProvider.todayRevenue),
              icon: Icons.attach_money,
              color: Colors.green,
              trend: _calculateRevenueTrend(dashboardProvider),
              onTap: () => context.goToReports(),
            ),
            StatsCard(
              title: AppLocalizations.of(context)?.totalProducts ?? AppLocalizations.of(context)!.products,
              value: '${dashboardProvider.totalProducts}',
              icon: Icons.inventory_2,
              color: Colors.blue,
              trend: _calculateProductsTrend(dashboardProvider),
              onTap: () => context.goToProducts(),
            ),
            StatsCard(
              title: AppLocalizations.of(context)?.totalClients ?? AppLocalizations.of(context)!.clients,
              value: '${dashboardProvider.totalClients}',
              icon: Icons.people,
              color: Colors.orange,
              trend: _calculateClientsTrend(dashboardProvider),
              onTap: () => context.goToClients(),
            ),
            StatsCard(
              title: AppLocalizations.of(context)?.lowStock ?? AppLocalizations.of(context)!.stockFaible,
              value: '${dashboardProvider.lowStockProducts}',
              icon: Icons.warning,
              color: Colors.red,
              isAlert: dashboardProvider.lowStockProducts > 0,
              onTap: () => context.goToProducts(),
            ),
          ],
        );
      },
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return AppLocalizations.of(context)!.bonjour;
    } else if (hour < 17) {
      return AppLocalizations.of(context)!.bonApresMidi;
    } else {
      return AppLocalizations.of(context)!.bonsoir;
    }
  }

  String _getActivityOverview(BuildContext context) {
    return AppLocalizations.of(context)!.apercuActivite;
  }

  String? _calculateRevenueTrend(DashboardProvider provider) {
    // Calculer la tendance basée sur les revenus de la semaine vs semaine précédente
    if (provider.weekRevenue > 0 && provider.todayRevenue > 0) {
      final dailyAverage = provider.weekRevenue / 7;
      final difference = provider.todayRevenue - dailyAverage;
      final percentage = (difference / dailyAverage * 100).abs();

      if (difference > 0) {
        return '+${percentage.toStringAsFixed(1)}%';
      } else if (difference < 0) {
        return '-${percentage.toStringAsFixed(1)}%';
      }
    }
    return null;
  }

  String? _calculateProductsTrend(DashboardProvider provider) {
    // Pour les produits, on peut calculer basé sur les nouveaux produits ajoutés
    // Pour l'instant, on retourne une valeur statique positive
    if (provider.totalProducts > 0) {
      return '+${(provider.totalProducts * 2.5).toStringAsFixed(1)}%';
    }
    return null;
  }

  String? _calculateClientsTrend(DashboardProvider provider) {
    // Pour les clients, on peut calculer basé sur les nouveaux clients
    // Pour l'instant, on retourne une valeur basée sur le nombre de clients
    if (provider.totalClients > 0) {
      return '+${(provider.totalClients * 8.3).toStringAsFixed(1)}%';
    }
    return null;
  }
}

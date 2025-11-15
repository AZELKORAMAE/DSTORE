import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../providers/product_provider.dart';
import '../../providers/client_provider.dart';
import '../../providers/invoice_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/charts/revenue_chart.dart';
import '../../widgets/charts/sales_pie_chart.dart';
import '../../widgets/charts/stock_bar_chart.dart';
import '../../services/report_service.dart';
import '../../main.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedPeriod = 'month';
  final GlobalKey _revenueChartKey = GlobalKey();
  final GlobalKey _salesChartKey = GlobalKey();
  final GlobalKey _stockChartKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).loadProducts();
      Provider.of<ClientProvider>(context, listen: false).loadClients();
      Provider.of<InvoiceProvider>(context, listen: false).loadInvoices();
      Provider.of<DashboardProvider>(context, listen: false)
          .loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec sélecteur de période
            _buildHeader(context),
            const SizedBox(height: 24),

            // Cartes de statistiques principales
            _buildMainStats(context, isDesktop, isTablet),
            const SizedBox(height: 24),

            // Graphiques et analyses
            _buildChartsSection(context, isDesktop, isTablet),
            const SizedBox(height: 24),

            // Tableaux détaillés
            _buildDetailedTables(context, isDesktop, isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rapports et Analyses',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Vue d\'ensemble de votre activité',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            // Bouton de partage
            IconButton(
              onPressed: _showShareOptions,
              icon: const Icon(Icons.share),
              tooltip: 'Partager le rapport',
            ),
            const SizedBox(width: 8),
            // Sélecteur de période
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                value: _selectedPeriod,
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem(value: 'week', child: Text('Cette semaine')),
                  DropdownMenuItem(value: 'month', child: Text('Ce mois')),
                  DropdownMenuItem(
                      value: 'quarter', child: Text('Ce trimestre')),
                  DropdownMenuItem(value: 'year', child: Text('Cette année')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedPeriod = value!;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMainStats(BuildContext context, bool isDesktop, bool isTablet) {
    final crossAxisCount = isDesktop ? 4 : (isTablet ? 2 : 1);

    return Consumer3<ProductProvider, ClientProvider, InvoiceProvider>(
      builder:
          (context, productProvider, clientProvider, invoiceProvider, child) {
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              'Chiffre d\'affaires',
              AppUtils.formatCurrency(invoiceProvider.totalRevenue),
              Icons.attach_money,
              Colors.green,
              '+12.5%',
            ),
            _buildStatCard(
              'Factures',
              invoiceProvider.totalInvoices.toString(),
              Icons.receipt_long,
              Colors.blue,
              '+8.2%',
            ),
            _buildStatCard(
              'Clients',
              clientProvider.totalClients.toString(),
              Icons.people,
              Colors.orange,
              '+5.1%',
            ),
            _buildStatCard(
              'Produits',
              productProvider.totalProducts.toString(),
              Icons.inventory_2,
              Colors.purple,
              '+3.7%',
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String change,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    change,
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Flexible(
              child: Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection(
      BuildContext context, bool isDesktop, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analyses graphiques',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        if (isDesktop)
          Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildSalesChart()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildProductsChart()),
                ],
              ),
              const SizedBox(height: 16),
              _buildStockChart(),
            ],
          )
        else
          Column(
            children: [
              _buildSalesChart(),
              const SizedBox(height: 16),
              _buildProductsChart(),
              const SizedBox(height: 16),
              _buildStockChart(),
            ],
          ),
      ],
    );
  }

  Widget _buildSalesChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Évolution des ventes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            Consumer<DashboardProvider>(
              builder: (context, dashboardProvider, child) {
                // Utiliser les vraies données des 7 derniers jours
                final weeklyRevenue = dashboardProvider.weeklyRevenueData;

                // Générer les noms des jours pour les 7 derniers jours
                final now = DateTime.now();
                final weekDays = <String>[];
                for (int i = 6; i >= 0; i--) {
                  final date = now.subtract(Duration(days: i));
                  final dayNames = [
                    'Dim',
                    'Lun',
                    'Mar',
                    'Mer',
                    'Jeu',
                    'Ven',
                    'Sam'
                  ];
                  weekDays.add(dayNames[date.weekday % 7]);
                }

                return RepaintBoundary(
                  key: _revenueChartKey,
                  child: RevenueChart(
                    weeklyRevenue: weeklyRevenue,
                    weekDays: weekDays,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Répartition par catégorie',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            Consumer<DashboardProvider>(
              builder: (context, dashboardProvider, child) {
                // Utiliser les vraies données des ventes par produit
                final salesData = dashboardProvider.salesByProduct;

                return RepaintBoundary(
                  key: _salesChartKey,
                  child: SalesPieChart(salesData: salesData),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockChart() {
    return Consumer<DashboardProvider>(
      builder: (context, dashboardProvider, child) {
        // Utiliser les vraies données du stock par catégorie
        final stockData = dashboardProvider.stockByCategory;

        return RepaintBoundary(
          key: _stockChartKey,
          child: StockBarChart(stockData: stockData),
        );
      },
    );
  }

  Widget _buildDetailedTables(
      BuildContext context, bool isDesktop, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tableaux détaillés',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildTopProductsTable()),
              const SizedBox(width: 16),
              Expanded(child: _buildTopClientsTable()),
            ],
          )
        else
          Column(
            children: [
              _buildTopProductsTable(),
              const SizedBox(height: 16),
              _buildTopClientsTable(),
            ],
          ),
      ],
    );
  }

  Widget _buildTopProductsTable() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top produits',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            Consumer<ProductProvider>(
              builder: (context, productProvider, child) {
                final products = productProvider.products.take(5).toList();

                return Column(
                  children: products
                      .map(
                        (product) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  product.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              Text(
                                AppUtils.formatCurrency(product.sellingPrice),
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopClientsTable() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top clients',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            Consumer<ClientProvider>(
              builder: (context, clientProvider, child) {
                final clients = clientProvider.clients.take(5).toList();

                return Column(
                  children: clients
                      .map(
                        (client) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  client.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              Text(
                                AppUtils.formatCurrency(client.totalPurchases),
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showShareOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Partager le rapport',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('Partager en PDF'),
              subtitle: const Text('Génère un PDF avec graphiques'),
              onTap: () {
                Navigator.pop(context);
                _shareReport('pdf');
              },
            ),
            ListTile(
              leading: const Icon(Icons.text_snippet, color: Colors.blue),
              title: const Text('Partager en texte'),
              subtitle: const Text('Partage les données en format texte'),
              onTap: () {
                Navigator.pop(context);
                _shareReport('text');
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _shareReport(String type) async {
    try {
      final title =
          'Rapport ${_selectedPeriod == 'week' ? 'Hebdomadaire' : _selectedPeriod == 'month' ? 'Mensuel' : _selectedPeriod == 'quarter' ? 'Trimestriel' : 'Annuel'}';

      // Récupérer les données des providers
      final productProvider = context.read<ProductProvider>();
      final clientProvider = context.read<ClientProvider>();
      final invoiceProvider = context.read<InvoiceProvider>();
      final dashboardProvider = context.read<DashboardProvider>();

      final data = {
        'stats': {
          'Chiffre d\'affaires': invoiceProvider.totalRevenue,
          'Nombre de factures': invoiceProvider.totalInvoices,
          'Nombre de clients': clientProvider.totalClients,
          'Nombre de produits': productProvider.totalProducts,
          'Revenus du jour': dashboardProvider.todayRevenue,
          'Revenus de la semaine': dashboardProvider.weekRevenue,
          'Revenus du mois': dashboardProvider.monthRevenue,
        },
        'details': [
          {
            'Type': 'Revenus',
            'Aujourd\'hui': dashboardProvider.todayRevenue,
            'Cette semaine': dashboardProvider.weekRevenue,
            'Ce mois': dashboardProvider.monthRevenue,
          },
          {
            'Type': 'Stock',
            'Produits totaux': productProvider.totalProducts,
            'Stock faible': dashboardProvider.lowStockProducts,
            'Valeur totale': dashboardProvider.totalStockValue,
          },
        ],
      };

      if (type == 'pdf') {
        await ReportService.shareReport(
          title: title,
          data: data,
          chartKey: _revenueChartKey,
        );
      } else {
        await ReportService.shareTextReport(
          title: title,
          data: data,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rapport partagé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

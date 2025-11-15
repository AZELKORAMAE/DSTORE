import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/dashboard_service.dart';
import '../../config/app_theme.dart';
import '../../l10n/app_localizations.dart';

class DailyRevenueCard extends StatefulWidget {
  const DailyRevenueCard({Key? key}) : super(key: key);

  @override
  State<DailyRevenueCard> createState() => _DailyRevenueCardState();
}

class _DailyRevenueCardState extends State<DailyRevenueCard> {
  final DashboardService _dashboardService = DashboardService();
  Map<String, dynamic>? _dailyRevenue;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDailyRevenue();
  }

  Future<void> _loadDailyRevenue() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Charger les vraies données des revenus du jour
      final revenue = await _dashboardService.getDailyRevenueDetails();

      print('📊 Revenus du jour chargés: $revenue');

      if (mounted) {
        setState(() {
          _dailyRevenue = revenue;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Erreur chargement revenus du jour: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.today,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.todayRevenue,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadDailyRevenue,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error != null)
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 48),
                    const SizedBox(height: 8),
                    Text(
                      l10n.erreurDeChargement,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _error!,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _loadDailyRevenue,
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              )
            else if (_dailyRevenue != null)
              _buildRevenueContent()
            else
              Center(
                child: Text(l10n.noDataAvailable),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueContent() {
    final l10n = AppLocalizations.of(context)!;
    final revenue = _dailyRevenue!;

    return Column(
      children: [
        // Résumé principal
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.totalSales,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatCurrency(revenue['totalSales'] as double),
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${revenue['salesCount']} ' +
                          ((revenue['salesCount'] as int) > 1
                              ? l10n.invoiceCountPlural
                              : l10n.invoiceCountSingle),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Détails des revenus
        Row(
          children: [
            Expanded(
              child: _buildRevenueItem(
                l10n.collected,
                revenue['totalPaid'] as double,
                Colors.green,
                Icons.check_circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildRevenueItem(
                l10n.pending,
                revenue['totalPending'] as double,
                Colors.orange,
                Icons.schedule,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildRevenueItem(
                l10n.purchases,
                revenue['totalPurchases'] as double,
                Colors.red,
                Icons.shopping_cart,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildRevenueItem(
                l10n.netProfit,
                revenue['netRevenue'] as double,
                (revenue['netRevenue'] as double) >= 0
                    ? Colors.green
                    : Colors.red,
                (revenue['netRevenue'] as double) >= 0
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Indicateur de performance
        if ((revenue['salesCount'] as int) > 0)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: Colors.grey[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Panier moyen: ${_formatCurrency((revenue['totalSales'] as double) / (revenue['salesCount'] as int))}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildRevenueItem(
      String label, double amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _formatCurrency(amount),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(2)} DH';
  }
}

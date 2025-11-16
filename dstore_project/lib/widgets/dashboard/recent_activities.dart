import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/invoice_provider.dart';
import '../../config/app_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../main.dart';

class RecentActivities extends StatefulWidget {
  const RecentActivities({super.key});

  @override
  State<RecentActivities> createState() => _RecentActivitiesState();
}

class _RecentActivitiesState extends State<RecentActivities> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InvoiceProvider>(context, listen: false).loadInvoices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)?.recentActivities ??
                      'Activités récentes',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => context.goToInvoices(),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      AppLocalizations.of(context)?.viewAll ?? 'Voir tout',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Consumer<InvoiceProvider>(
              builder: (context, invoiceProvider, child) {
                final recentInvoices =
                    invoiceProvider.allInvoices.take(5).toList();

                if (recentInvoices.isEmpty) {
                  return Container(
                    height: 200,
                    child: Center(
                      child: Text(
                          AppLocalizations.of(context)?.noRecentActivity ??
                              'Aucune activité récente'),
                    ),
                  );
                }

                return Column(
                  children: recentInvoices
                      .map((invoice) => _buildActivityItem(context, invoice))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, invoice) {
    IconData icon;
    Color color;
    String action;

    switch (invoice.status.value) {
      case 'draft':
        icon = Icons.edit;
        color = Colors.grey;
        action = 'Brouillon créé';
        break;
      case 'validated':
        icon = Icons.check_circle;
        color = Colors.blue;
        action = 'Facture validée';
        break;
      case 'paid':
        icon = Icons.payment;
        color = Colors.green;
        action = 'Paiement reçu';
        break;
      case 'cancelled':
        icon = Icons.cancel;
        color = Colors.red;
        action = 'Facture annulée';
        break;
      default:
        icon = Icons.receipt;
        color = Colors.grey;
        action = 'Facture créée';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.goToInvoiceDetail(invoice.id),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Facture ${invoice.invoiceNumber}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    if (invoice.client != null)
                      Text(
                        'Client: ${invoice.client!.name}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppUtils.formatCurrency(invoice.totalAmount),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppUtils.formatDate(invoice.invoiceDate),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

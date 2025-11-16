import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:go_router/go_router.dart';

import '../../providers/invoice_provider.dart';
import '../../config/app_router.dart';
import '../../main.dart';
import '../../widgets/invoices/invoice_card.dart';
import '../../widgets/invoices/invoice_list_item.dart';
import '../../widgets/common/search_bar_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../widgets/common/filter_chip_widget.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  bool _isGridView = false; // Les factures sont mieux en liste
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InvoiceProvider>(context, listen: false).loadInvoices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    // Localisation
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Column(
        children: [
          // Barre de recherche et filtres
          _buildSearchAndFilters(context),

          // Statistiques rapides
          _buildQuickStats(context),

          // Liste/Grille des factures
          Expanded(
            child: Consumer<InvoiceProvider>(
              builder: (context, invoiceProvider, child) {
                if (invoiceProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (invoiceProvider.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)!.erreurDeChargement,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          invoiceProvider.errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => invoiceProvider.loadInvoices(),
                          child: Text(AppLocalizations.of(context)!.retry),
                        ),
                      ],
                    ),
                  );
                }

                final invoices = invoiceProvider.filteredInvoices;

                if (invoices.isEmpty) {
                  return _buildEmptyState(context);
                }

                return RefreshIndicator(
                  onRefresh: () => invoiceProvider.loadInvoices(),
                  child: _isGridView
                      ? _buildGridView(context, invoices, isDesktop, isTablet)
                      : _buildListView(context, invoices),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.goToCreateInvoice(),
        icon: const Icon(Icons.receipt_long),
        label: Text(l10n.newInvoice),
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Barre de recherche
          Consumer<InvoiceProvider>(
            builder: (context, invoiceProvider, child) {
              return SearchBarWidget(
                hintText: l10n.invoicesSearchHint,
                onChanged: (query) => invoiceProvider.searchInvoices(query),
                onClear: () => invoiceProvider.clearFilters(),
              );
            },
          ),

          const SizedBox(height: 12),

          // Filtres et options d'affichage
          Row(
            children: [
              // Filtres par statut
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChipWidget(
                        label: l10n.filterAllInvoices,
                        isSelected: _filterStatus == 'all',
                        onSelected: (_) => _setFilter('all'),
                      ),
                      const SizedBox(width: 8),
                      FilterChipWidget(
                        label: l10n.filterDraft,
                        isSelected: _filterStatus == 'draft',
                        onSelected: (_) => _setFilter('draft'),
                        color: Colors.grey,
                        icon: Icons.edit,
                      ),
                      const SizedBox(width: 8),
                      FilterChipWidget(
                        label: l10n.filterSent,
                        isSelected: _filterStatus == 'sent',
                        onSelected: (_) => _setFilter('sent'),
                        color: Colors.blue,
                        icon: Icons.send,
                      ),
                      const SizedBox(width: 8),
                      FilterChipWidget(
                        label: l10n.filterPaid,
                        isSelected: _filterStatus == 'paid',
                        onSelected: (_) => _setFilter('paid'),
                        color: Colors.green,
                        icon: Icons.check_circle,
                      ),
                      const SizedBox(width: 8),
                      FilterChipWidget(
                        label: l10n.filterOverdue,
                        isSelected: _filterStatus == 'overdue',
                        onSelected: (_) => _setFilter('overdue'),
                        color: Colors.red,
                        icon: Icons.warning,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Options d'affichage
              Row(
                children: [
                  // Bouton de personnalisation
                  IconButton(
                    icon: const Icon(Icons.palette),
                    onPressed: () => context.go('/invoice-customization'),
                    tooltip: 'Personnaliser les factures',
                  ),

                  // Tri
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.sort),
                    onSelected: (value) {
                      // TODO: Implémenter le tri
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'date',
                        child: Text(l10n.sortByDate),
                      ),
                      PopupMenuItem(
                        value: 'amount',
                        child: Text(l10n.sortByAmount),
                      ),
                      PopupMenuItem(
                        value: 'client',
                        child: Text(l10n.sortByClient),
                      ),
                      PopupMenuItem(
                        value: 'status',
                        child: Text(l10n.sortByStatus),
                      ),
                    ],
                  ),

                  // Vue grille/liste
                  IconButton(
                    icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
                    onPressed: () {
                      setState(() {
                        _isGridView = !_isGridView;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _setFilter(String filterStatus) {
    setState(() {
      _filterStatus = filterStatus;
    });
    Provider.of<InvoiceProvider>(context, listen: false)
        .filterByStatus(filterStatus);
  }

  Widget _buildQuickStats(BuildContext context) {
    return Consumer<InvoiceProvider>(
      builder: (context, invoiceProvider, child) {
        final l10n = AppLocalizations.of(context)!;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatChip(
                  context,
                  l10n.total,
                  invoiceProvider.totalInvoices.toString(),
                  Icons.receipt_long,
                  Colors.blue,
                ),
                const SizedBox(width: 12),
                _buildStatChip(
                  context,
                  l10n.pending,
                  invoiceProvider.pendingInvoices.toString(),
                  Icons.schedule,
                  Colors.orange,
                ),
                const SizedBox(width: 12),
                _buildStatChip(
                  context,
                  l10n.paid,
                  invoiceProvider.paidInvoices.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
                const SizedBox(width: 12),
                Text(
                  // CA reste utilisé tel quel car c'est un terme financier souvent abrégé
                  'CA: ${AppUtils.formatCurrency(invoiceProvider.totalRevenue)}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatChip(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            '$label: $value',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(
    BuildContext context,
    List invoices,
    bool isDesktop,
    bool isTablet,
  ) {
    final crossAxisCount = isDesktop ? 3 : (isTablet ? 2 : 1);

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: invoices.length,
      itemBuilder: (context, index) {
        return InvoiceCard(invoice: invoices[index]);
      },
    );
  }

  Widget _buildListView(BuildContext context, List invoices) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: invoices.length,
      itemBuilder: (context, index) {
        return InvoiceListItem(invoice: invoices[index]);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.invoicesEmptyTitle,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.invoicesEmptySubtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.goToCreateInvoice(),
            icon: const Icon(Icons.receipt_long),
            label: Text(AppLocalizations.of(context)!.createInvoice),
          ),
        ],
      ),
    );
  }
}

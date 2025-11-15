import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:go_router/go_router.dart';

import '../../providers/client_provider.dart';
import '../../config/app_router.dart';
import '../../main.dart';
import '../../widgets/clients/client_card.dart';
import '../../widgets/clients/client_list_item.dart';
import '../../widgets/common/search_bar_widget.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common/filter_chip_widget.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  bool _isGridView = true;
  String _filterType = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ClientProvider>(context, listen: false).loadClients();
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
          
          // Liste/Grille des clients
          Expanded(
            child: Consumer<ClientProvider>(
              builder: (context, clientProvider, child) {
                if (clientProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (clientProvider.errorMessage != null) {
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
                          clientProvider.errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => clientProvider.loadClients(),
                          child: Text(AppLocalizations.of(context)!.retry),
                        ),
                      ],
                    ),
                  );
                }

                final clients = clientProvider.filteredClients;

                if (clients.isEmpty) {
                  return _buildEmptyState(context);
                }

                return RefreshIndicator(
                  onRefresh: () => clientProvider.loadClients(),
                  child: _isGridView
                      ? _buildGridView(context, clients, isDesktop, isTablet)
                      : _buildListView(context, clients),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.goToAddClient(),
        icon: const Icon(Icons.person_add),
        label: Text(l10n.addClient),
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
          Consumer<ClientProvider>(
            builder: (context, clientProvider, child) {
              return SearchBarWidget(
                hintText: l10n.clientsSearchHint,
                onChanged: (query) => clientProvider.searchClients(query),
                onClear: () => clientProvider.clearFilters(),
              );
            },
          ),
          
          const SizedBox(height: 12),
          
          // Filtres et options d'affichage
          Row(
            children: [
              // Filtres par type
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChipWidget(
                        label: l10n.filterAllClients,
                        isSelected: _filterType == 'all',
                        onSelected: (_) => _setFilter('all'),
                      ),
                      const SizedBox(width: 8),
                      FilterChipWidget(
                        label: l10n.filterPositiveCredit,
                        isSelected: _filterType == 'positive_credit',
                        onSelected: (_) => _setFilter('positive_credit'),
                        color: Colors.green,
                        icon: Icons.trending_up,
                      ),
                      const SizedBox(width: 8),
                      FilterChipWidget(
                        label: l10n.filterNegativeCredit,
                        isSelected: _filterType == 'negative_credit',
                        onSelected: (_) => _setFilter('negative_credit'),
                        color: Colors.red,
                        icon: Icons.trending_down,
                      ),
                      const SizedBox(width: 8),
                      FilterChipWidget(
                        label: l10n.filterActiveClients,
                        isSelected: _filterType == 'active',
                        onSelected: (_) => _setFilter('active'),
                        color: Colors.blue,
                        icon: Icons.check_circle,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Options d'affichage
              Row(
                children: [
                  // Tri
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.sort),
                    onSelected: (value) {
                      // TODO: Implémenter le tri
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'name',
                        child: Text(l10n.sortByName),
                      ),
                      PopupMenuItem(
                        value: 'credit',
                        child: Text(l10n.sortByCredit),
                      ),
                      PopupMenuItem(
                        value: 'last_purchase',
                        child: Text(l10n.sortByLastPurchase),
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

  void _setFilter(String filterType) {
    setState(() {
      _filterType = filterType;
    });
    Provider.of<ClientProvider>(context, listen: false).filterClients(filterType);
  }

  Widget _buildQuickStats(BuildContext context) {
    return Consumer<ClientProvider>(
      builder: (context, clientProvider, child) {
        final l10n = AppLocalizations.of(context)!;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _buildStatChip(
                context,
                l10n.clientsTotalLabel,
                clientProvider.totalClients.toString(),
                Icons.people,
                Colors.blue,
              ),
              const SizedBox(width: 12),
              _buildStatChip(
                context,
                l10n.clientsPositiveCreditShort,
                clientProvider.clientsWithPositiveCredit.toString(),
                Icons.trending_up,
                Colors.green,
              ),
              const SizedBox(width: 12),
              _buildStatChip(
                context,
                l10n.clientsNegativeCreditShort,
                clientProvider.clientsWithNegativeCredit.toString(),
                Icons.trending_down,
                Colors.red,
              ),
              const Spacer(),
              Text(
                '${l10n.totalCreditLabel}: ${AppUtils.formatCurrency(clientProvider.totalCreditBalance)}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
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
    List clients,
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
        childAspectRatio: 1.4,
      ),
      itemCount: clients.length,
      itemBuilder: (context, index) {
        return ClientCard(client: clients[index]);
      },
    );
  }

  Widget _buildListView(BuildContext context, List clients) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: clients.length,
      itemBuilder: (context, index) {
        return ClientListItem(client: clients[index]);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.clientsEmptyTitle,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.clientsEmptySubtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.goToAddClient(),
            icon: const Icon(Icons.person_add),
            label: Text(AppLocalizations.of(context)!.addClient),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:go_router/go_router.dart';

import '../../providers/supplier_provider.dart';
import '../../config/app_router.dart';
import '../../main.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/suppliers/supplier_card.dart';
import '../../widgets/suppliers/supplier_list_item.dart';
import '../../widgets/common/search_bar_widget.dart';

class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SupplierProvider>(context, listen: false).loadSuppliers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Column(
        children: [
          // Barre de recherche
          _buildSearchSection(context, l10n),
          
          // Statistiques rapides
          _buildQuickStats(context, l10n),
          
          // Liste/Grille des fournisseurs
          Expanded(
            child: Consumer<SupplierProvider>(
              builder: (context, supplierProvider, child) {
                if (supplierProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (supplierProvider.errorMessage != null) {
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
                          l10n.erreurDeChargement,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          supplierProvider.errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => supplierProvider.loadSuppliers(),
                          child: Text(l10n.retry),
                        ),
                      ],
                    ),
                  );
                }

                final suppliers = supplierProvider.suppliers;

                if (suppliers.isEmpty) {
                  return _buildEmptyState(context);
                }

                return RefreshIndicator(
                  onRefresh: () => supplierProvider.loadSuppliers(),
                  child: _isGridView
                      ? _buildGridView(context, suppliers, isDesktop, isTablet)
                      : _buildListView(context, suppliers),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.goToAddSupplier(),
        icon: const Icon(Icons.add_business),
        label: Text(l10n.addSupplier),
      ),
    );
  }

  Widget _buildSearchSection(BuildContext context, AppLocalizations l10n) {
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
      child: Row(
        children: [
          Expanded(
            child: Consumer<SupplierProvider>(
              builder: (context, supplierProvider, child) {
                return SearchBarWidget(
                  hintText: l10n.suppliersSearchHint,
                  onChanged: (query) => supplierProvider.searchSuppliers(query),
                  onClear: () => supplierProvider.clearSearch(),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
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
    );
  }

  Widget _buildQuickStats(BuildContext context, AppLocalizations l10n) {
    return Consumer<SupplierProvider>(
      builder: (context, supplierProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _buildStatChip(
                context,
                l10n.suppliersTotalLabel,
                supplierProvider.totalSuppliers.toString(),
                Icons.business,
                Colors.blue,
              ),
              const SizedBox(width: 12),
              _buildStatChip(
                context,
                l10n.suppliersActiveLabel,
                supplierProvider.activeSuppliers.toString(),
                Icons.check_circle,
                Colors.green,
              ),
              const SizedBox(width: 12),
              _buildStatChip(
                context,
                l10n.suppliersProductsLabel,
                supplierProvider.totalProducts.toString(),
                Icons.inventory_2,
                Colors.orange,
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
    List suppliers,
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
      itemCount: suppliers.length,
      itemBuilder: (context, index) {
        return SupplierCard(supplier: suppliers[index]);
      },
    );
  }

  Widget _buildListView(BuildContext context, List suppliers) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: suppliers.length,
      itemBuilder: (context, index) {
        return SupplierListItem(supplier: suppliers[index]);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            l10n.suppliersEmptyTitle,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.suppliersEmptySubtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.goToAddSupplier(),
            icon: const Icon(Icons.add_business),
            label: Text(l10n.addSupplier),
          ),
        ],
      ),
    );
  }
}

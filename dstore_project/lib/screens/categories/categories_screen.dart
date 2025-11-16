import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:go_router/go_router.dart';

import '../../providers/category_provider.dart';
import '../../config/app_router.dart';
import '../../main.dart';
import '../../widgets/categories/category_card.dart';
import '../../widgets/common/search_bar_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryProvider>(context, listen: false).loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    // Localisation
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Barre de recherche
            _buildSearchSection(context),

            // Statistiques rapides
            _buildStatsSection(context),

            // Liste des catégories
            Expanded(
              child: Consumer<CategoryProvider>(
                builder: (context, categoryProvider, child) {
                  if (categoryProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (categoryProvider.errorMessage != null) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red[300],
                            ),
                            const SizedBox(height: 16),
                            // Message d'erreur traduit
                            Text(
                              l10n.erreurDeChargement,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              categoryProvider.errorMessage!,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () =>
                                  categoryProvider.loadCategories(),
                              child: Text(l10n.retry),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final categories = categoryProvider.categories;

                  if (categories.isEmpty) {
                    return _buildEmptyState(context, l10n);
                  }

                  return RefreshIndicator(
                    onRefresh: () => categoryProvider.loadCategories(),
                    child: _buildCategoriesGrid(
                        context, categories, isDesktop, isTablet),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.goToAddCategory(),
        icon: const Icon(Icons.add),
        label: Text(l10n.add),
      ),
    );
  }

  Widget _buildSearchSection(BuildContext context) {
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
      child: Consumer<CategoryProvider>(
        builder: (context, categoryProvider, child) {
          return SearchBarWidget(
            hintText: l10n.categoriesSearchHint,
            onChanged: (query) => categoryProvider.searchCategories(query),
            onClear: () => categoryProvider.clearSearch(),
          );
        },
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        final l10n = AppLocalizations.of(context)!;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _buildStatChip(
                context,
                l10n.categoriesTotal,
                categoryProvider.totalCategories.toString(),
                Icons.category,
                Colors.blue,
              ),
              const SizedBox(width: 12),
              _buildStatChip(
                context,
                l10n.categoriesActive,
                categoryProvider.activeCategories.toString(),
                Icons.check_circle,
                Colors.green,
              ),
              const SizedBox(width: 12),
              _buildStatChip(
                context,
                l10n.categoriesProducts,
                categoryProvider.totalProductsInCategories.toString(),
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

  Widget _buildCategoriesGrid(
    BuildContext context,
    List categories,
    bool isDesktop,
    bool isTablet,
  ) {
    final crossAxisCount = isDesktop ? 4 : (isTablet ? 3 : 2);
    // Ajustement du ratio pour éviter l'overflow - encore plus réduit pour doubler la taille des images
    final childAspectRatio = isDesktop ? 0.8 : (isTablet ? 0.7 : 0.6);

    return GridView.builder(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 80, // Espace pour le FloatingActionButton
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final productCount =
            Provider.of<CategoryProvider>(context, listen: false)
                .getProductCountForCategory(category.id ?? '');
        return CategoryCard(
          category: category,
          productCount: productCount,
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60), // Espace pour centrer visuellement
            Icon(
              Icons.category_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              l10n.categoriesEmptyTitle,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.categoriesEmptySubtitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[500],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.goToAddCategory(),
              icon: const Icon(Icons.add),
              label: Text(l10n.createCategory),
            ),
            const SizedBox(height: 60), // Espace pour le FloatingActionButton
          ],
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';
import '../../providers/category_provider.dart';
import '../../providers/product_provider.dart';

class CategoryDetailManagementScreen extends StatefulWidget {
  final CategoryModel category;
  const CategoryDetailManagementScreen({super.key, required this.category});

  @override
  State<CategoryDetailManagementScreen> createState() => _CategoryDetailManagementScreenState();
}

class _CategoryDetailManagementScreenState extends State<CategoryDetailManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late bool _active;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.category.name);
    _descCtrl = TextEditingController(text: widget.category.description ?? '');
    _active = widget.category.isActive;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final productsProvider = context.watch<ProductProvider>();
    final List<ProductModel> products = productsProvider.allProducts
        .where((p) => p.categoryId == widget.category.id)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editCategory),
        actions: [
          TextButton.icon(
            onPressed: _saving ? null : _save,
            icon: const Icon(Icons.save),
            label: Text(l10n.save),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Edit form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.editCategory, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: InputDecoration(
                          labelText: l10n.categoryNameLabel,
                          hintText: l10n.categoryNameHint,
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? l10n.categoryNameRequired : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descCtrl,
                        decoration: InputDecoration(hintText: l10n.categoryDescriptionHint),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        value: _active,
                        onChanged: (v) => setState(() => _active = v),
                        title: Text(l10n.categoryActive),
                        subtitle: Text(l10n.categoryActiveHelper),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.icon(
                          onPressed: _saving ? null : _save,
                          icon: const Icon(Icons.save),
                          label: Text(l10n.save),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Products list
            Text(l10n.categoriesProducts, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (products.isEmpty)
              Text(l10n.categoriesEmptyTitle)
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (_, i) {
                  final p = products[i];
                  return ListTile(
                    leading: const Icon(Icons.inventory_2_outlined),
                    title: Text(p.name),
                    subtitle: Text('${l10n.stockActuel}: ${p.stock}'),
                    trailing: Text(p.unitPrice.toStringAsFixed(2)),
                  );
                },
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemCount: products.length,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final updated = widget.category.copyWith(
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      isActive: _active,
    );
    final ok = await context.read<CategoryProvider>().updateCategory(updated);
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.categoryUpdatedSuccess)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.errorOccurred)),
      );
    }
  }
}

import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/product_model.dart';
import '../../models/category_model.dart';

class CategoryDetailScreen extends StatefulWidget {
  final CategoryModel category;
  final List<ProductModel> productsInCategory;
  final Future<void> Function(CategoryModel updated) onSave;

  const CategoryDetailScreen({
    super.key,
    required this.category,
    required this.productsInCategory,
    required this.onSave,
  });

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _colorCtrl;
  bool _active = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.category.name ?? '');
    _descCtrl = TextEditingController(text: widget.category.description ?? '');
    _colorCtrl = TextEditingController(text: widget.category.colorHex ?? '');
    _active = widget.category.active ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _colorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.categoriesProducts, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (widget.productsInCategory.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(l10n.categoriesEmptyTitle),
            )
          else
            ...widget.productsInCategory.map((p) => Card(
              child: ListTile(
                leading: const Icon(Icons.inventory_2_outlined),
                title: Text(p.name ?? '-'),
                subtitle: Text('${l10n.stockActuel}: ${p.stock ?? 0}'),
              ),
            )),
          const Divider(height: 32),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(labelText: l10n.categoryNameLabel, hintText: l10n.categoryNameHint),
                  validator: (v) => (v == null || v.trim().isEmpty) ? l10n.categoryNameRequired : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descCtrl,
                  decoration: InputDecoration(hintText: l10n.categoryDescriptionHint),
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _colorCtrl,
                  decoration: InputDecoration(labelText: l10n.categoryColor, hintText: '#1565C0'),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  value: _active,
                  onChanged: (v) => setState(() => _active = v),
                  title: Text(l10n.categoryActive),
                  subtitle: Text(l10n.categoryActiveHelper),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(onPressed: _saving ? null : _save, icon: const Icon(Icons.save), label: Text(l10n.save)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final updated = widget.category.copyWith(
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      colorHex: _colorCtrl.text.trim(),
      active: _active,
    );
    await widget.onSave(updated);
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.categoryUpdatedSuccess)));
      Navigator.pop(context);
    }
  }
}
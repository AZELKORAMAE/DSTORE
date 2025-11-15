import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/supplier_provider.dart';
import '../../models/supplier_model.dart';
import '../../main.dart';
import '../../l10n/app_localizations.dart';

class AddEditSupplierScreen extends StatefulWidget {
  final String? supplierId;

  const AddEditSupplierScreen({
    super.key,
    this.supplierId,
  });

  @override
  State<AddEditSupplierScreen> createState() => _AddEditSupplierScreenState();
}

class _AddEditSupplierScreenState extends State<AddEditSupplierScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isActive = true;
  bool _isLoading = false;
  SupplierModel? _existingSupplier;

  @override
  void initState() {
    super.initState();
    if (widget.supplierId != null) {
      _loadSupplier();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactPersonController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadSupplier() async {
    if (widget.supplierId == null) return;

    setState(() => _isLoading = true);

    final supplierProvider = Provider.of<SupplierProvider>(context, listen: false);
    final supplier = await supplierProvider.getSupplierById(widget.supplierId!);

    if (supplier != null && mounted) {
      setState(() {
        _existingSupplier = supplier;
        _nameController.text = supplier.name;
        _contactPersonController.text = supplier.contactPerson ?? '';
        _phoneController.text = supplier.phone ?? '';
        _emailController.text = supplier.email ?? '';
        _addressController.text = supplier.address ?? '';
        _cityController.text = supplier.city ?? '';
        _notesController.text = supplier.notes ?? '';
        _isActive = supplier.isActive;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSupplier() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final supplierProvider = Provider.of<SupplierProvider>(context, listen: false);

    final supplier = SupplierModel(
      id: _existingSupplier?.id ?? '',
      userId: '',
      name: _nameController.text.trim(),
      contactPerson: _contactPersonController.text.trim().isNotEmpty 
          ? _contactPersonController.text.trim() 
          : null,
      phone: _phoneController.text.trim().isNotEmpty 
          ? _phoneController.text.trim() 
          : null,
      email: _emailController.text.trim().isNotEmpty 
          ? _emailController.text.trim() 
          : null,
      address: _addressController.text.trim().isNotEmpty 
          ? _addressController.text.trim() 
          : null,
      city: _cityController.text.trim().isNotEmpty 
          ? _cityController.text.trim() 
          : null,
      notes: _notesController.text.trim().isNotEmpty 
          ? _notesController.text.trim() 
          : null,
      isActive: _isActive,
      productCount: _existingSupplier?.productCount,
      totalPurchases: _existingSupplier?.totalPurchases ?? 0.0,
      lastOrderDate: _existingSupplier?.lastOrderDate,
      createdAt: _existingSupplier?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    bool success;
    if (_existingSupplier != null) {
      success = await supplierProvider.updateSupplier(supplier.copyWith(id: _existingSupplier!.id));
    } else {
      success = await supplierProvider.createSupplier(supplier);
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      final l10n = AppLocalizations.of(context)!;
      AppUtils.showSnackBar(
        context,
        _existingSupplier != null
            ? l10n.supplierUpdatedSuccess
            : l10n.supplierCreatedSuccess,
      );
      context.pop();
    } else if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      AppUtils.showSnackBar(
        context,
        supplierProvider.errorMessage ?? l10n.supplierSaveError,
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(_existingSupplier != null ? l10n.editSupplierTitle : l10n.addSupplierTitle),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveSupplier,
              child: Text(l10n.save),
            ),
        ],
      ),
      body: _isLoading && _existingSupplier == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Informations de base
                    _buildBasicInfoSection(),
                    const SizedBox(height: 24),

                    // Informations de contact
                    _buildContactInfoSection(),
                    const SizedBox(height: 24),

                    // Notes et options
                    _buildNotesSection(),
                    const SizedBox(height: 32),

                    // Boutons d'action
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBasicInfoSection() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.basicInfo,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),

            // Company name
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.supplierCompanyNameLabel,
                hintText: l10n.supplierCompanyNameHint,
                prefixIcon: const Icon(Icons.business),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.supplierCompanyNameRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Contact person
            TextFormField(
              controller: _contactPersonController,
              decoration: InputDecoration(
                labelText: l10n.supplierContactPersonLabel,
                hintText: l10n.supplierContactPersonHint,
                prefixIcon: const Icon(Icons.person),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoSection() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.supplierContactInfo,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Téléphone
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: l10n.supplierPhoneLabel,
                hintText: l10n.supplierPhoneHint,
                prefixIcon: const Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            // Email
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: l10n.supplierEmailLabel,
                hintText: l10n.supplierEmailHint,
                prefixIcon: const Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return l10n.invalidFormat;
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Adresse
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: l10n.supplierAddressLabel,
                hintText: l10n.supplierAddressHint,
                prefixIcon: const Icon(Icons.location_on),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Ville
            TextFormField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: l10n.supplierCityLabel,
                hintText: l10n.supplierCityHint,
                prefixIcon: const Icon(Icons.location_city),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.supplierNotesOptions,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: l10n.supplierNotesLabel,
                hintText: l10n.supplierNotesHint,
                prefixIcon: const Icon(Icons.note),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Fournisseur actif
            SwitchListTile(
              title: Text(l10n.supplierActiveLabel),
              subtitle: Text(l10n.supplierActiveHelper),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => context.pop(),
            child: Text(l10n.cancel),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveSupplier,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(_existingSupplier != null ? l10n.edit : l10n.create),
          ),
        ),
      ],
    );
  }
}

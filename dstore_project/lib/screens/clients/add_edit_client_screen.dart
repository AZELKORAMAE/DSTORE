import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/client_provider.dart';
import '../../models/client_model.dart';
import '../../main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddEditClientScreen extends StatefulWidget {
  final String? clientId;

  const AddEditClientScreen({
    super.key,
    this.clientId,
  });

  @override
  State<AddEditClientScreen> createState() => _AddEditClientScreenState();
}

class _AddEditClientScreenState extends State<AddEditClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _notesController = TextEditingController();
  final _creditLimitController = TextEditingController();

  bool _isActive = true;
  bool _isLoading = false;
  ClientModel? _existingClient;

  @override
  void initState() {
    super.initState();
    _creditLimitController.text = '0';
    if (widget.clientId != null) {
      _loadClient();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _notesController.dispose();
    _creditLimitController.dispose();
    super.dispose();
  }

  Future<void> _loadClient() async {
    if (widget.clientId == null) return;

    setState(() => _isLoading = true);

    final clientProvider = Provider.of<ClientProvider>(context, listen: false);
    final client = await clientProvider.getClientById(widget.clientId!);

    if (client != null && mounted) {
      setState(() {
        _existingClient = client;
        _nameController.text = client.name;
        _phoneController.text = client.phone ?? '';
        _emailController.text = client.email ?? '';
        _addressController.text = client.address ?? '';
        _cityController.text = client.city ?? '';
        _notesController.text = client.notes ?? '';
        _creditLimitController.text = client.creditLimit.toString();
        _isActive = client.isActive;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveClient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final clientProvider = Provider.of<ClientProvider>(context, listen: false);

    final client = ClientModel(
      id: _existingClient?.id ?? '',
      userId: '',
      name: _nameController.text.trim(),
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
      currentCredit: _existingClient?.currentCredit ?? 0.0,
      creditLimit: double.parse(_creditLimitController.text),
      totalPurchases: _existingClient?.totalPurchases ?? 0.0,
      lastPurchaseDate: _existingClient?.lastPurchaseDate,
      isActive: _isActive,
      createdAt: _existingClient?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    bool success;
    if (_existingClient != null) {
      success = await clientProvider
          .updateClient(client.copyWith(id: _existingClient!.id));
    } else {
      success = await clientProvider.createClient(client);
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      final l10n = AppLocalizations.of(context)!;
      final message = _existingClient != null
          ? l10n.clientUpdatedSuccess
          : l10n.clientCreatedSuccess;
      AppUtils.showSnackBar(
        context,
        message,
      );
      context.pop();
    } else if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      final errorMsg = clientProvider.errorMessage ?? l10n.saveErrorMessage;
      AppUtils.showSnackBar(
        context,
        errorMsg,
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _existingClient != null
              ? AppLocalizations.of(context)!.editClient
              : AppLocalizations.of(context)!.addClientTitle,
        ),
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
              onPressed: _saveClient,
              child: Text(AppLocalizations.of(context)!.save),
            ),
        ],
      ),
      body: _isLoading && _existingClient == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Aperçu du client
                    if (_existingClient != null) _buildClientPreview(),
                    if (_existingClient != null) const SizedBox(height: 24),

                    // Informations personnelles
                    _buildPersonalInfoSection(),
                    const SizedBox(height: 24),

                    // Informations de contact
                    _buildContactInfoSection(),
                    const SizedBox(height: 24),

                    // Crédit et limites
                    _buildCreditSection(),
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

  Widget _buildClientPreview() {
    if (_existingClient == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.clientPreview,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor:
                      Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Text(
                    _existingClient!.initials,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _existingClient!.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '${AppLocalizations.of(context)!.creditLabel} ',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          Text(
                            AppUtils.formatCurrency(
                                _existingClient!.creditBalance),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _existingClient!.creditBalance >= 0
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                        if (_existingClient!.totalPurchases > 0) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${AppLocalizations.of(context)!.totalPurchasesLabel} ${AppUtils.formatCurrency(_existingClient!.totalPurchases)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.personalInfo,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),

            // Nom complet
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.clientNameLabel,
                hintText: AppLocalizations.of(context)!.clientNameHint,
                prefixIcon: const Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppLocalizations.of(context)!.clientNameRequired;
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.contactInfo,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),

            // Téléphone
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.phoneLabel,
                hintText: AppLocalizations.of(context)!.phoneHint,
                prefixIcon: const Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            // Email
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.emailLabel,
                hintText: AppLocalizations.of(context)!.emailHint,
                prefixIcon: const Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return AppLocalizations.of(context)!.invalidEmail;
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
                labelText: AppLocalizations.of(context)!.addressLabel,
                hintText: AppLocalizations.of(context)!.addressHint,
                prefixIcon: const Icon(Icons.location_on),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Ville
            TextFormField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.cityLabel,
                hintText: AppLocalizations.of(context)!.cityHint,
                prefixIcon: const Icon(Icons.location_city),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.creditAndLimits,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),

            // Limite de crédit
            TextFormField(
              controller: _creditLimitController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.creditLimitLabel,
                hintText: AppLocalizations.of(context)!.creditLimitHint,
                suffixText: 'DH',
                prefixIcon: const Icon(Icons.account_balance_wallet),
                helperText:
                    AppLocalizations.of(context)!.creditLimitHelper,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)!.creditLimitRequired;
                }
                if (double.tryParse(value) == null) {
                  return AppLocalizations.of(context)!.invalidAmount;
                }
                return null;
              },
            ),

            if (_existingClient != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.currentCreditLabel,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        Text(
                          AppUtils.formatCurrency(
                              _existingClient!.creditBalance),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _existingClient!.creditBalance >= 0
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.totalPurchasesLabel,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        Text(
                          AppUtils.formatCurrency(
                              _existingClient!.totalPurchases),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.notesOptions,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.notesLabel,
                hintText: AppLocalizations.of(context)!.notesHint,
                prefixIcon: const Icon(Icons.note),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Client actif
            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.clientActive),
              subtitle: Text(AppLocalizations.of(context)!.clientActiveHelper),
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
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => context.pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveClient,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(_existingClient != null
                    ? AppLocalizations.of(context)!.edit
                    : AppLocalizations.of(context)!.addClient),
          ),
        ),
      ],
    );
  }
}

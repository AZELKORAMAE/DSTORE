import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/client_provider.dart';
import '../../models/client_model.dart';
import '../../models/credit_model.dart';
import '../../services/credit_service.dart';
import '../../config/app_router.dart';
import '../../utils/app_utils.dart';

class ClientDetailScreen extends StatefulWidget {
  final String clientId;

  const ClientDetailScreen({
    super.key,
    required this.clientId,
  });

  @override
  State<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends State<ClientDetailScreen> {
  ClientModel? _client;
  bool _isLoading = true;
  List<CreditModel> _clientCredits = [];
  bool _isLoadingCredits = false;
  final CreditService _creditService = CreditService();

  @override
  void initState() {
    super.initState();
    _loadClient();
  }

  Future<void> _loadClient() async {
    setState(() => _isLoading = true);

    final clientProvider = Provider.of<ClientProvider>(context, listen: false);
    final client = await clientProvider.getClientById(widget.clientId);

    if (mounted) {
      setState(() {
        _client = client;
        _isLoading = false;
      });

      // Charger les crédits après avoir chargé le client
      if (_client != null) {
        _loadClientCredits();
      }
    }
  }

  Future<void> _loadClientCredits() async {
    setState(() => _isLoadingCredits = true);

    try {
      print('🔍 Chargement des crédits pour client: ${widget.clientId}');
      final credits = await _creditService.getCreditsByClient(widget.clientId);
      print('✅ Crédits trouvés: ${credits.length}');

      if (mounted) {
        setState(() {
          _clientCredits = credits;
          _isLoadingCredits = false;
        });
        print('🎯 UI: setState appelé avec ${_clientCredits.length} crédits');
      }
    } catch (e) {
      print('❌ Erreur chargement crédits client: $e');
      if (mounted) {
        setState(() => _isLoadingCredits = false);
      }
    }
  }

  Future<void> _showCreditAdjustmentDialog() async {
    if (_client == null) return;

    final TextEditingController amountController = TextEditingController();
    final TextEditingController reasonController = TextEditingController();
    String adjustmentType = 'add';

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Ajuster le crédit'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Type d'ajustement
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'add',
                    label: Text('Ajouter'),
                    icon: Icon(Icons.add),
                  ),
                  ButtonSegment(
                    value: 'remove',
                    label: Text('Retirer'),
                    icon: Icon(Icons.remove),
                  ),
                ],
                selected: {adjustmentType},
                onSelectionChanged: (Set<String> selection) {
                  setDialogState(() {
                    adjustmentType = selection.first;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Montant
              TextField(
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: 'Montant',
                  hintText: '0.00',
                  suffixText: 'DH',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Raison
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Raison',
                  hintText: 'Ex: Paiement, Remboursement...',
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text);
                if (amount != null && amount > 0) {
                  Navigator.of(context).pop({
                    'type': adjustmentType,
                    'amount': amount,
                    'reason': reasonController.text.trim(),
                  });
                }
              },
              child: const Text('Confirmer'),
            ),
          ],
        ),
      ),
    );

    if (result != null && mounted) {
      await _adjustCredit(result);
    }
  }

  Future<void> _adjustCredit(Map<String, dynamic> adjustment) async {
    if (_client == null) return;

    final clientProvider = Provider.of<ClientProvider>(context, listen: false);
    final type = adjustment['type'] as String;
    final amount = adjustment['amount'] as double;
    final reason = adjustment['reason'] as String;

    final adjustmentAmount = type == 'add' ? amount : -amount;
    final success = await clientProvider.adjustCredit(
      _client!.id,
      adjustmentAmount,
      reason.isNotEmpty ? reason : 'Ajustement manuel',
    );

    if (success && mounted) {
      AppUtils.showSnackBar(context, 'Crédit mis à jour avec succès');
      await _loadClient(); // Recharger le client
    } else if (mounted) {
      AppUtils.showSnackBar(
        context,
        clientProvider.errorMessage ?? 'Erreur lors de la mise à jour',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_client?.name ?? 'Détails du client'),
        actions: [
          if (_client != null) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => context.goToEditClient(_client!.id),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'adjust_credit':
                    _showCreditAdjustmentDialog();
                    break;
                  case 'delete':
                    _showDeleteConfirmation();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'adjust_credit',
                  child: ListTile(
                    leading: Icon(Icons.account_balance_wallet),
                    title: Text('Ajuster le crédit'),
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Supprimer', style: TextStyle(color: Colors.red)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _client == null
              ? _buildErrorState()
              : _buildClientDetails(),
    );
  }

  Widget _buildErrorState() {
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
            'Client non trouvé',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.pop(),
            child: const Text('Retour'),
          ),
        ],
      ),
    );
  }

  Widget _buildClientDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec informations principales
          _buildHeaderSection(),
          const SizedBox(height: 24),

          // Statistiques du crédit
          _buildCreditSection(),
          const SizedBox(height: 24),

          // Historique des crédits
          _buildCreditHistorySection(),
          const SizedBox(height: 24),

          // Informations de contact
          _buildContactSection(),
          const SizedBox(height: 24),

          // Actions rapides
          _buildActionsSection(),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Text(
                _client!.initials,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                  fontSize: 24,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Informations principales
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _client!.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 8),

                  // Statut du crédit
                  _buildCreditStatus(),
                  
                  const SizedBox(height: 8),

                  // Informations supplémentaires
                  if (_client!.totalPurchases > 0) ...[
                    Text(
                      'Total achats: ${AppUtils.formatCurrency(_client!.totalPurchases)}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  
                  if (_client!.lastPurchaseDate != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Dernier achat: ${AppUtils.formatDate(_client!.lastPurchaseDate!)}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditStatus() {
    Color color;
    String text;
    IconData icon;

    if (_client!.creditBalance > 0) {
      color = Colors.green;
      text = 'Crédit positif';
      icon = Icons.trending_up;
    } else if (_client!.creditBalance < 0) {
      color = Colors.red;
      text = 'Dette';
      icon = Icons.trending_down;
    } else {
      color = Colors.grey;
      text = 'Neutre';
      icon = Icons.remove;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
              'Crédit et finances',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildCreditCard(
                    'Crédit actuel',
                    AppUtils.formatCurrency(_client!.creditBalance),
                    _client!.creditBalance >= 0 ? Colors.green : Colors.red,
                    Icons.account_balance_wallet,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildCreditCard(
                    'Limite de crédit',
                    AppUtils.formatCurrency(_client!.creditLimit),
                    Colors.blue,
                    Icons.credit_card,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildCreditCard(
                    'Crédit disponible',
                    AppUtils.formatCurrency(_client!.availableCredit),
                    Colors.orange,
                    Icons.savings,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildCreditCard(
                    'Utilisation',
                    '${_client!.creditUsagePercentage.toStringAsFixed(1)}%',
                    _getCreditUsageColor(),
                    Icons.pie_chart,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCreditUsageColor() {
    final percentage = _client!.creditUsagePercentage;
    if (percentage >= 100) return Colors.red;
    if (percentage >= 80) return Colors.orange;
    if (percentage >= 50) return Colors.yellow[700]!;
    return Colors.green;
  }

  Widget _buildCreditCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 16,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations de contact',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            if (_client!.phone != null)
              _buildContactRow(Icons.phone, 'Téléphone', _client!.phone!),
            
            if (_client!.email != null)
              _buildContactRow(Icons.email, 'Email', _client!.email!),
            
            if (_client!.fullAddress.isNotEmpty)
              _buildContactRow(Icons.location_on, 'Adresse', _client!.fullAddress),
            
            if (_client!.notes != null && _client!.notes!.isNotEmpty)
              _buildContactRow(Icons.note, 'Notes', _client!.notes!),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions rapides',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showCreditAdjustmentDialog,
                    icon: const Icon(Icons.account_balance_wallet),
                    label: const Text('Ajuster crédit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.goToEditClient(_client!.id),
                    icon: const Icon(Icons.edit),
                    label: const Text('Modifier'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation() async {
    final confirmed = await AppUtils.showConfirmDialog(
      context,
      title: 'Supprimer le client',
      message: 'Êtes-vous sûr de vouloir supprimer "${_client!.name}" ?\n\nCette action est irréversible.',
    );

    if (confirmed && mounted) {
      final clientProvider = Provider.of<ClientProvider>(context, listen: false);
      final success = await clientProvider.deleteClient(_client!.id);

      if (success && mounted) {
        AppUtils.showSnackBar(context, 'Client supprimé avec succès');
        context.pop();
      } else if (mounted) {
        AppUtils.showSnackBar(
          context,
          clientProvider.errorMessage ?? 'Erreur lors de la suppression',
          isError: true,
        );
      }
    }
  }

  Widget _buildCreditHistorySection() {
    print('🎯 UI: _buildCreditHistorySection appelé avec ${_clientCredits.length} crédits, isLoading: $_isLoadingCredits');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Historique des crédits',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_isLoadingCredits)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            if (_isLoadingCredits)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_clientCredits.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.credit_card_off,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Aucun crédit',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ce client n\'a aucun crédit en cours ou historique',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: [
                  // Résumé des crédits
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildCreditSummaryItem(
                          'Total crédits',
                          _clientCredits.length.toString(),
                          Icons.credit_card,
                        ),
                        _buildCreditSummaryItem(
                          'En cours',
                          _clientCredits.where((c) => c.status == CreditPaymentStatus.pending).length.toString(),
                          Icons.pending,
                        ),
                        _buildCreditSummaryItem(
                          'Payés',
                          _clientCredits.where((c) => c.status == CreditPaymentStatus.paid).length.toString(),
                          Icons.check_circle,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Liste des crédits
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _clientCredits.length > 5 ? 5 : _clientCredits.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final credit = _clientCredits[index];
                      return _buildCreditItem(credit);
                    },
                  ),

                  if (_clientCredits.length > 5) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        // Navigation vers l'écran complet des crédits
                        // TODO: Implémenter la navigation
                      },
                      child: Text('Voir tous les crédits (${_clientCredits.length})'),
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildCreditItem(CreditModel credit) {
    final statusColor = credit.status == CreditPaymentStatus.paid
        ? Colors.green
        : credit.status == CreditPaymentStatus.overdue
            ? Colors.red
            : Colors.orange;

    final statusText = credit.status == CreditPaymentStatus.paid
        ? 'Payé'
        : credit.status == CreditPaymentStatus.overdue
            ? 'En retard'
            : 'En cours';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Crédit du ${AppUtils.formatDate(credit.createdAt)}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Montant total',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    AppUtils.formatCurrency(credit.totalAmount),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Restant',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    AppUtils.formatCurrency(credit.remainingAmount),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: credit.remainingAmount > 0 ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (credit.dueDate != null) ...[
            const SizedBox(height: 4),
            Text(
              'Échéance: ${AppUtils.formatDate(credit.dueDate!)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

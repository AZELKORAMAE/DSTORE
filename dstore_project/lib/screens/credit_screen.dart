import 'package:flutter/material.dart';
import '../widgets/credit/credit_list_widget.dart';
import '../services/credit_service.dart';
import '../services/client_service.dart';
import '../models/client_model.dart';
import '../models/credit_model.dart';
import '../config/app_theme.dart';
import '../config/app_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CreditScreen extends StatefulWidget {
  const CreditScreen({Key? key}) : super(key: key);

  @override
  State<CreditScreen> createState() => _CreditScreenState();
}

class _CreditScreenState extends State<CreditScreen> {
  final CreditService _creditService = CreditService();
  final ClientService _clientService = ClientService();

  List<ClientModel> _clientsWithCredits = [];
  Map<String, List<CreditModel>> _clientCredits = {};
  Map<String, double> _clientTotalCredits = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadClientsWithCredits();
  }

  Future<void> _loadClientsWithCredits() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Charger tous les crédits
      final allCredits = await _creditService.getAllCredits();
      print('📊 Total crédits trouvés: ${allCredits.length}');

      // Grouper les crédits par client
      final Map<String, List<CreditModel>> creditsByClient = {};
      final Map<String, double> totalsByClient = {};

      for (final credit in allCredits) {
        if (!creditsByClient.containsKey(credit.clientId)) {
          creditsByClient[credit.clientId] = [];
          totalsByClient[credit.clientId] = 0.0;
        }
        creditsByClient[credit.clientId]!.add(credit);
        totalsByClient[credit.clientId] = totalsByClient[credit.clientId]! + credit.remainingAmount;
      }

      // Charger les informations des clients qui ont des crédits
      final List<ClientModel> clientsWithCredits = [];
      for (final clientId in creditsByClient.keys) {
        try {
          final client = await _clientService.getClientById(clientId);
          if (client != null) {
            clientsWithCredits.add(client);
          }
        } catch (e) {
          print('⚠️ Erreur chargement client $clientId: $e');
        }
      }

      setState(() {
        _clientsWithCredits = clientsWithCredits;
        _clientCredits = creditsByClient;
        _clientTotalCredits = totalsByClient;
        _isLoading = false;
      });

      print('✅ ${clientsWithCredits.length} clients avec crédits chargés');
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      print('❌ Erreur chargement clients avec crédits: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.clientsWithCreditsTitle),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadClientsWithCredits,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.loadingCredits),
          ],
        ),
      );
    }

    if (_error != null) {
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
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadClientsWithCredits,
              child: Text(AppLocalizations.of(context)!.retry),
            ),
          ],
        ),
      );
    }

    if (_clientsWithCredits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.credit_card_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.noCreditsTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.noCreditsSubtitle,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildSummaryCard(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadClientsWithCredits,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _clientsWithCredits.length,
              itemBuilder: (context, index) {
                final client = _clientsWithCredits[index];
                return _buildClientCreditCard(client);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    final totalClients = _clientsWithCredits.length;
    final totalAmount = _clientTotalCredits.values.fold(0.0, (sum, amount) => sum + amount);
    final totalCredits = _clientCredits.values.fold(0, (sum, credits) => sum + credits.length);
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.creditsSummary,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    l10n.clientsLabel,
                    '$totalClients',
                    Icons.people,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    l10n.creditsLabel,
                    '$totalCredits',
                    Icons.credit_card,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    l10n.totalAmountLabel,
                    '${totalAmount.toStringAsFixed(2)} DH',
                    Icons.account_balance_wallet,
                    Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildClientCreditCard(ClientModel client) {
    final clientCredits = _clientCredits[client.id] ?? [];
    final totalAmount = _clientTotalCredits[client.id] ?? 0.0;
    final creditCount = clientCredits.length;

    // Calculer les crédits en retard
    final overdueCredits = clientCredits.where((credit) {
      return credit.dueDate.isBefore(DateTime.now()) &&
             credit.status != CreditPaymentStatus.paid;
    }).length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showClientCreditsDetail(client),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppTheme.primaryColor,
                    child: Text(
                      client.name.isNotEmpty ? client.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          client.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (client.phone?.isNotEmpty == true) ...[
                          const SizedBox(height: 2),
                          Text(
                            client.phone!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (overdueCredits > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.overdueLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildCreditInfo(
                      AppLocalizations.of(context)!.creditsLabel,
                      '$creditCount',
                      Icons.credit_card,
                      Colors.blue,
                    ),
                  ),
                  Expanded(
                    child: _buildCreditInfo(
                      AppLocalizations.of(context)!.totalAmountLabel,
                      '${totalAmount.toStringAsFixed(2)} DH',
                      Icons.account_balance_wallet,
                      overdueCredits > 0 ? Colors.red : Colors.orange,
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

  Widget _buildCreditInfo(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showClientCreditsDetail(ClientModel client) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${AppLocalizations.of(context)!.creditsLabel} ${client.name}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CreditListWidget(
                  clientId: client.id,
                  showClientName: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

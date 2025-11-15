import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/client_service.dart';
import '../../config/app_theme.dart';
import '../../models/client_model.dart';
import '../common/overflow_safe_widgets.dart';

class RecentClientsCard extends StatefulWidget {
  const RecentClientsCard({Key? key}) : super(key: key);

  @override
  State<RecentClientsCard> createState() => _RecentClientsCardState();
}

class _RecentClientsCardState extends State<RecentClientsCard> {
  final ClientService _clientService = ClientService();
  List<ClientModel> _clients = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRecentClients();
  }

  Future<void> _loadRecentClients() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final allClients = await _clientService.getAllClients();
      final clients = allClients.take(5).toList();

      if (mounted) {
        setState(() {
          _clients = clients;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.people,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Clients récents',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadRecentClients,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error != null)
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 48),
                    const SizedBox(height: 8),
                    Text(
                      'Erreur de chargement',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _error!,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _loadRecentClients,
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              )
            else if (_clients.isNotEmpty)
              _buildClientsContent()
            else
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.person_add,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Aucun client trouvé',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ajoutez vos premiers clients pour les voir apparaître ici',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[500],
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientsContent() {
    return Column(
      children: [
        // Résumé
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total clients actifs',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_clients.length}',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[700],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.group,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Liste des clients
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _clients.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final clientSummary = _clients[index];
            return _buildClientTile(clientSummary);
          },
        ),

        const SizedBox(height: 16),

        // Bouton voir tous
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              // Navigation vers la liste complète des clients
              // TODO: Implémenter la navigation
            },
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Voir tous les clients'),
          ),
        ),
      ],
    );
  }

  Widget _buildClientTile(ClientModel client) {
    return SafeListTileFactory.withAvatar(
      avatarText: client.name.isNotEmpty ? client.name[0].toUpperCase() : '?',
      avatarBackgroundColor: AppTheme.primaryColor.withOpacity(0.1),
      avatarForegroundColor: AppTheme.primaryColor,
      title: client.name,
      titleStyle: const TextStyle(
        fontWeight: FontWeight.w600,
      ),
      subtitle: _buildClientSubtitle(client),
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      titleMaxLines: 1,
      subtitleMaxLines: 3,
    );
  }

  String _buildClientSubtitle(ClientModel client) {
    List<String> subtitleParts = [];
    
    if ((client.email ?? '').isNotEmpty) {
      subtitleParts.add(client.email!);
    }
    
    if ((client.phone ?? '').isNotEmpty) {
      subtitleParts.add(client.phone!);
    }
    
    // Ajouter les informations de factures si disponibles
    // TODO: Ajouter les statistiques de factures
    
    return subtitleParts.join('\n');
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.receipt,
                size: 14,
                color: Colors.grey[500],
              ),
              const SizedBox(width: 4),
              Text(
                '0 facture',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatCurrency(0.0),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Total dépensé',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 10,
            ),
          ),
        ],
      ),
      onTap: () {
        // TODO: Navigation vers le détail du client
      },
    );
  }

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(2)} DH';
  }
}

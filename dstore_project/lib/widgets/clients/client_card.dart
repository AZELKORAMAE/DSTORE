import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/client_model.dart';
import '../../config/app_router.dart';
import '../../main.dart';

class ClientCard extends StatelessWidget {
  final ClientModel client;

  const ClientCard({
    super.key,
    required this.client,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => context.goToClientDetail(client.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec avatar et statut
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Text(
                      client.initials,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  const Spacer(),
                  _buildCreditIndicator(context),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Nom du client
              Text(
                client.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 4),
              
              // Téléphone
              if (client.phone != null)
                Row(
                  children: [
                    Icon(
                      Icons.phone,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        client.phone!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              
              const SizedBox(height: 4),
              
              // Email
              if (client.email != null)
                Row(
                  children: [
                    Icon(
                      Icons.email,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        client.email!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              
              const Spacer(),
              
              // Crédit et dernière visite
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Crédit',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        AppUtils.formatCurrency(client.creditBalance),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getCreditColor(),
                        ),
                      ),
                    ],
                  ),
                  if (client.lastPurchaseDate != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Dernier achat',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          AppUtils.formatDateShort(client.lastPurchaseDate!),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreditIndicator(BuildContext context) {
    Color color = _getCreditColor();
    IconData icon;
    
    if (client.creditBalance > 0) {
      icon = Icons.trending_up;
    } else if (client.creditBalance < 0) {
      icon = Icons.trending_down;
    } else {
      icon = Icons.remove;
      color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        size: 16,
        color: color,
      ),
    );
  }

  Color _getCreditColor() {
    if (client.creditBalance > 0) {
      return Colors.green;
    } else if (client.creditBalance < 0) {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }
}

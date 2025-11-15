import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/client_model.dart';
import '../../config/app_router.dart';
import '../../main.dart';

class ClientListItem extends StatelessWidget {
  final ClientModel client;

  const ClientListItem({
    super.key,
    required this.client,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Text(
            client.initials,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        title: Text(
          client.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (client.phone != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.phone,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    client.phone!,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
            if (client.email != null) ...[
              const SizedBox(height: 2),
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
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            if (client.lastPurchaseDate != null) ...[
              const SizedBox(height: 4),
              Text(
                'Dernier achat: ${AppUtils.formatDateShort(client.lastPurchaseDate!)}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              AppUtils.formatCurrency(client.creditBalance),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _getCreditColor(),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            _buildCreditIndicator(context),
          ],
        ),
        onTap: () => context.goToClientDetail(client.id),
      ),
    );
  }

  Widget _buildCreditIndicator(BuildContext context) {
    Color color = _getCreditColor();
    IconData icon;
    String text;
    
    if (client.creditBalance > 0) {
      icon = Icons.trending_up;
      text = 'Crédit +';
    } else if (client.creditBalance < 0) {
      icon = Icons.trending_down;
      text = 'Dette';
    } else {
      icon = Icons.remove;
      text = 'Neutre';
      color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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

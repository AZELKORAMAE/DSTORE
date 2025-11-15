import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/supplier_model.dart';
import '../../config/app_router.dart';
import '../../main.dart';

class SupplierListItem extends StatelessWidget {
  final SupplierModel supplier;

  const SupplierListItem({
    super.key,
    required this.supplier,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Icon(
            Icons.business,
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(
          supplier.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (supplier.contactPerson != null) ...[
              const SizedBox(height: 4),
              Text(
                'Contact: ${supplier.contactPerson}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
            if (supplier.phone != null) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    Icons.phone,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    supplier.phone!,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
            if (supplier.lastOrderDate != null) ...[
              const SizedBox(height: 4),
              Text(
                'Dernière commande: ${AppUtils.formatDateShort(supplier.lastOrderDate!)}',
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
              '${supplier.productCount ?? 0} produits',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: supplier.isActive 
                    ? Colors.green.withOpacity(0.1) 
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                supplier.isActive ? 'Actif' : 'Inactif',
                style: TextStyle(
                  fontSize: 10,
                  color: supplier.isActive ? Colors.green : Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        onTap: () => context.goToEditSupplier(supplier.id),
      ),
    );
  }
}

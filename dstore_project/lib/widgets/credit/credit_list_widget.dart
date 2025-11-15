import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/credit_model.dart';
import '../../services/credit_service.dart';
import '../../config/app_theme.dart';
import 'credit_detail_widget.dart';

class CreditListWidget extends StatefulWidget {
  final String? clientId;
  final bool showClientName;

  const CreditListWidget({
    Key? key,
    this.clientId,
    this.showClientName = true,
  }) : super(key: key);

  @override
  State<CreditListWidget> createState() => _CreditListWidgetState();
}

class _CreditListWidgetState extends State<CreditListWidget> {
  final CreditService _creditService = CreditService();
  List<CreditModel> _credits = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCredits();
  }

  Future<void> _loadCredits() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      List<CreditModel> credits;
      if (widget.clientId != null) {
        credits = await _creditService.getCreditsByClient(widget.clientId!);
      } else {
        credits = await _creditService.getAllCredits();
      }

      setState(() {
        _credits = credits;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
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
              'Erreur de chargement',
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
              onPressed: _loadCredits,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_credits.isEmpty) {
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
              'Aucun crédit',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              widget.clientId != null
                  ? 'Ce client n\'a aucun crédit en cours'
                  : 'Aucun crédit en cours',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCredits,
      child: ListView.builder(
        itemCount: _credits.length,
        itemBuilder: (context, index) {
          final credit = _credits[index];
          return _buildCreditCard(credit);
        },
      ),
    );
  }

  Widget _buildCreditCard(CreditModel credit) {
    final isOverdue = credit.dueDate.isBefore(DateTime.now()) &&
        credit.status != CreditPaymentStatus.paid;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _showCreditDetail(credit),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.showClientName && credit.client != null)
                          Text(
                            credit.client!.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        if (widget.showClientName && credit.client != null)
                          const SizedBox(height: 4),
                        Text(
                          'Facture #${credit.invoiceId.substring(0, 8)}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(credit.status, isOverdue),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildAmountInfo(
                      'Total',
                      credit.totalAmount,
                      Colors.blue,
                    ),
                  ),
                  Expanded(
                    child: _buildAmountInfo(
                      'Payé',
                      credit.paidAmount,
                      Colors.green,
                    ),
                  ),
                  Expanded(
                    child: _buildAmountInfo(
                      'Restant',
                      credit.remainingAmount,
                      isOverdue ? Colors.red : Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: isOverdue ? Colors.red : Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Échéance: ${DateFormat('dd/MM/yyyy').format(credit.dueDate)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isOverdue ? Colors.red : Colors.grey[600],
                        ),
                  ),
                  if (isOverdue) ...[
                    const SizedBox(width: 8),
                    Text(
                      '(En retard)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(CreditPaymentStatus status, bool isOverdue) {
    Color color;
    String label;

    if (isOverdue && status != CreditPaymentStatus.paid) {
      color = Colors.red;
      label = 'En retard';
    } else {
      switch (status) {
        case CreditPaymentStatus.pending:
          color = Colors.orange;
          label = 'En attente';
          break;
        case CreditPaymentStatus.partiallyPaid:
          color = Colors.blue;
          label = 'Partiel';
          break;
        case CreditPaymentStatus.paid:
          color = Colors.green;
          label = 'Payé';
          break;
        case CreditPaymentStatus.overdue:
          color = Colors.red;
          label = 'En retard';
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAmountInfo(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 2),
        Text(
          '${amount.toStringAsFixed(2)} DH',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  void _showCreditDetail(CreditModel credit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreditDetailWidget(
        credit: credit,
        onPaymentMade: _loadCredits,
      ),
    );
  }
}

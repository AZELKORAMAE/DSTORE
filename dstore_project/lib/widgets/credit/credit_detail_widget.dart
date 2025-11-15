import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/credit_model.dart';
import '../../services/credit_service.dart';
import '../../config/app_theme.dart';

class CreditDetailWidget extends StatefulWidget {
  final CreditModel credit;
  final VoidCallback? onPaymentMade;

  const CreditDetailWidget({
    Key? key,
    required this.credit,
    this.onPaymentMade,
  }) : super(key: key);

  @override
  State<CreditDetailWidget> createState() => _CreditDetailWidgetState();
}

class _CreditDetailWidgetState extends State<CreditDetailWidget> {
  final CreditService _creditService = CreditService();
  final TextEditingController _paymentController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  List<CreditPaymentModel> _payments = [];
  bool _isLoading = false;
  bool _isLoadingPayments = true;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  @override
  void dispose() {
    _paymentController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadPayments() async {
    try {
      setState(() => _isLoadingPayments = true);
      final payments = await _creditService.getCreditPayments(widget.credit.id);
      setState(() {
        _payments = payments;
        _isLoadingPayments = false;
      });
    } catch (e) {
      setState(() => _isLoadingPayments = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur chargement historique: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Détails du crédit',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          const Divider(),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCreditInfo(),
                  const SizedBox(height: 24),
                  if (widget.credit.status != CreditPaymentStatus.paid) ...[
                    _buildPaymentForm(),
                    const SizedBox(height: 24),
                  ],
                  _buildPaymentHistory(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditInfo() {
    final isOverdue = widget.credit.dueDate.isBefore(DateTime.now()) &&
        widget.credit.status != CreditPaymentStatus.paid;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.credit.client?.name ?? 'Client inconnu',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                _buildStatusChip(widget.credit.status, isOverdue),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
                'Facture', '#${widget.credit.invoiceId.substring(0, 8)}'),
            _buildInfoRow('Date création',
                DateFormat('dd/MM/yyyy').format(widget.credit.createdAt)),
            _buildInfoRow('Échéance',
                DateFormat('dd/MM/yyyy').format(widget.credit.dueDate)),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildAmountCard(
                    'Montant total',
                    widget.credit.totalAmount,
                    Colors.blue,
                    Icons.receipt,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildAmountCard(
                    'Montant payé',
                    widget.credit.paidAmount,
                    Colors.green,
                    Icons.payment,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildAmountCard(
              'Montant restant',
              widget.credit.remainingAmount,
              isOverdue ? Colors.red : Colors.orange,
              Icons.account_balance_wallet,
              isLarge: true,
            ),
            if (widget.credit.notes != null) ...[
              const SizedBox(height: 12),
              Text(
                'Notes:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.credit.notes!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountCard(
      String label, double amount, Color color, IconData icon,
      {bool isLarge = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: isLarge ? 24 : 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            '${amount.toStringAsFixed(2)} DH',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: isLarge ? 18 : 14,
                ),
            textAlign: TextAlign.center,
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
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

  Widget _buildPaymentForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Effectuer un paiement',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _paymentController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Montant du paiement',
                suffixText: 'DH',
                hintText:
                    'Max: ${widget.credit.remainingAmount.toStringAsFixed(2)} DH',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optionnel)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _makePayment,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Effectuer le paiement'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentHistory() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Historique des paiements',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (_isLoadingPayments)
              const Center(child: CircularProgressIndicator())
            else if (_payments.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.history,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Aucun paiement effectué',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _payments.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final payment = _payments[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green.withOpacity(0.1),
                      child: Icon(
                        Icons.payment,
                        color: Colors.green,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      '${payment.amount.toStringAsFixed(2)} DH',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(DateFormat('dd/MM/yyyy à HH:mm')
                            .format(payment.paymentDate)),
                        if ((payment.notes ?? '').isNotEmpty)
                          Text(
                            payment.notes!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                    trailing: payment.paymentMethod != null
                        ? Chip(
                            label: Text(
                              payment.paymentMethod!,
                              style: const TextStyle(fontSize: 10),
                            ),
                            backgroundColor: Colors.blue.withOpacity(0.1),
                          )
                        : null,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _makePayment() async {
    final paymentText = _paymentController.text.trim();
    if (paymentText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez saisir un montant'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final paymentAmount = double.tryParse(paymentText);
    if (paymentAmount == null || paymentAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Montant invalide'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (paymentAmount > widget.credit.remainingAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le montant ne peut pas dépasser le montant restant'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);

      await _creditService.makePayment(
        creditId: widget.credit.id,
        paymentAmount: paymentAmount,
        paymentMethod: 'Espèces', // Par défaut
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );

      _paymentController.clear();
      _notesController.clear();

      await _loadPayments();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Paiement de ${paymentAmount.toStringAsFixed(2)} DH effectué'),
            backgroundColor: Colors.green,
          ),
        );

        widget.onPaymentMade?.call();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

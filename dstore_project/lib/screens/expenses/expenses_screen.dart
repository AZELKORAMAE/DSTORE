import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/expense_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../models/expense.dart';
import '../../main.dart';
import 'add_expense_screen.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExpenses();
    });
  }

  void _loadExpenses() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
    
    if (authProvider.currentUser != null) {
      expenseProvider.loadMonthlyExpenses(authProvider.currentUser!.id, _selectedMonth);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.expenses ?? 'Dépenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddExpenseDialog(),
          ),
        ],
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, child) {
          if (expenseProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Sélecteur de mois et statistiques
              _buildMonthSelector(context, l10n),
              _buildExpenseStats(context, l10n, expenseProvider),
              
              // Liste des dépenses
              Expanded(
                child: expenseProvider.expenses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.account_balance_wallet_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucune dépense pour ce mois',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => _showAddExpenseDialog(),
                              icon: const Icon(Icons.add),
                              label: Text(l10n?.addExpense ?? 'Ajouter une dépense'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: expenseProvider.expenses.length,
                        itemBuilder: (context, index) {
                          final expense = expenseProvider.expenses[index];
                          return _buildExpenseCard(context, expense, l10n);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMonthSelector(BuildContext context, AppLocalizations? l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
              });
              _loadExpenses();
            },
            icon: const Icon(Icons.chevron_left, color: Colors.white),
          ),
          Text(
            DateFormat('MMMM yyyy', 'fr_FR').format(_selectedMonth),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
              });
              _loadExpenses();
            },
            icon: const Icon(Icons.chevron_right, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseStats(BuildContext context, AppLocalizations? l10n, ExpenseProvider expenseProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n?.monthlyExpenses ?? 'Dépenses mensuelles',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total:',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                AppUtils.formatCurrency(expenseProvider.monthlyTotal),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Bénéfice net du mois (avant dépenses)
          Consumer<DashboardProvider>(
            builder: (context, dashboardProvider, child) {
              return FutureBuilder<double>(
                future: dashboardProvider.getMonthNetProfit(_selectedMonth),
                builder: (context, snapshot) {
                  final monthNetProfit = snapshot.data ?? 0.0;
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Bénéfice net du mois:',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            AppUtils.formatCurrency(monthNetProfit),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: monthNetProfit >= 0 ? Colors.blue : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Bénéfice net final (après dépenses)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n?.netProfit ?? 'Bénéfice net final:',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            AppUtils.formatCurrency(expenseProvider.calculateFinalNetProfit(monthNetProfit)),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: expenseProvider.calculateFinalNetProfit(monthNetProfit) >= 0 ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCard(BuildContext context, Expense expense, AppLocalizations? l10n) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getExpenseTypeColor(expense.type),
          child: Icon(
            _getExpenseTypeIcon(expense.type),
            color: Colors.white,
          ),
        ),
        title: Text(
          ExpenseType.getDisplayName(expense.type, 'fr'),
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(expense.description),
            Text(
              DateFormat('dd/MM/yyyy').format(expense.date),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: Text(
          AppUtils.formatCurrency(expense.amount),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        onTap: () => _showExpenseDetails(expense),
      ),
    );
  }

  Color _getExpenseTypeColor(String type) {
    switch (type) {
      case ExpenseType.rent:
        return Colors.blue;
      case ExpenseType.electricity:
        return Colors.orange;
      case ExpenseType.wifi:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getExpenseTypeIcon(String type) {
    switch (type) {
      case ExpenseType.rent:
        return Icons.home;
      case ExpenseType.electricity:
        return Icons.electrical_services;
      case ExpenseType.wifi:
        return Icons.wifi;
      default:
        return Icons.receipt;
    }
  }

  void _showAddExpenseDialog() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddExpenseScreen(),
      ),
    ).then((_) => _loadExpenses());
  }

  void _showExpenseDetails(Expense expense) {
    // TODO: Implémenter l'écran de détails/modification
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(ExpenseType.getDisplayName(expense.type, 'fr')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Montant: ${AppUtils.formatCurrency(expense.amount)}'),
            const SizedBox(height: 8),
            Text('Description: ${expense.description}'),
            const SizedBox(height: 8),
            Text('Date: ${DateFormat('dd/MM/yyyy').format(expense.date)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}

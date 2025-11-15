import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';

class ExpenseProvider with ChangeNotifier {
  final ExpenseService _expenseService = ExpenseService();
  
  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _error;
  double _monthlyTotal = 0.0;
  Map<String, double> _expensesByType = {};

  // Getters
  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get monthlyTotal => _monthlyTotal;
  Map<String, double> get expensesByType => _expensesByType;

  // Charger toutes les dépenses
  Future<void> loadExpenses(String userId) async {
    _setLoading(true);
    try {
      _expenses = await _expenseService.getExpenses(userId);
      _error = null;
      print('✅ ${_expenses.length} dépenses chargées');
    } catch (e) {
      _error = e.toString();
      print('❌ Erreur lors du chargement des dépenses: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Charger les dépenses mensuelles
  Future<void> loadMonthlyExpenses(String userId, DateTime month) async {
    _setLoading(true);
    try {
      _expenses = await _expenseService.getMonthlyExpenses(userId, month);
      _monthlyTotal = await _expenseService.getMonthlyExpensesTotal(userId, month);
      _expensesByType = await _expenseService.getExpensesByType(userId, month);
      _error = null;
      print('✅ Dépenses mensuelles chargées: ${_expenses.length} dépenses, total: $_monthlyTotal DH');
    } catch (e) {
      _error = e.toString();
      print('❌ Erreur lors du chargement des dépenses mensuelles: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Ajouter une nouvelle dépense
  Future<bool> addExpense(Expense expense) async {
    _setLoading(true);
    try {
      final newExpense = await _expenseService.createExpense(expense);
      _expenses.insert(0, newExpense);
      
      // Recalculer les totaux si c'est le mois courant
      final now = DateTime.now();
      if (expense.date.year == now.year && expense.date.month == now.month) {
        _monthlyTotal += expense.amount;
        _expensesByType[expense.type] = (_expensesByType[expense.type] ?? 0.0) + expense.amount;
      }
      
      _error = null;
      print('✅ Dépense ajoutée: ${expense.type} - ${expense.amount} DH');
      return true;
    } catch (e) {
      _error = e.toString();
      print('❌ Erreur lors de l\'ajout de la dépense: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Mettre à jour une dépense
  Future<bool> updateExpense(Expense expense) async {
    _setLoading(true);
    try {
      final updatedExpense = await _expenseService.updateExpense(expense);
      final index = _expenses.indexWhere((e) => e.id == expense.id);
      if (index != -1) {
        final oldExpense = _expenses[index];
        _expenses[index] = updatedExpense;
        
        // Recalculer les totaux si c'est le mois courant
        final now = DateTime.now();
        if (expense.date.year == now.year && expense.date.month == now.month) {
          _monthlyTotal = _monthlyTotal - oldExpense.amount + expense.amount;
          _expensesByType[oldExpense.type] = (_expensesByType[oldExpense.type] ?? 0.0) - oldExpense.amount;
          _expensesByType[expense.type] = (_expensesByType[expense.type] ?? 0.0) + expense.amount;
        }
      }
      
      _error = null;
      print('✅ Dépense mise à jour: ${expense.type} - ${expense.amount} DH');
      return true;
    } catch (e) {
      _error = e.toString();
      print('❌ Erreur lors de la mise à jour de la dépense: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Supprimer une dépense
  Future<bool> deleteExpense(String expenseId) async {
    _setLoading(true);
    try {
      await _expenseService.deleteExpense(expenseId);
      final expenseIndex = _expenses.indexWhere((e) => e.id == expenseId);
      if (expenseIndex != -1) {
        final expense = _expenses[expenseIndex];
        _expenses.removeAt(expenseIndex);
        
        // Recalculer les totaux si c'est le mois courant
        final now = DateTime.now();
        if (expense.date.year == now.year && expense.date.month == now.month) {
          _monthlyTotal -= expense.amount;
          _expensesByType[expense.type] = (_expensesByType[expense.type] ?? 0.0) - expense.amount;
        }
      }
      
      _error = null;
      print('✅ Dépense supprimée');
      return true;
    } catch (e) {
      _error = e.toString();
      print('❌ Erreur lors de la suppression de la dépense: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Calculer le bénéfice net final (bénéfice net du mois - dépenses)
  double calculateFinalNetProfit(double monthlyNetProfit) {
    return monthlyNetProfit - _monthlyTotal;
  }

  // Obtenir les statistiques des dépenses
  Future<Map<String, dynamic>> getExpenseStats(String userId, DateTime month) async {
    try {
      return await _expenseService.getExpenseStats(userId, month);
    } catch (e) {
      print('❌ Erreur lors de la récupération des statistiques: $e');
      return {
        'total': 0.0,
        'count': 0,
        'byType': <String, double>{},
        'expenses': <Expense>[],
      };
    }
  }

  // Méthodes utilitaires
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Filtrer les dépenses par type
  List<Expense> getExpensesByType(String type) {
    return _expenses.where((expense) => expense.type == type).toList();
  }

  // Obtenir le total des dépenses par type
  double getTotalByType(String type) {
    return _expensesByType[type] ?? 0.0;
  }
}

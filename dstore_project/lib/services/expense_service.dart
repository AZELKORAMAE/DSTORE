import '../models/expense.dart';
import 'local_storage_service.dart';

class ExpenseService {
  final LocalStorageService _localStorage = LocalStorageService.instance;

  // Créer une nouvelle dépense
  Future<Expense> createExpense(Expense expense) async {
    try {
      final expenseData = expense.toJson();
      expenseData['id'] = DateTime.now().millisecondsSinceEpoch.toString();
      expenseData['created_at'] = DateTime.now().toIso8601String();
      expenseData['updated_at'] = DateTime.now().toIso8601String();

      await _localStorage.saveExpense(expenseData);
      return Expense.fromJson(expenseData);
    } catch (e) {
      print('❌ Erreur lors de la création de la dépense: $e');
      throw Exception('Erreur lors de la création de la dépense: $e');
    }
  }

  // Récupérer toutes les dépenses d'un utilisateur
  Future<List<Expense>> getExpenses(String userId) async {
    try {
      final expensesData = _localStorage.getExpenses();
      final userExpenses = expensesData
          .where((expense) => expense['user_id'] == userId)
          .toList();

      // Trier par date de création (plus récent en premier)
      userExpenses.sort((a, b) {
        final dateA =
            DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(1970);
        final dateB =
            DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(1970);
        return dateB.compareTo(dateA);
      });

      return userExpenses.map((json) => Expense.fromJson(json)).toList();
    } catch (e) {
      print('❌ Erreur lors de la récupération des dépenses: $e');
      throw Exception('Erreur lors de la récupération des dépenses: $e');
    }
  }

  // Récupérer les dépenses d'un mois spécifique
  Future<List<Expense>> getMonthlyExpenses(
      String userId, DateTime month) async {
    try {
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

      final expensesData = _localStorage.getExpenses();
      final monthlyExpenses = expensesData.where((expense) {
        if (expense['user_id'] != userId) return false;

        final expenseDate = DateTime.tryParse(expense['date'] ?? '');
        if (expenseDate == null) return false;

        return expenseDate
                .isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
            expenseDate.isBefore(endOfMonth.add(const Duration(days: 1)));
      }).toList();

      // Trier par date (plus récent en premier)
      monthlyExpenses.sort((a, b) {
        final dateA = DateTime.tryParse(a['date'] ?? '') ?? DateTime(1970);
        final dateB = DateTime.tryParse(b['date'] ?? '') ?? DateTime(1970);
        return dateB.compareTo(dateA);
      });

      return monthlyExpenses.map((json) => Expense.fromJson(json)).toList();
    } catch (e) {
      print('❌ Erreur lors de la récupération des dépenses mensuelles: $e');
      throw Exception(
          'Erreur lors de la récupération des dépenses mensuelles: $e');
    }
  }

  // Calculer le total des dépenses mensuelles
  Future<double> getMonthlyExpensesTotal(String userId, DateTime month) async {
    try {
      final expenses = await getMonthlyExpenses(userId, month);
      return expenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);
    } catch (e) {
      print('❌ Erreur lors du calcul du total des dépenses mensuelles: $e');
      return 0.0;
    }
  }

  // Récupérer les dépenses par type
  Future<Map<String, double>> getExpensesByType(
      String userId, DateTime month) async {
    try {
      final expenses = await getMonthlyExpenses(userId, month);
      final Map<String, double> expensesByType = {};

      for (final expense in expenses) {
        expensesByType[expense.type] =
            (expensesByType[expense.type] ?? 0.0) + expense.amount;
      }

      return expensesByType;
    } catch (e) {
      print('❌ Erreur lors de la récupération des dépenses par type: $e');
      return {};
    }
  }

  // Mettre à jour une dépense
  Future<Expense> updateExpense(Expense expense) async {
    try {
      final expenseData = expense.toJson();
      expenseData['updated_at'] = DateTime.now().toIso8601String();

      await _localStorage.saveExpense(expenseData);
      return Expense.fromJson(expenseData);
    } catch (e) {
      print('❌ Erreur lors de la mise à jour de la dépense: $e');
      throw Exception('Erreur lors de la mise à jour de la dépense: $e');
    }
  }

  // Supprimer une dépense
  Future<void> deleteExpense(String expenseId) async {
    try {
      await _localStorage.deleteExpense(expenseId);
    } catch (e) {
      print('❌ Erreur lors de la suppression de la dépense: $e');
      throw Exception('Erreur lors de la suppression de la dépense: $e');
    }
  }

  // Récupérer les statistiques des dépenses
  Future<Map<String, dynamic>> getExpenseStats(
      String userId, DateTime month) async {
    try {
      final expenses = await getMonthlyExpenses(userId, month);
      final total =
          expenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);
      final expensesByType = await getExpensesByType(userId, month);

      return {
        'total': total,
        'count': expenses.length,
        'byType': expensesByType,
        'expenses': expenses,
      };
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
}

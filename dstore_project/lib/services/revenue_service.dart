import '../models/revenue_model.dart';
import 'local_storage_service.dart';
import 'package:uuid/uuid.dart';

class RevenueService {
  final LocalStorageService _localStorage = LocalStorageService.instance;
  final Uuid _uuid = const Uuid();

  /// Enregistrer un revenu (facture ou paiement de crédit)
  Future<RevenueModel> recordRevenue({
    required double amount,
    required RevenueType type,
    required String sourceId, // ID de la facture ou du crédit
    String? clientId,
    String? description,
    DateTime? date,
  }) async {
    try {
      final revenue = RevenueModel(
        id: _uuid.v4(),
        amount: amount,
        type: type,
        sourceId: sourceId,
        clientId: clientId,
        description: description,
        date: date ?? DateTime.now(),
        createdAt: DateTime.now(),
      );

      await _localStorage.saveRevenue(revenue.toJson());
      print('💰 Revenu enregistré: ${amount.toStringAsFixed(2)} DH - ${type.label}');
      
      return revenue;
    } catch (e) {
      throw Exception('Erreur lors de l\'enregistrement du revenu: $e');
    }
  }

  /// Obtenir tous les revenus
  Future<List<RevenueModel>> getAllRevenues() async {
    try {
      final revenuesData = _localStorage.getRevenues();
      return revenuesData.map((data) => RevenueModel.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des revenus: $e');
    }
  }

  /// Obtenir les revenus d'une période
  Future<List<RevenueModel>> getRevenuesByPeriod({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final allRevenues = await getAllRevenues();
      return allRevenues.where((revenue) {
        return revenue.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
               revenue.date.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des revenus par période: $e');
    }
  }

  /// Obtenir les revenus du jour
  Future<double> getTodayRevenue() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);
      
      final todayRevenues = await getRevenuesByPeriod(
        startDate: startOfDay,
        endDate: endOfDay,
      );
      
      return todayRevenues.fold<double>(0.0, (sum, revenue) => sum + revenue.amount);
    } catch (e) {
      print('❌ Erreur getTodayRevenue: $e');
      return 0.0;
    }
  }

  /// Obtenir les revenus de la semaine
  Future<double> getWeekRevenue() async {
    try {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final startOfWeek = DateTime(weekStart.year, weekStart.month, weekStart.day);
      
      final weekRevenues = await getRevenuesByPeriod(
        startDate: startOfWeek,
        endDate: now,
      );
      
      return weekRevenues.fold<double>(0.0, (sum, revenue) => sum + revenue.amount);
    } catch (e) {
      print('❌ Erreur getWeekRevenue: $e');
      return 0.0;
    }
  }

  /// Obtenir les revenus du mois
  Future<double> getMonthRevenue() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      
      final monthRevenues = await getRevenuesByPeriod(
        startDate: startOfMonth,
        endDate: now,
      );
      
      return monthRevenues.fold<double>(0.0, (sum, revenue) => sum + revenue.amount);
    } catch (e) {
      print('❌ Erreur getMonthRevenue: $e');
      return 0.0;
    }
  }

  /// Obtenir le total des revenus
  Future<double> getTotalRevenue() async {
    try {
      final allRevenues = await getAllRevenues();
      return allRevenues.fold<double>(0.0, (sum, revenue) => sum + revenue.amount);
    } catch (e) {
      print('❌ Erreur getTotalRevenue: $e');
      return 0.0;
    }
  }

  /// Obtenir les revenus par jour pour les graphiques
  Future<List<double>> getDailyRevenueData(int days) async {
    try {
      final now = DateTime.now();
      final dailyData = <double>[];

      for (int i = days - 1; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
        
        final dayRevenues = await getRevenuesByPeriod(
          startDate: startOfDay,
          endDate: endOfDay,
        );
        
        final dayTotal = dayRevenues.fold<double>(0.0, (sum, revenue) => sum + revenue.amount);
        dailyData.add(dayTotal);
      }

      return dailyData;
    } catch (e) {
      print('❌ Erreur getDailyRevenueData: $e');
      return List.filled(days, 0.0);
    }
  }

  /// Supprimer un revenu
  Future<void> deleteRevenue(String id) async {
    try {
      await _localStorage.deleteRevenue(id);
      print('🗑️ Revenu supprimé: $id');
    } catch (e) {
      throw Exception('Erreur lors de la suppression du revenu: $e');
    }
  }
}

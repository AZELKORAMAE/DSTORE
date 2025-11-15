import 'package:shared_preferences/shared_preferences.dart';

class AppLocalStorage {
  static SharedPreferences? _prefs;

  /// Initialiser le stockage local
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Obtenir une instance de SharedPreferences
  static Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Sauvegarder une chaîne de caractères
  static Future<bool> setString(String key, String value) async {
    final prefs = await _instance;
    return await prefs.setString(key, value);
  }

  /// Récupérer une chaîne de caractères
  static Future<String?> getString(String key) async {
    final prefs = await _instance;
    return prefs.getString(key);
  }

  /// Sauvegarder un entier
  static Future<bool> setInt(String key, int value) async {
    final prefs = await _instance;
    return await prefs.setInt(key, value);
  }

  /// Récupérer un entier
  static Future<int?> getInt(String key) async {
    final prefs = await _instance;
    return prefs.getInt(key);
  }

  /// Sauvegarder un booléen
  static Future<bool> setBool(String key, bool value) async {
    final prefs = await _instance;
    return await prefs.setBool(key, value);
  }

  /// Récupérer un booléen
  static Future<bool?> getBool(String key) async {
    final prefs = await _instance;
    return prefs.getBool(key);
  }

  /// Sauvegarder un double
  static Future<bool> setDouble(String key, double value) async {
    final prefs = await _instance;
    return await prefs.setDouble(key, value);
  }

  /// Récupérer un double
  static Future<double?> getDouble(String key) async {
    final prefs = await _instance;
    return prefs.getDouble(key);
  }

  /// Sauvegarder une liste de chaînes
  static Future<bool> setStringList(String key, List<String> value) async {
    final prefs = await _instance;
    return await prefs.setStringList(key, value);
  }

  /// Récupérer une liste de chaînes
  static Future<List<String>?> getStringList(String key) async {
    final prefs = await _instance;
    return prefs.getStringList(key);
  }

  /// Supprimer une clé
  static Future<bool> remove(String key) async {
    final prefs = await _instance;
    return await prefs.remove(key);
  }

  /// Vérifier si une clé existe
  static Future<bool> containsKey(String key) async {
    final prefs = await _instance;
    return prefs.containsKey(key);
  }

  /// Effacer toutes les données
  static Future<bool> clear() async {
    final prefs = await _instance;
    return await prefs.clear();
  }

  /// Obtenir toutes les clés
  static Future<Set<String>> getKeys() async {
    final prefs = await _instance;
    return prefs.getKeys();
  }
}

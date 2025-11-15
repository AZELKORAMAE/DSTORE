import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'language_code';
  static const String _scanSoundKey = 'scan_sound';
  static const String _logoPathKey = 'company_logo_path';
  static const String _companyNameKey = 'company_name';
  static const String _isAdminKey = 'is_admin';
  static const String _tvaRateKey = 'tva_rate';

  // Paramètres par défaut
  ThemeMode _themeMode = ThemeMode.system;
  String _languageCode = 'fr';
  String _scanSound = 'beep';
  String? _logoPath;
  String _companyName = 'Mon Entreprise';
  bool _isAdmin = false;
  double _tvaRate = 20.0; // Taux de TVA par défaut

  // Getters
  ThemeMode get themeMode => _themeMode;
  String get languageCode => _languageCode;
  String get scanSound => _scanSound;
  String? get logoPath => _logoPath;
  String get companyName => _companyName;
  bool get isAdmin => _isAdmin;
  double get tvaRate => _tvaRate;

  // Sons disponibles (les noms seront traduits dans l'interface)
  static const List<Map<String, String>> availableSounds = [
    {'id': 'beep', 'name': 'classicBeep'},
    {'id': 'success', 'name': 'success'},
    {'id': 'notification', 'name': 'notification'},
    {'id': 'cash_register', 'name': 'cashRegister'},
    {'id': 'none', 'name': 'noSound'},
  ];

  // Langues disponibles
  static const List<Map<String, String>> availableLanguages = [
    {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
    {'code': 'ar', 'name': 'العربية', 'flag': '🇲🇦'},
  ];

  // Thèmes disponibles (les noms seront traduits dans l'interface)
  static const List<Map<String, dynamic>> availableThemes = [
    {'mode': ThemeMode.light, 'name': 'lightTheme', 'icon': Icons.light_mode},
    {'mode': ThemeMode.dark, 'name': 'darkTheme', 'icon': Icons.dark_mode},
    {'mode': ThemeMode.system, 'name': 'systemTheme', 'icon': Icons.auto_mode},
  ];

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Charger le thème
      final themeIndex = prefs.getInt(_themeKey) ?? 2; // Système par défaut
      _themeMode = ThemeMode.values[themeIndex];

      // Charger la langue
      _languageCode = prefs.getString(_languageKey) ?? 'fr';

      // Charger le son de scan
      _scanSound = prefs.getString(_scanSoundKey) ?? 'beep';

      // Charger le logo
      _logoPath = prefs.getString(_logoPathKey);

      // Charger le nom de l'entreprise
      _companyName = prefs.getString(_companyNameKey) ?? 'Mon Entreprise';

      // Charger le statut admin
      _isAdmin = prefs.getBool(_isAdminKey) ?? false;

      // Charger le taux de TVA
      _tvaRate = prefs.getDouble(_tvaRateKey) ?? 20.0;

      notifyListeners();
    } catch (e) {
      print('Erreur lors du chargement des paramètres: $e');
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      _themeMode = mode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, mode.index);
      notifyListeners();
    } catch (e) {
      print('Erreur lors de la sauvegarde du thème: $e');
    }
  }

  Future<void> setLanguage(String languageCode) async {
    try {
      _languageCode = languageCode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
      notifyListeners();
    } catch (e) {
      print('Erreur lors de la sauvegarde de la langue: $e');
    }
  }

  Future<void> setLanguageCode(String languageCode) async {
    try {
      _languageCode = languageCode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
      notifyListeners();
    } catch (e) {
      print('Erreur lors de la sauvegarde de la langue: $e');
    }
  }

  Future<void> setScanSound(String sound) async {
    try {
      _scanSound = sound;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_scanSoundKey, sound);
      notifyListeners();
    } catch (e) {
      print('Erreur lors de la sauvegarde du son: $e');
    }
  }

  Future<void> setLogoPath(String? path) async {
    try {
      _logoPath = path;
      final prefs = await SharedPreferences.getInstance();
      if (path != null) {
        await prefs.setString(_logoPathKey, path);
      } else {
        await prefs.remove(_logoPathKey);
      }
      notifyListeners();
    } catch (e) {
      print('Erreur lors de la sauvegarde du logo: $e');
    }
  }

  Future<void> setCompanyName(String name) async {
    try {
      _companyName = name;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_companyNameKey, name);
      notifyListeners();
    } catch (e) {
      print('Erreur lors de la sauvegarde du nom d\'entreprise: $e');
    }
  }

  Future<void> setAdminStatus(bool isAdmin) async {
    try {
      _isAdmin = isAdmin;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isAdminKey, isAdmin);
      notifyListeners();
    } catch (e) {
      print('Erreur lors de la sauvegarde du statut admin: $e');
    }
  }

  Future<void> setTVARate(double rate) async {
    try {
      _tvaRate = rate;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_tvaRateKey, rate);
      notifyListeners();
    } catch (e) {
      print('Erreur lors de la sauvegarde du taux de TVA: $e');
    }
  }

  // Méthodes utilitaires
  String getLanguageName() {
    return availableLanguages.firstWhere(
        (lang) => lang['code'] == _languageCode,
        orElse: () => availableLanguages.first)['name']!;
  }

  String getLanguageFlag() {
    return availableLanguages.firstWhere(
        (lang) => lang['code'] == _languageCode,
        orElse: () => availableLanguages.first)['flag']!;
  }

  String getSoundName() {
    return availableSounds.firstWhere((sound) => sound['id'] == _scanSound,
        orElse: () => availableSounds.first)['name']!;
  }

  String getThemeName() {
    return availableThemes.firstWhere((theme) => theme['mode'] == _themeMode,
        orElse: () => availableThemes.last)['name']!;
  }

  IconData getThemeIcon() {
    return availableThemes.firstWhere((theme) => theme['mode'] == _themeMode,
        orElse: () => availableThemes.last)['icon']!;
  }

  Future<void> resetSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      _themeMode = ThemeMode.system;
      _languageCode = 'fr';
      _scanSound = 'beep';
      _logoPath = null;
      _companyName = 'Mon Entreprise';
      _isAdmin = false;
      _tvaRate = 20.0;

      notifyListeners();
    } catch (e) {
      print('Erreur lors de la réinitialisation: $e');
    }
  }
}

import 'dart:math';

class BarcodeGeneratorService {
  static const String _prefix = 'DS'; // DStore prefix
  static final Random _random = Random();

  /// Générer un code-barres court et mémorisable
  /// Format: MT + 4 chiffres (ex: MT1234)
  static String generateShortBarcode() {
    final number = _random.nextInt(9999) + 1; // 1 à 9999
    return '$_prefix${number.toString().padLeft(4, '0')}';
  }

  /// Générer un code-barres basé sur la catégorie
  /// Format: MT + code catégorie + 3 chiffres (ex: MTLEG123 pour légumes)
  static String generateCategoryBarcode(String categoryName) {
    final categoryCode = _getCategoryCode(categoryName);
    final number = _random.nextInt(999) + 1; // 1 à 999
    return '$_prefix$categoryCode${number.toString().padLeft(3, '0')}';
  }

  /// Générer un code-barres basé sur le nom du produit
  /// Format: MT + premières lettres + 3 chiffres (ex: MTTOM123 pour tomate)
  static String generateProductNameBarcode(String productName) {
    final nameCode = _getProductNameCode(productName);
    final number = _random.nextInt(999) + 1; // 1 à 999
    return '$_prefix$nameCode${number.toString().padLeft(3, '0')}';
  }

  /// Générer un code-barres numérique simple
  /// Format: 6 chiffres (ex: 123456)
  static String generateNumericBarcode() {
    final number = _random.nextInt(999999) + 100000; // 100000 à 999999
    return number.toString();
  }

  /// Générer un code-barres avec date
  /// Format: MT + MMDD + 2 chiffres (ex: MT0315 + 01 = MT031501)
  static String generateDateBasedBarcode() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final number = _random.nextInt(99) + 1; // 1 à 99
    return '$_prefix$month$day${number.toString().padLeft(2, '0')}';
  }

  /// Obtenir le code de catégorie (3 lettres)
  static String _getCategoryCode(String categoryName) {
    final name = categoryName.toLowerCase().replaceAll(' ', '');
    
    // Codes prédéfinis pour les catégories communes
    final Map<String, String> categoryCodes = {
      'légumes': 'LEG',
      'legumes': 'LEG',
      'fruits': 'FRU',
      'viande': 'VIA',
      'poisson': 'POI',
      'produitslaitiers': 'LAI',
      'laitiers': 'LAI',
      'boulangerie': 'BOU',
      'pain': 'BOU',
      'boissons': 'BOI',
      'épicerie': 'EPI',
      'epicerie': 'EPI',
      'surgelés': 'SUR',
      'surgeles': 'SUR',
      'conserves': 'CON',
      'hygiène': 'HYG',
      'hygiene': 'HYG',
      'entretien': 'ENT',
      'textile': 'TEX',
      'électronique': 'ELE',
      'electronique': 'ELE',
    };

    // Chercher un code prédéfini
    for (final entry in categoryCodes.entries) {
      if (name.contains(entry.key)) {
        return entry.value;
      }
    }

    // Si pas de code prédéfini, prendre les 3 premières lettres
    if (name.length >= 3) {
      return name.substring(0, 3).toUpperCase();
    } else {
      return name.toUpperCase().padRight(3, 'X');
    }
  }

  /// Obtenir le code du nom de produit (3 lettres)
  static String _getProductNameCode(String productName) {
    final name = productName.toLowerCase().replaceAll(' ', '');
    
    // Codes prédéfinis pour les produits communes
    final Map<String, String> productCodes = {
      'tomate': 'TOM',
      'pomme': 'POM',
      'banane': 'BAN',
      'carotte': 'CAR',
      'salade': 'SAL',
      'oignon': 'OIG',
      'pommedeterre': 'PDT',
      'courgette': 'COU',
      'aubergine': 'AUB',
      'poivron': 'POI',
      'concombre': 'CON',
      'radis': 'RAD',
      'navet': 'NAV',
      'brocoli': 'BRO',
      'choufleur': 'CHO',
      'épinard': 'EPI',
      'laitue': 'LAI',
      'persil': 'PER',
      'basilic': 'BAS',
      'menthe': 'MEN',
    };

    // Chercher un code prédéfini
    for (final entry in productCodes.entries) {
      if (name.contains(entry.key)) {
        return entry.value;
      }
    }

    // Si pas de code prédéfini, prendre les 3 premières lettres
    if (name.length >= 3) {
      return name.substring(0, 3).toUpperCase();
    } else {
      return name.toUpperCase().padRight(3, 'X');
    }
  }

  /// Valider qu'un code-barres généré est unique
  static bool isValidBarcode(String barcode) {
    // Vérifier la longueur (entre 4 et 10 caractères)
    if (barcode.length < 4 || barcode.length > 10) {
      return false;
    }

    // Vérifier qu'il contient seulement des lettres et chiffres
    final regex = RegExp(r'^[A-Z0-9]+$');
    return regex.hasMatch(barcode);
  }

  /// Générer plusieurs options de codes-barres
  static List<String> generateBarcodeOptions({
    String? productName,
    String? categoryName,
  }) {
    final List<String> options = [];

    // Option 1: Code court simple
    options.add(generateShortBarcode());

    // Option 2: Code numérique
    options.add(generateNumericBarcode());

    // Option 3: Code basé sur la date
    options.add(generateDateBasedBarcode());

    // Option 4: Code basé sur la catégorie (si fournie)
    if (categoryName != null && categoryName.isNotEmpty) {
      options.add(generateCategoryBarcode(categoryName));
    }

    // Option 5: Code basé sur le nom du produit (si fourni)
    if (productName != null && productName.isNotEmpty) {
      options.add(generateProductNameBarcode(productName));
    }

    return options;
  }
}

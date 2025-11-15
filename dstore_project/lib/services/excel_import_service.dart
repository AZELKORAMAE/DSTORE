import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
// import 'package:csv/csv.dart'; // Package non disponible
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';
import '../models/product_model.dart';

class ExcelImportService {
  /// Sélectionner et lire un fichier Excel (méthode principale)
  static Future<List<Map<String, dynamic>>?> pickAndReadExcelFile({String? filePath}) async {
    try {
      print('🚀🚀🚀 DÉBUT pickAndReadExcelFile - MÉTHODE PRINCIPALE APPELÉE !!! 🚀🚀🚀');
      // Si un chemin de fichier est fourni, l'utiliser directement
      if (filePath != null) {
        print('📁 Lecture du fichier spécifié: $filePath');
        final service = ExcelImportService();
        return await service.readExcelFile(File(filePath));
      }

      // Sinon, permettre à l'utilisateur de sélectionner un fichier
      print('📂 Sélection d\'un fichier Excel...');
      
      // Essayer d'abord avec les extensions spécifiques
      var result = await _pickFileWithExtensions();
      if (result != null) return result;
      
      // Si ça échoue, essayer avec FileType.any
      result = await _pickFileAny();
      return result;
      
    } catch (e) {
      print('❌ Erreur lors de la sélection du fichier Excel: $e');
      throw Exception('Erreur lors de la sélection du fichier: $e');
    }
  }

  /// Méthode avec extensions spécifiques
  static Future<List<Map<String, dynamic>>?> _pickFileWithExtensions() async {
    try {
      print('🔍 Tentative de sélection avec extensions spécifiques...');
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'csv'],
        allowMultiple: false,
      );

      if (result != null) {
        return await _processSelectedFile(result);
      }
      return null;
    } catch (e) {
      print('! Échec sélection avec extensions: $e');
      return null;
    }
  }

  /// Sélectionner et lire un fichier Excel avec option de suppression des produits sans image
  static Future<List<Map<String, dynamic>>?> pickAndReadExcelFileWithImageFilter({String? filePath, bool removeProductsWithoutImages = false}) async {
    try {
      print('🚀🚀🚀 DÉBUT pickAndReadExcelFileWithImageFilter - MÉTHODE AVEC FILTRE IMAGE !!! 🚀🚀🚀');
      print('🖼️ Suppression des produits sans image: $removeProductsWithoutImages');

      // Utiliser la méthode normale pour obtenir les données
      List<Map<String, dynamic>>? products;
      if (filePath != null) {
        print('📁 Lecture du fichier spécifié: $filePath');
        final file = File(filePath);
        final service = ExcelImportService();
        products = await service.readExcelFile(file);
      } else {
        products = await pickAndReadExcelFile();
      }

      // Appliquer le filtre si demandé
      if (products != null && removeProductsWithoutImages) {
        print('🔍 Application du filtre pour supprimer les produits sans image...');
        final originalCount = products.length;

        products = products.where((product) {
          final hasImage = product['imageBytes'] != null &&
                          product['imageBytes'] is Uint8List &&
                          (product['imageBytes'] as Uint8List).isNotEmpty;

          if (!hasImage) {
            print('❌ Produit supprimé (pas d\'image): "${product['nom'] ?? 'Sans nom'}"');
          }

          return hasImage;
        }).toList();

        final filteredCount = products.length;
        final removedCount = originalCount - filteredCount;

        print('📊 Résultat du filtrage:');
        print('   • Produits originaux: $originalCount');
        print('   • Produits avec image: $filteredCount');
        print('   • Produits supprimés: $removedCount');
      }

      return products;
    } catch (e) {
      print('❌ Erreur lors de la lecture du fichier Excel avec filtre: $e');
      throw Exception('Erreur lors de la lecture du fichier Excel avec filtre: $e');
    }
  }

  /// Méthode avec FileType.any
  static Future<List<Map<String, dynamic>>?> _pickFileAny() async {
    try {
      print('🔍 Tentative de sélection avec FileType.any...');
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null) {
        return await _processSelectedFile(result);
      }
      return null;
    } catch (e) {
      print('❌ Erreur lors de la sélection du fichier: $e');
      throw Exception('Erreur lors de la sélection du fichier: $e');
    }
  }

  /// Traiter le fichier sélectionné
  static Future<List<Map<String, dynamic>>?> _processSelectedFile(FilePickerResult result) async {
    final file = File(result.files.single.path!);
    final fileName = result.files.single.name.toLowerCase();

    print('📁 Fichier sélectionné: $fileName');
    print('📍 Chemin: ${file.path}');

    if (fileName.endsWith('.csv')) {
      print('📊 Traitement du fichier CSV...');
      final service = ExcelImportService();
      return await service.readCsvFile(file);
    } else if (fileName.endsWith('.xlsx') || fileName.endsWith('.xls')) {
      print('📊 Traitement du fichier Excel...');
      final service = ExcelImportService();
      return await service.readExcelFile(file);
    } else {
      // Essayer de traiter comme Excel par défaut
      print('📊 Type de fichier non reconnu, tentative de traitement comme Excel...');
      final service = ExcelImportService();
      return await service.readExcelFile(file);
    }
  }

  /// Lire un fichier Excel et extraire les données des produits
  Future<List<Map<String, dynamic>>> readExcelFile(File file) async {
    try {
      print('🚀 DÉBUT readExcelFile - Méthode appelée !');
      print('📖 Lecture du fichier Excel: ${file.path}');
      final filePath = file.path;

      // Lire le fichier Excel
      final bytes = await file.readAsBytes();

      // Extraire d'abord les images avant d'essayer de décoder les données
      print('🖼️ Extraction des images en premier...');
      final embeddedImages = await _extractImagesFromExcelFile(filePath);
      print('📦 ${embeddedImages.length} images extraites du fichier Excel');

      // Essayer de décoder le fichier Excel pour les données textuelles
      Excel? excel;
      List<Map<String, dynamic>> products = [];

      // Essayer d'abord une approche basée sur l'extraction ZIP
      try {
        print('🔍 Tentative de lecture des données via extraction ZIP...');
        print('📁 Chemin du fichier: $filePath');
        print('🖼️ Nombre d\'images extraites: ${embeddedImages.length}');

        products = await _extractDataFromExcelZip(filePath, embeddedImages);
        if (products.isNotEmpty) {
          print('✅ Lecture ZIP réussie avec ${products.length} produits !');
        } else {
          print('⚠️ Méthode ZIP n\'a trouvé aucune donnée');
          throw Exception('Aucune donnée trouvée via ZIP');
        }
      } catch (zipError) {
        print('❌ Erreur lecture ZIP: $zipError');
        print('📋 Stack trace: ${zipError.toString()}');

        // Fallback vers les méthodes Excel classiques
        try {
          print('🔍 Tentative de décodage Excel pour les données textuelles...');
          excel = Excel.decodeBytes(bytes);
          print('✅ Fichier Excel décodé avec succès');

          // Traiter les données normalement avec une approche plus robuste
          products = await _processExcelDataRobust(excel, embeddedImages);

        } catch (e) {
          print('⚠️ Erreur décodage Excel standard: $e');

          // Essayer une approche alternative plus robuste
          try {
            print('🔄 Tentative de lecture alternative...');
            excel = Excel.decodeBytes(bytes);
            products = await _processExcelDataAlternative(excel, embeddedImages);
            print('✅ Lecture alternative réussie !');
          } catch (e2) {
            print('⚠️ Erreur lecture alternative: $e2');

            // Essayer une approche ultra-défensive
            try {
              print('🔄 Tentative de lecture ultra-défensive...');
              excel = Excel.decodeBytes(bytes);
              products = await _processExcelDataUltraDefensive(excel, embeddedImages);
              print('✅ Lecture ultra-défensive réussie !');
            } catch (e3) {
              print('⚠️ Erreur lecture ultra-défensive: $e3');
              print('💡 Création de produits basés uniquement sur les images extraites...');

              // Si on ne peut pas lire les données textuelles mais qu'on a des images,
              // créer des produits avec des noms par défaut
              if (embeddedImages.isNotEmpty) {
                products = _createProductsFromImages(embeddedImages);
                print('✅ ${products.length} produits créés à partir des images');
              } else {
                throw Exception(
                  'Impossible de lire le fichier Excel et aucune image trouvée. '
                  'Veuillez vérifier que votre fichier contient bien des données et des images. '
                  'Erreur: $e'
                );
              }
            }
          }
        }
      }

      return products;
    } catch (e) {
      print('❌ Erreur lors de la lecture du fichier Excel: $e');
      throw Exception('Erreur lors de la lecture du fichier Excel: $e');
    }
  }

  /// Traite les données Excel avec une approche robuste
  Future<List<Map<String, dynamic>>> _processExcelDataRobust(
    Excel excel,
    List<Uint8List> embeddedImages
  ) async {
    final products = <Map<String, dynamic>>[];

    try {
      // Obtenir la première feuille disponible
      if (excel.tables.isEmpty) {
        throw Exception('Aucune feuille trouvée dans le fichier Excel');
      }

      final sheetName = excel.tables.keys.first;
      final sheet = excel.tables[sheetName];

      if (sheet == null) {
        throw Exception('Impossible d\'accéder à la feuille: $sheetName');
      }

      print('📋 Feuille trouvée: $sheetName avec ${sheet.maxRows} lignes et ${sheet.maxColumns} colonnes');

      // Afficher les en-têtes pour debug
      if (sheet.maxRows > 0) {
        final headerRow = sheet.rows[0];
        print('📝 En-têtes détectés:');
        for (int j = 0; j < headerRow.length && j < 5; j++) {
          final cell = headerRow[j];
          final value = cell?.value?.toString() ?? 'vide';
          print('   Colonne $j: "$value"');
        }
      }

      // Traiter chaque ligne avec vérifications robustes
      for (int i = 1; i < sheet.maxRows; i++) {
        try {
          final row = sheet.rows[i];
          print('🔍 Traitement ligne $i avec ${row.length} cellules');

          if (row.isNotEmpty) {
            // Extraire le nom (première colonne)
            String nom = '';
            if (row.isNotEmpty && row[0] != null && row[0]!.value != null) {
              nom = row[0]!.value.toString().trim();
              print('   📝 Nom extrait: "$nom"');
            } else {
              print('   ⚠️ Première cellule vide ou nulle');
            }

            // Extraire le code-barres (deuxième colonne)
            String codeBarre = '';
            if (row.length > 1 && row[1] != null && row[1]!.value != null) {
              codeBarre = row[1]!.value.toString().trim();
              print('   🏷️ Code-barres extrait: "$codeBarre"');
            } else {
              print('   ⚠️ Deuxième cellule vide ou nulle');
            }

            // Afficher toutes les cellules pour debug
            print('   📊 Contenu complet de la ligne $i:');
            for (int j = 0; j < row.length && j < 5; j++) {
              final cell = row[j];
              final value = cell?.value?.toString() ?? 'null';
              print('      Cellule $j: "$value"');
            }

            // Si on a au moins un nom ou un code-barres, créer le produit
            if (nom.isNotEmpty || codeBarre.isNotEmpty) {
              // Si le nom est vide, utiliser un nom par défaut
              if (nom.isEmpty) {
                nom = 'Produit ${i}';
                print('   🔄 Nom par défaut assigné: "$nom"');
              }

              // Associer l'image correspondante (index i-1 car on saute l'en-tête)
              Uint8List? imageBytes;
              if (embeddedImages.isNotEmpty && (i-1) < embeddedImages.length) {
                imageBytes = embeddedImages[i-1];
                print('   🖼️ Image associée: ${imageBytes?.length ?? 0} bytes');
              }

              products.add({
                'nom': nom,
                'codeBarre': codeBarre,
                'imageBytes': imageBytes,
              });

              print('✅ Produit ajouté: "$nom" (code: "${codeBarre.isNotEmpty ? codeBarre : 'sans code-barres'}")');
            } else {
              print('   ❌ Ligne $i ignorée: nom et code-barres vides');
            }
          } else {
            print('   ❌ Ligne $i vide');
          }
        } catch (e) {
          print('⚠️ Erreur ligne $i: $e - Passage à la ligne suivante');
          continue;
        }
      }

      print('📦 Total de ${products.length} produits extraits');
      return products;
    } catch (e) {
      print('❌ Erreur dans _processExcelDataRobust: $e');
      rethrow;
    }
  }

  /// Méthode alternative de traitement Excel
  Future<List<Map<String, dynamic>>> _processExcelDataAlternative(
    Excel excel,
    List<Uint8List> embeddedImages
  ) async {
    final products = <Map<String, dynamic>>[];

    try {
      // Essayer toutes les feuilles disponibles
      for (String sheetName in excel.tables.keys) {
        final sheet = excel.tables[sheetName];
        if (sheet == null) continue;

        print('📋 Tentative de lecture de la feuille: $sheetName');

        // Parcourir toutes les lignes de manière sécurisée
        final maxRows = sheet.maxRows;
        print('📊 Nombre de lignes détectées: $maxRows');

        for (int i = 0; i < maxRows; i++) {
          try {
            final row = sheet.rows[i];
            if (row.isEmpty) continue;

            // Ignorer la première ligne (en-tête probable)
            if (i == 0) continue;

            String nom = '';
            String codeBarre = '';

            // Essayer d'extraire les données de manière très défensive
            print('🔍 Alternative - Ligne $i avec ${row.length} cellules');
            for (int j = 0; j < row.length && j < 3; j++) {
              final cell = row[j];
              if (cell != null && cell.value != null) {
                final cellValue = cell.value.toString().trim();
                print('   📝 Alternative - Cellule $j: "$cellValue"');
                if (cellValue.isNotEmpty) {
                  if (j == 0 && nom.isEmpty) {
                    nom = cellValue;
                    print('   ✅ Alternative - Nom assigné: "$nom"');
                  } else if (j == 1 && codeBarre.isEmpty) {
                    codeBarre = cellValue;
                    print('   ✅ Alternative - Code-barres assigné: "$codeBarre"');
                  }
                }
              } else {
                print('   ⚠️ Alternative - Cellule $j vide ou nulle');
              }
            }

            // Créer le produit si on a des données
            if (nom.isNotEmpty || codeBarre.isNotEmpty) {
              if (nom.isEmpty) {
                nom = 'Produit ${products.length + 1}';
              }

              // Associer l'image correspondante
              Uint8List? imageBytes;
              final imageIndex = products.length;
              if (embeddedImages.isNotEmpty && imageIndex < embeddedImages.length) {
                imageBytes = embeddedImages[imageIndex];
              }

              products.add({
                'nom': nom,
                'codeBarre': codeBarre,
                'imageBytes': imageBytes,
              });

              print('✅ Produit alternatif ajouté: $nom (${codeBarre.isNotEmpty ? codeBarre : 'sans code-barres'})');
            }
          } catch (e) {
            print('⚠️ Erreur ligne $i de la feuille $sheetName: $e');
            continue;
          }
        }

        // Si on a trouvé des produits, on s'arrête
        if (products.isNotEmpty) {
          print('✅ ${products.length} produits trouvés dans la feuille $sheetName');
          break;
        }
      }

      return products;
    } catch (e) {
      print('❌ Erreur dans _processExcelDataAlternative: $e');
      rethrow;
    }
  }

  /// Crée des produits basés uniquement sur les images quand les données textuelles ne peuvent pas être lues
  List<Map<String, dynamic>> _createProductsFromImages(List<Uint8List> embeddedImages) {
    final products = <Map<String, dynamic>>[];
    
    for (int i = 0; i < embeddedImages.length; i++) {
      products.add({
        'nom': 'Produit ${i + 1}', // Nom par défaut
        'codeBarre': '', // Code-barres vide à remplir par l'utilisateur
        'imageBytes': embeddedImages[i],
      });
      
      print('✅ Produit créé à partir de l\'image ${i + 1}');
    }
    
    return products;
  }

  /// Extraire les images d'un fichier Excel avec analyse du positionnement
  Future<List<Uint8List>> _extractImagesFromExcelFile(String filePath) async {
    List<Uint8List> images = [];

    try {
      print('📦 NOUVELLE EXTRACTION: Analyse du positionnement des images...');
      print('📁 Taille du fichier: ${await File(filePath).length()} bytes');

      // Lire le fichier Excel comme une archive ZIP
      final bytes = await File(filePath).readAsBytes();

      try {
        final archive = ZipDecoder().decodeBytes(bytes);

        // D'abord, analyser le fichier drawing pour comprendre l'ordre des images
        String? drawingContent;
        for (final file in archive) {
          if (file.name == 'xl/drawings/drawing1.xml') {
            drawingContent = utf8.decode(file.content as List<int>);
            print('📋 Fichier drawing trouvé: ${drawingContent.length} caractères');
            break;
          }
        }

        // Analyser l'ordre des images dans le drawing
        List<String> imageOrder = [];
        if (drawingContent != null) {
          print('🔍 Analyse de l\'ordre des images dans drawing1.xml...');

          // Chercher les références aux images dans l'ordre d'apparition
          final imageRefs = RegExp(r'r:embed="rId(\d+)"').allMatches(drawingContent);
          final rIdToImage = <String, String>{};

          // Lire le fichier rels pour mapper les rId aux images
          for (final file in archive) {
            if (file.name == 'xl/drawings/_rels/drawing1.xml.rels') {
              final relsContent = utf8.decode(file.content as List<int>);
              final relMatches = RegExp(r'Id="rId(\d+)".*?Target="../media/(image\d+\.jpeg)"').allMatches(relsContent);
              for (final match in relMatches) {
                rIdToImage[match.group(1)!] = match.group(2)!;
              }
              break;
            }
          }

          // Construire l'ordre des images basé sur l'ordre d'apparition dans le drawing
          for (final match in imageRefs) {
            final rId = match.group(1)!;
            final imageName = rIdToImage[rId];
            if (imageName != null) {
              imageOrder.add('xl/media/$imageName');
            }
          }

          print('📍 Ordre des images trouvé: ${imageOrder.length} images');
          for (int i = 0; i < imageOrder.length; i++) {
            print('  $i: ${imageOrder[i]}');
          }
        }

        // Extraire les images dans l'ordre trouvé
        if (imageOrder.isNotEmpty) {
          for (final imagePath in imageOrder) {
            for (final file in archive) {
              if (file.name == imagePath && file.content != null) {
                final imageData = file.content as List<int>;
                final imageBytes = Uint8List.fromList(imageData);
                images.add(imageBytes);
                print('✅ Image extraite dans l\'ordre: ${file.name} (${imageBytes.length} bytes)');
                break;
              }
            }
          }
        } else {
          // Fallback: extraction normale par ordre numérique
          print('⚠️ Ordre non trouvé, extraction par ordre numérique...');

          // D'abord, compter combien d'images sont disponibles
          int maxImages = 0;
          for (final file in archive) {
            if (file.name.startsWith('xl/media/image') && file.name.endsWith('.jpeg')) {
              final imageNumber = int.tryParse(file.name.replaceAll('xl/media/image', '').replaceAll('.jpeg', ''));
              if (imageNumber != null && imageNumber > maxImages) {
                maxImages = imageNumber;
              }
            }
          }

          print('📊 Maximum d\'images détecté: $maxImages');

          // Extraire toutes les images disponibles
          for (int i = 1; i <= maxImages; i++) {
            for (final file in archive) {
              if (file.name == 'xl/media/image$i.jpeg' && file.content != null) {
                final imageData = file.content as List<int>;
                final imageBytes = Uint8List.fromList(imageData);
                images.add(imageBytes);
                print('✅ Image $i extraite: ${imageBytes.length} bytes');
                break;
              }
            }
          }
        }

        print('📊 ${images.length} images extraites dans le bon ordre');

      } catch (zipError) {
        print('⚠️ Erreur lors de la lecture de l\'archive ZIP: $zipError');
        print('💡 Le fichier pourrait être dans un ancien format Excel (.xls)');
        print('💡 Essayez de sauvegarder votre fichier au format .xlsx dans Excel');
      }

    } catch (e) {
      print('❌ Erreur lors de l\'extraction des images: $e');
      print('💡 Assurez-vous que le fichier Excel contient bien des images intégrées');
    }

    return images;
  }

  /// Lire un fichier CSV
  Future<List<Map<String, dynamic>>> readCsvFile(File file) async {
    try {
      print('📖 Lecture du fichier CSV: ${file.path}');

      final content = await file.readAsString();
      // Parsing CSV simple sans package externe
      final lines = content.split('\n');
      final List<List<dynamic>> csvData = lines.map((line) => line.split(',')).toList();

      if (csvData.isEmpty) {
        throw Exception('Le fichier CSV est vide');
      }

      // Première ligne = en-têtes
      final headers = csvData.first.map((e) => e.toString().toLowerCase().trim()).toList();
      print('📋 En-têtes CSV trouvés: $headers');

      List<Map<String, dynamic>> products = [];

      // Traiter les données (à partir de la deuxième ligne)
      for (int i = 1; i < csvData.length; i++) {
        final row = csvData[i];
        if (row.isNotEmpty) {
          final productData = _parseRowDataFromValues(
            row.map((e) => e.toString()).toList(),
            headers.map((e) => e.toString()).toList()
          );

          if (productData.isNotEmpty) {
            products.add(productData);
            print('✅ Produit CSV ajouté: ${productData['name'] ?? 'Sans nom'}');
          }
        }
      }

      print('📦 ${products.length} produits extraits du fichier CSV');
      return products;
    } catch (e) {
      print('❌ Erreur lors de la lecture du fichier CSV: $e');
      throw Exception('Erreur lors de la lecture du fichier CSV: $e');
    }
  }

  /// Télécharger une image depuis une URL
  Future<Uint8List?> downloadImageFromUrl(String imageUrl) async {
    try {
      print('🌐 Téléchargement de l\'image: $imageUrl');

      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        print('✅ Image téléchargée avec succès (${response.bodyBytes.length} bytes)');
        return response.bodyBytes;
      } else {
        print('❌ Erreur lors du téléchargement: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Erreur lors du téléchargement de l\'image: $e');
      return null;
    }
  }

  /// Convertir les données Excel en modèles de produits
  List<ProductModel> convertToProductModels(
    List<Map<String, dynamic>> excelData,
    String userId
  ) {
    List<ProductModel> products = [];

    for (int i = 0; i < excelData.length; i++) {
      final data = excelData[i];

      try {
        // Créer un ID unique pour le produit
        final productId = 'import_${DateTime.now().millisecondsSinceEpoch}_$i';

        // Extraire les données EXACTEMENT comme dans Excel (pas de génération automatique)
        final name = data['nom']?.toString().trim() ?? data['name']?.toString().trim() ?? '';
        final barcode = data['codeBarre']?.toString().trim() ?? data['barcode']?.toString().trim() ?? '';
        final description = data['description']?.toString().trim() ?? '';
        final category = data['category']?.toString().trim() ?? 'Non catégorisé';

        // Prix
        final purchasePrice = _parseDouble(data['purchasePrice'] ?? data['prixAchat'] ?? 0);
        final salePrice = _parseDouble(data['salePrice'] ?? data['prixVente'] ?? 0);

        // Stock
        final stock = _parseInt(data['stock'] ?? data['quantite'] ?? 0);
        final minStock = _parseInt(data['minStock'] ?? data['stockMin'] ?? 0);

        // Image
        String? imageUrl;
        if (data['imageBytes'] != null && data['imageBytes'] is Uint8List) {
          // Sauvegarder l'image temporairement
          imageUrl = _saveTemporaryImageSync(data['imageBytes'] as Uint8List, i);
        } else if (data['imageUrl'] != null) {
          imageUrl = data['imageUrl'].toString();
        }

        final product = ProductModel(
          id: productId,
          userId: userId,
          name: name,
          description: description,
          barcode: barcode,
          purchasePrice: purchasePrice,
          sellingPrice: salePrice,
          stockQuantity: stock.toDouble(),
          minStockThreshold: minStock,
          unit: 'pièce',
          imageUrl: imageUrl,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        products.add(product);

        // Log détaillé pour vérifier l'extraction
        final nameStatus = name.isNotEmpty ? name : '[VIDE]';
        final barcodeStatus = barcode.isNotEmpty ? barcode : '[VIDE]';
        final imageStatus = imageUrl != null ? 'avec image' : 'sans image';
        print('✅ Produit converti: nom="$nameStatus", code="$barcodeStatus", $imageStatus');

      } catch (e) {
        print('❌ Erreur lors de la conversion du produit $i: $e');
        // Continuer avec les autres produits
      }
    }

    print('📦 ${products.length} produits convertis en modèles');
    return products;
  }

  /// Parser les données d'une ligne CSV
  Map<String, dynamic> _parseRowDataFromValues(List<String> values, List<String> headers) {
    Map<String, dynamic> productData = {};

    // Mapper les colonnes selon les en-têtes
    for (int j = 0; j < values.length && j < headers.length; j++) {
      final header = headers[j].toLowerCase().trim();
      final value = values[j].trim();

      if (value.isNotEmpty) {
        _mapColumnValue(productData, header, value);
      }
    }

    return productData;
  }

  /// Mapper une valeur de colonne selon son en-tête
  void _mapColumnValue(Map<String, dynamic> productData, String header, dynamic cellValue) {
    switch (header) {
      case 'nom':
      case 'name':
      case 'produit':
        productData['name'] = cellValue.toString().trim();
        break;
      case 'code barre':
      case 'barcode':
      case 'code-barres':
      case 'codebarre':
        productData['barcode'] = cellValue.toString().trim();
        break;
      case 'description':
        productData['description'] = cellValue.toString().trim();
        break;
      case 'categorie':
      case 'category':
      case 'catégorie':
        productData['category'] = cellValue.toString().trim();
        break;
      case 'prix achat':
      case 'purchase price':
      case 'prixachat':
      case 'prix_achat':
        productData['purchasePrice'] = _parseDouble(cellValue);
        break;
      case 'prix vente':
      case 'sale price':
      case 'prixvente':
      case 'prix_vente':
        productData['salePrice'] = _parseDouble(cellValue);
        break;
      case 'stock':
      case 'quantite':
      case 'quantity':
      case 'quantité':
        productData['stock'] = _parseInt(cellValue);
        break;
      case 'stock min':
      case 'minimum stock':
      case 'stockmin':
      case 'stock_min':
        productData['minStock'] = _parseInt(cellValue);
        break;
      case 'image':
      case 'photo':
      case 'img':
        if (cellValue.toString().trim().isNotEmpty) {
          productData['imageUrl'] = cellValue.toString().trim();
        }
        break;
    }
  }

  /// Utilitaires de conversion
  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
    }
    return 0.0;
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }



  /// NOUVELLE APPROCHE : Extraire les données ligne par ligne
  Future<List<Map<String, dynamic>>> _extractDataFromExcelZip(
    String filePath,
    List<Uint8List> embeddedImages
  ) async {
    final products = <Map<String, dynamic>>[];

    try {
      print('🚀 NOUVELLE APPROCHE - Traitement ligne par ligne !');
      print('📦 Lecture du fichier Excel comme archive ZIP...');

      // Lire le fichier comme archive ZIP
      final bytes = await File(filePath).readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      // Chercher le fichier de données principal (sheet1.xml)
      ArchiveFile? sheetFile;
      for (final file in archive) {
        if (file.name.contains('xl/worksheets/sheet1.xml')) {
          sheetFile = file;
          print('📋 Fichier sheet1.xml trouvé: ${file.name}');
          break;
        }
      }

      if (sheetFile == null) {
        throw Exception('Fichier sheet1.xml non trouvé dans l\'archive Excel');
      }

      // Extraire le contenu XML
      final xmlContent = utf8.decode(sheetFile.content as List<int>);
      print('📄 Contenu XML extrait (${xmlContent.length} caractères)');

      // Chercher le fichier de chaînes partagées
      ArchiveFile? sharedStringsFile;
      for (final file in archive) {
        if (file.name == 'xl/sharedStrings.xml') {
          sharedStringsFile = file;
          print('📝 Fichier sharedStrings.xml trouvé');
          break;
        }
      }

      List<String> sharedStrings = [];
      if (sharedStringsFile != null) {
        final sharedStringsXml = utf8.decode(sharedStringsFile.content as List<int>);
        sharedStrings = _parseSharedStrings(sharedStringsXml);
        print('📚 ${sharedStrings.length} chaînes partagées extraites');
      }

      // NOUVELLE MÉTHODE : Traitement ligne par ligne
      final products = await _processRowByRowFromXml(xmlContent, sharedStrings, embeddedImages);
      print('✅ ${products.length} produits créés avec l\'approche ligne par ligne');

      return products;
    } catch (e) {
      print('❌ Erreur dans _extractDataFromExcelZip: $e');
      rethrow;
    }
  }

  /// Traiter les données ligne par ligne depuis le XML avec extraction d'image par cellule
  Future<List<Map<String, dynamic>>> _processRowByRowFromXml(
    String xmlContent,
    List<String> sharedStrings,
    List<Uint8List> embeddedImages
  ) async {
    final products = <Map<String, dynamic>>[];

    try {
      print('🔄 NOUVELLE APPROCHE : Traitement ligne par ligne avec extraction d\'image par cellule...');

      // Extraire toutes les lignes du XML
      final rowRegex = RegExp(r'<row[^>]*r="(\d+)"[^>]*>(.*?)</row>', dotAll: true);
      final rowMatches = rowRegex.allMatches(xmlContent);

      print('📊 ${rowMatches.length} lignes trouvées dans le XML');

      int productIndex = 0;

      for (final rowMatch in rowMatches) {
        final rowNumber = int.parse(rowMatch.group(1)!);
        final rowContent = rowMatch.group(2)!;

        // Ignorer la première ligne (en-têtes)
        if (rowNumber == 1) {
          print('⏭️ Ligne $rowNumber ignorée (en-têtes)');
          continue;
        }

        print('🔍 Traitement de la ligne $rowNumber...');

        // Extraire les données de cette ligne spécifique
        final rowData = await _extractRowData(rowContent, sharedStrings, rowNumber);

        if (rowData != null) {
          // APPROCHE TEMPORAIRE : Utiliser l'index du produit pour l'image
          // (En attendant l'implémentation complète de l'extraction par cellule)
          Uint8List? imageBytes;
          if (embeddedImages.isNotEmpty && productIndex < embeddedImages.length) {
            imageBytes = embeddedImages[productIndex];
            print('🖼️ Produit ${productIndex + 1} (ligne $rowNumber) → Image index $productIndex');
          } else {
            print('⚠️ Produit ${productIndex + 1} (ligne $rowNumber) → Aucune image disponible');
          }

          // Créer le produit
          final product = {
            'nom': rowData['nom'] ?? 'Produit ${productIndex + 1}',
            'codeBarre': rowData['codeBarre'] ?? '',
            'imageBytes': imageBytes,
          };

          products.add(product);
          productIndex++;

          print('✅ Produit créé: "${product['nom']}" (code: "${product['codeBarre']}") avec image index ${productIndex - 1}');
        }
      }

      print('🎉 Traitement ligne par ligne terminé: ${products.length} produits créés');
      return products;

    } catch (e) {
      print('❌ Erreur dans _processRowByRowFromXml: $e');
      rethrow;
    }
  }

  /// Extraire l'image spécifique d'une cellule C donnée
  Future<Uint8List?> _extractImageFromCell(String xmlContent, int rowNumber) async {
    try {
      print('🖼️ Recherche d\'image dans la cellule C$rowNumber...');

      // Chercher la cellule C de cette ligne spécifique
      final cellPattern = RegExp(r'<c[^>]*r="C' + rowNumber.toString() + r'"[^>]*>(.*?)</c>', dotAll: true);
      final cellMatch = cellPattern.firstMatch(xmlContent);

      if (cellMatch == null) {
        print('⚠️ Cellule C$rowNumber non trouvée');
        return null;
      }

      final cellContent = cellMatch.group(1)!;
      print('📱 Contenu de la cellule C$rowNumber trouvé');

      // Pour l'instant, retourner null car l'extraction d'image depuis une cellule spécifique
      // nécessite une analyse plus complexe du fichier Excel
      // TODO: Implémenter l'extraction d'image spécifique par cellule
      print('⚠️ Extraction d\'image par cellule pas encore implémentée');
      return null;

    } catch (e) {
      print('❌ Erreur lors de l\'extraction d\'image de C$rowNumber: $e');
      return null;
    }
  }

  /// Extraire les données d'une ligne spécifique
  Future<Map<String, String>?> _extractRowData(
    String rowContent,
    List<String> sharedStrings,
    int rowNumber
  ) async {
    try {
      print('🔍 Extraction des données de la ligne $rowNumber...');

      // Extraire toutes les cellules de cette ligne
      final cellRegex = RegExp(r'<c[^>]*r="([A-Z]+)\d+"[^>]*>(.*?)</c>', dotAll: true);
      final cellMatches = cellRegex.allMatches(rowContent);

      String nom = '';
      String codeBarre = '';

      print('📱 ${cellMatches.length} cellules trouvées dans la ligne $rowNumber');

      for (final cellMatch in cellMatches) {
        final cellRef = cellMatch.group(1)!; // A, B, C, etc.
        final cellContent = cellMatch.group(2)!;

        print('🔍 Cellule $cellRef$rowNumber: contenu brut = "${cellContent.substring(0, cellContent.length > 50 ? 50 : cellContent.length)}..."');

        // Extraire la valeur de la cellule
        String cellValue = '';

        // Vérifier si c'est une référence aux chaînes partagées
        if (cellContent.contains('<v>') && cellContent.contains('t="s"')) {
          final valueMatch = RegExp(r'<v>(\d+)</v>').firstMatch(cellContent);
          if (valueMatch != null) {
            final index = int.parse(valueMatch.group(1)!);
            if (index < sharedStrings.length) {
              cellValue = sharedStrings[index];
              print('📚 Cellule $cellRef$rowNumber: valeur depuis sharedStrings[$index] = "$cellValue"');
            }
          }
        } else if (cellContent.contains('<is><t>')) {
          // Texte inline dans les balises <is><t>...</t></is>
          final textMatch = RegExp(r'<is><t>(.*?)</t></is>').firstMatch(cellContent);
          if (textMatch != null) {
            cellValue = _decodeXmlEntities(textMatch.group(1)!);
            print('📝 Cellule $cellRef$rowNumber: texte inline = "$cellValue"');
          }
        } else if (cellContent.contains('<v>')) {
          // Valeur directe
          final valueMatch = RegExp(r'<v>(.*?)</v>').firstMatch(cellContent);
          if (valueMatch != null) {
            cellValue = _decodeXmlEntities(valueMatch.group(1)!);
            print('📝 Cellule $cellRef$rowNumber: valeur directe = "$cellValue"');
          }
        }

        // Assigner selon la colonne (EXTRACTION STRICTE)
        if (cellRef == 'A') {
          nom = cellValue.isNotEmpty ? cellValue.trim() : '';
          print(nom.isNotEmpty ? '✅ NOM trouvé dans A$rowNumber: "$nom"' : '⚠️ Cellule A$rowNumber vide - nom sera vide');
        } else if (cellRef == 'B') {
          codeBarre = cellValue.isNotEmpty ? cellValue.trim() : '';
          print(codeBarre.isNotEmpty ? '✅ CODE-BARRE trouvé dans B$rowNumber: "$codeBarre"' : '⚠️ Cellule B$rowNumber vide - code sera vide');
        }
      }

      // Retourner les données si on a au moins quelque chose
      if (nom.isNotEmpty || codeBarre.isNotEmpty) {
        // Résumé de la ligne avec statut des champs
        final nomStatus = nom.isNotEmpty ? nom : '[VIDE]';
        final codeStatus = codeBarre.isNotEmpty ? codeBarre : '[VIDE]';
        print('✅ Ligne $rowNumber: nom="$nomStatus", code="$codeStatus"');
        return {
          'nom': nom,
          'codeBarre': codeBarre,
        };
      } else {
        print('⚠️ Ligne $rowNumber: aucune donnée valide trouvée');
        return null;
      }

    } catch (e) {
      print('❌ Erreur lors de l\'extraction de la ligne $rowNumber: $e');
      return null;
    }
  }

  /// Parser les chaînes partagées du fichier Excel
  List<String> _parseSharedStrings(String xmlContent) {
    final strings = <String>[];

    try {
      print('🔍 Parsing des chaînes partagées...');
      print('📄 Contenu XML (premiers 500 caractères): ${xmlContent.substring(0, xmlContent.length > 500 ? 500 : xmlContent.length)}');

      // Rechercher toutes les balises <si> (string item) qui contiennent les chaînes
      final siRegex = RegExp(r'<si[^>]*>(.*?)</si>', dotAll: true);
      final siMatches = siRegex.allMatches(xmlContent);

      print('📊 ${siMatches.length} éléments <si> trouvés');

      for (final siMatch in siMatches) {
        final siContent = siMatch.group(1) ?? '';

        // Dans chaque <si>, chercher les balises <t> qui contiennent le texte
        final tRegex = RegExp(r'<t[^>]*>(.*?)</t>', dotAll: true);
        final tMatches = tRegex.allMatches(siContent);

        String combinedText = '';
        for (final tMatch in tMatches) {
          final text = tMatch.group(1) ?? '';
          combinedText += text;
        }

        if (combinedText.isNotEmpty) {
          final decodedText = _decodeXmlEntities(combinedText.trim());
          strings.add(decodedText);
          print('📝 Chaîne partagée ${strings.length - 1}: "$decodedText"');
        }
      }

      // Si aucune chaîne trouvée avec <si>, essayer l'ancienne méthode
      if (strings.isEmpty) {
        print('🔄 Aucune chaîne trouvée avec <si>, essai avec <t> directement...');
        final regex = RegExp(r'<t[^>]*>(.*?)</t>', dotAll: true);
        final matches = regex.allMatches(xmlContent);

        for (final match in matches) {
          final text = match.group(1) ?? '';
          if (text.trim().isNotEmpty) {
            final decodedText = _decodeXmlEntities(text.trim());
            strings.add(decodedText);
            print('📝 Chaîne directe ${strings.length - 1}: "$decodedText"');
          }
        }
      }

      print('✅ ${strings.length} chaînes partagées extraites au total');
    } catch (e) {
      print('⚠️ Erreur lors du parsing des chaînes partagées: $e');
    }

    return strings;
  }

  /// Parser les données de cellules du XML de la feuille
  Map<String, String> _parseSheetXml(String xmlContent, List<String> sharedStrings) {
    final cellData = <String, String>{};

    try {
      print('🔍 Parsing du XML de la feuille...');
      print('📊 ${sharedStrings.length} chaînes partagées disponibles');

      // Rechercher toutes les cellules, y compris celles sans valeur
      // Format 1: <c r="A1" t="s"><v>0</v></c> (avec valeur)
      // Format 2: <c r="A1" t="s"/> (sans valeur)
      // Format 3: <c r="A1"><v>123</v></c> (sans type)
      final regexWithValue = RegExp(r'<c r="([A-Z]+\d+)"[^>]*(?:\s+t="([^"]*)")?[^>]*><v>([^<]*)</v></c>');
      final regexWithoutValue = RegExp(r'<c r="([A-Z]+\d+)"[^>]*(?:\s+t="([^"]*)")?[^>]*/?>');

      final matchesWithValue = regexWithValue.allMatches(xmlContent);
      final matchesWithoutValue = regexWithoutValue.allMatches(xmlContent);

      print('📱 ${matchesWithValue.length} cellules avec valeur trouvées');
      print('📱 ${matchesWithoutValue.length} cellules sans valeur trouvées');

      // Lister toutes les cellules détectées pour débogage
      print('🔍 LISTE DES CELLULES DÉTECTÉES :');
      for (final match in matchesWithValue) {
        final cellRef = match.group(1) ?? '';
        print('   📍 Cellule avec valeur: $cellRef');
      }
      for (final match in matchesWithoutValue) {
        final cellRef = match.group(1) ?? '';
        if (!matchesWithValue.any((m) => m.group(1) == cellRef)) {
          print('   📍 Cellule sans valeur: $cellRef');
        }
      }

      // Traiter les cellules avec valeur
      for (final match in matchesWithValue) {
        final cellRef = match.group(1) ?? '';
        final cellType = match.group(2) ?? '';
        final cellValue = match.group(3) ?? '';

        String finalValue = cellValue;

        print('🔍 Cellule $cellRef: type="$cellType", valeur brute="$cellValue"');

        // Si c'est une chaîne partagée (t="s"), récupérer la valeur depuis sharedStrings
        if (cellType == 's' && sharedStrings.isNotEmpty) {
          final index = int.tryParse(cellValue);
          if (index != null && index < sharedStrings.length) {
            finalValue = sharedStrings[index];
            print('   ✅ Chaîne partagée [$index]: "$finalValue"');
          } else {
            print('   ⚠️ Index de chaîne partagée invalide: $cellValue (max: ${sharedStrings.length - 1})');
          }
        } else if (cellType == 's') {
          print('   ⚠️ Type chaîne partagée mais aucune chaîne disponible');
        } else {
          print('   📝 Valeur directe: "$finalValue"');
        }

        cellData[cellRef] = finalValue;
        print('   ➡️ Résultat final: "$finalValue"');
      }

      // Traiter les cellules sans valeur (pour débogage)
      for (final match in matchesWithoutValue) {
        final cellRef = match.group(1) ?? '';
        final cellType = match.group(2) ?? '';

        // Vérifier si cette cellule n'a pas déjà été traitée
        if (!cellData.containsKey(cellRef)) {
          print('🔍 Cellule VIDE $cellRef: type="$cellType" (pas de valeur)');
        }
      }

      print('✅ ${cellData.length} cellules parsées avec succès');
    } catch (e) {
      print('⚠️ Erreur lors du parsing du XML de la feuille: $e');
    }

    return cellData;
  }

  /// Organiser les données de cellules par lignes
  Map<int, Map<String, String>?> _organizeDataByRows(Map<String, String> cellData) {
    final rowData = <int, Map<String, String>?>{};

    for (final entry in cellData.entries) {
      final cellRef = entry.key;
      final value = entry.value;

      // Extraire le numéro de ligne et la colonne (ex: A1 -> ligne 1, colonne A)
      final match = RegExp(r'([A-Z]+)(\d+)').firstMatch(cellRef);
      if (match != null) {
        final column = match.group(1)!;
        final row = int.parse(match.group(2)!);

        if (!rowData.containsKey(row)) {
          rowData[row] = <String, String>{};
        }

        rowData[row]![column] = value;
      }
    }

    return rowData;
  }

  /// Traite les données Excel avec une approche ultra-défensive
  Future<List<Map<String, dynamic>>> _processExcelDataUltraDefensive(
    Excel excel,
    List<Uint8List> embeddedImages
  ) async {
    final products = <Map<String, dynamic>>[];

    try {
      print('🔍 Méthode ultra-défensive - Analyse des feuilles disponibles...');

      if (excel.tables.isEmpty) {
        throw Exception('Aucune feuille trouvée dans le fichier Excel');
      }

      // Essayer toutes les feuilles disponibles
      for (final sheetName in excel.tables.keys) {
        try {
          print('📋 Tentative de lecture de la feuille: $sheetName');
          final sheet = excel.tables[sheetName];

          if (sheet == null || sheet.rows.isEmpty) {
            print('⚠️ Feuille $sheetName vide ou inaccessible');
            continue;
          }

          print('📊 Feuille $sheetName: ${sheet.rows.length} lignes trouvées');

          // Essayer de lire ligne par ligne avec une approche très défensive
          for (int i = 1; i < sheet.rows.length; i++) {
            try {
              final row = sheet.rows[i];
              if (row.isEmpty) continue;

              String nom = '';
              String codeBarre = '';

              // Essayer de lire chaque cellule individuellement
              for (int j = 0; j < row.length && j < 3; j++) {
                try {
                  final cell = row[j];
                  if (cell?.value != null) {
                    final cellValue = cell!.value.toString().trim();
                    print('🔍 Ultra-défensive - Ligne $i, Cellule $j: "$cellValue"');

                    if (cellValue.isNotEmpty) {
                      if (j == 0 && nom.isEmpty) {
                        nom = cellValue;
                        print('✅ Ultra-défensive - Nom trouvé: "$nom"');
                      } else if (j == 1 && codeBarre.isEmpty) {
                        codeBarre = cellValue;
                        print('✅ Ultra-défensive - Code-barres trouvé: "$codeBarre"');
                      }
                    }
                  }
                } catch (cellError) {
                  print('⚠️ Erreur lecture cellule $j ligne $i: $cellError');
                  continue;
                }
              }

              // Si on a trouvé au moins un nom ou un code-barres
              if (nom.isNotEmpty || codeBarre.isNotEmpty) {
                if (nom.isEmpty) {
                  nom = 'Produit ${i}';
                }

                // Associer l'image correspondante
                Uint8List? imageBytes;
                if (embeddedImages.isNotEmpty && (i-1) < embeddedImages.length) {
                  imageBytes = embeddedImages[i-1];
                }

                products.add({
                  'nom': nom,
                  'codeBarre': codeBarre,
                  'imageBytes': imageBytes,
                });

                print('✅ Ultra-défensive - Produit ajouté: "$nom" (code: "${codeBarre.isNotEmpty ? codeBarre : 'sans code-barres'}")');
              }
            } catch (rowError) {
              print('⚠️ Erreur lecture ligne $i: $rowError');
              continue;
            }
          }

          // Si on a trouvé des produits dans cette feuille, on s'arrête
          if (products.isNotEmpty) {
            print('✅ ${products.length} produits trouvés dans la feuille $sheetName');
            break;
          }
        } catch (sheetError) {
          print('⚠️ Erreur lecture feuille $sheetName: $sheetError');
          continue;
        }
      }

      return products;
    } catch (e) {
      print('❌ Erreur dans _processExcelDataUltraDefensive: $e');
      rethrow;
    }
  }

  /// Sauvegarder une image temporairement (version synchrone)
  String? _saveTemporaryImageSync(Uint8List imageData, int index) {
    try {
      // Utiliser un répertoire temporaire simple
      final tempPath = Directory.systemTemp.path;
      final tempImagePath = '$tempPath/excel_image_$index.png';
      final tempFile = File(tempImagePath);
      tempFile.writeAsBytesSync(imageData);
      return tempImagePath;
    } catch (e) {
      print('❌ Erreur lors de la sauvegarde de l\'image $index: $e');
      return null;
    }
  }

  /// Décoder les entités XML et les caractères spéciaux
  String _decodeXmlEntities(String text) {
    if (text.isEmpty) return text;

    // Décoder les entités XML courantes
    String decoded = text
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'")
        .replaceAll('&#39;', "'");

    // Décoder les entités numériques hexadécimales (&#x...)
    decoded = decoded.replaceAllMapped(
      RegExp(r'&#x([0-9A-Fa-f]+);'),
      (match) {
        try {
          final hexValue = match.group(1)!;
          final codePoint = int.parse(hexValue, radix: 16);
          return String.fromCharCode(codePoint);
        } catch (e) {
          return match.group(0)!; // Retourner l'original si erreur
        }
      },
    );

    // Décoder les entités numériques décimales (&#...)
    decoded = decoded.replaceAllMapped(
      RegExp(r'&#(\d+);'),
      (match) {
        try {
          final decValue = match.group(1)!;
          final codePoint = int.parse(decValue);
          return String.fromCharCode(codePoint);
        } catch (e) {
          return match.group(0)!; // Retourner l'original si erreur
        }
      },
    );

    // Décoder quelques entités HTML courantes pour les caractères accentués
    decoded = decoded
        .replaceAll('&agrave;', 'à')
        .replaceAll('&aacute;', 'á')
        .replaceAll('&acirc;', 'â')
        .replaceAll('&atilde;', 'ã')
        .replaceAll('&auml;', 'ä')
        .replaceAll('&aring;', 'å')
        .replaceAll('&egrave;', 'è')
        .replaceAll('&eacute;', 'é')
        .replaceAll('&ecirc;', 'ê')
        .replaceAll('&euml;', 'ë')
        .replaceAll('&igrave;', 'ì')
        .replaceAll('&iacute;', 'í')
        .replaceAll('&icirc;', 'î')
        .replaceAll('&iuml;', 'ï')
        .replaceAll('&ograve;', 'ò')
        .replaceAll('&oacute;', 'ó')
        .replaceAll('&ocirc;', 'ô')
        .replaceAll('&otilde;', 'õ')
        .replaceAll('&ouml;', 'ö')
        .replaceAll('&ugrave;', 'ù')
        .replaceAll('&uacute;', 'ú')
        .replaceAll('&ucirc;', 'û')
        .replaceAll('&uuml;', 'ü')
        .replaceAll('&ccedil;', 'ç')
        .replaceAll('&ntilde;', 'ñ')
        .replaceAll('&Agrave;', 'À')
        .replaceAll('&Aacute;', 'Á')
        .replaceAll('&Acirc;', 'Â')
        .replaceAll('&Atilde;', 'Ã')
        .replaceAll('&Auml;', 'Ä')
        .replaceAll('&Aring;', 'Å')
        .replaceAll('&Egrave;', 'È')
        .replaceAll('&Eacute;', 'É')
        .replaceAll('&Ecirc;', 'Ê')
        .replaceAll('&Euml;', 'Ë')
        .replaceAll('&Igrave;', 'Ì')
        .replaceAll('&Iacute;', 'Í')
        .replaceAll('&Icirc;', 'Î')
        .replaceAll('&Iuml;', 'Ï')
        .replaceAll('&Ograve;', 'Ò')
        .replaceAll('&Oacute;', 'Ó')
        .replaceAll('&Ocirc;', 'Ô')
        .replaceAll('&Otilde;', 'Õ')
        .replaceAll('&Ouml;', 'Ö')
        .replaceAll('&Ugrave;', 'Ù')
        .replaceAll('&Uacute;', 'Ú')
        .replaceAll('&Ucirc;', 'Û')
        .replaceAll('&Uuml;', 'Ü')
        .replaceAll('&Ccedil;', 'Ç')
        .replaceAll('&Ntilde;', 'Ñ');

    return decoded;
  }

}

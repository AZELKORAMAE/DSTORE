# Guide d'importation de produits depuis Excel

## Fonctionnalité d'importation Excel

Cette fonctionnalité permet d'importer des produits en masse depuis un fichier Excel (.xlsx ou .xls).

## Comment utiliser l'importation Excel

### 1. Accéder à la fonctionnalité
- Allez dans l'écran "Produits"
- Cliquez sur le bouton orange d'importation (icône upload) en bas à droite
- Sélectionnez "Depuis un fichier Excel"

### 2. Format du fichier Excel requis

#### Colonnes obligatoires :
- **nom** : Nom du produit (obligatoire)

#### Colonnes optionnelles :
- **code barre** : Code-barres du produit
- **image** : URL de l'image du produit
- **description** : Description du produit
- **prix_achat** : Prix d'achat en DH
- **prix_vente** : Prix de vente en DH
- **stock** : Quantité en stock
- **unite** : Unité de mesure (pièce, kg, l, etc.)
- **categorie** : Nom de la catégorie

#### Variantes acceptées pour les noms de colonnes :
- **Nom** : nom, name, produit
- **Code-barres** : code barre, code_barre, barcode, code-barre
- **Image** : image, image_url, photo
- **Prix d'achat** : prix_achat, prix achat, purchase_price
- **Prix de vente** : prix_vente, prix vente, selling_price
- **Stock** : stock, quantite, quantity, stock_quantity
- **Unité** : unite, unit, unité
- **Catégorie** : categorie, category, catégorie

### 3. Exemple de fichier Excel

```
nom                | code barre      | image                           | prix_achat | prix_vente | stock | unite | categorie
acm rosakalm 40ml  | 3760050520913   | https://example.com/image1.jpg  | 45.50      | 65.00      | 10    | pièce | Cosmétiques
anjan xxl sun      | 3760050521001   | https://example.com/image2.jpg  | 38.00      | 55.00      | 15    | pièce | Cosmétiques
Shampoing Doux     | 1234567890123   |                                 | 12.50      | 18.00      | 25    | pièce | Hygiène
```

### 4. Processus d'importation

1. **Sélection du fichier** : Choisissez votre fichier Excel
2. **Lecture automatique** : L'application lit et analyse le fichier
3. **Vérification des données** : Les produits trouvés sont affichés
4. **Complétion des données** : Complétez les informations manquantes :
   - Sélectionnez une catégorie pour chaque produit
   - Ajoutez les prix d'achat et de vente si manquants
   - Définissez le stock initial
   - Choisissez l'unité de mesure
5. **Importation** : Cliquez sur le bouton de sauvegarde pour importer tous les produits

### 5. Gestion des images

- Si une URL d'image est fournie dans le fichier Excel, l'application tentera de télécharger l'image automatiquement
- Les images sont sauvegardées localement dans l'application
- Si le téléchargement échoue, le produit sera créé sans image

### 6. Gestion des erreurs

- Les produits sans nom seront ignorés
- Les erreurs de téléchargement d'images n'empêchent pas la création du produit
- Un résumé des succès et erreurs est affiché à la fin de l'importation

### 7. Conseils pour un import réussi

1. **Préparez vos catégories** : Créez d'abord les catégories dans l'application
2. **Vérifiez les URLs d'images** : Assurez-vous que les URLs sont accessibles
3. **Format des nombres** : Utilisez le point (.) comme séparateur décimal
4. **Encodage du fichier** : Sauvegardez votre Excel en UTF-8 pour éviter les problèmes d'accents
5. **Testez avec un petit fichier** : Commencez par importer quelques produits pour tester

### 8. Limitations

- Formats supportés : .xlsx et .xls uniquement
- Taille maximale du fichier : Dépend de la mémoire disponible
- Images : Seules les URLs HTTP/HTTPS sont supportées
- Catégories : Doivent être créées manuellement avant l'import

### 9. Exemple de fichier CSV (peut être converti en Excel)

Un fichier d'exemple `exemple_produits.csv` est fourni dans le projet pour vous aider à comprendre le format attendu.

## Support

Si vous rencontrez des problèmes lors de l'importation :
1. Vérifiez le format de votre fichier Excel
2. Assurez-vous que la colonne "nom" est présente et remplie
3. Vérifiez que les URLs d'images sont valides
4. Consultez les messages d'erreur affichés dans l'application

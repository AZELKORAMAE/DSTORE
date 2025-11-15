# Guide pour créer un fichier Excel avec les vraies images de produits

## 📋 Structure requise du fichier Excel

Votre fichier Excel doit contenir **exactement 3 colonnes** :

| nom | code barre | image |
|-----|------------|-------|
| Nom du produit | Code-barres | Image du produit |

## 🖼️ Comment ajouter les vraies images de produits

### Méthode 1 : Images intégrées dans Excel
1. **Ouvrez Excel** et créez un nouveau fichier
2. **Créez 3 colonnes** : `nom`, `code barre`, `image`
3. **Remplissez les données** des produits
4. **Pour chaque produit** :
   - Cliquez sur la cellule de la colonne "image"
   - Allez dans **Insertion > Images > Cet appareil**
   - Sélectionnez la vraie photo du produit
   - Redimensionnez l'image pour qu'elle tienne dans la cellule

### Méthode 2 : URLs d'images (plus simple)
1. **Hébergez vos images** sur un service comme :
   - Google Drive (liens publics)
   - Imgur
   - Votre propre serveur
2. **Dans la colonne image**, mettez l'URL directe de l'image :
   ```
   https://example.com/images/produit1.jpg
   ```

## 📝 Exemple de fichier Excel correct

```
nom                          | code barre    | image
ACM Rosakalm 40ml           | 123456789     | [IMAGE DU PRODUIT]
Anian Gel 250ml             | 987654321     | [IMAGE DU PRODUIT]
Bioderma Photoderm 30ml     | 456789123     | [IMAGE DU PRODUIT]
```

## ⚠️ Points importants

1. **Noms de colonnes exacts** : `nom`, `code barre`, `image`
2. **Pas d'espaces supplémentaires** dans les noms de colonnes
3. **Une image par produit** dans la même ligne
4. **Images de bonne qualité** (recommandé : 200x200 pixels minimum)
5. **Formats supportés** : JPG, PNG, GIF

## 🚀 Après création du fichier

1. **Sauvegardez** le fichier en format `.xlsx`
2. **Testez l'import** dans l'application
3. **Vérifiez** que chaque produit a sa vraie image

## 💡 Conseils

- **Nommez vos images** de façon claire (ex: `acm_rosakalm.jpg`)
- **Gardez les images** dans un dossier organisé
- **Testez avec quelques produits** avant de faire tout le catalogue

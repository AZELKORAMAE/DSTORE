#!/usr/bin/env python3
"""
Script pour créer un fichier Excel d'exemple pour tester l'importation de produits
"""

import pandas as pd

# Données d'exemple pour les produits
products_data = [
    {
        'nom': 'ACM Rosakalm 40ml',
        'code barre': '3760050520913',
        'image': 'https://via.placeholder.com/150x150/FF6B6B/FFFFFF?text=ACM',
        'description': 'Crème apaisante pour peaux sensibles et réactives',
        'prix_achat': 45.50,
        'prix_vente': 65.00,
        'stock': 10,
        'unite': 'pièce',
        'categorie': 'Cosmétiques'
    },
    {
        'nom': 'Anjan XXL Sun',
        'code barre': '3760050521001',
        'image': 'https://via.placeholder.com/150x150/4ECDC4/FFFFFF?text=ANJAN',
        'description': 'Crème solaire protection maximale SPF 50+',
        'prix_achat': 38.00,
        'prix_vente': 55.00,
        'stock': 15,
        'unite': 'pièce',
        'categorie': 'Cosmétiques'
    },
    {
        'nom': 'Shampoing Doux',
        'code barre': '1234567890123',
        'image': '',
        'description': 'Shampoing pour cheveux normaux à secs',
        'prix_achat': 12.50,
        'prix_vente': 18.00,
        'stock': 25,
        'unite': 'pièce',
        'categorie': 'Hygiène'
    },
    {
        'nom': 'Dentifrice Blancheur',
        'code barre': '9876543210987',
        'image': '',
        'description': 'Dentifrice blanchissant au fluor',
        'prix_achat': 8.75,
        'prix_vente': 12.50,
        'stock': 30,
        'unite': 'pièce',
        'categorie': 'Hygiène'
    },
    {
        'nom': 'Vitamine C 1000mg',
        'code barre': '5555666677778',
        'image': 'https://via.placeholder.com/150x150/FFE66D/000000?text=VIT+C',
        'description': 'Complément alimentaire vitamine C',
        'prix_achat': 25.00,
        'prix_vente': 35.00,
        'stock': 20,
        'unite': 'boîte',
        'categorie': 'Pharmacie'
    },
    {
        'nom': 'Paracétamol 500mg',
        'code barre': '1111222233334',
        'image': '',
        'description': 'Antalgique et antipyrétique',
        'prix_achat': 3.50,
        'prix_vente': 5.00,
        'stock': 50,
        'unite': 'boîte',
        'categorie': 'Pharmacie'
    }
]

# Créer un DataFrame
df = pd.DataFrame(products_data)

# Sauvegarder en Excel
df.to_excel('exemple_produits.xlsx', index=False, sheet_name='Produits')

print("✅ Fichier Excel créé: exemple_produits.xlsx")
print(f"📦 {len(products_data)} produits ajoutés")
print("\nColonnes disponibles:")
for col in df.columns:
    print(f"  - {col}")

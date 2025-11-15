-- Script pour nettoyer complètement la base de données
-- À exécuter dans l'éditeur SQL de Supabase

-- 1. Supprimer tous les utilisateurs de auth.users
DELETE FROM auth.users;

-- 2. Supprimer toutes les données des tables personnalisées
DELETE FROM verification_codes;
DELETE FROM purchase_order_items;
DELETE FROM purchase_orders;
DELETE FROM stock_movements;
DELETE FROM invoice_items;
DELETE FROM invoices;
DELETE FROM products;
DELETE FROM categories;
DELETE FROM suppliers;
DELETE FROM clients;
DELETE FROM users;

-- 3. Créer la table verification_codes si elle n'existe pas
CREATE TABLE IF NOT EXISTS verification_codes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email TEXT NOT NULL,
  code TEXT NOT NULL,
  expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
  used BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Activer RLS sur verification_codes
ALTER TABLE verification_codes ENABLE ROW LEVEL SECURITY;

-- 5. Créer la politique d'accès pour verification_codes
DROP POLICY IF EXISTS "Anyone can manage verification codes" ON verification_codes;
CREATE POLICY "Anyone can manage verification codes" ON verification_codes FOR ALL USING (true);

-- 6. Créer les index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_verification_codes_email ON verification_codes(email);
CREATE INDEX IF NOT EXISTS idx_verification_codes_expires_at ON verification_codes(expires_at);
CREATE INDEX IF NOT EXISTS idx_verification_codes_used ON verification_codes(used);

-- 7. Vérifier que les tables sont vides
SELECT 'auth.users' as table_name, COUNT(*) as count FROM auth.users
UNION ALL
SELECT 'verification_codes', COUNT(*) FROM verification_codes
UNION ALL
SELECT 'users', COUNT(*) FROM users
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'categories', COUNT(*) FROM categories;

-- 8. Fonction pour nettoyer automatiquement les codes expirés
CREATE OR REPLACE FUNCTION cleanup_expired_verification_codes()
RETURNS void AS $$
BEGIN
  DELETE FROM verification_codes 
  WHERE expires_at < NOW() OR used = true;
END;
$$ LANGUAGE plpgsql;

-- 9. Créer un trigger pour nettoyer automatiquement les anciens codes
-- (Optionnel - peut être exécuté manuellement)
-- SELECT cleanup_expired_verification_codes();

-- Migration pour ajouter la colonne image_path à la table invoices
-- À exécuter dans l'éditeur SQL de Supabase

-- Ajouter la colonne image_path à la table invoices
ALTER TABLE invoices 
ADD COLUMN IF NOT EXISTS image_path TEXT;

-- Créer un index sur image_path pour optimiser les requêtes
CREATE INDEX IF NOT EXISTS idx_invoices_image_path ON invoices(image_path);

-- Vérifier que la colonne a été ajoutée
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'invoices' 
AND column_name = 'image_path';

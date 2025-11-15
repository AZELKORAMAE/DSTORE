-- Migration pour ajouter les colonnes manquantes aux tables clients et suppliers
-- À exécuter dans l'éditeur SQL de Supabase

-- Ajouter les colonnes manquantes à la table clients
ALTER TABLE clients 
ADD COLUMN IF NOT EXISTS city TEXT,
ADD COLUMN IF NOT EXISTS notes TEXT,
ADD COLUMN IF NOT EXISTS total_purchases DECIMAL(10,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS last_purchase_date TIMESTAMP WITH TIME ZONE;

-- Ajouter les colonnes manquantes à la table suppliers
ALTER TABLE suppliers 
ADD COLUMN IF NOT EXISTS city TEXT,
ADD COLUMN IF NOT EXISTS notes TEXT,
ADD COLUMN IF NOT EXISTS total_purchases DECIMAL(10,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS last_order_date TIMESTAMP WITH TIME ZONE;

-- Ajouter les colonnes manquantes à la table invoices
ALTER TABLE invoices
ADD COLUMN IF NOT EXISTS supplier_id UUID REFERENCES suppliers(id) ON DELETE SET NULL,
ADD COLUMN IF NOT EXISTS invoice_type TEXT DEFAULT 'sale' CHECK (invoice_type IN ('sale', 'purchase'));

-- Mettre à jour les valeurs par défaut pour les colonnes existantes
UPDATE clients SET total_purchases = 0 WHERE total_purchases IS NULL;
UPDATE suppliers SET total_purchases = 0 WHERE total_purchases IS NULL;
UPDATE invoices SET invoice_type = 'sale' WHERE invoice_type IS NULL;

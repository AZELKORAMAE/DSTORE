-- Script complet pour créer la table suppliers et mettre à jour les tables existantes
-- À exécuter dans l'éditeur SQL de Supabase

-- 1. Création de la table suppliers
CREATE TABLE IF NOT EXISTS suppliers (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(50),
    address TEXT,
    city VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100),
    tax_number VARCHAR(100),
    notes TEXT,
    total_purchases DECIMAL(10,2) DEFAULT 0,
    last_order_date TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_suppliers_user_id ON suppliers(user_id);
CREATE INDEX IF NOT EXISTS idx_suppliers_name ON suppliers(name);
CREATE INDEX IF NOT EXISTS idx_suppliers_email ON suppliers(email);

-- 3. Politique de sécurité RLS (Row Level Security)
ALTER TABLE suppliers ENABLE ROW LEVEL SECURITY;

-- Supprimer les anciennes politiques si elles existent
DROP POLICY IF EXISTS "Users can view their own suppliers" ON suppliers;
DROP POLICY IF EXISTS "Users can insert their own suppliers" ON suppliers;
DROP POLICY IF EXISTS "Users can update their own suppliers" ON suppliers;
DROP POLICY IF EXISTS "Users can delete their own suppliers" ON suppliers;

-- Créer les nouvelles politiques
CREATE POLICY "Users can view their own suppliers" ON suppliers
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own suppliers" ON suppliers
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own suppliers" ON suppliers
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own suppliers" ON suppliers
    FOR DELETE USING (auth.uid() = user_id);

-- 4. Trigger pour mettre à jour automatiquement updated_at
CREATE OR REPLACE FUNCTION update_suppliers_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_suppliers_updated_at ON suppliers;
CREATE TRIGGER trigger_update_suppliers_updated_at
    BEFORE UPDATE ON suppliers
    FOR EACH ROW
    EXECUTE FUNCTION update_suppliers_updated_at();

-- 5. Ajouter les colonnes manquantes à la table invoices
ALTER TABLE invoices
ADD COLUMN IF NOT EXISTS supplier_id UUID REFERENCES suppliers(id) ON DELETE SET NULL,
ADD COLUMN IF NOT EXISTS invoice_type TEXT DEFAULT 'sale' CHECK (invoice_type IN ('sale', 'purchase'));

-- 6. Mettre à jour les valeurs par défaut
UPDATE invoices SET invoice_type = 'sale' WHERE invoice_type IS NULL;

-- 7. Ajouter quelques fournisseurs de test (optionnel - décommentez si nécessaire)
-- INSERT INTO suppliers (user_id, name, email, phone, address, city, country) VALUES
-- (auth.uid(), 'Fournisseur Test 1', 'fournisseur1@test.com', '+33123456789', '123 Rue Test', 'Paris', 'France'),
-- (auth.uid(), 'Fournisseur Test 2', 'fournisseur2@test.com', '+33987654321', '456 Avenue Test', 'Lyon', 'France');

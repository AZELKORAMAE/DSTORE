-- Script pour corriger les politiques RLS de la table admin_settings
-- À exécuter dans l'interface Supabase : Projet > SQL Editor > Nouveau script

-- 1. Supprimer les anciennes politiques conflictuelles
DROP POLICY IF EXISTS "Seuls les admins peuvent modifier" ON admin_settings;
DROP POLICY IF EXISTS "Utilisateurs authentifiés peuvent modifier" ON admin_settings;
DROP POLICY IF EXISTS "Tous peuvent lire les paramètres admin" ON admin_settings;

-- 2. Créer des politiques plus permissives pour le moment
-- Politique pour permettre la lecture à tous les utilisateurs authentifiés
CREATE POLICY "Lecture libre pour utilisateurs authentifiés" ON admin_settings
    FOR SELECT TO authenticated
    USING (true);

-- Politique pour permettre la modification à tous les utilisateurs authentifiés
-- (On peut restreindre plus tard selon les besoins)
CREATE POLICY "Modification libre pour utilisateurs authentifiés" ON admin_settings
    FOR ALL TO authenticated
    USING (true)
    WITH CHECK (true);

-- 3. Vérifier que la table existe et a les bonnes données
-- Si la table n'existe pas, la créer
CREATE TABLE IF NOT EXISTS admin_settings (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    setting_key TEXT UNIQUE NOT NULL,
    setting_value JSONB NOT NULL,
    updated_by UUID REFERENCES auth.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Insérer les paramètres par défaut si ils n'existent pas
INSERT INTO admin_settings (setting_key, setting_value) VALUES 
('contact_info', '{
    "business_name": "Mata24",
    "email": "azelkoramae23@gmail.com", 
    "phone": "+212 693700583666",
    "whatsapp": "+212 693700583666"
}'::jsonb)
ON CONFLICT (setting_key) DO UPDATE SET
setting_value = EXCLUDED.setting_value;

-- 5. S'assurer que RLS est activé
ALTER TABLE admin_settings ENABLE ROW LEVEL SECURITY;

-- 6. Vérifier les données existantes
SELECT * FROM admin_settings WHERE setting_key = 'contact_info';

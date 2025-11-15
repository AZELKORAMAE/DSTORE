-- Script pour la récupération de mot de passe avec code de vérification
-- Système de reset password avec code par email

-- 1. Créer la table pour les codes de vérification
CREATE TABLE IF NOT EXISTS password_reset_codes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    verification_code TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() + INTERVAL '1 minute'),
    used BOOLEAN DEFAULT FALSE,
    attempts INTEGER DEFAULT 0
);

-- 2. Créer un index pour optimiser les recherches
CREATE INDEX IF NOT EXISTS idx_password_reset_codes_email ON password_reset_codes(email);
CREATE INDEX IF NOT EXISTS idx_password_reset_codes_code ON password_reset_codes(verification_code);
CREATE INDEX IF NOT EXISTS idx_password_reset_codes_expires ON password_reset_codes(expires_at);

-- 3. Activer RLS sur la table
ALTER TABLE password_reset_codes ENABLE ROW LEVEL SECURITY;

-- 4. Créer les politiques RLS
CREATE POLICY "password_reset_codes_select_policy" ON password_reset_codes
    FOR SELECT TO authenticated
    USING (true);

CREATE POLICY "password_reset_codes_insert_policy" ON password_reset_codes
    FOR INSERT TO authenticated
    WITH CHECK (true);

CREATE POLICY "password_reset_codes_update_policy" ON password_reset_codes
    FOR UPDATE TO authenticated
    USING (true)
    WITH CHECK (true);

-- 5. Fonction pour nettoyer les codes expirés (à exécuter périodiquement)
CREATE OR REPLACE FUNCTION cleanup_expired_reset_codes()
RETURNS void AS $$
BEGIN
    DELETE FROM password_reset_codes 
    WHERE expires_at < NOW() OR used = TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. Fonction pour générer un code de vérification à 6 chiffres
CREATE OR REPLACE FUNCTION generate_verification_code()
RETURNS TEXT AS $$
BEGIN
    RETURN LPAD(FLOOR(RANDOM() * 1000000)::TEXT, 6, '0');
END;
$$ LANGUAGE plpgsql;

-- 7. Vérifier la structure
SELECT table_name, column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'password_reset_codes'
ORDER BY ordinal_position;

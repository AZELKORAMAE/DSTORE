-- Script pour ajouter la colonne password à la table users
-- À exécuter dans l'interface Supabase : Projet > SQL Editor > Nouveau script

-- ========================================
-- 1. AJOUTER LA COLONNE PASSWORD
-- ========================================

-- Ajouter la colonne password à la table users
ALTER TABLE users ADD COLUMN IF NOT EXISTS password TEXT;

-- ========================================
-- 2. METTRE À JOUR LES MOTS DE PASSE EXISTANTS
-- ========================================

-- Mettre un mot de passe par défaut pour les utilisateurs existants
-- REMPLACEZ 'votre_mot_de_passe_actuel' par votre vrai mot de passe
UPDATE users 
SET password = 'mata2024!' 
WHERE email = 'azelkoramae@gmail.com' AND password IS NULL;

-- ========================================
-- 3. FONCTION POUR SYNCHRONISER LES MOTS DE PASSE
-- ========================================

-- Fonction pour mettre à jour le mot de passe dans la table users
CREATE OR REPLACE FUNCTION update_user_password_simple(
    user_email TEXT,
    new_password TEXT
) RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Mettre à jour le mot de passe dans la table users
    UPDATE users 
    SET password = new_password,
        updated_at = NOW()
    WHERE email = user_email;
    
    -- Vérifier que la mise à jour a réussi
    IF FOUND THEN
        RETURN TRUE;
    ELSE
        RAISE EXCEPTION 'Utilisateur non trouvé: %', user_email;
    END IF;
END;
$$;

-- ========================================
-- 4. ACCORDER LES PERMISSIONS
-- ========================================

-- Accorder les permissions sur la fonction
GRANT EXECUTE ON FUNCTION update_user_password_simple(TEXT, TEXT) TO authenticated, anon;

-- ========================================
-- 5. VÉRIFICATIONS
-- ========================================

-- Vérifier la structure de la table users
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'users' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- Vérifier les données utilisateur
SELECT id, business_name, email, password, created_at, updated_at
FROM users
WHERE email = 'azelkoramae@gmail.com';

-- Message de confirmation
SELECT 'Colonne password ajoutée avec succès à la table users!' as status;

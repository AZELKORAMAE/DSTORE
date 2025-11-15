-- Script pour corriger les utilisateurs existants sans mot de passe
-- À exécuter dans l'interface Supabase : Projet > SQL Editor > Nouveau script

-- ========================================
-- 1. DIAGNOSTIC DES UTILISATEURS SANS MOT DE PASSE
-- ========================================

-- Identifier les utilisateurs sans mot de passe
SELECT 
    'UTILISATEURS SANS MOT DE PASSE' as section,
    id,
    email,
    full_name,
    business_name,
    account_status,
    created_at
FROM users 
WHERE password IS NULL OR password = ''
ORDER BY created_at DESC;

-- ========================================
-- 2. FONCTION POUR DÉFINIR UN MOT DE PASSE TEMPORAIRE
-- ========================================

-- Créer une fonction pour définir un mot de passe temporaire
CREATE OR REPLACE FUNCTION set_temporary_password(
    user_email TEXT,
    temp_password TEXT DEFAULT 'TempPassword2024!'
) RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    user_record RECORD;
BEGIN
    -- Vérifier que l'utilisateur existe
    SELECT * INTO user_record FROM users WHERE email = user_email;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Utilisateur non trouvé: %', user_email;
    END IF;
    
    -- Mettre à jour le mot de passe
    UPDATE users 
    SET 
        password = temp_password,
        updated_at = NOW()
    WHERE email = user_email;
    
    RAISE NOTICE 'Mot de passe temporaire défini pour: %', user_email;
    RETURN TRUE;
    
EXCEPTION WHEN OTHERS THEN
    RAISE EXCEPTION 'Erreur lors de la mise à jour: %', SQLERRM;
    RETURN FALSE;
END;
$$;

-- ========================================
-- 3. CORRIGER LES UTILISATEURS SPÉCIFIQUES
-- ========================================

-- Exemple pour corriger un utilisateur spécifique
-- REMPLACEZ 'votre_email@example.com' par l'email réel
-- REMPLACEZ 'VotreMotDePasse123!' par le mot de passe souhaité

-- Pour l'utilisateur principal (exemple)
-- SELECT set_temporary_password('azelkoramae@gmail.com', 'mata2024!');

-- ========================================
-- 4. CORRIGER TOUS LES UTILISATEURS SANS MOT DE PASSE
-- ========================================

-- ATTENTION: Cette section définit un mot de passe temporaire pour TOUS les utilisateurs sans mot de passe
-- Décommentez seulement si vous voulez appliquer cela à tous les utilisateurs

/*
DO $$
DECLARE
    user_record RECORD;
    temp_password TEXT := 'TempPassword2024!';
    updated_count INTEGER := 0;
BEGIN
    -- Parcourir tous les utilisateurs sans mot de passe
    FOR user_record IN 
        SELECT id, email FROM users 
        WHERE password IS NULL OR password = ''
    LOOP
        -- Mettre à jour le mot de passe
        UPDATE users 
        SET 
            password = temp_password,
            updated_at = NOW()
        WHERE id = user_record.id;
        
        updated_count := updated_count + 1;
        RAISE NOTICE 'Mot de passe défini pour: % (ID: %)', user_record.email, user_record.id;
    END LOOP;
    
    RAISE NOTICE 'Total d''utilisateurs mis à jour: %', updated_count;
END $$;
*/

-- ========================================
-- 5. VÉRIFICATION APRÈS CORRECTION
-- ========================================

-- Vérifier l'état après correction
SELECT 
    'ÉTAT APRÈS CORRECTION' as section,
    COUNT(*) as total_users,
    COUNT(CASE WHEN password IS NOT NULL AND password != '' THEN 1 END) as users_with_password,
    COUNT(CASE WHEN password IS NULL OR password = '' THEN 1 END) as users_without_password
FROM users;

-- Afficher les utilisateurs récemment mis à jour
SELECT 
    'UTILISATEURS MIS À JOUR' as section,
    email,
    full_name,
    CASE 
        WHEN password IS NOT NULL AND password != '' THEN 'OUI' 
        ELSE 'NON' 
    END as has_password,
    updated_at
FROM users 
WHERE updated_at > NOW() - INTERVAL '1 hour'
ORDER BY updated_at DESC;

-- ========================================
-- 6. INSTRUCTIONS POUR L'UTILISATEUR
-- ========================================

SELECT 
    'INSTRUCTIONS' as section,
    'Pour corriger un utilisateur spécifique, utilisez:' as instruction_1,
    'SELECT set_temporary_password(''email@example.com'', ''NouveauMotDePasse'');' as instruction_2,
    'Remplacez email@example.com et NouveauMotDePasse par les vraies valeurs' as instruction_3;

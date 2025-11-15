-- Script pour diagnostiquer et corriger les problèmes de mot de passe
-- À exécuter dans l'interface Supabase : Projet > SQL Editor > Nouveau script

-- ========================================
-- 1. DIAGNOSTIC COMPLET
-- ========================================

-- Vérifier l'état actuel de l'utilisateur
SELECT 
    'ÉTAT UTILISATEUR' as section,
    id,
    email,
    business_name,
    account_status,
    password IS NOT NULL as has_password_in_users,
    LENGTH(password) as password_length,
    created_at,
    updated_at
FROM users 
WHERE email = 'azelkoramae@gmail.com';

-- Vérifier dans auth.users aussi
SELECT 
    'ÉTAT AUTH.USERS' as section,
    id,
    email,
    encrypted_password IS NOT NULL as has_encrypted_password,
    LENGTH(encrypted_password) as encrypted_password_length,
    created_at,
    updated_at
FROM auth.users 
WHERE email = 'azelkoramae@gmail.com';

-- ========================================
-- 2. CORRECTION : DÉFINIR UN NOUVEAU MOT DE PASSE
-- ========================================

-- Définir un nouveau mot de passe simple pour les tests
-- CHANGEZ 'nouveaumotdepasse123' par le mot de passe que vous voulez
DO $$
DECLARE
    user_email TEXT := 'azelkoramae@gmail.com';
    new_password TEXT := 'nouveaumotdepasse123';  -- CHANGEZ ICI
    user_id UUID;
BEGIN
    -- Récupérer l'ID utilisateur
    SELECT id INTO user_id FROM users WHERE email = user_email;
    
    IF user_id IS NOT NULL THEN
        -- 1. Mettre à jour dans la table users (mot de passe en clair pour notre système)
        UPDATE users 
        SET 
            password = new_password,
            updated_at = NOW()
        WHERE email = user_email;
        
        RAISE NOTICE 'Mot de passe mis à jour dans la table users';
        
        -- 2. Mettre à jour dans auth.users (mot de passe chiffré pour Supabase)
        UPDATE auth.users 
        SET 
            encrypted_password = crypt(new_password, gen_salt('bf')),
            updated_at = NOW()
        WHERE email = user_email;
        
        RAISE NOTICE 'Mot de passe mis à jour dans auth.users';
        
        -- 3. S'assurer que le compte est actif
        UPDATE users 
        SET 
            account_status = 'active',
            subscription_type = 'premium',
            subscription_start_date = NOW(),
            subscription_end_date = NOW() + INTERVAL '365 days',
            updated_at = NOW()
        WHERE email = user_email;
        
        RAISE NOTICE 'Compte activé';
        
    ELSE
        RAISE NOTICE 'Utilisateur non trouvé';
    END IF;
END $$;

-- ========================================
-- 3. VÉRIFICATION FINALE
-- ========================================

-- Vérifier que tout est correct
SELECT 
    'VÉRIFICATION FINALE' as section,
    email,
    account_status,
    subscription_type,
    password IS NOT NULL as has_password,
    LENGTH(password) as password_length,
    subscription_end_date > NOW() as subscription_valid
FROM users 
WHERE email = 'azelkoramae@gmail.com';

-- Vérifier auth.users
SELECT 
    'VÉRIFICATION AUTH' as section,
    email,
    encrypted_password IS NOT NULL as has_encrypted_password,
    LENGTH(encrypted_password) as encrypted_length
FROM auth.users 
WHERE email = 'azelkoramae@gmail.com';

-- Autoriser tous les appareils
UPDATE user_devices 
SET 
    is_authorized = true,
    updated_at = NOW()
WHERE user_id = (
    SELECT id FROM users WHERE email = 'azelkoramae@gmail.com'
);

-- Compter les appareils autorisés
SELECT 
    'APPAREILS' as section,
    COUNT(*) as total_devices,
    COUNT(CASE WHEN is_authorized = true THEN 1 END) as authorized_devices
FROM user_devices ud
JOIN users u ON ud.user_id = u.id
WHERE u.email = 'azelkoramae@gmail.com';

-- Message final
SELECT 
    'RÉSULTAT' as status,
    'Mot de passe réinitialisé à: nouveaumotdepasse123' as message,
    'Changez ce mot de passe dans le script avant exécution!' as important,
    NOW() as timestamp;

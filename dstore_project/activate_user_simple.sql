-- Script ultra-simple pour activer votre compte (SANS LOGS)
-- À exécuter dans l'interface Supabase : Projet > SQL Editor > Nouveau script

-- ========================================
-- 1. VÉRIFIER LE STATUT ACTUEL
-- ========================================

-- Vérifier les informations de l'utilisateur
SELECT 
    'AVANT ACTIVATION' as section,
    email,
    account_status,
    subscription_type,
    subscription_end_date,
    password IS NOT NULL as has_password
FROM users 
WHERE email = 'azelkoramae@gmail.com';

-- Vérifier les appareils
SELECT 
    'APPAREILS AVANT' as section,
    device_id,
    device_name,
    is_authorized
FROM user_devices ud
JOIN users u ON ud.user_id = u.id
WHERE u.email = 'azelkoramae@gmail.com';

-- ========================================
-- 2. ACTIVER LE COMPTE DIRECTEMENT
-- ========================================

-- Activer le compte
UPDATE users
SET
    account_status = 'active',
    subscription_type = 'premium',
    subscription_start_date = NOW(),
    subscription_end_date = NOW() + INTERVAL '365 days',
    updated_at = NOW()
WHERE email = 'azelkoramae@gmail.com';

-- Autoriser tous les appareils
UPDATE user_devices
SET
    is_authorized = true,
    updated_at = NOW()
WHERE user_id = (
    SELECT id FROM users WHERE email = 'azelkoramae@gmail.com'
);

-- ========================================
-- 3. VÉRIFIER QUE TOUT EST ACTIVÉ
-- ========================================

-- Vérifier le compte après activation
SELECT 
    'APRÈS ACTIVATION' as section,
    email,
    account_status,
    subscription_type,
    subscription_start_date,
    subscription_end_date,
    subscription_end_date > NOW() as subscription_valid,
    password IS NOT NULL as has_password
FROM users 
WHERE email = 'azelkoramae@gmail.com';

-- Vérifier les appareils après activation
SELECT
    'APPAREILS APRÈS' as section,
    ud.device_id,
    ud.device_name,
    ud.is_authorized,
    ud.updated_at
FROM user_devices ud
JOIN users u ON ud.user_id = u.id
WHERE u.email = 'azelkoramae@gmail.com';

-- ========================================
-- 4. FONCTION SIMPLE POUR FUTURES ACTIVATIONS
-- ========================================

-- Fonction simple sans logs
CREATE OR REPLACE FUNCTION activate_user_simple(user_email TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    user_id_var UUID;
BEGIN
    -- Récupérer l'ID utilisateur
    SELECT id INTO user_id_var 
    FROM users 
    WHERE email = user_email;
    
    IF user_id_var IS NULL THEN
        RAISE EXCEPTION 'Utilisateur non trouvé: %', user_email;
    END IF;
    
    -- Activer le compte
    UPDATE users
    SET
        account_status = 'active',
        subscription_type = 'premium',
        subscription_start_date = NOW(),
        subscription_end_date = NOW() + INTERVAL '365 days',
        updated_at = NOW()
    WHERE id = user_id_var;

    -- Autoriser tous les appareils
    UPDATE user_devices
    SET
        is_authorized = true,
        updated_at = NOW()
    WHERE user_id = user_id_var;
    
    RETURN TRUE;
END;
$$;

-- Accorder les permissions
GRANT EXECUTE ON FUNCTION activate_user_simple(TEXT) TO authenticated, anon;

-- ========================================
-- 5. MESSAGE DE CONFIRMATION
-- ========================================

SELECT 
    'ACTIVATION TERMINÉE' as status,
    'Votre compte est maintenant activé' as message,
    NOW() as timestamp;

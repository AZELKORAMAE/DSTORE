-- Script pour corriger l'accès au compte et autoriser l'appareil
-- À exécuter dans l'interface Supabase : Projet > SQL Editor > Nouveau script

-- ========================================
-- 1. ACTIVER LE COMPTE UTILISATEUR
-- ========================================

-- Mettre à jour le statut du compte pour l'activer
UPDATE users 
SET 
    account_status = 'active',
    subscription_type = 'premium',
    subscription_start_date = NOW(),
    subscription_end_date = NOW() + INTERVAL '365 days',
    last_login_date = NOW(),
    updated_at = NOW()
WHERE email = 'azelkoramae@gmail.com';

-- ========================================
-- 2. AUTORISER TOUS LES APPAREILS POUR CET UTILISATEUR
-- ========================================

-- Autoriser tous les appareils existants pour cet utilisateur
UPDATE user_devices 
SET 
    is_authorized = true,
    updated_at = NOW()
WHERE user_id = (
    SELECT id FROM users WHERE email = 'azelkoramae@gmail.com'
);

-- ========================================
-- 3. VÉRIFICATIONS
-- ========================================

-- Vérifier le statut du compte
SELECT 
    email,
    account_status,
    subscription_type,
    subscription_start_date,
    subscription_end_date,
    created_at,
    updated_at
FROM users 
WHERE email = 'azelkoramae@gmail.com';

-- Vérifier les appareils autorisés
SELECT 
    ud.device_id,
    ud.device_name,
    ud.is_authorized,
    ud.created_at,
    ud.updated_at
FROM user_devices ud
JOIN users u ON ud.user_id = u.id
WHERE u.email = 'azelkoramae@gmail.com';

-- ========================================
-- 4. FONCTION POUR AUTORISER AUTOMATIQUEMENT LES NOUVEAUX APPAREILS
-- ========================================

-- Créer une fonction pour auto-autoriser les appareils de cet utilisateur
CREATE OR REPLACE FUNCTION auto_authorize_device_for_user()
RETURNS TRIGGER AS $$
BEGIN
    -- Si c'est un appareil pour l'utilisateur azelkoramae@gmail.com, l'autoriser automatiquement
    IF NEW.user_id = (SELECT id FROM users WHERE email = 'azelkoramae@gmail.com') THEN
        NEW.is_authorized = true;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Créer le trigger pour auto-autoriser
DROP TRIGGER IF EXISTS auto_authorize_device_trigger ON user_devices;
CREATE TRIGGER auto_authorize_device_trigger
    BEFORE INSERT ON user_devices
    FOR EACH ROW
    EXECUTE FUNCTION auto_authorize_device_for_user();

-- ========================================
-- 5. MESSAGE DE CONFIRMATION
-- ========================================

SELECT 
    'Compte activé et appareils autorisés avec succès!' as status,
    'Vous pouvez maintenant vous connecter' as message;

-- Script de vérification rapide du statut de compte
-- À exécuter dans l'interface Supabase : Projet > SQL Editor > Nouveau script

-- ========================================
-- 1. VÉRIFIER LE STATUT ACTUEL
-- ========================================

-- Vérifier les informations de l'utilisateur
SELECT 
    'STATUT UTILISATEUR' as section,
    email,
    business_name,
    account_status,
    subscription_type,
    subscription_start_date,
    subscription_end_date,
    subscription_end_date > NOW() as subscription_valid,
    password IS NOT NULL as has_password,
    created_at,
    updated_at
FROM users 
WHERE email = 'azelkoramae@gmail.com';

-- Vérifier les appareils
SELECT 
    'APPAREILS' as section,
    device_id,
    device_name,
    is_authorized,
    created_at,
    updated_at
FROM user_devices ud
JOIN users u ON ud.user_id = u.id
WHERE u.email = 'azelkoramae@gmail.com'
ORDER BY created_at DESC;

-- ========================================
-- 2. ACTIVER IMMÉDIATEMENT SI NÉCESSAIRE
-- ========================================

-- Activer le compte s'il n'est pas actif
UPDATE users 
SET 
    account_status = 'active',
    subscription_type = 'premium',
    subscription_start_date = NOW(),
    subscription_end_date = NOW() + INTERVAL '365 days',
    updated_at = NOW()
WHERE email = 'azelkoramae@gmail.com' 
AND account_status != 'active';

-- Autoriser tous les appareils
UPDATE user_devices 
SET 
    is_authorized = true,
    updated_at = NOW()
WHERE user_id = (
    SELECT id FROM users WHERE email = 'azelkoramae@gmail.com'
)
AND is_authorized != true;

-- ========================================
-- 3. VÉRIFICATION FINALE
-- ========================================

-- Vérifier que tout est maintenant correct
SELECT 
    'VÉRIFICATION FINALE' as section,
    email,
    account_status,
    subscription_type,
    subscription_end_date > NOW() as subscription_valid,
    password IS NOT NULL as has_password
FROM users 
WHERE email = 'azelkoramae@gmail.com';

-- Compter les appareils autorisés
SELECT 
    'APPAREILS AUTORISÉS' as section,
    COUNT(*) as total_devices,
    COUNT(CASE WHEN is_authorized = true THEN 1 END) as authorized_devices
FROM user_devices ud
JOIN users u ON ud.user_id = u.id
WHERE u.email = 'azelkoramae@gmail.com';

-- Message de confirmation
SELECT 
    'RÉSULTAT' as status,
    'Compte vérifié et activé si nécessaire' as message,
    NOW() as timestamp;

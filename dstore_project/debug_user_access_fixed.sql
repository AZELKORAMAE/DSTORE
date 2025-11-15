-- Script pour déboguer et corriger les problèmes d'accès utilisateur (VERSION CORRIGÉE)
-- À exécuter dans l'interface Supabase : Projet > SQL Editor > Nouveau script

-- ========================================
-- 1. VÉRIFIER LE STATUT ACTUEL DE L'UTILISATEUR
-- ========================================

-- Vérifier les informations de l'utilisateur
SELECT 
    'INFORMATIONS UTILISATEUR' as section,
    id,
    email,
    business_name,
    account_status,
    subscription_type,
    subscription_start_date,
    subscription_end_date,
    password IS NOT NULL as has_password,
    created_at,
    updated_at
FROM users 
WHERE email = 'azelkoramae@gmail.com';

-- ========================================
-- 2. VÉRIFIER LES APPAREILS AUTORISÉS
-- ========================================

-- Vérifier les appareils de l'utilisateur
SELECT 
    'APPAREILS UTILISATEUR' as section,
    ud.device_id,
    ud.device_name,
    ud.is_authorized,
    ud.created_at,
    ud.updated_at
FROM user_devices ud
JOIN users u ON ud.user_id = u.id
WHERE u.email = 'azelkoramae@gmail.com'
ORDER BY ud.created_at DESC;

-- ========================================
-- 3. CORRIGER AUTOMATIQUEMENT LES PROBLÈMES
-- ========================================

-- Activer le compte s'il ne l'est pas
UPDATE users 
SET 
    account_status = 'active',
    subscription_type = 'premium',
    subscription_start_date = NOW(),
    subscription_end_date = NOW() + INTERVAL '365 days',
    updated_at = NOW()
WHERE email = 'azelkoramae@gmail.com' 
AND account_status != 'active';

-- Autoriser tous les appareils de cet utilisateur
UPDATE user_devices 
SET 
    is_authorized = true,
    updated_at = NOW()
WHERE user_id = (
    SELECT id FROM users WHERE email = 'azelkoramae@gmail.com'
)
AND is_authorized != true;

-- ========================================
-- 4. CRÉER UNE TABLE DE LOGS SIMPLE
-- ========================================

-- Créer la table admin_logs avec une structure simple
CREATE TABLE IF NOT EXISTS admin_logs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    action TEXT NOT NULL,
    user_email TEXT,
    details TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ========================================
-- 5. FONCTION POUR ACTIVER UN UTILISATEUR COMPLÈTEMENT (VERSION SIMPLE)
-- ========================================

-- Fonction pour activer complètement un utilisateur (compte + appareils)
CREATE OR REPLACE FUNCTION activate_user_completely(
    user_email TEXT,
    subscription_days INTEGER DEFAULT 365
) RETURNS BOOLEAN
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
        subscription_end_date = NOW() + (subscription_days || ' days')::INTERVAL,
        updated_at = NOW()
    WHERE id = user_id_var;
    
    -- Autoriser tous les appareils
    UPDATE user_devices 
    SET 
        is_authorized = true,
        updated_at = NOW()
    WHERE user_id = user_id_var;
    
    -- Log de l'action (version simple)
    INSERT INTO admin_logs (action, user_email, details, created_at)
    VALUES (
        'ACTIVATE_USER_COMPLETELY',
        user_email,
        'Utilisateur activé pour ' || subscription_days || ' jours',
        NOW()
    );
    
    RETURN TRUE;
END;
$$;

-- ========================================
-- 6. ACTIVER COMPLÈTEMENT VOTRE COMPTE
-- ========================================

-- Activer complètement votre compte
SELECT activate_user_completely('azelkoramae@gmail.com', 365) as activation_result;

-- ========================================
-- 7. VÉRIFICATIONS FINALES
-- ========================================

-- Vérifier que tout est correct maintenant
SELECT 
    'VÉRIFICATION FINALE - UTILISATEUR' as section,
    email,
    account_status,
    subscription_type,
    subscription_end_date > NOW() as subscription_valid,
    password IS NOT NULL as has_password
FROM users 
WHERE email = 'azelkoramae@gmail.com';

-- Vérifier les appareils
SELECT 
    'VÉRIFICATION FINALE - APPAREILS' as section,
    COUNT(*) as total_devices,
    COUNT(CASE WHEN is_authorized = true THEN 1 END) as authorized_devices
FROM user_devices ud
JOIN users u ON ud.user_id = u.id
WHERE u.email = 'azelkoramae@gmail.com';

-- Vérifier les logs
SELECT 
    'LOGS RÉCENTS' as section,
    action,
    user_email,
    details,
    created_at
FROM admin_logs
WHERE user_email = 'azelkoramae@gmail.com'
ORDER BY created_at DESC
LIMIT 5;

-- Message de confirmation
SELECT 
    'ACTIVATION TERMINÉE' as status,
    'Votre compte est maintenant complètement activé' as message;

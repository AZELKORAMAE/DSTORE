-- Script pour améliorer le système d'activation admin (VERSION SIMPLE)
-- À exécuter dans l'interface Supabase : Projet > SQL Editor > Nouveau script

-- ========================================
-- 1. FONCTION POUR ACTIVER UN UTILISATEUR (VERSION AMÉLIORÉE)
-- ========================================

-- Fonction spécialisée pour l'activation par admin
CREATE OR REPLACE FUNCTION admin_activate_user(
    user_email TEXT,
    subscription_type_param TEXT DEFAULT 'premium',
    subscription_days_param INTEGER DEFAULT 365
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    user_id_var UUID;
    user_business_name TEXT;
BEGIN
    -- Récupérer les informations utilisateur
    SELECT id, business_name INTO user_id_var, user_business_name
    FROM users 
    WHERE email = user_email;
    
    IF user_id_var IS NULL THEN
        RAISE EXCEPTION 'Utilisateur non trouvé: %', user_email;
    END IF;
    
    -- Activer le compte avec tous les détails
    UPDATE users 
    SET 
        account_status = 'active',
        subscription_type = subscription_type_param,
        subscription_start_date = NOW(),
        subscription_end_date = NOW() + (subscription_days_param || ' days')::INTERVAL,
        updated_at = NOW()
    WHERE id = user_id_var;
    
    -- Autoriser TOUS les appareils de cet utilisateur
    UPDATE user_devices 
    SET 
        is_authorized = true,
        updated_at = NOW()
    WHERE user_id = user_id_var;
    
    -- Log de l'action
    INSERT INTO admin_logs (action, user_email, details, created_at)
    VALUES (
        'ADMIN_ACTIVATE_USER',
        user_email,
        'Utilisateur ' || COALESCE(user_business_name, 'Sans nom') || ' activé - Type: ' || subscription_type_param || ', Durée: ' || subscription_days_param || ' jours',
        NOW()
    );
    
    RETURN TRUE;
END;
$$;

-- ========================================
-- 2. FONCTION POUR SUSPENDRE UN UTILISATEUR
-- ========================================

CREATE OR REPLACE FUNCTION admin_suspend_user(user_email TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    user_id_var UUID;
    user_business_name TEXT;
BEGIN
    -- Récupérer les informations utilisateur
    SELECT id, business_name INTO user_id_var, user_business_name
    FROM users 
    WHERE email = user_email;
    
    IF user_id_var IS NULL THEN
        RAISE EXCEPTION 'Utilisateur non trouvé: %', user_email;
    END IF;
    
    -- Suspendre le compte
    UPDATE users 
    SET 
        account_status = 'suspended',
        updated_at = NOW()
    WHERE id = user_id_var;
    
    -- Désautoriser tous les appareils
    UPDATE user_devices 
    SET 
        is_authorized = false,
        updated_at = NOW()
    WHERE user_id = user_id_var;
    
    -- Log de l'action
    INSERT INTO admin_logs (action, user_email, details, created_at)
    VALUES (
        'ADMIN_SUSPEND_USER',
        user_email,
        'Utilisateur ' || COALESCE(user_business_name, 'Sans nom') || ' suspendu',
        NOW()
    );
    
    RETURN TRUE;
END;
$$;

-- ========================================
-- 3. FONCTION POUR VÉRIFIER L'ACCÈS D'UN UTILISATEUR
-- ========================================

CREATE OR REPLACE FUNCTION check_user_access_simple(user_email TEXT)
RETURNS TABLE (
    can_access BOOLEAN,
    account_status TEXT,
    subscription_valid BOOLEAN,
    devices_authorized INTEGER,
    subscription_end_date TIMESTAMP WITH TIME ZONE
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY 
    SELECT 
        (u.account_status = 'active' AND 
         (u.subscription_end_date IS NULL OR u.subscription_end_date > NOW())) as can_access,
        u.account_status,
        (u.subscription_end_date IS NULL OR u.subscription_end_date > NOW()) as subscription_valid,
        COALESCE(COUNT(ud.id) FILTER (WHERE ud.is_authorized = true), 0)::INTEGER as devices_authorized,
        u.subscription_end_date
    FROM users u
    LEFT JOIN user_devices ud ON u.id = ud.user_id
    WHERE u.email = user_email
    GROUP BY u.account_status, u.subscription_end_date;
END;
$$;

-- ========================================
-- 4. ACCORDER LES PERMISSIONS
-- ========================================

-- Accorder les permissions sur les nouvelles fonctions
GRANT EXECUTE ON FUNCTION admin_activate_user(TEXT, TEXT, INTEGER) TO authenticated, anon;
GRANT EXECUTE ON FUNCTION admin_suspend_user(TEXT) TO authenticated, anon;
GRANT EXECUTE ON FUNCTION check_user_access_simple(TEXT) TO authenticated, anon;

-- ========================================
-- 5. TESTER LES NOUVELLES FONCTIONS
-- ========================================

-- Vérifier l'accès actuel
SELECT 
    'VÉRIFICATION ACCÈS AVANT' as test,
    * 
FROM check_user_access_simple('azelkoramae@gmail.com');

-- Activer complètement l'utilisateur avec la nouvelle fonction
SELECT 
    'ACTIVATION ADMIN' as test,
    admin_activate_user('azelkoramae@gmail.com', 'premium', 365) as activation_success;

-- Vérifier à nouveau l'accès
SELECT 
    'VÉRIFICATION ACCÈS APRÈS' as test,
    * 
FROM check_user_access_simple('azelkoramae@gmail.com');

-- Afficher les logs récents
SELECT 
    'LOGS RÉCENTS' as test,
    action,
    user_email,
    details,
    created_at
FROM admin_logs
WHERE user_email = 'azelkoramae@gmail.com'
ORDER BY created_at DESC
LIMIT 3;

-- Message de confirmation
SELECT 
    'SYSTÈME ADMIN AMÉLIORÉ' as status,
    'Les fonctions d''activation sont maintenant opérationnelles' as message;

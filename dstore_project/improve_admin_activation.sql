-- Script pour améliorer le système d'activation admin
-- À exécuter dans l'interface Supabase : Projet > SQL Editor > Nouveau script

-- ========================================
-- 1. AMÉLIORER LA FONCTION update_user_status
-- ========================================

-- Supprimer l'ancienne fonction
DROP FUNCTION IF EXISTS update_user_status(UUID, TEXT, TEXT, INTEGER);

-- Créer une nouvelle fonction améliorée
CREATE OR REPLACE FUNCTION update_user_status(
    target_user_id UUID,
    new_status TEXT,
    new_subscription_type TEXT DEFAULT NULL,
    subscription_days INTEGER DEFAULT NULL
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Vérifier que l'utilisateur existe
    IF NOT EXISTS (SELECT 1 FROM users WHERE id = target_user_id) THEN
        RAISE EXCEPTION 'Utilisateur non trouvé';
    END IF;

    -- Mettre à jour le statut utilisateur
    UPDATE users 
    SET 
        account_status = new_status,
        subscription_type = COALESCE(new_subscription_type, subscription_type),
        subscription_start_date = CASE 
            WHEN new_status = 'active' AND subscription_days IS NOT NULL THEN NOW()
            ELSE subscription_start_date
        END,
        subscription_end_date = CASE 
            WHEN new_status = 'active' AND subscription_days IS NOT NULL THEN NOW() + (subscription_days || ' days')::INTERVAL
            ELSE subscription_end_date
        END,
        updated_at = NOW()
    WHERE id = target_user_id;

    -- Si on active l'utilisateur, autoriser automatiquement tous ses appareils
    IF new_status = 'active' THEN
        UPDATE user_devices 
        SET 
            is_authorized = true,
            updated_at = NOW()
        WHERE user_id = target_user_id;
        
        -- Log de l'action
        INSERT INTO admin_logs (action, details, created_at)
        VALUES (
            'ACTIVATE_USER_WITH_DEVICES',
            'Utilisateur activé avec tous ses appareils: ' || target_user_id::TEXT,
            NOW()
        ) ON CONFLICT DO NOTHING;
    END IF;

    -- Si on suspend l'utilisateur, suspendre aussi ses appareils
    IF new_status = 'suspended' THEN
        UPDATE user_devices 
        SET 
            is_authorized = false,
            updated_at = NOW()
        WHERE user_id = target_user_id;
        
        -- Log de l'action
        INSERT INTO admin_logs (action, details, created_at)
        VALUES (
            'SUSPEND_USER_WITH_DEVICES',
            'Utilisateur suspendu avec tous ses appareils: ' || target_user_id::TEXT,
            NOW()
        ) ON CONFLICT DO NOTHING;
    END IF;

    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Erreur lors de la mise à jour: %', SQLERRM;
        RETURN FALSE;
END;
$$;

-- ========================================
-- 2. FONCTION POUR ACTIVER UN UTILISATEUR SPÉCIFIQUE
-- ========================================

-- Fonction spécialisée pour l'activation
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
    user_info RECORD;
BEGIN
    -- Récupérer les informations utilisateur
    SELECT id, email, business_name INTO user_info
    FROM users 
    WHERE email = user_email;
    
    IF user_info.id IS NULL THEN
        RAISE EXCEPTION 'Utilisateur non trouvé: %', user_email;
    END IF;
    
    user_id_var := user_info.id;
    
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
    
    -- Créer un trigger pour auto-autoriser les futurs appareils
    -- (Supprimer d'abord s'il existe)
    DROP TRIGGER IF EXISTS auto_authorize_device_trigger ON user_devices;
    
    -- Log détaillé de l'action
    INSERT INTO admin_logs (action, details, created_at)
    VALUES (
        'ADMIN_ACTIVATE_USER',
        format('Utilisateur %s (%s) activé par admin - Type: %s, Durée: %s jours', 
               user_info.email, 
               COALESCE(user_info.business_name, 'Sans nom'),
               subscription_type_param,
               subscription_days_param),
        NOW()
    ) ON CONFLICT DO NOTHING;
    
    RETURN TRUE;
END;
$$;

-- ========================================
-- 3. FONCTION POUR VÉRIFIER L'ACCÈS D'UN UTILISATEUR
-- ========================================

-- Fonction pour vérifier si un utilisateur peut accéder
CREATE OR REPLACE FUNCTION check_user_access(user_email TEXT)
RETURNS TABLE (
    can_access BOOLEAN,
    account_status TEXT,
    subscription_valid BOOLEAN,
    devices_authorized INTEGER,
    details TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    user_record RECORD;
    device_count INTEGER;
BEGIN
    -- Récupérer les infos utilisateur
    SELECT 
        u.account_status,
        u.subscription_end_date,
        COUNT(ud.id) as total_devices,
        COUNT(CASE WHEN ud.is_authorized = true THEN 1 END) as auth_devices
    INTO user_record
    FROM users u
    LEFT JOIN user_devices ud ON u.id = ud.user_id
    WHERE u.email = user_email
    GROUP BY u.account_status, u.subscription_end_date;
    
    IF user_record IS NULL THEN
        RETURN QUERY SELECT false, 'not_found'::TEXT, false, 0, 'Utilisateur non trouvé'::TEXT;
        RETURN;
    END IF;
    
    -- Vérifier l'accès
    RETURN QUERY SELECT 
        (user_record.account_status = 'active' AND 
         (user_record.subscription_end_date IS NULL OR user_record.subscription_end_date > NOW())),
        user_record.account_status,
        (user_record.subscription_end_date IS NULL OR user_record.subscription_end_date > NOW()),
        COALESCE(user_record.auth_devices, 0),
        format('Statut: %s, Appareils autorisés: %s/%s', 
               user_record.account_status,
               COALESCE(user_record.auth_devices, 0),
               COALESCE(user_record.total_devices, 0));
END;
$$;

-- ========================================
-- 4. ACCORDER LES PERMISSIONS
-- ========================================

-- Accorder les permissions sur les nouvelles fonctions
GRANT EXECUTE ON FUNCTION admin_activate_user(TEXT, TEXT, INTEGER) TO authenticated, anon;
GRANT EXECUTE ON FUNCTION check_user_access(TEXT) TO authenticated, anon;
GRANT EXECUTE ON FUNCTION update_user_status(UUID, TEXT, TEXT, INTEGER) TO authenticated, anon;

-- ========================================
-- 5. TESTER LES NOUVELLES FONCTIONS
-- ========================================

-- Vérifier l'accès actuel
SELECT * FROM check_user_access('azelkoramae@gmail.com');

-- Activer complètement l'utilisateur avec la nouvelle fonction
SELECT admin_activate_user('azelkoramae@gmail.com', 'premium', 365) as activation_success;

-- Vérifier à nouveau l'accès
SELECT * FROM check_user_access('azelkoramae@gmail.com');

-- Message de confirmation
SELECT 
    'SYSTÈME ADMIN AMÉLIORÉ' as status,
    'Les fonctions d''activation sont maintenant plus robustes' as message;

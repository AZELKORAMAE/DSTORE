-- ==================== SCRIPT COMPLET POUR SUPABASE ====================
-- Exécutez ce script dans l'éditeur SQL de Supabase

-- ÉTAPE 1: Créer la table user_profiles si elle n'existe pas
CREATE TABLE IF NOT EXISTS public.user_profiles (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE NOT NULL,
    full_name TEXT,
    business_name TEXT,
    phone TEXT,
    address TEXT,
    account_status TEXT DEFAULT 'pending' CHECK (account_status IN ('pending', 'active', 'suspended', 'expired')),
    subscription_type TEXT DEFAULT 'basic' CHECK (subscription_type IN ('basic', 'premium', 'enterprise')),
    subscription_start_date DATE,
    subscription_end_date DATE,
    last_login_date TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ÉTAPE 2: Créer la table admin_logs si elle n'existe pas
CREATE TABLE IF NOT EXISTS public.admin_logs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    action TEXT NOT NULL,
    target_user_id UUID,
    performed_by UUID REFERENCES auth.users(id),
    performed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    details JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ÉTAPE 3: Créer la table admin_users pour gérer les administrateurs
CREATE TABLE IF NOT EXISTS public.admin_users (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    admin_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE NOT NULL,
    email TEXT NOT NULL,
    full_name TEXT,
    is_super_admin BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ÉTAPE 4: Supprimer toutes les fonctions existantes
DROP FUNCTION IF EXISTS delete_user_admin(UUID);
DROP FUNCTION IF EXISTS update_user_info_admin(UUID, TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS update_user_status(UUID, TEXT, TEXT, INTEGER);
DROP FUNCTION IF EXISTS get_all_users_for_admin();
DROP FUNCTION IF EXISTS verify_admin_password(TEXT, TEXT);

-- ÉTAPE 5: Fonction pour supprimer un utilisateur définitivement
CREATE FUNCTION delete_user_admin(target_user_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Vérifier que l'utilisateur existe
    IF NOT EXISTS (SELECT 1 FROM auth.users WHERE id = target_user_id) THEN
        RAISE EXCEPTION 'Utilisateur non trouvé';
    END IF;

    -- Supprimer d'abord les données liées dans user_profiles
    DELETE FROM public.user_profiles WHERE user_id = target_user_id;
    
    -- Supprimer l'utilisateur de auth.users (CASCADE supprimera automatiquement les sessions)
    DELETE FROM auth.users WHERE id = target_user_id;
    
    -- Log de l'action
    INSERT INTO public.admin_logs (action, target_user_id, performed_at)
    VALUES ('DELETE_USER', target_user_id, NOW());
    
    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Erreur lors de la suppression: %', SQLERRM;
        RETURN FALSE;
END;
$$;

-- ÉTAPE 6: Fonction pour modifier les informations d'un utilisateur
CREATE FUNCTION update_user_info_admin(
    target_user_id UUID,
    new_email TEXT DEFAULT NULL,
    new_full_name TEXT DEFAULT NULL,
    new_business_name TEXT DEFAULT NULL
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Vérifier que l'utilisateur existe
    IF NOT EXISTS (SELECT 1 FROM auth.users WHERE id = target_user_id) THEN
        RAISE EXCEPTION 'Utilisateur non trouvé';
    END IF;

    -- Mettre à jour l'email dans auth.users si fourni
    IF new_email IS NOT NULL THEN
        UPDATE auth.users 
        SET email = new_email, 
            updated_at = NOW()
        WHERE id = target_user_id;
    END IF;

    -- Mettre à jour les informations dans user_profiles si fournies
    IF new_full_name IS NOT NULL OR new_business_name IS NOT NULL THEN
        UPDATE public.user_profiles 
        SET 
            full_name = COALESCE(new_full_name, full_name),
            business_name = COALESCE(new_business_name, business_name),
            updated_at = NOW()
        WHERE user_id = target_user_id;
        
        -- Si aucune ligne n'a été mise à jour, créer le profil
        IF NOT FOUND THEN
            INSERT INTO public.user_profiles (
                user_id, 
                full_name, 
                business_name,
                created_at,
                updated_at
            ) VALUES (
                target_user_id, 
                new_full_name, 
                new_business_name,
                NOW(),
                NOW()
            );
        END IF;
    END IF;
    
    -- Log de l'action
    INSERT INTO public.admin_logs (action, target_user_id, performed_at, details)
    VALUES ('UPDATE_USER_INFO', target_user_id, NOW(), 
            jsonb_build_object(
                'email', new_email,
                'full_name', new_full_name,
                'business_name', new_business_name
            ));
    
    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Erreur lors de la modification: %', SQLERRM;
        RETURN FALSE;
END;
$$;

-- ÉTAPE 7: Fonction pour obtenir tous les utilisateurs
CREATE FUNCTION get_all_users_for_admin()
RETURNS TABLE (
    user_id UUID,
    email TEXT,
    full_name TEXT,
    business_name TEXT,
    account_status TEXT,
    subscription_type TEXT,
    subscription_end_date DATE,
    last_login_date TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.id as user_id,
        u.email,
        up.full_name,
        up.business_name,
        COALESCE(up.account_status, 'pending') as account_status,
        COALESCE(up.subscription_type, 'basic') as subscription_type,
        up.subscription_end_date,
        up.last_login_date,
        u.created_at
    FROM auth.users u
    LEFT JOIN public.user_profiles up ON u.id = up.user_id
    WHERE u.email IS NOT NULL
    ORDER BY u.created_at DESC;
END;
$$;

-- ÉTAPE 8: Fonction pour mettre à jour le statut d'un utilisateur
CREATE FUNCTION update_user_status(
    target_user_id UUID,
    new_status TEXT,
    new_subscription_type TEXT DEFAULT NULL,
    subscription_days INTEGER DEFAULT NULL
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    new_end_date DATE;
BEGIN
    -- Vérifier que l'utilisateur existe
    IF NOT EXISTS (SELECT 1 FROM auth.users WHERE id = target_user_id) THEN
        RAISE EXCEPTION 'Utilisateur non trouvé';
    END IF;

    -- Calculer la nouvelle date de fin d'abonnement si des jours sont fournis
    IF subscription_days IS NOT NULL THEN
        new_end_date := CURRENT_DATE + INTERVAL '1 day' * subscription_days;
    END IF;

    -- Mettre à jour le profil utilisateur
    UPDATE public.user_profiles 
    SET 
        account_status = new_status,
        subscription_type = COALESCE(new_subscription_type, subscription_type),
        subscription_end_date = COALESCE(new_end_date, subscription_end_date),
        updated_at = NOW()
    WHERE user_id = target_user_id;

    -- Si aucune ligne n'a été mise à jour, créer le profil
    IF NOT FOUND THEN
        INSERT INTO public.user_profiles (
            user_id, 
            account_status, 
            subscription_type, 
            subscription_end_date,
            created_at,
            updated_at
        ) VALUES (
            target_user_id, 
            new_status, 
            COALESCE(new_subscription_type, 'basic'), 
            new_end_date,
            NOW(),
            NOW()
        );
    END IF;
    
    -- Log de l'action
    INSERT INTO public.admin_logs (action, target_user_id, performed_at, details)
    VALUES ('UPDATE_STATUS', target_user_id, NOW(), 
            jsonb_build_object(
                'new_status', new_status,
                'subscription_type', new_subscription_type,
                'subscription_days', subscription_days
            ));
    
    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Erreur lors de la mise à jour du statut: %', SQLERRM;
        RETURN FALSE;
END;
$$;

-- ÉTAPE 9: Fonction pour vérifier le mot de passe admin
CREATE FUNCTION verify_admin_password(input_email TEXT, input_password TEXT)
RETURNS TABLE (
    admin_id UUID,
    email TEXT,
    full_name TEXT,
    is_super_admin BOOLEAN
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Pour la démo, utiliser un admin par défaut
    -- En production, vous devriez avoir une vraie vérification de mot de passe
    IF input_email = 'admin@mata24.com' AND input_password = 'admin123' THEN
        RETURN QUERY
        SELECT
            gen_random_uuid() as admin_id,
            input_email as email,
            'Administrateur Principal'::TEXT as full_name,
            TRUE as is_super_admin;
    END IF;

    RETURN;
END;
$$;

-- ÉTAPE 10: Créer ou recréer la vue admin_stats
DROP VIEW IF EXISTS admin_stats;
CREATE VIEW admin_stats AS
SELECT
    COUNT(*) as total_users,
    COUNT(CASE WHEN COALESCE(up.account_status, 'pending') = 'active' THEN 1 END) as active_users,
    COUNT(CASE WHEN COALESCE(up.account_status, 'pending') = 'pending' THEN 1 END) as pending_users,
    COUNT(CASE WHEN COALESCE(up.account_status, 'pending') = 'suspended' THEN 1 END) as suspended_users,
    COUNT(CASE WHEN COALESCE(up.account_status, 'pending') = 'expired' THEN 1 END) as expired_users
FROM auth.users u
LEFT JOIN public.user_profiles up ON u.id = up.user_id
WHERE u.email IS NOT NULL;

-- ==================== CORRECTION DU SYSTÈME D'ABONNEMENT V2 ====================
-- Ce script corrige le problème d'accès après activation d'un compte

-- ÉTAPE 1: Supprimer toutes les fonctions existantes pour éviter les conflits
DROP FUNCTION IF EXISTS update_last_login(UUID);
DROP FUNCTION IF EXISTS update_last_login(TEXT);
DROP FUNCTION IF EXISTS get_all_users_for_admin();
DROP FUNCTION IF EXISTS update_user_status(UUID, TEXT, TEXT, INTEGER);
DROP FUNCTION IF EXISTS update_user_info_admin(UUID, TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS delete_user_admin(UUID);

-- ÉTAPE 2: Créer la table users si elle n'existe pas (selon la configuration)
CREATE TABLE IF NOT EXISTS public.users (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT,
  business_name TEXT,
  phone TEXT,
  address TEXT,
  account_status TEXT DEFAULT 'pending' CHECK (account_status IN ('pending', 'active', 'suspended', 'expired')),
  subscription_type TEXT DEFAULT 'basic' CHECK (subscription_type IN ('basic', 'premium', 'enterprise')),
  subscription_start_date TIMESTAMP WITH TIME ZONE,
  subscription_end_date TIMESTAMP WITH TIME ZONE,
  last_payment_date TIMESTAMP WITH TIME ZONE,
  last_login_date TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ÉTAPE 3: Migrer les données de user_profiles vers users si elles existent
INSERT INTO public.users (
    id, 
    email, 
    full_name, 
    business_name, 
    phone, 
    address, 
    account_status, 
    subscription_type, 
    subscription_start_date,
    subscription_end_date,
    last_login_date,
    created_at, 
    updated_at
)
SELECT 
    up.user_id,
    au.email,
    up.full_name,
    up.business_name,
    up.phone,
    up.address,
    COALESCE(up.account_status, 'pending'),
    COALESCE(up.subscription_type, 'basic'),
    up.subscription_start_date,
    up.subscription_end_date,
    up.last_login_date,
    up.created_at,
    up.updated_at
FROM public.user_profiles up
JOIN auth.users au ON au.id = up.user_id
WHERE NOT EXISTS (
    SELECT 1 FROM public.users u WHERE u.id = up.user_id
)
ON CONFLICT (id) DO NOTHING;

-- ÉTAPE 4: Créer des profils pour tous les utilisateurs auth.users qui n'en ont pas
INSERT INTO public.users (
    id, 
    email, 
    account_status, 
    subscription_type, 
    created_at, 
    updated_at
)
SELECT 
    au.id,
    au.email,
    'pending',
    'basic',
    au.created_at,
    NOW()
FROM auth.users au
WHERE au.email IS NOT NULL 
AND NOT EXISTS (
    SELECT 1 FROM public.users u WHERE u.id = au.id
);

-- ÉTAPE 5: Fonction get_all_users_for_admin corrigée
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
        u.email::TEXT,
        COALESCE(u.full_name, '')::TEXT,
        COALESCE(u.business_name, '')::TEXT,
        COALESCE(u.account_status, 'pending')::TEXT,
        COALESCE(u.subscription_type, 'basic')::TEXT,
        u.subscription_end_date::DATE,
        u.last_login_date,
        u.created_at
    FROM public.users u
    WHERE u.email IS NOT NULL
    ORDER BY u.created_at DESC;
END;
$$;

-- ÉTAPE 6: Fonction update_user_status corrigée (pour l'activation)
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
    new_end_date TIMESTAMP WITH TIME ZONE;
    rows_affected INTEGER;
BEGIN
    -- Vérifier que l'utilisateur existe dans auth.users
    IF NOT EXISTS (SELECT 1 FROM auth.users WHERE id = target_user_id) THEN
        RAISE EXCEPTION 'Utilisateur non trouvé dans auth.users';
    END IF;

    -- Calculer la nouvelle date de fin d'abonnement si des jours sont fournis
    IF subscription_days IS NOT NULL THEN
        new_end_date := NOW() + INTERVAL '1 day' * subscription_days;
    END IF;

    -- Mettre à jour ou insérer dans public.users
    UPDATE public.users 
    SET 
        account_status = new_status,
        subscription_type = COALESCE(new_subscription_type, subscription_type, 'basic'),
        subscription_end_date = COALESCE(new_end_date, subscription_end_date),
        subscription_start_date = CASE 
            WHEN new_status = 'active' AND subscription_start_date IS NULL 
            THEN NOW() 
            ELSE subscription_start_date 
        END,
        last_payment_date = CASE 
            WHEN new_status = 'active' 
            THEN NOW() 
            ELSE last_payment_date 
        END,
        updated_at = NOW()
    WHERE id = target_user_id;

    GET DIAGNOSTICS rows_affected = ROW_COUNT;

    -- Si aucune ligne n'a été mise à jour, créer le profil
    IF rows_affected = 0 THEN
        INSERT INTO public.users (
            id, 
            email,
            account_status, 
            subscription_type, 
            subscription_start_date,
            subscription_end_date,
            last_payment_date,
            created_at,
            updated_at
        ) 
        SELECT 
            target_user_id,
            au.email,
            new_status, 
            COALESCE(new_subscription_type, 'basic'), 
            CASE WHEN new_status = 'active' THEN NOW() ELSE NULL END,
            new_end_date,
            CASE WHEN new_status = 'active' THEN NOW() ELSE NULL END,
            NOW(),
            NOW()
        FROM auth.users au 
        WHERE au.id = target_user_id;
    END IF;
    
    -- Log de l'action
    INSERT INTO public.admin_logs (action, target_user_id, performed_at, details)
    VALUES ('UPDATE_STATUS', target_user_id, NOW(), 
            jsonb_build_object(
                'new_status', new_status,
                'subscription_type', new_subscription_type,
                'subscription_days', subscription_days,
                'new_end_date', new_end_date
            ));
    
    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Erreur lors de la mise à jour du statut: %', SQLERRM;
        RETURN FALSE;
END;
$$;

-- ÉTAPE 7: Fonction update_user_info_admin
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
DECLARE
    rows_affected INTEGER;
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

    -- Mettre à jour les informations dans users si fournies
    IF new_full_name IS NOT NULL OR new_business_name IS NOT NULL THEN
        UPDATE public.users 
        SET 
            full_name = COALESCE(new_full_name, full_name),
            business_name = COALESCE(new_business_name, business_name),
            updated_at = NOW()
        WHERE id = target_user_id;
        
        GET DIAGNOSTICS rows_affected = ROW_COUNT;
        
        -- Si aucune ligne n'a été mise à jour, créer le profil
        IF rows_affected = 0 THEN
            INSERT INTO public.users (
                id, 
                email,
                full_name, 
                business_name,
                created_at,
                updated_at
            ) 
            SELECT 
                target_user_id,
                au.email,
                new_full_name, 
                new_business_name,
                NOW(),
                NOW()
            FROM auth.users au 
            WHERE au.id = target_user_id;
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

-- ÉTAPE 8: Fonction delete_user_admin
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

    -- Supprimer d'abord les données liées dans users
    DELETE FROM public.users WHERE id = target_user_id;
    
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

-- ÉTAPE 9: Fonction update_last_login
CREATE FUNCTION update_last_login(user_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    rows_affected INTEGER;
BEGIN
    UPDATE public.users 
    SET 
        last_login_date = NOW(),
        updated_at = NOW()
    WHERE id = user_id;
    
    GET DIAGNOSTICS rows_affected = ROW_COUNT;
    
    -- Si l'utilisateur n'existe pas dans users, le créer
    IF rows_affected = 0 THEN
        INSERT INTO public.users (id, email, last_login_date, created_at, updated_at)
        SELECT 
            user_id,
            au.email,
            NOW(),
            NOW(),
            NOW()
        FROM auth.users au 
        WHERE au.id = user_id;
    END IF;
END;
$$;

-- ÉTAPE 10: Recréer la vue admin_stats
DROP VIEW IF EXISTS admin_stats;
CREATE VIEW admin_stats AS
SELECT 
    COUNT(*) as total_users,
    COUNT(CASE WHEN COALESCE(u.account_status, 'pending') = 'active' THEN 1 END) as active_users,
    COUNT(CASE WHEN COALESCE(u.account_status, 'pending') = 'pending' THEN 1 END) as pending_users,
    COUNT(CASE WHEN COALESCE(u.account_status, 'pending') = 'suspended' THEN 1 END) as suspended_users,
    COUNT(CASE WHEN COALESCE(u.account_status, 'pending') = 'expired' THEN 1 END) as expired_users
FROM auth.users au
LEFT JOIN public.users u ON au.id = u.id
WHERE au.email IS NOT NULL;

-- ÉTAPE 11: Activer RLS sur la table users
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- ÉTAPE 12: Créer les politiques RLS pour la table users
DROP POLICY IF EXISTS "Users can view own data" ON public.users;
CREATE POLICY "Users can view own data" ON public.users FOR ALL USING (auth.uid() = id);

-- ÉTAPE 13: Vérifier les données créées
SELECT 'Vérification des utilisateurs:' as message;
SELECT 
    u.id,
    u.email,
    u.account_status,
    u.subscription_type,
    u.subscription_end_date,
    u.created_at
FROM public.users u
ORDER BY u.created_at DESC
LIMIT 5;

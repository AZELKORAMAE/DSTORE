-- ==================== CORRECTION DE LA FONCTION get_all_users_for_admin ====================
-- Exécutez ce script pour corriger le problème de type de données

-- ÉTAPE 1: Supprimer la fonction existante
DROP FUNCTION IF EXISTS get_all_users_for_admin();

-- ÉTAPE 2: Recréer la fonction avec les bons types de données
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
        u.email::TEXT,  -- Conversion explicite en TEXT
        COALESCE(up.full_name, '')::TEXT,
        COALESCE(up.business_name, '')::TEXT,
        COALESCE(up.account_status, 'pending')::TEXT,
        COALESCE(up.subscription_type, 'basic')::TEXT,
        up.subscription_end_date,
        up.last_login_date,
        u.created_at
    FROM auth.users u
    LEFT JOIN public.user_profiles up ON u.id = up.user_id
    WHERE u.email IS NOT NULL
    ORDER BY u.created_at DESC;
END;
$$;

-- ÉTAPE 3: Tester la fonction
SELECT * FROM get_all_users_for_admin() LIMIT 5;

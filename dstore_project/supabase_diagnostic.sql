-- ==================== SCRIPT DE DIAGNOSTIC SUPABASE ====================
-- Exécutez ce script pour diagnostiquer les problèmes

-- 1. Vérifier les tables existantes
SELECT table_name, table_schema
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('user_profiles', 'admin_logs', 'admin_users')
ORDER BY table_name;

-- 2. Vérifier les fonctions existantes
SELECT routine_name, routine_type
FROM information_schema.routines 
WHERE routine_schema = 'public' 
AND routine_name IN (
    'delete_user_admin', 
    'update_user_info_admin', 
    'get_all_users_for_admin',
    'update_user_status',
    'verify_admin_password'
)
ORDER BY routine_name;

-- 3. Vérifier les vues existantes
SELECT table_name, table_type
FROM information_schema.views 
WHERE table_schema = 'public' 
AND table_name = 'admin_stats';

-- 4. Compter les utilisateurs dans auth.users
SELECT 
    COUNT(*) as total_auth_users,
    COUNT(CASE WHEN email IS NOT NULL THEN 1 END) as users_with_email
FROM auth.users;

-- 5. Compter les profils utilisateurs
SELECT COUNT(*) as total_user_profiles
FROM public.user_profiles;

-- 6. Vérifier les utilisateurs sans profil
SELECT 
    u.id,
    u.email,
    u.created_at,
    CASE WHEN up.user_id IS NULL THEN 'PAS DE PROFIL' ELSE 'PROFIL EXISTE' END as profil_status
FROM auth.users u
LEFT JOIN public.user_profiles up ON u.id = up.user_id
WHERE u.email IS NOT NULL
ORDER BY u.created_at DESC
LIMIT 10;

-- 7. Tester la fonction get_all_users_for_admin si elle existe
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.routines 
        WHERE routine_schema = 'public' 
        AND routine_name = 'get_all_users_for_admin'
    ) THEN
        RAISE NOTICE 'Fonction get_all_users_for_admin existe - Test en cours...';
        PERFORM * FROM get_all_users_for_admin() LIMIT 1;
        RAISE NOTICE 'Test de la fonction réussi';
    ELSE
        RAISE NOTICE 'Fonction get_all_users_for_admin n''existe pas';
    END IF;
END $$;

-- 8. Vérifier les erreurs potentielles dans les logs
SELECT 
    schemaname,
    tablename,
    attname,
    n_distinct,
    correlation
FROM pg_stats 
WHERE schemaname = 'public' 
AND tablename IN ('user_profiles', 'admin_logs')
LIMIT 10;

-- ==================== SCRIPT POUR CRÉER DES DONNÉES DE TEST ====================
-- Exécutez ce script dans l'éditeur SQL de Supabase après avoir exécuté le script principal

-- ÉTAPE 1: Vérifier si la table user_profiles existe
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name = 'user_profiles';

-- ÉTAPE 2: Vérifier les utilisateurs existants dans auth.users
SELECT id, email, created_at 
FROM auth.users 
WHERE email IS NOT NULL 
ORDER BY created_at DESC 
LIMIT 10;

-- ÉTAPE 3: Créer des profils pour les utilisateurs existants qui n'en ont pas
INSERT INTO public.user_profiles (
    user_id, 
    full_name, 
    business_name, 
    account_status, 
    subscription_type, 
    subscription_start_date,
    subscription_end_date,
    created_at, 
    updated_at
)
SELECT 
    u.id,
    'Utilisateur Test ' || SUBSTRING(u.email FROM 1 FOR 10),
    'Commerce Test ' || SUBSTRING(u.email FROM 1 FOR 5),
    'pending',
    'basic',
    CURRENT_DATE,
    CURRENT_DATE + INTERVAL '30 days',
    u.created_at,
    NOW()
FROM auth.users u
WHERE u.email IS NOT NULL 
AND NOT EXISTS (
    SELECT 1 FROM public.user_profiles up 
    WHERE up.user_id = u.id
);

-- ÉTAPE 4: Créer quelques utilisateurs de test supplémentaires (optionnel)
-- Décommentez les lignes suivantes si vous voulez créer des utilisateurs de test

/*
-- Insérer des utilisateurs de test dans auth.users
INSERT INTO auth.users (
    id,
    email,
    encrypted_password,
    email_confirmed_at,
    created_at,
    updated_at,
    confirmation_token,
    recovery_token
) VALUES 
(
    gen_random_uuid(),
    'test1@mata24.com',
    crypt('password123', gen_salt('bf')),
    NOW(),
    NOW(),
    NOW(),
    '',
    ''
),
(
    gen_random_uuid(),
    'test2@mata24.com',
    crypt('password123', gen_salt('bf')),
    NOW(),
    NOW(),
    NOW(),
    '',
    ''
),
(
    gen_random_uuid(),
    'test3@mata24.com',
    crypt('password123', gen_salt('bf')),
    NOW(),
    NOW(),
    NOW(),
    '',
    ''
) ON CONFLICT (email) DO NOTHING;

-- Créer les profils pour ces utilisateurs de test
INSERT INTO public.user_profiles (
    user_id, 
    full_name, 
    business_name, 
    account_status, 
    subscription_type, 
    subscription_start_date,
    subscription_end_date
)
SELECT 
    u.id,
    CASE 
        WHEN u.email = 'test1@mata24.com' THEN 'Jean Dupont'
        WHEN u.email = 'test2@mata24.com' THEN 'Marie Martin'
        WHEN u.email = 'test3@mata24.com' THEN 'Pierre Durand'
        ELSE 'Utilisateur Test'
    END,
    CASE 
        WHEN u.email = 'test1@mata24.com' THEN 'Épicerie Dupont'
        WHEN u.email = 'test2@mata24.com' THEN 'Boutique Martin'
        WHEN u.email = 'test3@mata24.com' THEN 'Commerce Durand'
        ELSE 'Commerce Test'
    END,
    CASE 
        WHEN u.email = 'test1@mata24.com' THEN 'active'
        WHEN u.email = 'test2@mata24.com' THEN 'pending'
        WHEN u.email = 'test3@mata24.com' THEN 'suspended'
        ELSE 'pending'
    END,
    'basic',
    CURRENT_DATE,
    CURRENT_DATE + INTERVAL '30 days'
FROM auth.users u
WHERE u.email IN ('test1@mata24.com', 'test2@mata24.com', 'test3@mata24.com')
AND NOT EXISTS (
    SELECT 1 FROM public.user_profiles up 
    WHERE up.user_id = u.id
);
*/

-- ÉTAPE 5: Vérifier les données créées
SELECT 
    u.id,
    u.email,
    up.full_name,
    up.business_name,
    up.account_status,
    up.subscription_type,
    up.created_at
FROM auth.users u
LEFT JOIN public.user_profiles up ON u.id = up.user_id
WHERE u.email IS NOT NULL
ORDER BY u.created_at DESC;

-- ÉTAPE 6: Tester la fonction get_all_users_for_admin
SELECT * FROM get_all_users_for_admin();

-- ÉTAPE 7: Vérifier les statistiques
SELECT * FROM admin_stats;

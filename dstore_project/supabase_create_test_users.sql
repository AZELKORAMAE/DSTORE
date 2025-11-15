-- ==================== CRÉATION D'UTILISATEURS DE TEST AVEC COMPTES ACTIVÉS ====================
-- Ce script crée des utilisateurs de test avec des comptes déjà activés pour 30 jours

-- ÉTAPE 1: Créer des profils pour tous les utilisateurs existants qui n'en ont pas
INSERT INTO public.users (
    id, 
    email, 
    full_name, 
    business_name, 
    account_status, 
    subscription_type, 
    subscription_start_date,
    subscription_end_date,
    last_payment_date,
    created_at, 
    updated_at
)
SELECT 
    au.id,
    au.email,
    'Utilisateur ' || SUBSTRING(au.email FROM 1 FOR 10),
    'Commerce ' || SUBSTRING(au.email FROM 1 FOR 5),
    'active',  -- Activer directement le compte
    'basic',
    CURRENT_DATE,
    CURRENT_DATE + INTERVAL '30 days',  -- 30 jours d'abonnement
    NOW(),
    au.created_at,
    NOW()
FROM auth.users au
WHERE au.email IS NOT NULL 
AND NOT EXISTS (
    SELECT 1 FROM public.users u 
    WHERE u.id = au.id
);

-- ÉTAPE 2: Activer tous les comptes existants qui sont en attente
UPDATE public.users 
SET 
    account_status = 'active',
    subscription_start_date = COALESCE(subscription_start_date, CURRENT_DATE),
    subscription_end_date = COALESCE(subscription_end_date, CURRENT_DATE + INTERVAL '30 days'),
    last_payment_date = COALESCE(last_payment_date, NOW()),
    updated_at = NOW()
WHERE account_status = 'pending' OR account_status IS NULL;

-- ÉTAPE 3: Vérifier les utilisateurs créés
SELECT 
    u.id,
    u.email,
    u.full_name,
    u.business_name,
    u.account_status,
    u.subscription_type,
    u.subscription_start_date,
    u.subscription_end_date,
    CASE 
        WHEN u.subscription_end_date > CURRENT_DATE THEN 'VALIDE'
        ELSE 'EXPIRÉ'
    END as status_abonnement,
    u.created_at
FROM public.users u
ORDER BY u.created_at DESC;

-- ÉTAPE 4: Afficher les statistiques
SELECT 
    COUNT(*) as total_utilisateurs,
    COUNT(CASE WHEN account_status = 'active' THEN 1 END) as comptes_actifs,
    COUNT(CASE WHEN account_status = 'pending' THEN 1 END) as comptes_en_attente,
    COUNT(CASE WHEN subscription_end_date > CURRENT_DATE THEN 1 END) as abonnements_valides,
    COUNT(CASE WHEN subscription_end_date <= CURRENT_DATE THEN 1 END) as abonnements_expires
FROM public.users;

-- ÉTAPE 5: Tester la fonction get_all_users_for_admin
SELECT 'Test de la fonction get_all_users_for_admin:' as message;
SELECT * FROM get_all_users_for_admin() LIMIT 5;

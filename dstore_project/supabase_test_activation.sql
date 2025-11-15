-- ==================== TEST D'ACTIVATION D'UTILISATEUR ====================
-- Ce script teste l'activation d'un utilisateur et vérifie que tout fonctionne

-- ÉTAPE 1: Voir tous les utilisateurs actuels
SELECT 'UTILISATEURS AVANT ACTIVATION:' as message;
SELECT 
    u.id,
    u.email,
    u.account_status,
    u.subscription_type,
    u.subscription_start_date,
    u.subscription_end_date,
    CASE 
        WHEN u.subscription_end_date IS NULL THEN 'PAS D''ABONNEMENT'
        WHEN u.subscription_end_date > NOW() THEN 'ABONNEMENT VALIDE'
        ELSE 'ABONNEMENT EXPIRÉ'
    END as status_abonnement
FROM public.users u
ORDER BY u.created_at DESC;

-- ÉTAPE 2: Activer le premier utilisateur trouvé avec 30 jours d'abonnement
DO $$
DECLARE
    test_user_id UUID;
    activation_result BOOLEAN;
BEGIN
    -- Prendre le premier utilisateur
    SELECT id INTO test_user_id 
    FROM public.users 
    WHERE account_status != 'active' OR account_status IS NULL
    LIMIT 1;
    
    IF test_user_id IS NOT NULL THEN
        -- Activer l'utilisateur avec 30 jours
        SELECT update_user_status(test_user_id, 'active', 'basic', 30) INTO activation_result;
        
        RAISE NOTICE 'Utilisateur % activé: %', test_user_id, activation_result;
    ELSE
        RAISE NOTICE 'Aucun utilisateur à activer trouvé';
    END IF;
END $$;

-- ÉTAPE 3: Voir les utilisateurs après activation
SELECT 'UTILISATEURS APRÈS ACTIVATION:' as message;
SELECT 
    u.id,
    u.email,
    u.account_status,
    u.subscription_type,
    u.subscription_start_date,
    u.subscription_end_date,
    CASE 
        WHEN u.subscription_end_date IS NULL THEN 'PAS D''ABONNEMENT'
        WHEN u.subscription_end_date > NOW() THEN 'ABONNEMENT VALIDE'
        ELSE 'ABONNEMENT EXPIRÉ'
    END as status_abonnement,
    u.last_payment_date,
    u.updated_at
FROM public.users u
ORDER BY u.updated_at DESC;

-- ÉTAPE 4: Tester la fonction get_all_users_for_admin
SELECT 'TEST DE LA FONCTION get_all_users_for_admin:' as message;
SELECT * FROM get_all_users_for_admin() LIMIT 3;

-- ÉTAPE 5: Vérifier les logs d'administration
SELECT 'LOGS D''ADMINISTRATION:' as message;
SELECT 
    action,
    target_user_id,
    performed_at,
    details
FROM public.admin_logs 
ORDER BY performed_at DESC 
LIMIT 5;

-- ÉTAPE 6: Statistiques finales
SELECT 'STATISTIQUES:' as message;
SELECT * FROM admin_stats;

-- ÉTAPE 7: Test d'activation manuelle d'un utilisateur spécifique (remplacez l'ID)
-- Décommentez et remplacez l'ID par un vrai ID d'utilisateur pour tester
/*
SELECT update_user_status(
    'REMPLACEZ-PAR-UN-VRAI-UUID'::UUID, 
    'active', 
    'basic', 
    30
) as activation_result;
*/

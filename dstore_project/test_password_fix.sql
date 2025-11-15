-- Script de test pour vérifier que le problème de mot de passe est résolu
-- À exécuter dans l'interface Supabase : Projet > SQL Editor > Nouveau script

-- ========================================
-- 1. VÉRIFIER LA STRUCTURE DE LA TABLE
-- ========================================

-- Vérifier que la colonne password existe dans la table users
SELECT 
    'STRUCTURE TABLE USERS' as section,
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'users' 
AND table_schema = 'public'
AND column_name IN ('id', 'email', 'password', 'account_status')
ORDER BY ordinal_position;

-- ========================================
-- 2. TESTER L'INSERTION D'UN UTILISATEUR AVEC MOT DE PASSE
-- ========================================

-- Simuler ce que fait maintenant le code Flutter corrigé
-- (Remplacez les valeurs par des données de test)

DO $$
DECLARE
    test_user_id UUID := gen_random_uuid();
    test_email TEXT := 'test_user_' || extract(epoch from now()) || '@example.com';
    test_password TEXT := 'TestPassword123!';
BEGIN
    -- Insérer un utilisateur de test avec mot de passe
    INSERT INTO users (
        id,
        email,
        full_name,
        business_name,
        phone,
        address,
        password,
        account_status,
        subscription_type
    ) VALUES (
        test_user_id,
        test_email,
        'Utilisateur Test',
        'Entreprise Test',
        '+33123456789',
        '123 Rue Test',
        test_password,
        'pending',
        'basic'
    );
    
    RAISE NOTICE 'Utilisateur de test créé avec ID: %', test_user_id;
    RAISE NOTICE 'Email: %', test_email;
    RAISE NOTICE 'Mot de passe: %', test_password;
    
    -- Vérifier que l'insertion a fonctionné
    IF EXISTS (
        SELECT 1 FROM users 
        WHERE id = test_user_id 
        AND password = test_password
    ) THEN
        RAISE NOTICE '✅ SUCCESS: Mot de passe correctement sauvegardé';
    ELSE
        RAISE NOTICE '❌ ERREUR: Mot de passe non sauvegardé';
    END IF;
    
END $$;

-- ========================================
-- 3. VÉRIFIER LES UTILISATEURS EXISTANTS
-- ========================================

-- Compter les utilisateurs avec et sans mot de passe
SELECT 
    'ÉTAT ACTUEL DES MOTS DE PASSE' as section,
    COUNT(*) as total_users,
    COUNT(CASE WHEN password IS NOT NULL AND password != '' THEN 1 END) as users_with_password,
    COUNT(CASE WHEN password IS NULL OR password = '' THEN 1 END) as users_without_password
FROM users;

-- Afficher les détails des utilisateurs récents
SELECT 
    'UTILISATEURS RÉCENTS' as section,
    email,
    full_name,
    business_name,
    account_status,
    CASE 
        WHEN password IS NOT NULL AND password != '' THEN 'OUI' 
        ELSE 'NON' 
    END as has_password,
    LENGTH(password) as password_length,
    created_at
FROM users 
ORDER BY created_at DESC 
LIMIT 5;

-- ========================================
-- 4. NETTOYER LES DONNÉES DE TEST
-- ========================================

-- Supprimer les utilisateurs de test créés par ce script
DELETE FROM users 
WHERE email LIKE 'test_user_%@example.com' 
AND created_at > NOW() - INTERVAL '1 hour';

-- Message de confirmation
SELECT '✅ Test terminé - Vérifiez les résultats ci-dessus' as status;

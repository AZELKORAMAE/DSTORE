-- Script pour tester la suspension d'un utilisateur
-- À exécuter dans l'interface Supabase : Projet > SQL Editor > Nouveau script

-- ========================================
-- 1. VÉRIFIER L'ÉTAT ACTUEL
-- ========================================

-- Vérifier l'état actuel de l'utilisateur
SELECT 
    'ÉTAT ACTUEL' as section,
    email,
    business_name,
    account_status,
    subscription_type,
    subscription_end_date,
    created_at,
    updated_at
FROM users 
WHERE email = 'azelkoramae@gmail.com';

-- ========================================
-- 2. SUSPENDRE L'UTILISATEUR
-- ========================================

-- Suspendre le compte
UPDATE users 
SET 
    account_status = 'suspended',
    updated_at = NOW()
WHERE email = 'azelkoramae@gmail.com';

-- Message de confirmation
SELECT 
    'SUSPENSION' as action,
    'Utilisateur suspendu avec succès' as message,
    NOW() as timestamp;

-- ========================================
-- 3. VÉRIFIER LA SUSPENSION
-- ========================================

-- Vérifier que la suspension a été appliquée
SELECT 
    'ÉTAT APRÈS SUSPENSION' as section,
    email,
    business_name,
    account_status,
    subscription_type,
    updated_at
FROM users 
WHERE email = 'azelkoramae@gmail.com';

-- ========================================
-- 4. SCRIPT POUR RÉACTIVER (À UTILISER APRÈS TEST)
-- ========================================

-- DÉCOMMENTEZ LES LIGNES SUIVANTES POUR RÉACTIVER LE COMPTE :

/*
-- Réactiver le compte
UPDATE users 
SET 
    account_status = 'active',
    updated_at = NOW()
WHERE email = 'azelkoramae@gmail.com';

-- Vérifier la réactivation
SELECT 
    'ÉTAT APRÈS RÉACTIVATION' as section,
    email,
    business_name,
    account_status,
    subscription_type,
    updated_at
FROM users 
WHERE email = 'azelkoramae@gmail.com';

SELECT 
    'RÉACTIVATION' as action,
    'Utilisateur réactivé avec succès' as message,
    NOW() as timestamp;
*/

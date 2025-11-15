-- Script pour ajouter des données de test pour les appareils
-- À exécuter dans l'éditeur SQL de Supabase

-- D'abord, récupérer les IDs des utilisateurs existants
-- Remplacez ces UUIDs par les vrais IDs de vos utilisateurs

-- Insérer des appareils de test
INSERT INTO user_devices (
    user_id,
    device_id,
    device_name,
    device_type,
    platform,
    app_version,
    os_version,
    is_authorized,
    is_current_device,
    first_login_at,
    last_login_at
) VALUES 
-- Utilisateur 1 avec 2 appareils (un autorisé, un en attente)
(
    (SELECT id FROM auth.users LIMIT 1),
    'device-001-samsung-s21',
    'Samsung Galaxy S21',
    'mobile',
    'android',
    '1.0.0',
    'Android 13',
    true,
    true,
    NOW() - INTERVAL '5 days',
    NOW() - INTERVAL '1 hour'
),
(
    (SELECT id FROM auth.users LIMIT 1),
    'device-002-iphone-14',
    'iPhone 14 Pro',
    'mobile',
    'ios',
    '1.0.0',
    'iOS 16.5',
    false,
    false,
    NOW() - INTERVAL '2 days',
    NOW() - INTERVAL '3 hours'
),

-- Utilisateur 2 avec 3 appareils (2 autorisés, 1 en attente)
(
    (SELECT id FROM auth.users OFFSET 1 LIMIT 1),
    'device-003-macbook-pro',
    'MacBook Pro 2023',
    'desktop',
    'macos',
    '1.0.0',
    'macOS 13.4',
    true,
    false,
    NOW() - INTERVAL '10 days',
    NOW() - INTERVAL '2 days'
),
(
    (SELECT id FROM auth.users OFFSET 1 LIMIT 1),
    'device-004-samsung-tab',
    'Samsung Galaxy Tab S8',
    'tablet',
    'android',
    '1.0.0',
    'Android 12',
    true,
    true,
    NOW() - INTERVAL '7 days',
    NOW() - INTERVAL '30 minutes'
),
(
    (SELECT id FROM auth.users OFFSET 1 LIMIT 1),
    'device-005-windows-pc',
    'PC Windows Bureau',
    'desktop',
    'windows',
    '1.0.0',
    'Windows 11',
    false,
    false,
    NOW() - INTERVAL '1 day',
    NOW() - INTERVAL '6 hours'
),

-- Utilisateur 3 avec 1 seul appareil (autorisé)
(
    (SELECT id FROM auth.users OFFSET 2 LIMIT 1),
    'device-006-ipad-air',
    'iPad Air 5',
    'tablet',
    'ios',
    '1.0.0',
    'iPadOS 16.5',
    true,
    true,
    NOW() - INTERVAL '3 days',
    NOW() - INTERVAL '15 minutes'
);

-- Vérifier les données insérées
SELECT 
    ud.device_name,
    ud.platform,
    ud.is_authorized,
    ud.is_current_device,
    ud.last_login_at,
    u.email
FROM user_devices ud
JOIN auth.users u ON ud.user_id = u.id
ORDER BY u.email, ud.last_login_at DESC;

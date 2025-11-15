-- Script pour mettre à jour le mot de passe utilisateur dans Supabase
-- Remplacez 'VOTRE_EMAIL' et 'NOUVEAU_MOT_DE_PASSE' par les vraies valeurs

-- Option 1: Mettre à jour via auth.users (recommandé)
UPDATE auth.users 
SET encrypted_password = crypt('NOUVEAU_MOT_DE_PASSE', gen_salt('bf'))
WHERE email = 'VOTRE_EMAIL';

-- Option 2: Alternative si la première ne marche pas
-- UPDATE auth.users 
-- SET password_hash = crypt('NOUVEAU_MOT_DE_PASSE', gen_salt('bf'))
-- WHERE email = 'VOTRE_EMAIL';

-- Vérifier que la mise à jour a fonctionné
SELECT email, created_at, updated_at 
FROM auth.users 
WHERE email = 'VOTRE_EMAIL';

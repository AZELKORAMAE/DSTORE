-- Script SQL pour créer le système d'administration
-- À exécuter dans l'éditeur SQL de Supabase

-- 1. Mettre à jour la table users avec les champs d'abonnement
ALTER TABLE users ADD COLUMN IF NOT EXISTS account_status TEXT DEFAULT 'pending' CHECK (account_status IN ('pending', 'active', 'suspended', 'expired'));
ALTER TABLE users ADD COLUMN IF NOT EXISTS subscription_type TEXT DEFAULT 'basic' CHECK (subscription_type IN ('basic', 'premium', 'enterprise'));
ALTER TABLE users ADD COLUMN IF NOT EXISTS subscription_start_date TIMESTAMP WITH TIME ZONE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS subscription_end_date TIMESTAMP WITH TIME ZONE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS last_payment_date TIMESTAMP WITH TIME ZONE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS last_login_date TIMESTAMP WITH TIME ZONE;

-- 2. Créer la table admin
CREATE TABLE IF NOT EXISTS admin_users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  full_name TEXT NOT NULL,
  is_super_admin BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Activer RLS sur la table admin
ALTER TABLE admin_users ENABLE ROW LEVEL SECURITY;

-- 4. Politique pour les admins (seuls les admins peuvent voir les admins)
CREATE POLICY "Admins can manage admin users" ON admin_users FOR ALL USING (
  EXISTS (
    SELECT 1 FROM admin_users 
    WHERE email = auth.jwt() ->> 'email'
  )
);

-- 5. Créer le compte admin principal
-- IMPORTANT: Changez l'email et le mot de passe !
INSERT INTO admin_users (email, password_hash, full_name, is_super_admin) 
VALUES (
  'admin@mata24.com', 
  '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', -- password: "admin123"
  'Administrateur Principal',
  true
) ON CONFLICT (email) DO NOTHING;

-- 6. Fonction pour vérifier le mot de passe admin
CREATE OR REPLACE FUNCTION verify_admin_password(input_email TEXT, input_password TEXT)
RETURNS TABLE(
  admin_id UUID,
  email TEXT,
  full_name TEXT,
  is_super_admin BOOLEAN
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    a.id,
    a.email,
    a.full_name,
    a.is_super_admin
  FROM admin_users a
  WHERE a.email = input_email 
    AND a.password_hash = crypt(input_password, a.password_hash);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. Fonction pour obtenir tous les utilisateurs avec leurs statuts
CREATE OR REPLACE FUNCTION get_all_users_for_admin()
RETURNS TABLE(
  user_id UUID,
  email TEXT,
  full_name TEXT,
  business_name TEXT,
  account_status TEXT,
  subscription_type TEXT,
  subscription_start_date TIMESTAMP WITH TIME ZONE,
  subscription_end_date TIMESTAMP WITH TIME ZONE,
  last_payment_date TIMESTAMP WITH TIME ZONE,
  last_login_date TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    u.id,
    u.email,
    u.full_name,
    u.business_name,
    u.account_status,
    u.subscription_type,
    u.subscription_start_date,
    u.subscription_end_date,
    u.last_payment_date,
    u.last_login_date,
    u.created_at
  FROM users u
  ORDER BY u.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 8. Fonction pour mettre à jour le statut d'un utilisateur
CREATE OR REPLACE FUNCTION update_user_status(
  target_user_id UUID,
  new_status TEXT,
  new_subscription_type TEXT DEFAULT NULL,
  subscription_days INTEGER DEFAULT NULL
)
RETURNS BOOLEAN AS $$
DECLARE
  end_date TIMESTAMP WITH TIME ZONE;
BEGIN
  -- Calculer la date de fin si des jours sont spécifiés
  IF subscription_days IS NOT NULL THEN
    end_date := NOW() + (subscription_days || ' days')::INTERVAL;
  END IF;

  -- Mettre à jour l'utilisateur
  UPDATE users 
  SET 
    account_status = new_status,
    subscription_type = COALESCE(new_subscription_type, subscription_type),
    subscription_start_date = CASE 
      WHEN new_status = 'active' AND subscription_start_date IS NULL 
      THEN NOW() 
      ELSE subscription_start_date 
    END,
    subscription_end_date = COALESCE(end_date, subscription_end_date),
    last_payment_date = CASE 
      WHEN new_status = 'active' 
      THEN NOW() 
      ELSE last_payment_date 
    END,
    updated_at = NOW()
  WHERE id = target_user_id;

  RETURN FOUND;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 9. Fonction pour mettre à jour la dernière connexion
CREATE OR REPLACE FUNCTION update_last_login(user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  UPDATE users 
  SET last_login_date = NOW()
  WHERE id = user_id;
  
  RETURN FOUND;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 10. Vue pour les statistiques admin
CREATE OR REPLACE VIEW admin_stats AS
SELECT 
  COUNT(*) as total_users,
  COUNT(CASE WHEN account_status = 'active' THEN 1 END) as active_users,
  COUNT(CASE WHEN account_status = 'pending' THEN 1 END) as pending_users,
  COUNT(CASE WHEN account_status = 'suspended' THEN 1 END) as suspended_users,
  COUNT(CASE WHEN account_status = 'expired' THEN 1 END) as expired_users,
  COUNT(CASE WHEN last_login_date > NOW() - INTERVAL '24 hours' THEN 1 END) as users_last_24h,
  COUNT(CASE WHEN created_at > NOW() - INTERVAL '7 days' THEN 1 END) as new_users_week
FROM users;

-- 11. Accorder les permissions nécessaires
GRANT EXECUTE ON FUNCTION verify_admin_password TO anon, authenticated;
GRANT EXECUTE ON FUNCTION get_all_users_for_admin TO anon, authenticated;
GRANT EXECUTE ON FUNCTION update_user_status TO anon, authenticated;
GRANT EXECUTE ON FUNCTION update_last_login TO anon, authenticated;
GRANT SELECT ON admin_stats TO anon, authenticated;

-- 12. Créer un index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_users_account_status ON users(account_status);
CREATE INDEX IF NOT EXISTS idx_users_last_login ON users(last_login_date);
CREATE INDEX IF NOT EXISTS idx_admin_email ON admin_users(email);

-- 13. Afficher le résumé
SELECT 'Configuration terminée!' as status;
SELECT 'Email admin: admin@mata24.com' as info;
SELECT 'Mot de passe admin: admin123' as info;
SELECT 'CHANGEZ LE MOT DE PASSE IMMÉDIATEMENT!' as warning;

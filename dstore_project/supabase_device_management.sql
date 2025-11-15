-- Table pour la gestion des appareils autorisés par utilisateur
CREATE TABLE IF NOT EXISTS user_devices (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    device_id TEXT NOT NULL,
    device_name TEXT NOT NULL,
    device_type TEXT NOT NULL CHECK (device_type IN ('mobile', 'tablet', 'desktop', 'web')),
    platform TEXT NOT NULL CHECK (platform IN ('android', 'ios', 'windows', 'macos', 'web', 'unknown')),
    app_version TEXT NOT NULL,
    os_version TEXT NOT NULL,
    is_authorized BOOLEAN DEFAULT FALSE,
    is_current_device BOOLEAN DEFAULT FALSE,
    first_login_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    last_login_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    ip_address TEXT,
    location TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Contrainte unique pour éviter les doublons device_id + user_id
    UNIQUE(user_id, device_id)
);

-- Index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_user_devices_user_id ON user_devices(user_id);
CREATE INDEX IF NOT EXISTS idx_user_devices_device_id ON user_devices(device_id);
CREATE INDEX IF NOT EXISTS idx_user_devices_authorized ON user_devices(user_id, is_authorized);
CREATE INDEX IF NOT EXISTS idx_user_devices_last_login ON user_devices(last_login_at);

-- Fonction pour mettre à jour automatiquement updated_at
CREATE OR REPLACE FUNCTION update_user_devices_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger pour mettre à jour updated_at automatiquement
DROP TRIGGER IF EXISTS trigger_update_user_devices_updated_at ON user_devices;
CREATE TRIGGER trigger_update_user_devices_updated_at
    BEFORE UPDATE ON user_devices
    FOR EACH ROW
    EXECUTE FUNCTION update_user_devices_updated_at();

-- Politique de sécurité RLS (Row Level Security)
ALTER TABLE user_devices ENABLE ROW LEVEL SECURITY;

-- Politique pour permettre aux utilisateurs de voir seulement leurs propres appareils
CREATE POLICY "Users can view their own devices" ON user_devices
    FOR SELECT USING (auth.uid() = user_id);

-- Politique pour permettre aux utilisateurs d'insérer leurs propres appareils
CREATE POLICY "Users can insert their own devices" ON user_devices
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Politique pour permettre aux utilisateurs de mettre à jour leurs propres appareils
CREATE POLICY "Users can update their own devices" ON user_devices
    FOR UPDATE USING (auth.uid() = user_id);

-- Politique pour permettre aux utilisateurs de supprimer leurs propres appareils
CREATE POLICY "Users can delete their own devices" ON user_devices
    FOR DELETE USING (auth.uid() = user_id);

-- Fonction pour nettoyer automatiquement les anciens appareils (plus de 90 jours sans connexion)
CREATE OR REPLACE FUNCTION cleanup_old_devices()
RETURNS void AS $$
BEGIN
    DELETE FROM user_devices 
    WHERE last_login_at < NOW() - INTERVAL '90 days'
    AND is_authorized = false;
END;
$$ LANGUAGE plpgsql;

-- Fonction pour autoriser automatiquement le premier appareil d'un utilisateur
CREATE OR REPLACE FUNCTION auto_authorize_first_device()
RETURNS TRIGGER AS $$
BEGIN
    -- Si c'est le premier appareil de l'utilisateur, l'autoriser automatiquement
    IF NOT EXISTS (
        SELECT 1 FROM user_devices 
        WHERE user_id = NEW.user_id 
        AND id != NEW.id
    ) THEN
        NEW.is_authorized = true;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger pour autoriser automatiquement le premier appareil
DROP TRIGGER IF EXISTS trigger_auto_authorize_first_device ON user_devices;
CREATE TRIGGER trigger_auto_authorize_first_device
    BEFORE INSERT ON user_devices
    FOR EACH ROW
    EXECUTE FUNCTION auto_authorize_first_device();

-- Fonction pour limiter le nombre d'appareils autorisés par utilisateur (max 5)
CREATE OR REPLACE FUNCTION limit_authorized_devices()
RETURNS TRIGGER AS $$
DECLARE
    authorized_count INTEGER;
BEGIN
    -- Compter les appareils autorisés pour cet utilisateur
    SELECT COUNT(*) INTO authorized_count
    FROM user_devices 
    WHERE user_id = NEW.user_id 
    AND is_authorized = true
    AND id != NEW.id;
    
    -- Si on essaie d'autoriser un appareil et qu'il y en a déjà 5, empêcher
    IF NEW.is_authorized = true AND authorized_count >= 5 THEN
        RAISE EXCEPTION 'Maximum 5 appareils autorisés par utilisateur';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger pour limiter les appareils autorisés
DROP TRIGGER IF EXISTS trigger_limit_authorized_devices ON user_devices;
CREATE TRIGGER trigger_limit_authorized_devices
    BEFORE INSERT OR UPDATE ON user_devices
    FOR EACH ROW
    EXECUTE FUNCTION limit_authorized_devices();

-- Vue pour obtenir des statistiques sur les appareils
CREATE OR REPLACE VIEW user_device_stats AS
SELECT 
    user_id,
    COUNT(*) as total_devices,
    COUNT(*) FILTER (WHERE is_authorized = true) as authorized_devices,
    COUNT(*) FILTER (WHERE is_authorized = false) as pending_devices,
    COUNT(*) FILTER (WHERE last_login_at > NOW() - INTERVAL '7 days') as active_devices,
    MAX(last_login_at) as last_device_login
FROM user_devices
GROUP BY user_id;

-- Fonction pour obtenir les appareils en attente d'autorisation
CREATE OR REPLACE FUNCTION get_pending_devices(target_user_id UUID)
RETURNS TABLE (
    id UUID,
    device_id TEXT,
    device_name TEXT,
    device_type TEXT,
    platform TEXT,
    app_version TEXT,
    os_version TEXT,
    first_login_at TIMESTAMP WITH TIME ZONE,
    last_login_at TIMESTAMP WITH TIME ZONE,
    ip_address TEXT,
    location TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ud.id,
        ud.device_id,
        ud.device_name,
        ud.device_type,
        ud.platform,
        ud.app_version,
        ud.os_version,
        ud.first_login_at,
        ud.last_login_at,
        ud.ip_address,
        ud.location
    FROM user_devices ud
    WHERE ud.user_id = target_user_id
    AND ud.is_authorized = false
    ORDER BY ud.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Fonction pour obtenir les appareils autorisés
CREATE OR REPLACE FUNCTION get_authorized_devices(target_user_id UUID)
RETURNS TABLE (
    id UUID,
    device_id TEXT,
    device_name TEXT,
    device_type TEXT,
    platform TEXT,
    app_version TEXT,
    os_version TEXT,
    first_login_at TIMESTAMP WITH TIME ZONE,
    last_login_at TIMESTAMP WITH TIME ZONE,
    ip_address TEXT,
    location TEXT,
    is_current_device BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ud.id,
        ud.device_id,
        ud.device_name,
        ud.device_type,
        ud.platform,
        ud.app_version,
        ud.os_version,
        ud.first_login_at,
        ud.last_login_at,
        ud.ip_address,
        ud.location,
        ud.is_current_device
    FROM user_devices ud
    WHERE ud.user_id = target_user_id
    AND ud.is_authorized = true
    ORDER BY ud.last_login_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Commentaires pour la documentation
COMMENT ON TABLE user_devices IS 'Table pour gérer les appareils autorisés par utilisateur';
COMMENT ON COLUMN user_devices.device_id IS 'Identifiant unique de l''appareil (généré par l''app)';
COMMENT ON COLUMN user_devices.device_name IS 'Nom affiché de l''appareil (ex: Samsung Galaxy S21)';
COMMENT ON COLUMN user_devices.device_type IS 'Type d''appareil: mobile, tablet, desktop, web';
COMMENT ON COLUMN user_devices.platform IS 'Plateforme: android, ios, windows, macos, web';
COMMENT ON COLUMN user_devices.is_authorized IS 'Si l''appareil est autorisé à accéder au compte';
COMMENT ON COLUMN user_devices.is_current_device IS 'Si c''est l''appareil actuellement utilisé';

-- Données d'exemple (à supprimer en production)
-- INSERT INTO user_devices (user_id, device_id, device_name, device_type, platform, app_version, os_version, is_authorized)
-- VALUES 
-- ('00000000-0000-0000-0000-000000000000', 'test_device_1', 'Samsung Galaxy S21', 'mobile', 'android', '1.0.0', 'Android 12', true);

-- Afficher un message de confirmation
DO $$
BEGIN
    RAISE NOTICE 'Table user_devices créée avec succès avec toutes les fonctions et triggers !';
END $$;

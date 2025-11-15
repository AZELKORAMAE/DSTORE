-- Créer la table pour les paramètres admin globaux
CREATE TABLE IF NOT EXISTS admin_settings (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    setting_key TEXT UNIQUE NOT NULL,
    setting_value JSONB NOT NULL,
    updated_by UUID REFERENCES auth.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insérer les paramètres par défaut
INSERT INTO admin_settings (setting_key, setting_value) VALUES 
('contact_info', '{
    "business_name": "Mata24",
    "email": "admin@mata24.com", 
    "phone": "+212 693700583",
    "whatsapp": "+212 693700583"
}'::jsonb)
ON CONFLICT (setting_key) DO NOTHING;

-- Activer RLS
ALTER TABLE admin_settings ENABLE ROW LEVEL SECURITY;

-- Politique pour permettre la lecture à tous les utilisateurs authentifiés
CREATE POLICY "Tous peuvent lire les paramètres admin" ON admin_settings
    FOR SELECT TO authenticated
    USING (true);

-- Politique pour permettre la modification seulement aux admins
CREATE POLICY "Seuls les admins peuvent modifier" ON admin_settings
    FOR ALL TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM user_profiles 
            WHERE user_profiles.user_id = auth.uid() 
            AND user_profiles.role = 'admin'
        )
    );

-- Fonction pour mettre à jour automatiquement updated_at
CREATE OR REPLACE FUNCTION update_admin_settings_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    NEW.updated_by = auth.uid();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger pour mettre à jour automatiquement updated_at
CREATE TRIGGER update_admin_settings_updated_at
    BEFORE UPDATE ON admin_settings
    FOR EACH ROW
    EXECUTE FUNCTION update_admin_settings_updated_at();

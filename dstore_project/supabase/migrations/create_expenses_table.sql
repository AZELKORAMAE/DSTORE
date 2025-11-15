-- Créer la table des dépenses
CREATE TABLE IF NOT EXISTS expenses (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL CHECK (type IN ('rent', 'electricity', 'wifi', 'other')),
    amount DECIMAL(10,2) NOT NULL CHECK (amount > 0),
    description TEXT NOT NULL,
    date DATE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Créer un index sur user_id pour optimiser les requêtes
CREATE INDEX IF NOT EXISTS idx_expenses_user_id ON expenses(user_id);

-- Créer un index sur la date pour optimiser les requêtes par période
CREATE INDEX IF NOT EXISTS idx_expenses_date ON expenses(date);

-- Créer un index composé pour optimiser les requêtes par utilisateur et date
CREATE INDEX IF NOT EXISTS idx_expenses_user_date ON expenses(user_id, date);

-- Activer RLS (Row Level Security)
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;

-- Politique pour permettre aux utilisateurs de voir leurs propres dépenses
CREATE POLICY "Users can view their own expenses" ON expenses
    FOR SELECT USING (auth.uid() = user_id);

-- Politique pour permettre aux utilisateurs d'insérer leurs propres dépenses
CREATE POLICY "Users can insert their own expenses" ON expenses
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Politique pour permettre aux utilisateurs de modifier leurs propres dépenses
CREATE POLICY "Users can update their own expenses" ON expenses
    FOR UPDATE USING (auth.uid() = user_id);

-- Politique pour permettre aux utilisateurs de supprimer leurs propres dépenses
CREATE POLICY "Users can delete their own expenses" ON expenses
    FOR DELETE USING (auth.uid() = user_id);

-- Fonction pour mettre à jour automatiquement updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger pour mettre à jour automatiquement updated_at
CREATE TRIGGER update_expenses_updated_at 
    BEFORE UPDATE ON expenses 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Insérer quelques données de test (optionnel)
-- INSERT INTO expenses (user_id, type, amount, description, date) VALUES
-- (auth.uid(), 'rent', 5000.00, 'Loyer mensuel du magasin', CURRENT_DATE),
-- (auth.uid(), 'electricity', 800.00, 'Facture d\'électricité', CURRENT_DATE),
-- (auth.uid(), 'wifi', 300.00, 'Abonnement internet', CURRENT_DATE);

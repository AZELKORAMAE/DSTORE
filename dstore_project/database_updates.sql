-- Script de mise à jour de la base de données Supabase
-- À exécuter dans l'éditeur SQL de Supabase

-- 1. Ajouter la colonne image_url à la table categories si elle n'existe pas
ALTER TABLE categories ADD COLUMN IF NOT EXISTS image_url TEXT;

-- 2. Ajouter la colonne is_active à la table categories si elle n'existe pas
ALTER TABLE categories ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE;

-- 3. Créer le bucket pour les images de catégories
INSERT INTO storage.buckets (id, name, public) 
VALUES ('category-images', 'category-images', true)
ON CONFLICT (id) DO NOTHING;

-- 4. Créer les politiques de stockage pour les images de catégories
CREATE POLICY "Users can upload category images" ON storage.objects 
FOR INSERT WITH CHECK (
  bucket_id = 'category-images' AND auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Users can view category images" ON storage.objects 
FOR SELECT USING (
  bucket_id = 'category-images'
);

CREATE POLICY "Users can update own category images" ON storage.objects 
FOR UPDATE USING (
  bucket_id = 'category-images' AND auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Users can delete own category images" ON storage.objects 
FOR DELETE USING (
  bucket_id = 'category-images' AND auth.uid()::text = (storage.foldername(name))[1]
);

-- 5. Vérifier que les politiques existent (optionnel - pour debug)
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename = 'objects' AND schemaname = 'storage'
AND policyname LIKE '%category%';

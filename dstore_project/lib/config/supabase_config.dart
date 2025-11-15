class SupabaseConfig {
  // Vos clés Supabase configurées
  static const String url = 'https://pzbemsyremoypwnkxqew.supabase.co';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB6YmVtc3lyZW1veXB3bmt4cWV3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA4MDQyNTUsImV4cCI6MjA2NjM4MDI1NX0.NaIyXfR4BpDrPQTXX2Z9iaQNx5dv7fkOu_IGo2nXXMo';

  // Noms des tables
  static const String usersTable = 'users';
  static const String categoriesTable = 'categories';
  static const String productsTable = 'products';
  static const String clientsTable = 'clients';
  static const String suppliersTable = 'suppliers';
  static const String invoicesTable = 'invoices';
  static const String invoiceItemsTable = 'invoice_items';
  static const String stockMovementsTable = 'stock_movements';
  static const String purchaseOrdersTable = 'purchase_orders';
  static const String purchaseOrderItemsTable = 'purchase_order_items';

  // Buckets de stockage
  static const String productImagesBucket = 'product-images';
  static const String categoryImagesBucket = 'category-images';
  static const String invoicesBucket = 'invoices';

  // Politiques RLS (Row Level Security)
  static const Map<String, String> rlsPolicies = {
    'users': 'auth.uid() = user_id',
    'categories': 'auth.uid() = user_id',
    'products': 'auth.uid() = user_id',
    'clients': 'auth.uid() = user_id',
    'suppliers': 'auth.uid() = user_id',
    'invoices': 'auth.uid() = user_id',
    'invoice_items':
        'EXISTS (SELECT 1 FROM invoices WHERE invoices.id = invoice_items.invoice_id AND invoices.user_id = auth.uid())',
    'stock_movements': 'auth.uid() = user_id',
    'purchase_orders': 'auth.uid() = user_id',
    'purchase_order_items':
        'EXISTS (SELECT 1 FROM purchase_orders WHERE purchase_orders.id = purchase_order_items.purchase_order_id AND purchase_orders.user_id = auth.uid())',
  };
}

// Script SQL pour créer les tables (à exécuter dans l'éditeur SQL de Supabase)
const String createTablesSQL = '''
-- Activer RLS sur auth.users
ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;

-- Table des codes de vérification pour la réinitialisation de mot de passe
CREATE TABLE IF NOT EXISTS verification_codes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email TEXT NOT NULL,
  code TEXT NOT NULL,
  expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
  used BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des utilisateurs étendus avec gestion d'abonnement
CREATE TABLE IF NOT EXISTS users (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT,
  business_name TEXT,
  phone TEXT,
  address TEXT,
  account_status TEXT DEFAULT 'pending' CHECK (account_status IN ('pending', 'active', 'suspended', 'expired')),
  subscription_type TEXT DEFAULT 'basic' CHECK (subscription_type IN ('basic', 'premium', 'enterprise')),
  subscription_start_date TIMESTAMP WITH TIME ZONE,
  subscription_end_date TIMESTAMP WITH TIME ZONE,
  last_payment_date TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des catégories
CREATE TABLE IF NOT EXISTS categories (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  color TEXT DEFAULT '#2196F3',
  image_url TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, name)
);

-- Table des produits
CREATE TABLE IF NOT EXISTS products (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
  name TEXT NOT NULL,
  description TEXT,
  barcode TEXT,
  sku TEXT,
  purchase_price DECIMAL(10,2) NOT NULL DEFAULT 0,
  selling_price DECIMAL(10,2) NOT NULL DEFAULT 0,
  stock_quantity INTEGER NOT NULL DEFAULT 0,
  min_stock_threshold INTEGER DEFAULT 10,
  unit TEXT DEFAULT 'pièce',
  image_url TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, barcode),
  UNIQUE(user_id, sku)
);

-- Table des clients
CREATE TABLE IF NOT EXISTS clients (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  email TEXT,
  phone TEXT,
  address TEXT,
  city TEXT,
  notes TEXT,
  credit_limit DECIMAL(10,2) DEFAULT 0,
  current_credit DECIMAL(10,2) DEFAULT 0,
  total_purchases DECIMAL(10,2) DEFAULT 0,
  last_purchase_date TIMESTAMP WITH TIME ZONE,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des fournisseurs
CREATE TABLE IF NOT EXISTS suppliers (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  email TEXT,
  phone TEXT,
  address TEXT,
  city TEXT,
  contact_person TEXT,
  notes TEXT,
  total_purchases DECIMAL(10,2) DEFAULT 0,
  last_order_date TIMESTAMP WITH TIME ZONE,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des factures
CREATE TABLE IF NOT EXISTS invoices (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  client_id UUID REFERENCES clients(id) ON DELETE SET NULL,
  supplier_id UUID REFERENCES suppliers(id) ON DELETE SET NULL,
  invoice_number TEXT NOT NULL,
  invoice_type TEXT DEFAULT 'sale' CHECK (invoice_type IN ('sale', 'purchase')),
  invoice_date DATE NOT NULL DEFAULT CURRENT_DATE,
  due_date DATE,
  subtotal DECIMAL(10,2) NOT NULL DEFAULT 0,
  tax_amount DECIMAL(10,2) DEFAULT 0,
  discount_amount DECIMAL(10,2) DEFAULT 0,
  total_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
  paid_amount DECIMAL(10,2) DEFAULT 0,
  status TEXT DEFAULT 'draft' CHECK (status IN ('draft', 'validated', 'paid', 'cancelled')),
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, invoice_number)
);

-- Table des articles de facture
CREATE TABLE IF NOT EXISTS invoice_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  invoice_id UUID REFERENCES invoices(id) ON DELETE CASCADE NOT NULL,
  product_id UUID REFERENCES products(id) ON DELETE CASCADE NOT NULL,
  quantity INTEGER NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL,
  total_price DECIMAL(10,2) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des mouvements de stock
CREATE TABLE IF NOT EXISTS stock_movements (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  product_id UUID REFERENCES products(id) ON DELETE CASCADE NOT NULL,
  movement_type TEXT NOT NULL CHECK (movement_type IN ('in', 'out', 'adjustment')),
  quantity INTEGER NOT NULL,
  reference_type TEXT CHECK (reference_type IN ('invoice', 'purchase_order', 'adjustment')),
  reference_id UUID,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des commandes d'achat
CREATE TABLE IF NOT EXISTS purchase_orders (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  supplier_id UUID REFERENCES suppliers(id) ON DELETE SET NULL,
  order_number TEXT NOT NULL,
  order_date DATE NOT NULL DEFAULT CURRENT_DATE,
  expected_date DATE,
  total_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'received', 'cancelled')),
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, order_number)
);

-- Table des articles de commande d'achat
CREATE TABLE IF NOT EXISTS purchase_order_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  purchase_order_id UUID REFERENCES purchase_orders(id) ON DELETE CASCADE NOT NULL,
  product_id UUID REFERENCES products(id) ON DELETE CASCADE NOT NULL,
  quantity INTEGER NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL,
  total_price DECIMAL(10,2) NOT NULL,
  received_quantity INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Créer les index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_products_user_id ON products(user_id);
CREATE INDEX IF NOT EXISTS idx_products_category_id ON products(category_id);
CREATE INDEX IF NOT EXISTS idx_products_barcode ON products(barcode);
CREATE INDEX IF NOT EXISTS idx_invoices_user_id ON invoices(user_id);
CREATE INDEX IF NOT EXISTS idx_invoices_client_id ON invoices(client_id);
CREATE INDEX IF NOT EXISTS idx_invoices_date ON invoices(invoice_date);
CREATE INDEX IF NOT EXISTS idx_stock_movements_product_id ON stock_movements(product_id);
CREATE INDEX IF NOT EXISTS idx_stock_movements_user_id ON stock_movements(user_id);

-- Activer RLS sur toutes les tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE suppliers ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoice_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE stock_movements ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchase_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchase_order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE verification_codes ENABLE ROW LEVEL SECURITY;

-- Créer les politiques RLS
CREATE POLICY "Users can view own data" ON users FOR ALL USING (auth.uid() = id);
CREATE POLICY "Users can view own categories" ON categories FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can view own products" ON products FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can view own clients" ON clients FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can view own suppliers" ON suppliers FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can view own invoices" ON invoices FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can view own invoice items" ON invoice_items FOR ALL USING (
  EXISTS (SELECT 1 FROM invoices WHERE invoices.id = invoice_items.invoice_id AND invoices.user_id = auth.uid())
);
CREATE POLICY "Users can view own stock movements" ON stock_movements FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can view own purchase orders" ON purchase_orders FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can view own purchase order items" ON purchase_order_items FOR ALL USING (
  EXISTS (SELECT 1 FROM purchase_orders WHERE purchase_orders.id = purchase_order_items.purchase_order_id AND purchase_orders.user_id = auth.uid())
);

-- Politique pour les codes de vérification (accessible à tous pour la réinitialisation)
CREATE POLICY "Anyone can manage verification codes" ON verification_codes FOR ALL USING (true);

-- Créer les buckets de stockage
INSERT INTO storage.buckets (id, name, public) VALUES ('product-images', 'product-images', true);
INSERT INTO storage.buckets (id, name, public) VALUES ('category-images', 'category-images', true);
INSERT INTO storage.buckets (id, name, public) VALUES ('invoices', 'invoices', false);

-- Politiques de stockage
CREATE POLICY "Users can upload product images" ON storage.objects FOR INSERT WITH CHECK (
  bucket_id = 'product-images' AND auth.uid()::text = (storage.foldername(name))[1]
);
CREATE POLICY "Users can view product images" ON storage.objects FOR SELECT USING (
  bucket_id = 'product-images'
);
CREATE POLICY "Users can update own product images" ON storage.objects FOR UPDATE USING (
  bucket_id = 'product-images' AND auth.uid()::text = (storage.foldername(name))[1]
);
CREATE POLICY "Users can delete own product images" ON storage.objects FOR DELETE USING (
  bucket_id = 'product-images' AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Politiques pour les images de catégories
CREATE POLICY "Users can upload category images" ON storage.objects FOR INSERT WITH CHECK (
  bucket_id = 'category-images' AND auth.uid()::text = (storage.foldername(name))[1]
);
CREATE POLICY "Users can view category images" ON storage.objects FOR SELECT USING (
  bucket_id = 'category-images'
);
CREATE POLICY "Users can update own category images" ON storage.objects FOR UPDATE USING (
  bucket_id = 'category-images' AND auth.uid()::text = (storage.foldername(name))[1]
);
CREATE POLICY "Users can delete own category images" ON storage.objects FOR DELETE USING (
  bucket_id = 'category-images' AND auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Users can upload invoices" ON storage.objects FOR INSERT WITH CHECK (
  bucket_id = 'invoices' AND auth.uid()::text = (storage.foldername(name))[1]
);
CREATE POLICY "Users can view own invoices" ON storage.objects FOR SELECT USING (
  bucket_id = 'invoices' AND auth.uid()::text = (storage.foldername(name))[1]
);
''';

-- Add qr_code column to existing products table
ALTER TABLE products ADD COLUMN IF NOT EXISTS qr_code VARCHAR(255) UNIQUE;

-- Update existing products with QR codes
UPDATE products SET qr_code = CONCAT('QR-', product_id, '-MBS-', YEAR(created_at)) WHERE qr_code IS NULL;

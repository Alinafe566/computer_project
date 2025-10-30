-- COMBINED DATABASE SETUP FOR PRODUCT VERIFICATION SYSTEM
-- This file combines all SQL setup, fixes, and sample data into one comprehensive script
-- Run this entire script in phpMyAdmin SQL tab or MySQL command line

-- Create database
CREATE DATABASE IF NOT EXISTS product_verification_system_db;
USE product_verification_system_db;

-- Disable foreign key checks temporarily
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================
-- FIX 1: USERS TABLE
-- ============================================
DROP TABLE IF EXISTS users;
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(50) DEFAULT 'consumer',
    phone VARCHAR(20),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ============================================
-- FIX 2: MANUFACTURERS TABLE
-- ============================================
DROP TABLE IF EXISTS manufacturers;
CREATE TABLE manufacturers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    license_number VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(100),
    address TEXT,
    status VARCHAR(50) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ============================================
-- FIX 3: PRODUCT_BATCHES TABLE (SECURE QR SYSTEM)
-- ============================================
DROP TABLE IF EXISTS product_batches;
CREATE TABLE product_batches (
    id INT AUTO_INCREMENT PRIMARY KEY,
    batch_id VARCHAR(50) UNIQUE NOT NULL,
    product_name VARCHAR(200) NOT NULL,
    batch_number VARCHAR(100) NOT NULL,
    manufacturer_id INT NOT NULL,
    manufacture_date DATE NOT NULL,
    expiry_date DATE NOT NULL,
    qr_token VARCHAR(255) UNIQUE NOT NULL,
    qr_signature VARCHAR(255) NOT NULL,
    qr_image_path VARCHAR(255),
    certification_status VARCHAR(50) DEFAULT 'certified',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (manufacturer_id) REFERENCES manufacturers(id) ON DELETE CASCADE
);

-- ============================================
-- FIX 4: PRODUCTS TABLE (LEGACY SUPPORT)
-- ============================================
DROP TABLE IF EXISTS products;
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id VARCHAR(50) UNIQUE NOT NULL,
    qr_code VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(200) NOT NULL,
    manufacturer VARCHAR(200) NOT NULL,
    manufacturer_phone VARCHAR(20),
    manufacturer_email VARCHAR(100),
    description TEXT,
    category VARCHAR(100),
    price DECIMAL(10,2),
    manufacturing_date DATE,
    expiry_date DATE,
    batch_number VARCHAR(100),
    is_verified BOOLEAN DEFAULT TRUE,
    certification_status VARCHAR(100) DEFAULT 'Certified by MBS',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ============================================
-- FIX 5: SCAN_HISTORY TABLE
-- ============================================
DROP TABLE IF EXISTS scan_history;
CREATE TABLE scan_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    batch_id VARCHAR(50),
    product_name VARCHAR(200),
    scan_result VARCHAR(50) NOT NULL,
    scan_location VARCHAR(255),
    scan_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- ============================================
-- FIX 6: COUNTERFEIT_REPORTS TABLE
-- ============================================
DROP TABLE IF EXISTS counterfeit_reports;
CREATE TABLE counterfeit_reports (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    batch_id VARCHAR(50),
    product_name VARCHAR(200),
    store_name VARCHAR(200),
    store_location VARCHAR(255),
    report_description TEXT,
    photo_url VARCHAR(255),
    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- ============================================
-- FIX 7: PENALTIES TABLE
-- ============================================
DROP TABLE IF EXISTS penalties;
CREATE TABLE penalties (
    id INT AUTO_INCREMENT PRIMARY KEY,
    manufacturer_id INT NOT NULL,
    offense_type VARCHAR(100) NOT NULL,
    penalty_amount DECIMAL(10,2) NOT NULL,
    description TEXT,
    status VARCHAR(50) DEFAULT 'pending',
    issued_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (manufacturer_id) REFERENCES manufacturers(id) ON DELETE CASCADE
);

-- ============================================
-- FIX 8: AUDITS TABLE
-- ============================================
DROP TABLE IF EXISTS audits;
CREATE TABLE audits (
    id INT AUTO_INCREMENT PRIMARY KEY,
    manufacturer_id INT NOT NULL,
    audit_type VARCHAR(100) NOT NULL,
    audit_date DATE NOT NULL,
    auditor_name VARCHAR(200),
    receipt_number VARCHAR(100) UNIQUE,
    status VARCHAR(50) DEFAULT 'scheduled',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (manufacturer_id) REFERENCES manufacturers(id) ON DELETE CASCADE
);

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================
-- INSERT SAMPLE DATA
-- ============================================

-- Sample users (password: 'password')
INSERT INTO users (full_name, email, password, role) VALUES
('Admin User', 'admin@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin'),
('Test User', 'test@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'consumer'),
('John Doe', 'john@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'consumer');

-- Sample manufacturers
INSERT INTO manufacturers (name, license_number, phone, email, address, status) VALUES
('TechCorp Ltd', 'LIC001', '+265888123456', 'contact@techcorp.com', '123 Tech Street, Lilongwe', 'active'),
('Nature Foods', 'LIC002', '+265999654321', 'info@naturefoods.com', '456 Organic Ave, Blantyre', 'active'),
('AquaPure Water', 'LIC003', '+265888777666', 'info@aquapure.mw', '789 Water Road, Mzuzu', 'active');

-- Sample product batches with secure QR tokens
INSERT INTO product_batches (batch_id, product_name, batch_number, manufacturer_id, manufacture_date, expiry_date, qr_token, qr_signature, certification_status, is_active) VALUES
('MBS-2025-A1B2C3D4', 'Premium Headphones', 'BATCH-20240115-01', 1, '2024-01-15', '2026-01-15', 'A1B2C3D4E5F6G7H8', '7d9e3d2a1b5c8f4e6a9b2c5d8e1f4a7b3c6d9e2f5a8b1c4d7e0f3a6b9c2d5e8f1', 'certified', 1),
('MBS-2025-H8G7F6E5', 'Organic Green Tea', 'BATCH-20240201-02', 2, '2024-02-01', '2025-02-01', 'H8G7F6E5D4C3B2A1', '1f8e2d5c9b6a3d0e7f4a1b8c5d2e9f6a3b0c7d4e1f8a5b2c9d6e3f0a7b4c1d8e5', 'certified', 1),
('MBS-2025-X9Y8Z7W6', 'AquaPure 500ml', 'BATCH-20250101-03', 3, '2025-01-01', '2026-01-01', 'X9Y8Z7W6V5U4T3S2', '2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4e5f6a7b8c9d0e1f2a3b4', 'certified', 1);

-- Sample legacy products
INSERT INTO products (product_id, qr_code, name, manufacturer, manufacturer_phone, manufacturer_email, description, category, price, manufacturing_date, expiry_date, batch_number, certification_status) VALUES
('PRD001', 'QR-PRD001-MBS-2024', 'Premium Headphones', 'TechCorp Ltd', '+265888123456', 'contact@techcorp.com', 'High-quality wireless headphones', 'Electronics', 299.99, '2024-01-15', '2026-01-15', 'TC2024001', 'Certified by MBS'),
('PRD002', 'QR-PRD002-MBS-2024', 'Organic Green Tea', 'Nature Foods', '+265999654321', 'info@naturefoods.com', 'Premium organic green tea leaves', 'Food & Beverage', 24.99, '2024-02-01', '2025-02-01', 'NF2024002', 'Certified by MBS');

-- Sample scan history
INSERT INTO scan_history (user_id, batch_id, product_name, scan_result, scan_location) VALUES
(2, 'MBS-2025-A1B2C3D4', 'Premium Headphones', 'authentic', 'Lilongwe'),
(3, 'MBS-2025-H8G7F6E5', 'Organic Green Tea', 'authentic', 'Blantyre');

-- Sample counterfeit reports
INSERT INTO counterfeit_reports (user_id, batch_id, product_name, store_name, store_location, report_description, status) VALUES
(2, 'FAKE-001', 'Fake Headphones', 'Suspicious Store', 'Area 25, Lilongwe', 'Product packaging looks different', 'pending');

-- ============================================
-- DATABASE SETUP COMPLETE
-- ============================================
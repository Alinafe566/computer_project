-- Create database
CREATE DATABASE IF NOT EXISTS product_verification_system_db;
USE product_verification_system_db;

-- Create users table
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(50) DEFAULT 'consumer',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create products table
CREATE TABLE IF NOT EXISTS products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id VARCHAR(50) UNIQUE NOT NULL,
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

-- Insert sample data
INSERT IGNORE INTO users (full_name, email, password, role) VALUES 
('Admin User', 'admin@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin'),
('Test User', 'test@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'consumer');
-- Password for both users is 'password'

-- Create scan history table
CREATE TABLE IF NOT EXISTS scan_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    product_id VARCHAR(50),
    scan_result ENUM('authentic', 'fake', 'not_found') NOT NULL,
    scan_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Create counterfeit reports table
CREATE TABLE IF NOT EXISTS counterfeit_reports (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    product_id VARCHAR(50),
    report_description TEXT,
    photo_url VARCHAR(255),
    status ENUM('pending', 'investigating', 'resolved') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Create manufacturers table
CREATE TABLE IF NOT EXISTS manufacturers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    license_number VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    email VARCHAR(100),
    address TEXT,
    status ENUM('active', 'suspended', 'revoked') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data
INSERT IGNORE INTO users (full_name, email, password, role) VALUES 
('Admin User', 'admin@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin'),
('Test User', 'test@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'consumer');

INSERT IGNORE INTO manufacturers (name, license_number, phone, email, address) VALUES 
('TechCorp Ltd', 'LIC001', '+1234567890', 'contact@techcorp.com', '123 Tech Street'),
('Nature Foods', 'LIC002', '+0987654321', 'info@naturefoods.com', '456 Organic Ave');

INSERT IGNORE INTO products (product_id, name, manufacturer, manufacturer_phone, manufacturer_email, description, category, price, manufacturing_date, expiry_date, batch_number, certification_status) VALUES 
('PRD001', 'Premium Headphones', 'TechCorp Ltd', '+1234567890', 'contact@techcorp.com', 'High-quality wireless headphones', 'Electronics', 299.99, '2024-01-15', '2026-01-15', 'TC2024001', 'Certified by MBS'),
('PRD002', 'Organic Green Tea', 'Nature Foods', '+0987654321', 'info@naturefoods.com', 'Premium organic green tea leaves', 'Food & Beverage', 24.99, '2024-02-01', '2025-02-01', 'NF2024002', 'Certified by MBS');
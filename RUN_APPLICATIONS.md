# MBS Product Verification System - Quick Start Guide

## Current Network Configuration
- **Network IP**: `192.168.39.84`
- **API Base URL**: `http://192.168.39.84/product_verification_system_api`

## Prerequisites
1. **XAMPP** running with Apache and MySQL
2. **Flutter** installed and configured
3. **Database** setup completed

## Step 1: Start XAMPP Services
```cmd
# Start Apache and MySQL in XAMPP Control Panel
```

## Step 2: Setup Database (if not done)
1. Open phpMyAdmin: `http://localhost/phpmyadmin`
2. Import: `Product manager\product_verification_system_api\setup_database.sql`

## Step 3: Copy API Files to XAMPP
```cmd
# Copy API folder to XAMPP htdocs
xcopy "Product manager\product_verification_system_api" "C:\xampp\htdocs\product_verification_system_api" /E /I /Y
```

## Step 4: Test API Connection
Open browser: `http://192.168.39.84/product_verification_system_api/test_connection.php`

## Step 5: Run Consumer Mobile App
```cmd
cd "Product manager\product_verification"
flutter clean
flutter pub get
flutter run
```

## Step 6: Run Admin Desktop App
```cmd
cd "Product Management\product_verification"
flutter clean
flutter pub get
flutter run -d windows
```

## Updated Features
- ✅ Network IP updated to `192.168.39.84`
- ✅ Consumer app: QR scanning, product verification, counterfeit reporting
- ✅ Admin app: Batch management with QR generation
- ✅ API services: Secure verification, batch creation, reporting

## Test the System
1. **Admin App**: Create a product batch → generates QR code
2. **Mobile App**: Scan QR code → verify product authenticity
3. **Mobile App**: Report counterfeit if needed

## Troubleshooting
- If IP changes, update `api_service.dart` files in both apps
- Ensure XAMPP Apache is running on port 80
- Check Windows Firewall allows connections on port 80
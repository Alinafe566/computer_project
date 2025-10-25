# Product Verification System Installation Guide

## Backend Setup (XAMPP + PHP + MySQL)

### 1. Install XAMPP
- Download and install XAMPP from https://www.apachefriends.org/
- Start Apache and MySQL services

### 2. Setup Database
1. Open phpMyAdmin (http://localhost/phpmyadmin)
2. Import the SQL file: `trustscan_api/setup_database.sql`
3. Or manually run the SQL commands to create database and table

### 3. Deploy PHP API
1. Copy the `product_verification_system_api` folder to your XAMPP `htdocs` directory
   - Path: `C:\xampp\htdocs\product_verification_system_api\`
2. Ensure the folder structure is:
   ```
   htdocs/
   └── product_verification_system_api/
       ├── config/
       │   └── db_connect.php
       ├── auth/
       │   ├── register.php
       │   └── login.php
       └── setup_database.sql
   ```

### 4. Test API Endpoints
- Registration: http://localhost/product_verification_system_api/auth/register.php
- Login: http://localhost/product_verification_system_api/auth/login.php

## Flutter App Setup

### 1. Install Dependencies
```bash
cd product_verification
flutter pub get
```

### 2. Run on Android Emulator
```bash
flutter run
```

### 3. Test Login Credentials
- Email: test@example.com
- Password: password

## Network Configuration

### For Android Emulator:
- Use `10.0.2.2` instead of `localhost` (already configured in ApiService)
- API Base URL: `http://localhost/product_verification_system_api`

### For Physical Device:
- Replace `10.0.2.2` with your computer's IP address
- Example: `http://192.168.1.100/product_verification_system_api`

## Troubleshooting

### Common Issues:
1. **Connection refused**: Ensure XAMPP Apache is running
2. **Database connection failed**: Check MySQL service in XAMPP
3. **CORS errors**: Headers are already configured in PHP files
4. **404 errors**: Verify file paths in htdocs folder

### Testing API with Postman:
```json
POST http://localhost/product_verification_system_api/auth/register.php
Content-Type: application/json

{
    "full_name": "John Doe",
    "email": "john@example.com", 
    "password": "password123"
}
```

## Features Implemented

✅ User Registration with validation
✅ User Login with password verification  
✅ Session management with SharedPreferences
✅ State management with Provider
✅ Form validation
✅ Toast notifications
✅ Auto-login on app restart
✅ Logout functionality
✅ CORS headers for Flutter communication
✅ Secure password hashing
✅ Email uniqueness validation
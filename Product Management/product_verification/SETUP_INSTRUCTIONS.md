# Admin Login/Register System Setup

## Prerequisites
- XAMPP installed and running
- Flutter SDK installed
- Existing product_verification_system_api in XAMPP htdocs

## Backend Setup (Using Existing API)

1. **Start XAMPP**
   - Start Apache and MySQL services

2. **Database Already Setup**
   - Uses existing `product_verification_system_db` database
   - Uses existing `users` table with admin/consumer roles

3. **API Endpoints Available**
   - Login endpoint: http://localhost/product_verification_system_api/auth/login.php
   - Register endpoint: http://localhost/product_verification_system_api/auth/register.php

## Frontend Setup (Flutter)

1. **Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **Run the App**
   ```bash
   flutter run
   ```

## Default Test Credentials
- Email: test@example.com
- Password: password

## API Endpoints

### POST /product_verification_system_api/auth/login.php
```json
{
  "email": "test@example.com",
  "password": "password"
}
```

### POST /product_verification_system_api/auth/register.php
```json
{
  "full_name": "New User",
  "email": "newuser@example.com",
  "password": "password123"
}
```

## File Structure
```
product_verification/
├── lib/
│   └── main.dart (Flutter app with login/register)
└── pubspec.yaml (Updated with http dependency)

XAMPP htdocs/product_verification_system_api/
├── auth/
│   ├── login.php (Login endpoint)
│   └── register.php (Register endpoint)
├── config/
│   └── db_connect.php (Database configuration)
└── setup_database.sql (Database setup)
```
# Network Troubleshooting Guide

## Current Configuration
- **Server IP**: 192.168.127.84
- **API Base URL**: http://192.168.127.84/product_verification_system_api
- **Test Endpoint**: http://192.168.127.84/product_verification_system_api/test_connection.php

## Changes Made
1. ✅ Updated `.env` file with correct IP address
2. ✅ Updated `ApiService.dart` fallback URLs
3. ✅ Added CORS headers to PHP APIs
4. ✅ Created debug screen for connection testing
5. ✅ Added test endpoint for connectivity verification

## Testing Steps

### 1. Test from Computer (Verify Server Works)
```bash
curl http://192.168.127.84/product_verification_system_api/test_connection.php
```
Expected: `{"success":true,"message":"Connection successful",...}`

### 2. Test Mobile App Connection
1. Run the mobile app: `flutter run`
2. Navigate to the dashboard
3. Tap the **bug icon** (🐛) in the app bar
4. Tap "Test Connection" button
5. Check the result

### 3. If Connection Fails
**Option A: Windows Firewall (Run as Administrator)**
```cmd
netsh advfirewall firewall add rule name="Apache HTTP" dir=in action=allow protocol=TCP localport=80
```

**Option B: Use Different IP**
If WiFi IP changes, update both files:
- `.env`: `API_BASE_URL=http://NEW_IP/product_verification_system_api`
- `api_service.dart`: Update fallback URLs

**Option C: Check Network**
- Ensure phone and computer are on same WiFi network
- Try pinging from phone's browser: `http://192.168.127.84/product_verification_system_api/test_connection.php`

## Current Network Status
- ✅ XAMPP Server Running
- ✅ Apache on Port 80
- ✅ API Endpoints Accessible
- ✅ CORS Headers Added
- ⚠️ Windows Firewall May Block External Connections

## Next Steps
1. Run mobile app and test debug screen
2. If fails, run firewall command as administrator
3. If IP changes, update configuration files
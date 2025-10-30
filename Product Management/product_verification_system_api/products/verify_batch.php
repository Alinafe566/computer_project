<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST');
header('Access-Control-Allow-Headers: Content-Type');

require_once '../config/db_connect.php';
require_once '../config/config.php';

// Get token and signature from query params or POST
$token = $_GET['token'] ?? ($_POST['token'] ?? null);
$sig = $_GET['sig'] ?? ($_POST['sig'] ?? null);

if (!$token || !$sig) {
    echo json_encode([
        'success' => false,
        'message' => 'Invalid QR code - Missing parameters',
        'is_authentic' => false
    ]);
    exit;
}

try {
    // Verify HMAC signature
    $expected_sig = hash_hmac('sha256', $token, MBS_SECRET_KEY);
    
    if (!hash_equals($expected_sig, $sig)) {
        echo json_encode([
            'success' => false,
            'message' => 'COUNTERFEIT - Signature Invalid',
            'is_authentic' => false
        ]);
        exit;
    }
    
    // Fetch batch by token
    $stmt = $pdo->prepare("SELECT pb.*, m.name as manufacturer_name FROM product_batches pb JOIN manufacturers m ON pb.manufacturer_id = m.id WHERE pb.qr_token = ? AND pb.is_active = 1");
    $stmt->execute([$token]);
    $batch = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$batch) {
        echo json_encode([
            'success' => false,
            'message' => 'COUNTERFEIT - Product not found in database',
            'is_authentic' => false
        ]);
        exit;
    }
    
    // Check expiry
    $isExpired = strtotime($batch['expiry_date']) < time();
    $isOriginal = !$isExpired && strtolower($batch['certification_status']) === 'certified';
    
    echo json_encode([
        'success' => true,
        'message' => $isOriginal ? 'Product is ORIGINAL - Certified by MBS' : 'Product verification failed',
        'is_authentic' => $isOriginal,
        'is_original' => $isOriginal,
        'product' => [
            'batch_id' => $batch['batch_id'],
            'product_name' => $batch['product_name'],
            'batch_number' => $batch['batch_number'],
            'manufacturer' => $batch['manufacturer_name'],
            'manufacture_date' => $batch['manufacture_date'],
            'expiry_date' => $batch['expiry_date'],
            'certification_status' => $isExpired ? 'expired' : $batch['certification_status']
        ]
    ]);
    
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Database error']);
}
?>

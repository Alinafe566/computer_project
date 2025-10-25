<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

require_once '../config/db_connect.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit;
}

$input = json_decode(file_get_contents('php://input'), true);

if (!isset($input['qr_code']) || empty($input['qr_code'])) {
    echo json_encode(['success' => false, 'message' => 'QR code is required']);
    exit;
}

try {
    $stmt = $pdo->prepare("SELECT name, manufacturer, expiry_date, batch_number, is_verified, certification_status FROM products WHERE product_id = ?");
    $stmt->execute([$input['qr_code']]);
    $product = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($product) {
        $isExpired = $product['expiry_date'] && strtotime($product['expiry_date']) < time();
        $certificationStatus = $product['is_verified'] ? 
            ($isExpired ? 'Expired' : $product['certification_status']) : 
            'Not Certified';
        
        echo json_encode([
            'success' => true,
            'message' => $product['is_verified'] && !$isExpired ? 'Product verified successfully' : 'Product verification failed',
            'is_authentic' => $product['is_verified'] && !$isExpired,
            'product' => [
                'name' => $product['name'],
                'manufacturer' => $product['manufacturer'],
                'batch_number' => $product['batch_number'],
                'expiry_date' => $product['expiry_date'],
                'certification_status' => $certificationStatus
            ]
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'Product not found',
            'is_authentic' => false
        ]);
    }
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Database error']);
}
?>
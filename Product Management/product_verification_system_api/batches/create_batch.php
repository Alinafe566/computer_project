<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

require_once '../config/db_connect.php';
require_once '../config/config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit;
}

$input = json_decode(file_get_contents('php://input'), true);

$required = ['product_name', 'manufacturer_id', 'manufacture_date', 'expiry_date'];
foreach ($required as $field) {
    if (!isset($input[$field]) || empty($input[$field])) {
        echo json_encode(['success' => false, 'message' => "Field $field is required"]);
        exit;
    }
}

try {
    // Generate unique batch ID
    $batch_id = 'MBS-' . date('Y') . '-' . strtoupper(substr(bin2hex(random_bytes(4)), 0, 8));
    
    // Generate batch number if not provided
    $batch_number = $input['batch_number'] ?? 'BATCH-' . date('Ymd') . '-' . substr($batch_id, -4);
    
    // Generate secure QR token
    $qr_token = strtoupper(substr(hash('sha256', $input['product_name'] . '|' . $batch_number . '|' . microtime()), 0, 16));
    
    // Generate HMAC signature
    $qr_signature = hash_hmac('sha256', $qr_token, MBS_SECRET_KEY);
    
    // Insert batch record
    $stmt = $pdo->prepare("INSERT INTO product_batches (batch_id, product_name, batch_number, manufacturer_id, manufacture_date, expiry_date, qr_token, qr_signature, certification_status, is_active) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'certified', 1)");
    
    $result = $stmt->execute([
        $batch_id,
        $input['product_name'],
        $batch_number,
        $input['manufacturer_id'],
        $input['manufacture_date'],
        $input['expiry_date'],
        $qr_token,
        $qr_signature
    ]);

    if ($result) {
        // Construct QR payload URL
        $verify_url = BASE_URL . "/products/verify_batch.php?token=$qr_token&sig=$qr_signature";
        
        echo json_encode([
            'success' => true,
            'message' => 'Batch created successfully',
            'batch_id' => $batch_id,
            'qr_token' => $qr_token,
            'qr_url' => $verify_url,
            'batch_number' => $batch_number
        ]);
    } else {
        echo json_encode(['success' => false, 'message' => 'Failed to create batch']);
    }
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Database error: ' . $e->getMessage()]);
}
?>

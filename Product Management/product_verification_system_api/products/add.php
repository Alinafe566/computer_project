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

$required_fields = ['product_id', 'name', 'manufacturer', 'description', 'category', 'price', 'certification_status'];
foreach ($required_fields as $field) {
    if (!isset($input[$field]) || empty($input[$field])) {
        echo json_encode(['success' => false, 'message' => "Field $field is required"]);
        exit;
    }
}

try {
    // Generate unique QR code
    $qr_code = 'QR-' . $input['product_id'] . '-MBS-' . date('Y');
    
    $stmt = $pdo->prepare("INSERT INTO products (product_id, qr_code, name, manufacturer, manufacturer_phone, manufacturer_email, description, category, price, manufacturing_date, expiry_date, batch_number, certification_status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
    
    $result = $stmt->execute([
        $input['product_id'],
        $qr_code,
        $input['name'],
        $input['manufacturer'],
        $input['manufacturer_phone'] ?? null,
        $input['manufacturer_email'] ?? null,
        $input['description'],
        $input['category'],
        $input['price'],
        $input['manufacturing_date'] ?? null,
        $input['expiry_date'] ?? null,
        $input['batch_number'] ?? null,
        $input['certification_status']
    ]);

    if ($result) {
        echo json_encode([
            'success' => true, 
            'message' => 'Product added successfully',
            'qr_code' => $qr_code
        ]);
    } else {
        echo json_encode(['success' => false, 'message' => 'Failed to add product']);
    }
} catch (PDOException $e) {
    if ($e->getCode() == 23000) {
        echo json_encode(['success' => false, 'message' => 'Product ID already exists']);
    } else {
        echo json_encode(['success' => false, 'message' => 'Database error']);
    }
}
?>
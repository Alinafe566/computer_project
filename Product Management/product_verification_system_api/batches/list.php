<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

require_once '../config/db_connect.php';

try {
    $stmt = $pdo->prepare("SELECT pb.*, m.name as manufacturer_name FROM product_batches pb JOIN manufacturers m ON pb.manufacturer_id = m.id ORDER BY pb.created_at DESC");
    $stmt->execute();
    $batches = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        'success' => true,
        'batches' => $batches
    ]);
} catch(PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Database error']);
}
?>

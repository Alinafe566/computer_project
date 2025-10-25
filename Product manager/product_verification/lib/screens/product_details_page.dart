import 'package:flutter/material.dart';

class ProductDetailsPage extends StatelessWidget {
  final Map<String, dynamic> verificationResult;

  const ProductDetailsPage({super.key, required this.verificationResult});

  @override
  Widget build(BuildContext context) {
    final isAuthentic = verificationResult['is_authentic'] == true;
    final product = verificationResult['product'];
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Verification'),
        backgroundColor: isAuthentic ? Colors.green : Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isAuthentic ? Colors.green.shade100 : Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isAuthentic ? Colors.green : Colors.red,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    isAuthentic ? Icons.verified : Icons.warning,
                    size: 48,
                    color: isAuthentic ? Colors.green : Colors.red,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isAuthentic ? 'AUTHENTIC PRODUCT' : 'VERIFICATION FAILED',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isAuthentic ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    verificationResult['message'] ?? '',
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (product != null) ...[
              const Text(
                'Product Information:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildDetailCard(
                icon: Icons.shopping_bag,
                title: 'Product Name',
                value: product['name'] ?? 'Unknown',
              ),
              _buildDetailCard(
                icon: Icons.business,
                title: 'Manufacturer',
                value: product['manufacturer'] ?? 'Unknown',
              ),
              _buildDetailCard(
                icon: Icons.inventory,
                title: 'Batch Number',
                value: product['batch_number'] ?? 'N/A',
              ),
              _buildDetailCard(
                icon: Icons.calendar_today,
                title: 'Expiry Date',
                value: product['expiry_date'] ?? 'N/A',
              ),
              _buildDetailCard(
                icon: Icons.verified_user,
                title: 'Certification Status',
                value: product['certification_status'] ?? 'Unknown',
                valueColor: _getCertificationColor(product['certification_status']),
              ),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan Another Product'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: valueColor ?? Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCertificationColor(String? status) {
    if (status == null) return Colors.grey;
    if (status.contains('Certified')) return Colors.green;
    if (status.contains('Expired')) return Colors.orange;
    if (status.contains('Not Certified')) return Colors.red;
    return Colors.grey;
  }
}
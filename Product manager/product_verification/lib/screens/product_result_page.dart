import 'package:flutter/material.dart';

class ProductResultPage extends StatelessWidget {
  final Map<String, dynamic> scanResult;
  final bool isAuthentic;

  const ProductResultPage({
    super.key,
    required this.scanResult,
    required this.isAuthentic,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Result'),
        backgroundColor: isAuthentic ? const Color(0xFF2E7D32) : Colors.red,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Status Icon and Message
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: isAuthentic ? const Color(0xFF2E7D32) : Colors.red,
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                isAuthentic ? Icons.verified : Icons.dangerous,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isAuthentic ? 'AUTHENTIC PRODUCT' : 'COUNTERFEIT DETECTED',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isAuthentic ? const Color(0xFF2E7D32) : Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              isAuthentic 
                ? 'This product is verified and certified by MBS'
                : 'This product is not authentic or not found in our database',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Product Information Card
            if (isAuthentic && scanResult['product'] != null) ...[
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Product Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow('Product Name', scanResult['product']['name']),
                      _buildInfoRow('Manufacturer', scanResult['product']['manufacturer']),
                      _buildInfoRow('Category', scanResult['product']['category']),
                      _buildInfoRow('Batch Number', scanResult['product']['batch_number']),
                      _buildInfoRow('Certification', scanResult['product']['certification_status']),
                      if (scanResult['product']['expiry_date'] != null)
                        _buildInfoRow('Expiry Date', scanResult['product']['expiry_date']),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan Another Product'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (!isAuthentic)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/report-counterfeit');
                  },
                  icon: const Icon(Icons.report_problem),
                  label: const Text('Report Counterfeit'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
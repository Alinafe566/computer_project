import 'package:flutter/material.dart';
import 'report_counterfeit_page.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class ProductResultPage extends StatefulWidget {
  final Map<String, dynamic> scanResult;
  final bool isAuthentic;

  const ProductResultPage({
    super.key,
    required this.scanResult,
    required this.isAuthentic,
  });

  @override
  State<ProductResultPage> createState() => _ProductResultPageState();
}

class _ProductResultPageState extends State<ProductResultPage> {
  @override
  void initState() {
    super.initState();
    _logScan();
  }

  Future<void> _logScan() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      await ApiService.logScan(
        userId: authProvider.user!.id,
        batchId: widget.scanResult['product']?['batch_id'] ?? 'unknown',
        scanResult: widget.scanResult['status'] ?? 'fake',
        location: 'Mobile App',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Result'),
        backgroundColor: widget.isAuthentic ? const Color(0xFF2E7D32) : Colors.red,
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
                color: widget.isAuthentic ? const Color(0xFF2E7D32) : Colors.red,
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                widget.isAuthentic ? Icons.verified : Icons.dangerous,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _getStatusText(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _getStatusColor(),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              widget.isAuthentic 
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
            if (widget.isAuthentic && widget.scanResult['product'] != null) ...[
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
                      _buildInfoRow('Product Name', widget.scanResult['product']['name']),
                      _buildInfoRow('Manufacturer', widget.scanResult['product']['manufacturer']),
                      _buildInfoRow('Category', widget.scanResult['product']['category']),
                      _buildInfoRow('Batch Number', widget.scanResult['product']['batch_number']),
                      _buildInfoRow('Certification', widget.scanResult['product']['certification_status']),
                      if (widget.scanResult['product']['expiry_date'] != null)
                        _buildInfoRow('Expiry Date', widget.scanResult['product']['expiry_date']),
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
            if (!widget.isAuthentic)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReportCounterfeitPage(
                          productId: widget.scanResult['product']?['batch_id'],
                        ),
                      ),
                    );
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

  String _getStatusText() {
    final status = widget.scanResult['status'] ?? 'fake';
    switch (status) {
      case 'valid': return 'AUTHENTIC PRODUCT';
      case 'expired': return 'PRODUCT EXPIRED';
      default: return 'COUNTERFEIT DETECTED';
    }
  }

  Color _getStatusColor() {
    final status = widget.scanResult['status'] ?? 'fake';
    switch (status) {
      case 'valid': return const Color(0xFF2E7D32);
      case 'expired': return Colors.orange;
      default: return Colors.red;
    }
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
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'product_result_page.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  MobileScannerController controller = MobileScannerController();
  bool isScanning = true;
  String? lastScannedCode;

  Future<void> _verifyProduct(String qrCode) async {
    if (!isScanning || qrCode == lastScannedCode) return;
    
    setState(() {
      isScanning = false;
      lastScannedCode = qrCode;
    });
    
    // Parse QR code for token and signature
    String token = '';
    String? signature;
    
    if (qrCode.contains('token=')) {
      final uri = Uri.parse(qrCode);
      token = uri.queryParameters['token'] ?? '';
      signature = uri.queryParameters['sig'];
    } else {
      // Fallback: treat entire QR as token
      token = qrCode;
    }
    
    // Get user ID
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    
    final result = await ApiService.verifyProductBatch(
      token: token,
      signature: signature,
      userId: userId,
    );

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductResultPage(
          scanResult: result,
          isAuthentic: result['success'] == true && result['status'] == 'valid',
        ),
      ),
    );
    
    // Reset state when returning
    if (mounted) {
      setState(() {
        isScanning = true;
        lastScannedCode = null;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Product QR Code')),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: MobileScanner(
              controller: controller,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null) {
                    _verifyProduct(barcode.rawValue!);
                    break;
                  }
                }
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                isScanning ? 'Point camera at QR code' : 'Verifying...',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
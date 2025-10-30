import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static String get baseUrl {
    try {
      return dotenv.env['API_BASE_URL'] ??
          'http://localhost/product_verification_system_api';
    } catch (e) {
      return 'http://localhost/product_verification_system_api';
    }
  }

  static Future<Map<String, dynamic>> createBatch({
    required String productName,
    required int manufacturerId,
    required String manufactureDate,
    required String expiryDate,
    String? batchNumber,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/batches/create_batch.php'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'product_name': productName,
              'manufacturer_id': manufacturerId,
              'manufacture_date': manufactureDate,
              'expiry_date': expiryDate,
              if (batchNumber != null) 'batch_number': batchNumber,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<List<Map<String, dynamic>>> getBatches() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/batches/list.php'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return List<Map<String, dynamic>>.from(data['batches']);
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> testConnection() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/test_connection.php'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection failed: $e'};
    }
  }

  static Future<List<Map<String, dynamic>>> getCounterfeitReports() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reports/get_counterfeit.php'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return List<Map<String, dynamic>>.from(data['reports']);
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getManufacturers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/manufacturers/list.php'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return List<Map<String, dynamic>>.from(data['manufacturers']);
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/analytics/scan_stats.php'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return data['stats'];
        }
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  static Future<Map<String, dynamic>> updateReportStatus(
    int reportId,
    String status,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reports/update_status.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'report_id': reportId, 'status': status}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'success': false, 'message': 'Server error'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateManufacturerStatus(
    int manufacturerId,
    String action,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/manufacturers/update_status.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'manufacturer_id': manufacturerId, 'action': action}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'success': false, 'message': 'Server error'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<String> exportAnalyticsPDF() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/analytics/export_pdf.php'),
      );

      if (response.statusCode == 200) {
        return response.body;
      }
      return 'Export failed';
    } catch (e) {
      return 'Export error: $e';
    }
  }

  static Future<List<Map<String, dynamic>>> getAllProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/list.php'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return List<Map<String, dynamic>>.from(data['products']);
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> verifyProduct(String qrCode) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/products/verify.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'qr_code': qrCode}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'success': false, 'message': 'Server error'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> verifyBatch(String token, String signature) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/products/verify_batch.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token, 'sig': signature}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'success': false, 'message': 'Server error'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> addManufacturer(
    Map<String, dynamic> manufacturerData,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/manufacturers/add.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(manufacturerData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'success': false, 'message': 'Server error'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> addUser(
    Map<String, dynamic> userData,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/add.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'success': false, 'message': 'Server error'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> addPenalty(
    Map<String, dynamic> penaltyData,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/compliance/add_penalty.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(penaltyData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'success': false, 'message': 'Server error'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> scheduleAudit(
    Map<String, dynamic> auditData,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/compliance/schedule_audit.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(auditData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'success': false, 'message': 'Server error'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}

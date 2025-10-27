import 'package:flutter/material.dart';
import '../services/api_service.dart';

class BatchManagementPage extends StatefulWidget {
  const BatchManagementPage({super.key});

  @override
  State<BatchManagementPage> createState() => _BatchManagementPageState();
}

class _BatchManagementPageState extends State<BatchManagementPage> {
  final _formKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _manufactureDateController = TextEditingController();
  final _expiryDateController = TextEditingController();
  int _selectedManufacturerId = 1;
  bool _isLoading = false;
  String? _generatedBatchId;

  Future<void> _createBatch() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final data = await ApiService.createBatch(
        productName: _productNameController.text,
        manufacturerId: _selectedManufacturerId,
        manufactureDate: _manufactureDateController.text,
        expiryDate: _expiryDateController.text,
      );
      
      if (data['success']) {
        setState(() => _generatedBatchId = data['batch_id']);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Batch created: ${data['batch_id']}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connection error')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Product Batch'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _productNameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _selectedManufacturerId,
                decoration: const InputDecoration(
                  labelText: 'Manufacturer',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('TechCorp Ltd')),
                  DropdownMenuItem(value: 2, child: Text('Nature Foods')),
                ],
                onChanged: (value) => setState(() => _selectedManufacturerId = value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _manufactureDateController,
                decoration: const InputDecoration(
                  labelText: 'Manufacture Date (YYYY-MM-DD)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _expiryDateController,
                decoration: const InputDecoration(
                  labelText: 'Expiry Date (YYYY-MM-DD)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createBatch,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Create Batch & Generate QR'),
                ),
              ),
              if (_generatedBatchId != null) ...[
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('✅ Batch Created: $_generatedBatchId'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
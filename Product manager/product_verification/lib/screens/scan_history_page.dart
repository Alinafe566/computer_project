import 'package:flutter/material.dart';

class ScanHistoryPage extends StatefulWidget {
  const ScanHistoryPage({super.key});

  @override
  State<ScanHistoryPage> createState() => _ScanHistoryPageState();
}

class _ScanHistoryPageState extends State<ScanHistoryPage> {
  String _filter = 'all';

  final List<ScanRecord> _scanHistory = [
    ScanRecord(
      productName: 'Premium Headphones',
      manufacturer: 'TechCorp Ltd',
      scanDate: DateTime.now().subtract(const Duration(hours: 2)),
      result: 'authentic',
      productId: 'PRD001',
    ),
    ScanRecord(
      productName: 'Organic Green Tea',
      manufacturer: 'Nature Foods',
      scanDate: DateTime.now().subtract(const Duration(days: 1)),
      result: 'authentic',
      productId: 'PRD002',
    ),
    ScanRecord(
      productName: 'Unknown Product',
      manufacturer: 'Unknown',
      scanDate: DateTime.now().subtract(const Duration(days: 2)),
      result: 'not_found',
      productId: 'PRD999',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredHistory = _scanHistory.where((record) {
      if (_filter == 'all') return true;
      return record.result == _filter;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan History'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                _buildFilterChip('All', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('Authentic', 'authentic'),
                const SizedBox(width: 8),
                _buildFilterChip('Not Found', 'not_found'),
              ],
            ),
          ),
          Expanded(
            child: filteredHistory.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No scan history found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredHistory.length,
                    itemBuilder: (context, index) {
                      final record = filteredHistory[index];
                      return _buildHistoryCard(record);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return FilterChip(
      label: Text(label),
      selected: _filter == value,
      onSelected: (selected) {
        setState(() {
          _filter = value;
        });
      },
    );
  }

  Widget _buildHistoryCard(ScanRecord record) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (record.result) {
      case 'authentic':
        statusColor = Colors.green;
        statusIcon = Icons.verified;
        statusText = 'Authentic';
        break;
      case 'fake':
        statusColor = Colors.red;
        statusIcon = Icons.warning;
        statusText = 'Counterfeit';
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.help;
        statusText = 'Not Found';
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.1),
          child: Icon(statusIcon, color: statusColor),
        ),
        title: Text(record.productName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(record.manufacturer),
            Text(
              '${record.scanDate.day}/${record.scanDate.month}/${record.scanDate.year} ${record.scanDate.hour}:${record.scanDate.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class ScanRecord {
  final String productName;
  final String manufacturer;
  final DateTime scanDate;
  final String result;
  final String productId;

  ScanRecord({
    required this.productName,
    required this.manufacturer,
    required this.scanDate,
    required this.result,
    required this.productId,
  });
}
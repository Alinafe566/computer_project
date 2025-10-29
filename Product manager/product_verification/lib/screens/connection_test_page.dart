import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ConnectionTestPage extends StatefulWidget {
  const ConnectionTestPage({super.key});

  @override
  State<ConnectionTestPage> createState() => _ConnectionTestPageState();
}

class _ConnectionTestPageState extends State<ConnectionTestPage> {
  String connectionStatus = 'Testing...';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _testConnection();
  }

  Future<void> _testConnection() async {
    setState(() {
      isLoading = true;
      connectionStatus = 'Testing connection...';
    });

    try {
      final result = await ApiService.testConnection();
      setState(() {
        isLoading = false;
        if (result['success']) {
          connectionStatus = 'Connection successful!\nServer IP: ${result['server_ip']}\nTime: ${result['timestamp']}';
        } else {
          connectionStatus = 'Connection failed: ${result['message']}';
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        connectionStatus = 'Connection error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connection Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'API Connection Test',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    if (isLoading)
                      const CircularProgressIndicator()
                    else
                      Text(
                        connectionStatus,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: connectionStatus.contains('successful') ? Colors.green : Colors.red,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _testConnection,
              child: const Text('Test Again'),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Current Configuration:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Base URL: ${ApiService.baseUrl}'),
                    const Text('Network: WiFi'),
                    const Text('IP: 192.168.39.84'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
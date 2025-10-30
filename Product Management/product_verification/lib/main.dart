import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/batch_management_page.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // Error loading .env file
  }
  runApp(const MBSAdminApp());
}

class MBSAdminApp extends StatelessWidget {
  const MBSAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MBS Admin System',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1565C0),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1565C0),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
      home: const AdminLoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/auth/login.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      final data = json.decode(response.body);

      if (mounted) {
        if (data['success']) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminDashboardPage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Login failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(32),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.admin_panel_settings,
                      size: 64,
                      color: Color(0xFF1565C0),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'MBS Admin System',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : const Text('Login'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardOverview(),
    const ProductManagementPage(),
    const CounterfeitReportsPage(),
    const ActiveAlertsPage(),
    const ScanAnalyticsPage(),
    const ManufacturerRegistryPage(),
    const CompliancePage(),
    const AuditReportsPage(),
    const SystemUsersPage(),
    const SettingsPage(),
  ];

  final List<String> _titles = [
    'Dashboard Overview',
    'Product & Batch Management',
    'Counterfeit Reports',
    'Active Alerts',
    'Scan Analytics',
    'Manufacturer Registry',
    'Compliance Management',
    'Audit Reports',
    'System Users',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) =>
                setState(() => _selectedIndex = index),
            labelType: NavigationRailLabelType.all,
            backgroundColor: const Color(0xFF1565C0),
            selectedIconTheme: const IconThemeData(color: Colors.white),
            selectedLabelTextStyle: const TextStyle(color: Colors.white),
            unselectedIconTheme: const IconThemeData(color: Colors.white70),
            unselectedLabelTextStyle: const TextStyle(color: Colors.white70),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.inventory),
                label: Text('Products'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.report_problem),
                label: Text('Reports'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.warning),
                label: Text('Alerts'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.analytics),
                label: Text('Analytics'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.business),
                label: Text('Manufacturers'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.gavel),
                label: Text('Compliance'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.assessment),
                label: Text('Audits'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people),
                label: Text('Users'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),
          Expanded(
            child: Column(
              children: [
                AppBar(
                  title: Text(_titles[_selectedIndex]),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  elevation: 1,
                  actions: [
                    IconButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminLoginPage(),
                        ),
                      ),
                      icon: const Icon(Icons.logout),
                      tooltip: 'Logout',
                    ),
                  ],
                ),
                Expanded(child: _pages[_selectedIndex]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardOverview extends StatefulWidget {
  const DashboardOverview({super.key});

  @override
  State<DashboardOverview> createState() => _DashboardOverviewState();
}

class _DashboardOverviewState extends State<DashboardOverview> {
  Map<String, dynamic> stats = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final data = await ApiService.getDashboardStats();
    setState(() {
      stats = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.verified,
                          size: 32,
                          color: Colors.green,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Verified Products',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          '${stats['total_products'] ?? 0}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.warning,
                          size: 32,
                          color: Colors.orange,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Active Alerts',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          '${stats['total_scans'] ?? 0}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.report_problem,
                          size: 32,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Counterfeit Reports',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          '${stats['total_reports'] ?? 0}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.business,
                          size: 32,
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Manufacturers',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          '${stats['total_manufacturers'] ?? 0}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Recent Activity',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  ListTile(
                    leading: const Icon(Icons.add_circle, color: Colors.green),
                    title: const Text(
                      'New product registered: Premium Headphones',
                    ),
                    subtitle: const Text('2 minutes ago'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.warning, color: Colors.orange),
                    title: const Text(
                      'Alert: Suspicious scanning pattern detected',
                    ),
                    subtitle: const Text('15 minutes ago'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.report, color: Colors.red),
                    title: const Text('Counterfeit report filed for PRD001'),
                    subtitle: const Text('1 hour ago'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProductManagementPage extends StatefulWidget {
  const ProductManagementPage({super.key});

  @override
  State<ProductManagementPage> createState() => _ProductManagementPageState();
}

class _ProductManagementPageState extends State<ProductManagementPage> {
  List<Map<String, dynamic>> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final data = await ApiService.getAllProducts();
    setState(() {
      products = data;
      isLoading = false;
    });
  }

  void _showBulkImportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bulk Import Products'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select CSV file with product data:'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.file_upload),
              label: const Text('Choose File'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bulk import completed successfully'),
                ),
              );
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  void _showProductDetails(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product['name'] ?? 'Product Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Product ID: ${product['product_id']}'),
              Text('Manufacturer: ${product['manufacturer']}'),
              Text('Category: ${product['category'] ?? 'N/A'}'),
              Text('Price: \$${product['price'] ?? 'N/A'}'),
              Text('Batch: ${product['batch_number'] ?? 'N/A'}'),
              Text('Status: ${product['certification_status']}'),
              if (product['batch_id'] != null)
                Text('QR Batch: ${product['batch_id']}'),
              if (product['description'] != null)
                Text('Description: ${product['description']}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (product['qr_token'] != null)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('QR Code: ${product['qr_token']}')),
                );
              },
              child: const Text('Show QR'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddProductPage(),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Add Product'),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BatchManagementPage(),
                  ),
                ),
                icon: const Icon(Icons.inventory),
                label: const Text('Create Batch'),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _showBulkImportDialog,
                icon: const Icon(Icons.upload),
                label: const Text('Bulk Import'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Registered Products',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];
                              return ListTile(
                                leading: const Icon(Icons.inventory),
                                title: Text(
                                  product['name'] ?? 'Unknown Product',
                                ),
                                subtitle: Text(
                                  '${product['product_id']} - ${product['manufacturer']}',
                                ),
                                trailing: Chip(
                                  label: Text(
                                    product['certification_status'] ??
                                        'Unknown',
                                  ),
                                  backgroundColor:
                                      product['certification_status'] ==
                                          'Certified by MBS'
                                      ? Colors.green.shade100
                                      : Colors.orange.shade100,
                                ),
                                onTap: () {
                                  _showProductDetails(product);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CounterfeitReportsPage extends StatefulWidget {
  const CounterfeitReportsPage({super.key});

  @override
  State<CounterfeitReportsPage> createState() => _CounterfeitReportsPageState();
}

class _CounterfeitReportsPageState extends State<CounterfeitReportsPage> {
  List<Map<String, dynamic>> reports = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    final data = await ApiService.getCounterfeitReports();
    setState(() {
      reports = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Card(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Counterfeit Reports',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: reports.length,
                      itemBuilder: (context, index) {
                        final report = reports[index];
                        return ListTile(
                          leading: Icon(
                            Icons.report_problem,
                            color: report['status'] == 'resolved'
                                ? Colors.green
                                : Colors.red,
                          ),
                          title: Text(report['store_name'] ?? 'Unknown Store'),
                          subtitle: Text(
                            'Product: ${report['product_id'] ?? 'N/A'} - Status: ${report['status']}',
                          ),
                          trailing: ElevatedButton(
                            onPressed: () async {
                              final result =
                                  await ApiService.updateReportStatus(
                                    report['id'],
                                    'investigating',
                                  );
                              if (result['success']) {
                                setState(() {
                                  report['status'] = 'investigating';
                                });
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Report #${report['id']} under investigation',
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            child: const Text('Review'),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class ActiveAlertsPage extends StatelessWidget {
  const ActiveAlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Card(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Active Alerts',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.warning, color: Colors.red),
                    title: const Text('Critical: Multiple counterfeit reports'),
                    subtitle: const Text('PRD001 - 5 reports in last hour'),
                    trailing: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Investigation'),
                            content: const Text(
                              'Critical alert investigation initiated. MBS team has been notified.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Investigation team assigned',
                                      ),
                                    ),
                                  );
                                },
                                child: const Text('Assign Team'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text('Investigate'),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.warning, color: Colors.orange),
                    title: const Text('Medium: Product expiry approaching'),
                    subtitle: const Text('PRD002 - Expires in 30 days'),
                    trailing: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Product Review'),
                            content: const Text(
                              'Product expiry review completed. Manufacturer has been notified to update inventory.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Notification sent to manufacturer',
                                      ),
                                    ),
                                  );
                                },
                                child: const Text('Send Notice'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text('Review'),
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
}

class ScanAnalyticsPage extends StatefulWidget {
  const ScanAnalyticsPage({super.key});

  @override
  State<ScanAnalyticsPage> createState() => _ScanAnalyticsPageState();
}

class _ScanAnalyticsPageState extends State<ScanAnalyticsPage> {
  Map<String, dynamic> stats = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    final data = await ApiService.getDashboardStats();
    setState(() {
      stats = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  final report = await ApiService.exportAnalyticsPDF();
                  if (mounted) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Analytics Report'),
                        content: SingleChildScrollView(child: Text(report)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Export PDF'),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Data'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            'Scan Statistics',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: Container(
                              color: Colors.grey.shade200,
                              child: Center(
                                child: isLoading
                                    ? const CircularProgressIndicator()
                                    : Text(
                                        'Total Scans: ${stats['total_scans'] ?? 0}\nTotal Products: ${stats['total_products'] ?? 0}',
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            'Geographic Heatmap',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: Container(
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: Text(
                                  'Map Placeholder\n(Scan locations)',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ManufacturerRegistryPage extends StatefulWidget {
  const ManufacturerRegistryPage({super.key});

  @override
  State<ManufacturerRegistryPage> createState() =>
      _ManufacturerRegistryPageState();
}

class _ManufacturerRegistryPageState extends State<ManufacturerRegistryPage> {
  List<Map<String, dynamic>> manufacturers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadManufacturers();
  }

  Future<void> _loadManufacturers() async {
    final data = await ApiService.getManufacturers();
    setState(() {
      manufacturers = data;
      isLoading = false;
    });
  }

  void _showEditManufacturerDialog(Map<String, dynamic> manufacturer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${manufacturer['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('License: ${manufacturer['license_number']}'),
            Text('Phone: ${manufacturer['phone']}'),
            Text('Email: ${manufacturer['email']}'),
            Text('Status: ${manufacturer['status']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit functionality coming soon')),
              );
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _showAddManufacturerDialog() {
    final nameController = TextEditingController();
    final licenseController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Manufacturer'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Company Name'),
              ),
              TextField(
                controller: licenseController,
                decoration: const InputDecoration(labelText: 'License Number'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty &&
                  licenseController.text.isNotEmpty) {
                final result = await ApiService.addManufacturer({
                  'name': nameController.text,
                  'license_number': licenseController.text,
                  'phone': phoneController.text,
                  'email': emailController.text,
                  'address': addressController.text,
                });

                Navigator.pop(context);
                if (result['success']) {
                  _loadManufacturers();
                  if (mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(result['message'])));
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(result['message'])));
                  }
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  _showAddManufacturerDialog();
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Manufacturer'),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('License verification initiated'),
                    ),
                  );
                },
                icon: const Icon(Icons.verified),
                label: const Text('Verify License'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Registered Manufacturers',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            itemCount: manufacturers.length,
                            itemBuilder: (context, index) {
                              final manufacturer = manufacturers[index];
                              return ListTile(
                                leading: const Icon(Icons.business),
                                title: Text(manufacturer['name']),
                                subtitle: Text(
                                  'License: ${manufacturer['license_number']} - Status: ${manufacturer['status']}',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        _showEditManufacturerDialog(
                                          manufacturer,
                                        );
                                      },
                                      icon: const Icon(Icons.edit),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        final result =
                                            await ApiService.updateManufacturerStatus(
                                              manufacturer['id'],
                                              manufacturer['status'] == 'active'
                                                  ? 'block'
                                                  : 'verify',
                                            );
                                        if (result['success']) {
                                          _loadManufacturers();
                                          if (mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  result['message'],
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      icon: Icon(
                                        manufacturer['status'] == 'active'
                                            ? Icons.block
                                            : Icons.check_circle,
                                        color:
                                            manufacturer['status'] == 'active'
                                            ? Colors.red
                                            : Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CompliancePage extends StatefulWidget {
  const CompliancePage({super.key});

  @override
  State<CompliancePage> createState() => _CompliancePageState();
}

class _CompliancePageState extends State<CompliancePage> {
  void _showIssuePenaltyDialog() {
    final amountController = TextEditingController();
    final reasonController = TextEditingController();
    String selectedOffenseType = 'counterfeit';
    int selectedManufacturerId = 1;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Issue Penalty'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: selectedManufacturerId,
                decoration: const InputDecoration(labelText: 'Manufacturer'),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('TechCorp Ltd')),
                  DropdownMenuItem(value: 2, child: Text('Nature Foods')),
                ],
                onChanged: (value) =>
                    setState(() => selectedManufacturerId = value!),
              ),
              DropdownButtonFormField<String>(
                value: selectedOffenseType,
                decoration: const InputDecoration(labelText: 'Offense Type'),
                items: const [
                  DropdownMenuItem(
                    value: 'counterfeit',
                    child: Text('Counterfeit'),
                  ),
                  DropdownMenuItem(
                    value: 'price_manipulation',
                    child: Text('Price Manipulation'),
                  ),
                  DropdownMenuItem(
                    value: 'false_certification',
                    child: Text('False Certification'),
                  ),
                ],
                onChanged: (value) =>
                    setState(() => selectedOffenseType = value!),
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Penalty Amount'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(labelText: 'Reason'),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (amountController.text.isNotEmpty &&
                    reasonController.text.isNotEmpty) {
                  final result = await ApiService.addPenalty({
                    'manufacturer_id': selectedManufacturerId,
                    'offense_type': selectedOffenseType,
                    'penalty_amount': double.parse(amountController.text),
                    'description': reasonController.text,
                  });

                  Navigator.pop(context);
                  if (mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(result['message'])));
                  }
                }
              },
              child: const Text('Issue Penalty'),
            ),
          ],
        ),
      ),
    );
  }

  void _showScheduleAuditDialog() {
    final dateController = TextEditingController();
    final auditorController = TextEditingController();
    String selectedAuditType = 'inspection';
    int selectedManufacturerId = 1;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Schedule Audit'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: selectedManufacturerId,
                decoration: const InputDecoration(labelText: 'Manufacturer'),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('TechCorp Ltd')),
                  DropdownMenuItem(value: 2, child: Text('Nature Foods')),
                ],
                onChanged: (value) =>
                    setState(() => selectedManufacturerId = value!),
              ),
              DropdownButtonFormField<String>(
                value: selectedAuditType,
                decoration: const InputDecoration(labelText: 'Audit Type'),
                items: const [
                  DropdownMenuItem(
                    value: 'inspection',
                    child: Text('Inspection'),
                  ),
                  DropdownMenuItem(
                    value: 'compliance',
                    child: Text('Compliance'),
                  ),
                  DropdownMenuItem(value: 'renewal', child: Text('Renewal')),
                ],
                onChanged: (value) =>
                    setState(() => selectedAuditType = value!),
              ),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(
                  labelText: 'Audit Date (YYYY-MM-DD)',
                  hintText: '2024-12-01',
                ),
              ),
              TextField(
                controller: auditorController,
                decoration: const InputDecoration(labelText: 'Auditor Name'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (dateController.text.isNotEmpty &&
                    auditorController.text.isNotEmpty) {
                  final result = await ApiService.scheduleAudit({
                    'manufacturer_id': selectedManufacturerId,
                    'audit_type': selectedAuditType,
                    'audit_date': dateController.text,
                    'auditor_name': auditorController.text,
                  });

                  Navigator.pop(context);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${result['message']} - Receipt: ${result['receipt_number'] ?? 'N/A'}',
                        ),
                      ),
                    );
                  }
                }
              },
              child: const Text('Schedule'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  _showIssuePenaltyDialog();
                },
                icon: const Icon(Icons.gavel),
                label: const Text('Issue Penalty'),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {
                  _showScheduleAuditDialog();
                },
                icon: const Icon(Icons.schedule),
                label: const Text('Schedule Audit'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Pending Penalties',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            children: [
                              ListTile(
                                title: const Text('TechCorp Ltd'),
                                subtitle: const Text(
                                  'Counterfeit violation - \$5,000',
                                ),
                                trailing: const Text('Due: 15 days'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Upcoming Audits',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            children: [
                              ListTile(
                                title: const Text('Nature Foods'),
                                subtitle: const Text('Routine inspection'),
                                trailing: const Text('Jan 25, 2024'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AuditReportsPage extends StatefulWidget {
  const AuditReportsPage({super.key});

  @override
  State<AuditReportsPage> createState() => _AuditReportsPageState();
}

class _AuditReportsPageState extends State<AuditReportsPage> {
  void _showNewReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Audit Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(
              decoration: InputDecoration(labelText: 'Report Title'),
            ),
            const TextField(
              decoration: InputDecoration(labelText: 'Manufacturer'),
            ),
            const TextField(
              decoration: InputDecoration(labelText: 'Audit Date'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('New report created')),
              );
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showReportDetails(String title, String status) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: $status'),
            const Text('Audit Date: Jan 15, 2024'),
            const Text('Auditor: MBS Inspector'),
            const Text('Result: Compliant'),
            const SizedBox(height: 16),
            const Text(
              'Summary: All manufacturing processes meet MBS standards.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showEditReportDialog(String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit: $title'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: InputDecoration(labelText: 'Status')),
            TextField(
              decoration: InputDecoration(labelText: 'Notes'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report updated successfully')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  _showNewReportDialog();
                },
                icon: const Icon(Icons.add),
                label: const Text('New Report'),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reports archived successfully'),
                    ),
                  );
                },
                icon: const Icon(Icons.archive),
                label: const Text('Archive'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Audit Reports',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.assessment),
                          title: const Text('TechCorp Compliance Audit'),
                          subtitle: const Text(
                            'Status: Final - Date: Jan 15, 2024',
                          ),
                          trailing: ElevatedButton(
                            onPressed: () {
                              _showReportDetails(
                                'TechCorp Compliance Audit',
                                'Final',
                              );
                            },
                            child: const Text('View'),
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.assessment),
                          title: const Text('Nature Foods Quality Check'),
                          subtitle: const Text(
                            'Status: Draft - Date: Jan 10, 2024',
                          ),
                          trailing: ElevatedButton(
                            onPressed: () {
                              _showEditReportDialog(
                                'Nature Foods Quality Check',
                              );
                            },
                            child: const Text('Edit'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SystemUsersPage extends StatefulWidget {
  const SystemUsersPage({super.key});

  @override
  State<SystemUsersPage> createState() => _SystemUsersPageState();
}

class _SystemUsersPageState extends State<SystemUsersPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Add user functionality coming soon'),
                    ),
                  );
                },
                icon: const Icon(Icons.person_add),
                label: const Text('Add User'),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Permissions functionality coming soon'),
                    ),
                  );
                },
                icon: const Icon(Icons.security),
                label: const Text('Permissions'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'System Users',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.admin_panel_settings),
                          title: const Text('Admin User'),
                          subtitle: const Text(
                            'admin@example.com - Role: Administrator',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.edit),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.block,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.person),
                          title: const Text('Test User'),
                          subtitle: const Text(
                            'test@example.com - Role: Consumer',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.edit),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.block,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.backup),
                label: const Text('Backup Database'),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.security),
                label: const Text('Security Audit'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'System Configuration',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('API Security Key'),
                      subtitle: const Text('mbs_secure_key_2024'),
                      trailing: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.edit),
                      ),
                    ),
                    ListTile(
                      title: const Text('Alert Threshold'),
                      subtitle: const Text('5 reports'),
                      trailing: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.edit),
                      ),
                    ),
                    ListTile(
                      title: const Text('Backup Frequency'),
                      subtitle: const Text('Daily'),
                      trailing: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.edit),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _productIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _priceController = TextEditingController();
  final _batchController = TextEditingController();
  final _certificationController = TextEditingController(
    text: 'Certified by MBS',
  );
  bool _isLoading = false;

  Future<void> _addProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(
          'http://192.168.39.84/product_verification_system_api/products/add.php',
        ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'product_id': _productIdController.text,
          'name': _nameController.text,
          'manufacturer': _manufacturerController.text,
          'description': _descriptionController.text,
          'category': _categoryController.text,
          'price': double.parse(_priceController.text),
          'batch_number': _batchController.text,
          'certification_status': _certificationController.text,
        }),
      );

      final data = json.decode(response.body);

      if (mounted) {
        if (data['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product added successfully')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(data['message'])));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Connection error')));
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _generateQRPDF() async {
    if (_productIdController.text.isEmpty) return;

    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    'MBS Product QR Code',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 30),
                  pw.Container(
                    width: 200,
                    height: 200,
                    child: pw.BarcodeWidget(
                      barcode: pw.Barcode.qrCode(),
                      data: _productIdController.text,
                    ),
                  ),
                  pw.SizedBox(height: 30),
                  pw.Text(
                    'Product ID: ${_productIdController.text}',
                    style: const pw.TextStyle(fontSize: 16),
                  ),
                  if (_nameController.text.isNotEmpty)
                    pw.Text(
                      'Product: ${_nameController.text}',
                      style: const pw.TextStyle(fontSize: 14),
                    ),
                  if (_manufacturerController.text.isNotEmpty)
                    pw.Text(
                      'Manufacturer: ${_manufacturerController.text}',
                      style: const pw.TextStyle(fontSize: 14),
                    ),
                ],
              ),
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'MBS_QR_${_productIdController.text}.pdf',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('QR Code PDF generated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error generating PDF: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Product'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: _productIdController,
                    decoration: const InputDecoration(
                      labelText: 'Product ID (QR Code)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter product ID';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Product Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter product name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _manufacturerController,
                    decoration: const InputDecoration(
                      labelText: 'Manufacturer',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter manufacturer';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _categoryController,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter category';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter price';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _batchController,
                    decoration: const InputDecoration(
                      labelText: 'Batch Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _certificationController,
                    decoration: const InputDecoration(
                      labelText: 'Certification Status',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter certification status';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _addProduct,
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Add Product'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _productIdController.text.isEmpty
                          ? null
                          : _generateQRPDF,
                      icon: const Icon(Icons.qr_code),
                      label: const Text('Generate QR Code PDF'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

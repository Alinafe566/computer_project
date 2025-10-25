class Product {
  final String productId;
  final String name;
  final String manufacturer;
  final String description;
  final String category;
  final double price;
  final String? manufacturingDate;
  final String? expiryDate;
  final String? batchNumber;
  final bool isVerified;

  Product({
    required this.productId,
    required this.name,
    required this.manufacturer,
    required this.description,
    required this.category,
    required this.price,
    this.manufacturingDate,
    this.expiryDate,
    this.batchNumber,
    required this.isVerified,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['product_id'],
      name: json['name'],
      manufacturer: json['manufacturer'],
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      manufacturingDate: json['manufacturing_date'],
      expiryDate: json['expiry_date'],
      batchNumber: json['batch_number'],
      isVerified: json['is_verified'] == 1 || json['is_verified'] == true,
    );
  }
}
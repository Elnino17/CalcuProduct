// ignore_for_file: public_member_api_docs, sort_constructors_first
class Product {
  final int? id;
  final String name;
  double quantity; // Original quantity
  double quantityMultiplier; // Multiplier for quantity, initialize to 1
  final double price;
  int directTotalMultiplier;

  Product({
    // Initialize the direct input multiplier to 0
    this.id,
    required this.name,
    required this.quantity,
    required this.quantityMultiplier,
    required this.price,
    required this.directTotalMultiplier,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'quantityMultiplier': quantityMultiplier,
      'price': price,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    final int id = json['ID'] ??
        0; // Use a default value if 'ID' is missing or not an integer
    final String name =
        json['Name'] ?? ''; // Use an empty string if 'Name' is missing
    final double quantity = json['Qantity'] is int
        ? json['Qantity'].toDouble()
        : 0.0; // Convert to double with a default value of 0.0
    final double price = json['Prix'] is int
        ? json['Prix'].toDouble()
        : 0.0; // Convert to double with a default value of 0.0

    return Product(
      id: id,
      name: name,
      quantity: quantity,
      price: price,
      quantityMultiplier: 0.0,
      directTotalMultiplier: 0,
    );
  }
}

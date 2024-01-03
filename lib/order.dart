class Order {
  final String customerName;
  final List<String> orderDetails; // Change the type to List<String>
  final double total;

  Order({
    required this.customerName,
    required this.orderDetails, // Update the type here
    required this.total,
  });

  Map<String, dynamic> toJson() {
    return {
      'customerName': customerName,
      'orderDetails': orderDetails, // Update the field here
      'total': total,
    };
  }
}

class OrderDetail {
  final String productName;
  final int quantity; // Change this to quantity

  OrderDetail({
    required this.productName,
    required this.quantity, // Change this to quantity
  });

  Map<String, dynamic> toJson() {
    return {
      'productName': productName,
      'quantity': quantity, // Change this to quantity
    };
  }
}

import 'package:flutter/material.dart';
import 'product.dart';
import 'dart:convert'; // For JSON handling
import 'package:flutter/services.dart' show rootBundle;

class HomePageB extends StatefulWidget {
  const HomePageB({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePageB> {
  List<Product> products = [];
  List<TextEditingController> quantityControllers = [];
  List<TextEditingController> anotherInputControllers = [];
  double total = 0.0;
  String clientName = '';
  List<Order> orders = [];

  @override
  void initState() {
    super.initState();
    loadProductData();
    quantityControllers =
        List.generate(products.length, (_) => TextEditingController());
    anotherInputControllers =
        List.generate(products.length, (_) => TextEditingController());
  }

  Future<void> loadProductData() async {
    try {
      final String jsonText = await rootBundle.loadString('assets/data.json');
      final List<dynamic> productList = json.decode(jsonText);

      // Process and use the JSON data as needed
      final List<Product> products =
          productList.map((json) => Product.fromJson(json)).toList();
      setState(() {
        this.products = products;
        // Initialize controllers after the data is loaded
        quantityControllers =
            List.generate(products.length, (_) => TextEditingController());
        anotherInputControllers =
            List.generate(products.length, (_) => TextEditingController());
      });
    } catch (e) {
      print('Error loading JSON data: $e');
    }
  }

  Future<void> _calculateTotal() async {
    double calculatedTotal = 0.0;
    for (var product in products) {
      // ignore: unnecessary_null_comparison
      num multiplier = (product != null) ? product.quantityMultiplier : 1.0;
      calculatedTotal += (product.price * product.quantity * multiplier) +
          (product.directTotalMultiplier * product.price);
    }

    setState(() {
      total = calculatedTotal;
    });
  }

  void _clearAllData() {
    setState(() {
      for (var product in products) {
        product.quantityMultiplier = 0;
        product.directTotalMultiplier = 0;
      }
      // Clear the text in the TextFormFields using the controllers
      for (var controller in quantityControllers) {
        controller.clear();
      }
      for (var controller in anotherInputControllers) {
        controller.clear();
      }
      _calculateTotal();
    });
  }

  void _saveOrder() {
    // Ensure the client name is not empty
    if (clientName.isNotEmpty) {
      // Create an Order object with the client name and products
      Order order = Order(
        clientName: clientName,
        products: products
            .where((product) =>
                product.quantityMultiplier > 0 ||
                product.directTotalMultiplier > 0)
            .toList(),
      );

      // Add the order to the list of orders
      orders.add(order);

      // Clear the client name and product data
      setState(() {
        clientName = '';
        _clearAllData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Calculator'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _clearAllData,
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveOrder,
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              onChanged: (value) {
                setState(() {
                  clientName = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Client Name',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: ListTile(
                    leading: const Icon(
                        Icons.shopping_cart), // Add an icon for clarity
                    title: Padding(
                      padding: const EdgeInsets.only(
                          bottom: 8.0), // Add padding here
                      child: Text(
                        products[index].name,
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // ... Rest of the ListTile content remains the same
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(5.0),
            child: Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(
                  color: Colors.blue, // You can set the border color
                  width: 2.0, // You can set the border width
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                'Total: ${total.toStringAsFixed(2)} DA ',
                style: const TextStyle(
                    fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Order {
  final String clientName;
  final List<Product> products;

  Order({required this.clientName, required this.products});
}

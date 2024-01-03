import 'package:flutter/material.dart';
import 'product.dart';
import 'dart:convert'; // For JSON handling
import 'package:flutter/services.dart' show rootBundle;
import 'package:BadreCalcuter/order.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Product> products = [];
  List<Product> allProducts = [];
  List<TextEditingController> quantityControllers = [];
  List<TextEditingController> anotherInputControllers = [];
  TextEditingController customerNameController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  Map<Product, int> quantityMap = {};
  Map<Product, int> pieceMap = {};

  double total = 0.0;

  @override
  void initState() {
    super.initState();
    loadProductData();

    // Initialize controllers and maps after the data is loaded
    quantityControllers =
        List.generate(products.length, (_) => TextEditingController());
    anotherInputControllers =
        List.generate(products.length, (_) => TextEditingController());

    // Initialize maps with default values
    quantityMap = {for (var product in products) product: 0};
    pieceMap = {for (var product in products) product: 0};
  }

  Future<void> loadProductData() async {
    try {
      final String jsonText = await rootBundle.loadString('assets/data.json');
      final List<dynamic> productList = json.decode(jsonText);

      // Process and use the JSON data as needed
      final List<Product> products =
          productList.map((json) => Product.fromJson(json)).toList();

      // Initialize controllers and maps after the data is loaded
      setState(() {
        this.products = products;
        this.allProducts = List.of(products);
        quantityControllers = List.generate(
          products.length,
          (_) => TextEditingController(),
        );

        anotherInputControllers = List.generate(
          products.length,
          (_) => TextEditingController(),
        );

        // Initialize maps to associate products with quantity and piece values
        quantityMap = Map.fromIterable(
          products,
          key: (product) => product,
          value: (product) => 0, // Initialize quantities to 0
        );

        pieceMap = Map.fromIterable(
          products,
          key: (product) => product,
          value: (product) => 0, // Initialize piece values to 0
        );
      });
    } catch (e) {
      print('Error loading JSON data: $e');
    }
  }

  void _calculateTotal() {
    double calculatedTotal = 0.0;
    for (var product in products) {
      num multiplier = quantityMap[product] ?? 0;
      num pieceMultiplier = pieceMap[product] ?? 0;
      calculatedTotal += (product.price * product.quantity * multiplier) +
          (product.price * pieceMultiplier);
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

  void _searchProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        // If the search query is empty, show all products
        products = List.of(allProducts); // Restore all products
      } else {
        // Otherwise, filter products by name containing the query
        products = allProducts
            .where((product) =>
                product.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }

      // Update the quantityMap and pieceMap based on the filtered products
      quantityMap
          .removeWhere((product, quantity) => !products.contains(product));
      pieceMap.removeWhere((product, piece) => !products.contains(product));
    });
  }

  Future<void> saveOrder() async {
    try {
      String customerName = customerNameController.text.trim();
      if (customerName.isNotEmpty) {
        // Create a list of order details from the products
        List<String> orderDetails =
            []; // Use a list of strings for order details
        double orderTotal = 0.0; // Initialize the order total

        for (int index = 0; index < products.length; index++) {
          var product = products[index];
          var cartonQuantityValue =
              int.tryParse(quantityControllers[index].text) ?? 0;
          var pieceQuantityValue =
              int.tryParse(anotherInputControllers[index].text) ?? 0;

          if (cartonQuantityValue > 0 || pieceQuantityValue > 0) {
            // Format the product details as a string
            String productDetail = '${product.name}: ';
            if (cartonQuantityValue > 0) {
              productDetail += 'Carton: $cartonQuantityValue';
            }
            if (pieceQuantityValue > 0) {
              if (cartonQuantityValue > 0) {
                productDetail += ', ';
              }
              productDetail += 'Piece: $pieceQuantityValue';
            }

            orderDetails.add(productDetail);
            double productTotal = (product.price *
                (product.quantity * cartonQuantityValue + pieceQuantityValue));
            orderTotal += productTotal;
          }
        }
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final List<String> savedOrdersJson =
            prefs.getStringList('savedOrders') ?? [];
        Order order = Order(
          customerName: customerName,
          orderDetails: orderDetails,

          total: orderTotal, // Save the total in the order
        );
        savedOrdersJson.add(jsonEncode(order.toJson()));
        prefs.setStringList('savedOrders', savedOrdersJson);
      }
    } catch (e) {
      print('Error saving order: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Calculator'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: saveOrder,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _clearAllData,
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          TextField(
            controller: customerNameController,
            decoration: const InputDecoration(
              labelText: 'Customer Name',
              border: OutlineInputBorder(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: (query) {
                // Automatically update the product list as you type in the search bar
                _searchProducts(query);
              },
              decoration: const InputDecoration(
                labelText: 'Search Products',
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
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 8.0), // Add padding here
                          child: Text(
                            'Price: ${products[index].price.toStringAsFixed(2)} DA',
                            style: const TextStyle(fontSize: 16.0),
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            const Text(
                              'Carton : ',
                              style: TextStyle(fontSize: 16.0),
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: quantityControllers[index],
                                keyboardType: TextInputType.number,
                                style: const TextStyle(fontSize: 16.0),
                                onChanged: (newValue) {
                                  setState(() {
                                    quantityMap[products[index]] =
                                        int.tryParse(newValue) ?? 0;
                                    _calculateTotal();
                                  });
                                },
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    // Customize the border
                                    borderRadius: BorderRadius.circular(
                                        20), // Set the border radius
                                    borderSide: const BorderSide(
                                      // Set the border color and width
                                      color: Colors.blue,
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10.0), // Add some spacing
                            const Text(
                              'Piece : ',
                              style: TextStyle(fontSize: 16.0),
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: anotherInputControllers[index],
                                keyboardType: TextInputType.number,
                                style: const TextStyle(fontSize: 16.0),
                                onChanged: (newValue) {
                                  setState(() {
                                    pieceMap[products[index]] =
                                        int.tryParse(newValue) ?? 0;
                                    _calculateTotal();
                                  });
                                },
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    // Customize the border
                                    borderRadius: BorderRadius.circular(
                                        20), // Reduce the border radius
                                    borderSide: const BorderSide(
                                      // Set the border color and width
                                      color: Colors.blue,
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5.0), // Add some spacing
                        Text(
                          'Total Price: ${(products[index].price * (products[index].quantity * products[index].quantityMultiplier + products[index].directTotalMultiplier)).toStringAsFixed(2)} DA',
                          style: const TextStyle(fontSize: 16.0),
                        ),
                      ],
                    ),
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

import 'package:BadreCalcuter/HomePage.dart';
import 'package:BadreCalcuter/SavedOrder.dart';
import 'package:BadreCalcuter/order.dart';
import 'package:flutter/material.dart';

class OptionsPage extends StatelessWidget {
  final List<Order> savedOrders; // Define the list of saved orders

  const OptionsPage(
      {super.key, required this.savedOrders}); // Constructor to receive the saved orders

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Options Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Add logic for the first button here
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Add New Good Buy',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 16.0), // Add some spacing
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SavedOrdersPage(
                      savedOrders: savedOrders, // Pass the saved orders
                    ),
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'View Saved Good Buys',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

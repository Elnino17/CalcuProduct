import 'dart:convert';

import 'package:BadreCalcuter/OrderDetails.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'order.dart';

class SavedOrdersPage extends StatefulWidget {
  final List<Order> savedOrders;

  const SavedOrdersPage({Key? key, required this.savedOrders})
      : super(key: key);

  @override
  _SavedOrdersPageState createState() => _SavedOrdersPageState();
}

class _SavedOrdersPageState extends State<SavedOrdersPage> {
  Future<List<Map<String, dynamic>>> getSavedOrders() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<String>? savedOrdersJson = prefs.getStringList('savedOrders');
      if (savedOrdersJson != null) {
        return savedOrdersJson
            .map((jsonString) => json.decode(jsonString))
            .cast<Map<String, dynamic>>()
            .toList();
      }
    } catch (e) {
      print('Error getting saved orders: $e');
    }
    return [];
  }

  Future<void> deleteOrder(int index) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<String>? savedOrdersJson = prefs.getStringList('savedOrders');
      if (savedOrdersJson != null) {
        savedOrdersJson.removeAt(index);
        await prefs.setStringList('savedOrders', savedOrdersJson);
        setState(() {});
      }
    } catch (e) {
      print('Error deleting order: $e');
    }
  }

  void _showOrderDetailsDialog(Map<String, dynamic> orderData) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OrderDetailsScreen(orderData: orderData),
      ),
    );
  }

  void _showProductListDialog(List<String> orderDetails) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView.builder(
          itemCount: orderDetails.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(orderDetails[index]),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Orders'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getSavedOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final savedOrdersData = snapshot.data ?? [];
            return ListView.builder(
              itemCount: savedOrdersData.length,
              itemBuilder: (context, index) {
                final orderData = savedOrdersData[index];
                final customerName = orderData['customerName'];
                final orderDetailsData =
                    orderData['orderDetails'] as List<dynamic>;
                return GestureDetector(
                  onTap: () {
                    _showOrderDetailsDialog(orderData);
                  },
                  onLongPress: () {
                    _showProductListDialog(orderDetailsData.cast<String>());
                  },
                  child: Card(
                    margin: const EdgeInsets.all(8.0),
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: ListTile(
                      title: Text(customerName),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          // Add code here to delete the order
                          deleteOrder(index);
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

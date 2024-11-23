import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'food_item.dart';

class OrdersPage extends StatefulWidget {
  final String selectedDate;

  OrdersPage({required this.selectedDate});

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List<FoodItem> loadedOrders = [];

  @override
  void initState() {
    super.initState();
    _loadOrdersForDate();
  }

  // Load orders for the given date
  void _loadOrdersForDate() async {
    List<Map<String, dynamic>> orders = await DatabaseHelper.instance.getOrdersForDate(widget.selectedDate);
    if (orders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No orders found for this date')));
    } else {
      setState(() {
        loadedOrders.clear();
        orders.forEach((order) {
          loadedOrders.add(FoodItem(order[DatabaseHelper.columnFood], order[DatabaseHelper.columnCost]));
        });
      });
    }
  }

  // Show a dialog to update the food item
  void _showUpdateDialog(FoodItem item) {
    TextEditingController nameController = TextEditingController(text: item.foodName);
    TextEditingController costController = TextEditingController(text: item.cost.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Order'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Food Item'),
              ),
              TextField(
                controller: costController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: 'Cost'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                double newCost = double.tryParse(costController.text) ?? item.cost;
                if (nameController.text.isNotEmpty && newCost > 0) {
                  _updateOrder(item, nameController.text, newCost);
                  Navigator.pop(context); // Close the dialog after update
                }
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  // Update order details in the database
  void _updateOrder(FoodItem item, String newFoodName, double newCost) async {
    Map<String, dynamic> updatedRow = {
      DatabaseHelper.columnId: item.id,
      DatabaseHelper.columnFood: newFoodName,
      DatabaseHelper.columnCost: newCost,
      DatabaseHelper.columnDate: widget.selectedDate,
    };

    await DatabaseHelper.instance.updateOrder(updatedRow);

    setState(() {
      item.foodName = newFoodName;
      item.cost = newCost;
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order updated successfully')));
  }

  // Delete an order from the database
  void _deleteOrder(int index) async {
    await DatabaseHelper.instance.deleteOrder(loadedOrders[index].id);
    setState(() {
      loadedOrders.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order deleted successfully')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders for ${widget.selectedDate}'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: loadedOrders.isEmpty
            ? Center(child: Text('No orders found for this date'))
            : ListView.builder(
          itemCount: loadedOrders.length,
          itemBuilder: (context, index) {
            return Card(
              margin: EdgeInsets.symmetric(vertical: 5),
              child: ListTile(
                title: Text(loadedOrders[index].foodName),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        // Trigger the update dialog
                        _showUpdateDialog(loadedOrders[index]);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        // Trigger delete functionality
                        _deleteOrder(index);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

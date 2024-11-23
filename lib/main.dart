import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'food_item.dart';
import 'orders_page.dart'; // Import the new OrdersPage

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Ordering App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ),
      home: OrderPage(),
    );
  }
}

class OrderPage extends StatefulWidget {
  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  List<FoodItem> foodItems = [
    FoodItem('Steak & Mash', 12.99),
    FoodItem('Chicken & Rice', 8.50),
    FoodItem('Salad & Proteins', 6.99),
  ];

  List<FoodItem> selectedItems = [];
  double targetCost = 20.0;
  String selectedDate = '';
  final TextEditingController dateController = TextEditingController();

  // Save the order and add it to the database
  void _saveOrder() async {
    if (selectedDate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select a date')));
      return;
    }

    double totalCost = selectedItems.fold(0, (sum, item) => sum + item.cost);
    if (totalCost > targetCost) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Total cost exceeds target cost')));
      return;
    }

    for (var item in selectedItems) {
      Map<String, dynamic> row = {
        DatabaseHelper.columnFood: item.foodName,
        DatabaseHelper.columnCost: item.cost,
        DatabaseHelper.columnDate: selectedDate,
      };
      await DatabaseHelper.instance.insertOrder(row);
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order saved successfully')));
    setState(() {
      selectedItems.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Food Ordering App',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 10,
                color: Colors.blueAccent,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date input field
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent),
                borderRadius: BorderRadius.circular(8),
                color: Colors.blue.shade50,
              ),
              child: TextField(
                controller: dateController,
                decoration: InputDecoration(
                  labelText: 'Enter Date (e.g., 2024-11-22)',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                ),
                onChanged: (value) {
                  setState(() {
                    selectedDate = value;
                  });
                },
              ),
            ),
            SizedBox(height: 20),

            // Target cost slider
            Text('Target cost per day: \$${targetCost.toStringAsFixed(2)}'),
            Slider(
              value: targetCost,
              min: 0,
              max: 100,
              divisions: 100,
              label: targetCost.toStringAsFixed(2),
              onChanged: (value) {
                setState(() {
                  targetCost = value;
                });
              },
              activeColor: Colors.lightBlueAccent,
              inactiveColor: Colors.blueGrey,
            ),
            SizedBox(height: 20),

            // Food Items header
            Text(
              'Food Items:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: foodItems.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      color: selectedItems.contains(foodItems[index])
                          ? Colors.green.shade100
                          : (index % 2 == 0 ? Colors.white : Colors.grey.shade100),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Text(foodItems[index].foodName),
                      trailing: Text('\$${foodItems[index].cost.toStringAsFixed(2)}'),
                      onTap: () {
                        setState(() {
                          if (!selectedItems.contains(foodItems[index])) {
                            selectedItems.add(foodItems[index]);
                          } else {
                            selectedItems.remove(foodItems[index]);
                          }
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),

            // Buttons to Save and Load Orders
            ElevatedButton(
              onPressed: _saveOrder,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlueAccent),
              child: Text('Save Order'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedDate.isNotEmpty) {
                  // Navigate to the OrdersPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrdersPage(selectedDate: selectedDate),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select a date')));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlueAccent),
              child: Text('Load Orders for Date'),
            ),
          ],
        ),
      ),
    );
  }
}

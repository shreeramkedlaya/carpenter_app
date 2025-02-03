import 'package:carpenter_app/models/item_model.dart';
import 'package:flutter/material.dart';

import '../components/const.dart';

class OrderDetailsPage extends StatefulWidget {
  final List<Item> items;
  const OrderDetailsPage({super.key, required this.items});

  @override
  OrderDetailsPageState createState() => OrderDetailsPageState();
}

class OrderDetailsPageState extends State<OrderDetailsPage> {
  final Map<int, TextEditingController> _quantityControllers = {};

  // Method to handle checkbox changes and update item quantity
  void _onItemChanged(bool? newValue, int index) {
    setState(() {
      widget.items[index].isChecked = newValue!;
      if (widget.items[index].isChecked) {
        widget.items[index].quantity = 1;
      } else {
        widget.items[index].quantity = 0;
      }
    });
  }

  // Method to handle quantity changes
  void _onQuantityChanged(String value, int index) {
    setState(() {
      widget.items[index].quantity = int.tryParse(value) ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('Select Order Details', style: TextStyle(color: white)),
        ),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            onPressed: () {
              // Collect selected items and pass them back to the previous screen
              List<String> selectedItems = [];
              for (var i = 0; i < widget.items.length; i++) {
                if (widget.items[i].isChecked) {
                  selectedItems.add(
                      '${widget.items[i].name}(${widget.items[i].quantity})');
                }
              }
              Navigator.pop(context, selectedItems); // Pass data back
            },
            icon: Icon(Icons.check, color: white), // Done icon
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          // Initialize TextEditingController for each item if not already done
          if (!_quantityControllers.containsKey(index)) {
            _quantityControllers[index] = TextEditingController();
            _quantityControllers[index]!.text =
                widget.items[index].quantity.toString();
          }

          return Column(
            children: [
              ListTile(
                leading: Checkbox(
                  value: widget.items[index].isChecked,
                  onChanged: (bool? newValue) {
                    _onItemChanged(newValue, index);
                  },
                ),
                title: Text(widget.items[index].name),
                contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
              ),
              // Only display the TextField when the checkbox is checked
              if (widget.items[index].isChecked)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    children: [
                      Text('Quantity: ', style: TextStyle(fontSize: 16)),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _quantityControllers[index],
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            _onQuantityChanged(value, index);
                          },
                          decoration: InputDecoration(
                            hintText: 'Qty',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Divider(), // Adds the line separation between rows
            ],
          );
        },
      ),
    );
  }
}

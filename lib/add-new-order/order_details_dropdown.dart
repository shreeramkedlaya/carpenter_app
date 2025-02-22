import 'package:carpenter_app/models/item_model.dart';
import 'package:flutter/material.dart';

import '../components/const.dart';

class OrderDetailsDropdown extends StatefulWidget {
  final List<Item> items;
  const OrderDetailsDropdown({super.key, required this.items});

  @override
  OrderDetailsDropdownState createState() => OrderDetailsDropdownState();
}

class OrderDetailsDropdownState extends State<OrderDetailsDropdown> {
  List<String> selectedItems = [];
  final Map<int, TextEditingController> _quantityControllers = {};
  // Method to handle checkbox changes and update item quantity
  void _onItemChanged(bool? newValue, int index) {
    setState(() {
      widget.items[index].isChecked = newValue!;
      if (newValue) {
        widget.items[index].quantity = 1;
      } else {
        widget.items[index].quantity = 0;
        // set the controller to 1 when the checkbox is unchecked
        _quantityControllers[index]?.text = '1';
      }
    });
  }

// Method to handle quantity changes and update the controller
  void _onQuantityChanged(String value, int index) {
    setState(() {
      widget.items[index].quantity = int.tryParse(value) ?? 1;
      // Update the controller with the new value
      _quantityControllers[index]?.text = value;
    });
  }

  void _resetCheckBoxes() {
    setState(() {
      for (var i = 0; i < widget.items.length; i++) {
        widget.items[i].isChecked = false;
        widget.items[i].quantity = 0;
        _quantityControllers[i]?.clear(); // Clear quantity controllers
      }
    });
  }

  @override
  void dispose() {
    // Dispose of all TextEditingController instances
    for (var controller in _quantityControllers.values) {
      controller.dispose();
    }
    // Clear the map
    _quantityControllers.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('Select Order Details', style: TextStyle(color: white)),
        ),
        backgroundColor: kBlue800,
        actions: [
          IconButton(
            onPressed: () {
              // Collect selected items and pass them back to the previous screen

              for (var i = 0; i < widget.items.length; i++) {
                if (widget.items[i].isChecked) {
                  selectedItems.add(
                      '${widget.items[i].name}(${widget.items[i].quantity})');
                }
              }
              if (selectedItems.isEmpty) {
                // just pop
                Navigator.pop(context);
              } else {
                Navigator.pop(context, selectedItems); // Pass data back
              }
            },
            icon: Icon(Icons.check, color: white), // Done icon
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          // Initialize TextEditingController for each item if not already done
          if (!_quantityControllers.containsKey(index + 1)) {
            _quantityControllers[index] = TextEditingController();
            _quantityControllers[index]!.text =
                widget.items[index].quantity.toString();
          }

          return Column(
            children: [
              Row(
                children: [
                  Checkbox(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    activeColor: kBlue800,
                    value: widget.items[index].isChecked,
                    onChanged: (bool? newValue) {
                      _onItemChanged(newValue, index);
                    },
                  ),
                  Expanded(
                    child: Text(widget.items[index].name),
                  ),
                  // Only display the TextField when the checkbox is checked
                  if (widget.items[index].isChecked)
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, right: 14),
                      child: Row(
                        children: [
                          // Quantity TextField
                          Text('Qty: ', style: TextStyle(fontSize: 16)),
                          SizedBox(width: 1),
                          // Quantity TextField
                          Container(
                            width: 50,
                            height: 50,
                            child: TextField(
                              controller: _quantityControllers[index],
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                _onQuantityChanged(value, index);
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              Divider(),
              // reset button
              if (index == widget.items.length - 1)
                Container(
                  child: ElevatedButton(
                    onPressed: () {
                      _resetCheckBoxes();
                    },
                    child: Text('Reset'),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

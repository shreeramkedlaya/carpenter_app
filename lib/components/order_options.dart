import 'package:flutter/material.dart';

class OrderOption extends StatefulWidget {
  final String itemName;

  const OrderOption({super.key, required this.itemName});

  @override
  OrderOptionState createState() => OrderOptionState();
}

class OrderOptionState extends State<OrderOption> {
  bool isSelected = false;
  TextEditingController qtyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Checkbox(
              value: isSelected,
              onChanged: (bool? value) {
                setState(() {
                  isSelected = value ?? false;
                });
              },
            ),
            Text(widget.itemName),
          ],
        ),
        if (isSelected)
          Row(
            children: [
              Text('Qty: '),
              SizedBox(
                width: 50,
                child: TextField(
                  controller: qtyController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

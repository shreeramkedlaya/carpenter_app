import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/order_model.dart';

class OrderCard extends StatefulWidget {
  final Order order;

  const OrderCard({super.key, required this.order});

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  @override 
  Widget build(BuildContext context) {
    // Set the background color based on the order's status
    Color cardColor;
    switch (widget.order.status) {
      case 'Pending':
        cardColor = Colors.orange;
        break;
      case 'Started':
        cardColor = Colors.blue;
        break;
      case 'Ready':
        cardColor = Colors.green;
        break;
      case 'Delivered':
        cardColor = Colors.teal;
        break;
      case 'Hold':
        cardColor = Colors.grey;
        break;
      default:
        cardColor = Colors.white;
    }

    return Card(
      color: cardColor,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // Image on the left with 16px padding
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: Container(
                width: 100,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                      16), // Apply rounded corners to the image
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Check if the container is square
                      bool isSquare =
                          constraints.maxWidth == constraints.maxHeight;
                      return Container(
                        color: isSquare
                            ? Colors.white
                            : null, // Set white background if square
                        child: Image.asset(
                          'assets/profile.jpg',
                          fit: BoxFit.contain,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            // Order details displayed beside the image
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    // Display the order ID
                    widget.order.id,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Display the customer name
                  Text(
                    widget.order.customerName,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  // due date
                  Text(
                    'Due Date: ${DateFormat('yyyy-MM-dd').format(widget.order.dueDate)}',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),

                  // Order Status
                  Text(
                    "Order Status: ${widget.order.status}",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                ],
              ),
            ),

            // Arrow Icon on the right
            Icon(
              Icons.arrow_forward,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

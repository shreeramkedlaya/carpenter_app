import 'package:carpenter_app/components/const.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order_model.dart';
import 'vars.dart';

class OrderCard extends StatefulWidget {
  final Order order;

  const OrderCard({super.key, required this.order});

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  double getStatusProgress(String status) {
    switch (status) {
      case 'Pending':
        return 0.25;
      case 'Started':
        return 0.5;
      case 'Ready':
        return 0.75;
      case 'Delivered':
        return 1.0;
      case 'Hold':
        return 0.0;
      default:
        return 0.0;
    }
  }

  List<Color> statusColors = [
    kOrange800, // Color for 1st circle
    kBlue800, // Color for 2nd circle
    kGreen800, // Color for 3rd circle
    kTeal800, // Color for 4th circle
    Colors.grey, // Color for 5th circle
  ];
  @override
  Widget build(BuildContext context) {
    switch (widget.order.orderStatus) {
      case 'Pending':
        cardColor = kOrange800;
        break;
      case 'Started':
        cardColor = kBlue800;
        break;
      case 'Ready':
        cardColor = kGreen800;
        break;
      case 'Delivered':
        cardColor = kTeal800;
        break;
      case 'Hold':
        cardColor = Colors.grey;
        break;
      default:
        cardColor = white;
    }

    return Card(
      elevation: 2,
      surfaceTintColor: Colors.grey[150],
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // Image on the left with 16px padding
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: Container(
                width: 100,
                height: 125,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      bool isSquare =
                          constraints.maxWidth == constraints.maxHeight;
                      return Container(
                        decoration: BoxDecoration(shape: BoxShape.circle),
                        color: isSquare ? white : null,
                        child: Image.asset(
                          'assets/no_image_placeholder.png',
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
                  SizedBox(height: 4),

                  // Display the customer name
                  Row(
                    children: [
                      Text("Customer Name: "),
                      Text(
                        widget.order.customerName.length > 15
                            ? '${widget.order.customerName.substring(0, 15)}...'
                            : widget.order.customerName.isNotEmpty
                                ? widget.order.customerName
                                : 'N/A',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),

                  SizedBox(height: 4),

                  // due date
                  Row(
                    children: [
                      Text("Due Date: "),
                      Text(
                        DateFormat('yyyy-MM-dd').format(widget.order.orderDate),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 4),

                  // Order Status - Progress bar based on status
                  Row(
                    children: [
                      Text("Order Status: "),
                      SizedBox(width: 1),
                      Row(
                        children: widget.order.orderStatus == "Hold"
                            ? [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.orange
                                          .withAlpha((255 * 0.2).toInt()),
                                      radius: 15,
                                      child: Icon(
                                        Icons.pause,
                                        color: Colors.orange,
                                        size: 20,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "ON HOLD",
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )
                              ]
                            : List.generate(5, (index) {
                                double threshold = (index + 1) * 0.25;
                                return Padding(
                                  padding: EdgeInsets.only(
                                    left: 4,
                                    right: 8,
                                  ),
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.black, width: 0.5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey[200]!,
                                          blurRadius: 4,
                                          spreadRadius: 1,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: 6,
                                      backgroundColor: getStatusProgress(
                                                  widget.order.orderStatus) >=
                                              threshold
                                          ? statusColors[index]
                                          : Colors.grey[300],
                                    ),
                                  ),
                                );
                              }),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

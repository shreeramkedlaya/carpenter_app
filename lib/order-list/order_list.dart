import 'package:carpenter_app/components/order_card.dart';
import 'package:flutter/material.dart';

import '../components/const.dart';
import 'filter_tabs.dart';
import '../models/order_model.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  OrderListPageState createState() => OrderListPageState();
}

class OrderListPageState extends State<OrderListPage> {
  // Track the currently selected filter, defaulting to 'All'
  String? selectedFilter = 'All';

  // Dummy list of orders
  final List<Order> orders = [
    Order(
      DateTime(2025, 2, 3),
      id: '1',
      status: 'Pending',
      name: 'Pantry',
      customerName: 'qwerty',
      address: '',
    ),
    Order(
      DateTime(2025, 2, 3),
      id: '2',
      status: 'Started',
      name: 'Heater',
      customerName: 'asdfghj',
      address: '',
    ),
    Order(
      DateTime(2025, 2, 3),
      id: '3',
      status: 'Ready',
      name: 'Refurbish',
      customerName: 'jkl',
      address: '',
    ),
    Order(
      DateTime(2025, 2, 3),
      id: '4',
      status: 'Delivered',
      name: 'Polish',
      customerName: 'vbnm',
      address: '',
    ),
    Order(
      DateTime(2025, 2, 3),
      id: '5',
      status: 'Hold',
      name: 'Glass',
      customerName: 'yuiop',
      address: '',
    ),
  ];

  // Handle chip selection
  void _onFilterSelected(String filter) {
    setState(() {
      selectedFilter = (selectedFilter == filter) ? null : filter;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Order> filteredOrders = orders.where((order) {
      if (selectedFilter == null || selectedFilter == 'All') {
        return true; // Include all orders
      }
      return order.status == selectedFilter; // Include only matching orders
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order List',
          style: TextStyle(color: white),
        ),
        backgroundColor: Colors.blueAccent, // Lighter blue for the background
      ),
      body: Column(
        children: [
          // Top bar with scrollable filters
          Container(
            padding: EdgeInsets.all(8),
            color: white, // Light background for the filter area
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChipWidget(
                    label: 'All',
                    isSelected: selectedFilter == 'All',
                    onSelected: _onFilterSelected,
                  ),
                  FilterChipWidget(
                    label: 'Pending',
                    isSelected: selectedFilter == 'Pending',
                    onSelected: _onFilterSelected,
                  ),
                  FilterChipWidget(
                    label: 'Started',
                    isSelected: selectedFilter == 'Started',
                    onSelected: _onFilterSelected,
                  ),
                  FilterChipWidget(
                    label: 'Ready',
                    isSelected: selectedFilter == 'Ready',
                    onSelected: _onFilterSelected,
                  ),
                  FilterChipWidget(
                    label: 'Delivered',
                    isSelected: selectedFilter == 'Delivered',
                    onSelected: _onFilterSelected,
                  ),
                  FilterChipWidget(
                    label: 'Hold',
                    isSelected: selectedFilter == 'Hold',
                    onSelected: _onFilterSelected,
                  ),
                ],
              ),
            ),
          ),
          // Display the selected filter
          Expanded(
            child: ListView.builder(
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) {
                final order = filteredOrders[index];

                // Skip if the filter is set and the order doesn't match
                if (selectedFilter == null && order.status != selectedFilter) {
                  return Container();
                } else {
                  return OrderCard(order: order);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

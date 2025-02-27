import 'package:flutter/material.dart';
import '../components/const.dart';
import '../components/order_card.dart';
import '../components/vars.dart';
import 'filter_tabs.dart';
import '../models/order_model.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  OrderListPageState createState() => OrderListPageState();
}

class OrderListPageState extends State<OrderListPage> {
  // Handle chip selection
  void _onFilterSelected(String filter) {
    if (selectedFilter != filter) {
      setState(() {
        selectedFilter = (selectedFilter == filter) ? null : filter;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Order> orders = [];
    List<Order> filteredOrders = orders.where((order) {
      if (selectedFilter == null || selectedFilter == 'All') {
        return true; // Include all orders
      }
      return order.orderStatus ==
          selectedFilter; // Include only matching orders
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order List',
          style: TextStyle(color: white),
        ),
        backgroundColor: kBlue800,
      ),
      body: Column(
        children: [
          // Top bar with scrollable filters
          Container(
            padding: EdgeInsets.all(8),
            color: transparent, // Light background for the filter area
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
                      onSelected: _onFilterSelected),
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
                if (selectedFilter == null &&
                    order.orderStatus != selectedFilter) {
                  return Container();
                } else {
                  return OrderCard(order: filteredOrders[index]);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

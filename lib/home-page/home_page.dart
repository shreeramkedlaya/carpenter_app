// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:carpenter_app/components/const.dart';
import 'package:carpenter_app/home-page/graph/bar_graph.dart';
import 'package:carpenter_app/home-page/status_cards.dart';
import 'package:carpenter_app/order-list/order_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../add-new-order/new_order_page.dart';
import '../components/vars.dart';
import 'column_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (Platform.isAndroid) {
          SystemNavigator.pop();
          return false;
        } else if (Platform.isIOS) {
          exit(0);
        }
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'Carpenter App',
              style: TextStyle(color: white, fontSize: 20),
            ),
            backgroundColor: kBlue800,
          ),

          // drawer for navigation
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                UserAccountsDrawerHeader(
                  accountName: Text('Shreeram Kedlaya'),
                  accountEmail: Text('shreeram.kedlaya@example.com'),
                  currentAccountPicture: Container(
                    width: double.infinity, // Take full width of parent
                    height: double.infinity, // Take full height of parent
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/no_profile.png'),
                        fit: BoxFit
                            .cover, // Ensure the image covers the full area
                      ),
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: kBlue800,
                  ),
                ),

                // new order list tile
                ListTile(
                  leading: Icon(Icons.add_shopping_cart),
                  title: Text('New Order'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewOrderPage(),
                      ),
                    );
                  },
                ),
                // order list list_tile
                ListTile(
                  leading: Icon(Icons.list),
                  title: Text('Order List'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderListPage(),
                      ),
                    );
                  },
                ),
                // add new partner list tile
                ListTile(
                  leading: Icon(Icons.add),
                  title: Text('Add New Partner'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),

          // main page
          body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              // main column for page
              children: <Widget>[
                // total orders container
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: kBlue800,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  // column for blue container
                  child: Column(
                    children: [
                      Row(
                        // row for total orders and new order button
                        children: [
                          Text(
                            'Total Orders: 10',
                            style: TextStyle(fontSize: 18, color: white),
                          ),
                          Spacer(),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NewOrderPage(),
                                ),
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border: Border.all(color: white, width: 2.5),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Text(
                                  'New Order',
                                  style: TextStyle(fontSize: 16, color: white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      // row for overdue, jan, feb, mar, later
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue[700],
                            border: Border.all(color: white, width: 2.5),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              columnText('Overdue', '5'),
                              SizedBox(width: 10),
                              columnText('Jan', '5'),
                              SizedBox(width: 10),
                              columnText('Feb', '5'),
                              SizedBox(width: 10),
                              columnText('Mar', '5'),
                              SizedBox(width: 10),
                              columnText('Later', '5'),
                              SizedBox(width: 10),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                // customer orders this week
                Text(
                  'Customer Orders - This week',
                  style: TextStyle(color: black),
                ),
                SizedBox(height: 10),

                // row for cards
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        statusCards(context, '5', 'Due'),
                        SizedBox(width: 50),
                        statusCards(context, '5', 'Overdue'),
                        SizedBox(width: 50),
                        statusCards(context, '5', 'Urgent'),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        statusCards(context, '5', 'New'),
                        SizedBox(width: 50),
                        statusCards(context, '5', 'Delivered'),
                        SizedBox(width: 50),
                        statusCards(context, '5', 'Today'),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10),
                // customer orders status
                Text(
                  'Customer Orders - Status',
                  style: TextStyle(color: black),
                ),
                SizedBox(height: 10),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        statusCards(context, '5', 'Due'),
                        SizedBox(width: 50),
                        statusCards(context, '5', 'Overdue'),
                        SizedBox(width: 50),
                        statusCards(context, '5', 'Urgent'),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // bar graph text
                Center(
                  child: Text(
                    'Customer Orders - Chart',
                    style: TextStyle(color: black),
                  ),
                ),
                SizedBox(height: 10),
                // customer orders bar graph
                SizedBox(
                  height: 200,
                  width: MediaQuery.of(context).size.width,
                  child: MyBarGraph(weeklySummary: data),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

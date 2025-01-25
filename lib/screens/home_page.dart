import 'package:carpenter_app/components/const.dart';
import 'package:carpenter_app/components/graph/bar_graph.dart';
import 'package:carpenter_app/screens/new_order_page.dart';
import 'package:carpenter_app/widgets/status_cards.dart';
import 'package:flutter/material.dart';

import '../widgets/column_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // data for bar graph
  List<double> data = [
    1,
    5,
    10,
    15,
    20,
  ];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
                currentAccountPicture: CircleAvatar(
                  backgroundImage: AssetImage('assets/profile.jpg'),
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
                      builder: (context) => NewOrderPage(isEditMode: false),
                    ),
                  );
                },
              ),
              // order list list tile
              ListTile(
                leading: Icon(Icons.list),
                title: Text('Order List'),
                onTap: () {
                  Navigator.pop(context);
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
            // main container for page
            children: <Widget>[
              // total orders container
              Container(
                width: double.infinity,
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
                                builder: (context) =>
                                    NewOrderPage(isEditMode: false),
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
                        width: double.infinity,
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
              // spacer between container and text
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
    );
  }
}

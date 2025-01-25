import 'package:carpenter_app/components/const.dart';
import 'package:carpenter_app/screens/home_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Carpenter App',
      theme: ThemeData(
        primaryColor: kBlue800,
        appBarTheme: AppBarTheme(
          iconTheme:
              IconThemeData(color: white), // Custom color for the drawer icon
        ),
      ),
      home: HomePage(),
    );
  }
}

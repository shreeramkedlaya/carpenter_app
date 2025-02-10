import 'package:carpenter_app/components/const.dart';
import 'package:carpenter_app/home-page/home_page.dart';
import 'package:carpenter_app/sqlite-service/sqlite_service.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService().initDB();
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
          iconTheme: IconThemeData(
            color: white,
          ),
        ),
      ),
      home: HomePage(),
    );
  }
}

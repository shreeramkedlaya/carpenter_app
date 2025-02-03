import 'package:carpenter_app/components/const.dart';
import 'package:flutter/material.dart';

Widget statusCards(BuildContext context, String value, String text) {
  double width = MediaQuery.of(context).size.width / 3 - 50;
  return Material(
    elevation: 5,
    borderRadius: BorderRadius.circular(12.0),
    child: Container(
      width: width,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 16, color: kBlue800),
          ),
          Text(
            text,
            style: TextStyle(fontSize: 14, color: black),
          ),
        ],
      ),
    ),
  );
}

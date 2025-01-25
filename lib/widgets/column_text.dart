import 'package:carpenter_app/components/const.dart';
import 'package:flutter/material.dart';

Widget columnText(String text, String value) {
  return Column(
    children: [
      Text(
        value,
        style: TextStyle(fontSize: 14, color: white),
      ),
      Text(
        text,
        style: TextStyle(fontSize: 12, color: white),
      ),
    ],
  );
}

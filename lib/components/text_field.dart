import 'package:carpenter_app/components/const.dart';
import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final IconData? icon; // Optional icon parameter
  final String hintText;
  final bool readOnly;
  final TextEditingController? controller; // Optional controller parameter
  final TextInputType? keyboardType;

  const MyTextField({
    super.key,
    required this.hintText,
    this.icon,
    required this.readOnly,
    this.controller,
    this.keyboardType, // Initialize controller parameter
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: TextField(
        keyboardType: keyboardType,
        controller: controller, // Use the controller in the TextField
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: hintText, // Floating label
          floatingLabelBehavior:
              FloatingLabelBehavior.auto, // Label floats when focused
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: kBlue800),
          ),
          fillColor: white,
          filled: true,
          suffixIcon: icon != null
              ? Icon(
                  icon,
                  color: black,
                )
              : null, // Optional icon
        ),
      ),
    );
  }
}

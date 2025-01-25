import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePicker extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? icon;
  final bool readOnly;
  final DateTime initialDate;

  const DatePicker({
    super.key,
    required this.controller,
    required this.hintText,
    this.icon,
    this.readOnly = true,
    required this.initialDate,
  });

  // Function to show the DatePicker and update the controller with the selected date
  Future<void> _selectDate(BuildContext context) async {
    // Show DatePicker
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );

    // If a date is picked, format it and update the controller
    if (picked != null && picked != initialDate) {
      String formattedDate = DateFormat('dd-MM-yyyy').format(picked);
      controller.text = formattedDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format the date as 'dd-MM-yyyy'
    String formattedDate = DateFormat('dd-MM-yyyy').format(initialDate);
    controller.text = formattedDate; // Set the controller's initial text

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: TextField(
        controller: controller, // Use the controller in the TextField
        readOnly: readOnly, // Make the TextField read-only
        decoration: InputDecoration(
          labelText: hintText, // Floating label
          floatingLabelBehavior:
              FloatingLabelBehavior.auto, // Label floats when focused
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
          fillColor: Colors.grey[100],
          filled: true,
          suffixIcon: icon != null
              ? Icon(icon)
              : IconButton(
                  icon: Icon(Icons.calendar_today, color: Colors.grey),
                  onPressed: () =>
                      _selectDate(context), // Open Date Picker when tapped
                ),
        ),
      ),
    );
  }
}

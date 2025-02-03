import 'package:carpenter_app/add-new-order/status_model.dart';
import 'package:flutter/material.dart';

class StatusDropdown extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final List<Status> statuses;

  const StatusDropdown({
    required this.controller,
    required this.hintText,
    required this.statuses,
    super.key,
  });

  @override
  StatusDropdownState createState() => StatusDropdownState();
}

class StatusDropdownState extends State<StatusDropdown> {
  // Method to show the dropdown
  void _showDropdown(BuildContext context) async {
    final selectedStatus = await showDialog<Status>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select Order Status"),
          content: SingleChildScrollView(
            child: Column(
              children: widget.statuses.map(
                (status) {
                  return ListTile(
                    title: Text(status.text),
                    onTap: () {
                      Navigator.pop(context, status);
                    },
                  );
                },
              ).toList(),
            ),
          ),
        );
      },
    );

    if (selectedStatus != null) {
      setState(() {
        widget.controller.text = selectedStatus.text;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDropdown(context), // Trigger the dropdown on tap
      child: AbsorbPointer(
        child: TextField(
          controller: widget.controller,
          readOnly: true, // Make the text field read-only
          decoration: InputDecoration(
            labelText: widget.hintText,
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.keyboard_arrow_down), // Dropdown icon
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class FilterChipWidget extends StatefulWidget {
  final String label;
  final bool isSelected;
  final Function(String) onSelected;

  const FilterChipWidget({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  State<FilterChipWidget> createState() => _FilterChipWidgetState();
}

class _FilterChipWidgetState extends State<FilterChipWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          // FilterChip itself
          FilterChip(
            label: Text(widget.label),
            onSelected: (bool selected) {
              widget.onSelected(widget.label);
            },
            selectedColor: Colors.blueAccent,
            backgroundColor: Colors.grey[200],
            selected: widget.isSelected,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          if (widget.isSelected)
            Container(
              height: 2,
              width: 25, // Width of the underline, adjust as needed
              color: Colors.blueAccent, // Color of the underline
            ),
        ],
      ),
    );
  }
}

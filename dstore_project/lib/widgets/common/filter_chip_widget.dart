import 'package:flutter/material.dart';

class FilterChipWidget extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Function(bool) onSelected;
  final Color? color;
  final IconData? icon;

  const FilterChipWidget({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? Theme.of(context).primaryColor;
    
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : chipColor,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : chipColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: chipColor.withOpacity(0.1),
      selectedColor: chipColor,
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: chipColor.withOpacity(0.3),
        width: 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

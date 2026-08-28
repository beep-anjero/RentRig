import 'package:flutter/material.dart';
import 'package:rentrig/utils/app_colors.dart';

class CustomDropdown<T> extends StatelessWidget {
  final T value;
  final String labelText;
  final List<T> items;
  final Function(T?) onChanged;
  final String Function(T)? itemLabel;

  const CustomDropdown({
    super.key,
    required this.value,
    required this.labelText,
    required this.items,
    required this.onChanged,
    this.itemLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: AppDecorations.glassCard(radius: 12),
      child: DropdownButtonFormField<T>(
        initialValue: value,
        dropdownColor: AppColors.surface,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          border: InputBorder.none,
        ),
        items: items.map((item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(
              itemLabel != null ? itemLabel!(item) : item.toString(),
              style: const TextStyle(color: Colors.white),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

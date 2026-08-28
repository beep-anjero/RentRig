import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rentrig/utils/app_colors.dart';

class DatePickerButton extends StatelessWidget {
  final String label;
  final DateTime selectedDate;
  final VoidCallback onPressed;

  const DatePickerButton({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.calendar_today, color: AppColors.accent),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: AppColors.accent.withOpacity(0.4)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      ),
      label: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          Text(
            DateFormat('MMM dd').format(selectedDate),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

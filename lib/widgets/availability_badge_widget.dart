import 'package:flutter/material.dart';

class AvailabilityBadge extends StatelessWidget {
  final bool isAvailable;

  const AvailabilityBadge({
    super.key,
    required this.isAvailable,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: isAvailable
            ? Colors.green.withAlpha(25)
            : Colors.grey.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isAvailable ? Colors.green : Colors.grey,
        ),
      ),
      child: Text(
        isAvailable ? 'AVAILABLE' : 'UNAVAILABLE',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isAvailable ? Colors.green : Colors.grey,
        ),
      ),
    );
  }
}
